#!/usr/bin/env lua

local args = {...}

local bits = {
-- {"0", 1}, -- {name, bits}
}

local original = "./genbits.lua"
for i = 1, #args, 2 do
	local num = tonumber(args[i + 1])
	assert(num, "unable to numify " .. tostring(args[i + 1]))
	table.insert(bits, {args[i], num})
	original = original .. " " .. args[i] .. " " .. num
end

local bitCount = 0
for _, v in ipairs(bits) do
	bitCount = bitCount + v[2]
end
local highBit = bitCount - 1
for _, v in ipairs(bits) do
	local lowBit = ((highBit - v[2]) + 1)
	if highBit == lowBit then
		v[3] = "[" .. highBit .. "]"
	else
		v[3] = "[" .. highBit .. ":" .. lowBit .. "]"
	end
	highBit = highBit - v[2]
end

local margin = 24
local bitWidth = 80
local bitHeight = 56
local width = (margin * 2) + (bitCount * bitWidth)
local height = 120
local bitY = 48
local textY = 88
local textYUp = 40

print("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>")
print("<svg width=\"" .. width .. "\" height=\"" .. height .. "\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\">")
print("<!-- " .. original .. " -->")
local hX = margin

print("<rect")
print("style=\"fill:#ffffff;stroke:none\"")
print("width=\"" .. width .. "\" height=\"" .. height .. "\"")
print("x=\"0\" y=\"0\"/>")

for _, v in ipairs(bits) do
	local lW = v[2] * bitWidth
	print("<rect")
	print("style=\"fill:#ffffff;stroke:#000000;stroke-width:2px\"")
	print("width=\"" .. lW .. "\" height=\"" .. bitHeight .. "\"")
	print("x=\"" .. hX .. "\" y=\"" .. bitY .. "\"/>")

	print("<text")
	print("xml:space=\"preserve\"")
	print("style=\"font-style:normal;font-weight:normal;font-size:32px;font-family:sans-serif;text-align:center;text-anchor:middle;fill:#000000;stroke:none\"")
	print("x=\"" .. (hX + (lW / 2)) .. "\" y=\"" .. textYUp .. "\">" .. v[3] .. "</text>")

	print("<text")
	print("xml:space=\"preserve\"")
	print("style=\"font-style:normal;font-weight:normal;font-size:32px;font-family:sans-serif;text-align:center;text-anchor:middle;fill:#000000;stroke:none\"")
	print("x=\"" .. (hX + (lW / 2)) .. "\" y=\"" .. textY .. "\">" .. v[1] .. "</text>")
	hX = hX + lW
end
print("</svg>")
