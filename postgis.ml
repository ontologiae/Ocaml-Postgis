(*#require "postgresql";;*)
module Syntax = struct 
        include Syntax
end

open Syntax

open Postgresql

type wkt = Syntax.wkt
type pgis = [ `Postgis | `N ];;

type ocaml_result_type =
        | Text of string
        | Date of string
        | Int  of int
        | Num  of float
        | Char of char
        | Bool of bool
        | Postgis of wkt
        | NumRange of float * float
        | Blob of string 
        | Null


type operations =
        | Center        of wkt
        | Intersect     of wkt * wkt
        | Crosses       of wkt * wkt
        | Within        of wkt * wkt
        | Distance      of wkt * wkt
        | IsAtDistance  of wkt * wkt * float
        | Length        of wkt


type typed_result = {
        value : ocaml_result_type;
        pgtype : ftype
}


let convertFromPgType exc valu pgty =
                match exc with (*TODO : on regarde si on a pas un type spécial. Si oui on parse, sinon on laisse le classique*)
                | `Postgis  -> Postgis (Wktparse.parse valu)
                | _         ->
                 (   match pgty with
                    | TEXT | CSTRING | VARCHAR                          -> Text valu
                    | INT4 | INT8  | OID | XID | CID                    -> Int (int_of_string valu)
                    | TIMETZ | TIMESTAMPTZ | TIMESTAMP | TIME           -> Date valu
                    | NUMERIC | FLOAT8 | FLOAT4 | CASH                  -> Num (float_of_string valu)
                    | CHAR                                              -> Char (String.get valu 0)
                    | BOOL                                              -> (match valu with | "t" -> Bool true | "f" -> Bool false | _ -> Bool false)
                    | BYTEA                                             -> Blob valu
                    | _                                                 -> failwith "non géré"
                 );;



let convertTry valu pgty =
        match pgty with
         | TEXT                                              -> (try Postgis (Wktparse.parse valu) with e -> Text valu)
         | CSTRING | VARCHAR                                 -> Text valu
         | INT4 | INT8  | OID | XID | CID                    -> Int (int_of_string valu)
         | TIMETZ | TIMESTAMPTZ | TIMESTAMP | TIME           -> Date valu
         | NUMERIC | FLOAT8 | FLOAT4 | CASH                  -> Num (float_of_string valu)
         | CHAR                                              -> Char (String.get valu 0)
         | BOOL                                              -> (match valu with | "t" -> Bool true | "f" -> Bool false | _ -> Bool false)
         | BYTEA                                             -> Blob valu
         | _                                                 -> failwith "non géré"



let get_all (result : Postgresql.result)=
            let nfields = result#nfields in
            let contruitLigne nligne = Array.init nfields (fun t -> let pgt = result#ftype t in
                                         { value  = convertTry (result#getvalue nligne t ) pgt;
                                           pgtype = pgt;
                                         } ) in
            let nbligne = result#ntuples in
            Array.init nbligne (fun t -> contruitLigne t)


let get_all_with_format type_array (result : Postgresql.result)  =
            let nfields = result#nfields in
            let contruitLigne nligne = Array.init nfields (fun t -> let pgt = result#ftype t in
                                                                    let mask = type_array.(t) in
                                                                    
                                         { value  = convertFromPgType mask (result#getvalue nligne t ) pgt;
                                           pgtype = pgt;
                                         } ) in
            let nbligne = result#ntuples in
            Array.init nbligne (fun t -> contruitLigne t)



let string_of_geom g =
        to_string g

let static_request (conn : Postgresql.connection)  operations =
        let tos geom = "'"^(to_string geom)^"'::geometry" in
        let select1 geom op at = 
                let astext = match at with true -> "ST_ASText" | false -> "" in
                                        "SELECT "^astext^"("^op^"("^(tos geom)^"))" in
        let select2 geom geom2 op at = let astext = match at with true -> "ST_ASText" | false -> "" in
                                        "SELECT "^astext^"("^op^"("^(tos geom)^","^(tos geom2)^"))" in
        let select3 geom geom2 f op at = let astext = match at with true -> "ST_ASText" | false -> "" in
                                        "SELECT "^astext^"("^op^"("^(tos geom)^","^(tos geom2)^","^(string_of_float f)^"))" in
        let req =
                match operations with
                | Center g              -> select1 g "ST_centroid" true
                | Intersect(g1,g2)      -> select2 g1 g2 "ST_Intersects" false
                | Crosses(g1,g2)        -> select2 g1 g2 "ST_Crosses" false
                | Within(g1,g2)         -> select2 g1 g2 "ST_Within" false
                | Distance(g1,g2)       -> select2 g1 g2 "ST_Distance" false
                | IsAtDistance(g1,g2,f) -> select3 g1 g2 f "ST_DWithin" false
                | Length  g             -> select1 g "ST_Length" false
        in 
        conn#exec req |> get_all 

