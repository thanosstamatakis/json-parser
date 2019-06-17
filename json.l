%{
    #include "y.tab.h"
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
	
	int tabs = 0;
    int arrTabs = 0;
    int after_comma = 0;
	void printTabs(int number);
    void printArrTabs(int number);
    void printArrayStart( void );
    void printArrayEnd( void );
    void printString(char* string);
    void printNumber(char* number);
    void printObjectStart(void);
    void printObjectEnd(void);
    void printComma(char* comma);

%}

%option yylineno

letter                  [a-zA-Z]

Digit1to9               [1-9]

Digit                   [0-9]

Digits                  {Digit}+

Integer                 {Digit}|{+-}?{Digit1to9}{Digits}* 

Fraction                [.]{Digits}

E                       ("+"|"-")?({Digits}|{Digits}\.{Digits})?("e"|"E")("+"|"-")?({Digits}|{Digits}\.{Digits})?

Exp                     {E}{Digits}

Hex_Digit               [0-9a-f]

Real_Num                {Integer}|{Integer}{Fraction}|{Integer}{Exp}|{Integer}{Fraction}{Exp}

UnescapedChar           [ -!#-\[\]-~_:+<>=…]

EscapedChar             \\["\\bfnrt/]

UnicodeChar             \\u{Hex_Digit}{Hex_Digit}{Hex_Digit}{Hex_Digit}

Char                    {UnescapedChar}|{EscapedChar}|{UnicodeChar}|{letter}

Chars                   {Char}+

Double_Quote            ["]

text                    {Double_Quote}"text"{Double_Quote}

created_at              {Double_Quote}"created_at"{Double_Quote}

number                  {E}|{Digit}|{Digits}|-{Digits}|({Digits}\.{Digits})|-({Digits}\.{Digits})

json_start              [\{]

json_end                [\}]

array_start             [\[]

array_end               [\]]

boolean_value           ("True"|"False"|"true"|"false")

comma                   ","

colon                   [:]

string                  {Double_Quote}({Char}*){Double_Quote}

user                    {Double_Quote}user{Double_Quote}

tweet                   {Double_Quote}tweet{Double_Quote}

retweet                 {Double_Quote}retweeted_status{Double_Quote}

truncated               {Double_Quote}truncated{Double_Quote}

display_t_r             {Double_Quote}display_text_range{Double_Quote}

extended_tweet          {Double_Quote}extended_tweet{Double_Quote}

entities                {Double_Quote}entities{Double_Quote}

id_str                  {Double_Quote}id_str{Double_Quote}

full_text               {Double_Quote}full_text{Double_Quote}

indices                 {Double_Quote}indices{Double_Quote}

hashtags                {Double_Quote}hashtags{Double_Quote}

null                    "null"

ws                      [ \t\n]

%%

{json_start}		{ printObjectStart();return TK_OBJECT_START; }

{created_at}        { printf("%s",yytext);return TK_CREATED; }

{display_t_r}       { printf("%s",yytext);return TK_DISPLAY_T_R; }

{entities}          { printf("%s",yytext);return TK_ENTITIES; }

{indices}           { printf("%s",yytext);return TK_INDICES; }

{id_str}            { printf("%s",yytext);return TK_ID_STR; }

{hashtags}          { printf("%s",yytext);return TK_HASHTAGS; }

{full_text}         { printf("%s",yytext);return TK_FULL_TEXT; }

{extended_tweet}    { printf("%s",yytext);return TK_EXT_TWEET; }

{text}              { printf("%s",yytext);return TK_TEXT; }

{user}              { printf("%s",yytext);return TK_USER;}

{truncated}         { printf("%s",yytext);return TK_TRUNCATED;}

{tweet}             { printf("%s",yytext);return TK_TWEET;}

{retweet}           { printf("%s",yytext);return TK_RETWEET;}

{string}			{ printf("%s",yytext);yylval.stringval = strdup(yytext);return TK_STRING; }

{colon}				{ printf("%s", yytext);return TK_COLON; }

{comma}				{ printf("%s\n",yytext);printTabs(tabs);return TK_COMMA; }

{json_end}			{ printObjectEnd();return TK_OBJECT_END; }

{array_start}		{ printArrayStart();return TK_ARRAY_START; }

{number}			{ printf("%s",yytext);yylval.numval = strdup(yytext);return TK_NUMBER; }

{array_end}			{ printArrayEnd(); return TK_ARRAY_END; }

{boolean_value}		{ printf("%s", yytext);yylval.booleanval = strdup(yytext);return TK_BOOLEAN; }

{ws}                { /* ignore whitespaces */ }

{Char}              {return TK_CHAR;}

%%

void printTabs(int number){
    for( int i = 0; i < number; i++ ){
      printf("\t");
    }
    after_comma =0;
}

void printArrTabs(int number){
    for( int i = 0; i < number; i++ ){
      printf("\t");
    }
}

void printArrayStart( void ) {
    tabs++;
    printf("[\n");
    printTabs(tabs);
}

void printArrayEnd( void ) {
    printf("\n");
    tabs--;
    printTabs(tabs);
    printf("]");
}

void printString( char* string) {
    printf("%s", string);
}

void printNumber( char* number) {
    printf("%s", number);
}

void printObjectStart(void) {
    tabs++;
    printf("{\n");
    printTabs(tabs);
}

void printObjectEnd(void) {
    printf("\n");
    tabs--;
    printTabs(tabs);
    printf("}");
}

void printComma( char* comma) {
    printf("%s\n", comma);
    printTabs(tabs);
}

int yywrap() {
    return 1;
}