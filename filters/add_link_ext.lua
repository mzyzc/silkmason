-- Add a HTML file extension to links with no extension

function Link(link)
    if link.target:sub (-1, -1) == "/" then return end

    local ext = link.target:match ("%.(.*)$")
    if ext then return end

    link.target = link.target .. ".html"
    return link
end