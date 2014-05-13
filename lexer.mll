{
  open Parser
  open Lexing

  let incr_linenum lexbuf =
    let pos = lexbuf.lex_curr_p in
    lexbuf.lex_curr_p <- { pos with
      pos_lnum = pos.pos_lnum + 1;
      pos_bol = pos.pos_cnum;
    }
}

let nbr = ['+' '-']?(['0' - '9']+(.['0' - '9']*)?|.['0' - '9']+)(['e' 'E']['+' '-' ]?['0' - '9']+)? ;


rule token = parse
    '#' [^'\n']* '\n' { incr_linenum lexbuf; token lexbuf }
  | '\n'            { incr_linenum lexbuf; token lexbuf }
  | ['\t']      { token lexbuf }
  | ' '             { SPACE}
  | "EMPTY"         { EMPTY }
  | "ZM"            { ZM  }
  | "Z"             { Z } 
  | "M"             { M } 
  | '('             { LPAREN }
  | ')'             { RPAREN }
  | ','             { COMMA }
  | '.'             { POINT}
  | 'CURVEPOLYGON'        { CURVEPOLYGON  }
  | 'GEOMETRYCOLLECTION'  { GEOMETRYCOLLECTION } 
  | 'TIN'                 { TIN }
  | 'POLYHEDRALSURFACE'   { POLYHEDRALSURFACE }
  | 'MULTIPOLYGON'        { MULTIPOLYGON }
  | 'MULTISURFACE'        { MULTISURFACE }
  | 'MULTILINESTRING'     { MULTILINESTRING }
  | 'MULTICURVE'          { MULTICURVE } 
  | 'MULTIPOINT'          { MULTIPOINT }
  | 'TRIANGLE'            { TRIANGLE }
  | 'POLYGON'             { POLYGON }
  | 'CURVEPOLYGON'        { CURVEPOLYGON }
  | 'COMPOUNDCURVE'       { COMPOUNDCURVE }
  | 'CIRCULARSTRING'      { CIRCULARSTRING }
  | 'LINESTRING'          { LINESTRING }
  | 'POINT'               { POINT }
  | nbr             { NBR (float_of_string (lexeme lexbuf))}
  | eof             { EOF }

{
}
