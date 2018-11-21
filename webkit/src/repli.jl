

function reptag!(atag::tag, rtag::tag, repcount)

  tag(atag, fill(rtag, repcount));

  end;



function reptag!(taglist::Array{tag}, replist::Array{Int})

  n = size(replist,1);

  n2 = size(taglist,1)

  if(n!=n2 || replist[1]!= 1)

    println("$(n) != $(n2) || replist[1] != 1");

    return [];

    end;

  for iter = n2:-1:2

    reptag!(taglist[iter-1], taglist[iter], replist[iter]);

    ##tag(taglist[iter-1], fill(taglist[iter], replist[iter]));

    end;

  end;


function clonetag(atag::tag)

  return tag(atag.name, atag.pairs);

  end;


##function cyclic_check(atag::tag, xtaglist::Array{tag})

##  return any(x->x===atag, xtaglist)

##  end;


function cc_nodes(xnodelist, xnodeptr)

  znode = [];

  i = xnodeptr;

  while(i>0)

    push!(znode, i);

    i = xnodelist[i];

    end;

##  println(znode);

  return znode;

  end;


function cc_mode(xptr, xtag, xlist, ccstack, xnodes)

  if( !cyclic_check(xtag, ccstack))

    push!(ccstack, xtag);

    return false;

    end;

  xid = findfirst(x->x===xtag, ccstack);

  ##if(ccti[xid] == 2)

##  xvar = xlist[cc_nodes(xnodes, xptr)];

  ##println([x.name for x in xvar]);
 
  return cyclic_check(xtag, xlist[cc_nodes(xnodes, xptr)]);

  end;



function dereptags(atag::tag)

  taglist = tag[atag];

  clonelist = tag[];

  nodelist = [0];

  cctagstack = [atag];

##  cctagcount = [1];

  tagptr = 1;

  itercount = 1;

  while tagptr <= itercount ##tp_ptr>0

    local ctag = nodelist[tagptr]; ##tagptr[tp_ptr];

    local xtag;

    if(ctag == 0)

      xtag = taglist[tagptr];

      push!(clonelist, clonetag(xtag));

      m = size(xtag.attach,1);

      append!(taglist, xtag.attach);

      append!(nodelist, fill(tagptr, m));

      itercount += m;

      tagptr += 1;

      tagptr > itercount && return clonelist[1];

      ctag = nodelist[tagptr];

      end;

    if(!cc_mode(ctag, taglist[tagptr], taglist, cctagstack, nodelist))

      xtag = clonetag(taglist[tagptr]); ##.attach[ctag];

      tag(clonelist[nodelist[tagptr]], xtag);

      push!(clonelist, xtag);

      m = size(taglist[tagptr].attach,1);

      append!(taglist, taglist[tagptr].attach);

      append!(nodelist, fill(tagptr, m));

      itercount += m;

      end;

    tagptr += 1;

    end;

  return clonelist[1];

  end;
    

