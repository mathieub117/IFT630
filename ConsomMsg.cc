/**************************************************************************/
/**************************************************************************/
/*                                                                        */
/* Ce programme permet d'implanter un processus consommateur              */
/*                                                                        */
/*                                                                        */
/**************************************************************************/
/**************************************************************************/
#include <unistd.h>
#include "../libc++/msglib.h"
#include <stdio.h>

main()
{ 
  key_t key_porte = 99887766;

  struct msgbuf {
         long mtype;
         long toto;
         char test[20];
         char mtext[80];
  } message;
   
  Port Port1(key_porte);

  for ( int i = 0; i < 20; i++ )
   { 
      Port1.Recoit(&message,104);
      printf( "'J'ai consomme %s'\n" ,message.mtext );
      usleep(15);
   }  
 }
