#include "lex.h"
#include <stdio.h>
#include <ctype.h>
#include <string.h>

char* yytext = ""; /* Lexeme (not '\0'
                      terminated)              */
int yyleng   = 0;  /* Lexeme length.           */
int yylineno = 0;  /* Input line number        */


int lex(){

   static char input_buffer[1024];
   char        *current;

   current = yytext + yyleng; /* Skip current
                                 lexeme        */

   while(1){       /* Get the next one         */
      while(!*current ){
         /* Get new lines, skipping any leading
         * white space on the line,
         * until a nonblank line is found.
         */

         current = input_buffer;
         if(!gets(input_buffer)){
            *current = '\0' ;

            return EOI;
         }
         ++yylineno;
         while(isspace(*current))
            ++current;
      }
      for(; *current; ++current){
         /* Get the next token */
         yytext = current;
         yyleng = 1;
         switch( *current ){
           case ';':
            return SEMI;
           case '+':
            return PLUS;
           case '-':
            return MINUS;
           case '*':
            return TIMES;
           case '/':
            return DIV;
           case '(':
            return LP;
           case ')':
            return RP;
           case '>':
            return GT;
           case '<':
            return LT;
           case '=':
            return ET;
           case '\n':
           case '\t':
           case ' ' :
            break;
           default:
            if(*current == ':' && *(current+1) == '=')
            {
              current += 2;
              yyleng = current - yytext;
              return COLET;
            }
            else if(!isalnum(*current))
               fprintf(stderr, "Not alphanumeric <%c>\n", *current);
            else{
                //identify string based lexemes
                char temp[50];
                int i=0;
               while(isalnum(*current))
               {
                temp[i++]= (*current);
                ++current;
               }
               temp[i]='\0';
               yyleng = current - yytext;
               if(strcmp(temp,"if")==0)
                    return IF;
               if(strcmp(temp,"then")==0)
                    return THEN;
               if(strcmp(temp,"while")==0)
                    return WHILE;
               if(strcmp(temp,"do")==0)
                    return DO;
               if(strcmp(temp,"begin")==0)
                    return BEGIN;
               if(strcmp(temp,"end")==0)
                    return END;
               return NUM_OR_ID;
            }
            break;
         }
      }
   }
}


static int Lookahead = -1; /* Lookahead token  */

int match(int token){
   /* Return true if "token" matches the
      current lookahead symbol.                */

   if(Lookahead == -1)
      Lookahead = lex();

#define EOI			0	/* End of input			*/
#define SEMI		1	/* ; 				*/
#define PLUS 		2	/* + 				*/
#define TIMES		3	/* * 				*/
#define LP			4	/* (				*/
#define RP			5	/* )				*/
#define NUM_OR_ID	6	/* Decimal Number or Identifier */
#define MINUS 		7
#define DIV			8
#define IF 			9
#define THEN		10
#define WHILE		11
#define DO			12
#define BEGIN		13
#define END 		14
#define COLET 		15
#define GT			16
#define LT			17
#define ET 			18
   if (token == Lookahead)
   {
	   	//Print lexemes for different tokens
      FILE * fp = fopen("Lexemes.txt", "a+");
   		if(token==1)
   			fprintf(fp,"<SEMI> ");
   		else if(token==2)
   			fprintf(fp,"<PLUS> ");
   		else if(token==3)
   			fprintf(fp,"<TIMES> ");
   		else if(token==4)
   			fprintf(fp,"<LEFT_PAR> ");
   		else if(token==5)
   			fprintf(fp,"<RIGHT_PAR> ");
   		else if(token==7)
   			fprintf(fp,"<MINUS> ");
   		else if(token==8)
   			fprintf(fp,"<DIV> ");
   		else if(token==9)
   			fprintf(fp,"<IF> ");
   		else if(token==10)
   			fprintf(fp,"<THEN> ");
   		else if(token==11)
   			fprintf(fp,"<WHILE> ");
   		else if(token==12)
   			fprintf(fp,"<DO> ");
   		else if(token==13)
   			fprintf(fp,"<BEGIN> ");
   		else if(token==15)
   			fprintf(fp,"<COLON> <EQUAL> ");
   		else if(token==16)
   			fprintf(fp,"<GREATER_THAN> ");
   		else if(token==17)
   			fprintf(fp,"<LESS_THAN> ");
   		else if(token==18)
   			fprintf(fp,"<EQUAL> ");
		fclose(fp);
   		return 1;
   }
   return 0;
}

void advance(void){
/* Advance the lookahead to the next
   input symbol.                               */

    Lookahead = lex();
}
