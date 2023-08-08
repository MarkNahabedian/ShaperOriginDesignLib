using Pkg
Pkg.activate("../..")

using Markdown
using InteractiveUtils

# using Markdown
# using PlutoUI
using XML
using Unitful
using UnitfulUS
using ShaperOriginDesignLib
import Unitful: °


# Presentation parameters
SVG_MARGIN = 3u"inch"


# Nightstand measurements

# The bed is 27" high, so the table should be about that height
HEIGHT = 27u"inch"

# Maximum hypotenuse length is 32"
# Why didn't I measure the distance of the bed from the wall?
TRIANGLE_LEG_DISTANCE = 20u"inch"

LEG_THICKNESS = 1u"inch"
LEG_INSET = 1u"inch"


struct Leg
    x1
    y1
    x2
    y2

    function Leg(x1, y1, thickness)
        @assert thickness > 0u"inch"
        new(x1, y1, x1 + thickness, y1 + thickness)
    end
end

width(leg::Leg) = leg.x2 - leg.x1
height(leg::Leg) = leg.y2 - leg.y1

center(leg::Leg) = ((leg.x1 + leg.x2) / 2,
                    (leg.y1 + leg.y2) / 2)
     

function arc_point(x, y, direction, radius)
    d = rem(direction, 360°)
    (x + radius * Base.cos(d),
     y + radius * Base.sin(d))
end

let
    r = 1u"inch"
    leg = Leg(2u"inch", 2u"inch", 1u"inch")
    @assert leg.x2 == 3u"inch"
    @assert leg.y2 == 3u"inch"

    @assert arc_point(leg.x1, leg.y1,  90°, r) == (leg.x1, leg.y1 + r)
    @assert arc_point(leg.x2, leg.y1,  90°, r) == (leg.x2, leg.y1 + r)
    
    @assert arc_point(leg.x1, leg.y1, 180°, r) == (leg.x1 - r, leg.y1)
    @assert arc_point(leg.x1, leg.y2, 180°, r) == (leg.x1 - r, leg.y2)

    @assert arc_point(leg.x1, leg.y2, 270°, r) == (leg.x1, leg.y2 - r)
    @assert arc_point(leg.x2, leg.y2, 270°, r) == (leg.x2, leg.y2 - r)

    @assert arc_point(leg.x2, leg.y1, 360°, r) == (leg.x2 + r, leg.y1)
    @assert arc_point(leg.x2, leg.y2, 360°, r) == (leg.x2 + r, leg.y2)
end


function svg(leg::Leg, attrs...)
    elt("g",
        attrs...,
        elt("rect",
            :x => svgval(leg.x1),
            :y => svgval(leg.y1),
            :width => svgval(width(leg)),
            :height => svgval(height(leg)))
        #=
        elt("path", :d => pathd([ "M", leg.x2, leg.y1 ],
                                [ "L", leg.x1, leg.y2 ])),
        elt("path", :d => pathd([ "M", leg.x1, leg.y1 ],
                                [ "L", leg.x2, leg.y2 ]))
        =#
        )
end


function top_outline()
    corner_radius = LEG_INSET + LEG_THICKNESS / 2
    right_angle_leg = Leg(LEG_INSET, LEG_INSET, LEG_THICKNESS)
    leg1 = Leg(LEG_INSET, TRIANGLE_LEG_DISTANCE - LEG_INSET, LEG_THICKNESS)
    leg2 = Leg(TRIANGLE_LEG_DISTANCE - LEG_INSET, LEG_INSET, LEG_THICKNESS)
    leg_rect_args = [
        :style => "fill: none; stroke: green; stroke-width: 0.01;"
    ]
    elt("svg",
        namespace_attributes()...,
        viewport_attributes(
            - SVG_MARGIN,
            - SVG_MARGIN,
            TRIANGLE_LEG_DISTANCE + SVG_MARGIN,
            TRIANGLE_LEG_DISTANCE + SVG_MARGIN,
            u"inch" #, false
	)...,
	:width => "90%",
	:style => "background-color: pink",
        elt("g",
            # Invert Y axis for conventional coordinate system:
            :transform => "scale(1 -1) translate(0, $(TRIANGLE_LEG_DISTANCE))",
            svg(right_angle_leg, leg_rect_args...),
            svg(leg1, leg_rect_args...),
            svg(leg2, leg_rect_args...),
            #=
            elt("path",
                :style => shaper_style_string(:guide_line),
                 :d => pathd(
                    [ "M", center(leg1)... ],
                    [ "L", center(right_angle_leg)... ],
                    [ "L", center(leg2)... ],
                    [ "L", center(leg1)... ])),
            =#
            elt("path",
                :style => shaper_style_string(:guide_line),
                :d => pathd(
                    [ "M", arc_point(center(leg1)..., 180°, corner_radius)... ],
                    [ "L", arc_point(center(right_angle_leg)...,
                                     180°, corner_radius)... ],
                    [ "A", corner_radius, corner_radius,
                      0, 0, 1,
                      arc_point(center(right_angle_leg)...,
                                     -90°, corner_radius)... ],
                    [ "M", arc_point(center(right_angle_leg)...,
                                     -90°, corner_radius)... ],
                    [ "L", arc_point(center(leg2)..., -90°, corner_radius)... ],
                    [ "A", corner_radius, corner_radius,
                      0, 0, 1,
                      arc_point(center(leg2)..., 45°, corner_radius)... ],
                    [ "M", arc_point(center(leg2)..., 45°, corner_radius)... ],
                    [ "L", arc_point(center(leg1)..., 45°, corner_radius)... ],
                    [ "A", corner_radius, corner_radius,
                      0, 0, 1,
                      arc_point(center(leg1)..., 180°, corner_radius)... ]))
            ))
end


let
    svg = top_outline()
    html = elt("html",
		elt("head"),
		elt("body",
			svg
		)
	)
    XML.write("top.svg", svg)
    HTML(XML.write(html))
end


# Dimensions of the hinge
HINGE_THICKNESS = 0.03u"inch"       # mottice depth
HINGE_LENGTH = 0.8u"inch"
HINGE_WIDTH = 1.0u"inch"    # from edge of one leaf to the edge of the other

SCREW_HOLE_DIAMETER = 0.135u"inch"   # 1/8# transfer punch passes through
DISTANCE_BETWEEN_CENTERS = 0.315u"inch" + SCREW_HOLE_DIAMETER
SCREW_HOLE_CENTER_FROM_END = (HINGE_LENGTH - DISTANCE_BETWEEN_CENTERS
                              - 2 * SCREW_HOLE_DIAMETER) / 2
SCREW_HOLE_CENTER_FROM_EDGE = 0.14u"inch" + SCREW_HOLE_DIAMETER / 2


function hinge_mortise(center_x, center_y)
    elt("svg",
        namespace_attributes()...,
        viewport_attributes(
            - SVG_MARGIN,
            - SVG_MARGIN,
            HINGE_LENGTH + SVG_MARGIN,
            HINGE_WIDTH + SVG_MARGIN,
            u"inch")...,
	:style => "background-color: yellow",
        elt("g",
            elt("path",
                :d => pathd([ "M", 0u"inch", 0u"inch" ],
                            [ "h", HINGE_LENGTH ],
                            [ "v", HINGE_WIDTH ],
                            [ "h", - HINGE_LENGTH ],
                            "z"),
                :style => shaper_style_string(:pocket_cut),
                shaper_cut_depth(HINGE_THICKNESS)),
            elt("path",
                :d => pathd([ "M", 0u"inch", center_y ],
                            [ "l", HINGE_LENGTH ]),
                :style => shaper_style_string(:guide_line)),
            custom_anchor(center_x, center_y),
            center_mark(SCREW_HOLE_CENTER_FROM_END,
                        SCREW_HOLE_CENTER_FROM_EDGE),
            center_mark(HINGE_LENGTH - SCREW_HOLE_CENTER_FROM_END,
                        SCREW_HOLE_CENTER_FROM_EDGE),
            center_mark(SCREW_HOLE_CENTER_FROM_END,
                        HINGE_WIDTH - SCREW_HOLE_CENTER_FROM_EDGE),
            center_mark(HINGE_LENGTH - SCREW_HOLE_CENTER_FROM_END,
                        HINGE_WIDTH - SCREW_HOLE_CENTER_FROM_EDGE)
            ))
end


let
    center_x = HINGE_LENGTH / 2
    center_y = HINGE_WIDTH / 2
    svg = hinge_mortise(center_x, center_y)
    html = elt("html",
	       elt("head"),
	       elt("body", svg))
    XML.write("hinge_mortise.svg", svg)
    HTML(XML.write(html))
end

