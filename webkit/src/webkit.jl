
module webkit

  export tag, page, tag_table;

  ##greet() = print("Hello World!")

  mutable struct tag;

    name::Symbol;
    pairs::Bool;
    attrib::NamedTuple;
    attach::Array{tag};
    text::String;
    end;


  mutable struct page;

    doctype::tag;
    head::tag;
    body::tag;
    end;

## def

  tag(text::String) = 			  tag(:empty, false, NamedTuple(), [], text);

  tag(name::Symbol) = 			  tag(name, false, NamedTuple(), [], "");

  tag(name::Symbol, pairs::Bool) = 	  tag(name, pairs, NamedTuple(), [], "");

  tag(name::Symbol, text::String) = 	  tag(name, true, NamedTuple(), [], text);

  tag(name::Symbol, attach::Array{tag}) = tag(name, true, NamedTuple(), attach, "");

  tag(name::Symbol, attach::tag) = 	  tag(name, true, NamedTuple(), [attach], "");

  tag(name::Symbol, attrib::NamedTuple) = tag(name, true, attrib, [], "");


  tag(parent::tag, child::tag) = 	  push!(parent.attach, child);

  tag(parent::tag, childr::Array{tag}) =  append!(parent.attach, childr);

  
  tag!(target::tag, attr::NamedTuple) = (target.attrib = attr; nothing);
  
  tag!(target::tag, xtext::String) = (target.text = xtext; nothing);
  
  
  
  schema_patch(z::Array{NamedTuple{Z, T}, N}) where{Z, T, N} = Z; 

  schema_patch(z::Array{NamedTuple{Z}}) where{Z} = Z; 



  function page(;doctype::tag = tag("<!DOCTYPE html><html>"), head::tag = tag(:head, true), body::tag = tag(:body, "Hello Webkit!"))

    page(doctype, head, body);

    end;


  function (x::page)(;generate = false)

    if(generate)

      io = IOBuffer();

      writetags(io, x.doctype);

      writetags(io, x.head);

      writetags(io, x.body);

      write(io, "</html>");

      return( String(take!(io)));

      end;

    nothing;

    end;
    


  ##  


# low level api

function writetags(io::IO, xtag::tag)

  if(xtag.name !== :empty)

    write(io, "<$(xtag.name)");

    for (k, v) in pairs(xtag.attrib)

      write(io, " $k = \"$v\" ");

      end

    !xtag.pairs && write(io, " /");

    write(io, ">");

    end;

  write(io, xtag.text);

  for x in xtag.attach

    writetags(io, x);

    end;

  xtag.pairs && write(io, "</$(xtag.name)>");

  xtag.pairs && length(xtag.attach)>1 && write(io, "\n");

  end



function tag_table(table, caption="")

  xtable = tag(:table, true);

  (caption !== "") && tag(xtable, tag(:caption, caption));

  xlabels = hasmethod(schema_patch, (typeof(table), )) ? schema_patch(table) : [];

  thead = tag(:thead, true);

  [tag(thead, tag(:th, "$x")) for x in xlabels];

  tbody = tag(:tbody, true);

  for (id, xrow) in enumerate(table)

    local trow = tag(:tr, true);

    for elem in values(xrow)

      tag(trow, tag(:td, "$elem"));

      end;

    tag(tbody, trow);

    end;

  tag(xtable, thead);

  tag(xtable, tbody);

  return xtable;

  end;


  include("verif.jl");
  
  include("repli.jl");
  
  include("attr.jl");


  end # module
