
export Rectangle,
    left, top, right, bottom, width, height,
    enlarge, svg_attributes

"""
    Rectangle(; left, top, right, bottom, width, height)

Defines a geometric rectangle given at leat two out of three
measurements in each direction.

The functions `left`, 'top`, `right`, and `bottom`,
return coordinates of the corners of the rectangle.

The functions `width` and `height` return the width and height,
respectively.
"""
struct Rectangle
    left
    top
    width
    height

    function Rectangle(;
                       left=missing, top=missing,
                       right=missing, bottom=missing,
                       width=missing, height=missing)
        if sum(x -> (x isa Missing) ? 0 : 1, [left, right, width]) < 2
            error("at least two of left, right, and width must be specified")
        end
        if sum(x -> (x isa Missing) ? 0 : 1, [top, bottom, height]) < 2
            error("at least two of top, bottom, and height must be specified")
        end
        if left isa Missing
            left = right - width
        end
        if right isa Missing
            right = left + width
        end
        if width isa Missing
            width = right - left
        end
        if top isa Missing
            top = bottom - height
        end
        if bottom isa Missing
            bottom = top + height
        end
        if height isa Missing
            height = bottom - top
        end
        @assert width > zero(width)
        @assert height > zero(height)
        new(left, top, width, height)
    end
end


left(r::Rectangle) = r.left
top(r::Rectangle) = r.top
right(r::Rectangle) = r.left + r.width
bottom(r::Rectangle) = r.top + r.height
width(r::Rectangle) = r.width
height(r::Rectangle) = r.height


"""
    enlarge(r::Rectangle, x_amount, y_amount)::Rectangle

Returns a new Rectangle that is expanded in each direction by
the specified amounts.
"""
function enlarge(r::Rectangle, x_amount, y_amount)::Rectangle
    Rectangle(;
              left = left(r) - x_amount,
              top = top(r) - y_amount,
              right = right(r) + x_amount,
              bottom = bottom(r) + y_amount)
end

"""
    svg_attributes(r::Rectangle)

Returns a tuple of Pairs providing the `x`, `y`, `width`, and `height`
attributes for an SVG rect for rendering this Rectangle.
"""
function svg_attributes(r::Rectangle)
    (:x => svgval(left(r)),
     :y => svgval(top(r)),
     :width => svgval(width(r)),
     :height => svgval(height(r)))
end

