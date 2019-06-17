%{

#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include <errno.h>
#include <ctype.h>

// Define decimal base
#define BASE         (10)

extern int yylineno;

// Declarations 
int errorCount = 0;
int user_field_count = 0;
int irr_field_count = 0;
long id_counter = 0;
long ids[20];
int active_tweet = 0;
int active_retweet = 0;
int detected_extended_tweet = 0;
int truncated = 0;
char* original_text;
int truncated_d_t_r = 0 ;
int hashtag_index =0;
int hashtag_count=0;
int errorline[20];
int error_count = 0;
char* error[20];
char* tweet_text;
char* retweet_text;
char* original_author;
char* textfield_text;
char* end_index;
char* start_index;
char* hashtag_text;
char* full_text;

// Flex/Yacc functions
int yylex();
void yyerror(char *);

// Custom functions
void checkTextField(char *);
void countUserField(char*, char *);
void validateUserField(int);
void checkTimeStamp(char*); 
void checkUserId(char*, char*);
void getTweetText(char*);
// void getReTweetText(char*);
// void validateRetweetText();
// void checkTweetRetweet();
void checkTruncatedValue(char*);
void checkDisplayTextRange(char*, char*);
void checkExtendedDisplayTextRange(char*, char*);
void checkHashtag(void);
void checkTruncated();
void checkHashtagNumber();
void checkIdString(char*);
void checkScreenName(char*);
void checkOriginalText(char*);

// External Files
extern FILE *yyin;
extern FILE *yyout;

%}

%union {
    char* numval;
    char* stringval;
    char* booleanval;
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
%token <booleanval>TK_BOOLEAN
%left TK_COMMA
%token TK_TEXT
%token TK_CHAR
%token TK_USER
%token TK_CREATED
%token TK_TWEET
%token TK_RETWEET
%token TK_TRUNCATED
%token TK_DISPLAY_T_R
%token TK_EXT_TWEET;
%token TK_FULL_TEXT;
%token TK_ENTITIES;
%token TK_INDICES;
%token TK_HASHTAGS;
%token TK_ID_STR;

%%

Json: 
    TK_OBJECT_START TK_OBJECT_END
|   TK_OBJECT_START KeyValuePairs TK_OBJECT_END;



KeyValuePairs: 
    KeyValuePair
|   KeyValuePair TK_COMMA KeyValuePairs;



KeyValuePair:
    TK_STRING TK_COLON Value
|   TK_TEXT TK_COLON TK_STRING {checkTextField($3);original_text=$3;}
|   TK_CREATED TK_COLON TK_STRING {checkTimeStamp($3);}
|   TK_ID_STR TK_COLON TK_STRING {checkIdString($3);}
|   TK_USER TK_COLON TK_OBJECT_START UserKVPairs TK_OBJECT_END {validateUserField(user_field_count);}
|   TK_ENTITIES TK_COLON Value
|   TK_RETWEET TK_COLON TK_OBJECT_START RetweetKVPairs TK_OBJECT_END
|   TK_TRUNCATED TK_COLON TK_BOOLEAN {checkTruncatedValue($3);}
|   TK_DISPLAY_T_R TK_COLON TK_ARRAY_START TK_NUMBER TK_COMMA TK_NUMBER TK_ARRAY_END {truncated_d_t_r++;checkDisplayTextRange($4,$6);}
|   TK_EXT_TWEET TK_COLON TK_OBJECT_START ExtendedKVPairs TK_OBJECT_END
|   TK_FULL_TEXT TK_COLON Value
|   TK_INDICES TK_COLON Value
|   TK_TWEET TK_COLON TK_OBJECT_START TweetKVPairs TK_OBJECT_END
|   TK_HASHTAGS TK_COLON Value;



ExtendedKVPairs:
    ExtendedKVPair
|   ExtendedKVPair TK_COMMA ExtendedKVPairs;



ExtendedKVPair:
    TK_FULL_TEXT TK_COLON TK_STRING {full_text = strdup($3);}
|   TK_DISPLAY_T_R TK_COLON TK_ARRAY_START TK_NUMBER TK_COMMA TK_NUMBER TK_ARRAY_END {checkExtendedDisplayTextRange($4, $6);}
|   TK_ENTITIES TK_COLON TK_OBJECT_START EntitiesKVPairs TK_OBJECT_END;



EntitiesKVPairs:
    EntitiesKVPair
|   EntitiesKVPair TK_COMMA EntitiesKVPairs;



EntitiesKVPair:
    TK_HASHTAGS TK_COLON TK_ARRAY_START HashtagKVPairs TK_ARRAY_END;



HashtagKVPairs:
    HashtagKVPair
|   HashtagKVPair TK_COMMA HashtagKVPairs;



HashtagKVPair:
    TK_OBJECT_START HashObjectKVPairs TK_OBJECT_END ;



HashObjectKVPairs:
    HashObjectKVPair
|   HashObjectKVPair TK_COMMA HashObjectKVPairs;



HashObjectKVPair:
    TK_TEXT TK_COLON TK_STRING {hashtag_text = strdup($3);checkHashtag();}
|   TK_INDICES TK_COLON TK_ARRAY_START TK_NUMBER  TK_COMMA TK_NUMBER TK_ARRAY_END {start_index = $4; end_index = $6; checkHashtagNumber();};



TweetKVPairs:
    TweetKVPair
|   TweetKVPair TK_COMMA TweetKVPairs;



TweetKVPair:
    TK_TEXT TK_COLON TK_STRING {getTweetText($3);}
|   TK_USER TK_COLON TK_OBJECT_START RetweetUser TK_OBJECT_END;



RetweetKVPairs:
    RetweetKVPair
|   RetweetKVPair TK_COMMA RetweetKVPairs;



RetweetKVPair:
    TK_TEXT TK_COLON TK_STRING {checkOriginalText($3);}
|   TK_USER TK_COLON TK_OBJECT_START RetweetUser TK_OBJECT_END;



RetweetUser:
    TK_STRING TK_COLON TK_STRING {checkScreenName($1);};



UserKVPairs:
    UserKVPair
|   UserKVPair TK_COMMA UserKVPairs;



UserKVPair:
    TK_STRING TK_COLON TK_STRING {countUserField($1,$3);}
|   TK_STRING TK_COLON TK_NUMBER {countUserField($1,$3);checkUserId($1,$3);};



Array:
    TK_ARRAY_START TK_ARRAY_END
|   TK_ARRAY_START Elements TK_ARRAY_END;



Elements:
    Value
|   Value TK_COMMA Elements;



Value:
    TK_STRING
|   TK_NUMBER
|   TK_BOOLEAN
|   TK_NULL
|   Array
|   Json;

%%								    
    
void yyerror (char *s){
    errorCount++;
    fprintf(stderr,"%s on line %d\n",s , yylineno);
}



// Checks if there is a correspondig truncated-extended_tweet field.
void checkTruncated() {
    if (truncated == 1 && truncated_d_t_r==0){
        error[error_count] = "Truncated found but no display_text_range.\n";
        errorline[error_count++] = yylineno;
    }
}



// Counts how many relevant or irrelevant fields the user key has 
void countUserField(char* key, char* value){
    if (!strcmp(key, "\"id\"")){
        user_field_count++;
    }else if (!strcmp(key, "\"name\"")){
        user_field_count++;
    }else if (!strcmp(key, "\"screen_name\"")){
        original_author = value;
        // Strip original_author quotes
        original_author++;
        original_author[strlen(original_author)-1] = 0;
        user_field_count++;
    }else if (!strcmp(key, "\"location\"")){
        user_field_count++;
    }else{irr_field_count++;}
}



// Check for unique user ids
void checkUserId (char* field, char* id_as_string){
    int unique = 1;
    char* errCheck;
    long id = strtol(id_as_string, &errCheck, BASE);
    if (field[1]='i'&& field[2]=='d'){
    // Itterate through the array of ids and check
    // if the new id that was read is unique 
    for (int i = 0; i <=id_counter ; i++){
        if (ids[i] == id){
            unique = 0;
        }
    }
    
    if (!unique){
        // printf("\n\nUser ID is not Unique.\n\n");
        // exit(1);
        error[error_count] = "User ID is not Unique.\n";
        errorline[error_count++] = yylineno;
    }
    
    ids[id_counter++] = id;  
    // return "\n\n\nUser ID is Unique.\n";
    }
}



// Checks if hashtag matches indices
void checkHashtag(void){
    char* full = strdup(full_text);
    char* text = strdup(hashtag_text);
    char* token;

    full++;
    full[strlen(full)-1]=0;

    text++;
    text[strlen(text)-1]=0;

    token = strtok(full, "#");
    hashtag_count++;
    for (int i=0; i<hashtag_count; i++){
       token = strtok(NULL,"#");
    }

    token = strtok(token, " ");


    if (strcmp(text,token)){
        error[error_count] = "Hashtag not corresponding to full_text.\n";
        errorline[error_count++] = yylineno;
    }

}



// Checks truncated
void checkTruncatedValue(char* value){
    int result_true = !strcmp(value, "true");
    int result_false = !strcmp(value, "false");

    
    if (result_true){
        truncated = 1;
    }

}



// Validates if the user key is complete with all the necessary fields
void validateUserField(int count){
    if(count != 4){
        // printf("\n\n\nUser does not contain all the correct fields, or contains too many fields.\n");
        // exit(1);    
        error[error_count] = "User does not contain all the correct fields, or contains too many fields.\n";
        errorline[error_count++] = yylineno;
    }else{
        user_field_count = 0;
        irr_field_count = 0;
    }
}



// Check if the timestamp is correct
void checkTimeStamp(char * str){
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
            error_msg = "Wrong days in datetime.\n";
        }
    }

    // Check if months are valid
    for (i=0; i<12; i++){
        if (strstr(MONTH_DICT[i], string[1]) != NULL){
            valid[1] = 1;
        }else{
            error_msg = "Wrong months in datetime.\n";
        }
    }

    // Check for date
    if (atoi(string[2])<0 || atoi(string[2])>31){
        error_msg = "Wrong date in datetime.\n";        
    }else{
        valid[2] = 1;
    }

    // Check for hours
    if (atoi(string[3])<0 || atoi(string[2])>24){
        error_msg = "Wrong hours in datetime.\n";        
    }else{
        valid[3] = 1;
    }

    // Check for minutes
    if (atoi(string[4])<0 || atoi(string[4])>59){
        error_msg = "Wrong minutes in datetime.\n";        
    }else{
        valid[4] = 1;
    }

    // Check for seconds
    if (atoi(string[5])<0 || atoi(string[5])>59){
        error_msg = "Wrong seconds in datetime.\n";                
    }else{
        valid[5] = 1;
    }

    // Check timezone
    if(string[6][0]=='+'){
        parsed_chars = strtok (string[6],"+");
        if (atoi(parsed_chars)>1400||atoi(parsed_chars)<0){
            error_msg = "Wrong timezone in datetime.\n";        
        }else{
            valid[6] = 1;
        }
    }else if (string[6][0]=='-'){
        parsed_chars = strtok (string[6],"-");
        if (atoi(parsed_chars)>1200||atoi(parsed_chars)<0){
            error_msg = "Invalid timezone\n";
        }else{
            valid[6] = 1;
        }
    }

    // Check year 
    if (atoi(string[7])<1900 || atoi(string[7])>2019){
        error_msg = "Wrong year in datetime.\n";        
    }else{
        valid[7] = 1;
    }

    for (i = 0; i < 8; i++){
        if(valid[i]==0){
            // return error_msg;
            // printf("Error: %s", error_msg);
            // exit(1);
            error[error_count] = error_msg;
            errorline[error_count++] = yylineno;
        }
    }
    
    // return "OK";
}



void checkTextField(char * text){

    char * parsed_chars;
    char * string[10];
    char * error_msg; 
    
    if(strlen(text)>142){
        // printf("\nTextfield too large.\n");
        // exit(1);
        error[error_count] = "Textfield too large.\n";
        errorline[error_count++] = yylineno;
    }else{
        textfield_text = text;
    }
}



// Checks display_text_range attribute
void checkDisplayTextRange(char* start, char* finish){
    int arr_start = atoi(start);
    int arr_end = atoi(finish);

    if (arr_start<0 || arr_end>140){
        error[error_count] = "Outter display_text_range out of allowed range.\n";
        errorline[error_count++] = yylineno;
    }
}



// Checks display_text_range attribute
void checkExtendedDisplayTextRange(char* start, char* finish){
    int arr_start = atoi(start);
    int arr_end = atoi(finish);
    int length = strlen(full_text)-3;

    printf("%d", length);
    if (arr_start<0 || arr_end != length){
        error[error_count] = "Inner display_text_range out of allowed range.\n";
        errorline[error_count++] = yylineno;
    }
}



// Check Retweet text
void checkOriginalText(char* text){
    if(strcmp(text, original_text)){
        error[error_count] = "Retweet text field not the same as the original text.\n";
        errorline[error_count++] = yylineno;
    }
}



// Get & store the text from tweet textfield
void getTweetText(char* text){
    // Remove double quotes from text field value.
    text++;
    text[strlen(text)-1]=0;

    char* rt = strtok(text, " ");
    if (strcmp(rt, "RT")){
        error[error_count] = "No RT in tweet text field.\n";
        errorline[error_count++] = yylineno;
    }

    char* at_author = strtok(NULL, " ");
    if (at_author[0]!='@'){
        error[error_count] = "No @ in tweet text field.\n";
        errorline[error_count++] = yylineno;
    }

    char* author = ++at_author;
    if (strcmp(author, original_author)){
        error[error_count] = "Original author does not match tweet field @<original_author>.\n";
        errorline[error_count++] = yylineno;
    }
    
}



void checkHashtagNumber() {
    int start = atoi(start_index);
    int end = atoi(end_index);
    int diff = end - start;

    char* formated_hashtag = (char*)malloc((diff)*sizeof(char));

    char* text = strdup(hashtag_text);
    char* full = strdup(full_text);

    full++;
    full[strlen(full)-1]=0;
    
    text++;
    text[strlen(text)-1]=0;

    if (start>end){
        error[error_count] = "Start index larger than end index.\n";
        errorline[error_count++] = yylineno;
        return;
    }

    for(int i = 1; i <= diff; i++){
        formated_hashtag[i-1] = full[start+i];
    }
    
    if(strcmp(formated_hashtag,text)){
        error[error_count] = "Indices do not match hashtag in full text.\n";
        errorline[error_count++] = yylineno;
    }
}



// Check if the key is "screen_name"
void checkScreenName(char* key){
    if (strcmp(key,"\"screen_name\"")){
        error[error_count] = "No screen_name found.\n";
        errorline[error_count++] = yylineno;
    }
}



// Check id_str field
void checkIdString(char* id_str) {
    // Strip quotes from char*
    id_str++;
    id_str[strlen(id_str)-1] = 0;
    int digits = 0;

    for (int i=0; i<strlen(id_str); i++){
        if(isdigit(id_str[i]))
            digits++;
    }
    if (digits!=(strlen(id_str))){
        error[error_count] = "id_str field does not contain only numbers.\n";
        errorline[error_count++] = yylineno;
    }
}



int main(int argc, const char **argv)
{

    if (argc > 1) {
        yyin = fopen(argv[1], "r");
    } else {
        printf("\x1B[31mCan not open file. Exiting....\n\n");
        exit(1);
    }

    yyparse();
    fclose(yyin);
    checkTruncated();
    if (error_count>0){
        for (int i=0; i<error_count; i++){
            printf("\n\x1B[31mError at line %d: ",errorline[i]);
            printf("%s%s","\x1B[37m" ,error[i]);
        }
        printf("\n\n\n\n");

        exit(1);
    }

    printf("\n\nNo syntax errors.\n\n\n\n\n");

    return 0;
}	