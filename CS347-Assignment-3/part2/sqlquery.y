%{
#include <stdio.h>
#include <stdlib.h>

int yylex();
int yyparse();
int yylineno;
void yyerror(char *s);
%}

// token declaration

%token SELECT PROJECT CARTESIAN_PRODUCT EQUI_JOIN
%token OR AND NOT
%token INT STRING ID
%token LT GT LTE GTE EQUAL NE
%token LP RP COMMA DOT NEWLINE

//Grammar
%%
stmts : stmt NEWLINE stmts
        | stmt
        | error NEWLINE {printf("Invalid Syntax: Error in line number %d\n\n",yylineno-1);} stmts 
        ;

stmt : SELECT LT condition GT LP Table_Name RP      {printf("\nValid Syntax\n");}
        | PROJECT LT attribute_list GT LP Table_Name RP     {printf("\nValid Syntax\n");}
        | LP Table_Name RP CARTESIAN_PRODUCT LP Table_Name RP       {printf("\nValid Syntax\n");}
        | LP Table_Name RP EQUI_JOIN LT condition GT LP Table_Name RP   {printf("\nValid Syntax\n");}
        | %empty
        ;

// OR has lower precedence than AND
condition : temp_cond1 OR condition
            | temp_cond1
            ;

// AND has lower precedence than NOT
temp_cond1 : temp_cond2 AND temp_cond1
            | temp_cond2
            ;

temp_cond2 : NOT expression
            | expression
            ;

expression : column op STRING
            | STRING op column
            | column op column
            | column op INT
            | INT op column
            | INT op INT
            | STRING op STRING
            | LP condition RP
            ;

op : LT
    | GT
    | LTE
    | GTE
    | EQUAL
    | NE
    ;

attribute_list : column COMMA attribute_list
                | column
                ;

column : column_name
        | Table_Name DOT column_name
        ;

column_name : ID
            ;

Table_Name : ID
            ;


%%
int main()
{
  yyparse();
}

void yyerror(char *s)
{}
