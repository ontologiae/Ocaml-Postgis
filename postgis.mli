type pgis = [ `N | `Postgis ]
type ocaml_result_type =
        Text of string
              | Date of string
              | Int of int
              | Num of float
              | Char of char
              | Bool of bool
              | Postgis of Syntax.wkt
              | NumRange of float * float
              | Blob of string
              | Null
type operations =
        Center of Syntax.wkt
              | Intersect of Syntax.wkt * Syntax.wkt
              | Crosses of Syntax.wkt * Syntax.wkt
              | Within of Syntax.wkt * Syntax.wkt
              | Distance of Syntax.wkt * Syntax.wkt
              | IsAtDistance of Syntax.wkt * Syntax.wkt * float
              | Length of Syntax.wkt
type typed_result = { value : ocaml_result_type; pgtype : Postgresql.ftype; }
val convertFromPgType :
        [> `Postgis ] -> string -> Postgresql.ftype -> ocaml_result_type
val convertTry : string -> Postgresql.ftype -> ocaml_result_type
val get_all : Postgresql.result -> typed_result array array
val get_all_with_format :
        [> `Postgis ] array -> Postgresql.result -> typed_result
        array array
val string_of_geom : Syntax.wkt -> string
val static_request : Postgresql.connection -> operations -> typed_result array array

