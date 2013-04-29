TEX=$(shell which pdflatex) -interaction nonstopmode
BIBTEX=$(shell which bibtex)

NAME=main

# Find all .tex-files in current dir
FILES=$(filter %.tex, $(shell /usr/bin/find .))
TEMP_EXTS=aux log toc idx ind ilg lot lof bbl blg brf out nls nlo
TEMPS=$(patsubst %.tex, %, ${FILES})

.PHONY: clean clean_all

all: ${NAME}.pdf

clean_all: clean
	if [ -e '${NAME}.pdf' ]; then rm -f ${NAME}.pdf; fi

${NAME}.pdf: ${FILES} ${NAME}.bbl
	${TEX} ${NAME}.tex # to be shure of toc and links

${NAME}.ind: ${NAME}.idx ${NAME}.nlo
	makeindex ${NAME}.idx
	makeindex ${NAME}.nlo  -s nomencl.ist -o ${NAME}.nls

${NAME}.idx: ${NAME}.tex
	${TEX} ${NAME}.tex

${NAME}.bbl: bibliography.bib ${NAME}.aux
	${BIBTEX} ${NAME}

${NAME}.aux: ${FILES}
	${TEX} ${NAME}.tex

# Loop though all source files and remove name concated with any temp-extension
clean:
	for f in ${TEMPS}; do\
		 for ext in ${TEMP_EXTS}; do\
			rm -f $$f.$$ext;\
		done;\
	done

#
# Thought we might wanted to spellcheck the .tex-files
#
spellcheck: ${FILES}
	for f in ${FILES}; do\
		aspell -t --home-dir=. -c $$f ; \
	done
