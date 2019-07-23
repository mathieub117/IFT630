global a
    const nbPhilosophe := 5
    var philosophes[nbPhilosophe]: int

    op  init()
body a
    proc init()
        fa i := 1 to nbPhilosophe ->
            philosophes[i] := 0
        af
    end

end

_monitor(pMonitor)
    import a
    op pick(i:int), release(i:int)
_body(pMonitor)
    _condvar1(eat,a.nbPhilosophe)

    _proc(pick(i))
        if a.philosophes[i] != 0 ->
              _wait(eat[i])
          fi
        a.philosophes[i] := 1;
    _proc_end

    _proc(release(i))
       if a.philosophes[i] != 0 ->
          a.philosophes[i] := 0
          _signal(eat[i])
          fi
    _proc_end
_monitor_end


resource main()
    import a
    import pMonitor
    a.init()
    process ps(i:=1 to a.nbPhilosophe-1)
        do true ->
        pMonitor.pick(i)
        pMonitor.pick(1+i mod 5)
        write("Philosopher", i, "begin to eat")
        nap(int(random())*100)
        write("Philosopher", i, "finish to eat")
        pMonitor.release(i)
        pMonitor.release(1+i mod 5)
        write("Philosopher", i, "Think")
        od
    end
  process ps5
        do true ->
          pMonitor.pick(1)
          pMonitor.pick(5)
          write("Philosopher", 5, "begin to eat")
          nap(int(random())*100)
          write("Philosopher", 5, "finish to eat")
          pMonitor.release(1)
          pMonitor.release(5)
          write("Philosopher", 5, "Think")
          od
  end
end
