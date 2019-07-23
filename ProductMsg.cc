/**************************************************************************/
/**************************************************************************/
/*                                                                        */
/* Ce programme permet d'implanter un processus producteur                */
/*                                                                        */
/*                                                                        */
/**************************************************************************/
/**************************************************************************/
#include <unistd.h>
#include "../libc++/msglib.h"
#include <stdio.h>

 
main()
{ 
   struct msgbuf 
   {
      long mtype;
      long toto;
      char test[20];
      char mtext[80];
   } message; 

  
   key_t key_porte = 99887766; 
   Port Port1(key_porte);

   message.mtype = 1;

   for ( int i = 0; i < 20; i++ )
   { 
      sprintf(message.mtext,"Automobile %d",i);
      printf( "'J'ai produit %s'\n" , message.mtext ); 
      Port1.Envoie(&message,104);
      usleep(10);
   }  
}
