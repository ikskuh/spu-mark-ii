local Peripherial = {}

function Peripherial.Register(name, offset, size, access, desc)
  local reg = {
    name = name or error("requires name!"),
    offset = tonumber(offset) or error("requires offset!"),
    size = tonumber(size) or error("requires size!"),
    access = tostring(access) or error("requires access"),
    desc = desc or "Missing description",
  }
  if reg.size ~= 1 and reg.size ~= 2 then
    error("size must be 1 or 2")
  end
  if reg.access ~= "RO" and reg.access ~= "WO" and reg.access ~= "RW" then
    error ("access must be RO, WO or RW")
  end
  
  return function(details)
    if details ~= nil then
      reg.details = tostring(details)
    end
    return reg
  end
end

function Peripherial.RegisterSet(set)
  for i=1,#set do
    local reg = set[i]

    if type(reg) == "function" then
     reg = reg(nil) -- no details given
    end

    set[i] = reg
  end
  return set
end

local function flattenString(string)
  local indent
  return string:gsub("[^\n]+", function(line)
    if indent == nil then
      indent = line:match("%s+")
    end
    return line:sub(#indent + 1)
  end)
end

function Peripherial.RegisterChapter(datasheet, chapter)
  
  local str = ""

  str = str .. "| Offset  | Name  | Size | Access | Description                                |" .. "\n"
  str = str .. "|---------|-------|------|--------|--------------------------------------------|" .. "\n"

  for i=1,#datasheet.registers do
    local reg = datasheet.registers[i]

    local access = ({
      RO = "R",
      WO = "W",
      RW = "R/W",
    })[reg.access]

    str = str .. ("| `0x%03X` | %-5s | %4d | %-6s | %-42s |\n"):format(
      reg.offset,
      reg.name,
      reg.size,
      access,
      reg.desc
    )
    
  end

  for i=1,#datasheet.registers do
    local reg = datasheet.registers[i]
    if reg.details and #reg.details > 0 then
      str = str .. "\n"
      str = str .. "### " .. reg.desc .. "\n\n"
      str = str .. flattenString(reg.details) 
    end
  end

  return str
end

return Peripherial