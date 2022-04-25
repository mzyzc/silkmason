-- Add a HTML file extension to links with no extension

function Link(link)
    local ext = link.target:match ("%.(.*)$")

    if not ext then
        link.target = link.target .. ".html"
    end

    return link
end