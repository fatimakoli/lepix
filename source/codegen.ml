module L = Llvm
module A = Ast
module S = Semast
module StringMap = Map.Make(String)

exception CodegenError of string

let generate (sprog) =
	let context = L.global_context () in
	let _le_module = L.create_module context "Lepix"
	and f32_t   = L.float_type   context
	and f64_t   = L.double_type  context
	and i8_t    = L.i8_type      context
(*	and char_t  = L.i8_type      context *) 
	and i32_t   = L.i32_type     context
(*	and i64_t   = L.i64_type     context *)
	and bool_t  = L.i1_type      context
	and void_t  = L.void_type    context in	

	let compute_array_index d il = match d with 1 -> (List.nth il 0)
			 				| 2 -> (List.nth il 0) * (List.nth il 1)
							| 3-> (List.nth il 0) * (List.nth il 1) * (List.nth il 2)
							| _ -> raise(CodegenError("Too many dimensions"))
	in
	let rec ast_to_llvm_type = function
		| A.Bool -> bool_t
		| A.Int -> i32_t
		| A.Float -> f32_t
		| A.Void -> void_t
		| A.Array(t, il, d) -> L.array_type (ast_to_llvm_type t) (compute_array_index d il)
	in
	let global_vars = 
		let global_var map (typ,name) = 
			let init = L.const_int (ast_to_llvm_type typ) 0
			in StringMap.add name (L.define_global name init _le_module) map in
			let globals_list = List.map (fun (typ,s,e) -> (typ,s)) sprog.S.globals in
		List.fold_left global_var StringMap.empty globals_list
	in	
	let print_t = L.var_arg_function_type i32_t [| L.pointer_type i8_t |] in
		let print_func = L.declare_function "printf" print_t _le_module in
	
	let function_decls = 
		let function_decl map fdecl = 
			let param_types = Array.of_list (List.map (fun (t,s) -> ast_to_llvm_type t) fdecl.S.func_parameters)
		in let ftype = L.function_type (ast_to_llvm_type fdecl.S.func_return_type) param_types
		in StringMap.add fdecl.S.func_name (L.define_function fdecl.S.func_name ftype _le_module,fdecl) map
		in List.fold_left function_decl StringMap.empty sprog.S.functions
	in
	let function_body fdecl = 
		let (func,_) = StringMap.find fdecl.S.func_name function_decls
		in let builder = L.builder_at_end context (L.entry_block func) in

		let int_format_str = L.build_global_stringptr "%d\n" "fmt" builder in
	 let local_vars = 	
		let add_formals map (name,typ) p = L.set_value_name name p;
		let local = L.build_alloca (ast_to_llvm_type typ) name builder in
		ignore (L.build_store p local builder);
		StringMap.add name local map in
		
		let rec add_local map (name,typ,e) = let local_var = L.build_alloca (ast_to_llvm_type typ) name builder in		
							StringMap.add name local_var map
		in
                let params_list = List.map (fun (s,t) -> (t,s)) fdecl.S.func_parameters
                in
                let formals = List.fold_left2 add_formals StringMap.empty params_list (Array.to_list (L.params func))
                in
                let locals_list = List.map (fun (s,t,e) -> (t,s,e)) fdecl.S.func_locals in
                List.fold_left add_local formals locals_list

	
	in let lookup name = try StringMap.find name local_vars with Not_found -> StringMap.find name global_vars
	in let rec gen_expression sexpr builder = 
		match sexpr with
		  S.S_Id(s,typ) -> L.build_load (lookup s) s builder
		| S.S_BoolLit(value) -> L.const_int bool_t (if value then 1 else 0) (* bool_t is still an integer, must convert *)
		| S.S_IntLit(value) -> L.const_int i32_t value
		| S.S_FloatLit(value) -> L.const_float f32_t value
		| S.S_Call("print", [e], typ) -> L.build_call print_func [| int_format_str ; (gen_expression e builder) |] "printf" builder
		| S.S_Call("printb",[e], typ) -> L.build_call print_func [| int_format_str ; (gen_expression e builder) |] "printf" builder
		| S.S_Call("printf",[e],typ) -> let gen= gen_expression e builder in
						let double = L.build_fpext gen f64_t "dou" builder in
						 L.build_call print_func [| (L.build_global_stringptr "%.2f\n" "floatfmt" builder) ; 
										double |] "else" builder
		| S.S_Call("printppm", [e], typ) -> L.build_call print_func [| (L.build_global_stringptr "%s\n" "charfmt" builder); 
										(L.build_global_stringptr "P6\n4 4\n256\n0 0 0 100 0 0 0 0 0 255 0 255\n0 0 0 0 255 175 0 0 0 0 0 0\n0 0 0 0 0 0 0 15 175 0 0 0\n255 0 255 0 0 0 0 0 0 255 255 255" "str1" builder) |] "uhhh" builder;
						(* L.build_call print_func [| int_format_str; 
										(gen_expression e builder) |] "printppm" builder*)
						L.build_call print_func [| int_format_str; (gen_expression e builder) |] "printf" builder

		| S.S_Call(e, el,typ) -> let (fcode,fdecl) = StringMap.find e function_decls in
					 let actuals = List.rev (List.map (fun s -> gen_expression s builder) (List.rev el) )in
					 let result = (match fdecl.S.func_return_type with A.Void -> ""
											| _ -> e ^ "_result")
				          in L.build_call fcode (Array.of_list actuals) result builder
		| S.S_ArrayLit(el,typ) -> L.const_array (ast_to_llvm_type typ) (Array.of_list (List.map (fun x -> 
											gen_expression x builder) el))
													
		| S.S_Access(s, el,typ,A.Array(t,il,d)) -> (match d with 1 ->  let index = gen_expression (List.hd el) builder in
					    			 let index = L.build_add index (L.const_int i32_t 0) "tmp" builder in
					    			  let value = L.build_gep (lookup s) 
								  [| (L.const_int i32_t 0); index; |] "tmp" builder
								 in L.build_load value "tmp" builder

							| 2 -> let indexlist = List.map (fun x -> gen_expression x builder) el in
								let index = L.build_add (L.const_int i32_t 0) 
											(List.nth indexlist 1) "tmp" builder in
								let rows = L.build_mul (List.nth indexlist 0)  (L.const_int i32_t 
													(List.nth il 1)) "tmp2" builder
								in let index = L.build_add index rows "tmp" builder in  
								 let value = L.build_gep (lookup s)
								  [| (L.const_int i32_t 0); index |] "tmp" builder
								 in L.build_load value "tmp" builder
 
							| _ -> raise(CodegenError("Invalid dim number"))	
				 	    	)
		| S.S_Binop(e1, op, e2,A.Float) ->
                        let left = gen_expression e1 builder
                        and right = gen_expression e2 builder in
                        (
                        match op with A.Add -> L.build_fadd
                        |             A.Sub -> L.build_fsub
                        |             A.Mult -> L.build_fmul
                        |             A.Div -> L.build_fdiv 
                        |             A.Equal -> L.build_fcmp L.Fcmp.Ueq
                        |             A.Neq -> L.build_fcmp L.Fcmp.Une
                        |             A.Less -> L.build_fcmp L.Fcmp.Ult
                        |         A.Leq -> L.build_fcmp L.Fcmp.Ule
                    	|         A.Greater -> L.build_fcmp L.Fcmp.Ugt
                        |             A.Geq -> L.build_fcmp L.Fcmp.Uge
			| _ -> raise(CodegenError("Invalid operator for floats"))
                        ) left right "tmp" builder
		| S.S_Binop(e1, op, e2,typ) ->
                        let left = gen_expression e1 builder
                        and right = gen_expression e2 builder in
                        (
                        match op with A.Add -> L.build_add
                        |             A.Sub -> L.build_sub
                        |             A.Mult -> L.build_mul
                        |             A.Div -> L.build_sdiv
                        |             A.And -> L.build_and
                        |             A.Or -> L.build_or
                        |             A.Equal -> L.build_icmp L.Icmp.Eq
                        |             A.Neq -> L.build_icmp L.Icmp.Ne
                        |             A.Less -> L.build_icmp L.Icmp.Slt
                        |         A.Leq -> L.build_icmp L.Icmp.Sle
                        |         A.Greater -> L.build_icmp L.Icmp.Sgt
                        |             A.Geq -> L.build_icmp L.Icmp.Sge
                        ) left right "tmp" builder
		| S.S_Unop(op, e1, typ) ->
			let exp = gen_expression  e1 builder in
			(
				match op with A.Neg -> L.build_neg
					      | A.Not -> L.build_not
			) exp "tmp" builder
		| S.S_Assign(s, e, typ) -> let e' = gen_expression e builder in ignore(L.build_store e' (lookup s) builder); e'
							
		| S.S_ArrayAssign(s, el, e2, typ,A.Array(t,il,d)) -> (match d with 1 ->  let index = gen_expression (List.hd el) builder in
                                                                 let index = L.build_add index (L.const_int i32_t 0) "tmp" builder in
                                                                  let value = L.build_gep (lookup s)
                                                                  [| (L.const_int i32_t 0); index; |] "tmp" builder
                                                                 in L.build_store (gen_expression e2 builder) value builder 

                                                        | 2 -> let indexlist = List.map (fun x -> gen_expression x builder) el in
                                                                let index = L.build_add (L.const_int i32_t 0)
                                                                                        (List.nth indexlist 1) "tmp" builder in
                                                                let rows = L.build_mul (List.nth indexlist 0)  (L.const_int i32_t
                                                                                                        (List.nth il 1)) "tmp2" builder
                                                                in let index = L.build_add index rows "tmp" builder in
                                                                 let value = L.build_gep (lookup s)
                                                                  [| (L.const_int i32_t 0); index |] "tmp" builder
                                                                 in L.build_store (gen_expression e2 builder) value builder

                                                        | _ -> raise(CodegenError("Invalid dim number"))
 
						 	)			

		| S.S_ArrayLit(el, typ) -> L.const_array (ast_to_llvm_type typ) (Array.of_list 
								(List.map (fun x-> gen_expression x builder) el))
	
		| S.S_Noexpr ->
			L.const_int i32_t 0

		| _ -> L.const_int i32_t 0	

	in 
	let global= 
	let globals (typ, s, e) = 
		match typ with A.Array(t,il,d) -> if e = S.S_Noexpr then ()
							else let e' = gen_expression e builder
								in ignore(L.build_store e' ( StringMap.find s global_vars) builder );
								ignore(e'); 
				| _ -> (match e with S.S_Noexpr -> () 
							| _ -> let e' = gen_expression e builder in 
							ignore(L.build_store e' (StringMap.find s global_vars) builder); 
							ignore (e');) 
	
	in List.iter globals sprog.S.globals

	in	
        let add_terminal builder e =
        	match L.block_terminator (L.insertion_block builder ) with
                Some _ -> ()
                | None -> ignore (e builder)	
	in
	let rec gen_statement builder s =
		match s with 
		  S.S_Expr(e, typ) -> ignore(gen_expression e builder); builder
		| S.S_Return(e, typ) -> ignore (match fdecl.S.func_return_type with A.Void -> L.build_ret_void builder
								| _ -> L.build_ret (gen_expression e builder) builder); builder
		| S.S_Block(sl) -> gen_stmt_list sl builder 
		| S.S_If(e, then_expr, else_expr) -> let cond = gen_expression e builder in
								let start_bb = L.insertion_block builder in
								let func = L.block_parent start_bb in
							 	let then_bb = L.append_block context "then" func in
								L.position_at_end then_bb builder;

								let _ = gen_statement builder then_expr in
								let new_then_bb = L.insertion_block builder in  
								let else_bb = L.append_block context "else" func in
		                        L.position_at_end else_bb builder;
								(* add_terminal (gen_statement  (L.builder_at_end context true_bb) then_stmt )
		                                                            (L.build_br merge_bb); *)
		                        
		                        let _ = gen_statement builder else_expr in
		                        let new_else_bb = L.insertion_block builder in
		                        let merge_bb = L.append_block context "ifcont" func in
		                        L.position_at_end merge_bb builder;

		                        (* let incoming = [(then_val, new_then_bb); (else_val, new_else_bb)] in
		                        let phi = L.build_phi incoming "iftmp" builder in *)
		                        let else_bb_val = L.value_of_block new_else_bb in
		                        L.position_at_end start_bb builder;

		                        ignore (L.build_cond_br cond then_bb else_bb builder);

		                        L.position_at_end new_then_bb builder; ignore (L.build_br merge_bb builder);
		                        L.position_at_end new_else_bb builder; ignore (L.build_br merge_bb builder);

		                        L.position_at_end merge_bb builder;

		                        (* phi *)
		                    	ignore(else_bb_val); builder
								(* let false_bb = L.append_block context "else" func in 
								add_terminal (gen_statement (L.builder_at_end context false_bb) else_stmt)
									(L.build_br merge_bb);

								ignore(L.build_cond_br cond true_bb false_bb builder);
								L.builder_at_end context merge_bb *)
	
		| S.S_For(inite, compe, incre, sl) ->	
				                      let the_function = L.block_parent (L.insertion_block builder) in
						      let _ = gen_expression inite builder in
						      let loop_bb = L.append_block context "loop" the_function in
						      let inc_bb = L.append_block context "inc" the_function in
						      let cond_bb = L.append_block context "cond" the_function in
				                      let after_bb = L.append_block context "afterloop" the_function in

						      
						      
						 
						 
						      ignore(L.build_br cond_bb builder);
					              L.position_at_end loop_bb builder;
					              ignore(gen_statement builder sl);

						      let bb = L.insertion_block builder in
					              L.move_block_after bb inc_bb;
		                                      L.move_block_after inc_bb cond_bb;
						      L.move_block_after cond_bb after_bb;
                                                      ignore(L.build_br inc_bb builder);

						      L.position_at_end inc_bb builder;
						      let _ = gen_expression incre builder in
						      ignore(L.build_br cond_bb builder);

						      L.position_at_end cond_bb builder;

						      let cond_val = gen_expression compe builder in
						      ignore(L.build_cond_br cond_val loop_bb after_bb builder);

						      L.position_at_end after_bb builder;
						      				  
						      builder;

		| S.S_While(expr, body) -> let null_expr = S.S_IntLit(0) in
					   gen_statement builder (S.S_For(null_expr,expr,null_expr,body))
	
		| S.S_Break -> builder
                | S.S_Continue -> builder
			   	
		| S.S_VarDecStmt(S.S_VarDecl((name,typ),sexpr)) -> 
								match typ with A.Array(t,il,d) -> if sexpr = S.S_Noexpr then builder
									else 
									let e' = gen_expression sexpr builder
									in ignore(L.build_store e' (lookup name) builder );
									ignore(e'); builder 
								| _ -> (match sexpr with S.S_Noexpr -> builder  
									| _ -> let e' = gen_expression sexpr builder in 
									ignore(L.build_store e' (lookup name) builder); 
									ignore(e'); builder)
	and 
	gen_stmt_list sl builder = 
		match sl with [] -> builder
			   |  hd::[] -> gen_statement builder hd
			   |  hd::tl -> ignore(gen_statement builder hd); gen_stmt_list tl builder
	in
	let builder = gen_statement builder (S.S_Block fdecl.S.func_body) in 

	add_terminal builder (match fdecl.S.func_return_type with A.Void -> L.build_ret_void

				| t -> L.build_ret (L.const_int (ast_to_llvm_type t) 0))
	in	
	List.iter function_body sprog.S.functions;	
	_le_module 

