module Syntax :
        sig
                type vector = V of float list
                and wkt =
                          | CURVEPOLYGON of z_m option * wkt list
                          | GEOMETRYCOLLECTION of z_m option * wkt list
                          | TIN of z_m option * vector list list
                          | POLYHEDRALSURFACE of z_m option * wkt list
                          | MULTIPOLYGON of z_m option * wkt list
                          | MULTISURFACE of z_m option * wkt list
                          | MULTILINESTRING of z_m option * vector list list
                          | MULTICURVE of z_m option * wkt list
                          | MULTIPOINT of z_m option * vector list
                          | TRIANGLE of z_m option * vector list
                          | POLYGON of z_m option * vector list list
                          | COMPOUNDCURVE of z_m option * wkt list
                          | CIRCULARSTRING of z_m option * vector list
                          | LINESTRING of z_m option * vector list
                          | POINT of z_m option * vector
                          | VECTOR of vector
                          | NBR of float
                and z_m = ZM | Z | M

                val to_vect : vector -> string
                val to_nbr : float -> string
                val of_zm : z_m option -> string
                val vectlist_to_string : vector list -> string
                val to_string : wkt -> string
        end

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

val get_wkt : ocaml_result_type -> Syntax.wkt

type distance = float and angle = float
              
type operations =
              | Center          of Syntax.wkt
              | Intersect       of Syntax.wkt * Syntax.wkt
              | Crosses         of Syntax.wkt * Syntax.wkt
              | Within          of Syntax.wkt * Syntax.wkt
              | Distance        of Syntax.wkt * Syntax.wkt
              | IsAtDistance    of Syntax.wkt * Syntax.wkt * float
              | Projection      of Syntax.wkt * distance * angle
              | Length          of Syntax.wkt
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


module type STATICGEOM =
  sig
    val center : Postgresql.connection -> Syntax.wkt -> Syntax.wkt
    val intersect : Postgresql.connection -> Syntax.wkt -> Syntax.wkt -> bool
    val crosses : Postgresql.connection -> Syntax.wkt -> Syntax.wkt -> bool
    val within : Postgresql.connection -> Syntax.wkt -> Syntax.wkt -> bool
    val distance : Postgresql.connection -> Syntax.wkt -> Syntax.wkt -> float
    val isAtDistance :
      Postgresql.connection -> Syntax.wkt -> Syntax.wkt -> float -> bool
    val projection :
      Postgresql.connection -> Syntax.wkt -> distance -> angle -> Syntax.wkt
    val length : Postgresql.connection -> Syntax.wkt -> float
  end
module StaticGeom : STATICGEOM

