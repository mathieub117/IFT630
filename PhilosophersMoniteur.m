global p
    const nbPhilosophe := 5
    const round := 10
    type state = enum(Think, Hungry, Eat)
    var philosophes[nbPhilosophe]: state
    var baguettesPicked[nbPhilosophe]: bool

    op printPhilosophe(philosopher:int), init()
    op printValue(s:state) returns r: string[6]
body p
    proc init()
        fa i := 1 to nbPhilosophe ->
            philosophes[i] := Think
            baguettesPicked[i]:= false
            printPhilosophe(i)
        af
    end

    proc printPhilosophe(i)
        write("Philosopher", i, printValue(philosophes[i]))
    end

    proc printValue(s) returns r
        if s = Think -> r := "Think" fi
        if s = Hungry -> r := "Hungry" fi
        if s = Eat -> r := "Eat" fi
    end
end

_monitor(pMonitor)
    import p
    op pickBaguettes(i:int), dropBaguettes(i:int)
_body(pMonitor)
    _condvar1(eat,p.nbPhilosophe)

    _proc(pickBaguettes(i))
        p.philosophes[i] := Hungry
        p.printPhilosophe(i)
        if p.baguettesPicked[i] = false ->
          if p.baguettesPicked[1 + i mod 5] = false ->
            if p.philosophes[i] = Hungry ->
               p.philosophes[i] := Eat
               p.printPhilosophe(i)
               baguettesPicked[i] := true
               baguettesPicked[1 + i mod 5] := true
               nap(int(random()*1000))
               _signal(eat[i])
              fi
            fi
          fi
        if p.philosophes[i] != Eat ->
            _wait(eat[i])
        fi
    _proc_end

    _proc(dropBaguettes(i))
        p.philosophes[i] := Think
        p.printPhilosophe(i)
        baguettesPicked[i] := false
        baguettesPicked[1 + i mod 5] := false
        _signal(eat[i])
    _proc_end
_monitor_end


resource main()
    import p
    import pMonitor

    p.init()

    process ps(i:=1 to p.nbPhilosophe)
        fa k := 0 to p.round ->
            pMonitor.pickBaguettes(i)
            pMonitor.dropBaguettes(i)
            k++
        af
    end
end
