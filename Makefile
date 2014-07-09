TARGET=wktparse

SOURCES = \
	syntax.ml \
	lexer.mll \
	parse_wkt.mly \
	wktparse.ml \
	postgis.ml

OCAMLBUILD=ocamlbuild -classic-display 
#-use-menhir
CAML2HTML=caml2html
OCAMLDOC=ocamldoc

default: byte

all: byte opt html

top: 
	utop -I _build/  syntax.cmo  lexer.cmo parse_wkt.cmo wktparse.cmo  -init postgis.ml


byte:
	ocamllex.opt lexer.mll
	ocamlyacc parse_wkt.mly
	ocamlc.opt -c -o syntax.cmo syntax.ml
	ocamlc.opt -c -o parse_wkt.cmi parse_wkt.mli
	ocamlc.opt -c -o lexer.cmo lexer.ml
	ocamlc.opt -c -o parse_wkt.cmo parse_wkt.ml
	ocamlfind ocamlc -c -linkall -thread -linkpkg -package batteries,postgresql syntax.cmo parse_wkt.cmo lexer.cmo wktparse.ml -o wktparse.cmo
	ocamlfind ocamlc -c -linkall -thread -linkpkg -package batteries,postgresql syntax.cmo parse_wkt.cmo lexer.cmo wktparse.cmo postgis.mli
	ocamlfind ocamlc -c -linkall -thread -linkpkg -package batteries,postgresql syntax.cmo parse_wkt.cmo lexer.cmo wktparse.cmo postgis.ml -o postgis.cmo

opt:
	ocamllex.opt lexer.mll
	ocamlyacc parse_wkt.mly
	ocamlopt.opt -c -o syntax.cmx syntax.ml
	ocamlopt.opt -c -o parse_wkt.cmi parse_wkt.mli
	ocamlopt.opt -c -o lexer.cmx lexer.ml
	ocamlopt.opt -c -o wktparse.cmx wktparse.ml
	ocamlopt.opt -c -o parse_wkt.cmx parse_wkt.ml
	ocamlfind ocamlopt -c -linkall -thread -linkpkg -package batteries,postgresql syntax.cmx parse_wkt.cmx lexer.cmx wktparse.cmx postgis.mli
	ocamlfind ocamlopt -c -linkall -thread -linkpkg -package batteries,postgresql syntax.cmx parse_wkt.cmx lexer.cmx wktparse.cmx postgis.ml 


#native:
#	$(OCAMLBUILD) -classic-display $(TARGET).native

web: html
	echo '<div class="lang">' > web.html
	echo "<h3>$(TARGET)</h3>" >> web.html
	echo '<div class="version">Last update: ' >> web.html
	echo '</div>' >> web.html
	echo '<div class="description">' >> web.html
	cat description.html >> web.html
	echo '</div>' >> web.html
	echo '<div class="download">Download source: <a href="src/$(TARGET).zip">$(TARGET).zip</a></div>' >> web.html
	/bin/echo -n '<div class="source"><a href="html/$(TARGET).html">View source online</a> (' >> web.html
	cat $(SOURCES) | wc -l >> web.html
	echo ' lines)</div>' >> web.html
	echo "</div>" >> web.html

html:
	/bin/mkdir html
	$(CAML2HTML) -nf -ln -noannot -o html/$(TARGET).html $(SOURCES)

#clean:
#	rm *.cm*
#	/bin/rm -rf web.html html/
#	$(OCAMLBUILD) -clean

clean:
		rm -f *~ *.cm[iox] *.o
		rm -rf html
install:
		ocamlfind install postgis META *.mli *.ml *.cm[iox] *.o
uninstall:
		ocamlfind remove postgis

