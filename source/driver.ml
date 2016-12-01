(* LePiX Language Compiler Implementation
Copyright (c) 2016- ThePhD, Gabrielle Taylor, Akshaan Kakar, Fatimazorha Koly, Jackie Lin

Permission is hereby granted, free of charge, to any person obtaining a copy of this 
software and associated documentation files (the "Software"), to deal in the Software 
without restriction, including without limitation the rights to use, copy, modify, 
merge, publish, distribute, sublicense, and/or sell copies of the Software, and to 
permit persons to whom the Software is furnished to do so, subject to the following 
conditions:

The above copyright notice and this permission notice shall be included in all copies 
or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION 
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. *)

(* Drives the typical lexing and parsing algorithm
while adding pertinent source, line and character information. *)

type context = {
     mutable source_name : string;
     mutable source_code : string;
	mutable original_source_code : string;
	mutable token_count : int;
     mutable token : Parser.token * Core.token_source;
}

let lex sourcename lexbuf =
	let tokennumber = ref 0 in
	let rec acc lexbuf tokens =
		let next_token = Scanner.token lexbuf
		and startp = Lexing.lexeme_start_p lexbuf
		and endp = Lexing.lexeme_end_p lexbuf
		in
		let line = startp.Lexing.pos_lnum
		and relpos = (1 + startp.Lexing.pos_cnum - startp.Lexing.pos_bol)
		and endrelpos = (1 + endp.Lexing.pos_cnum - endp.Lexing.pos_bol) 
		and abspos = startp.Lexing.pos_cnum
		and endabspos = endp.Lexing.pos_cnum
		in
		let create_token token =
			let t = ( token, { Core.token_source_name = sourcename; Core.token_number = !tokennumber; 
				Core.token_line_number = line; Core.token_line_start = startp.Lexing.pos_bol; 
				Core.token_column_range = (relpos, endrelpos); Core.token_character_range = (abspos, endabspos) } 
			) in
			tokennumber := 1 + !tokennumber;
			t
		in
		match next_token with
		| Parser.EOF as token -> ( create_token token ) :: tokens
		| token -> ( create_token token ) :: ( acc lexbuf tokens )
	in acc lexbuf []

let parse context token_list =
	(* Keep a reference to the original token list
	And use that to dereference rather than whatever crap we get from
	the channel *)
	let tokenlist = ref(token_list) in
	let tokenizer _ = match !tokenlist with
	(* Break each token down into pieces, info and all*)
	| (token, info) :: rest -> 
		context.source_name <- info.Core.token_source_name;
		context.token_count <- 1 + context.token_count;
		context.token <- ( token, info );
		(* Shift the list down by one by referencing 
		the beginning of the rest of the list *)
		tokenlist := rest; 
		(* return token we care about *)
		token
	(* The parser stops calling the tokenizer when 
	it hits EOF: if it reaches the empty list, WE SCREWED UP *)
	| [] -> raise (Error.MissingEoF)
	in
	(* Pass in an empty channel built off a cheap string
	and then ignore the fuck out of it in our 'tokenizer' 
	internal function *)
	let program = Parser.program tokenizer (Lexing.from_string "") in
	program

let analyze program =
	(* TODO: other important checks and semantic analysis here 
	that will create a proper checked program type*)
	let sem = Semant.check program in
	sem
