# Analisador Léxico (Flex) e Sintático (Bison)
	Alunos:
	- Guilherme Gamaliel Lima;
	- Marco Antonio Reche Rigon 

Compile com `bison -d gramatica.y && flex gramatica.l && gcc gramatica.tab.c lex.yy.c -o analisador -lm` e teste com `./analisador teste` (programa válido) ou `./analisador teste-erro` (programa com erro sintático)
