/**************************************************************************/
/**************************************************************************/
/*                                                                        */
/* Ce programme permet de creer un processus consommateur et producteur   */
/*                                                                        */
/*                                                                        */
/**************************************************************************/
/**************************************************************************/

#include "../libc++/pcslib.h"
#include "../libc++/msglib.h"

main()
{  
   key_t key_porte = 99887766;

   Port Porte(key_porte);

   Pcs PcsProduct((char *)"ProductMsg");
   Pcs PcsConsom ((char *)"ConsomMsg");

   PcsProduct.Join();
   PcsConsom.Join();

   Porte.Detruit();
 }
