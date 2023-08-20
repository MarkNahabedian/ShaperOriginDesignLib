
export Point, dot, elementwise_product, distance, normalize, direction

struct Point
    x
    y
end

Base.length(point::Point) = 2

function Base.iterate(point::Point)
    return point.x, :y
end

function Base.iterate(point::Point, state)
    if state == :y
        return point.y, :done
    end
end


(Base.:(==))(p1::Point, p2::Point) = p1.x == p2.x && p1.y == p2.y
(Base.:+)(p1::Point, p2::Point) = Point(p1.x + p2.x, p1.y + p2.y)
(Base.:-)(p1::Point, p2::Point) = Point(p1.x - p2.x, p1.y - p2.y)

(Base.:*)(n::Number, p::Point) = Point(n * p.x, n * p.y)
(Base.:/)(p::Point, n::Number) = Point(p.x / n, p.y / n)

dot(p1::Point, p2::Point) = p1.x * p2.x + p1.y * p2.y

elementwise_product(p1::Point, p2::Point) = p1.*p2

distance(x1, y1, x2, y2) = sqrt((x2 - x1)^2 + (y2 - y1)^2)

distance(p::Point) = sqrt((p.x)^2 + (p.y)^2)

normalize(p::Point) = p / distance(p)


function direction(point1::Point, point2::Point)
    delta = point2 - point1
    atan(delta.y, delta.x)
end


function direction(vertex::Point, p1::Point, p2::Point)
    v1 = p1 - vertex
    v2 = p2 - vertex
    acos(dot(v1, v2) / (distance(v1) * distance(v2)))
end

