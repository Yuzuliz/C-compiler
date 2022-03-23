#include <iostream>
#include <fstream>
#include <iomanip>
#include <stdio.h>//printf和FILE要用的
using namespace std;
//#ifndef _GLBCXX_USE_CXX11_ABI
#define _D_GLBCXX_USE_CXX11_ABI 0
//#endif
 
/*当lex每识别出一个记号后，是通过变量yylval向yacc传递数据的。默认情况下yylval是int类型，也就是只能传递整型数据。
yylval是用YYSTYPE宏定义的，只要重定义YYSTYPE宏，就能重新指定yylval的类型(可参见yacc自动生成的头文件yacc.tab.h)。
在我们的例子里，当识别出标识符后要向yacc传递这个标识符串，yylval定义成整型不太方便(要先强制转换成整型，yacc里再转换回char*)。
这里把YYSTYPE重定义为struct Type，可存放多种信息*/

//class Node;
class label{
public:
  string start_label;
  string next_label;
  string true_label;
  string false_label;
  label():start_label(""),next_label(""),true_label(""),false_label(""){};
};

class basicInfo{
public:
  int No;
  string value;
  string type;
  basicInfo(string v="", string t="",int n=0):value(v),type(t),No(n){};
  void copy(basicInfo *bsi){
    No = bsi->No;
    value = bsi->value;
    type = bsi->type;
  }
};

class idNode{
public:
  basicInfo *basic;
  idNode *next;
  idNode(string v="", string t="",int n=0):next(NULL){
    basic = new basicInfo(v,t,n);
  };
  idNode(basicInfo *b){
    basic = b;
    next = NULL;
  }
  idNode(idNode *idn){
    basic = idn->basic;
    next = idn->next;
  };
  string get_type(){
    return basic->type;
  }
};

class idList{
public:
  idNode *start;
  string listArea;
  int earliest;
  idList():start(NULL),listArea(""){};
  void addPoint(idNode *p){
    if(start == NULL){
      start = p;
    }
    else{
      idNode *cur = start;
      for(;cur && cur->next ;cur = cur->next );
      if(cur && !cur->next){
        cur->next = p;
      }
    }
  };
  void addId(string v,string t,int n){
    idNode *p = new idNode(v, t,n);
    addPoint(p);
  };
  void display(){
    if(start == NULL){
      return;
    }
    cout << listArea << " : " ;
    for(idNode *cur = start ; cur ; cur = cur->next){
      cout << cur->basic->No << ":" << cur->basic->type << "-" << cur->basic->value << "    ";
    }
    cout << endl;
  };
  void fetch(idList *l){
    // 将l的idList据为己有
    // l没有idList
    if(l->start == NULL){
      //cout << "l->start == NULL" << endl;
      return;
    }
    // 自己没有idList
    if(start == NULL){
      //cout << "start == NULL" << endl;
      start = l->start;
    }
    // 都有idList，把l的接在后面，检查重声明现象
    else{
      /**/
      //cout << "neither empty" << endl;
      idNode *lnode=l->start,*node,*cur;
      int same;
      while( lnode ){
        same = 0;
        for(node = start ; node ; node = node->next){
          if(node->basic->type == lnode->basic->type && node->basic->value == lnode->basic->value){
            cout << ">>> !!! " << l->listArea << "其中" << lnode->basic->value << "是重声明变量 !!! <<<" << endl;
            same = 1;
            break;
          }
          if(!node->next){
            break;
          }
        }
        cur = lnode;
        lnode = cur->next;
        if(!same){
          node->next = cur;
        }
        else{
          delete cur;
        }
      }
    }
    l->start = NULL;
  };
};

class Node{
public:
  basicInfo *basic;
  Node *father;
  Node *child;
  Node *leftBro;
  Node *rightBro;
  idList *idChain;
  label *labels;
  int combined;
  Node(string v="", int tid = 7):child(NULL),leftBro(NULL),rightBro(NULL),father(NULL),combined(0){
    basic = new basicInfo;
    basic->No = -1;
    basic->value = v;
    idChain = new idList;
    labels = new label;
    switch (tid)
    {
      case 1:
        basic->type = "int";
        break;
      case 2:
        basic->type = "char";
        break;
      case 3:
        basic->type = "constStr";
        break;
      case 4:
        basic->type = "keyword";
        break;
      case 5:
        basic->type = "sign";
        break;
      case 6:
        basic->type = "operator";
        break;
      default:
        basic->type = "void";
        break;
    };
  };
  void set_value(string s){
    basic->value = s;
  };
  void set_type(string t){
    basic->type = t;
  };
  void fetch(Node *n){
    idChain->fetch(n->idChain);
  }
};

#define YYSTYPE Node*
//把YYSTYPE(即yylval变量)重定义为Node*类型，这样lex就能向yacc返回更多的数据了

/*
  //打开要读取的文本文件
  const char* sFile="./1.c";
	FILE* fp=fopen(sFile, "r");
	if(fp==NULL)
	{
		printf("cannot open %s\n", sFile);
		return -1;
	}
  //yyin和yyout都是FILE*类型
	extern FILE* yyin;	
  //yacc会从yyin读取输入，yyin默认是标准输入，这里改为磁盘文件。yacc默认向yyout输出，可修改yyout改变输出目的
	yyin=fp;
  ofstream outfile("1_result.txt",ios::app);*/