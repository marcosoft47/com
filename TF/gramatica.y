%{
    // bison -d gramatica.y && flex gramatica.l && gcc gramatica.tab.c lex.yy.c -o analisador -lm

    #include <stdio.h>
    #include <stdlib.h>

    extern int yylex(void);
    extern int yylineno;
    extern FILE *yyin;

    void yyerror(const char *msg);
%}

/* Mensagens de erro mais detalhadas (tokens esperados) */
%define parse.error verbose

/*
    Conflitos esperados (um para cada token NOME, NUMERO e "("): após "return",
    se o próximo token puder iniciar uma expressão, o Bison não sabe se é
    "return <expressao>" ou "return" seguido de um novo comando. A gramática
    não tem separador de comandos, então isso é uma ambiguidade real. É
    resolvido por shift, ou seja, a expressão é associada ao return.
*/
%expect 3

/* ---------- Terminais ---------- */

%token NOME NUMERO
%token IF ELSE WHILE FOR IN DEF RETURN IMPORT
%token IGUAL DIFERENTE MENOR_IGUAL MAIOR_IGUAL MENOR MAIOR
%token INIDEBL FIMDEBL

%start programa

%%

programa
    : lista_comandos
    ;

lista_comandos
    : comando
    | comando lista_comandos
    ;

comando
    : atribuicao
    | expressao
    | if
    | while
    | for
    | funcao
    | return
    | import
    ;

atribuicao
    : identificador '=' expressao
    ;

expressao
    : termo
    | expressao '+' termo
    | expressao '-' termo
    ;

termo
    : fator
    | termo '*' fator
    | termo '/' fator
    ;

fator
    : numero
    | identificador
    | '(' expressao ')'
    ;

if
    : IF condicao ':' bloco
    | IF condicao ':' bloco ELSE ':' bloco
    ;

while
    : WHILE condicao ':' bloco
    ;

for
    : FOR identificador IN expressao ':' bloco
    ;

funcao
    : DEF identificador '(' parametros ')' ':' bloco
    ;

parametros
    : %empty
    | identificador
    | identificador ',' parametros
    ;

return
    : RETURN
    | RETURN expressao
    ;

/* <import> não é definido na gramática base; assume-se "import NOME" */
import
    : IMPORT identificador
    ;

condicao
    : expressao op_relacional expressao
    ;

op_relacional
    : IGUAL
    | DIFERENTE
    | MENOR
    | MAIOR
    | MENOR_IGUAL
    | MAIOR_IGUAL
    ;

bloco
    : INIDEBL lista_comandos FIMDEBL
    ;

identificador
    : NOME
    ;

numero
    : NUMERO
    ;

%%

void yyerror(const char *msg) {
    fprintf(stderr, "Erro sintático na linha %d: %s\n", yylineno, msg);
}

int main(int argc, char **argv) {
    ++argv, --argc;
    if (argc > 0) {
        yyin = fopen(argv[0], "r");
        if (!yyin) {
            perror(argv[0]);
            return 1;
        }
    } else {
        yyin = stdin;
    }

    if (yyparse() == 0) {
        printf("Programa sintaticamente correto.\n");
        return 0;
    }
    return 1;
}
