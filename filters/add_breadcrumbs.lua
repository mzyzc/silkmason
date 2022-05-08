-- Add breadcrumb navigation to non-index pages

local toml = require "toml"

local file = io.open ("config.toml", "r")
io.input (file)
local data = io.read("*a")
data = toml.parse (data)
file:close ()

local root = data ["input_dir"]
root = root:gsub ("~", os.getenv ("HOME"))
root = root:gsub ("\n", "")

function Pandoc(doc)
    local blocks = {}

    -- Get the path of the current file
    local path_string = PANDOC_STATE.input_files[1]
    path_string = path_string:gsub ("index%..*$", "") -- Exclude index pages (they're implied when the path with a directory)
    path_string = pandoc.path.make_relative (path_string, root)
    local path_list = pandoc.path.split (path_string)

    -- Only affect pages that are deep enough
    if #path_list < 3 then return end

    local links = {}

    local dirs_so_far = {"/"}
    table.remove (path_list, #path_list) -- No need to link back to the current page

    -- Add links to breadcrumb list
    for _, file in ipairs (path_list) do
        table.insert (dirs_so_far, file)

        local link = pandoc.Link (
            file,
            pandoc.path.join (dirs_so_far).."/"
        )
        table.insert (links, link)
    end

    -- Add ID
    local attributes = {}
    attributes["id"] = "crumbs"

    -- Finish it off
    local crumbs = pandoc.Div (
        pandoc.OrderedList (links),
        attributes
    )

    table.insert (blocks, crumbs)

    -- Keep the rest of the page
    for _, elem in ipairs (doc.blocks) do
        table.insert (blocks, elem)
    end

    return pandoc.Pandoc (blocks, doc.meta)
end