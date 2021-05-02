require "lfs"
require "lib/file"

inputDir = arg[1]
outputDir = arg[2]

function handleDirectory (dir)
    for file in lfs.dir (dir) do
        if isHidden (file) then
            local attributes = lfs.attributes (dir..'/'..file)
            if attributes.mode == "directory" then
                local prefixDir = string.gsub (dir, inputDir, outputDir)
                lfs.mkdir (prefixDir..'/'..file)
                handleDirectory (dir..'/'..file)
            elseif attributes.mode == "file" then
                handleFile (dir..'/'..file)
            end
        end
    end
end

function handleFile (file)
    local splitFile = splitFilePath (file)
    splitFile[#splitFile] = splitFileName (splitFile[#splitFile])

    local baseFile = splitFile[#splitFile]

    -- Convert Markdown files to HTML
    if baseFile[#baseFile] == "md" then
        baseFile[#baseFile] = "html"
        local outputFile = '/'..joinFilePath (splitFile)
        outputFile = string.gsub (outputFile, inputDir, outputDir)

        os.execute ("pandoc -i "..file.." -o "..outputFile)
    end

    print (file)
end

handleDirectory (inputDir)
