(* Top-level of the LePiX compiler: scan & parse the input,
   check the resulting AST, generate LLVM IR, and dump the module *)

type action = Ast | Ir | Compile

let _ =
  let action = if Array.length Sys.argv > 1 then
    List.assoc Sys.argv.(1) [ ("-a", Ast);	(* Print the AST only *)
			      ("-l", Ir);  (* Generate LLVM, don't check *)
			      ("-c", Compile) ] (* Generate, check LLVM IR *)
  else Ir in
  let lexbuf = Lexing.from_channel stdin in
  let ast = Parser.program Scanner.token lexbuf in
  (* Semant.check ast; *) (* we don't have this yet *)
  match action with
    Ast -> print_string (Ast.string_of_program ast)
  | Ir -> print_string (Llvm.string_of_llmodule (Codegen.generate ast))
  | Compile -> let m = Codegen.generate ast in
    Llvm_analysis.assert_valid_module m;
    print_string (Llvm.string_of_llmodule m)
