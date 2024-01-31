

export custom_anchor

"""
custom_anchor(x, y; xdirection=1, ydirection=-1, size=0.25u"inch")

Mark the location of a custom anchor for Shaper Origin.
Returns an SVG `path` element.
"""
function custom_anchor(x, y; xdirection=1, ydirection=-1, size=0.25u"inch")
    elt("path",
        :class => "custom_anchor",
        :fill => "red",
        :stroke => "none",
        :opacity => "0.5",
	:d => pathd(
	    ["M", x, y],
	    ["h", xdirection * size],
	    ["L", x, y + ydirection * 2 * size],
	    ["z"]))
end
