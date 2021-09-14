# SVG line styles for the different kinds of cut paths of the Shaper Origin:

export shaper_cut_attributes

shaper_cut_attributes = Dict(
	:inside_cut => Dict(
		"fill" => "white",
		"stroke" => "black",
		"stroke-width" => "0.01",
		"opacity" => "1.0"),
	:outside_cut => Dict(
		"fill" => "black",
		"stroke" => "black",
		"stroke-width" => "0.01",
		"opacity" => "1.0"
	),
	:on_line_cut => Dict(
		"fill" => "none",
		"stroke" => "gray",
		"stroke-width" => "0.01",
		"opacity" => "1.0"
	),
	:on_line_cut => Dict(
		"fill" => "none",
		"stroke" => "gray",
		"stroke-width" => "0.01",
		"opacity" => "1.0"
	),
	:pocket_cut => Dict(
		"fill" => "gray",
		"stroke" => "none",
		"opacity" => "1.0"
	),
	:guide_line => Dict(
		"fill" => "none",
		"stroke" => "blue",
		"stroke-width" => "0.01",
		"opacity" => "1.0"
	)
)
