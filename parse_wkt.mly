%{
  open Syntax
%}

%token <float>NBR

%token EMPTY, ZM, Z, M, LPAREN, RPAREN, COMMA, CURVEPOLYGON, GEOMETRYCOLLECTION, TIN, POLYHEDRALSURFACE, MULTIPOLYGON, MULTISURFACE, MULTILINESTRING, MULTICURVE, MULTIPOINT, TRIANGLE, POLYGON,
COMPOUNDCURVE, CIRCULARSTRING, LINESTRING, POINT, EOF

//%token EOF


%start well_known_text_representation
%type <Syntax.wkt> well_known_text_representation

%%

well_known_text_representation :
|    point_text_representation                                  {$1}
|    curve_text_representation                                  {$1}
|    surface_text_representation                                {$1}
|    collection_text_representation                             {$1}

point_text_representation :
       | POINT  z_m  point_text                                 {POINT(Some($2),$3)}
       | POINT  point_text                                      {POINT(None,$2)}

curve_text_representation :
 |   linestring_text_representation                             {$1}
 |   circularstring_text_representation                         {$1}
 |   compoundcurve_text_representation                          {$1}

linestring_text_representation :
 |   LINESTRING  linestring_text_body                           {LINESTRING(None,$2)}
 |   LINESTRING z_m linestring_text_body                        {LINESTRING(Some($2),$3)}

circularstring_text_representation :
 |   CIRCULARSTRING  circularstring_text                        {CIRCULARSTRING(None,$2)}
 |   CIRCULARSTRING z_m circularstring_text                     {CIRCULARSTRING(Some($2),$3)}

compoundcurve_text_representation :
 |   COMPOUNDCURVE  compoundcurve_text                          {COMPOUNDCURVE(None,$2)}
 |   COMPOUNDCURVE  z_m compoundcurve_text                      {COMPOUNDCURVE(Some($2),$3)}

surface_text_representation :
 |   curvepolygon_text_representation	                	{$1}

curvepolygon_text_representation :
 |   CURVEPOLYGON  curvepolygon_text_body               	{CURVEPOLYGON(None,$2)}
 |   CURVEPOLYGON  z_m  curvepolygon_text_body	                {CURVEPOLYGON(Some($2),$3)}
 |   polygon_text_representation 		                {$1}
 |   triangle_text_representation		                {$1}

polygon_text_representation :
 |   POLYGON  polygon_text_body		                        {POLYGON(None,$2)}
 |   POLYGON  z_m  polygon_text_body		                {POLYGON(Some($2),$3)}

triangle_text_representation :
  |  TRIANGLE  z_m  triangle_text_body		                {TRIANGLE(Some($2),$3)}
  |  TRIANGLE  triangle_text_body		                {TRIANGLE(None,$2)}

collection_text_representation :
  |  multipoint_text_representation 		                {$1}
  |  multicurve_text_representation 		                {$1}
  |  multisurface_text_representation 		                {$1}
  |  geometrycollection_text_representation	                {$1}

multipoint_text_representation :
  |  MULTIPOINT z_m multipoint_text		                {MULTIPOINT(Some($2),$3)}
  |  MULTIPOINT  multipoint_text		                {MULTIPOINT(None,$2)}


multicurve_text_representation :
  |  MULTICURVE z_m multicurve_text 		                {MULTICURVE(Some($2),$3)}
  |  MULTICURVE multicurve_text 		                {MULTICURVE(None,$2)}
  |  multilinestring_text_representation	                {$1}

multilinestring_text_representation :
  |  MULTILINESTRING z_m multilinestring_text		        {MULTILINESTRING(Some($2),$3)}
  |  MULTILINESTRING  multilinestring_text		        {MULTILINESTRING(None,$2)}


multisurface_text_representation :
  |  MULTISURFACE z_m multisurface_text 		        {MULTISURFACE(Some($2),$3)}
  |  MULTISURFACE  multisurface_text 	        	        {MULTISURFACE(None,$2)}
  |  multipolygon_text_representation 	        	        {$1}
  |  polyhedralsurface_text_representation 		        {$1}
  |  tin_text_representation	                	        {$1}

multipolygon_text_representation :
  |  MULTIPOLYGON z_m multipolygon_text	        	        {MULTIPOLYGON(Some($2),$3)}
  |  MULTIPOLYGON  multipolygon_text	        	        {MULTIPOLYGON(None,$2)}


polyhedralsurface_text_representation :
  |  POLYHEDRALSURFACE z_m polyhedralsurface_text               {POLYHEDRALSURFACE(Some($2),$3)}
  |  POLYHEDRALSURFACE  polyhedralsurface_text		        {POLYHEDRALSURFACE(None,$2)}


tin_text_representation :
  |  TIN z_m tin_text	                        	        {TIN(Some($2),$3)}
  |  TIN  tin_text	                        	        {TIN(None,$2)}

geometrycollection_text_representation :
  |  GEOMETRYCOLLECTION z_m geometrycollection_text	        {GEOMETRYCOLLECTION(Some($2),$3)}
  |  GEOMETRYCOLLECTION  geometrycollection_text	        {GEOMETRYCOLLECTION(None,$2)}


linestring_text_body :
  |  linestring_text		                                {$1}

curvepolygon_text_body :
  |  curvepolygon_text		                                {$1}

polygon_text_body :
  |  polygon_text		                                {$1}

triangle_text_body :
        triangle_text                                           {$1}

point_text :
  |  empty_set 		                                        {$1}
  |  LPAREN point RPAREN	                                {$2}

point :
      |    x y                                                  {[$1;$2]}
      |    x y z                                                {[$1;$2;$3]}
      |    x y z m                                              {[$1;$2;$3;$4]}

x : 
 | number {$1}
y : 
 | number {$1}
z : 
 | number {$1}
m : 
 | number {$1}

number :
   | NBR {$1}

/*Ici gérer des listes...*/

linestring_text :
   | empty_set 		                                        {$1}
   | LPAREN point    RPAREN                                     {$2}
   | LPAREN point point_list RPAREN                             {$2::$3}

point_list :
   | COMMA point point_list                                     {$2::$3}
   | COMMA point                                                {[$2]}
   | empty_set                                                  {$1}

ring_list:
   | empty_set                                                  {$1}
   | COMMA ring_text                                            {[|$2|]}
   | COMMA ring_text ring_list                                  {[|$2::$3|]} 

curve_list:
   | empty_set                                                  {$1}
   | COMMA curve_text                                           {[|$2|]}
   | COMMA curve_text curve_list                                {$2::$3}

linestring_list:
   | empty_set                                                  {$1}
   | COMMA linestring_text                                      {[|$2|]}
   | COMMA linestring_text linestring_text                      {$2::$3}

linestring_text_body_list :
   | empty_set                                                  {$1}
   | COMMA linestring_text_body                                 {[|$2|]}
   | COMMA linestring_text_body linestring_text_body_list       {$2::$3}

single_curve_list :
   | empty_set                                                  {$1}
   | COMMA single_curve_text                                    {[|$2|]}
   | COMMA single_curve_text single_curve_list                  {$2:$3}

surface_text_list:
   | empty_set                                                  {$1}
   | COMMA surface_text                                         {[|$2|]}
   | COMMA surface_text surface_text_list                       {$2::$3}

polygon_text_body_list:
    | empty_set                                                 {$1}
    | COMMA polygon_text_body                                   {[|$2|]}
    | COMMA polygon_text_body polygon_text_body_list            {$2::$3}

triangle_text_body_list:
    | empty_set                                                 {$1}
    | COMMA triangle_text_body                                  {[|$2|]}
    | COMMA triangle_text_body triangle_text_body_list          {$2::$3}

well_known_text_representation_list:
     | empty_set                                                {$1}
     | COMMA well_known_text_representation                     {[|$2|]}
     | COMMA well_known_text_representation well_known_text_representation_list {$2::$3}


circularstring_text :
   | empty_set 		                                        {$1}
   | LPAREN point  point_list  RPAREN                           {$2::$3}

compoundcurve_text :
   | empty_set 		                                        {$1}
   | LPAREN single_curve_text  single_curve_list  RPAREN        {$2::$3}

single_curve_text :
   | linestring_text_body 		                        {$1}
   | circularstring_text_representation		                {$1}

curve_text :
   | linestring_text_body 		                        {$1}
   | circularstring_text_representation 	                {$1}
   |  compoundcurve_text_representation		                {$1}

ring_text :
   | linestring_text_body 		                        {$1}
   | circularstring_text_representation 	                {$1}
   | compoundcurve_text_representation		                {$1}

surface_text :
   | CURVEPOLYGON curvepolygon_text_body 	                {CURVEPOLYGON $2}
   | polygon_text_body		                                {$1}

curvepolygon_text :
   | empty_set 		                                        {$1}
   | LPAREN ring_text  ring_list  RPAREN                        {$2::$3}

polygon_text :
   | empty_set 		                                        {$1}
   | LPAREN linestring_text  linestring_list  RPAREN            {$2::$3}

triangle_text :
    | empty_set		                                        {$1}
    | LPAREN linestring_text RPAREN		                {}

multipoint_text :
    | empty_set		                                        {$1}
    | LPAREN point_text  point_list   RPAREN                    {$2::$3}

multicurve_text :
    | empty_set		                                        {$1}
    | LPAREN curve_text  curve_list  RPAREN                     {$2::$3}


multilinestring_text :
    | empty_set		                                        {$1}
    | LPAREN linestring_text_body  linestring_text_body_list  RPAREN {$2::$3}

multisurface_text :
    | empty_set		                                        {$1}
    | LPAREN surface_text  surface_text_list  RPAREN            {$2::$3}

multipolygon_text :
    | empty_set		                                        {$1}
    | LPAREN polygon_text_body  polygon_text_body_list  RPAREN  {$2::$3}

polyhedralsurface_text :
    | empty_set		                                        {$1}
    | LPAREN polygon_text_body  polygon_text_body_list  RPAREN  {$2::$3}

tin_text :
    | empty_set		                                        {$1}
    | LPAREN triangle_text_body  triangle_text_body_list RPAREN {$2::$3}

geometrycollection_text :
    | empty_set		                                        {$1}
    | LPAREN well_known_text_representation  well_known_text_representation_list  RPAREN {$2::$3}

empty_set : 
        EMPTY {[||]}

z_m :
       | ZM  {ZM}
       | Z   {Z}
       | M   {M}
