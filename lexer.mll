{
  open Parse_wkt_simple
  open Lexing

  let incr_linenum lexbuf =
    let pos = lexbuf.lex_curr_p in
    lexbuf.lex_curr_p <- { pos with
      pos_lnum = pos.pos_lnum + 1;
      pos_bol = pos.pos_cnum;
    }
}

let int = '-'? ['0'-'9'] ['0'-'9']*
let digit = ['0'-'9']
let frac = '.' digit*
let plusmoins = ['-' '+']?
let exp = ['e' 'E'] ['-' '+']? digit+
let nbr = plusmoins? digit* frac? exp?



rule token = parse
    '#' [^'\n']* '\n' { incr_linenum lexbuf; token lexbuf }
  | '\n'              { incr_linenum lexbuf; token lexbuf }
  | [' ' '\t']        { token lexbuf }
  | "EMPTY"           { EMPTY }
  | "ZM"              { ZM    }
  | "Z"               { Z     } 
  | "M"               { M     } 
  | '('               { LPAREN }
  | ')'               { RPAREN }
  | ','                   { COMMA }

  | "CURVEPOLYGON"        { CURVEPOLYGON  }
  | "GEOMETRYCOLLECTION"  { GEOMETRYCOLLECTION } 
  | "TIN"                 { TIN }
  | "POLYHEDRALSURFACE"   { POLYHEDRALSURFACE }
  | "MULTIPOLYGON"        { MULTIPOLYGON }
  | "MULTISURFACE"        { MULTISURFACE }
  | "MULTILINESTRING"     { MULTILINESTRING }
  | "MULTICURVE"          { MULTICURVE } 
  | "MULTIPOINT"          { MULTIPOINT }
  | "TRIANGLE"            { TRIANGLE }
  | "POLYGON"             { POLYGON }

  | "COMPOUNDCURVE"       { COMPOUNDCURVE }
  | "CIRCULARSTRING"      { CIRCULARSTRING }
  | "LINESTRING"          { LINESTRING }
  | "POINT"               { POINT }
  | nbr                   { NBR (float_of_string (lexeme lexbuf))}
  (*| eof             { EOF }*)

{
}
