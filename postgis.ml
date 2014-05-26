open Postgresql


type ocaml_result_type =
        | Text of string
        | Date of string
        | Int  of int
        | Num  of float
        | Char of char
        | Bool of bool
        | Postgis of string
        | NumRange of float * float
        | Blob of string 
        | Null

type typed_result = {
        value : ocaml_result_type;
        pgtype : ftype
}



let get_all_with_type (result : Postgresql.result)=
            let convert valu pgty =
                    match pgty with
                    | TEXT | CSTRING | VARCHAR                          -> Text valu
                    | INT4 | INT8 | INT8 | OID | XID | CID    -> Int (int_of_string valu)
                    | TIMETZ | TIMESTAMPTZ | TIMESTAMP | TIME           -> Date valu
                    | NUMERIC | FLOAT8 | FLOAT4 | CASH                  -> Num (float_of_string valu)
                    | CHAR                                              -> Char (String.get valu 0)
                    | BOOL                                              -> Bool (bool_of_string valu)
                    | BYTEA                                             -> Blob valu
                    | _                                                 -> failwith "non géré"
            in
            let nfields = result#nfields in
            let contruitLigne nligne = Array.init nfields (fun t -> let pgt = result#ftype t in
                                         { value  = convert (result#getvalue nligne t ) pgt;
                                           pgtype = pgt;
                                         } ) in
            let nbligne = result#ntuples in
            Array.init nbligne (fun t -> contruitLigne t)

let get_all_with_format (result : Postgresql.result) type_array =
        let convert valu pgty exc =
                (*match exc TODO : on regarde si on a pas un type spécial. Si oui on parse, sinon on laisse le classique*)
                    match pgty with
                    | TEXT | CSTRING | VARCHAR                          -> Text valu
                    | INT4 | INT8 | INT8 | OID | XID | CID              -> Int (int_of_string valu)
                    | TIMETZ | TIMESTAMPTZ | TIMESTAMP | TIME           -> Date valu
                    | NUMERIC | FLOAT8 | FLOAT4 | CASH                  -> Num (float_of_string valu)
                    | CHAR                                              -> Char (String.get valu 0)
                    | BOOL                                              -> Bool (bool_of_string valu)
                    | BYTEA                                             -> Blob valu
                    | _                                                 -> failwith "non géré"
            in
            let nfields = result#nfields in
            let contruitLigne nligne = Array.init nfields (fun t -> let pgt = result#ftype t in
                                                                    let mask = type_array.(t) in
                                                                    
                                         { value  = convert (result#getvalue nligne t ) pgt;
                                           pgtype = pgt;
                                         } ) in
            let nbligne = result#ntuples in
            Array.init nbligne (fun t -> contruitLigne t)



