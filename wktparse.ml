#load "syntax.cmo";;
#load "lexer.cmo";;
#load "parse_wkt_simple.cmo";;
open Lexing;;
exception Fatal_error of string;;

let lexer_from_string str =
  let lex = Lexing.from_string str in
  let pos = lex.lex_curr_p in
    lex.lex_curr_p <- { pos with pos_fname = ""; pos_lnum = 1; } ;
    lex;;

let string_of_position {pos_fname=fn; pos_lnum=ln; pos_bol=bol; pos_cnum=cn} =
  let c = cn - bol in
    if fn = "" then
      "Character " ^ string_of_int c
    else
      "File \"" ^ fn ^ "\", line " ^ string_of_int ln ^ ", character " ^
      string_of_int c;;


let string_of msg pos = string_of_position pos ^ ":\n" ^ msg;;


let syntax_error {lex_curr_p=pos} = string_of "Syntax error" pos;;
    

let lexer = function str ->  lexer_from_string str;;
let fatal_error msg = raise (Fatal_error msg);;

#load "syntax.cmo";;
#load "lexer.cmo";;
#load "parse_wkt_simple.cmo";;


let cmds lex =
        try
                Parse_wkt_simple.well_known_text_representation Lexer.token lex
        with
        | Failure("lexing : empty token")
        | Parsing.Parse_error -> fatal_error (syntax_error lex);;


let lex s = Lexer.token (lexer_from_string s);;

let parse s = cmds (lexer_from_string s);;
