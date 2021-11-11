#!/usr/bin/env lua5.3

local root_path = arg[0]:gsub("/[^/]+", "")
package.path = root_path .. "/modules/?.lua;" .. package.path


local Datasheet = require "Datasheet"

local loadDB = require "Database"

local db = loadDB(root_path)

for i=1,#db.datasheets do
  local ds = db.datasheets[i]

  local output_path = root_path .. "/../documentation/specs/" .. ds.id .. ".md"

  print("Rendering "..output_path)

  local f = io.open(output_path, "wb")

  Datasheet.renderMarkdown(
    ds,
    function(text) 
      f:write(text)
    end
  )
  f:close()

end
