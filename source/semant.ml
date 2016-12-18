(* Semantic checking for the Lepix compiler *)

open Ast
open Semast

exception SemanticException of string

let rec check_dup l = match l with [] -> false 
                                  | hd::tl -> let x = (List.filter (fun x -> x = hd) tl ) in
                                  if (x == []) then
                                        check_dup tl
                                  else
                                        true
let rec list_if_uniq l = if (check_dup l) then raise(SemanticException("Duplicate arg names in func")) else l


let rec find_variable scope name = 
	try 
		List.find (fun (_,s) -> s = name) scope.vars
	with Not_found -> 
	(
		match scope.parent_scope 
	with Some(parent) -> 
		find_variable parent name
	| _ -> raise (SemanticException ("Undefined ID " ^ name))
	)

let rec list_compare l1 l2 = 
	match (l1,l2) with ([],[]) -> true
	| (hd1::tl1 , hd2::tl2) -> if hd1 = hd2 then list_compare tl1 tl2 else false
	| _ -> false

let get_expr_type sexpr = 
	match sexpr with S_IntLit(i) -> Int
	| S_BoolLit(b) -> Bool
	| S_FloatLit(f) -> Float
	| S_Id(s,typ) -> typ 
	| S_Call(s,el,typ) -> typ
	| S_Access(s,el,typ) -> typ
	| S_Binop(l,op,r,typ) -> typ
	| S_Unop(op,e,typ) -> typ
	| S_Assign(s,e,typ) -> typ
	| S_ArrayAssign(s,el,e,typ) -> typ
	| S_ArrayLit(el,typ) -> typ
	| S_InitArray(s,el,typ) -> typ
	| S_Noexpr -> Void

let rec check_expr e env =
        match e with
        IntLit(i) -> S_IntLit(i)
        | FloatLit(f) -> S_FloatLit(f)
        | BoolLit(b) -> S_BoolLit(b)
        | Id(x) -> (let (typ,var) = find_variable env.scope x in S_Id(var,typ))
        | Binop(l,op,r) -> check_binop l op r env
        | Unop(op,l) -> check_unop op l env
        | Call(s,el) -> check_call s el env
        | Access(s,el) -> check_access s el env
        | Assign(s,e) -> check_assign s e env
        | ArrayAssign(s,ind,exp) -> check_array_assign s ind exp env
        | InitArray(s,el) -> check_init_array s el env
        | ArrayLit(el) -> check_array_lit el env
        | Noexpr -> S_Noexpr


and check_binop l op r env =
	let sexpr_l = check_expr l env and
	sexpr_r = check_expr r env in 
	let ltyp = get_expr_type sexpr_l and
	rtyp = get_expr_type sexpr_r in
	if ltyp = rtyp then 
		match op with Add -> S_Binop(sexpr_l,op,sexpr_r,ltyp)
			    | Sub -> S_Binop(sexpr_l,op,sexpr_r,ltyp)
			    | Mult -> S_Binop(sexpr_l,op,sexpr_r,ltyp)
			    | Div -> S_Binop(sexpr_l,op,sexpr_r,ltyp)
			    | _ -> S_Binop(sexpr_l,op,sexpr_r,Bool)
	else  raise (SemanticException("Incompatible types"))
and check_unop op e env = 
	let sexp = check_expr e env in
	let sexp_typ = get_expr_type sexp in
	match sexp_typ with 
	Int -> (match op with Neg -> S_Unop(op,sexp,sexp_typ) | _ -> raise(SemanticException("Invalid operator")))
	| Float -> (match op with Neg -> S_Unop(op,sexp,sexp_typ) | _ -> raise(SemanticException("Invalid operator")))
	| Bool -> (match op with Not -> S_Unop(op,sexp,sexp_typ) | _ -> raise(SemanticException("Invalid operator")))
	| _ -> raise(SemanticException("Unary op on invalid type"))
and check_assign l r env =
	let (ltype,vname) = find_variable env.scope l
	and sexpr_r = check_expr r env in
	let rtype = get_expr_type sexpr_r in
	if ltype = rtype then S_Assign(vname,sexpr_r,ltype) else raise(SemanticException("Incompatible types in assignment"))
and check_expr_list el typ env =
	match el with  [] -> raise(SemanticException("Invalid array access"))
	| hd::[] -> let sexpr = check_expr hd env in if get_expr_type sexpr <> typ 
		then raise(SemanticException("Invalid array access")) 
		else sexpr::[]
	| hd::tl -> let sexpr = check_expr hd env in if get_expr_type sexpr <> typ 
		then raise(SemanticException("Invalid array access")) 
		else sexpr::check_expr_list tl typ env
and check_access s el env = 
	let (typ,name) = find_variable env.scope s and
	sexpr_list = check_expr_list el Int env in
	match typ with Ast.Array(t,il,d) -> S_Access(s,sexpr_list,t)
	| _ -> raise(SemanticException("Attempting array access in non-array"))
and create_sexpr_list el env =
	match el with  [] -> []
	| hd::tl -> (check_expr hd env)::(create_sexpr_list tl env)
	
and find_function env fname el =
        let sexpr_list_args = create_sexpr_list el env in
        let args_types_call = List.map get_expr_type sexpr_list_args in
        try
                let found = List.find ( fun f -> f.func_name = fname ) env.funcs in
                let formals_types = List.map fst found.func_parameters in
                if List.length args_types_call = List.length formals_types
                then (if list_compare args_types_call formals_types 
		      then found 
		      else raise(SemanticException("Incompatible args to func")))
                else raise(SemanticException("Wrong num of args to func"))
        with    Not_found -> raise(SemanticException("Undefined func called"))
and check_call s el env =
	let sfunc = find_function env s el in
	S_Call(s,create_sexpr_list el env,sfunc.func_return_type)
and check_array_assign s el e env = 
	let (atype,var) = find_variable env.scope s in
	let sexpr_index = check_expr_list el Int env and
	sexpr_assign = check_expr e env	in
	let assgn_type = get_expr_type sexpr_assign in
	if assgn_type = atype then S_ArrayAssign(s,sexpr_index,sexpr_assign,assgn_type) 
	else raise(SemanticException("Invalid type in array assign"))
and check_init_array s el env = 
	let (atype,name) = find_variable env.scope s in 
	let sexpr_assgn_list = check_expr_list el atype env in	
		S_InitArray(s,sexpr_assgn_list,atype) 
	
and check_array_lit el env = 
	let sexpr_list = create_sexpr_list el env  in
	let type_list = List.map get_expr_type sexpr_list  in
	match type_list with [] -> raise(SemanticException("Empty array lit"))
	| hd::_ -> S_ArrayLit(check_expr_list el hd env, hd)

let rec check_stmt st env = 
	match st with Expr(e) -> let sexpr = check_expr e env in let sexpr_typ = get_expr_type sexpr in S_Expr(sexpr,sexpr_typ) 
	| Return(e) -> check_return e env
	| Block(sl) -> let new_scope = { parent_scope = Some(env.scope); vars = []; } in
			let new_env = { env with scope = new_scope} in
			let stmt_list = List.map (fun s -> check_stmt s new_env) sl in
			new_scope.vars <- List.rev new_scope.vars;
			S_Block(stmt_list)
	| If(e,sl1,sl2) -> check_if e sl1 sl2 env
	| For(e1,e2,e3,sl) -> check_for e1 e2 e3 sl env
	| While(e,sl) -> check_while e sl env
	| Break -> S_Break
	| Continue -> S_Continue
	| VarDecStmt(VarDecl((name,typ),e)) -> check_var_decl name typ e env  
				

and check_return e env = 
	if not env.in_function_body then raise(SemanticException("Return used outside function body"))
	else 
	let sexpr = check_expr e env in
	let ret_typ = get_expr_type sexpr in
	if ret_typ = env.return_type then S_Return(sexpr,ret_typ)
	else raise(SemanticException("Incorrect return type"))

and check_if e sl1 sl2 env =
	let sexpr_cond = check_expr e env in
	let cond_typ = get_expr_type sexpr_cond
	and sstmt1 = check_stmt sl1 env 
	and sstmt2 = check_stmt sl2 env in
	if cond_typ = Bool then S_If(sexpr_cond,sstmt1,sstmt2)
	else raise(SemanticException("If condition does not evaluate to bool"))

and check_for e1 e2 e3 sl env = 
	let sexpr1 = check_expr e1 env 
	in let t1 = get_expr_type sexpr1 
	in let sexpr2 = check_expr e2 env
	in let t2 = get_expr_type sexpr2
	in let sexpr3 = check_expr e3 env
	in let t3 = get_expr_type sexpr3
	in if t1 <> Int && t1 <> Void then
		raise( SemanticException("For loop first expr of invalid type"))
	else (if t2 <> Bool && t2 <> Int then 
		raise (SemanticException("For loop second expr not of type bool"))
	else (if t3 <> Int then
		raise (SemanticException("For loop third expr not of type int"))
	else (let s = check_stmt sl env in S_For(sexpr1,sexpr2,sexpr3,s))))

and check_while e sl env = 
	let sexpr = check_expr e env
	in let sexpr_typ = get_expr_type sexpr
	in let s = check_stmt sl env in 
	if sexpr_typ <> Bool && sexpr_typ <> Int then raise(SemanticException("While condition has invalid type"))
	else S_While(sexpr,s)

and check_var_decl name typ e env =
        let sexpr = check_expr e env in
        let sexpr_typ = get_expr_type sexpr in 
        if List.exists (fun (_,vname) -> vname = name) env.scope.vars
        then raise(SemanticException("Variable has already been declared"))
        else 
	if sexpr_typ <> typ && sexpr_typ <> Void then raise(SemanticException("Invalid type assigned in declaration"))
	else if typ = Void then raise(SemanticException("Cannot have var of type void")) 
        else env.scope.vars <- (typ,name)::env.scope.vars; S_VarDecStmt(S_VarDecl((name,typ),sexpr))

let check_func_decl (fdecl : Ast.func_decl) env =	
	if env.in_function_body then
		raise (SemanticException("Nested function declaration"))
	else
		let f_env = { env with scope = {parent_scope = Some(env.scope); 
						vars = List.map (fun (name,typ) -> (typ,name)) fdecl.func_parameters;};
						return_type = fdecl.func_return_type; in_function_body = true} 
		in	
		if (fdecl.func_return_type = Void || 
			List.exists (fun x -> match x with Return(e) -> true | _ -> false) fdecl.func_body) 
		then let sfbody = List.map (fun s -> check_stmt s f_env) fdecl.func_body in	
		let sfdecl = {Semast.func_name = fdecl.func_name; 
						Semast.func_return_type = fdecl.func_return_type;
						Semast.func_parameters = List.map (fun (a,b) -> match b with 
									 Void -> raise(SemanticException("Void type for func arg"))
										   |_ -> (b,a))  (list_if_uniq fdecl.func_parameters);	
						Semast.func_body = sfbody;
						Semast.func_locals = List.map (fun x -> 
										match x with 
										S_VarDecStmt(S_VarDecl((name,typ),sexpr)) -> 
													(typ,name,sexpr)
										| _ -> raise(SemanticException("You're fucked"))
										) 
								     		(List.filter (fun decl ->  
											match decl with  
										S_VarDecStmt(S_VarDecl(t,sexpr)) ->
										 true 
										| _ -> false
										) sfbody);} 
		     in (		
			if List.exists (fun f -> sfdecl.func_name = f.func_name 
						&& list_compare sfdecl.func_parameters f.func_parameters) env.funcs
			then raise(SemanticException("Redefining function " ^ fdecl.func_name))
			else env.funcs <- sfdecl::env.funcs; sfdecl
			)
		else raise(SemanticException("No return stmt in func def" ^ fdecl.func_name))

let create_environment =
        let new_funcs = [{ Semast.func_return_type = Void;
			   Semast.func_name = "print";
			   Semast.func_parameters = [(Int,"a")];
			   Semast.func_body = [];
			   Semast.func_locals = [];
			};]
	in
        let new_scope = { parent_scope = None; vars = [];} in
        {
                Semast.funcs = new_funcs;
                scope = new_scope;
                return_type = Void;
                in_function_body = false;
        }

let check_decl env prog =
                let vars = List.filter (fun decl ->  match decl with Var(vdecl) -> true | _ -> false) prog
		and funs = List.filter (fun decl -> match decl with Func(decl) -> true | _ -> false) prog
		in 
		let globs = List.map (fun x -> match x with Var(vdecl) -> check_stmt (VarDecStmt(vdecl)) env
						            | _ -> raise(SemanticException("Func in vardecls list")) ) vars 
		and fdcls = List.map (fun x -> match x with Func(fdecl) -> check_func_decl fdecl env
							    | _ -> raise(SemanticException("Var in funcdecls list")) ) funs
		in
		{ Semast.globals = List.map (fun x -> match x with S_VarDecStmt(S_VarDecl((s,t),e)) -> (t,s,e)
							    | _ -> raise(SemanticException("Var in funcdecls list")) ) globs;
		  Semast.functions = fdcls 
		}

let check_prog prog =
        let env = create_environment in 
	let sprog = check_decl env prog 
	in
	if List.exists (fun f -> f.func_name = "main" && f.func_return_type = Int) env.funcs 
	then sprog
	else raise(SemanticException("Main function not defined"))
