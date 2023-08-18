
export Point, dot, distance, angle

struct Point
    x
    y
end

(Base.:+)(p1::Point, p2::Point) = Point(p1.x + p2.x, p1.y + p2.y)
(Base.:-)(p1::Point, p2::Point) = Point(p1.x - p2.x, p1.y - p2.y)

dot(p1::Point, p2::Point) = p1.x * p2.x + p1.y * p2.y

distance(x1, y1, x2, y2) = sqrt((x2 - x1)^2 + (y2 - y1)^2)

distance(p::Point) = sqrt((p.x)^2 + (p.y)^2)

@assert distance(Point(3, 4)) == 5

function angle(vertex::Point, p1::Point, p2::Point)
    v1 = p1 - vertex
    v2 = p2 - vertex
    acos(dot(v1, v2) / (distance(v1) * distance(v2)))
end

@assert angle(Point(0, 0), Point(1, 0), Point(1, sqrt(3))) == pi/3

