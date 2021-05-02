require "lfs"
require "lib/file"

inputDir = arg[1]
outputDir = arg[2]

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
