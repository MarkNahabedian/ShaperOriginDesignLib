
export Line, coefficients, vector_parametric
export direction, normal_vector, intercept
export translate, point_on_line, point_in_segment, intersetction


"""
Line models a line segment.
"""
struct Line
    point1::Point
    point2::Point

    function Line(point1, point2)
        @assert point1 != point2
        new(point1, point2)
    end
end

"""
    coefficients(::Line)

Return the coefficients A, B, and C of the equation of the Line
`Ax + By + C = 0`
"""
function coefficients(line::Line)
    x1 = line.point1.x
    x2 = line.point2.x
    y1 = line.point1.y
    y2 = line.point2.y
    A = y1 - y2
    B = x2 - x1
    C = x1 * y2 - x2 * y1
    return A, B, C
end


"""
    vector_parametric(line::Line)

Return two vectors V and C (represented as Points) defining the line,
such that
`[x, y] = Vt + C`
for some scalar parameter t which varies for each poiint on the
line.
"""
function vector_parametric(line::Line)
    return line.point2 - line.point1, line.point1
end


# Length of the line segment
distance(line::Line) = distance(line.point1, line.point2)


direction(line::Line) = direction(line.point2, line.point1)


function normal_vector(line::Line)
    Point(line.point1.y - line.point2.y,
          line.point2.x - line.point1.x)
end


function translate(line::Line, displacement::Point)
    Line(line.point1 - displacement,
         line.point2 - displacement)
end

function translate(line::Line, delta_x, delta_y)
    translate(line, Point(delta_x, delta_y))
end


function intercept(line::Line)
    delta = line.point2 - line.point1
    u = unit(line.point1.x)
    if ustrip(delta.x) == 0
        return Point(line.point1.x, 0 * u)
    else
        m = delta.y / delta.x
        return Point(0 * u, line.point1.y - m * line.point1.x)
    end
    #=
    -1 * elementwise_product(delta, line.point1)
    =#
end


function point_on_line(point::Point, line::Line)::Bool
    A, B, C = coefficients(line)
    A * point.x + B * point.y + C == 0
end


function point_in_segment(point::Point, line::Line)::Bool
    if !point_on_line(point, line)
        return false
    end
    x1 = min(line.point1.x, line.point2.x)
    x2 = max(line.point1.x, line.point2.x)
    y1 = min(line.point1.y, line.point2.y)
    y2 = max(line.point1.y, line.point2.y)
    point.x >= x1 && point.x <= x2 &&
        point.y >= y1 && point.y <= y2
end


function intersetction(line1::Line, line2::Line)::Point
    a1, b1, c1 = coefficients(line1)
    a2, b2, c2 = coefficients(line2)
    println([a1 b1; a2 b2])
    return Point((inv([a1 b1; a2 b2]) * [-c1; -c2])...)
end

