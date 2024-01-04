# Construct SVG path stems in a way that sypports units conversiion.


SVG_PATH_OPS = Dict{Union{AbstractChar, AbstractString},
                    Tuple{Val, AbstractChar}}()

function register_pathd_op(letter::Char)
    uc = uppercase(letter)
    lc = lowercase(letter)
    v = Val{Symbol(uc)}()
    SVG_PATH_OPS[uc] = (v, uc)
    SVG_PATH_OPS["$uc"] = (v, uc)
    SVG_PATH_OPS[lc] = (v, lc)
    SVG_PATH_OPS["$lc"] = (v, lc)
end    

svg_pathd(args::Vector) = svg_pathd(args...)

function svg_pathd(op, args...)
    # If any arg is a Point, spread its coordinates:
    nargs = []
    for arg in args
        if arg isa Point
            push!(nargs, arg.x, arg.y)
        else
            push!(nargs, arg)
        end
    end
    svg_pathd(SVG_PATH_OPS[op]..., nargs...)
end

function svg_pathd(op::Val{:M}, char::Char, x, y)
    (char, user_units_val(x), user_units_val(y))
end

function svg_pathd(op::Val{:Z}, char::Char)
    (char,)
end

function svg_pathd(op::Val{:L}, char::Char, coords...)
    @assert iseven(length(coords))
    (char, map(user_units_val, coords)...)
end

function svg_pathd(op::Val{:H}, char::Char, x)
    (char, user_units_val(x))
end

function svg_pathd(op::Val{:V}, char::Char, y)
    (char, user_units_val(y))
end

function svg_pathd(op::Val{:C}, char::Char, x1, y1, x2, y2, x, y)
    (char,
     user_units_val(x1), user_units_val(y1),
     user_units_val(x2), user_units_val(y2),
     user_units_val(x), user_units_val(y))
end

function svg_pathd(op::Val{:A}, char::Char, rx, ry,
                   x_axis_rotation, large_arc_flag, sweep_flag,
                   x, y)
    (char,
     user_units_val(rx), user_units_val(ry),
     x_axis_rotation, large_arc_flag, sweep_flag,
     user_units_val(x), user_units_val(y))
end

function svg_pathd(op::Val{:Q}, char::Char, coords...)
    @assert (length(coords) % 4) == 0
    (char, map(user_units_val, coords)...)
end

function svg_pathd(op::Val{:T}, char::Char, coords...)
    @assert iseven(length(coords))
    (char, map(user_units_val, coords)...)
end

# register the methods:
function init_path_ops()
    for m in methods(svg_pathd)
        p = m.sig.parameters
        if length(p) < 2; continue; end
        if !hasproperty(p[2], :parameters); continue; end
        if length(p[2].parameters) != 1; continue; end
        if p[2].name != Base.typename(Val); continue; end
        if !isa(p[2].parameters[1], Symbol); continue; end
        op_str = string(p[2].parameters[1])
        op_char = op_str[1]
        register_pathd_op(op_char)
    end
end

