# SVG line styles for the different kinds of cut paths of the Shaper Origin:

using DataStructures: OrderedDict

export shaper_cut_attributes, shaper_style_string, shaper_cut_depth

shaper_cut_attributes = Dict(
	:inside_cut => OrderedDict(
		"fill" => "white",
		"stroke" => "black",
		"stroke-width" => "1px",
		"opacity" => "1.0",
                "vector-effect" => "non-scaling-stroke"
        ),
	:outside_cut => OrderedDict(
		"fill" => "black",
		"stroke" => "black",
		"stroke-width" => "1px",
		"opacity" => "1.0"
	),
	:on_line_cut => OrderedDict(
		"fill" => "none",
		"stroke" => "rgb(70 70 70)",     # "gray"
		"stroke-width" => "1px",
		"opacity" => "1.0",
                "vector-effect" => "non-scaling-stroke"
	),
	:pocket_cut => OrderedDict(
		"fill" => "rgb(175 175 175)",       # "gray"
		"stroke" => "none",
		"opacity" => "1.0"
	),
	:guide_line => OrderedDict(
		"fill" => "none",
		"stroke" => "blue",
		"stroke-width" => "1px",
		"opacity" => "1.0",
                "vector-effect" => "non-scaling-stroke"
	)
)

"""
    shaper_style_string(cut_type::Symbol)::String

Returns a String to be used as the value of the `style` attribute of
an SVG element to inform Shaper Origin of the cut type.
"""
function shaper_style_string(cut_type::Symbol)
    io = IOBuffer()
    for (css, value) in shaper_cut_attributes[cut_type]
        if position(io) > 0
            write(io, " ")
        end
        write(io, "$css: $value;")
    end
    String(take!(io))
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

