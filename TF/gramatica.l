%{
    #include <math.h>
%}
%option noyywrap

/* Terminais */
NOME  [aA-zZ][aA0-zZ9]*
NUMERO  [0-9]


%%

// <expressao> ::= <termo>
//               | <expressao> "+" <termo>
//               | <expressao> "-" <termo>

// <termo> ::= <fator>
//           | <termo> "*" <fator>
//           | <termo> "/" <fator>

// <fator> ::= <numero>
//           | <identificador>
//           | "(" <expressao> ")"

{NOME} {
    printf("identificador: %s\n", yytext);
}

{NUMERO}+  {
    printf("número: %d\n", atoi(yytext));
}

[ \t\n]+  /* ignora espaços em branco */

. {printf("Não reconhecido: %s\n", yytext);}

%%

int main(int argc, char** argv )
{
	++argv, --argc;
	if ( argc > 0 )
		yyin = fopen( argv[0], "r" );
	else
		yyin = stdin;

	yylex();
    
	return 0;
}
