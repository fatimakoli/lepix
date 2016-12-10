(* Semantic checking for the Lepix compiler *)

open Ast
open Semast

exception Error of string

let rec find_variable scope name = 
	try 
		List.find (fun (_,s) -> s = name) scope.vars
	with Not_found -> 
	(
		match scope.parent_scope 
	with Some(parent) -> 
		find_variable parent name
	| _ -> raise (Error ("Undefined ID " ^ name))
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
	if ltyp = rtyp then S_Binop(sexpr_l,op,sexpr_r,ltyp)
	else  raise (Error("Incompatible types"))
and check_unop op e env = 
	let sexp = check_expr e env in
	let sexp_typ = get_expr_type sexp in
	match sexp_typ with 
	Int -> (match op with Neg -> S_Unop(op,sexp,sexp_typ) | _ -> raise(Error("Invalid operator")))
	| Float -> (match op with Neg -> S_Unop(op,sexp,sexp_typ) | _ -> raise(Error("Invalid operator")))
	| Bool -> (match op with Not -> S_Unop(op,sexp,sexp_typ) | _ -> raise(Error("Invalid operator")))
	| _ -> raise(Error("Unary op on invalid type"))
and check_assign l r env =
	let (ltype,vname) = find_variable env.scope l
	and sexpr_r = check_expr r env in
	let rtype = get_expr_type sexpr_r in
	if ltype = rtype then S_Assign(vname,sexpr_r,ltype) else raise(Error("Incompatible types in assignment"))
and check_expr_list el typ env =
	match el with  [] -> raise(Error("Invalid array access"))
	| hd::[] -> let sexpr = check_expr hd env in if get_expr_type sexpr <> typ 
		then raise(Error("Invalid array access")) 
		else sexpr::[]
	| hd::tl -> let sexpr = check_expr hd env in if get_expr_type sexpr <> typ 
		then raise(Error("Invalid array access")) 
		else sexpr::check_expr_list tl typ env
and check_access s el env = 
	let (typ,name) = find_variable env.scope s and
	sexpr_list = check_expr_list el Int env in
	S_Access(s,sexpr_list,typ)
and create_sexpr_list el env =
	match el with  [] -> []
	| hd::tl -> (check_expr hd env)::(create_sexpr_list tl env)
	
and find_function env fname el =
        let sexpr_list_args = create_sexpr_list el env in
        let args_types_call = List.map get_expr_type sexpr_list_args in
        try
                let found = List.find ( fun f -> f.func_name = fname ) env.funcs in
                let formals_types = List.map snd found.func_parameters in
                if List.length args_types_call = List.length formals_types
                then (if list_compare args_types_call formals_types then found else raise(Error("Incompatible args to func")))
                else raise(Error("Wrong num of args to func"))
        with    Not_found -> raise(Error("Undefined func called"))
and check_call s el env =
	let sfunc = find_function env s el in
	S_Call(s,create_sexpr_list el env,sfunc.func_return_type)
and check_array_assign s el e env = 
	let (atype,var) = find_variable env.scope s in
	let sexpr_index = check_expr_list el atype env and
	sexpr_assign = check_expr e env	in
	let assgn_type = get_expr_type sexpr_assign in
	if assgn_type = atype then S_ArrayAssign(s,sexpr_index,sexpr_assign,assgn_type) else raise(Error("Invalid type in array assign"))
and check_init_array s el env = 
	let (atype,name) = find_variable env.scope s in 
	let sexpr_assgn_list = check_expr_list el atype env in	
		S_InitArray(s,sexpr_assgn_list,atype) 
	
and check_array_lit el env = 
	let sexpr_list = create_sexpr_list el env  in
	let type_list = List.map get_expr_type sexpr_list  in
	match type_list with [] -> raise(Error("Empty array lit"))
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
	if not env.in_function_body then raise(Error("Return used outside function body"))
	else 
	let sexpr = check_expr e env in
	let ret_typ = get_expr_type sexpr in
	if ret_typ = env.return_type then S_Return(sexpr,ret_typ)
	else raise(Error("Incorrect return type"))


and check_stmt_list sl env = 
	List.map (fun s -> check_stmt s env) sl

and check_if e sl1 sl2 env =
	let sexpr_cond = check_expr e env in
	let cond_typ = get_expr_type sexpr_cond
	and sstmt1 = check_stmt sl1 env 
	and sstmt2 = check_stmt sl2 env in
	if cond_typ = Bool then S_If(sexpr_cond,sstmt1,sstmt2)
	else raise(Error("If condition does not evaluate to bool"))

and check_for e1 e2 e3 sl env = 
	let sexpr1 = check_expr e1 env 
	in let t1 = get_expr_type sexpr1 
	in let sexpr2 = check_expr e2 env
	in let t2 = get_expr_type sexpr2
	in let sexpr3 = check_expr e3 env
	in let t3 = get_expr_type sexpr3
	in if t1 <> Int && t1 <> Void then
		raise( Error("For loop first expr of invalid type"))
	else (if t2 <> Bool && t2 <> Int then 
		raise (Error("For loop second expr not of type bool"))
	else (if t3 <> Int then
		raise (Error("For loop third expr not of type int"))
	else (let s = check_stmt sl env in S_For(sexpr1,sexpr2,sexpr3,s))))

and check_while e sl env = 
	let sexpr = check_expr e env
	in let sexpr_typ = get_expr_type sexpr
	in let s = check_stmt sl env in 
	if sexpr_typ <> Bool && sexpr_typ <> Int then raise(Error("While condition has invalid type"))
	else S_While(sexpr,s)

and check_var_decl name typ e env =
        let sexpr = check_expr e env in
        let sexpr_typ = get_expr_type sexpr in
        if List.exists (fun (_,vname) -> vname = name) env.scope.vars
        then raise(Error("Variable has already been declared"))
        else 
	if sexpr_typ <> typ && sexpr_typ <> Void then raise(Error("Invalid type assigned in declaration"))
        else env.scope.vars <- (typ,name)::env.scope.vars; S_VarDecStmt(S_VarDecl((name,typ),sexpr))

let check_return_exists (fdecl : Ast.func_decl) =
	match fdecl.func_return_type with Void -> true
	| _ -> List.exists (fun x -> match x with Return(e) -> true | _ -> false) fdecl.func_body	

let check_func_decl (fdecl : Ast.func_decl) env = 
	if env.in_function_body then
		raise (Error("Nested function declaration"))
	else
		let f_env = { env with scope = {parent_scope = Some(env.scope); vars = [];};
		return_type = fdecl.func_return_type; in_function_body = true} 
		in
		ignore(List.map (fun (name,typ) -> (typ,name)::f_env.scope.vars) fdecl.func_parameters);
		if (check_return_exists fdecl) then {Semast.func_name = fdecl.func_name; 
						Semast.func_return_type = fdecl.func_return_type;
						Semast.func_parameters = fdecl.func_parameters; 
						Semast.func_body = (check_stmt_list fdecl.func_body f_env);}
		else raise(Error("No return stmt in func def" ^ fdecl.func_name))

let create_environment =
        let new_funcs = [{ func_return_type = Void;
			   func_name = "print";
			   func_parameters = [("a",Int)];
			   func_body = [];
			};]
	in
        let new_scope = { parent_scope = None; vars = [];} in
        {
                funcs = new_funcs;
                scope = new_scope;
                return_type = Void;
                in_function_body = false;
        }

let check_decl env decl =
                match decl with Var(vdecl) -> let S_VarDecStmt(s) = check_stmt (VarDecStmt(vdecl)) env in S_Var(s)	
                | Func(fdecl) -> S_Func(check_func_decl fdecl env)

let check_prog prog =
        let env = create_environment in
        S_Prog(List.map (check_decl env) prog)
