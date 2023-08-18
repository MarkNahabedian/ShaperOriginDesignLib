module ShaperOriginDesignLib

using Printf
using Unitful
using UnitfulUS
using XML

export SVG_NAMESPACE, SHAPER_NAMESPACE

SVG_NAMESPACE = "http://www.w3.org/2000/svg"
SHAPER_NAMESPACE = "http://www.shapertools.com/namespaces/shaper"

include("elt.jl")
include("shaper_cut_attributes.jl")
include("svg_utils.jl")
include("custom_anchor.jl")
include("point.jl")

end
