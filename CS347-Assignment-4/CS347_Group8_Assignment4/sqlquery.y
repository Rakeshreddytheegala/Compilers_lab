%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex();
int yyparse();
int yylineno;
int yylinenumber;
char* yytext;
int yyleng;
void yyerror(char* s);
int currentValue;
char curArrayList[200][200];
%}

%code requires 
{
    #include "helper.h"
}

%union 
{
    struct OrList orList;
    struct AndEntry andEntry;
    struct AndList andList;
    
    char charText[100];
    int integerValue;
    struct 
    {
        char* table;
        char* colName;
    } columnAttribute;

    struct 
    {
        int operandType;
    } opType;
}

// token declaration

%token SELECT PROJECT CARTESIAN_PRODUCT EQUI_JOIN
%token OR AND NOT
%token INT STRING ID
%token LT GT LTE GTE EQUAL NE
%token LP RP COMMA DOT NEWLINE

%type <orList> condition
%type <andList> temp_cond1
%type <andEntry> temp_cond2
%type <andEntry> expression
%type <opType> operator
%type <columnAttribute> column
%type <integerValue> INT;
%type <charText> STRING;
%type <charText> ID;



//Grammar and the respective implementation
%%
stmts : stmt NEWLINE stmts
        | stmt
        | error NEWLINE {printf("Invalid Syntax: Error in line number %d\n",yylineno-1);printf("-----------------------------------------\n-----------------------------------------\n\n");} stmts 
        ;


stmt:  SELECT LT  GT LP ID RP
    {
        yylinenumber = yylineno;
        char fileName[200];
        memset(fileName,0,200);
        sprintf(fileName,"testfile/%s.csv",$5);         //Getting the table name
        if(is_table_present($5))
        {   
            FILE* fp = fopen(fileName,"r");             //Open the respective database table
            char str[1000];
            fgets(str, 1000, fp);
            printf("%s", str);
            fgets(str, 1000, fp);
            OrList condOr;
            condOr.head = 0;
            condOr.tail = 0;
            int recordCount = 0;
            
            //Output the required records satisfying the query
            while (fgets(str, 1000, fp))
            {
                sscanf(str, "%[^\n]", str);
                int res = computingCondSelect(condOr, str, $5);     //Verify the condition
                if (res == -1)
                {
                    break;
                }
                else if (res)  
                {
                    printf("%s\n", str);                                        //Print the record as it satisfies criteria
                    recordCount++;
                }
            }
            printf("Total number of records : %d\n", recordCount);
            fclose(fp);
        }
        else
        {
            printf("Could not find Table %s.\n",$5);
        }
        printf("-----------------------------------------\n-----------------------------------------\n\n");        
    }
    |SELECT LT condition GT LP ID RP
    {
        yylinenumber = yylineno;
        char fileName[200];
        memset(fileName,0,200);
        sprintf(fileName,"testfile/%s.csv",$6);         //Getting the table name
        if(is_table_present($6))
        {
            FILE* fp = fopen(fileName,"r");             //Open the respective database table
            char str[1000];
            fgets(str, 1000, fp);
            printf("%s", str);
            fgets(str, 1000, fp);
            int recordCount = 0;
            
            //Output the required records satisfying the query
            while (fgets(str, 1000, fp))
            {
                sscanf(str, "%[^\n]", str);
                int returnResult = computingCondSelect($3, str, $6);        //Verify the condition
                if (returnResult == -1)
                {
                    break;
                }
                else if (returnResult)  
                {
                    recordCount++;
                    printf("%s\n", str);                                    //Print the record as it satisfies criteria
                }
            }

            printf("Total number of records : %d\n", recordCount);
            fclose(fp);
        }
        else
        {
            printf("Could not find Table %s.\n",$6); 
        }
        printf("-----------------------------------------\n-----------------------------------------\n\n");
    }
    | PROJECT LT attribute_list GT LP ID RP
    {
        //Project the required columns in the query by veryfing presence of table and required attributes
        yylinenumber = yylineno;
        if (is_table_present($6)) 
        {
            projection(curArrayList, currentValue, $6);        
        }
        else 
        {
            fprintf(stdout, "Could not find Table %s.\n", $6);
        }
        printf("-----------------------------------------\n-----------------------------------------\n\n");
    }
    | LP ID RP CARTESIAN_PRODUCT LP ID RP       
    {
        //Getting each pair of records from both tables as the cartesian product query
        yylinenumber = yylineno;
        cartesian_product($2, $6);
        printf("-----------------------------------------\n-----------------------------------------\n\n");
    }
    | LP ID RP EQUI_JOIN LT condition GT LP ID RP       
    {
        //Joining of tables on similar attributes
        yylinenumber = yylineno;
        int recordCount=0;
        
        //Check if both tables are present
        if (!is_table_present($2)) 
        {
            fprintf(stdout, "Table %s not present\n", $2);
        }
        else if (!is_table_present($9)) 
        {
            fprintf(stdout, "Table %s not present\n", $9);
        }
        else 
        {
            int x = attachTable($2, $9, &($6));
            
            //If the equijoin condition is fulfilled, we process the query
            if (x == 1) 
            {
                recordCount = showEquiJoin($2, $9, &($6));
            }
            printf("Total number of records : %d\n", recordCount);
        }
        printf("-----------------------------------------\n-----------------------------------------\n\n");
    }
    | %empty
    ;

// OR has lower precedence than AND
condition: temp_cond1 OR condition
    {
        $$ = combineOrList($3, $1); 
    } 
    | temp_cond1  
    {
        $$.tail = malloc(sizeof(AndList));
        $$.head = $$.tail;
        memcpy($$.head, &$1, sizeof (AndList));
    }
    ;

// AND has lower precedence than NOT
temp_cond1: temp_cond2 AND temp_cond1
            {
                $$ = combineAndList($3, $1); 
            }
            | temp_cond2
            {
                $$.tail = malloc(sizeof(AndEntry));
                $$.head = $$.tail;
                $$.nextPtr = 0;
                memcpy($$.head, &$1, sizeof (AndEntry));
            }
            ;
//checking for not of condition
temp_cond2 : NOT LP condition RP
            {   
                $$.findInteger1 = $$.findInteger2 = 0;
                $$.firstString = $$.secondString = 0;

                $$.tableEntry1 = $$.tableEntry2 = $$.columnEntry1 = $$.columnEntry2 = 0;
                $$.operation = 0;

                $$.nextPtr = 0;
                $$.isCondition = $$.isNegation = 1;
                $$.nestedCond = malloc(sizeof(OrList));
                memcpy($$.nestedCond, &$3, sizeof (OrList));
            }
            | expression
            ;

expression: column operator STRING
            {
            	//allocate table1 if not alreadt allocated
                if($1.table)
                { 
                    $$.tableEntry1 = malloc(100); 
                    memset($$.tableEntry1, 0, 100); 
                    sprintf($$.tableEntry1, "%s", $1.table);
                }
                else
                { 
                    $$.tableEntry1 = $1.table;                    
                }
                
                $$.tableEntry2 = 0;
                $$.columnEntry1 = malloc(100);  
                memset($$.columnEntry1, 0, 100);
                $$.columnEntry2 = 0;
                sprintf($$.columnEntry1, "%s", $1.colName);
                $$.operation = $2.operandType;
                
                $$.findInteger1 = $$.findInteger2 = 0;
                $$.firstString = 0;
                $$.secondString = malloc(100); 
                memset($$.secondString, 0, 100);
                sprintf($$.secondString, "%s", $3);
                
                $$.nextPtr = 0;
                $$.isNegation = $$.isCondition = 0;
                $$.nestedCond = 0;
            }
            | STRING operator column
            {
            	//allocate table3 if not alreadt allocated
                if($3.table)
                { 
                    $$.tableEntry1 = malloc(100); 
                    memset($$.tableEntry1, 0, 100); 
                    sprintf($$.tableEntry1, "%s", $3.table);
                }
                else 
                { 
                    $$.tableEntry1 = $3.table; 
                }
                
                $$.tableEntry2 = 0;
                $$.columnEntry1 = malloc(100);  
                memset($$.columnEntry1, 0, 100);
                $$.columnEntry2 = 0;
                sprintf($$.columnEntry1, "%s", $3.colName);
                $$.operation = makeComplement($2.operandType);

                $$.findInteger1 = $$.findInteger2 = 0;
                $$.firstString = 0;
                $$.secondString = malloc(100);
                memset($$.secondString, 0, 100);
                sprintf($$.secondString, "%s", $1);
                
                $$.nextPtr = 0;
                $$.isNegation = $$.isCondition = 0;
                $$.nestedCond = 0;
            }
            | column operator column
            {
            	//allocate table1 if not alreadt allocated
                if($1.table)
                { 
                    $$.tableEntry1 = malloc(100); 
                    memset($$.tableEntry1, 0, 100); 
                    sprintf($$.tableEntry1, "%s", $1.table);
                }
                else 
                {
                    $$.tableEntry1 = $1.table;
                }
            	//allocate table3 if not alreadt allocated
                if($3.table)
                { 
                    $$.tableEntry2 = malloc(100); 
                    memset($$.tableEntry2, 0, 100); 
                    sprintf($$.tableEntry2, "%s", $3.table);
                }
                else 
                { 
                    $$.tableEntry2 = $3.table; 
                }
                $$.columnEntry1 = malloc(100);  
                memset($$.columnEntry1, 0, 100);
                $$.columnEntry2 = malloc(100);  
                memset($$.columnEntry2, 0, 100); 
                sprintf($$.columnEntry1, "%s", $1.colName);
                sprintf($$.columnEntry2, "%s", $3.colName);
                $$.operation = $2.operandType;
                
                $$.findInteger1 = $$.findInteger2 = 0;
                $$.firstString = $$.secondString = 0;
                
                $$.nextPtr = 0;
                $$.isNegation = $$.isCondition = 0;
                $$.nestedCond = 0;    
            }
            | column operator INT
            {
            	//allocate table1 if not alreadt allocated
                if($1.table)
                { 
                    $$.tableEntry1 = malloc(100); 
                    memset($$.tableEntry1, 0, 100); 
                    sprintf($$.tableEntry1, "%s", $1.table);
                }
                else 
                { 
                    $$.tableEntry1 = $1.table; 
                }
                $$.tableEntry2 = 0;
                $$.columnEntry1 = malloc(100);  
                memset($$.columnEntry1, 0, 100);
                $$.columnEntry2 = 0;
                sprintf($$.columnEntry1, "%s", $1.colName);
                $$.operation = $2.operandType;

                $$.nextPtr = 0;
                $$.isNegation = $$.isCondition = 0;
                $$.nestedCond = 0;

                $$.findInteger1 = 0;
                $$.findInteger2 = 1;
                $$.secondVal = $3;
                $$.firstString = $$.secondString = 0;
            }
            | INT operator column
            {
            	//allocate table3 if not alreadt allocated
                if($3.table)
                {
                    $$.tableEntry1 = malloc(100); 
                    memset($$.tableEntry1, 0, 100); 
                    sprintf($$.tableEntry1, "%s", $3.table);
                }
                else 
                { 
                    $$.tableEntry1 = $3.table; 
                }
                $$.tableEntry2 = 0;
                $$.columnEntry1 = malloc(100);  
                memset($$.columnEntry1, 0, 100);
                $$.columnEntry2 = 0;
                sprintf($$.columnEntry1, "%s", $3.colName);
                $$.operation = makeComplement($2.operandType);

                $$.nextPtr = 0;
                $$.isNegation = $$.isCondition = 0;
                $$.nestedCond = 0;

                $$.findInteger1 = 0;
                $$.findInteger2 = 1;
                $$.secondVal = $1;
                $$.firstString = $$.secondString = 0;
            }
            | LP condition RP
            {
            	//nested condition case
                $$.findInteger1 = $$.findInteger2 = 0;
                $$.firstString = $$.secondString = 0;   
                $$.tableEntry1 = $$.tableEntry2 = $$.columnEntry1 = $$.columnEntry2 = 0;
                $$.operation = 0;

                $$.nextPtr = 0;
                $$.isNegation = 0;        
                $$.isCondition = 1;
                $$.nestedCond = malloc(sizeof(OrList));
                memcpy($$.nestedCond, &$2, sizeof (OrList));
            }
            ;

operator: LT 
		{
			$$.operandType = 1;
		}
        | GT 
        {
        	$$.operandType = 2;
        }
        | LTE 
        {
        	$$.operandType = 3;
        }
        | GTE 
        {
        	$$.operandType = 4;
        }
        | EQUAL 
        {
        	$$.operandType = 5;
        }
        | NE 
        {	
        	$$.operandType = 6;
        }
        ;

attribute_list: column COMMA attribute_list
                {
                    sprintf(curArrayList[currentValue], "%s", $1.colName);
                    currentValue++;
                }
                | column
                {
                    memset(curArrayList, 0, 10000);
                    currentValue = 0;
                    sprintf(curArrayList[0], "%s", $1.colName);
                    currentValue++;
                }
                ;

column: ID DOT ID 
        {
            $$.table = malloc(100);
            $$.colName = malloc(100);
            memset($$.colName, 0, 100);
            memset($$.table, 0, 100);
            sprintf($$.table, "%s", $1);
            sprintf($$.colName, "%s", $3);
        }
        | ID  
        {
            $$.table = 0;
            $$.colName = malloc(100);
            memset($$.colName, 0, 100);
            sprintf($$.colName, "%s", $1);       
        }
        ;

%%
int main(int argc, char **argv)
{
  yyparse();
}

void yyerror(char *s){}