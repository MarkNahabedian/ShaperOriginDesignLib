
@testset "Geometric rectangles" begin
    rectLTRB = Rectangle(;
                      left = 0u"cm",
                      top = 1u"cm",
                      right = 2u"cm",
                      bottom = 3u"cm")
    @test width(rectLTRB) == right(rectLTRB) - left(rectLTRB)
    @test height(rectLTRB) == bottom(rectLTRB) - top(rectLTRB)
    rectLTWH = Rectangle(;
                         left = left(rectLTRB),
                         top = top(rectLTRB),
                         width = width(rectLTRB),
                         height = height(rectLTRB))
    @test rectLTRB == rectLTWH
    rectWHLB = Rectangle(;
                         width = width(rectLTRB),
                         height = height(rectLTRB),
                         right = right(rectLTRB),
                         bottom = bottom(rectLTRB))
    @test rectLTRB == rectWHLB
    rectE = enlarge(rectLTRB, 1u"cm", 2u"cm")
    @test left(rectE) == left(rectLTRB) - 1u"cm"
    @test right(rectE) == right(rectLTRB) + 1u"cm"
    @test top(rectE) == top(rectLTRB) - 2u"cm"
    @test bottom(rectE) == bottom(rectLTRB) + 2u"cm"
    @test svg_attributes(rectLTRB) ==
        (:x => svgval(left(rectLTRB)),
         :y => svgval(top(rectLTRB)),
         :width => svgval(width(rectLTRB)),
         :height => svgval(height(rectLTRB)))
end

