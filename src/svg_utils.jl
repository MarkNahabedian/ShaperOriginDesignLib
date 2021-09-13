
export svgval, pathd


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
	    throw(Exception("Unsupported pathd token $token"))
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

