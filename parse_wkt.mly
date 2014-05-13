%{
  open Syntax
%}

%token <float>NBR

%token EMPTY, ZM, Z, M, LPAREN, RPAREN, COMMA, CURVEPOLYGON, GEOMETRYCOLLECTION, TIN, POLYHEDRALSURFACE, MULTIPOLYGON, MULTISURFACE, MULTILINESTRING, MULTICURVE, MULTIPOINT, TRIANGLE, POLYGON, COMPOUNDCURVE, CIRCULARSTRING, LINESTRING, POINT

//%token EOF


%start well_known_text_representation
%type <Syntax.wkt> well_known_text_representation

%%

well_known_text_representation :
|    point_text_representation          {$1}
|    curve_text_representation          {$1}
|    surface_text_representation        {$1}
|    collection_text_representation     {$1}

point_text_representation :
       | POINT  z_m  point_text {}
       | POINT  point_text      {}

curve_text_representation :
 |   linestring_text_representation      {}
 |   circularstring_text_representation  {}
 |   compoundcurve_text_representation  {}

linestring_text_representation :
 |   LINESTRING  linestring_text_body    {}
 |   LINESTRING z_m linestring_text_body {}

circularstring_text_representation :
 |   CIRCULARSTRING  circularstring_text {}
 |   CIRCULARSTRING z_m circularstring_text {}

compoundcurve_text_representation :
 |   COMPOUNDCURVE  compoundcurve_text {}
 |   COMPOUNDCURVE  z_m compoundcurve_text {}

surface_text_representation :
 |   curvepolygon_text_representation		{}

curvepolygon_text_representation :
 |   CURVEPOLYGON  curvepolygon_text_body 		{}
 |   CURVEPOLYGON  z_m  curvepolygon_text_body		{}
 |   polygon_text_representation 		{}
 |   triangle_text_representation		{}

polygon_text_representation :
 |   POLYGON  polygon_text_body		{}
 |   POLYGON  z_m  polygon_text_body		{}

triangle_text_representation :
  |  TRIANGLE  z_m  triangle_text_body		{}
  |  TRIANGLE  triangle_text_body		{}

collection_text_representation :
  |  multipoint_text_representation 		{}
  |  multicurve_text_representation 		{}
  |  multisurface_text_representation 		{}
  |  geometrycollection_text_representation		{}

multipoint_text_representation :
  |  MULTIPOINT z_m multipoint_text		{}
  |  MULTIPOINT  multipoint_text		{}


multicurve_text_representation :
  |  MULTICURVE z_m multicurve_text 		{}
  |  multilinestring_text_representation		{}

multilinestring_text_representation :
  |  MULTILINESTRING z_m multilinestring_text		{}
  |  MULTILINESTRING  multilinestring_text		{}


multisurface_text_representation :
  |  MULTISURFACE z_m multisurface_text 		{}
  |  multipolygon_text_representation 	        	{}
  |  polyhedralsurface_text_representation 		{}
  |  tin_text_representation	                	{}

multipolygon_text_representation :
  |  MULTIPOLYGON z_m multipolygon_text		{}
  |  MULTIPOLYGON  multipolygon_text		{}


polyhedralsurface_text_representation :
  |  POLYHEDRALSURFACE z_m polyhedralsurface_text		{}
  |  POLYHEDRALSURFACE  polyhedralsurface_text		{}


tin_text_representation :
  |  TIN z_m tin_text		{}
  |  TIN  tin_text		{}

geometrycollection_text_representation :
  |  GEOMETRYCOLLECTION z_m geometrycollection_text		{}

linestring_text_body :
  |  linestring_text		{}

curvepolygon_text_body :
  |  curvepolygon_text		{}

polygon_text_body :
  |  polygon_text		{}

triangle_text_body :
        triangle_text           {}

point_text :
  |  empty_set 		{}
  |  LPAREN point RPAREN		{}

point :
      |    x y                  {}
      |    x y  z               {}
      |    x y  z  m            {}

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

linestring_text :
   | empty_set 		{}
   | LPAREN point  COMMA point  RPAREN {}

circularstring_text :
   | empty_set 		{}
   | LPAREN point  COMMA point  RPAREN {}

compoundcurve_text :
   | empty_set 		{}
   | LPAREN single_curve_text  COMMA single_curve_text  RPAREN {}

single_curve_text :
   | linestring_text_body 		{}
   | circularstring_text_representation		{}

curve_text :
   | linestring_text_body 		{}
   | circularstring_text_representation 		{}
   |  compoundcurve_text_representation		{}

ring_text :
   | linestring_text_body 		{}
   | circularstring_text_representation 		{}
   | compoundcurve_text_representation		{}

surface_text :
   | CURVEPOLYGON curvepolygon_text_body 		{}
   | polygon_text_body		{}

curvepolygon_text :
   | empty_set 		{}
   | LPAREN ring_text  COMMA ring_text  RPAREN {}

polygon_text :
   | empty_set 		{}
   | LPAREN linestring_text  COMMA linestring_text  RPAREN {}

triangle_text :
    | empty_set		{}
    | LPAREN linestring_text RPAREN		{}

multipoint_text :
    | empty_set		{}
    | LPAREN point_text  COMMA point_text  RPAREN {}

multicurve_text :
    | empty_set		{}
    | LPAREN curve_text  COMMA curve_text  RPAREN {}

multilinestring_text :
    | empty_set		{}
    | LPAREN linestring_text_body  COMMA linestring_text_body  RPAREN {}

multisurface_text :
    | empty_set		{}
    | LPAREN surface_text  COMMA surface_text  RPAREN {}

multipolygon_text :
    | empty_set		{}
    | LPAREN polygon_text_body  COMMA polygon_text_body  RPAREN {}

polyhedralsurface_text :
    | empty_set		{}
    | LPAREN polygon_text_body  COMMA polygon_text_body  RPAREN {}

tin_text :
    | empty_set		{}
    | LPAREN triangle_text_body  COMMA triangle_text_body  RPAREN {}

geometrycollection_text :
    | empty_set		{}
    | LPAREN well_known_text_representation  COMMA well_known_text_representation  RPAREN {}

empty_set : 
        EMPTY {EMPTY}

z_m :
       | ZM  {ZM}
       | Z   {Z}
       | M   {M}
