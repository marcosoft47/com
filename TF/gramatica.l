%{
    #include <math.h>

    /* Controle de indentação (INIDEBL / FIMDEBL) */
    #define MAX_NIVEIS 100
    #define TAM_TAB 4

    int pilha_indent[MAX_NIVEIS] = {0};
    int topo = 0;

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

    void trata_indentacao(int largura) {
        if (largura > pilha_indent[topo]) {
            if (topo + 1 >= MAX_NIVEIS) {
                printf("Erro: excesso de níveis de indentação\n");
                return;
            }
            pilha_indent[++topo] = largura;
            printf("INIDEBL\n");
        } else {
            while (largura < pilha_indent[topo]) {
                topo--;
                printf("FIMDEBL\n");
            }
            if (largura != pilha_indent[topo])
                printf("Erro: indentação inconsistente\n");
        }
    }
%}
%option noyywrap

/* Estado de início de linha, onde a indentação é analisada */
%x INDENT

/* Terminais */
NOME  [a-zA-Z_][a-zA-Z0-9_]*
NUMERO  [0-9]

/*
	======== Comportamentos do analisador léxico ========
*/
%%

 /* ---------- Indentação (início de linha) ---------- */

<INDENT>[ \t\r]*\n  /* linha em branco: ignora */

<INDENT>[ \t]*[^ \t\r\n] {
    yyless(yyleng - 1);   /* devolve o primeiro caractere da linha */
    trata_indentacao(largura_indent(yytext, yyleng));
    BEGIN(INITIAL);
}

<INDENT><<EOF>> {
    while (topo > 0) {
        topo--;
        printf("FIMDEBL\n");
    }
    yyterminate();
}

 /* ---------- Palavras reservadas ---------- */

"if"      { printf("palavra reservada: %s\n", yytext); }
"else"    { printf("palavra reservada: %s\n", yytext); }
"while"   { printf("palavra reservada: %s\n", yytext); }
"for"     { printf("palavra reservada: %s\n", yytext); }
"in"      { printf("palavra reservada: %s\n", yytext); }
"def"     { printf("palavra reservada: %s\n", yytext); }
"return"  { printf("palavra reservada: %s\n", yytext); }
"import"  { printf("palavra reservada: %s\n", yytext); }

 /* ---------- Operadores relacionais ---------- */

"=="  { printf("operador relacional: %s\n", yytext); }
"!="  { printf("operador relacional: %s\n", yytext); }
"<="  { printf("operador relacional: %s\n", yytext); }
">="  { printf("operador relacional: %s\n", yytext); }
"<"   { printf("operador relacional: %s\n", yytext); }
">"   { printf("operador relacional: %s\n", yytext); }

 /* ---------- Atribuição e operadores aritméticos ---------- */

"="   { printf("atribuição: %s\n", yytext); }
"+"   { printf("operador aritmético: %s\n", yytext); }
"-"   { printf("operador aritmético: %s\n", yytext); }
"*"   { printf("operador aritmético: %s\n", yytext); }
"/"   { printf("operador aritmético: %s\n", yytext); }

 /* ---------- Delimitadores ---------- */

"("   { printf("abre parênteses: %s\n", yytext); }
")"   { printf("fecha parênteses: %s\n", yytext); }
":"   { printf("dois pontos: %s\n", yytext); }
","   { printf("vírgula: %s\n", yytext); }

 /* ---------- Identificadores e números ---------- */

{NOME} {
    printf("identificador: %s\n", yytext);
}

{NUMERO}+  {
    printf("número: %d\n", atoi(yytext));
}

\n  { BEGIN(INDENT); /* nova linha: analisa a indentação */ }

[ \t\r]+  /* ignora espaços em branco */

<<EOF>> {
    while (topo > 0) {
        topo--;
        printf("FIMDEBL\n");
    }
    yyterminate();
}

. {printf("Não reconhecido: %s\n", yytext);}

%%

int main(int argc, char** argv )
{
	++argv, --argc;
	if ( argc > 0 )
		yyin = fopen( argv[0], "r" );
	else
		yyin = stdin;

	BEGIN(INDENT);   /* a primeira linha também tem a indentação analisada */
	yylex();

	return 0;
}
