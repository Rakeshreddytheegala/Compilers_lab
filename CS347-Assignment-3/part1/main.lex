%{
	#include<stdio.h>
	#include<stdlib.h>
	#include<stdbool.h>
	#include<string.h>

	//Function declarations
	void remove_comments();
	void line_increment(void);
    void put_class_in_array(char*);
    int exists_class(char*);
    void verify_obj(char*);

    //Variable declarations
    char class_to_add[200];
    char class_list[10000][200];
    int class_count=0;
    int op_overload_total=0;
    int class_total = 0;
    int object_total=0;
    int inherited_class_total = 0;
    int constructor_total=0;
    int operator_in_line = 0;
    int class_in_line = 0;
    int object_in_line=0;
    int inherited_class_in_line = 0;
    int constructor_in_line = 0;
%}

/*alias for patterns*/
word   [A-Za-z_0-9]
str   [A-Za-z_]
cls_type   public|private|protected
oper \+|-|\*|\/|\+=|-=|\*=|\/=|%=|\^=|&=|\|=|<<|>>|>>=|<<=|==|!=|<=|>=|<=>|&&|\|\||\+\+|--|\,|->\*|\\->|\(\s*\)|\[\s*\]|%|\^|&|\||~|!|=|<|>


%option noyywrap
/*Start conditions --> States for DFA */
%x CLS_A CLS_B CLS_C CLS_D CNST_A CNST_B DST_A DST_B
%%


[^A-Za-z_]operator" "*{oper}" "*([^\{\;\n]*)[\n\{]     { operator_in_line = 1; if(yytext[yyleng-1]=='\n'){line_increment();}}


[^0-9a-zA-Z_]class[\t ]+  		{ if(yytext[0] == '\n'){line_increment();} BEGIN(CLS_A); }
<CLS_A>{str}{word}*             { memset(class_to_add, 0, sizeof(class_to_add)) ; snprintf(class_to_add, 200, "%s", yytext); BEGIN(CLS_B) ; }
<CLS_B>[ \t]                 	{ BEGIN(CLS_B) ; }
<CLS_B>\n                    	{ class_in_line = 1; line_increment(); if(exists_class(class_to_add)==0){put_class_in_array(class_to_add);} BEGIN(INITIAL);}
<CLS_B>"{"                   	{ class_in_line = 1; if(exists_class(class_to_add)==0){put_class_in_array(class_to_add);} /*printf("%s-was here\n", class_to_add);*/ BEGIN(INITIAL); }
<CLS_B>":"                   	{ BEGIN(CLS_C); }
<CLS_B>[^\n{:]               	{ put_class_in_array(class_to_add); BEGIN(INITIAL);}
<CLS_C>[ \t]                 	{ BEGIN(CLS_C); }
<CLS_C>{cls_type}            	{ BEGIN(CLS_C); }
<CLS_C>{str}{word}*             { BEGIN(CLS_D); }
<CLS_D>[ \t]                 	{ BEGIN(CLS_D); }
<CLS_D>","                   	{ BEGIN(CLS_C); }
<CLS_D>\n                    	{ inherited_class_in_line = 1, class_in_line = 1; line_increment(); if(exists_class(class_to_add)==0){put_class_in_array(class_to_add);} BEGIN(INITIAL);}
<CLS_D>"{"                   	{ class_in_line = 1, inherited_class_in_line = 1; if(exists_class(class_to_add)==0){put_class_in_array(class_to_add);} BEGIN(INITIAL); }
<CLS_D>[^,\n{ ]              	{ put_class_in_array(class_to_add); BEGIN(INITIAL);}


[~][ \t]*{str}{word}*[\t ]*[(]	{BEGIN(DST_A) ; }
<DST_A>[^)]                  	{ BEGIN(DST_A);}
<DST_A>[)]                   	{ BEGIN(DST_B);}
<DST_B>[ \t]                 	{ BEGIN(DST_B);}
<DST_B>[{:]                  	{ BEGIN(INITIAL);}
<DST_B>\n                    	{ line_increment(); BEGIN(INITIAL);}
<DST_B>[^\n{:]               	{ BEGIN(INITIAL);}

{str}{word}*[\t ]*[(]          	{ memset(class_to_add, 0, sizeof(class_to_add)) ; sscanf(yytext, "%[A-Za-z0-9_]s", class_to_add); BEGIN(CNST_A) ; }
<CNST_A>[^)]                  	{ BEGIN(CNST_A);}
<CNST_A>[)]                   	{ BEGIN(CNST_B);}
<CNST_B>[ \t]                 	{ BEGIN(CNST_B);}
<CNST_B>[{:]                  	{ if (exists_class(class_to_add)){ constructor_in_line = 1; }  BEGIN(INITIAL);}
<CNST_B>\n                    	{ if (exists_class(class_to_add)) {constructor_in_line = 1; }line_increment(); BEGIN(INITIAL);}
<CNST_B>[^\n{:]               	{ BEGIN(INITIAL);}

.                         		;
\n                        		{ line_increment();}

{str}{word}*[*]*[ ]+[*]*[A-Za-z0-9_,][A-Za-z0-9_,\.\[\] ()]*[^\n;<>]*;  {/*printf("%s\n", yytext);*/ verify_obj(yytext);}



%%
//CHECKING FOR EXISTING CLASS
int exists_class(char *class_name){
    int cls=0;
    while (cls < class_count){
        if(strcmp(class_list[cls], class_name) == 0)					//May not work, check earlier
    		return 1;
    	cls++;
    }
    return 0;
}

//FUNCTION TO ADD NEW CLASS TO CLASS ARRAY
void put_class_in_array(char* class_to_add){
    class_count++;
    snprintf(class_list[class_count-1],  200, "%s", class_to_add);
}

//VERIFY IF STRING IS AN OBJECT
void verify_obj(char *class_value){
    char class_title[200];
    memset(class_title, 0, sizeof(class_title));
    sscanf(class_value, "%s", class_title);
    int len = strlen(class_title);								//Remove * from class
    while(class_title[len-1] == '*') {
        class_title[len-1] = '\0';
        len--;
    }
    // if(strstr(class_value, "operator") && strstr(class_value, "{")){
    //     operator_in_line=1;
    //     return;
    // }
    if(exists_class(class_title)){
        object_in_line = 1;
    }
}

//INCREMENTING ALL COUNTERS AND RESETING VARIABLES
void line_increment(){
    op_overload_total += operator_in_line;
    class_total += class_in_line;
    object_total += object_in_line;
    inherited_class_total += inherited_class_in_line;
    constructor_total += constructor_in_line;

    /*
			if (object_in_line == 1)
        printf("Object counted\n");
		*/
    operator_in_line = 0;
    class_in_line = 0;
    object_in_line = 0;
    inherited_class_in_line = 0;
    constructor_in_line = 0;
}

//FUNCTION TO REMOVE COMMENTS AND STRINGS FROM INPUT FILE
void remove_comments()
{
	FILE * fil = fopen("input.txt","r");
	if (fil == NULL)
	{
		printf("File doesn't exist in the current directory\n");
		exit(0);
	}
	FILE * temp = fopen("temp.txt","w");

	bool is_string=false;				//To indicate current text is part of string
	bool single_line_comment=false;		//To indicate current text is part of single line comment
	bool multi_line_comment=false;		//To indicate current text is part of multi line comment

	size_t val = 2000;
	char * line=malloc(2000);			//To read the text
	memset(line,0,sizeof(line));
	char ch=' ';
	while(getline(&line,&val,fil)!=-1)
	{
		int len=strlen(line);
		if(line[len-1]=='\n')
			len--;
		single_line_comment=false;
		is_string=false;
		for(int i=0;i<len;i++)
		{
			if(is_string == true && line[i-1]!= '\\' && line[i] == '\"')		//To check if the current string is about to close
			{
				is_string = false;
				line[i-1]= ch;
				line[i]= ch;
			}
			else if (is_string == true)		//If we are processing a string, we replace them by whitespace
			{
				line[i-1]=ch;
			}
			else if (multi_line_comment == true && line[i]=='*' && i+1<len && line[i+1]=='/' )		//To check if the multiline comment is about to close
			{
				multi_line_comment= false;
				line[i]=ch;
				i++;
				line[i]=ch;
			}
			else if (single_line_comment == true || multi_line_comment == true)		//If the current text is a part of the text, replace the character by a whitespace
			{
				line[i]=ch;
			}
			else if (( i==0 || line[i-1]!= '\\') && line[i]=='\"')		//To check if a string is abpout to start
			{
				is_string= true;
			}
			else if (line[i]=='/' && i+1<len && line[i+1]=='*')		//To check if a multiline comment is about to begin
			{
				multi_line_comment = true;
				line[i]=ch;
				i++;
				line[i]=ch;
			}
			else if (line[i]=='/' && i+1<len && line[i+1]=='/')		//To check is a single line comment is about to begin
			{
				single_line_comment = true;
				line[i]=ch;
				i++;
				line[i]=ch;
			}
		}
		fprintf(temp,"%s",line);		//Write the processed text to temp.txt which will be free of comments
		memset(line,0,sizeof(line));
	}
	fclose(fil);
	fclose(temp);
	// return temp;
}

int main()
{
	// FILE * fin_ptr = remove_comments();
	remove_comments();
	FILE* fin_ptr = fopen("temp.txt", "r");
	yyin = fin_ptr;
	yylex();

	line_increment();
	FILE * opt = fopen ("output.txt", "w");
	fprintf(opt, "Count of Object Declarations:\t\t\t\t%d\n", object_total);
	fprintf(opt, "Count of Class Definitions:\t\t\t\t%d\n", class_total);
	fprintf(opt, "Count of Constructor Definitions:\t\t\t%d\n", constructor_total);
  fprintf(opt, "Count of Inherited Class Definitions:\t\t\t%d\n", inherited_class_total);
  fprintf(opt, "Count of Operator Overloaded Function Definitions:\t%d\n", op_overload_total);
	fclose(opt);
}
