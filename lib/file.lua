-- Check if a file is marked as hidden
function isHidden (filename) return string.sub (filename, 1, 1) == '.' end

-- Split a string at specified delimiters
local function splitString (string, delimiter)
    local stringSegments = {}

    -- Match all segments between the . symbols
    for segment in string.gmatch (string, "[^%"..delimiter.."]+") do
        table.insert (stringSegments, segment)
    end

    return stringSegments
end

-- Split a path on its directories
function splitFilePath (filePath) return splitString (filePath, '/') end

-- Split a filename on its extensions
function splitFileName (filename) return splitString (filename, '.') end

-- Join a string with specified delimiters
local function joinString (list, delimiter)
    local stringBuilder = list[1]

    for i = 2, #list do
        stringBuilder = stringBuilder..delimiter..list[i]
    end

    return stringBuilder
end

-- Join a path at its directories
function joinFilePath (filePath)
    -- Join the file and its extensions first
    filePath[#filePath] = joinFileName (filePath[#filePath])
    return '/'..joinString (filePath, '/')
end

-- Join a filename at its extensions
function joinFileName (filename) return joinString (filename, '.') end
