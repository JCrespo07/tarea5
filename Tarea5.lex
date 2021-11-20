/* Archivo con el reconocedor léxico para la calculadora */
%{
#include<stdlib.h>
#include<math.h>
  /* Se incluye el archivo generado por bison para tener las definiciones
     de los tokens */
#include "tarea5.tab.h"
float yylvalfloat;
int linea = 1;

%}

LETRA [A-Za-z]
DIGITO [0-9]
FLOTANTE ([0-9])+"."([0-9])*
ID    [a-zA-Z][a-zA-Z0-9]*

%%

{DIGITO}*         {yylval = atoi(yytext); return NUMI;}       /* Convierte el NUM a numero */
{FLOTANTE}*       {yylvalfloat = atof(yytext); return NUMF;}  /* Convierte el NUM a decimal */
"+"               {return SUMA;}            /* Se encontro un simbolo de suma */
"-"               {return RESTA;}           /* Se encontro un simbolo de resta */
"*"               {return MULTI;}           /* Se encontro un simbolo de multiplicacion */
"/"               {return DIVIDE;}          /* Se encontro un simbolo de division */
"("               {return PARENI;}          /* Se encontro un "(" */
")"               {return PAREND;}          /* Se encontro un ")" */
"$"               {return FINEXP;}          /* Se encontro un $, que es simbolo de fin de expr */
","               {return COMA;}            /* Se encontro un ",", que es simbolo de coma */
";"               {return PUNTOYCOMA;}      /* Se encontro un ";", que es simbolo de punto y coma*/
":"               {return DOSPUNTOS;}       /* Se encontro un ":", que es simbolo de dos puntos */
"="               {return IGUAL;}           /* Se encontro un "=", que es simbolo de  igual*/
">"               {return MAYOR;}           /* Se encontro un ">", que es simbolo de  mayor que*/
"<"               {return MENOR;}           /* Se encontro un "<", que es simbolo de menor que */
"program"         {return PROGRAM;}         /* Se encontro un "program"*/
"id"              {return ID;}              /* Se encontro un "id"*/
"begin"           {return BEG;}             /* Se encontro un "begin"*/
"end"             {return END;}             /* Se encontro un "end"*/
"int"             {return INT;}             /* Se encontro un "int"*/
"float"           {return FLOAT;}           /* Se encontro un "float"*/
"set"             {return SET;}             /* Se encontro un "set"*/
"if"              {return IF;}              /* Se encontro un "if"*/
"endif"           {return ENDIF;}           /* Se encontro un "endif"*/
"else"            {return ELSE;}            /* Se encontro un "else"*/
"do"              {return DO;}              /* Se encontro un "do"*/
"while"           {return WHILE;}           /* Se encontro un "while"*/
"read"            {return READ;}            /* Se encontro un "read"*/
"print"           {return PRINT;}           /* Se encontro un "print"*/
{ID}              {return ID;}              /* Se encontro un identificador*/
"\n"              {linea++;}                /* Se agrega 1 al numero de linea*/

%%