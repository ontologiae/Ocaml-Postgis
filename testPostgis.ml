#require "postgis";;
#require "postgresql";;
#require "benchmark";;

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


(*let t0 = Benchmark.make 0L in
        let r8 = for i = 1 to 1_000_000 do Postgis.static_request conn t8 done in
        let b = Benchmark.sub (Benchmark.make 0L) t0 in
        print_endline "Benchmark results:";
        print_endline (Benchmark.to_string b)  ;;

*)
