-- Check if a file is marked as hidden
function isHidden (filename) return string.sub (filename, 1, 1) ~= '.' end

-- Split a string at delimiters
local function splitString (string, delimiter)
    local stringSegments = {}

    -- Match all segments between the . symbols
    for segment in string.gmatch (string, "[^%"..delimiter.."]+") do
        table.insert (stringSegments, segment)
    end

    return stringSegments
end

function splitFilePath (filePath) return splitString (filePath, '/') end
function splitFileName (filename) return splitString (filename, '.') end

-- Join a string at delimiters
local function joinString (string, delimiter)
    local stringBuilder = string[1]

    for i = 2, #string do
        stringBuilder = stringBuilder..delimiter..string[i]
    end

    return stringBuilder
end

function joinFilePath (filePath)
    -- Join the filename into a string first
    filePath[#filePath] = joinFileName (filePath[#filePath])
    return joinString (filePath, '/')
end

function joinFileName (filename) return joinString (filename, '.') end
