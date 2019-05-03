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

%option noyywrap

letter              [a-zA-Z]
digit               [0-9]
digits              {digit}*
number              {digit}|{digits}|-{digits}|({digits}\.{digits})|-({digits}\.{digits})
dbl_quote           ["]
string              {dbl_quote}({letter}({letter}|{digits}|{other_chars})*)*{dbl_quote}
object_start        [{]
object_end          [}]
array_start         [\[]
array_end           [\]]
boolean_value       ("True"|"False"|"true"|"false")
null                [null]
comma               ","
colon               [:]
other_chars         [.\-_]
seperator           (" "*{comma}" "*)
ws                  [ \t\n]

%%
{comma}             { printf("%s", yytext);return TK_COMMA; }
{array_start}       { printArrayStart(yytext); return TK_ARRAY_START;}
{array_end}         { printArrayEnd(yytext); return TK_ARRAY_END; }
{string}            { printString(yytext);return TK_STRING; }
{number}            { printNumber(yytext);return TK_NUMBER; }
{object_start}      { printObjectStart(yytext);return TK_OBJECT_START; }
{object_end}        { printObjectEnd(yytext);return TK_OBJECT_END; }
{colon}             { printf("%s", yytext);return TK_COLON; }
{boolean_value}     { printf("%s", yytext);return TK_BOOLEAN; }
{null}              { printf("%s", yytext);return TK_NULL; }
{seperator}         { return TK_SEPERATOR; }
{ws}                { /* ignore whitespaces */ }
.                   { printf("%s", yytext);return TK_ILLEGAL_SEQ; }

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
    printf("%s", objectEnd);
}