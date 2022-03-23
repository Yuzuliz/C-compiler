%{
  #include "main.h"
  extern "C"{
    void yyerror(const char *s);
    extern int yylex(void);
  };
  class rodataPart{
  public:
    basicInfo *basic;
    rodataPart *next;
    rodataPart(basicInfo *bsi):basic(bsi),next(NULL){};
    rodataPart(Node *n):basic(n->basic),next(NULL){};
  };
  Node* root;
  idList *globalChain = new idList;
  rodataPart *rdp = NULL;
  int index=1;
  int newLabel = 1;
  int constNo = 0;

  void printTree(Node *root,ofstream& outfile){
    if(root == NULL){
      printf("it's an empty tree!\n");
      return;
    }
    else{
      cout << "@" << setw(3) << left << root->basic->No  << "|" << setw(15) << left << root->basic->type  << "|" << setw(20) << left << root->basic->value  << "|[";
      for(Node *temp = root->child; temp ; temp = temp->rightBro){
        cout << "@" << temp->basic->No << " ";
      }
      cout <<"]" << endl;
      outfile << "@" << setw(3) << left << root->basic->No  << "|" << setw(15) << left << root->basic->type  << "|" << setw(20) << left << root->basic->value  << "|[";
      for(Node *temp = root->child; temp ; temp = temp->rightBro){
        outfile << "@" << temp->basic->No << " ";
      }
      outfile <<"]" << endl;
      
      for(Node *temp = root->child; temp ; temp = temp->rightBro){
        printTree(temp,outfile);
      }
    }
  };

  void printIdList(Node *root){
    if(root == NULL){
      //printf("it's an empty tree!\n");
      return;
    }
    else{
      if(root->idChain->start)
        cout << root->basic->No << "—— ";
      root->idChain->display();
      for(Node *temp = root->child; temp ; temp = temp->rightBro){
        printIdList(temp);
      }
    }
  };

  void setNo(Node *node,int i){
    node->basic->No = i;
  };

  void order(Node *root){
    for(Node *temp = root->child ; temp ; temp = temp->rightBro){
      temp->basic->No = ::index;
      ::index++;
    }
    for(Node *temp = root->child ; temp ; temp = temp->rightBro){
      order(temp);
    }
  };

  void add_child(Node *f, Node* s = NULL){
    if(s == NULL){
      s = new Node;
    }
    if(f->child == NULL){
      f->child = s;
    }
    else{
      Node* temp;
      for(temp = f->child ; temp->rightBro != NULL && temp ; temp = temp->rightBro);
      if(temp && !temp->rightBro){
        if(s){
          temp->rightBro = s;
          s->leftBro = temp;
        }
      }
    }
    s->father = f;
  };

  string searchId(Node *s, Node *f){
    if(s->basic->type != "variable"){
      return s->basic->type;
    }
    if(f == NULL){
      cout << ">>> !!! TYPE ERROR : " << s->basic->value << " NOT FOUND !!! <<<" << endl;
      return "ERROR TYPE";
    }
    if(f->idChain == NULL){
      return searchId(s, f->father);
    }
    idNode *st = f->idChain->start;
    if(st == NULL){
      return searchId(s, f->father);
    }
    if(s->basic->No < st->basic->No){
      return searchId(s, f->father);
    }
    idNode *temp;
    for(temp = f->idChain->start ; temp ; temp = temp->next){
      if(temp->basic->value == s->basic->value){
        return temp->basic->type;
      }
    }
    return searchId(s, f->father);
  };

  void setIdType(Node *s){
    for(Node *temp = s->child ; temp ; temp = temp->rightBro){
      temp->basic->type = searchId(temp,s);
    }
    for(Node *temp = s->child ; temp ; temp = temp->rightBro){
      setIdType(temp);
    }
  };

  void typeCheck(Node *root);

  void recursive_return_check(string t, Node *root){
    if(root == NULL){
      return;
    }
    if(root->basic->value == "return"){
      typeCheck(root->child);
      if(root->child && root->child->basic->type == t){
        //Do nothing
      }
      else if(root->child == NULL && t == "void"){
        //Do nothing
      }
      else{
        cout << root->basic->No << " : 函数返回值不符合类型" << endl;
      }
    }
    for(Node *cur = root->child ; cur ; cur = cur->rightBro){
      recursive_return_check(t, cur);
    }
  };

  Node* join(Node *list, Node *p, string t){
    if(list->combined){
    add_child(list, p);
    return list;
    }
    // 单个id
    else{
      Node *node = new Node;
      add_child(node, list);
      add_child(node, p);
      node->set_type(t);
      node->combined = 1;
      return node;
    }
  }

  void typeCheck(Node *root){
    if(root == NULL){
      return ;
    }
    // return类型：找到return，检查类型是否对应
    else if(root->basic->type == "function"){
      recursive_return_check(root->child->basic->value,root->child->rightBro->rightBro);
    }
    // 几何运算
    // 双目
    else if(root->basic->type == "cal-double"){
      Node *expr1 = root->child;
      Node *expr2 = expr1->rightBro;
      typeCheck(expr1);
      typeCheck(expr2);
      if(expr1->basic->type == "int" && expr2->basic->type == "int"){
        //root->basic->type = "int";
      }
      else{
        cout << root->basic->No << " : 运算数" << expr1->basic->value << "和" << expr2->basic->value << "的类型不合法" << endl;
      }
    }
    // a++
    else if(root->basic->type == "cal-behind"){
      typeCheck(root->child);
      if(root->child->basic->type == "int"){
        //root->basic->type = "int";
      }
      else{
        cout << root->basic->No << " : 运算数" << root->child->basic->value << "的类型不合法" << endl;
      }
    }
    // ++a
    else if(root->basic->type == "cal-front"){
      typeCheck(root->child);
      if(root->child->basic->type == "int"){
        //root->basic->type = "int";
      }
      else{
        cout << root->basic->No << " : 运算数" << root->child->child->basic->value << "的类型不合法" << endl;
      }
    }
    // 赋值运算
    else if(root->basic->type == "assign"){
      Node *assignl = root->child;
      Node *assignr = assignl->rightBro;
      typeCheck(assignl);
      typeCheck(assignr);
      if(assignl->basic->type != assignr->basic->type){
        cout << root->basic->No << " : 赋值两侧类型不一致" << endl;
      }
    }
    // bool类型间运算
    // 双目
    else if(root->basic->type == "bool-double"){
      Node *bool1 = root->child;
      Node *bool2 = bool1->rightBro;
      typeCheck(bool1);
      typeCheck(bool2);
      if(bool1->basic->type == "bool" && bool2->basic->type == "bool"){
        root->basic->type = "bool";
      }
      else{
        cout << root->basic->No << " : " << bool1->basic->value << "和" << bool2->basic->value << "不是布尔类型" << endl;
      }
    }
    // 单目
    if(root->basic->type == "bool-single"){
      typeCheck(root->child);
      if(root->child->basic->type == "bool"){
          root->basic->type = "bool";
        }
        else{
          cout << root->basic->No << " : " << root->child->basic->value << "不是布尔类型" << endl;
        }
    }
    // 比较运算
    if(root->basic->type == "bool-compare"){
      Node *expr1 = root->child;
      Node *expr2 = expr1->rightBro;
      typeCheck(expr1);
      typeCheck(expr2);
      if(expr1->basic->type == expr2->basic->type){
        //Do nothing
      }
      else{
        cout << root->basic->No << " : 比较两侧类型不一致" << endl;
      }
    }
    // 标准输入输出
    if(root->basic->type == "instr-iostd"){
      string tem = root->child->basic->value;
      int i = 0,l = tem.length();
      Node *curId = root->child->rightBro;
      if(root->child->rightBro->basic->type == "idList"){
        curId = curId->child;
      }
      for(int i = 0  ; i < l ; i++){
        if(tem.at(i) == '\\' && tem.at(i+1) == '%'){
          i++;
        }
        else if(tem.at(i) == '%'){
          //cout << i << " : " ;
          if(curId == NULL){
            cout << root->basic->No << " : NULL标准输入输出类型不合法！" << endl;
            root->basic->type = "ERROR-"+root->basic->value;
            break;
          }
          else if(tem.at(i+1) == 'd' && curId->basic->type == "int"){
            //cout << "int OK";
            curId = curId->rightBro;
          }
          else if(tem.at(i+1) == 'c' && curId->basic->type == "char"){
            //cout << "char OK";
            curId = curId->rightBro;
          }
          else{
            cout << root->basic->No << " : 标准输入输出类型不合法！" << endl;
            root->basic->type = "ERROR-"+root->basic->value;
            break;
          }
        }
      }
      if(curId != NULL){
        cout << root->basic->No << " : 标准输入输出类型不合法！" << endl;
        root->basic->type = "ERROR-"+root->basic->value;
      }
      else{
        root->basic->type = root->basic->value;
      }
    }

    for(Node *cur = root->child ; cur ; cur = cur->rightBro){
      typeCheck(cur);
    }
  };
  
  void addIdNode(idList *l, Node *v){
    idNode *p = new idNode(v->basic);
    l->addPoint(p);
  };

  string get_new_label(){
    string s = "L" + to_string(::newLabel);
    ::newLabel++;
    return s;
  };

  string get_last_label(){
    return "L" + to_string(::newLabel-1);
  };

  string get_next_label(){
    return "L" + to_string(::newLabel);
  }

  void get_label(Node *t){
    if(t == NULL){
      return;
    }
    if(t->basic->type == "function"){
      t->labels->start_label = t->child->rightBro->basic->value;
      if(t->labels->start_label == "main"){
        t->labels->start_label = "_start";
      }
      get_label(t->child->rightBro->rightBro);
    }
    else if(t->basic->type == "void"){
      for(Node *cur = t->child ; cur ; cur = cur->rightBro){
        get_label(cur);
      }
    }
    else if(t->basic->type == "statement-while"){
      // 循环条件
      Node *e = t->child;
      // 循环体
      Node *s = e->rightBro;
      if(t->labels->start_label == ""){
        t->labels->start_label = get_new_label();
      }      
      s->labels->next_label = t->labels->start_label;
      e->labels->true_label = get_new_label();
      s->labels->start_label = e->labels->true_label;
      //循环结束的标号
      if (t->labels->next_label == "")
      t->labels->next_label = get_new_label();
      //循环条件的假值标号即为循环的下一条语句标号
      e->labels->false_label = t->labels->next_label;
      //兄弟节点的开始标号即为当前节点的下一条语句的标号
      if (t->rightBro)
        t->rightBro->labels->start_label = t->labels->next_label;
      /**/// 语句块
      if(s->basic->type == "void"){
        Node *cur;
        for(cur = s->child ; cur->rightBro ; cur = cur->rightBro);
        cout << cur->basic->type << cur->basic->value << "-----------" ;
        cur->labels->next_label = t->labels->start_label;
        cout << cur->labels->next_label << "|" << t->labels->start_label << endl;
      }
      //递归生成
      get_label(e);
      get_label(s);
    }
    else if(t->basic->type == "statement-for"){
      //声明
      Node *d = t->child;
      //判断
      Node *e = d->rightBro;
      //举措
      Node *a = e->rightBro;
      //循环体
      Node *s = a->rightBro;
      if(e->labels->start_label == ""){
        e->labels->start_label = get_new_label();        
      }
      if(a)
        a->labels->next_label = e->labels->start_label;
      if(t->rightBro){
        t->rightBro->labels->start_label = get_new_label();
        t->labels->next_label = t->rightBro->labels->start_label;
      }
      cout <<"----------------for:" << t->labels->next_label << endl;
      if(e->basic->type != "void"){
        e->labels->false_label = t->labels->next_label;
      }
      get_label(s);
    }
    else if(t->basic->type == "statement-if"){
      // 判断条件
      Node *e = t->child;
      // 语句体
      Node *s = e->rightBro;
      if(t->labels->start_label == ""){
        t->labels->start_label = get_new_label();
      }
      //e->labels->start_label = t->labels->start_label;
      if(s->labels->start_label == ""){
        s->labels->start_label = get_new_label();
      }
      e->labels->true_label = s->labels->start_label;
      if(t->rightBro){
        t->rightBro->labels->start_label = get_new_label();
        e->labels->false_label = t->rightBro->labels->start_label;
      }
      else{
        e->labels->false_label = t->labels->next_label;
      }
      s->labels->next_label = e->labels->false_label;
      if(s->basic->type == "void"){
        Node *cur;
        for(cur = s->child ; cur->rightBro ; cur = cur->rightBro);
        cur->labels->next_label = e->labels->false_label;
      }
      get_label(s);
    }
    else if(t->basic->type == "statement-ifElse"){
      // 判断条件
      Node *e = t->child;
      // 语句体
      Node *st = e->rightBro;
      Node *sf = st->rightBro;
      if(st->labels->start_label == ""){
        st->labels->start_label = get_new_label();
      }
      if(t->rightBro){
        t->rightBro->labels->start_label = get_new_label();
        st->labels->next_label = t->rightBro->labels->start_label;
        sf->labels->next_label = t->rightBro->labels->start_label;
      }
      else{
        st->labels->next_label = t->labels->next_label;
        sf->labels->next_label = t->labels->next_label;
      }
      e->labels->true_label = st->labels->start_label;
      if(st->basic->type == "void"){
        Node *cur;
        for(cur = st->child ; cur->rightBro ; cur = cur->rightBro);
        cur->labels->next_label = t->labels->next_label;
      }
      else
        st->labels->next_label = t->labels->next_label;
      if(sf->basic->type == "void"){
        Node *cur;
        for(cur = sf->child ; cur->rightBro ; cur = cur->rightBro);
        cur->labels->next_label = t->labels->next_label;
      }
      else
        sf->labels->next_label = t->labels->next_label;
      get_label(sf);
      get_label(st);
    }
    
    /*
    for(Node *cur = root ; cur ; cur = cur->rightBro){
      get_label(cur);
    }*/
  };

  void set_bss(ofstream& outfile){
    outfile << endl << "# bss 段 存储全局变量" << endl << "\t .bss" << endl;
    cout << endl << "# bss 段 存储全局变量" << endl << "\t .bss" << endl;
    for(idNode *cur = globalChain->start ; cur ; cur = cur->next){
      outfile << "\t .align 4" << endl << cur->basic->value << ":" << endl << "\t .zero 4" << endl;
      cout << "\t .align 4" << endl << cur->basic->value << ":" << endl << "\t .zero 4" << endl;
    }
  };

  void set_rodata(Node *root, ofstream& outfile){
    if(root == NULL){
      return;
    }
    if(root->basic->type == "constStr"){
      
      /*rodataPart *cur = ::rdp;
      for( ; cur && cur->basic->value != root->basic->value ; cur = cur->next);
      if(!cur){
        rodataPart *p = new rodataPart(root);
        cur = p;
        if(::constNo == 0){
          outfile << endl << "# rodata 段 存储常量" << endl;
          cout << endl << "# rodata 段 存储常量" << endl;
          outfile << "\t .section \t rodata" << endl;
          cout << "\t .section \t rodata" << endl;
        }
        p->basic->type = "STR" + to_string(::constNo);
        ::constNo++;
      }
      else{
        root->basic->type = cur->basic->type;
      }
      */
      rodataPart *cur = ::rdp, *p = new rodataPart(root);
      if(::constNo == 0){
        outfile << endl << "# rodata 段 存储常量" << endl;
        cout << endl << "# rodata 段 存储常量" << endl;
        outfile << "\t .section \t rodata" << endl;
        cout << "\t .section \t rodata" << endl;
        root->basic->type = "STR" + to_string(::constNo);
        outfile << root->basic->type << ":" << endl;
        cout << root->basic->type << ":" << endl;
        outfile << "\t .string  "<< root->basic->value << endl;
        cout << "\t .string  "<< root->basic->value << endl;
        ::rdp = p;
        //cur = p->next;
        ::constNo++;
      }else{
        for(cur = ::rdp ; cur ; cur = cur->next){
          if(cur->basic->value == p->basic->value){
            break;
          }
          if(!cur->next ){
            break;
          }
        }
        if(cur->basic->value != p->basic->value){
          root->basic->type = "STR" + to_string(::constNo);
          outfile << root->basic->type << ":" << endl;
          cout << root->basic->type << ":" << endl;
          outfile << "\t .string  "<< root->basic->value << endl;
          cout << "\t .string  "<< root->basic->value << endl;
          root->basic->value = root->basic->type;
          cur->next = p;
          ::constNo++;
        }
        else{
          root->basic->type = cur->basic->type;
        }
      }
      
    }
    for(Node *cur = root->child ; cur ; cur = cur->rightBro){
      set_rodata(cur,outfile);
    }
  };

  void recursive_gen_code(Node *root,ofstream& outfile){
    if(root == NULL){
      return ;
    }
    if(root->basic->type == "function"){
      string funcName = root->labels->start_label;
      outfile << endl << "# 函数" << funcName << endl;
      cout << endl << "# 函数" << funcName << endl;
      outfile << "\t .text" << endl;
      cout << "\t .text" << endl;
      outfile << "\t .globl \t" << funcName << endl;
      cout << "\t .globl \t" << funcName << endl;
      outfile << "\t .type \t " << funcName << ",@function" << endl;
      cout << "\t .type \t "<< funcName << ",@function" << endl;
      outfile << funcName << ":" << endl;
      cout << funcName << ":" << endl;
      outfile << "\t pushl \t %ebp \n\t movl \t %esp,%ebp \n\t subl \t $4,%esp" << endl;
      cout << "\t pushl \t %ebp \n\t movl \t %esp,%ebp \n\t subl \t $4,%esp" << endl;
      for(Node *cur = root->child->rightBro->rightBro->child ; cur ; cur = cur->rightBro){
        recursive_gen_code(cur, outfile);
      }
    }
    else if(root->labels->start_label != ""){
      outfile << root->labels->start_label << ":" << endl;
      cout << root->labels->start_label << ":" << endl;
    }
    if(root->basic->type == "scanf"){
      int offset = 4;
      outfile << "# scanf( " << root->child->basic->value ;
      cout << "# scanf( " << root->child->basic->value ;
      Node *variables = root->child->rightBro;
      if(variables == NULL){
        outfile << ");" << endl;
        cout << ");" << endl;
      }
      else{
        Node *cur;
        if(variables->basic->type == "idList"){
          for(cur = variables->child ; cur && cur->rightBro ; cur = cur->rightBro){
            outfile << ", &" << cur->basic->value;
            cout << ", &" << cur->basic->value;
          }
          outfile << ", &" << cur->basic->value << ");" << endl;
          cout <<  ", &" << cur->basic->value << ");" << endl;
          while(cur){
            outfile << "\t pushl \t $" << cur->basic->value << endl;
            cout << "\t pushl \t $" << cur->basic->value << endl;
            offset += 4;
            cur = cur->leftBro;
          }
        }
        else{
          outfile << ", &" << variables->basic->value << ");" << endl;
          cout <<  ", &" << variables->basic->value << ");" << endl;
          outfile << "\t pushl \t $" << variables->basic->value << endl;
            cout << "\t pushl \t $" << variables->basic->value << endl;
          offset += 4;
        }
        
      }
      outfile << "\t pushl \t $" << root->child->basic->type << endl;
      cout << "\t pushl \t $" << root->child->basic->type << endl;
      outfile << "\t call \t scanf" << endl;
      cout << "\t call \t scanf" << endl;
      outfile << "\t addl \t $" << offset << ", %esp" << endl << endl;
      cout << "\t addl \t $" << offset << ", %esp" << endl << endl;
      if(root->labels->next_label != ""){
        outfile << "\t jmp \t " << root->labels->next_label << endl;
        cout << "\t jmp \t " << root->labels->next_label << endl;
      }
    }
    else if(root->basic->type == "printf"){
      //printf("constr",idList);  root->child:constr idlist
      //printf("constr");
      int offset = 4;
      outfile << "# printf( " << root->child->basic->value ;
      cout << "# printf( " << root->child->basic->value ;
      Node *variables = root->child->rightBro;
      if(variables == NULL){
        outfile << ");" << endl;
        cout << ");" << endl;
      }
      else{
        Node *cur;
        if(variables->basic->type == "idList"){
          for(cur = variables->child ; cur && cur->rightBro ; cur = cur->rightBro){
            outfile << ", " << cur->basic->value;
            cout << ", " << cur->basic->value;
          }
          outfile << ", " << cur->basic->value << ");" << endl;
          cout <<  ", " << cur->basic->value << ");" << endl;
          while(cur){
            outfile << "\t pushl \t $" << cur->basic->value << endl;
            cout << "\t pushl \t $" << cur->basic->value << endl;
            offset += 4;
            //cout << "offset=" << offset << endl;
            cur = cur->leftBro;
          }
          //cout << "break while" << endl;
        }
        else{
          outfile << ", " << variables->basic->value << ");" << endl;
          cout <<  ", " << variables->basic->value << ");" << endl;
          outfile << "\t pushl \t $" << variables->basic->value << endl;
            cout << "\t pushl \t $" << variables->basic->value << endl;
          offset += 4;
        }
        
      }
      outfile << "\t pushl \t $" << root->child->basic->type << endl;
      cout << "\t pushl \t $" << root->child->basic->type << endl;
      outfile << "\t call \t printf" << endl;
      cout << "\t call \t printf" << endl;
      outfile << "\t addl \t $" << offset << ", %esp" << endl << endl;
      cout << "\t addl \t $" << offset << ", %esp" << endl << endl;
      if(root->labels->next_label != ""){
        outfile << "\t jmp \t " << root->labels->next_label << endl;
        cout << "\t jmp \t " << root->labels->next_label << endl;
      }
    }
    else if(root->basic->type == "assign"){
      Node *assignl = root->child;
      Node *assignr = assignl->rightBro;
      string result = "";
      if(assignr->basic->type == "int"){
        outfile << "\t movl \t $" << assignr->basic->value << ", %eax" << endl;
        cout << "\t movl \t $" << assignr->basic->value << ", %eax" << endl;
      }
      else if(assignr->basic->type.substr(0,3) == "STR"){
        outfile << "\t movl \t $" << assignr->basic->type << ", %eax" << endl;
        cout << "\t movl \t $" << assignr->basic->type << ", %eax" << endl;
      }
      else{
        recursive_gen_code(assignr,outfile);
        result = "$eax";
      }
      outfile << "\t movl \t %eax, " << assignl->basic->value << endl;
      cout << "\t movl \t %eax, " << assignl->basic->value << endl;
      outfile << "\t movl \t " << assignl->basic->value << ", %eax" << endl;
      cout << "\t movl \t " << assignl->basic->value << ", %eax" << endl;
      if(root->labels->next_label != ""){
        outfile << "\t jmp \t " << root->labels->next_label << endl;
        cout << "\t jmp \t " << root->labels->next_label << endl;
      }
    }
    else if(root->basic->type == "assign-cal"){
      Node *assignl = root->child;
      Node *assignr = assignl->rightBro;
      if(assignr->basic->type == "int"){
        outfile << "\t movl	$" << assignr->basic->value << ", %eax" << endl;
        cout << "\t movl	$" << assignr->basic->value << ", %eax" << endl;
      }
      outfile << "\t movl	$" << assignl->basic->value << ", %ebx" << endl;
      cout << "\t movl	$" << assignl->basic->value << ", %ebx" << endl;
      outfile << "\t " << root->basic->value << " \t %eax, %ebx" << endl ;
      cout << "\t " << root->basic->value << " \t %eax, %ebx" << endl;
      outfile << "\t movl \t %ebx, $" << assignl->basic->value << endl << endl;
      cout << "\t movl \t %ebx, $" << assignl->basic->value << endl << endl;
      if(root->labels->next_label != ""){
        outfile << "\t jmp \t " << root->labels->next_label << endl;
        cout << "\t jmp \t " << root->labels->next_label << endl;
      }
    }
    else if(root->basic->type == "cal-double"){
      Node *call = root->child;
      Node *calr = call->rightBro;
      outfile << "\t movl \t $" << call->basic->value << ", %eax" << endl;
      cout << "\t movl \t $" << call->basic->value << ", %eax" << endl;
      if(root->basic->value == "mod"){
        outfile << "\t pushl \t %eax" << endl;
        outfile << "\t movl \t $" << calr->basic->value << ", %eax" <<endl;
        outfile << "\t movl \t %eax, %ebx" <<endl;
        outfile << "\t popl \t %eax" <<endl;
        outfile << "\t cltd" <<endl;
        outfile << "\t idivl \t %ebx" <<endl;
        outfile << "\t movl \t %edx, %eax" <<endl;
        outfile << "\t pushl \t %eax" <<endl;
        cout << "\t pushl \t %eax" << endl;
        cout << "\t movl \t $" << calr->basic->value << ", %eax" <<endl;
        cout << "\t movl \t %eax, %ebx" <<endl;
        cout << "\t popl \t %eax" <<endl;
        cout << "\t cltd" <<endl;
        cout << "\t idivl \t %ebx" <<endl;
        cout << "\t movl \t %edx, %eax" <<endl;
        cout << "\t pushl \t %eax" <<endl;
      }
      else{
        outfile << "\t " << root->basic->value << " \t $" << calr->basic->value << ", %eax" << endl;
        outfile << "\t movl \t %eax, " << call->basic->value << endl;
        outfile << "\t movl \t " << call->basic->value << ", %eax" << endl;
      }
      
    }
    else if(root->basic->type == "cal-behind" || root->basic->type == "cal-front"){
      Node *var = root->child;
      if(var->basic->type == "int"){
        outfile << "\t movl \t $" << var->basic->value << ", %ebx" << endl;
        cout << "\t movl \t $" << var->basic->value << ", %ebx" << endl;
      }
      outfile << "\t " << root->basic->value << " \t $1, %ebx" << endl ;
      cout << "\t " << root->basic->value << " \t $1, %ebx" << endl;
      outfile << "\t movl \t %ebx, $" << var->basic->value << endl << endl;
      cout << "\t movl \t %ebx, $" << var->basic->value << endl << endl;
      if(root->labels->next_label != ""){
        outfile << "\t jmp \t " << root->labels->next_label << endl;
        cout << "\t jmp \t " << root->labels->next_label << endl;
      }
    }
    else if(root->basic->type == "statement-if"){
      outfile << "# " << root->basic->type << endl;
      cout << "# " << root->basic->type << endl;
      // 判断条件
      Node *e = root->child;
      // 语句体
      Node *s = e->rightBro;
      recursive_gen_code(e, outfile);
      outfile << "\t cmpl \t $0, %eax" << endl;
        cout << "\t cmpl \t $0, %eax" << endl;
      outfile << "\t je \t " << e->labels->false_label << endl;
      cout << "\t je \t " << e->labels->false_label << endl;
      recursive_gen_code(s, outfile);
      if(!root->rightBro){
        outfile << "\t jmp \t " << s->labels->next_label << endl;
        cout << "\t jmp \t " << s->labels->next_label << endl;
      }
    }
    else if(root->basic->type == "statement-ifElse"){
      outfile << "# " << root->basic->type << endl;
      cout << "# " << root->basic->type << endl;
      // 判断条件
      Node *e = root->child;
      // 语句体
      Node *st = e->rightBro;
      Node *sf = st->rightBro;
      recursive_gen_code(e, outfile);
      outfile << "\t cmpl \t $0, %eax" << endl;
        cout << "\t cmpl \t $0, %eax" << endl;
      outfile << "\t jne \t " << e->labels->true_label << endl;
      cout << "\t jne \t " << e->labels->true_label << endl;
      recursive_gen_code(sf, outfile);
      outfile << "\t jmp \t " << sf->labels->next_label << endl;
      cout << "\t jmp \t " << sf->labels->next_label << endl;
      recursive_gen_code(st, outfile);
      if(!root->rightBro){
        outfile << "\t jmp \t " << st->labels->next_label << endl;
        cout << "\t jmp \t " << st->labels->next_label << endl;
      }
    }
    else if(root->basic->type == "statement-for"){
      outfile << "# " << root->basic->type << endl;
      cout << "# " << root->basic->type << endl;
       //声明
      Node *d = root->child;
      //判断
      Node *e = d->rightBro;
      //举措
      Node *a = e->rightBro;
      //循环体
      Node *s = a->rightBro;
      if(d->basic->value != ""){
        recursive_gen_code(d, outfile);
      }
      if(e->basic->value != ""){
        recursive_gen_code(e, outfile);
        outfile << "\t cmpl \t $0, %eax" << endl;
        cout << "\t cmpl \t $0, %eax" << endl;
        outfile << "\t je \t " << e->labels->false_label << endl;
        cout << "\t je \t " << e->labels->false_label << endl;
      }
      recursive_gen_code(s, outfile);
      if(a->basic->value != ""){
        recursive_gen_code(a, outfile);
      }
      outfile << "\t jmp \t " << e->labels->start_label << endl;
      cout << "\t jmp \t " << e->labels->start_label << endl;
    }
    else if(root->basic->type == "statement-while"){
      outfile << "# " << root->basic->type << endl;
      cout << "# " << root->basic->type << endl;
      // 循环条件
      Node *e = root->child;
      // 循环体
      Node *s = e->rightBro;
      recursive_gen_code(e, outfile);
      outfile << "\t cmpl \t $0, %eax" << endl;
      cout << "\t cmpl \t $0, %eax" << endl;
      outfile << "\t je \t " << e->labels->false_label << endl;
      cout << "\t je \t " << e->labels->false_label << endl;
      recursive_gen_code(s, outfile);
      //outfile << "\t jmp \t " << s->labels->next_label << endl;
      //cout << "\t jmp \t " << s->labels->next_label << endl;
    }
    else if(root->basic->type == "bool-compare"){
      Node *bool1 = root->child;
      Node *bool2 = bool1->rightBro;
      if(bool1->basic->type == "int" || bool1->basic->type == "char"){
        if(bool1->basic->value.substr(0,1) == "-"){
          outfile << "\t movl \t $" << bool1->basic->value.substr(1) << ", %eax" << endl;
          cout << "\t movl \t $" << bool1->basic->value.substr(1) << ", %eax" << endl;
          outfile << "\t negl \t %eax" << endl;
          cout << "\t negl \t %eax" << endl;
        }
        else{
          outfile << "\t movl \t $" << bool1->basic->value << ", %eax" << endl;
          cout << "\t movl \t $" << bool1->basic->value << ", %eax" << endl;
        }
        outfile << "\t pushl \t %eax" << endl;
        cout << "\t pushl \t %eax" << endl;
      }
      else{
        recursive_gen_code(bool1, outfile);
      }
      if(bool2->basic->type == "int" || bool2->basic->type == "char"){
        if(bool2->basic->value.substr(0,1) == "-"){
          outfile << "\t movl \t $" << bool2->basic->value.substr(1) << ", %eax" << endl;
          cout << "\t movl \t $" << bool2->basic->value.substr(1) << ", %eax" << endl;
          outfile << "\t negl \t %eax" << endl;
          cout << "\t negl \t %eax" << endl;
        }
        else{
          outfile << "\t movl \t $" << bool2->basic->value << ", %eax" << endl;
          cout << "\t movl \t $" << bool2->basic->value << ", %eax" << endl;
        }
        outfile << "\t popl \t %ebx" << endl;
        cout << "\t popl \t %ebx" << endl;
      }
      else{
        recursive_gen_code(bool2, outfile);
      }
      outfile << "\t cmpl \t %eax, %ebx" << endl;
      cout << "\t cmpl \t %eax, %ebx" << endl;
      outfile << "\t set" << root->basic->value << " \t %al" << endl;
      cout << "\t set" << root->basic->value << " \t %al" << endl;
      outfile << "\t movzbl \t %al, %eax" << endl;
      cout << "\t movzbl \t %al, %eax" << endl;
    }
    else if(root->basic->type == "bool-double"){
      Node *bool1 = root->child;
      Node *bool2 = bool1->rightBro;
      recursive_gen_code(bool1,outfile);
      outfile << "\t pushl \t %eax" << endl;
      cout << "\t pushl \t %eax" << endl;
      recursive_gen_code(bool2,outfile);
      outfile << "\t popl \t %ebx" << endl;
      cout << "\t popl \t %ebx" << endl;
      outfile << "\t " << root->basic->value << " \t %ebx,%eax" << endl;
      cout << "\t " << root->basic->value << " \t %ebx,%eax" << endl;
    }
    else if(root->basic->type == "return"){
      if(root->child != NULL){
        outfile << "# return " << endl;
        cout << "# return " << endl;
        if(root->child->basic->type == "int" || root->child->basic->type == "char"){
          outfile << "\t addl \t $4, %esp" << endl;
          cout << "\t addl \t $4, %esp" << endl;
          outfile << "\t movl \t $" << root->child->basic->value << ", %eax" << endl;
          cout << "\t movl \t $" << root->child->basic->value << ", %eax" << endl;
        }
        else{
          recursive_gen_code(root->child,outfile);
          outfile << "\t addl \t $4, %esp" << endl;
          cout << "\t addl \t $4, %esp" << endl;
        }
      }
      outfile << "\t popl \t %ebp" << endl;
      cout << "\t popl \t %ebp" << endl;
      outfile << "\t ret" << endl;
      cout << "\t ret" << endl;
    }
    else if(root->basic->type == "void"){
      for(Node *cur = root->child ; cur ; cur = cur->rightBro){
        recursive_gen_code(cur, outfile);
      }
    }
    /*
    else{
      for(Node *cur = root->child ; cur ; cur = cur->rightBro){
        recursive_gen_code(cur, outfile);
      }
    }*/
  };

  void gen_code(Node *root,ofstream& outfile){
    get_label(root);
    set_bss(outfile);
    set_rodata(root, outfile);
    recursive_gen_code(root,outfile);
    outfile << "# 可执行堆栈段" << endl;
    cout << "# 可执行堆栈段" << endl;
    outfile << "\t .section \t .note.GNU-stack,\"\",@progbits" << endl;
    cout << "\t .section \t .note.GNU-stack,\"\",@progbits" << endl;
  }
%}

%token String
%token Num
%token Scanf
%token Printf
%token Return
%token While
%token If
%token Else
%token Switch
%token For
%token Break
%token Continue
%token Do
%token Type
%token True
%token False
%token Lp
%token Rp
%token Lb
%token Rb
%token Semicolon
%token CompOp
%token And
%token Or
%token Not
%token Addr
%token Assign
%token Plus
%token Minus
%token Mult
%token Div
%token Mod
%token SelfOp
%token AriAOp
%token Variable

%left CompOp

%right AriAOp

%left Plus Minus
%left Mult Div Mod

%left Or
%left And
%right Not


%%
Prog 
: Stmts                                                        {::root = $1;::root->basic->No=0;}
;         

Stmts 
: Stmt                                                           {$$ = $1;$$->combined = 0;}
| Stmts Stmt                                              {
  if($1->combined){
    add_child($1, $2);
    $$ = $1;
    $$->fetch($2);
  }
  else{
    Node *node = new Node;
    add_child(node, $1);
    add_child(node, $2);
    node->combined = 1;
    node->fetch($1);
    node->fetch($2);
    $$ = node;
  }}
;

Stmt 
: Instr Semicolon                                  {$$ = $1;}
| Type x Lp Rp Block                            {
  Node *node = new Node;
  node->set_type("function");
  add_child(node, $1);
  add_child(node, $2);
  add_child(node, $5);
  $2->set_type("function-name");
  $5->idChain->listArea = $2->basic->value;
  $$=node;}
| If Lp BExp Rp Block                             {
  $1->set_type("statement-if");
  add_child($1, $3);
  add_child($1, $5);
  $5->idChain->listArea = "if";
  $$=$1;}
| If Lp BExp Rp Block Else Block       {
  Node *node = new Node;
  node->set_type("statement-ifElse");
  add_child(node, $3);
  add_child(node, $5);
  add_child(node, $7);
  $7->idChain->listArea = "if-else";
  $$=node;}
| For Lp Semicolon Semicolon Rp Block                                      {
  $1->set_type("statement-for");
  add_child($1);
  add_child($1);
  add_child($1);
  add_child($1, $6);
  $1->fetch($6);
  $1->idChain->listArea = "for";
  $$=$1;}
| For Lp Semicolon Semicolon Instr Rp Block                           {
  $1->set_type("statement-for");
  add_child($1);
  add_child($1);
  add_child($1, $5);
  add_child($1, $7);
  $1->fetch($7);
  $1->idChain->listArea = "for";
  $$=$1;}
| For Lp Semicolon BExp Semicolon Rp Block                          {
  $1->set_type("statement-for");
  add_child($1);
  add_child($1, $4);
  add_child($1);
  add_child($1, $7);
  $1->fetch($7);
  $1->idChain->listArea = "for";
  $$=$1;}
| For Lp Semicolon BExp Semicolon Instr Rp Block               {
  $1->set_type("statement-for");
  add_child($1);
  add_child($1, $4);
  add_child($1, $6);
  add_child($1, $8);
  $1->fetch($8);
  $1->idChain->listArea = "for";
  $$=$1;}
| For Lp Instr Semicolon Semicolon Rp Block                          {
  $1->set_type("statement-for");
  add_child($1, $3);
  add_child($1);
  add_child($1);
  add_child($1, $7);
  $1->fetch($3);
  $1->fetch($7);
  $1->idChain->listArea = "for";
  $$=$1;}
| For Lp Instr Semicolon Semicolon Instr Rp Block                {
  $1->set_type("statement-for");
  add_child($1, $3);
  add_child($1);
  add_child($1, $6);
  add_child($1, $8);
  $1->fetch($3);
  $1->fetch($8);
  $1->idChain->listArea = "for";
  $$=$1;}
| For Lp Instr Semicolon BExp Semicolon Rp Block               {
  $1->set_type("statement-for");
  add_child($1, $3);
  add_child($1, $5);
  add_child($1);
  add_child($1, $8);
  $1->fetch($3);
  $1->fetch($8);
  $1->idChain->listArea = "for";
  $$=$1;}
| For Lp Instr Semicolon BExp Semicolon Instr Rp Block     {
  $1->set_type("statement-for");
  add_child($1, $3);
  add_child($1, $5);
  add_child($1, $7);
  add_child($1, $9);
  $1->fetch($3);
  $1->fetch($9);
  $1->idChain->listArea = "for";
  $$=$1;}
| While Lp BExp Rp Block                    {
  $1->set_type("statement-while");
  add_child($1, $3);
  add_child($1, $5);
  $5->idChain->listArea = "while";
  $$=$1;}
;

Block 
:Stmt                                                           {$$=$1;}
| Lb Stmts Rb                                           {$$=$2;}
| Lb RtnExpr Rb                                       {$$=$2;}
| Lb Stmts RtnExpr Rb                          {
  add_child($2,$3);
  $$=$2;}
;

RtnExpr
: Return Expr Semicolon             {
  add_child($1,$2);
  $1->set_type("return");
  $$ = $1;}
| Return Semicolon                       {
  $1->set_type("return");
  $$ = $1;}
;

Instr 
: Type idList                      {
  Node *node = new Node;
  add_child(node, $1);
  add_child(node, $2);
  node->set_type("declaration");
  // 生成符号表
  // 单个ID
  if(!$2->combined){
    // a = 1
    if($2->basic->type == "assign"){
      $2->child->set_type($1->basic->value);
      node->idChain->listArea = $1->basic->value;
      for(Node *n = $2->child ; n ; n = n->rightBro){
        node->idChain->listArea += " " + n->basic->value;
      }
      node->idChain->listArea += ",";
      addIdNode(node->idChain,$2->child);
      addIdNode(globalChain, $2->child);
    }
    // a
    else{
      $2->set_type($1->basic->value);
      node->idChain->listArea = $1->basic->value;
      node->idChain->listArea += " " + $2->basic->value;
      addIdNode(node->idChain,$2);
      addIdNode(globalChain, $2);
    }
  }
  // 多个ID
  else{
    node->idChain->listArea = $1->basic->value;
    for(Node *cur = $2->child ; cur ; cur = cur->rightBro){
      if(cur->basic->type == "assign"){
        cur->child->set_type($1->basic->value);
        for(Node *n = cur->child ; n ; n = n->rightBro){
          node->idChain->listArea += n->basic->value;
        }
      }
      else{
        node->idChain->listArea += cur->basic->value;
      }
      node->idChain->listArea += ",";
    }
    for(Node *cur = $2->child ; cur ; cur = cur->rightBro){
      if(cur->basic->type == "assign"){
        cur->child->set_type($1->basic->value);
        addIdNode(node->idChain,cur->child);
        addIdNode(globalChain, cur->child);
      }
      else{
        cur->set_type($1->basic->value);
        addIdNode(node->idChain,cur);
        addIdNode(globalChain, cur);
      }
    }
  }
  $$ = node;}
| x Assign Expr                {
  add_child($2, $1);
  add_child($2, $3);
  $2->set_type("assign");
  $$ = $2;}
| x AriAOp Expr               {
  add_child($2, $1);
  add_child($2, $3);
  $2->set_type("assign-cal");
  $$ = $2;}
|SelfOp x                          {
  add_child($1, $2);
  $1->set_type("cal-front");
  $$ = $1;}
| x SelfOp                         {
  add_child($2, $1);
  $2->set_type("cal-behind");
  $$ = $2;}
| Printf Lp Expr Rp        {
  add_child($1, $3);
  $1->set_type("printf");
  $$ = $1;}
| Printf Lp BExp Rp       {
  add_child($1, $3);
  $1->set_type("printf");
  $$ = $1;}
| Printf Lp String PrStd Rp  {
  add_child($1, $3);
  add_child($1, $4);
  $1->set_type("instr-iostd");
  $$ = $1;}
| Scanf Lp String ScanStd Rp  {
  add_child($1, $3);
  add_child($1, $4);
  $1->set_type("instr-iostd");
  $$ = $1;}
;

PrStd
: x                                                              {$$=$1;}
| PrStd x                                                 {$$ = join($1, $2,"idList");}
;

ScanStd
: Addr x                                                    {$$=$2;}
| ScanStd Addr x                                  {$$ = join($1, $3,"idList");}
;

idList 
: id                                                              {$$=$1;}
| idList id                                                  {$$ = join($1, $2, "idList");}
;

id 
: x                                                               {$$=$1;}
| x Assign Expr                                      {
  add_child($2, $1);
  add_child($2, $3);
  $2->set_type("assign");
  $$ = $2;}
;

BExp 
: True                                                         {$$ = $1;$$->set_type("bool");}
| False                                                        {$$ = $1;$$->set_type("bool");}
| Expr CompOp Expr                            {
  add_child($2, $1);
  add_child($2, $3);
  $2->set_type("bool-compare");
  $$ = $2;}
| Not BExp                                                {
  add_child($1, $2);
  $1->set_type("bool-single");
  $$ = $1;}
| BExp And BExp                                    {
  add_child($2, $1);
  add_child($2, $3);
  $2->set_type("bool-double");
  $$ = $2;}
| BExp Or BExp                                    {
  add_child($2, $1);
  add_child($2, $3);
  $2->set_type("bool-double");
  $$ = $2;}
;

Expr  
: x                                                              {$$ = $1;}
| Num                                                      {$$ = $1;$$->set_type("int");}
| String                                                    {$$ = $1;}
| Plus Expr                                             {$$ = $2;}
| Minus Expr                                             {
  add_child($1, $2);
  $1->set_type("uminus");
  $$ = $1;}
| Expr Plus Expr                                      {
  add_child($2, $1);
  add_child($2, $3);
  $2->set_type("cal-double");
  $$ = $2;}
| Expr Minus Expr                                   {
  add_child($2, $1);
  add_child($2, $3);
  $2->set_type("cal-double");
  $$ = $2;}
| Expr Mult Expr                                      {
  add_child($2, $1);
  add_child($2, $3);
  $2->set_type("cal-double");
  $$ = $2;}
| Expr Div Expr                                        {
  add_child($2, $1);
  add_child($2, $3);
  $2->set_type("cal-double");
  $$ = $2;}
| Expr Mod Expr                                     {
  add_child($2, $1);
  add_child($2, $3);
  $2->set_type("cal-double");
  $$ = $2;}
;

x 
: Variable                                                   {$$ = $1;$$->basic->type = "variable";}
;
        

%%
int main(int argc,char**argv){
  //打开要读取的文本文件
  //const char* sFile="1.c";
  const char *inFile = argv[1];
  string outTxt = argv[2];//"1_result.txt"
  string outS = argv[3];//"1_code.S"
	FILE* fp=fopen(inFile, "r");
	if(fp==NULL)
	{
		printf("cannot open %s\n", inFile);
		return -1;
	}
  //yyin和yyout都是FILE*类型
	extern FILE* yyin;	
  //yacc会从yyin读取输入，yyin默认是标准输入，这里改为磁盘文件。yacc默认向yyout输出，可修改yyout改变输出目的
	yyin=fp;
 ofstream outfile(outTxt,ios::app), outCompile(outS,ios::app);

  // 词法、语法分析
	printf("\n\n-------------------------begin parsing %s-------------------------\n\n", inFile);
	yyparse();//使yacc开始读取输入和解析，它会调用lex的yylex()读取记号
	puts("------------------------------end parsing------------------------------\n");
  fclose(fp);
  
  // 编号
  order(root);
  puts("------------------------------end marking------------------------------\n");

  // 给所有的变量设置类型，检查变量未声明、重声明错误
  setIdType(root);
  puts("------------------------id type check finished------------------------\n");
  cout << "---------------------------------------- tree ----------------------------------------\n";
  // 表头
  cout << " No |" << setw(15) << left << "yacc type" << "|" << setw(20) << left << "value" << "|" << setw(50) << left << "Child" << endl;
  // 输出文件
  // 打印语法树
  printTree(root,outfile);
  outfile << "--------------------------------------------------\n";
  //outfile.close();
  cout << "---------------------------------------- End tree----------------------------------------\n";
  cout << "---------------------------------------- idList ----------------------------------------" << endl;
  printIdList(root);
  cout << ">>>end of the idList<<<" << endl;
  globalChain->listArea = "total";
  globalChain->display();
  cout << "---------------------------------------- End List ----------------------------------------" << endl;


  // 类型错误检查，检查运算对象合法性、输入输出参数类型
  typeCheck(root);
  cout << "------------------------------typeCheck Finished ------------------------------" << endl;
  cout << "---------------------------------------- tree ----------------------------------------\n";
  // 表头
  cout << " No |" << setw(15) << left << "yacc type" << "|" << setw(20) << left << "value" << "|" << setw(50) << left << "Child" << endl;
  // 打印语法树
  printTree(root,outfile);
  outfile.close();
  cout << "---------------------------------------- End tree----------------------------------------\n";
  // 打印符号单链表
  cout << "---------------------------------------- idList ----------------------------------------" << endl;
  printIdList(root);
  cout << ">>>end of the idList<<<" << endl;
  globalChain->listArea = "total";
  globalChain->display();
  cout << "---------------------------------------- End List ----------------------------------------" << endl;
  cout << "------------------------------------------ code ------------------------------------------" << endl;
  gen_code(root, outCompile);
  
	return 0;
}

void yyerror(const char* s) {
	fprintf (stderr , "Parse error : %s\n", s );
	exit (1);
}