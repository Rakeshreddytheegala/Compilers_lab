main:	main.lex
		flex main.lex
		gcc -o exec lex.yy.c 
		
clean:	exec lex.yy.c temp.txt output.txt
		rm exec lex.yy.c temp.txt output.txt