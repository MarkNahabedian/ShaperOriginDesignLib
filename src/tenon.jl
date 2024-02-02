export tenon


"""
    tenon(tenon_length, cutter_diameter,
          tenon_i, tenon_j, stock_i, stock_j, extra)

..._i and ..._j are the dimensions along each of two axes (looking at
the stock end on) of the tenon itself and the end of the stock.

Defines an outside cut for the rectangular tenon and a pocket cut for
the rest of the stock.

`cutter_diameter` is for the cutter that will be used for the mortise,
so the tenon can be rounded to match.

The tenon is centered on the stock.

The coordinate 0, 0 is at the top left corner of the stock.

`extra` is how much bigger the pocket cut outline should be beyond the
stock itself.  It defaults to `cutter_diameter`.
"""
function tenon(tenon_length, cutter_diameter,
               tenon_i, tenon_j, stock_i, stock_j;
               extra=cutter_diameter)
    @assert cutter_diameter <=  tenon_i
    @assert cutter_diameter <= tenon_j
    # Should 0, 0 be at the top left or bottom left?
    # Should the custom anchor be at the top left or bottom left?
    # It's more accurate to define the workspace grid by touching off
    # on the stock than on the partially mutilated edge of the Shaper
    # Workstation's spoilboard.  
    # Therefore, we should put the custom anchor at the bottom left.
    ZERO = zero(stock_i)
    stock_rect = Rectangle(; left=ZERO, top=ZERO,
                           width=stock_i, height=stock_j)
    waste_i = (stock_i - tenon_i) / 2
    waste_j = (stock_j - tenon_j) / 2
    tenon_rect = enlarge(stock_rect, - waste_i, - waste_j)
    # cos(pi/4) 0.7071067811865476
    tenon_safty = enlarge(tenon_rect,
                          0.25 * cutter_diameter,
                          0.25 * cutter_diameter)
    pocket_outer_bounds = enlarge(stock_rect,
                                  0.5 * cutter_diameter,
                                  0.5 * cutter_diameter)
    pocket_overlap = 0.75 * cutter_diameter
    elt("g",
        :class => "tenon",
        XML.Comment(
            " mortise and tenon:\n\t" *
            "tenon: $tenon_i by $tenon_j\n\t" *
            "stock: $stock_i by $stock_j\n\t" *
            "tenon length: $tenon_length\n\t" *
            "cutter diameter: $cutter_diameter\n\t" *
            "extra: $extra\n"),
        elt("g", :class => "pockets",
            # When the pocket is expressed as a single rectangle,
            # Shaper Origin doesn't protect the outside cut of the
            # tenon itself.  Instead, we define four pockets, one for
            # each outside edge of the outside cut.
            elt("rect",
                svg_attributes(
                    Rectangle(;
                              left = left(pocket_outer_bounds),
                              top = top(pocket_outer_bounds),
                              right = right(pocket_outer_bounds),
                              bottom = top(tenon_safty)))...,
                shaper_cut_depth(tenon_length),
                shaper_cut_attributes(:pocket_cut)...),
            elt("rect",
                svg_attributes(
                    Rectangle(;
                              left = left(pocket_outer_bounds),
                              top = bottom(tenon_safty),
                              right = right(pocket_outer_bounds),
                              bottom = bottom(pocket_outer_bounds)))...,
                shaper_cut_depth(tenon_length),
                shaper_cut_attributes(:pocket_cut)...),
            elt("rect",
                svg_attributes(
                    Rectangle(;
                              left = left(pocket_outer_bounds),
                              top = top(tenon_safty) - pocket_overlap,
                              right = left(tenon_safty),
                              bottom = bottom(tenon_safty) + pocket_overlap))...,
                shaper_cut_depth(tenon_length),
                shaper_cut_attributes(:pocket_cut)...),
            elt("rect",
                svg_attributes(
                    Rectangle(;
                              left = right(tenon_safty),
                              top = top(tenon_safty) - pocket_overlap,
                              right = right(pocket_outer_bounds),
                              bottom = bottom(tenon_safty) + pocket_overlap))...,
                shaper_cut_depth(tenon_length),
                shaper_cut_attributes(:pocket_cut)...)),
        elt("rect",
            svg_attributes(tenon_rect)...,
            :rx => svgval(cutter_diameter / 2),
            :ry => svgval(cutter_diameter / 2),
            shaper_cut_depth(tenon_length),
            shaper_cut_attributes(:outside_cut)...),
        XML.Comment(" Guide line that's a cutter diameter outside of the tenon's outside cut: "),
        elt("rect",
            svg_attributes(tenon_safty)...,
            # Using the same radius is a bit of a fudge:
            :rx => svgval(cutter_diameter / 2),
            :ry => svgval(cutter_diameter / 2),
            shaper_cut_attributes(:guide_line)...),
        XML.Comment(" Outside edge of the stock: "),
        elt("rect",
            svg_attributes(stock_rect)...,
            shaper_cut_attributes(:guide_line)...))
end


#=
function tenon(tenon_length, cutter_diameter,
               tenon_i, tenon_j, stock_i, stock_j;
               extra=cutter_diameter)
    @assert cutter_diameter <=  tenon_i
    @assert cutter_diameter <= tenon_j
    # Should 0, 0 be at the top left or bottom left?
    # Should the custom anchor be at the top left or bottom left?
    # It's more accurate to define the workspace grid by touching off
    # on the stock than on the partially mutilated edge of the Shaper
    # Workstation's spoilboard.  
    # Therefore, we should put the custom anchor at the bottom left.
    waste_i = (stock_i - tenon_i) / 2
    waste_j = (stock_j - tenon_j) / 2
    cutter_fraction = 2/3
    elt("g",
        :class => "tenon",
        XML.Comment(
            " mortise and tenon:\n\t" *
            "tenon: $tenon_i by $tenon_j\n\t" *
            "stock: $stock_i by $stock_j\n\t" *
            "tenon length: $tenon_length\n\t" *
            "cutter diameter: $cutter_diameter\n\t" *
            "extra: $extra\n"),
        elt("g", :class => "pockets",
            # When the pocket is expressed as a single rectangle,
            # Shaper Origin doesn't protect the outside cut of the
            # tenon itself.  Instead, we define four pockets, one for
            # each outside edge of the outside cut.
            elt("rect",
                :x => svgval(- cutter_fraction * cutter_diameter),
                :y => svgval(- cutter_fraction * cutter_diameter),
                :width => svgval(stock_i +
                    2 * cutter_fraction * cutter_diameter),
                :height => svgval(waste_j +
                    2 * cutter_fraction * cutter_diameter),
                shaper_cut_depth(tenon_length),
                shaper_cut_attributes(:pocket_cut)...),
            elt("rect",
                :x => svgval(- cutter_fraction * cutter_diameter),
                :y => svgval(stock_j - waste_j -
                    cutter_fraction * cutter_diameter),
                :width => svgval(stock_i +
                    2 * cutter_fraction * cutter_diameter),
                :height => svgval(waste_j +
                    2 * cutter_fraction * cutter_diameter),
                shaper_cut_depth(tenon_length),
                shaper_cut_attributes(:pocket_cut)...),
            elt("rect",
                :x => svgval(- cutter_fraction * cutter_diameter),
                :y => svgval(waste_j - cutter_fraction * cutter_diameter),
                :width => svgval(waste_i +
                    2 + cutter_fraction * cutter_diameter),
                :height => svgval(tenon_j +
                    2 * cutter_fraction * cutter_diameter),
                shaper_cut_depth(tenon_length),
                shaper_cut_attributes(:pocket_cut)...),
            elt("rect",
                :x => svgval(waste_i + tenon_i + cutter_diameter / 2),
                :y => svgval(waste_j - cutter_fraction * cutter_diameter),
                :width => svgval(waste_i),
                :height => svgval(tenon_j +
                    2 * cutter_fraction * cutter_diameter),
                shaper_cut_depth(tenon_length),
                shaper_cut_attributes(:pocket_cut)...)),
        elt("rect",
            :x => svgval(stock_i / 2 - tenon_i / 2),
            :y => svgval(stock_j / 2 - tenon_j / 2),
            :width => svgval(tenon_i),
            :height => svgval(tenon_j),
            :rx => svgval(cutter_diameter / 2),
            :ry => svgval(cutter_diameter / 2),
            shaper_cut_depth(tenon_length),
            shaper_cut_attributes(:outside_cut)...),
        XML.Comment(" Guide line that's a cutter diameter outside of the tenon's outside cut: "),
        elt("rect",
            :x => svgval(stock_i / 2 - tenon_i / 2 - cutter_diameter),
            :y => svgval(stock_j / 2 - tenon_j / 2 - cutter_diameter),
            :width => svgval(tenon_i + 2 * cutter_diameter),
            :height => svgval(tenon_j + 2 * cutter_diameter),
            :rx => svgval(cutter_diameter / 2),
            :ry => svgval(cutter_diameter / 2),
            shaper_cut_attributes(:guide_line)...),
        XML.Comment(" Outside edge of the stock: "),
        elt("rect",
            :x => 0,
            :y => 0,
            :width => svgval(stock_i),
            :height => svgval(stock_j),
            shaper_cut_attributes(:guide_line)...))
end
=#
