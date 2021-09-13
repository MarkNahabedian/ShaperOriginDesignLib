module ShaperOriginDesignLib

using Printf
using Unitful
using UnitfulUS

export SVG_NAMESPACE

SVG_NAMESPACE = "http://www.w3.org/2000/svg"

include("shaper_cut_attributes.jl")
include("svg_utils.jl")

end
