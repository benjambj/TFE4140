TEX=$(shell which pdflatex) -interaction nonstopmode
BIBTEX=$(shell which bibtex)

NAME=technote

# Find all .tex-files in current dir
FILES=$(filter %.tex, $(shell /usr/bin/find .))
DOTFILES=$(filter %.dot, $(shell /usr/bin/find .))
DOTPDFS=$(patsubst %.dot, %.pdf, ${DOTFILES})
TEMP_EXTS=aux log toc idx ind ilg lot lof bbl blg brf out
TEMPS=$(patsubst %.tex, %, ${FILES})

.PHONY: clean clean_all

all: ${NAME}.pdf

clean_all: clean
	if [ -e '${NAME}.pdf' ]; then rm -f ${NAME}.pdf; fi

${NAME}.pdf: ${FILES} state.pdf
# ${NAME}.ind bibliography.bbl
	${TEX} ${NAME}.tex
	${TEX} ${NAME}.tex # to be shure of toc and links

${NAME}.ind: ${NAME}.idx
	makeindex ${NAME}

${NAME}.idx: ${NAME}.tex
	${TEX} ${NAME}.tex

bibliography.bbl:
	${BIBTEX} ${NAME}

dot: ${DOTPDFS}

%.pdf: %.dot
	dot -Tpdf -o $*.pdf $*.dot

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
