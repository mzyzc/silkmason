require "lfs"

inputDir = arg[1]
outputDir = arg[2]

-- Check if a file is marked as hidden
local function isHidden (filename) return string.sub (filename, 1, 1) ~= '.' end

function handleDirectory (dir)
    for file in lfs.dir (dir) do
        if isHidden (file) then
            local attributes = lfs.attributes (dir..'/'..file)
            if attributes.mode == "directory" then
                handleDirectory (dir..'/'..file)
            elseif attributes.mode == "file" then
                handleFile (dir..'/'..file)
            end
        end
    end
end

function handleFile (file)
    print (file)
end

handleDirectory (inputDir)
