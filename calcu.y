/* Este archivo contiene un reconocedor de expresiones aritm�ticas junto
   con algunas reglas sem�nticas que calculan los valores de las
   expresiones que se reconocen. Las expresiones son muy sencillas y
   consisten �nicamente de sumas, restas, multiplicaciones y divisiones de
   n�meros enteros.

   Para compilar y ejecutar:
   flex calculadora.lex
   bison calculadora.y
   gcc lex.yy.c calculadora.tab.c -lfl
   ./a.out

   Autor: Alberto Oliart Ros */

%{
#include<stdlib.h>
#include<stdio.h>

// Definimos una estructura para hacer el �rbol sint�ctico reducido.
typedef struct asr ASR;
struct asr{
   unsigned char tipo;  // Indica si es una operaci�n o un n�mero: 1 = operaci�n, 0 = operando.
   int valor; // Si es un n�mero es el valor del n�mero. Si no, es la operaci�n.
   ASR * izq; // La subexpresi�n a la izquierda
   ASR * der; // La subexpresi�n a la derecha
};

extern int yylex();
int yyerror(char const * s);
ASR * nuevoNodo(unsigned char, int, ASR *, ASR *);
int recorre(ASR *);

%}

%union{
   int valor;  // Para las constantes num�ricas
   struct asr * arbol;  // Para los apuntadores a �rbol sint�ctico
}

/* Los elementos terminales de la gram�tica. La declaraci�n de abajo se
   convierte en definici�n de constantes en el archivo calculadora.tab.h
   que hay que incluir en el archivo de flex. */

%token SUMA RESTA DIVIDE MULTI PAREND PARENI FINEXP
%token<valor> NUM
%type <arbol> expr term factor
%start exp

%%

exp : expr FINEXP {printf("resultado = %d\n", recorre($1)); exit(0);}
;

expr : expr SUMA term    {$$ = nuevoNodo(1,SUMA,$1, $3);}
     | expr RESTA term   {$$ = nuevoNodo(1,RESTA, $1, $3);}
     | term
;

term : term MULTI factor   {$$ = nuevoNodo(1,MULTI,$1,$3);}
     | term DIVIDE factor  {$$ = nuevoNodo(1,DIVIDE,$1,$3);}
     | factor
;

factor : PARENI expr PAREND  {$$ = $2;}
       | NUM   {$$ = nuevoNodo(0,$1,NULL, NULL);}
;

%%

int yyerror(char const * s) {
  fprintf(stderr, "%s\n", s);
}

void main() {

  yyparse();
}

/* La funci�n nuevoNodo crea un nuevo nodo para un �rbol sint�ctico reducido.
   Los par�metros son el tipo de nodo (operaci�n u operando), el valor que
   representa qu� operando se est� usando o el valor del n�mero en cuesti�n y
   los apuntadores a los sub�rboles correspondientes.
*/

ASR * nuevoNodo(unsigned char tipo, int valor, ASR * izq, ASR * der) {

   ASR * aux = (ASR *) malloc(sizeof(ASR));
   aux -> tipo = tipo;
   aux -> valor = valor;
   aux -> izq = izq;
   aux -> der = der;
   return aux;
}

/* La funci�n recorre es el int�rprtete en este caso. Simplemente recorre
   el �rbol en postorden para obtner los valores correspondientes.
*/

int recorre(ASR * raiz) {
   int aux1, aux2;

   if (raiz == NULL) return 0;

   if (raiz -> tipo == 1) { // Se trata de un operando, hay que recorrer sus sub�rboles
      aux1 = recorre(raiz -> izq);
      aux2 = recorre(raiz -> der);
      // Ya tenemos los valores correspondientes, ahora hay que operar y devolver el
      // valor de la operaci�n.
      if (raiz -> valor == SUMA) return aux1 + aux2;
      if (raiz -> valor == RESTA) return aux1 - aux2;
      if (raiz -> valor == MULTI) return aux1 * aux2;
      if (raiz -> valor == DIVIDE) return aux1 / aux2;
   }
   else // El valor de tipo debe ser 0 y por tanto es un operando
      return raiz -> valor;
}
