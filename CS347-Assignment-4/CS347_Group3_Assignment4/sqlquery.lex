%{
# include "sqlquery.tab.h"
#include "string.h"
%}

%%
(?i:SELECT)                          { return SELECT; }
(?i:PROJECT)                         { return PROJECT; }
(?i:CARTESIAN_PRODUCT)               { return CARTESIAN_PRODUCT; }
(?i:EQUI_JOIN)                       { return EQUI_JOIN; }
(?i:OR)                            { return OR; }
(?i:AND)                           { return AND; }
(?i:NOT)                           { return NOT; }
[0-9]+                          { yylval.integerValue = atoi(yytext); return INT; }
\<                             {return LT;}
\>                             {return GT;}
\<\=                            {return LTE;}
\>\=                            {return GTE;}
\=                             {return EQUAL;}             
\!\=                            {return NE;}           
,                               { return COMMA; }
\.                              { return DOT; }
\'[0-9A-Za-z_,]*\'                { 
									char help[200];
									int j=0;
									//removing inverted commas
									int len=strlen(yytext);
									for(int i=1;i<len-1;i++)
										help[j++]=yytext[i];
									help[j]='\0';
									sprintf(yylval.charText,"%s", help); 
									return STRING; 
								  }
\"[0-9A-Za-z_,]*\"                { 
									char help[200];
									int j=0;
									//removing inverted commas
									int len=strlen(yytext);
									for(int i=1;i<len-1;i++)
										help[j++]=yytext[i];
									help[j]='\0';
									sprintf(yylval.charText,"%s", help); 
									return STRING;
								  }
[(]                             { return LP; }
[)]                             { return RP; }
[A-Za-z_][0-9A-Za-z_]*          { sprintf(yylval.charText,"%s", yytext); return ID; }
\n                              { yylineno++; return NEWLINE; }
[ \t]                           { /* ignore whitespace */ }
.                               { printf("Unknown character %c\n", *yytext); }
%%