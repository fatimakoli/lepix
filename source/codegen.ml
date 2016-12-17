module L = Llvm
module A = Ast
module S = Semast
module StringMap = Map.Make(String)

let generate (sprog) =
	let context = L.global_context () in
	let _le_module = L.create_module context "Lepix"
	and f32_t   = L.float_type   context
	and f64_t   = L.double_type  context
	and i8_t    = L.i8_type      context
	and char_t  = L.i8_type      context
	and i32_t   = L.i32_type     context
	and i64_t   = L.i64_type     context
	and bool_t  = L.i1_type      context
	and void_t  = L.void_type    context in	
	let rec ast_to_llvm_type = function
		| A.Bool -> bool_t
		| A.Int -> i32_t
		| A.Float -> f32_t
		| A.Void -> void_t
		| A.Array(t, d) -> L.array_type (ast_to_llvm_type t) d
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
			let param_types = Array.of_list (List.map (fun (_,t) -> ast_to_llvm_type t) fdecl.S.func_parameters)
		in let ftype = L.function_type (ast_to_llvm_type fdecl.S.func_return_type) param_types
		in StringMap.add fdecl.S.func_name (L.define_function fdecl.S.func_name ftype _le_module,fdecl) map
		in List.fold_left function_decl StringMap.empty sprog.S.functions
	in
	let function_body fdecl = 
		let (func,_) = StringMap.find fdecl.S.func_name function_decls
		in let builder = L.builder_at_end context (L.entry_block func) in

		let int_format_str = L.build_global_stringptr "%d\n" "fmt" builder in
	let local_vars = 
		let add_formals map (typ,name) p = L.set_value_name name p;
		let local = L.build_alloca (ast_to_llvm_type typ) name builder in
		ignore (L.build_store p local builder);
		StringMap.add name local map in
		
		let add_local map (typ,name) =
			let local_var = L.build_alloca (ast_to_llvm_type typ) name builder
			in StringMap.add name local_var map
		in 
		let params_list = List.map (fun (s,t) -> (t,s)) fdecl.S.func_parameters
		in
		let formals = List.fold_left2 add_formals StringMap.empty params_list (Array.to_list (L.params func)) 
		in
		let locals_list = List.map (fun (s,t) -> (t,s)) fdecl.S.func_locals in
		List.fold_left add_local formals locals_list in

	let lookup name = try StringMap.find name local_vars with Not_found -> StringMap.find name global_vars
	in
	let rec gen_expression sexpr builder = 
		match sexpr with
		  S.S_Id(s, typ) -> L.build_load (lookup s) s builder
		| S.S_BoolLit(value) -> L.const_int bool_t (if value then 1 else 0) (* bool_t is still an integer, must convert *)
		| S.S_IntLit(value) -> L.const_int i32_t value
		| S.S_FloatLit(value) -> L.const_float f32_t value
		| S.S_Call("print", [e], typ) -> L.build_call print_func [| int_format_str ; (gen_expression e builder) |] "printf" builder
		| S.S_Call(e, el,typ) -> let (fcode,fdecl) = StringMap.find e function_decls in
					 let actuals = List.rev (List.map (fun s -> gen_expression s builder) (List.rev el) )in
					 let result = (match fdecl.S.func_return_type with A.Void -> ""
											| _ -> e ^ "_result")
				          in L.build_call fcode (Array.of_list actuals) result builder
	
		| S.S_Access(e, el, typ) ->
			L.const_int i32_t 0
		| S.S_Binop(e1, op, e2, typ) ->
			let left = gen_expression e1 builder
			and right = gen_expression e2 builder in
			(
			match op with A.Add -> L.build_add
			|	      A.Sub -> L.build_sub
			|	      A.Mult -> L.build_mul 
			|	      A.Div -> L.build_sdiv
			|	      A.And -> L.build_and
			|	      A.Or -> L.build_or
			|	      A.Equal -> L.build_icmp L.Icmp.Eq
			|	      A.Neq -> L.build_icmp L.Icmp.Ne
			|	      A.Less -> L.build_icmp L.Icmp.Slt
			|             A.Leq -> L.build_icmp L.Icmp.Sle
		        |             A.Greater -> L.build_icmp L.Icmp.Sgt
			|	      A.Geq -> L.build_icmp L.Icmp.Sge
			) left right "tmp" builder
		| S.S_Unop(op, e1, typ) ->
			let exp = gen_expression  e1 builder in
			(
				match op with A.Neg -> L.build_neg
					      | A.Not -> L.build_not
			) exp "tmp" builder
		| S.S_Assign(s, e, typ) ->
				L.const_int i32_t 0
		| S.S_ArrayAssign(s, e1, e2, typ) ->
			L.const_int i32_t 0	
		| S.S_InitArray(s, el, e, typ) ->	(* L.const_int i32_t 0	 *)
											let arr = L.build_alloca [e x (ast_to_llvm_type typ)] in
											let pointer = L.bitcast L.pointer_type arr L.pointer_type (ast_to_llvm_type typ) in
											L.build_call void @llvm.memcpy.p0i8.p0i8.i64(i8* %2, i8* bitcast ([3 x i32]* @main.arr to i8*), i64 12, i32 4, i1 false)
											(* llvm for int arr[3] = {2,3,4};
											%arr = alloca [3 x i32], align 4
											%2 = bitcast [3 x i32]* %arr to i8*
  											call void @llvm.memcpy.p0i8.p0i8.i64(i8* %2, i8* bitcast ([3 x i32]* @main.arr to i8*)(*, i64 12, i32 4, i1 false) *)
											(* from PICEL:
											let arraystar_type = L.pointer_type (ast_to_llvm_type typ) in  
							                let cast_pointer = L.build_bitcast addr arraystar_type "c_ptr" builder in
							                let addr = L.build_in_bounds_gep cast_pointer (Array.make 1 e1') "elmt_addr" builder in 
							                ignore (L.build_store e2' addr builder); e2' *)
		| S.S_ArrayLit(el, typ) ->
			L.const_int i32_t 0
		| S.S_Noexpr ->
			L.const_int i32_t 0
	in
        let add_terminal builder e =
        	match L.block_terminator (L.insertion_block builder ) with
                Some _ -> ()
                | None -> ignore (e builder)	
	in
	let rec gen_statement s builder =
		match s with 
		  S.S_Expr(e, typ) -> ignore(gen_expression e builder); builder
		| S.S_Return(e, typ) -> ignore (match fdecl.S.func_return_type with A.Void -> L.build_ret_void builder
								| _ -> L.build_ret (gen_expression e builder) builder); builder
		| S.S_Block(sl) -> gen_stmt_list sl builder 
		| S.S_If(e, true_sl, false_sl) -> let cond = gen_expression e builder in
						  let merge_bb = L.append_block context "merge" func in
						  let then_bb = L.append_block context "then" func in
						  add_terminal (gen_statement true_sl (L.builder_at_end context then_bb))
                                                                (L.build_br then_bb);
						  let else_bb = L.append_block context "else" func in
						  add_terminal (gen_statement false_sl (L.builder_at_end context else_bb))
								(L.build_br merge_bb);

						  ignore(L.build_cond_br cond then_bb else_bb builder);
						  L.builder_at_end context merge_bb

		| S.S_For(inite, compe, incre, sl) -> gen_statement (S.S_Block [S.S_Expr(inite,A.Int); S.S_While (compe, 
								S.S_Block [sl ; S.S_Expr(incre,A.Int)])]) builder
		| S.S_While(expr, body) -> let pred_bb = L.append_block context "while" func in
						       ignore(L.build_br pred_bb builder);
					 let body_bb = L.append_block context "while_bod" func in
				 	 add_terminal (gen_statement body (L.builder_at_end context body_bb)) (L.build_br pred_bb);
				
					let pred_builder = L.builder_at_end context pred_bb in
					let bool_val = gen_expression expr pred_builder in
					let merge_bb = L.append_block context "merge" func in
					ignore(L.build_cond_br bool_val body_bb merge_bb pred_builder);
					L.builder_at_end context merge_bb 
		| S.S_VarDecStmt(v) -> builder	
	and 
	gen_stmt_list sl builder = 
		match sl with [] -> builder
			   |  hd::[] -> gen_statement hd builder
			   |  hd::tl -> ignore(gen_statement hd builder); gen_stmt_list tl builder 
	in
	let builder = gen_statement (S.S_Block fdecl.S.func_body) builder in 

	add_terminal builder (match fdecl.S.func_return_type with A.Void -> L.build_ret_void
				| t -> L.build_ret (L.const_int (ast_to_llvm_type t) 0))
	in
	List.iter function_body sprog.functions;
	_le_module 
