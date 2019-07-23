/*
m2sr -sw ParcMoniteur.m
sr -o NomFichier ParcMoniteur.sr
./NomFichier
*/

global parc
    const NOMBRE_TOURS_PISTE := 5
    const TEMPS_TOURS_PISTE := 1000
    const NOMBRE_PASSAGERS_VOITURE := 5
    const MULTIPLICATEUR := 3
    const NOMBRE_PERSONNES := NOMBRE_PASSAGERS_VOITURE * MULTIPLICATEUR + 2

    op AfficherPersonnePassager(i,j:int)
body parc
    proc AfficherPersonnePassager(i,j)
        write("La Personne #",i, "A entré dans le siège #",j)
    end
end

_monitor(parcMonitor)
    import parc

    var personneDansVoiture := 0
    var index := 0

    op PartirVoiture(), AjouterPassager(i:int)
_body(parcMonitor)
    _condvar1(personne,parc.NOMBRE_PERSONNES)

    _proc(PartirVoiture())
	fa tp := 1 to parc.NOMBRE_TOURS_PISTE ->
            nap(parc.TEMPS_TOURS_PISTE)
            write("Tour", tp)
        af
	index := index mod parc.NOMBRE_PERSONNES
        fa i := 1 to parc.NOMBRE_PASSAGERS_VOITURE ->
	    if ((i+index) mod parc.NOMBRE_PERSONNES) != 0 ->
	        _signal(personne[(i+index) mod parc.NOMBRE_PERSONNES])
	    [] else ->
		_signal(personne[parc.NOMBRE_PERSONNES])
	    fi
        af
	personneDansVoiture := 0
    _proc_end

    _proc(AjouterPassager(i))
        if personneDansVoiture != parc.NOMBRE_PASSAGERS_VOITURE ->
	    _signal(personne[i])
	    personneDansVoiture++
	    index++
            parc.AfficherPersonnePassager(i, personneDansVoiture)
        [] else ->
            _wait(personne[i])
        fi
    _proc_end
_monitor_end


resource main()
    import parc
    import parcMonitor

    process personne(i := 1 to parc.NOMBRE_PERSONNES)
	do true ->
	    parcMonitor.AjouterPassager(i)
	    nap((parc.TEMPS_TOURS_PISTE))
	od
    end

    process voiture
        do true ->
	    if parcMonitor.personneDansVoiture = parc.NOMBRE_PASSAGERS_VOITURE ->
		parcMonitor.PartirVoiture()
	    fi
        od
    end
end
