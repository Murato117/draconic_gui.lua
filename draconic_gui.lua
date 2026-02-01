-- ===== PERIPHERALS =====
local core = peripheral.find("draconic_rf_storage")
local fgIn = peripheral.find("flow_gate")
local fgOut = peripheral.find("flow_gate", function(_, p) return p ~= fgIn end)
local mon = peripheral.find("monitor")
if not mon then error("MONITOR NOT FOUND") end
mon.setTextScale(0.5)

-- ===== CONSTANTS =====
local STEP = 50000
local MIN_FLOW = 0
local MAX_FLOW = 999999999

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

-- ===== CORE BALL =====
local function drawCore(x, y, pulse)
  local c1 = (pulse % 2 == 0) and colors.orange or colors.yellow
  local c2 = (pulse % 2 == 0) and colors.yellow or colors.orange
  local rows = {
    "  ####  ",
    " ###### ",
    "########",
    "########",
    " ###### ",
    "  ####  "
  }

  for i = 1, #rows do
    for j = 1, #rows[i] do
      if rows[i]:sub(j, j) == "#" then
        mon.setBackgroundColor(((i + j + pulse) % 2 == 0) and c1 or c2)
        mon.setCursorPos(x + j - 1, y + i - 1)
        mon.write(" ")
      end
    end
  end
end

-- ===== MAIN DRAW =====
local function draw(pulse)
  mon.setBackgroundColor(colors.black)
  mon.clear()

  local stored = core.getEnergyStored()
  local max = core.getMaxEnergyStored()
  local percent = math.floor((stored / max) * 100)
  local inFlow = fgIn.getFlow()
  local outFlow = fgOut.getFlow()

  -- PANELS
  frame(2, 2, 24, 12, colors.lightGray)
  frame(27, 2, 22, 12, colors.lightGray)
  frame(27, 15, 22, 10, colors.lightGray)

  -- TITLES
  text(4, 2, "ENERGY CORE")
  text(29, 2, "DETAILS")
  text(29, 15, "CONTROLS")

  -- CORE
  drawCore(6, 5, pulse)

  -- DETAILS
  text(29, 4, "Tier: 7")
  text(29, 5, "Stored:")
  text(29, 6, fmt(stored).." / INF RF", colors.lime)
  text(29, 7, "Fill: "..percent.."%")
  text(29, 9, "Input Max:")
  text(40, 9, fmt(inFlow).." RF/t", colors.lime)
  text(29, 10, "Output Max:")
  text(40, 10, fmt(outFlow).." RF/t", colors.red)

  -- BUTTONS
  mon.setBackgroundColor(colors.green)
  mon.setCursorPos(29, 17)
  mon.write(" + INPUT ")

  mon.setCursorPos(38, 17)
  mon.write(" - INPUT ")

  mon.setBackgroundColor(colors.red)
  mon.setCursorPos(29, 19)
  mon.write(" + OUTPUT")

  mon.setCursorPos(38, 19)
  mon.write(" - OUTPUT")
end

-- ===== MAIN LOOP =====
local pulse = 0
draw(pulse)

local timer = os.startTimer(0.3)

while true do
  local e, a, b, c = os.pullEvent()

  if e == "timer" and a == timer then
    pulse = pulse + 1
    drawCore(6, 5, pulse)
    timer = os.startTimer(0.3)
  end

  if e == "monitor_touch" then
    local x, y = b, c

    -- INPUT +
    if y == 17 and x >= 29 and x <= 36 then
      fgIn.setFlow(math.min(fgIn.getFlow() + STEP, MAX_FLOW))
      draw(pulse)
    end

    -- INPUT -
    if y == 17 and x >= 38 and x <= 45 then
      fgIn.setFlow(math.max(fgIn.getFlow() - STEP, MIN_FLOW))
      draw(pulse)
    end

    -- OUTPUT +
    if y == 19 and x >= 29 and x <= 36 then
      fgOut.setFlow(math.min(fgOut.getFlow() + STEP, MAX_FLOW))
      draw(pulse)
    end

    -- OUTPUT -
    if y == 19 and x >= 38 and x <= 45 then
      fgOut.setFlow(math.max(fgOut.getFlow() - STEP, MIN_FLOW))
      draw(pulse)
    end
  end
end
