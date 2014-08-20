(*#require "postgresql";;*)
module Syntax = struct 
        include Syntax
end

open Syntax
 
open Postgresql

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

let get_wkt w = match w with
                | Postgis wkt -> wkt
                | _           -> failwith "Postgis.get_wkt : invalid argument"

type distance = float and angle = float







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





module type STATICGEOM = sig


        val center      : Postgresql.connection -> wkt -> wkt
        val intersect   : Postgresql.connection -> wkt -> wkt -> bool
        val crosses     : Postgresql.connection -> wkt -> wkt -> bool
        val within      : Postgresql.connection -> wkt -> wkt -> bool
        val distance    : Postgresql.connection -> wkt -> wkt -> float
        val isAtDistance : Postgresql.connection -> wkt -> wkt -> float -> bool
        val projection  : Postgresql.connection -> wkt -> distance -> angle -> wkt
        val length      : Postgresql.connection -> wkt -> float

               
end;;

module StaticGeom : STATICGEOM = 
        
         struct

                        let tos geom = "'"^(to_string geom)^"'::geometry"

                        let select1 geom op at = 
                                let astext  = match at with true -> "ST_ASText" | false -> "" in
                                "SELECT "^astext^"("^op^"("^(tos geom)^"))" 

                        let select1_2 geom p1 p2 op at = 
                                let astext = match at with true -> "ST_ASText" | false -> "" in
                                "SELECT "^astext^"("^op^"("^(tos geom)^","^(string_of_float p1)^","^(string_of_float p2)^"))" 

                        let select2 geom geom2 op at = let astext = match at with true -> "ST_ASText" | false -> "" in
                                "SELECT "^astext^"("^op^"("^(tos geom)^","^(tos geom2)^"))" 

                        let select3 geom geom2 f op at = let astext = match at with true -> "ST_ASText" | false -> "" in
                                "SELECT "^astext^"("^op^"("^(tos geom)^","^(tos geom2)^","^(string_of_float f)^"))"

                        let getBool w = match w with
                        | Bool b -> b
                        | _           -> failwith "Postgis.getBool : invalid argument"

                        let getNum w = match w with
                        | Num f -> f
                        | _           -> failwith "Postgis.get_int : invalid argument"

 


                let center (conn : Postgresql.connection) g                    = let r = select1 g "ST_centroid" true |> conn#exec |> get_all in
                                                                                        get_wkt (Array.get (Array.get r 0) 0).value

                let intersect (conn : Postgresql.connection) g1 g2             = let r = select2 g1 g2 "ST_Intersects" false |> conn#exec |> get_all in
                                                                                        getBool (Array.get (Array.get r 0) 0).value

                let crosses   (conn : Postgresql.connection) g1 g2             = let r = select2 g1 g2 "ST_Crosses" false |> conn#exec |> get_all in
                                                                                        getBool (Array.get (Array.get r 0) 0).value

                let within    (conn : Postgresql.connection) g1 g2             = let r = select2 g1 g2 "ST_Within" false |> conn#exec |> get_all in
                                                                                        getBool (Array.get (Array.get r 0) 0).value

                let distance  (conn : Postgresql.connection) g1 g2             = let r = select2 g1 g2 "ST_Distance" false |> conn#exec |> get_all in
                                                                                        getNum (Array.get (Array.get r 0) 0).value

                let isAtDistance (conn : Postgresql.connection) g1 g2 d        = let r = select3 g1 g2 d "ST_DWithin" false |> conn#exec |> get_all in
                                                                                        getBool (Array.get (Array.get r 0) 0).value

                let projection (conn : Postgresql.connection) g1 dst ang       = let r = select1_2 g1 dst ang "ST_Project" true |> conn#exec |> get_all in
                                                                                        get_wkt (Array.get (Array.get r 0) 0).value

                let length (conn : Postgresql.connection) g                    = let r = select1 g "ST_Length" false |> conn#exec |> get_all in
                                                                                        getNum (Array.get (Array.get r 0) 0).value

        end;;              

