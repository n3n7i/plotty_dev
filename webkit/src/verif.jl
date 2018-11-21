

#const tagfield = collect(fieldnames(tag));


function cyclic_check(atag::tag, xtaglist::Array{tag})

  return any(x->x===atag, xtaglist)

  end;



function verifytags(atag::tag)

  taglist = tag[];

  tagstack = [atag];

  taglim = [size(atag.attach, 1)];

  tagptr = [0];

  tp_ptr = 1;

  itercount = 1;

  while tp_ptr>0

    local ctag = tagptr[tp_ptr];

    local xtag;

    local zval;

    local subtag =0;

    if(ctag == 0)

      xtag = tagstack[tp_ptr];

      ctag += 1;

      ctag > taglim[1] && return tag[];

      end;

    if(ctag <= taglim[tp_ptr])

      xtag = tagstack[tp_ptr].attach[ctag];

      ctag += 1;

      tagptr[tp_ptr] = ctag;

      subtag = size(xtag.attach,1);

      if(subtag > 0 && cyclic_check(xtag, tagstack))

        append!(taglist, [tagstack[tp_ptr]; xtag]);

        subtag = 0;

        end;
              
      if(subtag > 0)

        push!(tagstack, xtag);

        push!(taglim, subtag);

        push!(tagptr, 1);

        tp_ptr += 1;

        ctag = 1;

        end;

      end;


    if(ctag > taglim[tp_ptr])

      pop!(tagstack);#, xtag);

      pop!(taglim); #, subtag);

      pop!(tagptr); #, 1);

      tp_ptr -= 1;
        
      end;       

    end;

  return taglist;

  end;
    
