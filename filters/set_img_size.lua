-- Set 'width' and 'height' attributes of image elements

local function run (command)
    local handle = io.popen (command)
    if handle == nil then return end
    local data = handle:read ("*a")
    handle:close ()

    return data
end

local root = (run ("tomlq -r .input_dir config.toml")):gsub ("~", os.getenv ("HOME"))
root = root:gsub ("~", os.getenv ("HOME"))
root = root:gsub ("\n", "")

function Image (img)
    if img.src:match ("^https?://") then
        return
    end

    local path

    if img.src:match ("^/") then
        path = root..img.src
    else
        path = pandoc.path.make_relative (img.src, root)
    end

    img.attributes["width"] = run ("identify -format '%w' "..path)
    img.attributes["height"] = run ("identify -format '%h' "..path)

    return img
end