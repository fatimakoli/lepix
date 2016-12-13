(* Top-level of the LePiX compiler: scan & parse the input,
   check the resulting AST, generate LLVM IR, and dump the module *)

type action = Ast | Sem | Compile

let _ = let action = if Array.length Sys.argv > 1 then
	List.assoc Sys.argv.(1) [ 
		("-a", Ast);	(* Print the AST only *)
		("-s", Sem);
		("-c", Compile) (* Generate, check LLVM IR *)
	]
	else Compile in	
	let lexbuf = Lexing.from_channel stdin in
	let ast = Parser.program Scanner.token lexbuf in
	let sast = Semant.check_prog ast in
	match action with
		Ast -> print_endline (Ast.string_of_program ast)
		| Sem -> print_endline "Semantic checking passed"; 
		| Compile -> let m = Codegen.generate sast in 
		Llvm_analysis.assert_valid_module m;
		print_endline (Llvm.string_of_llmodule m)
