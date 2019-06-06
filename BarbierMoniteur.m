global Variables
	const NB_CHAISES := 2

	const NB_CLIENTS_MAX := 4

	const TEMPS_MAX_RETOUR := 5000

	const TEMPS_ENTRER := 3000

	const TEMPS_COIFFURE := 15000

	const TEMPS_DEPLACEMENT := 5000
end

_monitor(ClientNumberVar)
	import Variables

	op Increment()
	op Decrement()
	op IsBarberShopEmpty() returns bool
	op IsBarberShopFull() returns bool
_body(ClientNumberVar)
	var nbClients: int := 0

	_proc(Decrement())
		nbClients--
	_proc_end

	_proc(Increment())
		nbClients++
	_proc_end

	_proc(IsBarberShopEmpty() returns result)
		if nbClients=0 ->
			result := true
		[] else ->
			result := false
		fi
	_proc_end

	_proc(IsBarberShopFull() returns result)
		if nbClients=Variables.NB_CHAISES ->
			result := true
		[] else ->
			result := false
		fi
	_proc_end
_monitor_end

_monitor(Deplacement)
	import Variables
    
	op BarbierVersLaSortie()
	op BarbierVersSonPoste()
	op ClientVersLaSortie(i: int)
	op ClientVersChaises(i: int)
	op ClientVersBarbier(i: int)
_body(Deplacement)
	var plancherOccuper: int := 0
	_condvar(seDeplace)

	_proc (BarbierVersLaSortie())
		write("Le barbier attend que personne se déplace.")
		if plancherOccuper=1 ->
			_wait(seDeplace)
		fi
		plancherOccuper:=1
		write("Le barbier marche jusqu'à la porte de sortie.")
		nap(Variables.TEMPS_DEPLACEMENT)
		plancherOccuper:=0
		_signal(seDeplace)
	_proc_end

	_proc (BarbierVersSonPoste())
		write("Le barbier attend que personne se déplace.")
		if plancherOccuper=1 ->
			_wait(seDeplace)
		fi
		plancherOccuper:=1
		write("Le barbier retourne à son poste de travail.")
		nap(Variables.TEMPS_DEPLACEMENT)
		write("Le barbier est de retour à son poste de travail.")
		plancherOccuper:=0
		_signal(seDeplace)
	_proc_end

	_proc (ClientVersLaSortie(i))
		write("Client", i, "attend que personne ne se deplace.")
		if plancherOccuper=1 ->
			_wait(seDeplace)
		fi
		plancherOccuper:=1
		write("Client", i, "se dirige vers la porte de sortie.")
		nap(Variables.TEMPS_DEPLACEMENT)
		plancherOccuper:=0
		_signal(seDeplace)
	_proc_end

	_proc (ClientVersChaises(i))
		write("Client", i, "attend que personne ne se deplace.")
		if plancherOccuper=1 ->
			_wait(seDeplace)
		fi
		plancherOccuper:=1
		write("Client", i, "se dirige vers les chaises.")
		nap(Variables.TEMPS_DEPLACEMENT)
		plancherOccuper:=0
		_signal(seDeplace)
		write("Client", i, "prend une place.")
	_proc_end

	_proc (ClientVersBarbier(i))
		write("Le barbier fait signe au client", i, "de venir s'asseoir")
		write("Client", i, "attend que personne ne se deplace.")
		if plancherOccuper=1 ->
			_wait(seDeplace)
		fi
		plancherOccuper:=1
		write("Client", i, "se dirige vers la chaise du barbier.")
		nap(Variables.TEMPS_DEPLACEMENT)
		plancherOccuper:=0
		_signal(seDeplace)
		write("Le client", i, "est assis sur la chaise du barbier.")
	_proc_end
_monitor_end

_monitor(InteractionBarbierClients)
    import ClientNumberVar
    import Deplacement
    import Variables

    op Dormir()
    op ReveillerBarbier()
    op TraiterClient()
    op SeFaireCoiffer(i: int)
    op SortirClient()
    op ClientUtiliserPorteAvant(i: int)
	op ClientUtiliserPorteArriere(i: int)
	op BarbierUtiliserPorteArriere()
_body(InteractionBarbierClients)

	var porteSortieUtilise := 0
	var porteEntreeUtilise := 0

	_condvar(porteEntree)
	_condvar(porteSortie)
	_condvar(dormir)
	_condvar(clientSurChaise)
	_condvar(seFaireCoiffer)
	_condvar(attendreChaise)
	_condvar(clientSortit)

	_proc(SortirClient())
		_signal(seFaireCoiffer)
		_wait(clientSortit)
	_proc_end

	_proc (TraiterClient())
		_signal(attendreChaise)
		_wait(clientSurChaise)

		write("Le barbier coiffe le client.")
		nap(Variables.TEMPS_COIFFURE)
		write("La coiffure est terminé.")

		Deplacement.BarbierVersLaSortie()
		BarbierUtiliserPorteArriere()
		Deplacement.BarbierVersSonPoste()

		ClientNumberVar.Decrement()
	_proc_end

	_proc (SeFaireCoiffer(i))
		_wait(attendreChaise)
		Deplacement.ClientVersBarbier(i)
		_signal(clientSurChaise)
		_wait(seFaireCoiffer)
		Deplacement.ClientVersLaSortie(i)
		nap(Variables.TEMPS_ENTRER)
		_signal(clientSortit)
		write("Client", i, "est sortie.")
	_proc_end

	_proc (Dormir())
		write("Il n'y a pas de client, donc le barbier s'endort.")
		_wait(dormir)
	_proc_end

	_proc (ReveillerBarbier())
		write("Le client réveille le barbier.")
		_signal(dormir)
	_proc_end

	_proc(ClientUtiliserPorteArriere(i))
		write("Client", i, "attend que personne n'utilise la porte.")
		if porteSortieUtilise=1 ->
			_wait(porteSortie)
		fi
		porteSortieUtilise := 1
		nap(Variables.TEMPS_ENTRER)
		porteSortieUtilise := 0
		_signal(porteSortie)
		write("Client", i, "est sortie.")
	_proc_end

	_proc(ClientUtiliserPorteAvant(i))
		if porteEntreeUtilise=1 ->
			_wait(porteEntree)
		fi
		porteEntreeUtilise := 1
		nap(Variables.TEMPS_ENTRER)
		porteEntreeUtilise := 0
		_signal(porteEntree)
		write("Client", i, "est entré.")
	_proc_end

	_proc(BarbierUtiliserPorteArriere())
		write("Le barbier ouvre la porte pour que le client sorte.")
		if porteSortieUtilise=1 ->
			_wait(porteSortie)
		fi
		porteSortieUtilise := 1
		InteractionBarbierClients.SortirClient()
		porteSortieUtilise := 0
		_signal(porteSortie)
	_proc_end
_monitor_end

resource main()
	import Variables
	import InteractionBarbierClients
	import Deplacement
	import ClientNumberVar

	procedure AllerChezBarbier(i: int)
		InteractionBarbierClients.ClientUtiliserPorteAvant(i)

		if ClientNumberVar.IsBarberShopEmpty() ->
			ClientNumberVar.Increment()
			Deplacement.ClientVersChaises(i)
			InteractionBarbierClients.ReveillerBarbier()
			InteractionBarbierClients.SeFaireCoiffer(i)	

		[] ClientNumberVar.IsBarberShopFull() != true ->
			ClientNumberVar.Increment()
			Deplacement.ClientVersChaises(i)
			InteractionBarbierClients.SeFaireCoiffer(i)

		[] else ->
			write("Il n'y a pas de place pour le client ", i, ".")
			Deplacement.ClientVersLaSortie(i)
			InteractionBarbierClients.ClientUtiliserPorteArriere(i)
		fi
	end

	process Barbier 
		do true ->
			write("Le barbier regarde s'il y a des clients.")
			if ClientNumberVar.IsBarberShopEmpty() ->
				InteractionBarbierClients.Dormir()
			fi
			nap(10)
			InteractionBarbierClients.TraiterClient()
		od
	end

	process clients(i := 1 to Variables.NB_CLIENTS_MAX) 
		do true ->
			nap(int(random(Variables.TEMPS_MAX_RETOUR)))
			call AllerChezBarbier(i)
		od
	end
end
