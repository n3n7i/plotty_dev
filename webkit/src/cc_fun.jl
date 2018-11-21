

function cc_unique(xtags::Array{tag})

  ccstack = tag[];

  for xtag in xtags

    if( !cyclic_check(xtag, ccstack))

      push!(ccstack, xtag);

      end;

    end;

  return ccstack;

  end;


function cc_bunch(xtags::Array{tag})

  ztags = tag[];

  for x in xtags

    append!(ztags, cc_unique(x.attach));

    end;

  return ztags;

  end;



function cc_forward(atag::tag, depth=4)

  n=0;

  xtags = cc_unique(atag.attach);

  while(n<=depth)

    if cyclic_check(atag, xtags)

      return (term = :false, depth = n);

      end;

    if size(xtags,1) == 0
 
      return (term = :true, depth = n);

      end;

    xtags = cc_bunch(xtags);

    n += 1;

    end;

  return (term = :unknown, depth = n);

  end;

