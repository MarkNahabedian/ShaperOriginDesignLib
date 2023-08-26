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


MAX_HYPOTENUSE = 33u"inch"

# Presentation parameters
SVG_MARGIN = 3u"inch"


################################################################################

struct Triangle
    point1::Point
    point2::Point
    point3::Point
end

legs(t::Triangle) = [ Line(t.point1, t.point2),
                      Line(t.point2, t.point3),
                      Line(t.point3, t.point1) ]


function inset(t::Triangle, inset)
    # Translate the edge designated by p1, p2 in the p3 direction by
    # inset:
    function translated_edge(p1, p2, p3)
        line = Line(p1, p2)
        N = normal_vector(line)
        # same direction from the line as p2?
        N = inset * normalize(sign(dot(N, p3 - p1)) * N)
        Line(p1 + N, p2 + N)
    end
    edge12 = translated_edge(t.point1, t.point2, t.point3)
    edge23 = translated_edge(t.point2, t.point3, t.point1)
    edge31 = translated_edge(t.point3, t.point1, t.point2)
    # Preserve vertex order:
    Triangle(intersetction(edge12, edge31),
             intersetction(edge23, edge12),
             intersetction(edge31, edge23))
end

function svg(t::Triangle, style)
    elt("g",
        :class => "Triangle",
        elt("path",
            :d => pathd(
                [ "M", t.point1 ],
                [ "L", t.point2 ],
                [ "L", t.point3 ],
                "z"),
            :style => style))
end

################################################################################

struct Leg
    x1
    y1
    x2
    y2

    function Leg(x1, y1, thickness)
        @assert thickness > zero(x1)
        new(x1, y1, x1 + thickness, y1 + thickness)
    end

    Leg(p::Point, thickness) = Leg(p.x, p.y, thickness)
end

function Leg(; center::Point, thickness)
    Leg(center.x - thickness/2,
        center_y - thickness/2,
        thickness)
end


width(leg::Leg) = leg.x2 - leg.x1
height(leg::Leg) = leg.y2 - leg.y1

center(leg::Leg) = [(leg.x1 + leg.x2) / 2,
                    (leg.y1 + leg.y2) / 2]

thickness(leg::Leg) = leg.x2 - leg.x1

ShaperOriginDesignLib.translate(leg::Leg, delta_x, delta_y) =
    Leg(leg.x1 + delta_x, leg.y1 + delta_y, thickness(leg))


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
    perimeter
    inset_triangle
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
        z = zero(nightstand_height)
        perimeter = Triangle(
            Point(z, z),   # point1 is the right angle.
            Point(z, triangle_leg_distance),
            Point(triangle_leg_distance, z))
        inset_triangle = inset(perimeter, leg_inset)
        hypotanuse = argmax(distance, legs(inset_triangle))
        imaginary_right_angle_leg = Leg(inset_triangle.point1, leg_thickness)
        raleg1 = translate(imaginary_right_angle_leg, leg_thickness, z)
        leg1 = translate(raleg1,
                         (point(hypotanuse; y = raleg1.y2)
                          - Point(raleg1.x2, raleg1.y2))...)
        raleg2 = translate(imaginary_right_angle_leg, z, leg_thickness)
        leg2 = translate(raleg2,
                         (point(hypotanuse; x = raleg2.x2)
                          - Point(raleg2.x2, raleg2.y2))...)
        new(nightstand_height,
            top_thickness,
            triangle_leg_distance,
            leg_inset,
            leg_thickness,
            tenon_length,
            # perimeter:
            perimeter, inset_triangle,
            imaginary_right_angle_leg,
            raleg1, raleg2, leg1, leg2)
    end
end


leg_length(nsm::NightstandModel) =
    nsm.nightstand_height - nsm.top_thickness

leg_count(nsm::NightstandModel) = 4

stringer_count(nsm::NightstandModel) = 4

stringer_length(nsm::NightstandModel) =
    (
        distance(center(nsm.raleg1)..., center(nsm.leg1)...)
        - nsm.leg_thickness
        + 2 * nsm.tenon_length
    )

function write_top_outline_file(nsm::NightstandModel, filename)
    svg = top_outline(nsm)
    XML.write(filename, svg)
end

function show_parameters(io::IO, nsm::NightstandModel)
    rnd(u) = round(unit(u), u, digits=3)
    max_leg = (sqrt(MAX_HYPOTENUSE * MAX_HYPOTENUSE / 2))
    println(io, "nightstand_height\t$(nsm.nightstand_height)")
    println(io, "top_thickness\t$(nsm.top_thickness)")
    println(io, "triangle_leg_distance\t$(nsm.triangle_leg_distance) \t max $(rnd(max_leg))")
    println(io, "leg_inset\t$(nsm.leg_inset)")
    println(io, "leg_thickness\t$(nsm.leg_thickness)")
    println(io, "tenon_length\t$(nsm.tenon_length)")
    hypotenuse = sqrt(2 * nsm.triangle_leg_distance * nsm.triangle_leg_distance)
    println(io, "hypotenuse\t$(rnd(hypotenuse)) \tmax $(rnd(MAX_HYPOTENUSE))")
end


################################################################################


function top_outline(nsm::NightstandModel)
    z = zero(nsm.nightstand_height)
    corner_radius = nsm.leg_inset
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
                :style => shaper_style_string(:outside_cut),
                # :style => "fill: none; stroke: green; stroke-width: 5px; vector-effect: non-scaling-stroke",
                :d => pathd(
                    let
                        c = center(nsm.imaginary_right_angle_leg)
                        # how far the center of
                        # imaginary_right_angle_leg is inset:
                        ci = nsm.leg_thickness/2 + nsm.leg_inset
                        r2 = nsm.leg_inset / sqrt(2)
                        startend = Point(nsm.leg2.x1 - nsm.leg_inset, nsm.leg2.y2)
                        corner_roundness = 1.5
                        # Table top perimeter counterclockwise
                        # starting from left hand edge in the SVG
                        # drawing:
                        [
                            [ "M", startend... ],
                            [ "L", c[1] - ci, c[2] ],   # left edge
                            [ "A", ci, ci, 0, 0, 1, c[1], c[2] - ci ],   # right angle corner
                            let
                                p1 = Point(nsm.leg1.x2, nsm.leg1.y1 - nsm.leg_inset)
                                p2 = Point(nsm.leg1.x2, nsm.leg1.y2) + Point(r2, r2)
                                [
                                    [ "L", p1... ],   # bottom edge
                                    [ "C",
                                      (p1 + corner_roundness * (1u"inch") * Point(1, 0))...,
                                      (p2 + corner_roundness * (1u"inch") * Point(1, -1))...,
                                      p2... ]
                                ]
                            end...,
                            let
                                p1 = Point(nsm.leg2.x2, nsm.leg2.y2 ) + Point(r2, r2)
                                [
                                    [ "L", p1... ],
                                    [ "C",
                                      (p1 + corner_roundness * (1u"inch") * Point(-1, 1))...,
                                      (startend + corner_roundness * (1u"inch") * Point(0, 1))...,
                                      startend... ]
                                ]
                            end...
                                ]
                    end...)),
            elt("path",
                :style => shaper_style_string(:guide_line),
                 :d => pathd(
                    [ "M", center(nsm.leg1)... ],
                    [ "L", center(nsm.imaginary_right_angle_leg)... ],
                    [ "L", center(nsm.leg2)... ],
                    [ "L", center(nsm.leg1)... ])),
            svg(nsm.perimeter, shaper_style_string(:guide_line)),
            svg(nsm.inset_triangle,
                shaper_style_string(:guide_line)),
            svg(nsm.raleg1, leg_rect_args...),
            svg(nsm.raleg2, leg_rect_args...),
            svg(nsm.leg1, leg_rect_args...),
            svg(nsm.leg2, leg_rect_args...),
            center_mark(center(nsm.raleg1)...),
            center_mark(center(nsm.raleg2)...),
            center_mark(center(nsm.leg1)...),
            center_mark(center(nsm.leg2)...)
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
# Nightstand measurements

# Maximum hypotenuse length is 32"
# Why didn't I measure the distance of the bed from the wall?
# TRIANGLE_LEG_DISTANCE = 20u"inch"

NIGHTSTAND_MODEL =
    NightstandModel(;
                    # The bed is 27" high, so the table should be about that height
                    nightstand_height = 28u"inch",
                    top_thickness = 0.75u"inch",
                    # Maximum hypotenuse length is 32"
                    # Why didn't I measure the distance of the bed from the wall?

                    # length of the two abstract legs of the right
                    # isocelese triangle of the tabletop:
                    triangle_leg_distance = 16.5u"inch",
                    leg_inset = 1u"inch",
                    leg_thickness = 1.5u"inch",
                    tenon_length = 0.75u"inch"
                    )

write_measurement_file(NIGHTSTAND_MODEL, "stock.txt")

write_top_outline_file(NIGHTSTAND_MODEL, "top.svg")


let
    lt = NIGHTSTAND_MODEL.leg_thickness
    CUTTER_DIAMETER = 0.25u"inch"
    tenon_length = 0.75u"inch"
    tenon_size = 0.5u"inch"
    svg = elt("svg",
              namespace_attributes()...,
              viewport_attributes(
                  - SVG_MARGIN,
                  - SVG_MARGIN,
                  lt + SVG_MARGIN,
                  lt + SVG_MARGIN,
                  u"inch", false)...,
              :width => "90%",
              tenon(tenon_length, CUTTER_DIAMETER,
                    tenon_size, tenon_size,
                    lt, lt,
                    0.25u"inch"))
    XML.write("mortise_and_tenon.svg", svg)
end


################################################################################

struct Hinge
    leaf_thickness
    length   # length is of each leaf in the direction parallel to the hinge pin
    width    # measurement of the entire hinge, perpendicular to the length
    screw_hole_diameter
    distance_between_centers
    screw_hole_center_from_end
    # The hinges I have measure a consistent distance from the
    # abstract center line of the hinge (the projection of the center
    # of the hinge pin onto the plane of the hinge when opened flat,
    # but the two leaves vary in width.  For this reason we measure
    # hole to hole across the center.
    screw_hole_center_from_axis

    Hinge(; leaf_thickness, length, width,
          screw_hole_diameter, distance_between_centers,
          screw_hole_center_from_end, screw_hole_center_from_axis) =
              new(leaf_thickness, length, width,
                  screw_hole_diameter, distance_between_centers,
                  screw_hole_center_from_end,
                  screw_hole_center_from_axis)
end


function hinge_mortise(hinge::Hinge)
    center_x = hinge.length / 2
    center_y = hinge.width / 2
    elt("svg",
        namespace_attributes()...,
        viewport_attributes(
            - SVG_MARGIN,
            - SVG_MARGIN,
            hinge.length + SVG_MARGIN,
            hinge.width + SVG_MARGIN,
            u"inch", false)...,
        :width => "90%",
        elt("g",
            elt("path",
                :d => pathd([ "M", 0u"inch", 0u"inch" ],
                            [ "h", hinge.length ],
                            [ "v", hinge.width ],
                            [ "h", - hinge.length ],
                            "z"),
                :style => shaper_style_string(:pocket_cut),
                shaper_cut_depth(hinge.leaf_thickness)),
            elt("path",
                :d => pathd([ "M", 0u"inch", center_y ],
                            [ "h", hinge.length ]),
                :style => shaper_style_string(:guide_line)),
            custom_anchor(center_x, center_y),
            center_mark(hinge.screw_hole_center_from_end,
                        center_y - hinge.screw_hole_center_from_axis),
            center_mark(hinge.length - hinge.screw_hole_center_from_end,
                        center_y -  hinge.screw_hole_center_from_axis),
            center_mark(hinge.screw_hole_center_from_end,
                        center_y + hinge.screw_hole_center_from_axis),
            center_mark(hinge.length - hinge.screw_hole_center_from_end,
                        center_y + hinge.screw_hole_center_from_axis)))
end


################################################################################

LEG_HINGE =
    let
        HINGE_LENGTH = 0.764u"inch"
        # 1/8" transfer punch passes through
        SCREW_HOLE_DIAMETER = 0.125u"inch"
        DISTANCE_BETWEEN_CENTERS = 0.320u"inch" + SCREW_HOLE_DIAMETER
        Hinge(leaf_thickness = 0.03u"inch",
              length = HINGE_LENGTH,
              width = 1.0u"inch",
              screw_hole_diameter = SCREW_HOLE_DIAMETER,
              distance_between_centers = DISTANCE_BETWEEN_CENTERS,
              screw_hole_center_from_end = (HINGE_LENGTH - DISTANCE_BETWEEN_CENTERS
                                            - SCREW_HOLE_DIAMETER) / 2,
              screw_hole_center_from_axis = (0.465u"inch" + SCREW_HOLE_DIAMETER) / 2)
    end


let
    svg = hinge_mortise(LEG_HINGE)
    XML.write("hinge_mortise.svg", svg)
end


