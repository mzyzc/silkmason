-- Set 'width' and 'height' attributes of image elements

local toml = require "toml"

local file = io.open ("config.toml", "r")
io.input (file)
local data = io.read("*a")
data = toml.parse (data)
file:close ()

local root = data ["input_dir"]
root = root:gsub ("~", os.getenv ("HOME"))
root = root:gsub ("\n", "")

function Image (img)
    if img.src:match ("^https?://") then
        return
    end

    if img.src:match ("%.mp4$") then
        return
    end

    local path

    if img.src:match ("^/") then
        path = root..img.src
    else
        path = pandoc.path.make_relative (img.src, root)
    end

    img.attributes["width"] = pandoc.pipe ("identify", {"-format", "%w", path}, "")
    img.attributes["height"] = pandoc.pipe ("identify", {"-format", "%h", path}, "")

    return img
end