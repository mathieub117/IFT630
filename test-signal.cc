#include <iostream>
#include <signal.h>

using namespace std;

void traite_signal(int);
// définition d'un type pour faciliter le traitement d'un signal 
//-------------------------------------------------------------
typedef void Sigfunc(int);
Sigfunc *signal(int,Sigfunc *);

//-------------------------------------------------------------
// Routine qui provoque une division par zéro
//-------------------------------------------------------------
void divZero(int b)
{ 

   int a,c;
	a = 1; 
   
   cout << "on divise par " << b << endl;
	c = a/b;
   cout << "apres" << c << endl;
}

//-------------------------------------------------------------
// Routine qui provoque une erreur d'adressage
//-------------------------------------------------------------
void erreurAdressage(int * b)
{ 

   int a,c;
	 
   if (signal(SIGSEGV,traite_signal) == SIG_ERR)
	cout << "erreur dans initialisation" << endl;

   cout << "on addresse a " << b << endl;
	c = *b;
   cout << "apres" << c << endl;
}

//-------------------------------------------------------------
// Routine qui traite les signaux d'erreur
//-------------------------------------------------------------
void traite_signal(int no)
{
  void suite();

  
  if (no==SIGBUS)
     cout << "Il y a eu bus erreur" << endl;
  else if (no==SIGSEGV) 
     cout << "Il y a eu une erreur d'adressage" << endl;
  else if (no==SIGILL)
     cout << "Il y a eu une instruction illegale" << endl;
  else if (no==SIGFPE)
  {
     cout << "Il y a eu une division par zero" << endl<< endl;
     cout << "On teste un adressage illégal " << endl;
     erreurAdressage(0);
  }  

  exit(0);
}



//-------------------------------------------------------------
// Routine qui traite les signaux du Crtl-c
//-------------------------------------------------------------
void controlc(int no)
{
   static int nb_INT = 0;
   if (no==SIGINT) 
   {   nb_INT ++;
       if (nb_INT < 5)
       {
          cout << "SIGNAL " << SIGINT << " : Il y a eu un crtl-c, je ne termine pas " << endl; 
          // on réinitialise le signal
          if (signal(SIGINT,SIG_IGN) != SIG_IGN)
	       signal(SIGINT,controlc) ;
       }
       else 
       {
           cout << "SIGNAL " << SIGINT << " : Il y a eu 5 crtl-c, on termine  -- Bye" << endl; 
           exit(0);
       }
   }
}

//-------------------------------------------------------------
// Routine qui traite les signaux du Crtl-z
//-------------------------------------------------------------
void suspendre(int no)
{
   if (no==SIGTSTP) 
   {
       cout << "SIGNAL " << SIGTSTP << " : Non-- je ne veux pas etre suspendu (Crtl -z)" << endl; 
       // on réinitialise le signal
       signal(SIGTSTP,suspendre) ;
   }
}

//-------------------------------------------------------------
// Routine qui traite divers signaux 
//-------------------------------------------------------------
void mykill(int no)
{
   if (no==SIGUSR1) 
   {
       cout << "SIGNAL " << SIGUSR1 << "Il y a eu un kill SIGUSR1, je ne termine pas" << endl; 
       // on réinitialise le signal
       signal(SIGUSR1,mykill) ;
   }
   else if (no==SIGUSR2) 
   {
       cout << "SIGNAL " << SIGUSR2 << "Il y a eu un kill SIGUSR2, On teste les erreurs" << endl; 

       cout << "test division par zéro" << endl;
       divZero(0);
       
   }
   else if (no==SIGABRT) 
   {
       cout << "SIGNAL " << SIGABRT << "Il y a eu un kill -6, je ne termine pas" << endl; 
       // on réinitialise le signal
       signal(SIGABRT,mykill) ;
   }
   else if (no==SIGTERM) 
   {
       cout << "SIGNAL " << SIGTERM << "Il y a eu un kill -TERM, je ne termine pas" << endl; 
       // on réinitialise le signal
       signal(SIGTERM,mykill) ;
   }
   else if (no==SIGHUP) 
   {
       cout << "SIGNAL " << SIGHUP  << "Il y a eu un kill -1 (hangup), je ne termine pas" << endl; 
       // on réinitialise le signal
       signal(SIGHUP,mykill) ;
   }
   else if (no==SIGQUIT) 
   {
       cout << "SIGNAL " << SIGQUIT << "Il y a eu un quit, je ne termine pas" << endl; 
       // on réinitialise le signal
       signal(SIGQUIT,mykill) ;
   }
   else if (no==SIGILL) 
   {
       cout << "SIGNAL " << SIGILL << "Il y a eu une instruction illegale, on continue" << endl; 
       // on réinitialise le signal
       signal(SIGILL,mykill) ;
   }
}


/*****************************************************************************
*  On teste les signaux....
******************************************************************************/

int main()
{ 
     int b=0;
    
     if (signal(SIGFPE,traite_signal) == SIG_ERR)
         cout << "erreur dans initialisation" << endl;
     if (signal(SIGSEGV,traite_signal) == SIG_ERR)
         cout << "erreur dans initialisation" << endl;
     if (signal(SIGILL,mykill) == SIG_ERR)
         cout << "erreur dans initialisation" << endl;
     cout << "_____________________________________________________________________" << endl;
     cout << "                      T E S T S  " << endl;
     cout << "------------------------------------------------------------" << endl;
     cout << "Dans la fenêtre du programme : Crtl-c ou  Crtl-z. " <<endl;
     cout << "   (pour arrêter le programme directement faites 5 Crtl-c)" <<endl;
     cout << "------------------------------------------------------------" << endl;
     cout << "Dans une autre fenêtre  " <<endl;
     cout << " ------- Kill -noSignal IdProcessus " <<endl<<endl;
     cout << "Les signaux utiles pour les tests sont : " <<endl;
     cout << "	 SIGHUP  1  : hangup	     ---  SIGINT  2  : interrupt" <<endl;
     cout << "	 SIGQUIT 3  : quit	     ---  SIGILL  4  : illegal instruction " <<endl;
     cout << "	 SIGBUS  10 : bus error      ---  SIGSEGV 11 : segmentation violation " <<endl;
     cout << "	 SIGTERM 15 : termination    ---  SIGSTOP 17 : stop signal" <<endl;
     cout << "	 SIGTSTP 18 : stop signal    ---  SIGCHLD 20 : stop (Crtl-z) " <<endl;
     cout << "	 SIGXCPU 24 : CPU time limit ---  SIGXFSZ 25 : file size limit " <<endl;
     cout << "	 ------ " <<endl;
     cout << "	 SIGUSR1 30 : (ne fait rien) " <<endl;
     cout << "	 ------ " <<endl;
     cout << "	 SIGUSR2 31 : demarre le test des erreurs " <<endl ;
     cout << "	 SIGKILL 9  : kill (arrêt force du programme) " <<endl;
     cout << "_____________________________________________________________________" << endl;


     signal(SIGUSR1,mykill) ;
     signal(SIGUSR2,mykill) ;
     signal(SIGABRT,mykill) ;
     signal(SIGTERM,mykill) ;
     signal(SIGHUP,mykill) ;
     signal(SIGTSTP,suspendre) ;
     if (signal(SIGINT,SIG_IGN) != SIG_IGN)
     	  signal(SIGINT,controlc) ;
     if (signal(SIGQUIT,SIG_IGN) != SIG_IGN)
     	  signal(SIGQUIT,mykill) ;

    while(1) ;

} 
  


