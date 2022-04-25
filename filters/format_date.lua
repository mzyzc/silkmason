-- Take the 'date' metadata and format it in a friendlier form for displaying

function Meta(meta)
  if meta.date then

    -- Split date string into year, month, and day
    local date = {}
    for unit in meta.date[1].text:gmatch ("([^-]+)") do
            table.insert (date, unit)
    end

    date = os.time {year = date[1], month = date[2], day = date[3]}
    meta.datef = os.date ("%e %B %Y", date)
    return meta
  end
end
