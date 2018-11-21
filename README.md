# plotty_dev
semi-functional webgl render @ localhost

#Basic Demo

cd("plotty")

include("initplotty.jl")

asciiServer.taskport();    ## init localserver

s1 = bezPlain.n3bezier.point3d([1 2 3.0], [1;2;3.0], 3.0); ##surface control

pvec = collect(0:0.05:1);    ##point control

z1 = bezPlain.n3bezier.bqgon(collect.(s1)..., pvec', pvec); ##pointgen

(a,b) = bezPlain.n3bezier.collectmaps([z1]); ([##], 3)  ## array shape formatting

xstr = htmlPlot("", a,b, true, "T");     ##htmlgen

asciiServer.cgSet(xstr); ## file is served, visit localhost:8088/Graph 
