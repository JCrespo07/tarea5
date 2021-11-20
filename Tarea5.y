%{
#include<stdlib.h>
#include<stdio.h>

// Definimos una estructura para hacer el árbol sintáctico reducido.
typedef struct asr ASR;
struct asr{
   unsigned char[] tipoNodo;  // reglas gramaticales y variables
   unsigned char[] tipoOperacion; //
   int valor; // Si es un número es el valor del número. Si no, es el operador.
   ASR * uno; 
   ASR * dos;
   ASR * tres;
};

extern int yylex();
int yyerror(char const * s);
extern int linea;
ASR * nuevoNodo(unsigned char[], unsigned char[], int, ASR *, ASR *, ASR *);
int recorre(ASR *);

%}

%union{
   int valor;  // Para las constantes numéricas
   struct asr * arbol;  // Para los apuntadores a árbol sintáctico  
}

/* Los elementos terminales de la gramática. La declaración de abajo se
   convierte en definición de constantes en el archivo tarea5.tab.h
   que hay que incluir en el archivo de flex. */

%token NUMF SUMA RESTA MULTI DIVIDE PARENI PAREND FINEXP COMA PUNTOYCOMA DOSPUNTOS IGUAL MAYOR MENOR PROGRAM ID BEG END INT FLOAT SET IF ENDIF ELSE DO WHILE READ PRINT
%token <valor> NUMI
%type <arbol> stmt opt_stmts stmt_lst expr term factor expresion        //???
%start prog

%%

prog : PROGRAM ID opt_decls BEG opt_stmts END {printf("Accepted\n"); exit(0);}
;

opt_decls : decl_lst | 
;

decl_lst : decl PUNTOYCOMA decl_lst | decl    
;

decl : id_lst DOSPUNTOS type // Insercion en tabla de simbolos
;

id_lst : ID COMA id_lst | ID  // Insercion en tabla de simbolos, lista ligada ??? es lo 1ro
;

type : INT | FLOAT
;
set x x+y
stmt : SET ID expr      {$$ = nuevoNodo("instruccion", SET, NULL, *nodoTablaSimbolos , $3 , NULL);}
| IF PARENI expresion PAREND stmt ENDIF       {$$ = nuevoNodo("instruccion", IF, NULL, *dentrodelparen , *ifTrue , NULL);}    
| IF PARENI expresion PAREND stmt ELSE stmt ENDIF     {$$ = nuevoNodo("instruccion", IF, NULL, *dentrodelparen , *ifTrue , *else);}
| DO stmt WHILE PARENI expresion PAREND {$$ = nuevoNodo("instruccion", DO, NULL, *dentrodelparen , *while , NULL);}
| READ ID       {$$ = nuevoNodo("instruccion", READ, NULL, *tablasimbolosnodo, NULL);}
| PRINT expr      {$$ = nuevoNodo("instruccion", PRINT, NULL, *expr, NULL);}
| BEG opt_stmts END       {$$ = nuevoNodo("instruccion", BEG, NULL, *opt_stmts, NULL);}
;

opt_stmts : stmt_lst |
;

stmt_lst : stmt | stmt_lst PUNTOYCOMA stmt_lst
;

expr : expr SUMA term    {$$ = nuevoNodo("operador",SUMA, NULL,$1, $3, NULL);}
     | expr RESTA term   {$$ = nuevoNodo("operador",RESTA, NULL, $1, $3, NULL);}
     | term
;

term : term MULTI factor   {$$ = nuevoNodo("operador",MULTI, NULL, $1,$3, NULL);}
     | term DIVIDE factor  {$$ = nuevoNodo("operador",DIVIDE, NULL, $1,$3,NULL);}
     | factor
;

factor : PARENI expr PAREND  {$$=$2;}
        | ID //generar nodo para id $$ = nuevo nodo
        | NUMI 
        | NUMF
;

expresion : expr MENOR expr {$$ = nuevoNodo("operador",MENOR, NULL, $1, $3);}
| expr MAYOR expr  {$$ = nuevoNodo("operador",MAYOR, NULL, $1, $3);}
| expr IGUAL expr  {$$ = nuevoNodo("operador",IGUAL, NULL, $1, $3);}
;

%%

int yyerror(char const * s) {
  fprintf(stderr, "%s, %d\n", s, linea);
}

void main(int argc, char * argv[]) {
  extern FILE * yyin;
  if(argc<2){
    printf("faltan argumentos\n");exit(1);
  }
  yyin = fopen(argv[1],"r");
  yyparse();
}

//                     ?? COMO LIGAR NODOS???

/* La función nuevoNodo crea un nuevo nodo para un árbol sintáctico reducido.
   Los parámetros son el tipo de nodo (operación u operando), el valor que
   representa qué operando se está usando o el valor del número en cuestión y
   los apuntadores a los subárboles correspondientes.
*/

ASR * nuevoNodo(unsigned char[] tipoNodo, unsigned char[] tipoOperacion, int valor, ASR * uno, ASR * dos, ASR * tres) {

   ASR * aux = (ASR *) malloc(sizeof(ASR));
   aux -> tipoNodo = tipoNodo;
   aux -> tipoOperacion = tipoOperacion;
   aux -> valor = valor;
   aux -> uno = uno;
   aux -> dos = dos;
   aux -> tres = tres;
   return aux;
}

/* La función recorre es el intérprtete en este caso. Simplemente recorre
   el árbol en postorden para obtener los valores correspondientes.
*/

int recorre(ASR * raiz) {
   int aux1, aux2;

   if (raiz == NULL) return 0;

   if (raiz -> tipo == "operador") { // Se trata de un operador, hay que recorrer sus subárboles 
      aux1 = recorre(raiz -> uno);
      aux2 = recorre(raiz -> dos);
      // Ya tenemos los valores correspondientes, ahora hay que operar y devolver el
      // valor de la operación.
      if (raiz -> valor == SUMA) return aux1 + aux2;
      if (raiz -> valor == RESTA) return aux1 - aux2;
      if (raiz -> valor == MULTI) return aux1 * aux2;
      if (raiz -> valor == DIVIDE) return aux1 / aux2;
      if (raiz -> valor == MENOR) return aux1 < aux2;
      if (raiz -> valor == MAYOR) return aux1 > aux2;
      if (raiz -> valor == IGUAL) return aux1 = aux2;
   }
   else // El valor de tipo debe ser 0 y por tanto es un operando
      return raiz -> valor;
}










