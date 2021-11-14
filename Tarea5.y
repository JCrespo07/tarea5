%{
#include<stdlib.h>
#include<stdio.h>
extern int yylex();
int yyerror(char const * s);
extern FILE *yyin;
extern int linea;

%}

/* Los elementos terminales de la gramática. La declaración de abajo se
   convierte en definición de constantes en el archivo Tarea4.tab.h
   que hay que incluir en el archivo de flex. */

%token NUMI NUMF SUMA RESTA MULTI DIVIDE PARENI PAREND FINEXP
%token COMA PUNTOYCOMA DOSPUNTOS IGUAL MAYOR MENOR PROGRAM ID BEG 
%token END INT FLOAT SET IF ENDIF ELSE DO WHILE READ PRINT
%start prog

%%

prog : PROGRAM ID opt_decls BEG opt_stmts END
;

opt_decls : decl_lst | 
;

decl_lst : decl PUNTOYCOMA decl_lst | decl
;

decl : id_lst DOSPUNTOS type
;

id_lst : ID COMA id_lst | ID
;

type : INT | FLOAT
;

stmt : SET ID expr
| IF PARENI expresion PAREND stmt ENDIF
| IF PARENI expresion PAREND stmt ELSE stmt ENDIF
| DO stmt WHILE PARENI expresion PAREND
| READ ID
| PRINT expr
| BEG opt_stmts END
;

opt_stmts : stmt_lst |
;

stmt_lst : stmt | stmt_lst PUNTOYCOMA stmt_lst
;

expr : expr SUMA term
| expr RESTA term
| term
;

term : term MULTI factor
| term DIVIDE factor
| factor
;

factor : PARENI expr PAREND
| ID
| NUMI 
| NUMF
;

expresion : expr MENOR expr
| expr MAYOR expr
| expr IGUAL expr
;

%%

int yyerror(char const * s) {
  fprintf(stderr, "%s, %d\n", s, linea);
}

int main(int argc, char * argv[]) {

  int lectura;

  if (argc < 2) {
    printf ("Error, falta el nombre de un archivo\n");
    exit(1);
  }

  yyin = fopen(argv[1], "r");

  if (yyin == NULL) {
    printf("Error: el archivo no existe\n");
    exit(1);
  }

  yyparse();

  /* yylex es la función que flex provee */

  /* while ((0 = yylex()) != FINEXP) {
      printf("La ficha encontrada es %d y corresponde a %s\n", lectura, yytext);
      if (lectura == NUM) printf("El valor numerico es %d\n", yylval);
  } */

}

