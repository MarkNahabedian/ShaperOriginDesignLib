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
    elt("g",
        :class => "tenon",
        elt("rect",
            :x => svgval(- extra),
            :y => svgval(- extra),
            :width => svgval(stock_i + 2 * extra),
            :height => svgval(stock_j + 2 * extra),
            shaper_cut_depth(tenon_length),
            shaper_cut_attributes(:pocket_cut)...),
        elt("rect",
            :x => svgval(stock_i / 2 - tenon_i / 2),
            :y => svgval(stock_j / 2 - tenon_j / 2),
            :width => svgval(tenon_i),
            :height => svgval(tenon_j),
            :rx => svgval(cutter_diameter / 2),
            :ry => svgval(cutter_diameter / 2),
            shaper_cut_depth(tenon_length),
            shaper_cut_attributes(:outside_cut)...),
        elt("rect",
            :x => 0,
            :y => 0,
            :width => svgval(stock_i),
            :height => svgval(stock_j),
            shaper_cut_attributes(:guide_line)...))
end

