
export svgval, SVG_UNITS, namespace_attributes, viewport_attributes, pathd


"""
    svgval(value)
return a representation of `value` that can appear in SVG code.
"""
function svgval end

function svgval(x::Quantity)
    ustrip(Real, u"inch", x)
end

function svgval(x::Number)
    x
end


SVG_UNITS = Dict{Unitful.Units, String}(
    u"cm" => "cm",
    u"mm" => "mm",
    u"inch" => "in"
)


"""
    namespace_attributes()

Return a vector of XML namestpace declaration attributes to be applied
to the root SVG element.
"""
function namespace_attributes()
    return [
        :xmlns => SVG_NAMESPACE,
        Symbol("xmlns:shaper") => SHAPER_NAMESPACE
    ]
end


"""
    viewport_attributes(left, top, right, bottom)

Return a named tuple of SVG attributes to be added to the SVG element.
"""
function viewport_attributes(left::Unitful.Length, top::Unitful.Length,
                             right::Unitful.Length, bottom::Unitful.Length,
                             to_units::Unitful.Units)
    left, top, right, bottom = (x -> ustrip(to_units, x)).((left, top, right, bottom))
    width = right - left
    height = bottom - top
    return (
        viewBox = "$left $top $width $height",
        width = "$width$(SVG_UNITS[to_units])",
        height = "$height$(SVG_UNITS[to_units])"
    )
end


"""
    pathd(steps...)

`pathd` is a convenience function for generating an SVG `path` element.
Each step is an array of a path step letter, e.g. `M`, `L`, `h` and
the parameters for that step.
A string suitable for use as the `d` attribute of an SVG `path`
element is retuirned.
"""
function pathd(steps...)
    d = IOBuffer()
    needspace = false
    function putd(token)
	if needspace
	    write(d, " ")
            needspace = false
	end
	if token isa String
	    write(d, token)
            needspace = true
	elseif token isa Symbol
	    putd(string(token))
            needspace = true
	elseif token isa Quantity
	    putd(svgval(token))
            needspace = true
	elseif token isa Integer
	    @printf(d, "%d", token)
            needspace = true
	elseif token isa Real
	    @printf(d, "%3f", token)
            needspace = true
	else
	    throw(ErrorException("Unsupported pathd token $token"))
	end
    end
    for step in steps
	if step isa Union{Tuple, Vector}
	    for token in step
		putd(token)
	    end
	else
	    putd(step)
	end
    end
    String(take!(d))
end

