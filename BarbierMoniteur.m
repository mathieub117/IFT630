global Variables
	const NB_CHAISES := 2
	const NB_CLIENTS_MAX := 4

	const TEMPS_MAX_RETOUR := 5000

	const TEMPS_ENTRER := 3000

	const TEMPS_COIFFURE := 15000

	const TEMPS_DEPLACEMENT := 5000

	var nbClients: int := 0
	var nbIteration: int
end

_monitor(MoniteurBarbier)
    import Variables

    op TraiterClient()
    op SeFaireCoiffer(i: int)
    op AllerChezBarbier(i: int)
    op StartBarbier()
    op StartClients(i: int)
    op Start()

_body(MoniteurBarbier)

    _condvar(seDeplace)
	_condvar(porteEntree)
	_condvar(porteSortie)
	_condvar(nbClient)
	_condvar(dormir)
	_condvar(clientSurChaise)
	_condvar(seFaireCoiffer)
	_condvar(attendreChaise)
	_condvar(clientSortit)

	_proc (TraiterClient())
		_signal(attendreChaise)		
		_wait(clientSurChaise)

		write("Le barbier coiffe le client.")
		nap(Variables.TEMPS_COIFFURE)
		write("La coiffure est terminé.")

		write("Le barbier attend que personne se déplace.")
		_wait(seDeplace)
		write("Le barbier marche jusqu'à la porte de sortie.")
		nap(Variables.TEMPS_DEPLACEMENT)
		_signal(seDeplace)
		write("Le barbier ouvre la porte pour que le client sorte.")
		_wait(porteSortie)
		_signal(seFaireCoiffer)
		_wait(clientSortit)
		_signal(porteSortie)

		write("Le barbier attend que personne se déplace.")
		_wait(seDeplace)
		write("Le barbier retourne à son poste de travail.")
		nap(Variables.TEMPS_DEPLACEMENT)
		write("Le barbier est de retour à son poste de travail.")
		_signal(seDeplace)

		_wait(nbClient)
		nbClients--
		_signal(nbClient)
	_proc_end

	_proc (SeFaireCoiffer(i))
		_wait(attendreChaise)
		write("Le barbier fait signe au client", i, "de venir s'asseoir")
		write("Client", i, "attend que personne ne se deplace.")
		_wait(seDeplace)
		write("Client", i, "se dirige vers la chaise du barbier.")
		nap(Variables.TEMPS_DEPLACEMENT)
		_signal(seDeplace)
		write("Le client", i, "est assis sur la chaise du barbier.")
		_signal(clientSurChaise)
		_wait(seFaireCoiffer)
		write("Client", i, "attend que personne ne se deplace.")
		_wait(seDeplace)
		write("Client", i, "se dirige vers la porte de sortie.")
		nap(Variables.TEMPS_DEPLACEMENT)
		_signal(seDeplace)
		nap(Variables.TEMPS_ENTRER)
		_signal(clientSortit)
		write("Client", i, "est sortie.")
	_proc_end

	_proc (AllerChezBarbier(i))
		_wait(porteEntree)
		nap(Variables.TEMPS_ENTRER)
		_signal(porteEntree)
		write("Client", i, "est entré.")

		_wait(nbClient)
		if nbClients = 0 ->
			write("Client", i, "attend que personne ne se deplace.")
			_wait(seDeplace)
			write("Client", i, "se dirige vers les chaises.")
			nap(Variables.TEMPS_DEPLACEMENT)
			_signal(seDeplace)
			write("Client", i, "prend une place.")
			nbClients++
			_signal(nbClient)
			write("Le client réveille le barbier.")
			_signal(dormir)
			call SeFaireCoiffer(i)	

		[] nbClients != NB_CHAISES ->
			write("Client", i, "attend que personne ne se deplace.")
			_wait(seDeplace)
			write("Client", i, "se dirige vers les chaises.")
			nap(Variables.TEMPS_DEPLACEMENT)
			_signal(seDeplace)
			write("Client", i, "prend une place.")
			nbClients++
			_signal(nbClient)
			call SeFaireCoiffer(i)

		[] else ->
			_signal(nbClient)
			write("Il n'y a pas de place pour le client ", i, ".")
			write("Client", i, "attend que personne ne se deplace.")
			_wait(seDeplace)
			write("Client", i, "se dirige vers la porte de sortie.")
			nap(Variables.TEMPS_DEPLACEMENT)
			_signal(seDeplace)
			write("Client", i, "attend que personne n'utilise la porte.")
			_wait(porteSortie)
			nap(Variables.TEMPS_ENTRER)
			_signal(porteSortie)
			write("Client", i, "est sortie.")
		fi
	_proc_end

	_proc (StartBarbier())
		do true ->
			_wait(nbClient)
			write("Le barbier regarde s'il y a des clients.")
			if nbClients = 0 ->
				_signal(nbClient)
				write("Il n'y a pas de client, donc le barbier s'endort.")
				_wait(dormir)
				call TraiterClient()
			[] else ->
				_signal(nbClient)
				call TraiterClient()
			fi
		od
	_proc_end

	_proc (StartClients(i))
		read(nbIteration)
		fa j := 1 to nbIteration ->
			nap(int(random(Variables.TEMPS_MAX_RETOUR)))
			call AllerChezBarbier(i)
		af
	_proc_end

	_proc (Start())
		co
			StartBarbier() // (i := 1 to variables.NB_CLIENTS_MAX) StartClients(i)
		oc
	_proc_end
_monitor_end

resource main()
	import MoniteurBarbier

	process p 
		MoniteurBarbier.Start()
	end
end