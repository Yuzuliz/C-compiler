%{
  #include "main.h"
  #include "main.tab.h"
  extern "C"{
    int yywrap(void);
    int yylex(void);
  }
  // \/\*                 ([^\*^\/]*    |    [\*^\/*]*   |    [^\**\/]*)*              \*\/

%}

BLOCKCOMMENT     \/\*([^\*^\/]*|[\*^\/*]*|[^\**\/]*)*\*\/
LINECOMMENT         \/\/[^\n]*
CONSTSTR                  \"(\\.|[^"\\])*\"
SIGN                              [-]?
NUMBER                      {SIGN}[0-9]+
SCANF                          scanf
PRINTF                         printf
RETURN                       return
WHILE                           while
IF                                     if
ELSE                               else
SWITCH                         switch
FOR                                 for
BREAK                            break
CONTINUE                    continue
DO                                    do
INT                                   int
CHAR                               char
FLOAT                             float
DOUBLE                         double
VOID                                void
CONST                            const
TRUE                               true
FALSE                              false
LPAREN                          \(
RPAREN                          \)
LBRACE                           \{
RBRACE                          \}
SEMICOLON                  [;]
EQ                                     ==
NE                                     !=
LE                                      \<\=
GE                                     \>\=
PLUSA                              \+\=
MINUSA                           \-\=
MULTA                              \*\=
DIVA                                   \/\=
MODA                                \%\=
AND                                  &&
OR                                     \|\|
NOT                                   [!]
ADDR                                [&]
LT                                       \<
GT                                      \>
ASSIGN                            [=]
PLUS                                [+]
MINUS                             [-]
MULT                                [*]
DIV                                    [/]
MOD                                 [%]
INCRE                              \+\+
DECRE                             \-\-
SPACE                             [ \n\t]+
ID                                      [A-Za-z_][A-Za-z0-9_]*
OTHER                           .

%%

{BLOCKCOMMENT}    {/*Do nothing*/}
{LINECOMMENT}         {/*Do nothing*/}
{SPACE}                           {/*Do nothing*/}
{NUMBER}                      {Node *node = new Node(string(yytext), 1);yylval = node;return Num;}
{SCANF}                          {Node *node = new Node(string(yytext), 4);yylval = node;return Scanf;}
{PRINTF}                         {Node *node = new Node(string(yytext), 4);yylval = node;return Printf;}
{RETURN}                       {Node *node = new Node(string(yytext), 4);yylval = node;return Return;}
{WHILE}                           {Node *node = new Node(string(yytext), 4);yylval = node;return While;}
{IF}                                     {Node *node = new Node(string(yytext), 4);yylval = node;return If;}
{ELSE}                              {Node *node = new Node(string(yytext), 4);yylval = node;return Else;}
{SWITCH}                        {Node *node = new Node(string(yytext), 4);yylval = node;return Switch;}
{FOR}                                {Node *node = new Node(string(yytext), 4);yylval = node;return For;}
{BREAK}                          {Node *node = new Node(string(yytext), 4);yylval = node;return Break;}
{CONTINUE}                  {Node *node = new Node(string(yytext), 4);yylval = node;return Continue;}
{DO}                                  {Node *node = new Node(string(yytext), 4);yylval = node;return Do;}
{INT}                                 {Node *node = new Node(string(yytext), 4);yylval = node;return Type;}
{CHAR}                            {Node *node = new Node(string(yytext), 4);yylval = node;return Type;}
{FLOAT}                           {Node *node = new Node(string(yytext), 4);yylval = node;return Type;}
{DOUBLE}                       {Node *node = new Node(string(yytext), 4);yylval = node;return Type;}
{VOID}                              {Node *node = new Node(string(yytext), 4);yylval = node;return Type;}
{CONST}                          {Node *node = new Node(string(yytext), 4);yylval = node;return Type;}
{TRUE}                             {Node *node = new Node(string(yytext), 4);yylval = node;return True;}
{FALSE}                            {Node *node = new Node(string(yytext), 4);yylval = node;return False;}
{LPAREN}                        {Node *node = new Node(string(yytext),3);yylval = node;return Lp;}
{RPAREN}                       {Node *node = new Node(string(yytext),3);yylval = node;return Rp;}
{LBRACE}                        {Node *node = new Node(string(yytext),3);yylval = node;return Lb;}
{RBRACE}                        {Node *node = new Node(string(yytext),3);yylval = node;return Rb;}
{SEMICOLON}               {Node *node = new Node(string(yytext),3);yylval = node;return Semicolon;}
{EQ}                                  {Node *node = new Node("e",4);yylval = node;return CompOp;}
{NE}                                  {Node *node = new Node("ne",4);yylval = node;return CompOp;}
{LT}                                   {Node *node = new Node("l",4);yylval = node;return CompOp;}
{GT}                                  {Node *node = new Node("g",4);yylval = node;return CompOp;}
{LE}                                   {Node *node = new Node("le",4);yylval = node;return CompOp;}
{GE}                                  {Node *node = new Node("ge",4);yylval = node;return CompOp;}
{AND}                               {Node *node = new Node("andl",4);yylval = node;return And;}
{OR}                                  {Node *node = new Node("orl",4);yylval = node;return Or;}
{NOT}                               {Node *node = new Node("not",4);yylval = node;return Not;}
{ADDR}                             {Node *node = new Node(string(yytext),4);yylval = node;return Addr;}
{ASSIGN}                         {Node *node = new Node(string(yytext),4);yylval = node;return Assign;}
{PLUS}                             {Node *node = new Node("addl",4);yylval = node;return Plus;}
{MINUS}                          {Node *node = new Node("subl",4);yylval = node;return Minus;}
{MULT}                             {Node *node = new Node("mul",4);yylval = node;return Mult;}
{DIV}                                 {Node *node = new Node("div",4);yylval = node;return Div;}
{MOD}                              {Node *node = new Node("mod",4);yylval = node;return Mod;}
{INCRE}                           {Node *node = new Node("addl",4);yylval = node;return SelfOp;}
{DECRE}                          {Node *node = new Node("subl",4);yylval = node;return SelfOp;}
{PLUSA}                          {Node *node = new Node("addl",4);yylval = node;return AriAOp;}
{MINUSA}                       {Node *node = new Node("subl",4);yylval = node;return AriAOp;}
{MULTA}                          {Node *node = new Node("mul",4);yylval = node;return AriAOp;}
{DIVA}                              {Node *node = new Node("div",4);yylval = node;return AriAOp;}
{MODA}                           {Node *node = new Node("mod",4);yylval = node;return AriAOp;}
{ID}                                   {Node *node = new Node(string(yytext),7);yylval = node;return Variable;}
{CONSTSTR}                  {Node *node = new Node(string(yytext), 3);yylval = node;return String;}
{OTHER}                         {}

%%

int yywrap(void){
  puts(">>>end of the file<<<");
  return 1;
}