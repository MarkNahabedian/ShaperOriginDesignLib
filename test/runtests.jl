
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
        "fill: none; stroke: gray; stroke-width: 0.01; opacity: 1.0;"
end

@testset "viewport_attributes" begin
    left, top, right, bottom = (0.0u"inch", 0.0u"cm", 5.0u"inch", 2.54u"cm")
    attrs = viewport_attributes(left, top, right, bottom, u"inch")
    @test attrs.width == "5.0in"
    @test attrs.height == "1.0in"
    @test attrs.viewBox == "0.0 0.0 5.0 1.0"
end
