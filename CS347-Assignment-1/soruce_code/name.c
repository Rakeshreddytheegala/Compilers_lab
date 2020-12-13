// #include "name.h"

char  *Names[] = { "t0", "t1", "t2", "t3", "t4", "t5", "t6", "t7" };
char  Register_Names[] = { 'A', 'B', 'C', 'D', 'E', 'F', 'H', 'L' };
char  **Namep  = Names;

//Assign the topmost register for use
char  *newname(void)
{
    if( Namep >= &Names[ sizeof(Names)/sizeof(*Names) ] )
    {
        fprintf( stderr, "%d: Expression too complex\n", yylineno );
        exit( 1 );
    }

    return( *Namep++ );
}

//Pop off the top most register
void freename(char *s)
{
    if( Namep > Names )
    *--Namep = s;
    else
    fprintf(stderr, "%d: (Internal error) Name stack underflow\n",
                                yylineno );
}

//Check if string corresponds to a token
char getRegister(char * s)
{
    for(int i=0;i<8;i++)
    {
        if(strcmp(Names[i],s)==0)
            return Register_Names[i];
    }
    return '\0';
}

//Add '_' infont of variables for intermediate file generation
void uscore(char * s, char * ans)
{
	int flag=0;

    if(getRegister(s)=='\0' )
	{
        char *tp = s;

        while (*tp != '\0'){
            if (!isdigit(*tp)){
                flag = 1;
                break;
            }
            tp++;
        }
	}
	int index=0;
	if(flag==1)
	{
		ans[index++]='_';
	}
	while(*s!='\0')
	{
		ans[index++]=*s;
        s++;
	}
	ans[index]='\0';
    // printf("%s\n", ans);
	return;
}
