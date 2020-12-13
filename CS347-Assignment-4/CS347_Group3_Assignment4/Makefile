sqlquery:	sqlquery.lex sqlquery.y helper.c
		bison -d sqlquery.y
		flex sqlquery.lex
		gcc -o exec sqlquery.tab.c lex.yy.c helper.c -lfl -g
		
clean:		exec sqlquery.tab.c sqlquery.tab.h lex.yy.c
		rm exec sqlquery.tab.c sqlquery.tab.h lex.yy.c
