#include<stdio.h>
#include<stdlib.h>
#include<string.h>
extern int display_memory();
long int getLength()
{
    FILE *fp;
    fp= fopen("program.txt","r");
    if(fp == NULL) return -1;
    fseek(fp,0L,SEEK_END);
    long int res = ftell(fp);
    fclose(fp);
    return res;
}
void getFileText(char *str)
{
    FILE *fp;
    fp = fopen("program.txt","r");
    int i =0;
    while(!feof(fp))
    {
        str[i++]=fgetc(fp);
    }
    fclose(fp);
}
void main()
{	
    long int res = getLength();
    char *str = (char*)malloc((res+1)*sizeof(char));
    char c[17];
    getFileText(str);
    int count=0;
    for(int i =0 ; i<res;i++)
    {
        if(*(str+i)!= 0) 
        {
            c[count++] = *(str+i);
        }
        if(count == 16)
        {   
	    c[count]='\0';
            display_memory(c,count);
            count=0;
	    
        }
    }
	if(count!=0)
	display_memory(c,count);
    return;
}
