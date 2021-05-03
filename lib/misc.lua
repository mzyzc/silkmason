require "lib/file"

-- Check if a value is empty or nil
function isEmpty (x) return s == nil or s == '' end

-- Modify a path to match the output directory
function getOutputPath (path, inputDir, outputDir)
    local outputFile = joinFilePath (path)
    outputFile = string.gsub (outputFile, inputDir, outputDir)
    return outputFile
end
