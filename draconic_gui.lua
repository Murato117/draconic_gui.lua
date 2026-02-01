-- ===== PERIPHERALS =====
local core = peripheral.find("draconic_rf_storage")
local fgIn = peripheral.find("flow_gate")
local fgOut = peripheral.find("flow_gate", function(_, p) return p ~= fgIn end)
local mon = peripheral.find("monitor")
if not mon then error("MONITOR NOT FOUND") end

mon.setTextScale(0.5)

-- ===== HELPERS =====
local function text(x, y, t, fg, bg)
  mon.setTextColor(fg or colors.white)
  mon.setBackgroundColor(bg or colors.black)
  mon.setCursorPos(x, y)
  mon.write(tostring(t))
end

local function frame(x, y, w, h, c)
  mon.setTextColor(c)
  mon.setCursorPos(x, y)
  mon.write("+" .. string.rep("-", w-2) .. "+")
  for i = 1, h-2 do
    mon.setCursorPos(x, y+i)
    mon.write("|")
    mon.setCursorPos(x+w-1, y+i)
    mon.write("|")
  end
  mon.setCursorPos(x, y+h-1)
  mon.write("+" .. string.rep("-", w-2) .. "+")
end

local function fmt(n)
  if n >= 1e12 then return string.format("%.1fT", n/1e12)
  elseif n >= 1e9 then return string.format("%.1fG", n/1e9)
  elseif n >= 1e6 then return string.format("%.1fM", n/1e6)
  elseif n >= 1e3 then return string.format("%.1fk", n/1e3)
  else return tostring(n) end
end

-- ===== MAIN DRAW =====
local function draw()
  mon.setBackgroundColor(colors.black)
  mon.clear()

  local stored = tonumber(core.getEnergyStored()) or 0
  local max = tonumber(core.getMaxEnergyStored()) or 1
  local percent = math.floor((stored / max) * 100)

  local inFlow = tonumber(fgIn.getFlow()) or 0
  local outFlow = tonumber(fgOut.getFlow()) or 0

  -- PANELS
  frame(2, 2, 24, 12, colors.lightGray)   -- ENERGY CORE
  frame(27, 2, 22, 12, colors.lightGray)  -- DETAILS
  frame(2, 15, 24, 10, colors.lightGray)  -- LOGS
  frame(27, 15, 22, 10, colors.lightGray) -- CONTROLS

  -- TITLES
  text(4, 2, "ENERGY CORE")
  text(29, 2, "DETAILS")
  text(4, 15, "LOGS")
  text(29, 15, "CONTROLS")

  -- DETAILS
  text(29, 4, "Tier: 7")
  text(29, 5, "Stored:")
  text(29, 6, fmt(stored).." / INF RF", colors.lime)
  text(29, 7, "Fill: "..percent.."%")
  text(29, 9, "Input Max:")
  text(40, 9, fmt(inFlow).." RF/t", colors.lime)
  text(29, 10, "Output Max:")
  text(40, 10, fmt(outFlow).." RF/t", colors.red)
  text(29, 12, "Limited:")
  text(40, 12, "ON", colors.green)

  -- CONTROLS
  mon.setBackgroundColor(colors.green)
  mon.setCursorPos(29, 17)
  mon.write("  Edit Input Max ")

  mon.setBackgroundColor(colors.red)
  mon.setCursorPos(29, 19)
  mon.write("  Edit Output Max")

  mon.setBackgroundColor(colors.orange)
  mon.setCursorPos(29, 21)
  mon.write("    Edit Config  ")

  mon.setBackgroundColor(colors.black)
  text(30, 23, "Not Used Yet", colors.gray)

  -- LOGS (STATIC)
  text(4, 17, "[2024-11-06 19:49]")
  text(4, 18, "Changed Output Max")
  text(4, 19, "Detected Flow Gates")

  -- FOOTER
  text(32, 26, "Version 1.0", colors.gray)
end

-- ===== LOOP =====
while true do
  draw()
  sleep(0.5)
end
