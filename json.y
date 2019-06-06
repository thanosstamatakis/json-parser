%{

#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include <errno.h>

// Define decimal base
#define BASE         (10)

// Declarations 
int errorCount = 0;
int user_field_count = 0;
int irr_field_count = 0;
long id_counter = 0;
long ids[20];


// Flex/Yacc functions
int yylex();
void yyerror(char *);

// Custom functions
void checkTextField(char *);
void countUserField(char *);
void validateUserField(int);
char* checkTimeStamp(char*); 
char* checkUserId(char*, char*); 

// External Files
extern FILE *yyin;
extern FILE *yyout;

%}

%union {
    char* numval;
    char* stringval;
}

%start Json
%token TK_ILLEGAL_SEQ
%left TK_OBJECT_START
%left TK_OBJECT_END
%token <stringval> TK_STRING
%token <numval>TK_NUMBER             
%left TK_ARRAY_START        
%left TK_ARRAY_END                  
%token TK_NULL               
%left TK_COLON               
%token TK_BOOLEAN
%left TK_COMMA
%token TK_TEXT
%token TK_CHAR
%token TK_USER
%token TK_CREATED

%%

Json:
    Object
|   Object TK_COMMA Object;

Object: 
    TK_OBJECT_START TK_OBJECT_END
|   TK_OBJECT_START KeyValuePairs TK_OBJECT_END 
|   TK_OBJECT_START KeyValuePair TK_OBJECT_END;

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
|   TK_CREATED TK_COLON TK_STRING {printf("%s",checkTimeStamp($3));}
|   TK_STRING TK_COLON TK_STRING
|   TK_USER TK_COLON TK_OBJECT_START UserValues TK_OBJECT_END {validateUserField(user_field_count);}
|   TK_STRING TK_COLON Array;


UserValues:
    UserValue TK_COMMA UserValue
|   UserValues TK_COMMA UserValue
|   UserValues TK_COMMA;


UserValue:
    TK_STRING TK_COLON TK_STRING {countUserField($1);}
|   TK_STRING TK_COLON TK_NUMBER {countUserField($1);printf("%s",checkUserId($1,$3));};


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

// Checks the textfield for max character length of 140
void checkTextField(char * text){
    if(strlen(text)>142){
        printf("\nTextfield too large.\n");
        exit(1);
    }
}

// Check for unique user ids
char* checkUserId (char* field, char* id_as_string){
    int unique = 1;
    char* errCheck;
    long id = strtol(id_as_string, &errCheck, BASE);

    // Itterate through the array of ids and check
    // if the new id that was read is unique 
    for (int i = 0; i <=id_counter ; i++){
        if (ids[i] == id){
            unique = 0;
        }
    }
    
    if (!unique){
        return "\n\nUser ID is not Unique.\n\n";
    }
    
    ids[id_counter++] = id;  
    return "\n\n\nUser ID is Unique.\n\n";
}


// Check if the timestamp is correct
char* checkTimeStamp(char * str){
    char * parsed_chars;
    char * string[10];
    const char *DAYS_DICT[] = {"Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"};
    const char *MONTH_DICT[] = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};
    int valid[7];
    char * error_msg; 
    
    // Get the first token
    parsed_chars = strtok (str," \",.:");
    string[0] = parsed_chars;
    valid[0] = 0;
    int i = 1;

    // Get the rest of the tokens and insert them 
    // into the string array
    while (parsed_chars != NULL && i<=7){
        parsed_chars = strtok (NULL, " \",.:");
        valid[i] = 0;
        string[i++] = parsed_chars;
    }
        
    // Check if days are valid
    for (i=0; i<7; i++){
        if (strstr(DAYS_DICT[i], string[0]) != NULL){
            valid[0] = 1;
        }else{
            error_msg = "Wrong days in datetime.";
        }
    }

    // Check if months are valid
    for (i=0; i<12; i++){
        if (strstr(MONTH_DICT[i], string[1]) != NULL){
            valid[1] = 1;
        }else{
            error_msg = "Wrong months in datetime.";
        }
    }

    // Check for date
    if (atoi(string[2])<0 || atoi(string[2])>31){
        error_msg = "Wrong date in datetime.";        
    }else{
        valid[2] = 1;
    }

    // Check for hours
    if (atoi(string[3])<0 || atoi(string[2])>24){
        error_msg = "Wrong hours in datetime.";        
    }else{
        valid[3] = 1;
    }

    // Check for minutes
    if (atoi(string[4])<0 || atoi(string[4])>59){
        error_msg = "Wrong minutes in datetime.";        
    }else{
        valid[4] = 1;
    }

    // Check for seconds
    if (atoi(string[5])<0 || atoi(string[5])>59){
        error_msg = "Wrong seconds in datetime.";                
    }else{
        valid[5] = 1;
    }

    // Check timezone
    if(string[6][0]=='+'){
        parsed_chars = strtok (string[6],"+");
        if (atoi(parsed_chars)>1400||atoi(parsed_chars)<0){
            error_msg = "Wrong timezone in datetime.";        
        }else{
            valid[6] = 1;
        }
    }else if (string[6][0]=='-'){
        parsed_chars = strtok (string[6],"-");
        if (atoi(parsed_chars)>1200||atoi(parsed_chars)<0){
            printf("Invalid timezone\n\n");
        }else{
            valid[6] = 1;
        }
    }

    // Check year 
    if (atoi(string[7])<1900 || atoi(string[7])>2019){
        error_msg = "Wrong year in datetime.";        
    }else{
        valid[7] = 1;
    }

    for (i = 0; i < 8; i++){
        if(valid[i]==0){
            return error_msg;
        }
    }
    
    return "OK";
}

// Counts how many relevant or irrelevant fields the user key has 
void countUserField(char* key){
    if (!strcmp(key, "\"id\"")){
        user_field_count++;
    }else if (!strcmp(key, "\"name\"")){
        user_field_count++;
    }else if (!strcmp(key, "\"description\"")){
        user_field_count++;
    }else if (!strcmp(key, "\"screen_name\"")){
        user_field_count++;
    }else if (!strcmp(key, "\"location\"")){
        user_field_count++;
    }else if (!strcmp(key, "\"url\"")){
        user_field_count++;
    }else{irr_field_count++;}
}

// Validates if the user key is complete with all the necessary fields
void validateUserField(int count){
    if(count != 6 || (count == 6 && irr_field_count > 0)){
        printf("\n\n\nUser does not contain all the correct fields, or contains too many fields.\n");
        exit(1);    
    }else{
        user_field_count = 0;
        irr_field_count = 0;
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