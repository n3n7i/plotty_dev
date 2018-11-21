

const tagfield = collect(fieldnames(tag));



function readtags(atag::tag, xfield::Symbol, xval; collectall::Bool = false)

  if(!collectall && !any(x->x==xfield, tagfield))

    println("$xfield not in $(tagfield[:])");

    return nothing;

    end;

  taglist = tag[];

  tagstack = [atag];

  taglim = [size(atag.attach, 1)];

  tagptr = [0];

  tp_ptr = 1;

  while tp_ptr>0

    local ctag = tagptr[tp_ptr];

    local xtag;

    local zval;

    local subtag =0;

    if(ctag == 0)

      xtag = tagstack[tp_ptr];

      zval = getfield(xtag, xfield);

      (zval == xval || collectall) && push!(taglist, xtag);

      ctag += 1;

      end;

    if(ctag <= taglim[tp_ptr])

      xtag = tagstack[tp_ptr].attach[ctag];

      ctag += 1;

      tagptr[tp_ptr] = ctag;

      zval = getfield(xtag, xfield);

      (zval == xval || collectall) && push!(taglist, xtag);

      subtag = size(xtag.attach,1);

      if(ctag > taglim[tp_ptr])

        pop!(tagstack);#, xtag);

        pop!(taglim); #, subtag);

        pop!(tagptr); #, 1);

        tp_ptr -= 1;
        
        end;       
        
      if(subtag > 0)

        push!(tagstack, xtag);

        push!(taglim, subtag);

        push!(tagptr, 1);

        tp_ptr += 1;

        end;

      end;

    end;

  return taglist;

  end;
    
