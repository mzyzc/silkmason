-- Set the document title to be the same as the top-level heading

local title

local function get_title (header)
    if not title and header.level == 1 then
        title = header.content
    end
    return nil
end

return {
    {Meta = function (meta) title = meta.title end},
    {Header = get_title},
    {Meta = function (meta) meta.title = title; return meta end},
}
