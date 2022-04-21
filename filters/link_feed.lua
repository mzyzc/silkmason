-- Add a webfeed link to pages which have feeds

local is_feed_page
local counter = 0

function add_link (header)
    if not is_feed_page then return header end
    if not (header.level == 1) then return header end
    if not (counter == 0) then return header end

    link = pandoc.Link ("", "feed.xml", "", "feed")
    table.insert (header.content, link)

    counter = counter + 1
    return header
end

return {
    {Meta = function (meta) is_feed_page = meta.feed end},
    {Header = add_link},
}
