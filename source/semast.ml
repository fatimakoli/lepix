open Ast

type s_expr = 
|  	S_IntLit of int
|	S_BoolLit of bool
|	S_FloatLit of float
|	S_Id of string * typ
|	S_Call of string * s_expr list * typ
|	S_Access of string * s_expr list * typ
|	S_Binop of s_expr * op * s_expr * typ
|	S_Unop of uop * s_expr * typ
|	S_Assign of string * s_expr * typ
|	S_ArrayAssign of string * s_expr list * s_expr * typ
|	S_ArrayLit of s_expr list * typ
|	S_InitArray of string * s_expr list * typ
|	S_Noexpr

type s_var_decl
	= S_VarDecl of bind * s_expr

type s_stmt = 
|	S_Expr of s_expr * typ
|	S_Return of s_expr * typ
| 	S_If of s_expr * s_stmt * s_stmt
|	S_For of s_expr * s_expr * s_expr * s_stmt
|	S_While of s_expr * s_stmt
| 	S_Break
|	S_Continue
|	S_VarDecStmt of s_var_decl
|	S_Block of s_stmt list 

type s_func_decl = {
	func_name : string;
	func_parameters : bind list;
	func_return_type : typ;
	func_body : s_stmt list;	
}

type s_decl = 
|	S_Func of s_func_decl
|	S_Var of s_var_decl


type s_program = 	
	S_Prog of s_decl list	


type symbolTable = {
	parent_scope: symbolTable option;
	mutable vars: (typ * string) list;
}

type env = {
	mutable funcs: s_func_decl list;
	scope: symbolTable;
	return_type : typ;
	in_function_body : bool;
}
