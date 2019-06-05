%{
    #include "y.tab.h"
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
	
	int tabs = 0;
    int arrTabs = 0;
	void printTabs(int number);
    void printArrTabs(int number);
    void printArrayStart(char* arrayStart);
    void printArrayEnd(char* arrayEnd);
    void printString(char* string);
    void printNumber(char* number);
    void printObjectStart(char* objectStart);
    void printObjectEnd(char* objectEnd);

%}


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

UnescapedChar           [ -!#-\[\]-~_:+<>=]

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

null                    "null"

ws                      [ \t\n]

%%

{json_start}		{ printObjectStart(yytext);return TK_OBJECT_START; }

{created_at}        { printf("%s",yytext);return TK_CREATED; }

{text}              { printString(yytext);return TK_TEXT; }

{user}              {printf("%s",yytext);return TK_USER;}

{string}			{ printString(yytext);yylval.stringval = strdup(yytext);return TK_STRING; }

{colon}				{ printf("%s", yytext);return TK_COLON; }

{comma}				{ printf("%s\n", yytext);printTabs(tabs); return TK_COMMA; }

{json_end}			{ printObjectEnd(yytext);return TK_OBJECT_END; }

{array_start}		{ printArrayStart(yytext); return TK_ARRAY_START; }

{number}			{ printNumber(yytext);return TK_NUMBER; }

{array_end}			{ printArrayEnd(yytext); return TK_ARRAY_END; }

{boolean_value}		{ printf("%s", yytext); return TK_BOOLEAN; }

{ws}                { /* ignore whitespaces */ }

{Char}              {return TK_CHAR;}

%%

void printTabs(int number){
    for( int i = 0; i < number; i++ ){
      printf("\t");
    }
}

void printArrTabs(int number){
    for( int i = 0; i < number; i++ ){
      printf("\t");
    }
}

void printArrayStart( char* arrayStart) {
    tabs++;
    printf("%s\n", arrayStart);
    printTabs(tabs);
}

void printArrayEnd( char* arrayEnd) {
    printf("\n");
    tabs--;
    printTabs(tabs);
    printf("%s", arrayEnd);
}

void printString( char* string) {
    printf("%s", string);
}

void printNumber( char* number) {
    printf("%s", number);
}

void printObjectStart( char* objectStart) {
    tabs++;
    printf("%s\n", objectStart);
    printTabs(tabs);
}

void printObjectEnd( char* objectEnd) {
    printf("\n");
    tabs--;
    printTabs(tabs);
    printf("%s", objectEnd);
}

int yywrap() {
    return 1;
}