%{
# include "sqlquery.tab.h"
%}

%%
\n                              {printf("%s",yytext ); yylineno++; return NEWLINE; }
SELECT                          {printf("<SELECT> " ); return SELECT;}
PROJECT                         {printf("<PROJECT> " ); return PROJECT;}
CARTESIAN_PRODUCT               {printf("<CARTESIAN_PRODUCT> " ); return CARTESIAN_PRODUCT;} 
EQUI_JOIN                       {printf("<EQUI_JOIN> " ); return EQUI_JOIN;}
OR                            	{printf("<OR> " ); return OR;}
AND                           	{printf("<AND> " ); return AND;}
NOT                           	{printf("<NOT> " ); printf("<%s> ",yytext ); return NOT;}
[0-9]+                          {printf("<INT, %s> ",yytext ); return INT; }
\'[A-Za-z_][0-9A-Za-z_]*\'		{printf("<STRING, %s> ",yytext ); return STRING;}
\"[A-Za-z_][0-9A-Za-z_]*\"  	{printf("<STRING, %s> ",yytext ); return STRING;}
\<                             {printf("<LT> " ); return LT;}
\>                             {printf("<GT> " ); return GT;}
\<\=                            {printf("<LTE> " ); return LTE;}
\>\=                            {printf("<GTE> " ); return GTE;}
\=                             {printf("<EQUAL> " ); return EQUAL;}             
\<\>                            {printf("<NE> " ); return NE;} 
\(                         	    {printf("<LP> " ); return LP;}
\)                           	{printf("<RP> " ); return RP;}
,                               {printf("<COMMA> " ); return COMMA;}
\.                              {printf("<DOT> " ); return DOT;}
[A-Za-z_][0-9A-Za-z_]*          {printf("<ID, %s> ", yytext ); return ID; }
[ \t]                           {/* no need to do anything for whitespaces */ }
.                               {printf("Invalid character %c\n", *yytext);}
%%
