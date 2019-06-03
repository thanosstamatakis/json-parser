%{
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
int errorCount = 0; 
int yylex();
void yyerror(char *);
long getTextLength(char *);
void checkTextField(char *);
extern FILE *yyin;
extern FILE *yyout;						
%}

%union {
    int intval;
    char* stringval;
}

%start Object
%token TK_ILLEGAL_SEQ
%left TK_OBJECT_START
%left TK_OBJECT_END
%token <stringval> TK_STRING
%token TK_NUMBER             
%left TK_ARRAY_START        
%left TK_ARRAY_END                  
%token TK_NULL               
%left TK_COLON               
%token TK_BOOLEAN
%left TK_COMMA
%token TK_TEXT
%token TK_CHAR

%%

Object: 
    TK_OBJECT_START TK_OBJECT_END
|   TK_OBJECT_START KeyValuePairs TK_OBJECT_END {printf("Full Object.\n");}
|   TK_OBJECT_START KeyValuePair TK_OBJECT_END {printf("Single Attribute Object.\n");};

KeyValuePairs: 
    KeyValuePair TK_COMMA KeyValuePair
|   KeyValuePairs TK_COMMA KeyValuePair
|   KeyValuePairs TK_COMMA;


KeyValuePair:
    TK_STRING TK_COLON TK_BOOLEAN {printf("%s",$1);}
|   TK_STRING TK_COLON TK_NULL
|   TK_STRING TK_COLON TK_NUMBER
|   TK_STRING TK_COLON Object
|   TK_TEXT TK_COLON TK_STRING {checkTextField($3);}
|   TK_STRING TK_COLON TK_STRING
|   TK_STRING TK_COLON Array;

Array: 
    TK_ARRAY_START TK_ARRAY_END
|   TK_ARRAY_START Datatypes TK_ARRAY_END
|   TK_ARRAY_START Datatypes TK_COMMA TK_ARRAY_END
|   TK_ARRAY_START CommaSeperatedValues TK_ARRAY_END;

CommaSeperatedValues:
    Datatypes TK_COMMA Datatypes
|   CommaSeperatedValues TK_COMMA Datatypes
|   CommaSeperatedValues TK_COMMA;

Datatypes:
    TK_STRING
|   TK_NULL
|   TK_NUMBER
|   TK_BOOLEAN
|   Object
|   Array;



%%								    
    

void yyerror (char *s){
    errorCount++;
    fprintf(stderr,"%s on some line \n",s);
}

long getTextLength (char *s){
    printf("%ld",strlen(s));
    return strlen(s);
}

void checkTextField(char * text){
    if(strlen(text)>142){
        printf("\nTextfield too large.\n");
        exit(1);
    }
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