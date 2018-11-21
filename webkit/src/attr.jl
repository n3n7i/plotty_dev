

function SrcAttr(val)
  return (src = val, );
  end;
  
function HrefAttr(val)
  return (href = val, );
  end;
  

function grabTags(root::tag, name::Symbol)
  i = 0;
  list = [];
  for x in root.attach    
    z = x;
    if(x.name !== name)
	  for y in x.attach
	    if(y.name == name)
	      push!(list, y);
		  end;
		end;
	  end;
	if(x.name == name)
      push!(list, x);
	  end;
	end;
  return list;
  end;
  
  
function setTags(xlist, xvals)

  size(xlist,1) == size(xvals, 1) && tag!.(xlist, xvals);
  
  end;
  
  