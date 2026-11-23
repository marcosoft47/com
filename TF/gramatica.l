%{
	// bison -d gramatica.y && flex gramatica.l && gcc gramatica.tab.c lex.yy.c -o analisador -lm

    #include <stdio.h>
    #include <stdlib.h>
    #include "gramatica.tab.h"

    void yyerror(const char *msg);

    /* Controle de indentação (INIDEBL / FIMDEBL) */
    #define MAX_NIVEIS 100
    #define TAM_TAB 4

    int pilha_indent[MAX_NIVEIS] = {0};
    int topo = 0;

    /* Quantidade de FIMDEBL ainda a serem entregues ao analisador sintático
       (um recuo pode fechar vários blocos de uma vez, mas o yylex só
       retorna um token por chamada) */
    int fimdebl_pendentes = 0;

    /* Calcula a largura da indentação, contando TAB como TAM_TAB espaços */
    int largura_indent(const char *s, int n) {
        int largura = 0;
        for (int i = 0; i < n; i++) {
            if (s[i] == '\t')
                largura += TAM_TAB - (largura % TAM_TAB);
            else
                largura++;
        }
        return largura;
    }

    /* Retorna INIDEBL, FIMDEBL ou 0 (mesmo nível de indentação) */
    int trata_indentacao(int largura) {
        if (largura > pilha_indent[topo]) {
            if (topo + 1 >= MAX_NIVEIS) {
                yyerror("excesso de níveis de indentação");
                exit(1);
            }
            pilha_indent[++topo] = largura;
            return INIDEBL;
        }

        while (largura < pilha_indent[topo]) {
            topo--;
            fimdebl_pendentes++;
        }
        if (largura != pilha_indent[topo]) {
            yyerror("indentação inconsistente");
            exit(1);
        }
        if (fimdebl_pendentes > 0) {
            fimdebl_pendentes--;
            return FIMDEBL;
        }
        return 0;
    }
%}
%option noyywrap
%option yylineno
%option nounput noinput

/* Estado de início de linha, onde a indentação é analisada */
%x INDENT

/* Terminais */
NOME  [a-zA-Z_][a-zA-Z0-9_]*
NUMERO  [0-9]

/*
	======== Comportamentos do analisador léxico ========
*/
%%

 /* Executado a cada chamada do yylex: na primeira chamada ativa o estado
    INDENT (para analisar a indentação da primeira linha) e, nas demais,
    entrega os FIMDEBL pendentes */
    static int primeira_chamada = 1;
    if (primeira_chamada) {
        primeira_chamada = 0;
        BEGIN(INDENT);
    }
    if (fimdebl_pendentes > 0) {
        fimdebl_pendentes--;
        return FIMDEBL;
    }

 /* ---------- Indentação (início de linha) ---------- */

<INDENT>[ \t\r]*\n  /* linha em branco: ignora */

<INDENT>[ \t]*[^ \t\r\n] {
    yyless(yyleng - 1);   /* devolve o primeiro caractere da linha */
    BEGIN(INITIAL);
    int token = trata_indentacao(largura_indent(yytext, yyleng));
    if (token)
        return token;
}

 /* Fim de arquivo: fecha todos os blocos ainda abertos, um por chamada */
<INDENT,INITIAL><<EOF>> {
    if (topo > 0) {
        topo--;
        return FIMDEBL;
    }
    yyterminate();
}

 /* ---------- Palavras reservadas ---------- */

"if"      { return IF; }
"else"    { return ELSE; }
"while"   { return WHILE; }
"for"     { return FOR; }
"in"      { return IN; }
"def"     { return DEF; }
"return"  { return RETURN; }
"import"  { return IMPORT; }

 /* ---------- Operadores relacionais ---------- */

"=="  { return IGUAL; }
"!="  { return DIFERENTE; }
"<="  { return MENOR_IGUAL; }
">="  { return MAIOR_IGUAL; }
"<"   { return MENOR; }
">"   { return MAIOR; }

 /* ---------- Atribuição, operadores aritméticos e delimitadores ---------- */

"="|"+"|"-"|"*"|"/"|"("|")"|":"|","  { return yytext[0]; }

 /* ---------- Identificadores e números ---------- */

{NOME}       { return NOME; }

{NUMERO}+    { return NUMERO; }

\n  { BEGIN(INDENT); /* nova linha: analisa a indentação */ }

[ \t\r]+  /* ignora espaços em branco */

. {
    fprintf(stderr, "Erro léxico na linha %d: caractere não reconhecido '%s'\n", yylineno, yytext);
    exit(1);
}

%%

 /* O main está em gramatica.y */
