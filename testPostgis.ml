(*#require "postgis";;
#require "postgresql";;
#require "benchmark";;*)

open Postgis

let connecteur host dbname user pass =
        try new Postgresql.connection ~host:host
        ~dbname:dbname
        ~user:user
        ~password:pass ()
        with Postgresql.Error a ->  raise
        (Postgresql.Error a);;

let conn = connecteur "localhost" "UpperWorld" "ontologiae" "postgres";;

let req s =  conn#exec s ;;

let resreq = req "select a.name, ST_AsText(a.geom), b.name, ST_AsText(b.geom), ST_Intersects(a.geom,b.geom),  ST_Crosses(a.geom,b.geom), ST_Within(a.geom,b.geom)  from geometries a, geometries b WHERE a.name not like 'Coll%' and b.name not like 'Coll%'";;

let poly = 
       (Postgis.Syntax.POLYGON (None,
         [[Postgis.Syntax.V [0.; 0.]; Postgis.Syntax.V [10.; 0.]; Postgis.Syntax.V [10.; 10.]; Postgis.Syntax.V [0.; 10.]; Postgis.Syntax.V [0.; 0.]];
          [Postgis.Syntax.V [1.; 1.]; Postgis.Syntax.V [1.; 2.]; Postgis.Syntax.V [2.; 2.]; Postgis.Syntax.V [2.; 1.]; Postgis.Syntax.V [1.; 1.]]]));;

let poly2 = Postgis.Syntax.POLYGON (None, [[Postgis.Syntax.V [0.; 0.]; Postgis.Syntax.V [2.; 0.]; Postgis.Syntax.V [2.; 3.]; Postgis.Syntax.V [0.; 2.]; Postgis.Syntax.V [0.; 0.]]]);;

let poly3 = Postgis.Syntax.POINT(None, Postgis.Syntax.V [-1.5848751; 47.2291439]);;

let t1 = Postgis.Center (poly);;
let t2 = Postgis.Intersect (poly,poly2);;
let t3 = Postgis.Crosses (poly,poly2);;
let t4 = Postgis.Within (poly,poly2);;
let t5 = Postgis.Distance (poly,poly2);;
let t6 = Postgis.IsAtDistance (poly,poly2,0.5);;
let t7 = Postgis.Length (poly);;
let t8 = Postgis.Projection(poly3,100.,0.78537);;



let r1 = Postgis.static_request conn t1;;
let r2 = Postgis.static_request conn t2;;
let r3 = Postgis.static_request conn t3;;
let r4 = Postgis.static_request conn t4;;
let r5 = Postgis.static_request conn t5;;
let r6 = Postgis.static_request conn t6;;
let r7 = Postgis.static_request conn t7;;
let r8 = Postgis.static_request conn t8;;

(*
 * φ = LATITUDE
 * λ = LONGITUDE
ar φ2 = asin( sin(φ1)*cos(d/R) + cos(φ1)*sin(d/R)*cos(brng) );
var λ2 = λ1 + atan2( sin(brng)*sin(d/R)*cos(φ1), cos(d/R)-sin(φ1)*sin(φ2) );
*)
let project lat long angle distance =
        let r = 6371009. in (*en mètre*)
        let radian_to_degree r =  180.*.r /. 3.1415 in
        let degree_to_radian d =  3.1415 *. d /. 180. in
        let latrad  = degree_to_radian lat in
        let longrad = degree_to_radian long in
        let distance_angulaire = distance /. r in
        let sin_distance_angulaire = sin distance_angulaire in
        let cos_distance_angulaire = cos distance_angulaire in
        let sin_latrad = sin latrad in
        let cos_latrad = cos latrad in
        let latrad2 = asin ( sin_latrad*.cos_distance_angulaire +. cos_latrad*.sin_distance_angulaire*.cos(angle) ) in
        let longrad2 = longrad +. atan2 (sin(angle)*.sin_distance_angulaire*.cos_latrad) (cos_distance_angulaire-.sin_latrad*.sin(latrad2)) in
        radian_to_degree latrad2, radian_to_degree longrad2;;


 print_endline "Externe : 100 000";;
 
let nbcycle s = let parit = 1_000_000. /. s in 2_000_000_000. /. parit;;
 
 let t0 = Benchmark.make 0L in
        let r8 = for i = 1 to 100_000 do Postgis.static_request conn t8 done in
        let b = Benchmark.sub (Benchmark.make 0L) t0 in
        print_endline "Benchmark results:";
        print_endline (Benchmark.to_string b);
        print_endline ("Soit "^(nbcycle b.wall |> string_of_float)^" cycles par appel") ;;

print_endline "Interne : 1 000 0000";;

 let tt0 = Benchmark.make 0L in
        let r8 = for i = 1 to 1_000_000 do project 47.2291439 (-1.5848751) 0.78537 0.1 done in
        let b = Benchmark.sub (Benchmark.make 0L) tt0 in
        print_endline "Benchmark results:";
        print_endline (Benchmark.to_string b);
        print_endline ("Soit "^(nbcycle b.wall |> string_of_float)^" cycles par appel") ;;


  


