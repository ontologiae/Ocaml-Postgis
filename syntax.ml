type 
vector = float list
and
wkt =
| CURVEPOLYGON          of z_m option * vector
| GEOMETRYCOLLECTION    of z_m option * wkt list
| TIN                   of z_m option * vector list list
| POLYHEDRALSURFACE     of z_m option * vector list list
| MULTIPOLYGON          of z_m option * vector list
| MULTISURFACE          of z_m option * wkt list
| MULTILINESTRING       of z_m option * vector list
| MULTICURVE            of z_m option * wkt list
| MULTIPOINT            of z_m option * vector list
| TRIANGLE              of z_m option * vector list
| POLYGON               of z_m option * vector list
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



     
