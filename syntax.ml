module S = String;;
module L = List;;

type 
vector = V of float list
and
wkt =
| CURVEPOLYGON          of z_m option * wkt list
| GEOMETRYCOLLECTION    of z_m option * wkt list
| TIN                   of z_m option * vector list list
| POLYHEDRALSURFACE     of z_m option * wkt list 
| MULTIPOLYGON          of z_m option * wkt list 
| MULTISURFACE          of z_m option * wkt list
| MULTILINESTRING       of z_m option * vector list list
| MULTICURVE            of z_m option * wkt list
| MULTIPOINT            of z_m option * vector list
| TRIANGLE              of z_m option * vector list
| POLYGON               of z_m option * vector list list (*Potentiellement, plusieurs linestrig*)
| COMPOUNDCURVE         of z_m option * wkt list
| CIRCULARSTRING        of z_m option * vector list
| LINESTRING            of z_m option * vector list
| POINT                 of z_m option * vector
| VECTOR                of vector
| NBR                   of float 

and
z_m = 
       | ZM  
       | Z   
       | M   


let rec to_vect (V l) =
       S.concat " " (L.map string_of_float l)
and to_nbr n = string_of_float n
and of_zm  zm  = 
        match zm with
        | Some Z  -> "Z"
        | Some M  -> "M"
        | Some ZM -> "ZM"
        | None    -> ""
and  vectlist_to_string (vl : vector list ) = "("^(S.concat "," (L.map to_vect vl))^")"
and  to_string geom = 
        match geom with
	| CURVEPOLYGON(zmval,l)         -> "CURVEPOLYGON "^(of_zm zmval)^"("^(S.concat "," (L.map to_string l))^")"
	| GEOMETRYCOLLECTION(zmval,l)   -> "GEOMETRYCOLLECTION "^(of_zm zmval)^"("^(S.concat "," (L.map to_string l))^")"
	| TIN(zmval,l)                  -> "TIN "^(of_zm zmval)^"("^(S.concat "," (L.map vectlist_to_string l))^")"
	| POLYHEDRALSURFACE(zmval,l)    -> "POLYHEDRALSURFACE "^(of_zm zmval)^"("^(S.concat "," (L.map to_string l))^")"
	| MULTIPOLYGON(zmval,l)         -> "MULTIPOLYGON "^(of_zm zmval)^"("^(S.concat "," (L.map to_string l))^")"
	| MULTISURFACE(zmval,l)         -> "MULTISURFACE "^(of_zm zmval)^"("^(S.concat "," (L.map to_string l))^")"
	| MULTILINESTRING(zmval,l)      -> "MULTILINESTRING "^(of_zm zmval)^"("^(S.concat "," (L.map vectlist_to_string l))^")"
	| MULTICURVE(zmval,l)           -> "MULTICURVE "^(of_zm zmval)^"("^(S.concat "," (L.map to_string l))^")"
	| MULTIPOINT(zmval,l)           -> "MULTIPOINT "^(of_zm zmval)^"("^(vectlist_to_string l)^")"
	| TRIANGLE(zmval,l)             -> "TRIANGLE "^(of_zm zmval)^"("^(vectlist_to_string l)^")"
	| POLYGON(zmval,l)              -> "POLYGON "^(of_zm zmval)^"("^(S.concat "," (L.map vectlist_to_string l))^")"
	| COMPOUNDCURVE(zmval,l)        -> "COMPOUNDCURVE "^(of_zm zmval)^"("^(S.concat "," (L.map to_string l))^")"
	| CIRCULARSTRING(zmval,l)       -> "CIRCULARSTRING "^(of_zm zmval)^"("^(vectlist_to_string l)^")"
	| LINESTRING(zmval,l)           -> "LINESTRING "^(of_zm zmval)^"("^(vectlist_to_string l)^")"
	| POINT(zmval,p)                -> "POINT "^(of_zm zmval)^"("^(to_vect p)^")"
        | VECTOR  v                     -> to_vect v
        | NBR   n                       -> to_nbr n




     
