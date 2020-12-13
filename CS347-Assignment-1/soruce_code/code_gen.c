// #include "code_gen.h"

extern char *newname( void       );
extern void freename( char *name );

void stmt_list();
void stmt();
void opt_stmts();
char * expr();
char    *factor     ( void );
char    *term       ( void );
char    *expression ( void );
char symbol_entry[500][100];
int symtable_size=0;

//Write gieven string in specified file
void write_in_file (char * filename, char * text)
{
	FILE *fp = fopen(filename, "a+");
	fprintf(fp, "%s",text);
	fclose(fp);
}

// Write integer in file
void write_in_file_int (char * filename, int val)
{
	FILE *fp = fopen(filename, "a+");
	fprintf(fp, "%d",val);
	fclose(fp);
}

//Generate symbol table during parsing
int in_symtable(char * s)
{
	for(int i=0;i<symtable_size;i++)
	{
		if(strcmp(s,symbol_entry[i])==0)
			return i;
	}
	return -1;
}

char *tp;
int done = 0;

//Starting production of grammar generation
void stmt_list ()
{
    /* stmt_list ->   stmt
                    | stmt_list'

        stmt_list' -> stmt; stmt_list'
                    | epsilon
    */

    if (!done){
		done = 1;
		tp = (char*)malloc (100*sizeof(char));
	}

    char * tempvar;
    while (1)
    {
        stmt();
        if(match(END) || match(EOI))
        {
            break;
        }
        if( match( SEMI ) )
            advance();
        else
        {
					write_in_file("Lexemes.txt","<SEMI> ");
					fprintf( stderr,"%d: Inserting missing semicolon\n", yylineno );
				}
    }
}

void stmt ()
{
    /*stmt ->   id := expr
                | if expr then stmt
                | while expr do stmt
                | begin opt_stmts end
    */

    char * tempvar;
    if(match(NUM_OR_ID))
    {

        int yyleng_temp=yyleng;
        char yytext_temp[50];
        strcpy(yytext_temp,yytext);
				char sym_name[50];
				for(int i=0;i<yyleng_temp;i++)
					sym_name[i]=yytext_temp[i];
				sym_name[yyleng_temp]='\0';
				//
				int sym_index=in_symtable(sym_name);
				if(sym_index==-1)
				{
					strcpy(symbol_entry[symtable_size],sym_name);
					sym_index=symtable_size;
					symtable_size++;
				}
				sym_index++;

				write_in_file("Lexemes.txt","<ID,");
				write_in_file_int("Lexemes.txt",sym_index);
				write_in_file("Lexemes.txt","> ");
        advance();
        if(!match(COLET))
        {
					write_in_file("Lexemes.txt","<COLON> <EQUAL> ");
					fprintf( stderr,"%d: Inserting missing colon equal to\n", yylineno );
        }
				else
            advance();


		tempvar=expr();

		char help[30], help2[30];
		char yy[50];
		for(int i=0;i<yyleng_temp;i++)
				yy[i]=yytext_temp[i];
		yy[yyleng_temp]='\0';
		uscore(yy, help);
		uscore(tempvar, help2);
		sprintf(tp, "%s = %s\n", help, help2);
        write_in_file("Intermediate.txt", tp);
        freename(tempvar);
        return;
    }
    //check if "IF" case
    if (match(IF))
    {
        sprintf(tp, "if(\n");
        write_in_file("Intermediate.txt", tp);
        advance();
        tempvar=expr();
        char help[30];
        uscore(tempvar, help);
        sprintf(tp, "%s\n)\n", help);
        write_in_file("Intermediate.txt", tp);
        freename(tempvar);
        if(!match(THEN))
        {
					write_in_file("Lexemes.txt","<THEN> ");
					fprintf( stderr,"%d: Inserting missing then\n", yylineno );
        }
				else
            advance();

        sprintf(tp, "then{\n");
        write_in_file("Intermediate.txt", tp);
        stmt();
       	sprintf(tp, "}\n");
        //Writing intermediate symbols
        write_in_file("Intermediate.txt", tp);
        return;
    }
    //check "WHILE" terminal encountered
    if (match(WHILE))
    {
        sprintf(tp, "while(\n");
        write_in_file("Intermediate.txt", tp);
        advance();
        tempvar=expr();
        char help[30];
        uscore(tempvar, help);
        sprintf(tp, "%s\n)\n", help);
        write_in_file("Intermediate.txt", tp);
        freename(tempvar);
        if(!match(DO))
        {
					write_in_file("Lexemes.txt","<DO> ");
					fprintf( stderr,"%d: Inserting missing do\n", yylineno );
        }
				else
            advance();

       	sprintf(tp, "do{\n");
        write_in_file("Intermediate.txt", tp);
        stmt();
        sprintf(tp, "}\n");
        write_in_file("Intermediate.txt", tp);
        return;
    }
    //check "BEGIN" terminal
    if(match(BEGIN))
    {
        sprintf(tp, "begin{\n");
        write_in_file("Intermediate.txt", tp);
        advance();
        opt_stmts();
        return;
    }
    // All cases covered -> Must be a syntax error
    fprintf( stderr,"%d: Grammar mismatch\n", yylineno );
    // exit(0);
}

void opt_stmts ()
{
    /* opt_stmts -> stmt_lists
                    | epsilon
    */

    if(match(END))
    {
        advance();
    	write_in_file("Lexemes.txt","<END> ");
        sprintf(tp, "}end\n");
        write_in_file("Intermediate.txt", tp);
        return;
    }
    stmt_list();
    if(!match(END))
    {
			write_in_file("Lexemes.txt","<END> ");
			fprintf( stderr,"%d: Inserting missing end\n", yylineno);
   	}
		else
        advance();
	write_in_file("Lexemes.txt","<END> ");
    sprintf(tp, "}end\n");
    write_in_file("Intermediate.txt", tp);
}

char   *expr ()
{
    /* expr -> expression < expression
             | expression = expression
             | expression = expression
             | expression
    */

    char * tempvar;
    char * tempvarRes;
    char * tempvar2;

    tempvar=expression();
    if(match(GT))
    {
        freename(tempvar);
        tempvarRes=newname();
        tempvar=newname();

        sprintf(tp, "%s = %s\n", tempvar, tempvarRes);
        write_in_file("Intermediate.txt", tp);
        advance();
        tempvar2=expression();

        sprintf(tp, "%s = %s > %s\n",tempvarRes,tempvar,tempvar2);
        write_in_file("Intermediate.txt", tp);
        freename(tempvar2);
        freename(tempvar);
        return tempvarRes;
    }
    // Less than equal to case
    else if (match(LT))
    {
		freename(tempvar);
		tempvarRes=newname();
		tempvar=newname();

		sprintf(tp, "%s = %s\n", tempvar, tempvarRes);
		write_in_file("Intermediate.txt", tp);
		advance();
		tempvar2=expression();

		sprintf(tp, "%s = %s < %s\n",tempvarRes,tempvar,tempvar2);
		write_in_file("Intermediate.txt", tp);
		freename(tempvar2);
		freename(tempvar);
		return tempvarRes;
    }
    // Equal to case
    else if (match(ET))
    {
		freename(tempvar);
		tempvarRes=newname();
		tempvar=newname();

		sprintf(tp, "%s = %s\n", tempvar, tempvarRes);
		write_in_file("Intermediate.txt", tp);
		advance();
		tempvar2=expression();

		sprintf(tp, "%s = %s == %s\n",tempvarRes,tempvar,tempvar2);
		write_in_file("Intermediate.txt", tp);
		freename(tempvar2);
		freename(tempvar);
		return tempvarRes;
    }
    else
    {
        return tempvar;
    }
    //return register with temporary value
}

char   *expression()
{
    /* expression -> term expression'
     * expression' -> + term expression'
                    | - term expression'
                    | epsilon
     */
    // printf("expression\n");

    char  *tempvar, *tempvar2;

    tempvar = term();
    while(1)
    {
        if(match(PLUS))
        {
            advance();
            tempvar2 = term();
            sprintf(tp, "%s += %s\n", tempvar, tempvar2 );
            	write_in_file("Intermediate.txt", tp);
            freename( tempvar2 );
        }
        else if(match(MINUS))
        {
			advance();
			tempvar2 = term();
			sprintf(tp, "%s -= %s\n", tempvar, tempvar2 );
			write_in_file("Intermediate.txt", tp);
			freename( tempvar2 );
        }
        else
            break;
    }
    return tempvar;
}

char    *term()
{
    /* term -> factor * factor
             | factor / factor
             | factor
    */

    char  *tempvar, *tempvar2 ;

    tempvar = factor();
    while(1)
    {
        if( match( TIMES ) )
        {
            advance();
            tempvar2 = factor();
            sprintf(tp, "%s *= %s\n", tempvar, tempvar2 );
        		write_in_file("Intermediate.txt", tp);
            freename( tempvar2 );
        }
        else if (match (DIV))
        {
			advance();
			tempvar2 = factor();
			sprintf(tp, "%s /= %s\n", tempvar, tempvar2 );
			write_in_file("Intermediate.txt", tp);
			freename( tempvar2 );
        }
        else
            break;
    }

    return tempvar;
}

char    *factor()
{
    /* factor -> NUM_OR_ID
    */

    char *tempvar;

    if( match(NUM_OR_ID) )
    {
 /* Print the assignment instruction. The %0.*s conversion is a form of
  * %X.Ys, where X is the field width and Y is the maximum number of
  * characters that will be printed (even if the string is longer). I'm
  * using the %0.*s to print the string because it's not \0 terminated.
  * The field has a default width of 0, but it will grow the size needed
  * to print the string. The ".*" tells printf() to take the maximum-
  * number-of-characters count from the next argument (yyleng).
  */

		char sym_name[50];
		for(int i=0;i<yyleng;i++)
			sym_name[i]=yytext[i];


		sym_name[yyleng]='\0';

		int flag=0;
		for(int i=0;i<strlen(sym_name);i++)
		{
			if(sym_name[i]>='0' && sym_name[i]<='9')
				continue;
			flag=1;
			break;
		}
		if(flag==0)
		{
			write_in_file("Lexemes.txt","<const,");
			write_in_file("Lexemes.txt",sym_name);
		}
		else
		{
			write_in_file("Lexemes.txt","<ID,");
			int sym_index=in_symtable(sym_name);
			if(sym_index==-1)
			{
				strcpy(symbol_entry[symtable_size],sym_name);
				sym_index=symtable_size;
				symtable_size++;
			}
			sym_index++;
			write_in_file_int("Lexemes.txt",sym_index);
		}

		write_in_file("Lexemes.txt","> ");

		char help[30];
		char yy[50];
		for(int i=0;i<yyleng;i++)
				yy[i]=yytext[i];
		yy[yyleng]='\0';
		uscore(yy, help);
        sprintf(tp, "%s = %s\n", tempvar = newname(), help );
        write_in_file("Intermediate.txt", tp);
        advance();
    }
    // else if( match(LP) )
    // {
    //     advance();
    //     tempvar = expression();
    //     if( match(RP) )
    //         advance();
    //     else
    //         fprintf(stderr, "%d: Mismatched parenthesis\n", yylineno );
    // }
    else
 		fprintf( stderr, "%d: Number or identifier expected\n", yylineno );

    return tempvar;
}
