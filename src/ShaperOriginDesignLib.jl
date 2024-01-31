module ShaperOriginDesignLib

using Printf
using Unitful
using UnitfulUS
using XML

export SVG_NAMESPACE, SHAPER_NAMESPACE, user_units_val

SVG_NAMESPACE = "http://www.w3.org/2000/svg"
SHAPER_NAMESPACE = "http://www.shapertools.com/namespaces/shaper"


user_units_val(n::Number) = n
user_units_val(n::Quantity) =
    svgval(uconvert(task_local_storage(:SVG_USER_LENGTH_UNIT), n))


include("elt.jl")
include("shaper_cut_attributes.jl")
include("svg_utils.jl")
include("svg_path.jl")
include("custom_anchor.jl")
include("point.jl")
include("line.jl")
include("rectangle.jl")
include("tenon.jl")

# Must be called after all methods of svg_pathd have been defined:
init_path_ops()

end
