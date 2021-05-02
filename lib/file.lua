-- Check if a file is marked as hidden
function isHidden (filename) return string.sub (filename, 1, 1) ~= '.' end

-- Split the filename into its basename and extensions, using . as a delimiter
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
