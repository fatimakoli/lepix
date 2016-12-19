#Build top level lepix executable
lepix :
	ocamlbuild -use-ocamlfind -pkgs llvm,llvm.analysis lepix.native

#Clean intermediate files
clean :
	ocamlbuild -clean
	rm -rf ../testall.log ../*.err ../*.diff ../*.ll lepix scanner.ml parser.ml parser.mli
	rm -rf *.cmx *.cmi *.cmo *.cmx *.o
	rm -rf parser.output





