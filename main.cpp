#include "main.h"
void Node::add_child(Node* c){
    if(child == NULL){
      child = c;
      /*if(type == UNREADABLE){
        No = c->No;
      }*/
    }
    else{
      Node* temp;
      for(temp = child ; temp->bro != NULL && temp ; temp = temp->bro);
      if(temp && !temp->bro){
        temp->bro = c;
      }
    }
};