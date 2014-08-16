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
	ocamlfind ocamlc -c -thread -package batteries -package postgresql -o postgis.cmi postgis.mli
	ocamllex.opt -q lexer.mll
	ocamlyacc parse_wkt.mly
	ocamlfind ocamlc -c -thread -package batteries -package postgresql -o syntax.cmo syntax.ml
	ocamlfind ocamlc -c -thread -package batteries -package postgresql -o parse_wkt.cmi parse_wkt.mli
	ocamlfind ocamlc -c -thread -package batteries -package postgresql -o lexer.cmo lexer.ml
	ocamlfind ocamlc -c -thread -package batteries -package postgresql -o wktparse.cmo wktparse.ml
	ocamlfind ocamlc -c -thread -package batteries -package postgresql -o postgis.cmo postgis.ml
	ocamlfind ocamlc -c -thread -package batteries -package postgresql -o parse_wkt.cmo parse_wkt.ml
	ocamlfind ocamlc -a -thread -package batteries -package postgresql syntax.cmo parse_wkt.cmo lexer.cmo wktparse.cmo postgis.cmo -o postgis.cma

opt:
	ocamlfind ocamlc -c -thread -package batteries -package postgresql -o postgis.cmi postgis.mli
	ocamlfind ocamlc -c -thread -package batteries -package postgresql -o syntax.cmo syntax.ml
	ocamllex.opt lexer.mll
	ocamlyacc parse_wkt.mly
	ocamlfind ocamlc -c -thread -package batteries -package postgresql -o parse_wkt.cmi parse_wkt.mli
	ocamlfind ocamlc -c -thread -package batteries -package postgresql -o lexer.cmo lexer.ml
	ocamlfind ocamlc -c -thread -package batteries -package postgresql -o wktparse.cmo wktparse.ml
	ocamlfind ocamlopt -c -thread -package batteries -package postgresql -o syntax.cmx syntax.ml
	ocamlfind ocamlopt -c -thread -package batteries -package postgresql -o parse_wkt.cmx parse_wkt.ml
	ocamlfind ocamlopt -c -thread -package batteries -package postgresql -o lexer.cmx lexer.ml
	ocamlfind ocamlopt -c -thread -package batteries -package postgresql -o wktparse.cmx wktparse.ml
	ocamlfind ocamlopt -c -thread -package batteries -package postgresql -o postgis.cmx postgis.ml
	ocamlfind ocamlopt -a -thread -package batteries -package postgresql syntax.cmx parse_wkt.cmx lexer.cmx wktparse.cmx postgis.cmx -o postgis.cmxa


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
		rm -f *~ *.cm[ioxa] *.o *.cmxa
		rm -rf html
install:
		ocamlfind install postgis META postgis.cma postgis.cmxa *.cmi *.mli *.a
		#*.cm[iox] *.o
uninstall:
		ocamlfind remove postgis

