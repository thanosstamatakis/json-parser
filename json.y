%{
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
int errorCount = 0; 
int yylex();
void yyerror(char *);
extern FILE *yyin;
extern FILE *yyout;						
%}

%start Object
%token TK_ILLEGAL_SEQ
%token TK_OBJECT_START
%token TK_OBJECT_END
%token TK_STRING
%token TK_NUMBER             
%token TK_ARRAY_START        
%token TK_ARRAY_END                  
%token TK_NULL               
%token TK_COLON               
%token TK_BOOLEAN
%token TK_COMMA


%%
    Datatypes: TK_NULL
    | TK_NUMBER
    | TK_STRING
    | TK_BOOLEAN;

    HalfSeries: TK_COMMA Datatypes;

    Series: Datatypes TK_COMMA Datatypes
    | Series HalfSeries;

    Array: TK_ARRAY_START TK_ARRAY_END
    | TK_ARRAY_START Series TK_ARRAY_END;

    Attribute: TK_STRING TK_COLON TK_STRING
    | TK_STRING TK_COLON TK_NUMBER
    | TK_STRING TK_COLON Array
    | TK_STRING TK_COLON Object;
  
    Object: TK_OBJECT_START Array TK_OBJECT_END
    | TK_OBJECT_START Attribute TK_OBJECT_END;

%%								    
    

void yyerror (char *s)
{
    errorCount++;
    fprintf(stderr,"%s on some line \n",s);
}
int main(int argc, const char **argv)
{
    // FILE *fptr = fopen("output.json", "w"); 
    // if (fptr == NULL) 
    // { 
    //     printf("Could not open file"); 
    //     return 0; 
    // } 

    if (argc > 1) {
        yyin = fopen(argv[1], "r");
    } else {
        yyin = stdin;
    }
    // while (yylex() != 0) {
    //     printf("%d", yylex());
    // }

    if (yyparse()) {   
        printf("\nFound %d syntax errors\n",errorCount);
    }
    else {
        printf("\nNo syntax errors\n");
    }

    // fclose(fptr);
    return 0;
}	