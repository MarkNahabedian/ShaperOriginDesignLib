
using NativeSVG

export custom_anchor

```
    Mark the location of a custom anchor for Shaper Origin.
    ```
function custom_anchor(io, x, y; xdirection=1, ydirection=-1, size=0.25u"inch")
    path(io; style="fill:red;
		    stroke=none;",
	 d=pathd(
	     ["M", x, y],
	     ["h", xdirection * size],
	     ["L", x, y + ydirection * 2 * size],
	     ["z"]
	 ))
end
