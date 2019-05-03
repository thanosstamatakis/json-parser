# Makefile
all: calc


calc:
	bison -y -d json.y
	flex json.l
	gcc -c y.tab.c lex.yy.c
	gcc y.tab.o lex.yy.o -o parser

clean:
	rm parser y.tab.c lex.yy.c y.tab.h y.tab.o lex.yy.o