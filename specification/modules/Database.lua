require "lfs"

local Datasheet = require "Datasheet"

local function load(root_path)
  local datasheets = {}

  for path in lfs.dir(root_path.."/devices") do
    if path:match(".lua$") then
      local full_path = root_path.."/devices/" .. path
      local ds = dofile(full_path) or error(path .. " does not return a datasheet!")
      ds.id = ds.id or path:gsub(".lua$", "")
      ds.full_path = full_path   
      table.insert(datasheets, ds)
      if datasheets[ds.id] then
        error("A datasheet with the id " .. ds.id .. " already exists!")
      end
      datasheets[ds.id] = ds
    end
  end

  return {
    datasheets = datasheets,
  }
end

return load