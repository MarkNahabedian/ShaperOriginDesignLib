# ShaperOriginDesignLib

Being a computer programmer, I prefer describing the geometry of my
designs in code rather than via a graphical user interface.

When I first got my Shaper Origin, I was generating SVG files for it
by implementing an HTML file that contained JavaScript that
dynamically generated SVG and displayed it on the web page.  I was
fairly successful with this approach and developed a JavaScript
library to facilitate it.  The debug loop was a bit cumbersome though.
My code for this is on GitHub at
[MarkNahabedian/DesignWithSVG](https://github.com/MarkNahabedian/DesignWithSVG)

I'm now trying a different approach for my designs.  I'm writing Julia
code in a Pluto Notebook.  This allows me to edit code, immediately see
the rendering of the updated SVG, and finally copy it to a file when
I'm happy with the design.  This repository contains the julia library
of common code that facilitates this approach.

My first such design notebook -- for a plate for a floor drain -- can be
found
[here](https://github.com/MarkNahabedian/DesignWithSVG/tree/master/floor_drain).
Click through the link there to run the notebook.  It takes some time
for the notebook to load, so be patient with it.


## My Example Projects that use this

[floordrain cover plate](https://github.com/MarkNahabedian/DesignWithSVG/tree/master/floor_drain)

[End Stub Check Register Box](https://github.com/MarkNahabedian/DesignWithSVG/tree/master/end_stub_check_register_box)

[a Mounting Bracket for some Solar Lights](https://github.com/MarkNahabedian/DesignWithSVG/tree/master/solar_lights_bracket)

