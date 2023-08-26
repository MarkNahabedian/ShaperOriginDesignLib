
using Printf
using ShaperOriginDesignLib
using Unitful
using UnitfulUS
using Test

@testset "ShaperOriginDesignLib.jl" begin
    @test svgval(1.5) == 1.5
    @test svgval(4.5u"inch") == 4.5
    d = pathd(
        ["M", 0, 0],
        ["h", 3u"cm"],
        ["v", 4u"cm"],
        ["z"]
    )
    @test d == @sprintf("M 0 0 h %3f v %3f z",
                        3 / 2.54, 4 / 2.54)
    @test shaper_style_string(:on_line_cut) ==
        "fill: none; stroke: rgb(70 70 70); stroke-width: 1px; opacity: 1.0; vector-effect: non-scaling-stroke;"
end

@testset "viewport_attributes" begin
    left, top, right, bottom = (0.0u"inch", 0.0u"cm", 5.0u"inch", 2.54u"cm")
    attrs = viewport_attributes(left, top, right, bottom, u"inch")
    d = Dict(attrs)
    @test d[:width] == "5.0in"
    @test d[:height] == "1.0in"
    @test d[:viewBox] == "0.0 0.0 5.0 1.0"
end

@testset "geometry" begin
    @test distance(Point(3, 4)) == 5
    let
        p1 = Point(1, 2)
        p2 = Point(2, 4)
        @test collect(p2) == [2, 4]
        @test p1 + p2 == Point(3, 6)
        @test 2*p1 - p2 == Point(0, 0)
        @test p1.*(p2) == [2, 8]
    end
    let
        p1 = Point(1, 2)
        p2 = Point(2, 2)
        p3 = Point(2, 2 + sqrt(3))
        @test direction(p1, p3) == pi/3
    end
    @test direction(Point(0, 0), Point(1, 0), Point(1, sqrt(3))) == pi/3
    let
        p0 = Point(0, 3.0)
        p1 = Point(1, 5)
        p2 = Point(2, 7)
        line = Line(p2, p1)
        @test direction(line) == atan(2, 1)
        @test intercept(line) == p0
        @test point_on_line(p1, line)
        @test point_on_line(p2, line)
        @test point_on_line(p0, line)
    end
    let
        p1 = Point(0.0, 0.0)
        p2 = Point(0.0, 1.0)
        p3 = Point((p1.x + p2.x) / 2, (p1.y + p2.y) / 2)
        line = Line(p1, p2)
        V, C = vector_parametric(line)
        @test 0 * V + C == p1
        @test 1 * V + C == p2
        @test 0.5 * V + C == p3
        @test point_in_segment(p1, line)
        @test point_in_segment(p2, line)
        @test point_in_segment(p3, line)
    end
    let
        line = Line(Point(2, 4), Point(2, 1))
        @test direction(line) == pi/2
        @test intercept(line) == Point(2, 0)
    end
    @test distance(normalize(Point(1.0u"inch", 2.54u"cm"))) == 1.0
    let
        p1 = Point(0.0, 0.0)
        p2 = Point(1.0, 0.0)
        p3 = Point(0.0, 1.0)
        line12 = Line(p1, p2)
        line23 = Line(p2, p3)
        line31 = Line(p3, p1)
        @test intersetction(line12, line23) == p2
        @test intersetction(line23, line31) == p3
        @test intersetction(line31, line12) == p1
    end
end
