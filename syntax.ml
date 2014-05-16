(*
 * multipolygon_text_representation OU polyhedralsurface_text_representation :
         * MULTIPOLYGON OU POLYHEDRALSURFACE  
 * multipolygon_text OU polyhedralsurface_text
 * polygon_text
 * linestring_list
 *
 * *)
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



     
