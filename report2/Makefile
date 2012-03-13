m2.pdf: m2.tex main.png boolean.png number.png whitespace.png
	@pdflatex m2.tex

main.png: main.gv
	@dot main.gv -Tpng > main.png

boolean.png: boolean.gv
	@dot boolean.gv -Tpng > boolean.png

number.png: number.gv
	@dot number.gv -Tpng > number.png

string.png: string.gv
	@dot string.gv -Tpng > string.png

whitespace.png: whitespace.gv
	@dot whitespace.gv -Tpng > whitespace.png
