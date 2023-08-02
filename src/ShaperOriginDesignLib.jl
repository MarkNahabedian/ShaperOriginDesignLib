module ShaperOriginDesignLib

using Printf
using Unitful
using UnitfulUS
using XML
using TabletWeaving: elt

export SVG_NAMESPACE

SVG_NAMESPACE = "http://www.w3.org/2000/svg"

include("shaper_cut_attributes.jl")
include("svg_utils.jl")
include("custom_anchor.jl")

end
