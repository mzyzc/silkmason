-- Set the document description to the first paragraph

local description

local function get_description (paragraph)
    if not description then
        description = paragraph.content
    end
    return nil
end

return {
    {Meta = function (meta) description = meta.description end},
    {Para = get_description},
    {Meta = function (meta) meta.description = description; return meta end},
}
