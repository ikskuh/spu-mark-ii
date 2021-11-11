local device_map = require "specification/device_map"

local devices = {}
local tot_gpio = 0

for i,v in ipairs(device_map) do
  for n=1,v.count do
    local dev = {
      name = v.name,
      gpio = v.gpio,
    }
    if v.count > 1 then
      dev.index = n
      dev.name = dev.name .. (" (%d)"):format(n)
    end
    devices[#devices+1] = dev

    if #dev.gpio > 0 then
      print(dev.name .. " => " .. tostring(#dev.gpio))
    end

    tot_gpio = tot_gpio + #dev.gpio
    
  end
end

print("total gpio count:", tot_gpio)