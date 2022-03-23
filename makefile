LEX := flex
YACC := bison
CC := g++
OBJECT := main
 
$(OBJECT) : lex.yy.o main.tab.o main.h
	$(CC) lex.yy.o main.tab.o -o $(OBJECT)
	@./$(OBJECT) 1.c 1_result.txt 1_code.S
 
lex.yy.o : lex.yy.c  main.tab.h  main.h
	$(CC) -c lex.yy.c
 
yacc.tab.o : main.tab.c  main.h
	$(CC) -c main.tab.c
 
main.tab.c main.tab.h : main.y main.h
	$(YACC) -d main.y
 
lex.yy.c : main.l main.h
	$(LEX) main.l
 
clean:
	@rm -f $(OBJECT) *.o ：