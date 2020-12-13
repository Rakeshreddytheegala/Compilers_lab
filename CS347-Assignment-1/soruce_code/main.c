#include <stdio.h>
#include <stdlib.h>
#include <error.h>
#include <string.h>
#include <ctype.h>
#include "lex.c"
#include "name.c"
#include "code_gen.c"


void main ()
{
	FILE * fp=fopen("Lexemes.txt","w");
	fp=fopen("Intermediate.txt","w");
	fclose(fp);
	//Run parser to find language
	stmt_list();
	if(match(EOI))
		write_in_file("Lexemes.txt","<END_OF_INPUT> ");
	else
    	fprintf( stderr,"%d: Grammar mismatch\n", yylineno );

    //Print symbol table of parsed language
	fp=fopen("Symbol_Table.txt","w");
	fprintf(fp, "ID\t\tSymbol\n");
	for(int i=0;i<symtable_size;i++)
	{
		fprintf(fp, "%d\t\t%s\n", i+1, symbol_entry[i]);
	}
	fclose(fp);
	printf("\"Lexemes.txt\", \"Symbol_Table.txt\" and \"Intermediate.txt\" generated\n");
	// convert();
}
