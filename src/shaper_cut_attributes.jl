# SVG line styles for the different kinds of cut paths of the Shaper Origin:

using DataStructures: OrderedDict

export shaper_cut_attributes, shaper_cut_depth

SHAPER_CUT_ATTRIBUTES = Dict(
    #= NOTE:
    Shaper Origin doesn't understand color specifications like
    "rgb(...)"  Only use hex values or standard color names.
    =#
    :inside_cut => (
	Symbol("fill") => "white",
	Symbol("stroke") => "black",
	Symbol("stroke-width") => "1px",
	Symbol("opacity") => "1.0",
        Symbol("vector-effect") => "non-scaling-stroke"
    ),
    :outside_cut => (
	Symbol("fill") => "black",
	Symbol("stroke") => "black",
	Symbol("stroke-width") => "1px",
	Symbol("opacity") => "1.0",
        Symbol("vector-effect") => "non-scaling-stroke"
    ),
    :on_line_cut => (
	Symbol("fill") => "none",
	Symbol("stroke") => "#464646",     # "gray"
	Symbol("stroke-width") => "1px",
	Symbol("opacity") => "1.0",
        Symbol("vector-effect") => "non-scaling-stroke"
    ),
    :pocket_cut => (
	Symbol("fill") => "#afafaf",       # "gray"
	Symbol("stroke") => "none",
	Symbol("opacity") => "1.0",
        Symbol("vector-effect") => "non-scaling-stroke"
    ),
    :guide_line => (
	Symbol("fill") => "none",
	Symbol("stroke") => "blue",
	Symbol("stroke-width") => "1px",
	Symbol("opacity") => "1.0",
        Symbol("vector-effect") => "non-scaling-stroke"
    )
)


"""
    shaper_cut_attributes(cut_type::Symbol)

Returns a tuple of pairs of XML attribute/value Pairs descreibing the
specified Shaper Origin cut type.
"""
function shaper_cut_attributes(cut_type::Symbol)
    SHAPER_CUT_ATTRIBUTES[cut_type]
end


"""
    shaper_cut_depth(depth)

Return an XML element attribute (as a Pair{String, String}) to control
the depth of a pocket cut.
"""
function shaper_cut_depth(depth)
    # See https://support.shapertools.com/hc/en-us/articles/12946815194011-Manual-SVG-Cut-Depth-Encoding
    Symbol("shaper:cutDepth") => "$(svgval(depth))"
end

