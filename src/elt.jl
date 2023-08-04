export elt

# Copied from TabletWeaving.jl

# XML.jl convenience function for making elements:
function elt(tag::String, stuff...)
    attributes = Dict{Symbol, String}()
    children = []
    for s in stuff
        if s isa Pair
            attributes[s.first] = string(s.second)
        elseif s isa AbstractString
            push!(children, XML.Text(s))
        elseif s isa Number
            push!(children, XML.Text(string(s)))
        elseif s isa XML.Node
            push!(children, s)
        else
            error("unsupported XML content: $s")
        end
    end
    XML.Node(XML.Element, tag, attributes, nothing, children)
end

