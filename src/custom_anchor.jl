

export custom_anchor

"""
custom_anchor(x, y; size=0.25u"inch")

Mark the location of a custom anchor for Shaper Origin.
Returns an SVG `path` element.
"""
function custom_anchor(x, y;  size=0.25u"inch")
    # https://support.shapertools.com/hc/en-us/articles/4402965445019-Custom-Anchors:
    # "To add a custom anchor, create a right-angled triangle that's a
    # closed shape and contains a red fill with no stroke. The right
    # angle vertex defines the location of the anchor point. The
    # shorter leg of the right angle defines the X-axis and the longer
    # leg defines the Y-axis."
    elt("path",
        :class => "custom_anchor",
        :fill => "red",
        :stroke => "none",
        :opacity => "0.5",
	:d => pathd(
	    ["M", x, y],
	    ["h",  size],
	    ["L", x, y + 2 * size],
	    ["z"]))
end
