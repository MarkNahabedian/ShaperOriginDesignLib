
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
end
