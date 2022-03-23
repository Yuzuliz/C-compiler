void main() {
  int a, s;
  a = 10;
  s = 0;
  char ch;
  scanf("%c", &ch);
  printf("%c", ch);
  while(a>0 && a<=10 || a%100==10) {//L1
    a -= 1;//L2
    a = 10;
    s += a;
    if(s > -10) {
      printf("result is: %d\n", s);//L4
      int b;
      b = 10;
      int i;
      for(i=0; i<b; i++) {//i<b L5
      printf("Have fun: %d\n", i);
      }
    }
    else{
      a++;
      printf("Have fun: \%d\n", a);
    }
  }
  return 0;//L3
}
// No more compilation error.

/*int main() {
  int a, s;
  a = + 10;
  s = 5 * 6;
  s = 8 / 4;
  s = 6 % 3;
  char ch;
  scanf("%c %d", &ch, &s );
  while(a>0 && a<=10 || a%100==10 && !a==10) {
    a -= 1;
    char a = "123";
    s += a;
    char a,c;
    k = 1;
  }
  if(-s < -10) {
    printf("\%result is: %d\n", s);
    int b;
    b = 10;
  }
  else{
    printf("123456\n");
  }
  for(int i=0; ; i++) {
    printf("Have fun: %d %d\n", i,s);
  }
  //test
  return a+1;
}


// No more compilation error.

int main(){
  int a;
  scanf("%d",&a);
  printf("%d",a);
	return 0;
}*/