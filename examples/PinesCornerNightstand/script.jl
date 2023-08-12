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
TOP_THICKNESS = 0.5u"inch"


# Maximum hypotenuse length is 32"
# Why didn't I measure the distance of the bed from the wall?
TRIANGLE_LEG_DISTANCE = 20u"inch"

LEG_THICKNESS = 1u"inch"
LEG_INSET = 1u"inch"
TENON_LENGTH = 0.75u"inch"


################################################################################

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
     

function svg(leg::Leg, attrs...)
    elt("g",
        :class => "Leg",
        elt("rect",
            :x => svgval(leg.x1),
            :y => svgval(leg.y1),
            :width => svgval(width(leg)),
            :height => svgval(height(leg)),
            attrs...,)
        #=
        elt("path", :d => pathd([ "M", leg.x2, leg.y1 ],
                                [ "L", leg.x1, leg.y2 ])),
        elt("path", :d => pathd([ "M", leg.x1, leg.y1 ],
                                [ "L", leg.x2, leg.y2 ]))
        =#
        )
end

################################################################################

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


################################################################################


struct NightstandModel
    nightstand_height
    top_thickness
    triangle_leg_distance
    leg_inset
    leg_thickness
    tenon_length

    # Derived properties:
    imaginary_right_angle_leg
    raleg1
    raleg2
    leg1
    leg2

    function NightstandModel(;
                             nightstand_height,
                             top_thickness,
                             triangle_leg_distance,
                             leg_inset,
                             leg_thickness,
                             tenon_length)
        new(nightstand_height,
            top_thickness,
            triangle_leg_distance,
            leg_inset,
            leg_thickness,
            tenon_length,
            Leg(LEG_INSET, LEG_INSET, LEG_THICKNESS),  # imaginary_right_angle_leg
            Leg(LEG_INSET, LEG_INSET + LEG_THICKNESS, LEG_THICKNESS),  # raleg1
            Leg(LEG_INSET + LEG_THICKNESS, LEG_INSET, LEG_THICKNESS),  # raleg2
            Leg(LEG_INSET, TRIANGLE_LEG_DISTANCE - LEG_INSET, LEG_THICKNESS), # leg1
            Leg(TRIANGLE_LEG_DISTANCE - LEG_INSET, LEG_INSET, LEG_THICKNESS)  # leg2
            )
    end
end


leg_length(nsm::NightstandModel) =
    nsm.nightstand_height - nsm.top_thickness

leg_count(nsm::NightstandModel) = 4

stringer_count(nsm::NightstandModel) = 4

stringer_length(nsm::NightstandModel) =
    (nsm.triangle_leg_distance
     - 2 * nsm.leg_inset
     - 2 * nsm.leg_thickness
     + 2 * nsm.tenon_length)

function write_top_outline_file(nsm::NightstandModel, filename)
    svg = top_outline(nsm)
    XML.write(filename, svg)
end

function show_parameters(io::IO, nsm::NightstandModel)
    println(io, "nightstand_height\t$(nsm.nightstand_height)")
    println(io, "top_thickness\t$(nsm.top_thickness)")
    println(io, "triangle_leg_distance\t$(nsm.triangle_leg_distance)")
    println(io, "leg_inset\t$(nsm.leg_inset)")
    println(io, "leg_thickness\t$(nsm.leg_thickness)")
    println(io, "tenon_length\t$(nsm.tenon_length)")
end


################################################################################


function top_outline(nsm::NightstandModel)
    corner_radius = nsm.leg_inset
    imaginary_right_angle_leg = nsm.imaginary_right_angle_leg
    raleg1 = nsm.raleg1 
    raleg2 = nsm.raleg2
    leg1 = nsm.leg1
    leg2 = nsm.leg2
    leg_rect_args = [
        :style => shaper_style_string(:guide_line)
    ]
    elt("svg",
        namespace_attributes()...,
        viewport_attributes(
            - SVG_MARGIN,
            - SVG_MARGIN,
            nsm.triangle_leg_distance + SVG_MARGIN,
            nsm.triangle_leg_distance + SVG_MARGIN,
            u"inch", false)...,
	:width => "90%",
        elt("g",
            # Invert Y axis for conventional coordinate system:
            :transform => "translate(0, $(svgval(nsm.triangle_leg_distance))) scale(1 -1)",
            elt("path",
                :style => shaper_style_string(:guide_line),
                 :d => pathd(
                    [ "M", center(leg1)... ],
                    [ "L", center(imaginary_right_angle_leg)... ],
                    [ "L", center(leg2)... ],
                    [ "L", center(leg1)... ])),
            elt("path",
                :style => shaper_style_string(:outside_cut),
                :d => pathd(
                    [ "M", arc_point(center(leg1)..., 180°, corner_radius)... ],
                    [ "L", arc_point(center(imaginary_right_angle_leg)...,
                                     180°, corner_radius)... ],
                    [ "A", corner_radius, corner_radius,
                      0, 0, 1,
                      arc_point(center(imaginary_right_angle_leg)...,
                                     -90°, corner_radius)... ],
                    [ "L", arc_point(center(leg2)..., -90°, corner_radius)... ],
                    [ "A", corner_radius, corner_radius,
                      0, 0, 1,
                      arc_point(center(leg2)..., 45°, corner_radius)... ],
                    [ "L", arc_point(center(leg1)..., 45°, corner_radius)... ],
                    [ "A", corner_radius, corner_radius,
                      0, 0, 1,
                      arc_point(center(leg1)..., 180°, corner_radius)... ])),
            svg(raleg1, leg_rect_args...),
            svg(raleg2, leg_rect_args...),
            svg(leg1, leg_rect_args...),
            svg(leg2, leg_rect_args...),
            center_mark(center(raleg1)...),
            center_mark(center(raleg2)...),
            center_mark(center(leg1)...),
            center_mark(center(leg2)...)
            ))
end


function write_top_outline_file(nsm::NightstandModel, filename)
    svg = top_outline(nsm)
    XML.write(filename, svg)
end


function write_measurement_file(nsm::NightstandModel, filename)
    open(filename, "w") do io
        show_parameters(io, nsm)
        println(io)
        println(io, "$(leg_count(nsm)) legs, $(leg_length(nsm)) each.")
        println(io, "$(stringer_count(nsm)) stringers, $(stringer_length(nsm)) each.")
    end
end


################################################################################

NIGHTSTAND_MODEL =
    NightstandModel(;
                    # The bed is 27" high, so the table should be about that height
                    nightstand_height = 27u"inch",
                    top_thickness = 0.5u"inch",
                    # Maximum hypotenuse length is 32"
                    # Why didn't I measure the distance of the bed from the wall?

                    triangle_leg_distance = 20u"inch",
                    leg_inset = 1u"inch",
                    leg_thickness = 1u"inch",
                    tenon_length = 0.75u"inch"
                    )

write_measurement_file(NIGHTSTAND_MODEL, "stock.txt")

write_top_outline_file(NIGHTSTAND_MODEL, "top.svg")


################################################################################


# Dimensions of the hinge
HINGE_THICKNESS = 0.03u"inch"       # mottice depths
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

