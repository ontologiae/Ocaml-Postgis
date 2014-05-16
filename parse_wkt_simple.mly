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
|    point_text_representation                                  {$1} // POINT
|    curve_text_representation                                  {$1} // LINESTRING, CIRCULARSTRING, COMPOUNDCURVE
|    surface_text_representation                                {$1}
|    collection_text_representation                             {$1}



point_text_representation :
       | POINT  z_m  point_text                                 {POINT(Some($2),$3)}
       | POINT  point_text                                      {POINT(None,$2)}

// Start -> 2
curve_text_representation :
 |   LINESTRING  linestring_text                                {LINESTRING(None,$2)}
 |   LINESTRING z_m linestring_text                             {LINESTRING(Some($2),$3)}
 |   CIRCULARSTRING  circularstring_text                        {CIRCULARSTRING(None,$2)    }
 |   CIRCULARSTRING z_m circularstring_text                     {CIRCULARSTRING(Some($2),$3)}
 |   COMPOUNDCURVE  compoundcurve_text                          {COMPOUNDCURVE(None,$2)}        // wkt list
 |   COMPOUNDCURVE  z_m compoundcurve_text                      {COMPOUNDCURVE(Some($2),$3)}






// Start -> 3

/*surface_text_representation_list:
        | empty_set                                             {$1}
        | COMMA surface_text_representation                     {[$2]}
        | COMMA surface_text_representation surface_text_representation_list {$2::$3}*/

surface_text_representation :
 |   CURVEPOLYGON  surface_text_representation               	{CURVEPOLYGON(None,[$2])}
 |   CURVEPOLYGON  z_m  surface_text_representation             {CURVEPOLYGON(Some($2),[$3])}
 // TODO les listes
 |   POLYGON  polygon_text		                        {POLYGON(None,$2)}
 |   POLYGON  z_m  polygon_text         	                {POLYGON(Some($2),$3)}
 |  TRIANGLE  z_m  triangle_text		                {TRIANGLE(Some($2),$3)}
 |  TRIANGLE  triangle_text    		                        {TRIANGLE(None,$2)}

polygon_text : //vector list list list
   | empty_set 		                                        {$1}
   | LPAREN linestring_text  RPAREN                             {[$2]}
   | LPAREN linestring_text linestring_list RPAREN              {$2::$3}


triangle_text :
    | empty_set		                                        {[]}
    | LPAREN linestring_text RPAREN		                {$2}





// Start 4


collection_text_representation :
 |  MULTIPOINT z_m multipoint_text		                {MULTIPOINT(Some($2),$3)}
 |  MULTIPOINT  multipoint_text		                        {MULTIPOINT(None,$2)}
 |  MULTICURVE z_m multicurve_text 		                {MULTICURVE(Some($2),$3)}
 |  MULTICURVE multicurve_text 		                        {MULTICURVE(None,$2)}
 |  MULTILINESTRING z_m multilinestring_text		        {MULTILINESTRING(Some($2),$3)}
 |  MULTILINESTRING  multilinestring_text		        {MULTILINESTRING(None,$2)}
 |  MULTISURFACE z_m multisurface_text 		                {MULTISURFACE(Some($2),$3)}
 |  MULTISURFACE  multisurface_text 	        	        {MULTISURFACE(None,$2)}
 |  POLYHEDRALSURFACE z_m polyhedralsurface_text                {POLYHEDRALSURFACE(Some($2),$3)}
 |  POLYHEDRALSURFACE  polyhedralsurface_text		        {POLYHEDRALSURFACE(None,$2)}
 |  TIN z_m tin_text	                        	        {TIN(Some($2),$3)}
 |  TIN  tin_text	                        	        {TIN(None,$2)}


curve_text :
   | linestring_text 		                                {LINESTRING(None,$1)}
   | CIRCULARSTRING  circularstring_text                        {CIRCULARSTRING(None,$2)}
   | CIRCULARSTRING z_m circularstring_text                     {CIRCULARSTRING(Some($2),$3)}
   | COMPOUNDCURVE  compoundcurve_text                          {COMPOUNDCURVE(None,$2)}
   | COMPOUNDCURVE  z_m compoundcurve_text                      {COMPOUNDCURVE(Some($2),$3)}

ring_text:
        | curve_text {$1}




surface_text :
   | CURVEPOLYGON curvepolygon_text     	                {CURVEPOLYGON(None,$2)}
   | polygon_text		                                {POLYGON(None,$1)}


curvepolygon_text :
   | empty_set 		                                        {[]}
   | LPAREN ring_text  ring_list  RPAREN                        {$2::$3}


multipoint_text :
    | empty_set		                                        {[]}
    | LPAREN point_text  point_list   RPAREN                    {$2::$3}

multicurve_text :
    | empty_set		                                        {[]}
    | LPAREN curve_text  curve_list  RPAREN                     {$2::$3}


multilinestring_text :
    | empty_set		                                        {[]}
    | LPAREN linestring_text  linestring_list RPAREN            {$2::$3}

multisurface_text :
    | empty_set		                                        {[]}
    | LPAREN surface_text  surface_text_list  RPAREN            {$2::$3}
    // wkt list

multipolygon_text : //vector list list list list
    | empty_set		                                        {$1}
    | LPAREN polygon_text    RPAREN                             {$2}

polyhedralsurface_text : //vector list list list list mais devrait être vector list list
    | empty_set		                                        {[]}
    | LPAREN polygon_text    RPAREN                             {[POLYGON(None,$2)]}

tin_text :
    | empty_set		                                        {[]}
    | LPAREN triangle_text  triangle_text_body_list RPAREN {$2::$3}

geometrycollection_text :
    | empty_set		                                        {[]}
    | LPAREN well_known_text_representation  well_known_text_representation_list  RPAREN {$2::$3}


well_known_text_representation_list:
     | empty_set                                                {[]}
     | COMMA well_known_text_representation                     {[$2]}
     | COMMA well_known_text_representation well_known_text_representation_list {$2::$3}









// LIB BASE



point_text :
  |  empty_set 		                                        {V []}
  |  LPAREN point RPAREN	                                {$2}

point_list :
   | empty_set                                                  {[]}
   | COMMA point point_list                                     {$2::$3}
   | COMMA point                                                {[$2]}
   
point :
      |    x y                                                  {V [$1;$2]}
      |    x y z                                                {V [$1;$2;$3]}
      |    x y z m                                              {V [$1;$2;$3;$4]}

x : 
 | NBR {$1}
y : 
 | NBR {$1}
z : 
 | NBR {$1}
m : 
 | NBR {$1}



// RECURSIVE LIST

linestring_list: // vector list list
   | empty_set                                                  {$1} 
   | COMMA linestring_text                                      {[$2]}
   | COMMA linestring_text linestring_list                      {$2::$3}


linestring_text :
   | empty_set 		                                        {[]} // vector list
   | LPAREN point    RPAREN                                     {[$2]}
   | LPAREN point point_list RPAREN                             {$2::$3}

   
   
single_curve_list :
   | empty_set                                                  {[]} //wkt list
   | COMMA single_curve_text                                    {[$2]}
   | COMMA single_curve_text single_curve_list                  {$2::$3}


triangle_text_body_list:
    | empty_set                                                 {[]}
    | COMMA triangle_text                                       {[$2]}
    | COMMA triangle_text triangle_text_body_list               {$2::$3}

surface_text_list:
   | empty_set                                                  {[]}
   | COMMA surface_text                                         {[$2]}
   | COMMA surface_text surface_text_list                       {$2::$3}

curve_list:
   | empty_set                                                  {[]}
   | COMMA curve_text                                           {[$2]}
   | COMMA curve_text curve_list                                {$2::$3}


ring_list:
   | empty_set                                                  {[]}
   | COMMA ring_text                                            {[$2]}
   | COMMA ring_text ring_list                                  {$2::$3}









circularstring_text :
   | empty_set 		                                        {[]}
   | LPAREN point  point_list  RPAREN                           {$2::$3}

compoundcurve_text :
   | empty_set 		                                        {[]} // wkt list
   | LPAREN single_curve_text  single_curve_list  RPAREN        {($2)::$3}

single_curve_text : //wkt
   | linestring_text 		                                { LINESTRING(None,$1) }
   |  CIRCULARSTRING  circularstring_text                       { CIRCULARSTRING(None,$2)     }
   |  CIRCULARSTRING z_m circularstring_text                    { CIRCULARSTRING(Some($2),$3) }


    
empty_set : 
        EMPTY {[]}

z_m :
       | ZM  {ZM}
       | Z   {Z}
       | M   {M}
