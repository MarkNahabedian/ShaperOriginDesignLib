module ShaperOriginDesignLib

using Printf
using Unitful
using UnitfulUS
using XML
using NahaXMLUtils
using NahaXMLUtils: SVG_UNITS

export SHAPER_NAMESPACE, user_units_val, SHAPER_NAMESPACE


user_units_val(n::Number) = n
user_units_val(n::Quantity) =
    svgval(uconvert(task_local_storage(:SVG_USER_LENGTH_UNIT), n))


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
