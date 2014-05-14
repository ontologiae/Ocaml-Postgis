exception Fatal_error of string

let lexer = function str ->  Message.lexer_from_string str;;
let fatal_error msg = raise (Fatal_error msg);;

let cmds lex =
        try
                Parse_wkt.well_known_text_representation Lexer.token lex
        with
        | Failure("lexing : empty token")
        | Parsing.Parse_error -> fatal_error (Message.syntax_error lex);;



