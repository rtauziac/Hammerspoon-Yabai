-- Test 
--[[ hs.hotkey.bind({"cmd", "alt", "ctrl"}, "W", function()
  hs.notify.new({title="Hammerspoon", informativeText="Hello World"}):send()
end) ]]

local previousAppNameAlert = nil
local focusHistory = {}
local historySize = 8
local justTiled2W = false -- used to track if we toggle 
local canvas = require("hs.canvas")

local screenWidth = hs.screen.mainScreen():fullFrame().w
local screenHeight = hs.screen.mainScreen():fullFrame().h

local mainScreenCanvas = canvas.new({x=0, y=0, w=screenWidth, h=screenHeight})

local lineElement = {
  action = "fill", type = "rectangle", fillColor = { red=1.0, green=1.0, blue=1.0, alpha=0.5 }, frame = {x=0, y=23, w="100%", h=10}, padding = 0
}
mainScreenCanvas:appendElements(lineElement)

-- mainScreenCanvas:show()

hs.window.animationDuration = 0

--////////////////
--//// TILING ////
--////////////////
-- //// LEFT
-- hs.hotkey.bind({"ctrl", "alt"}, "a", function()
--   local currentWindow = hs.window.focusedWindow()
--   local currentApp = currentWindow:application()
--   tileLeft(currentWindow:title())
-- end)
-- //// MAXIMIZED
-- hs.hotkey.bind({"ctrl", "alt"}, "é", function()
--   local currentWindow = hs.window.focusedWindow()
--   local currentApp = currentWindow:application()
--   maximize(currentWindow:title())
-- end)
-- //// RIGHT
-- hs.hotkey.bind({"ctrl", "alt"}, "i", function()
--   local currentWindow = hs.window.focusedWindow()
--   local currentApp = currentWindow:application()
--   tileRight(currentWindow:title())
-- end)
-- //// TILE THE LAST 2 WINDOWS
-- hs.hotkey.bind({"ctrl", "alt"}, "u", function()
--   local windowR = focusHistory[#focusHistory]
--   local windowL = focusHistory[#focusHistory-1]
--   if justTiled2W then
--     windowR = focusHistory[#focusHistory-1]
--     windowL = focusHistory[#focusHistory]
--     justTiled2W = false
--   else
--     justTiled2W = true
--   end

--   if windowL and windowR and windowL ~= windowR then
--     tileLeft(windowL:title())
--     tileRight(windowR:title())
--   end
-- end)

-- //// GLOBAL MENU
-- hs.hotkey.bind({"ctrl", "alt", "shift"}, "return", function()
--   local ch = hs.chooser.new(function(option)
--     if option then
--       if option.alert then
--         hs.alert(option.alert)
--       end
      
--       if option.cmd == "reset" then
--         hs.reload()
--       end
--     end
--   end)
--   ch:bgDark(false)
--   ch:choices({
--     --[[ {text="Okay", subText="Choose this if you agree", alert="Great!"}, ]]
--     --[[ {text="Nope", subText="Choose this if you don't agree", alert="Whatever…"}, ]]
--     {text="Restart Hammerspoon", subText="Reload the new settings", cmd="reset"}
--   })
--   ch:show()
-- end)

-- //// FOCUS WATCHER
local windowFilter = hs.window.filter.new()
windowFilter:subscribe(hs.window.filter.windowFocused, function(window, appName, event)
  -- alert
  if previousAppNameAlert then
    hs.alert.closeSpecific(previousAppNameAlert)
  end
  previousAppNameAlert = hs.alert.show(appName, hs.alert.defaultStyle, hs.screen.mainScreen(), 0.9)

  -- store window focus history
  -- focusHistory[#focusHistory+1] = window
  -- if #focusHistory >= 8 then
  --   table.remove(focusHistory, 1)
  -- end

--[[   for i, v in ipairs(focusHistory) do
    hs.printf(v:title())
    hs.printf(v:application():name())
  end
  hs.printf("========") ]]

  -- justTiled2W = false
end)

-- -- //// APP SWITCHER
-- hs.hotkey.bind({"ctrl", "shift"}, "return", function()
--   local ch = hs.chooser.new(function(option)
--     if option then
--       if option.alert then
--         hs.alert.show(option.alert)
--       end
      
--       if option.cmd == "reset" then
--         hs.reload()
--       elseif option.cmd == "switch" then
--         option.focus()
--       end
--     end
--   end)
--   ch:bgDark(true)
--   local allWindows = hs.window.filter:getWindows()
--   print(tostring(allWindows))
--   setmetatable(allWindows, {__index=function(the_table, the_key)
--     if the_key == "title" then
--       return the_table.title
--     elseif the_key == "cmd" then
--       return "switch"
--     end
--   end})
--   --ch:choices({
--     --[[ {text="Okay", subText="Choose this if you agree", alert="Great!"}, ]]
--     --[[ {text="Nope", subText="Choose this if you don't agree", alert="Whatever…"}, ]]
--     --{text="Restart Hammerspoon", subText="Reload the new settings", cmd="reset"}
--   --})
--   ch:choices(allWindows)
--   ch:show()
-- end)

-- //// APP PICKER
-- Indicator
local lineIndicator = hs.drawing.line(hs.geometry.point(0, 20), hs.geometry.point(screenWidth, 20))
lineIndicator:setStroke(true)
lineIndicator:setStrokeWidth(10)


--a = canvas.new{ x = 100, y = 100, h = 100, w = 100 }:show()
--a:insertElement({ type = "rectangle", id = "part1", fillColor = { blue = 1 } })
--a:insertElement({ type = "circle", id = "part2", fillColor = { green = 1 } })

local globalPickerModal = hs.hotkey.modal.new({"ctrl", "alt"}, "\"")
local codePickerModal = hs.hotkey.modal.new({"ctrl", "alt"}, "»")
local webPickerModal = hs.hotkey.modal.new({"ctrl", "alt"}, "(")

-- Indicator
function globalPickerModal:entered()
  -- old drawing
  lineIndicator:setStrokeColor({
    red=1,
    green=0.75,
    blue=0.6,
    alpha=1
  })
  codePickerModal:exit()
  webPickerModal:exit()
  lineIndicator:show()

  -- new canvas
  lineElement.fillColor = {red=1.0, green=0.89, blue=0.3, alpha=0.5}
  mainScreenCanvas:assignElement(lineElement, 1)
  mainScreenCanvas:show()
end
function globalPickerModal:exited()
  lineIndicator:hide() -- old api
  mainScreenCanvas:hide() -- new api
end

globalPickerModal:bind(nil, "escape", function()
  globalPickerModal:exit()
end)
globalPickerModal:bind(nil, "\"", function()
  focusApplication("Finder")
  globalPickerModal:exit()
end)
globalPickerModal:bind(nil, "«", function()
  focusApplication("Skype")
  globalPickerModal:exit()
end)
globalPickerModal:bind(nil, "»", function()
  focusApplication("Aperçu")
  globalPickerModal:exit()
end)
globalPickerModal:bind(nil, ")", function()
  focusApplication("KeePassXC")
  globalPickerModal:exit()
end)

-- Indicator
function codePickerModal:entered()
  -- old drawing
  lineIndicator:setStrokeColor({
    red=0.75,
    green=0.89,
    blue=1,
    alpha=1
  })
  globalPickerModal:exit()
  webPickerModal:exit()
  lineIndicator:show()
  
  -- new canvas
  lineElement.fillColor = {red=0.75, green=0.89, blue=1.0, alpha=0.5}
  mainScreenCanvas:assignElement(lineElement, 1)
  mainScreenCanvas:show()
end
function codePickerModal:exited()
  lineIndicator:hide() -- old api
  mainScreenCanvas:hide() -- new api
end

codePickerModal:bind(nil, "escape", function()
  codePickerModal:exit()
end)
codePickerModal:bind(nil, "»", function()
  focusApplication("Xcode")
  codePickerModal:exit()
end)
codePickerModal:bind(nil, "«", function()
  focusApplication("Simulator")
  codePickerModal:exit()
end)
codePickerModal:bind(nil, "(", function()
  focusApplication("Fork")
  codePickerModal:exit()
end)
codePickerModal:bind(nil, ")", function()
  focusApplication("Code")
  codePickerModal:exit()
end)
codePickerModal:bind(nil, "\"", function()
  focusApplication("Unity")
  codePickerModal:exit()
end)

function webPickerModal:entered()
  -- old drawing
  lineIndicator:setStrokeColor({
    red=1,
    green=0.5,
    blue=0.45,
    alpha=1
  })
  globalPickerModal:exit()
  codePickerModal:exit()
  lineIndicator:show()
  
  -- new canvas
  lineElement.fillColor = {red=1.0, green=0.5, blue=0.45, alpha=0.5}
  mainScreenCanvas:assignElement(lineElement, 1)
  mainScreenCanvas:show()
end
function webPickerModal:exited()
  lineIndicator:hide() -- old api
  mainScreenCanvas:hide() -- new api
end

webPickerModal:bind(nil, "escape", function()
  webPickerModal:exit()
end)
webPickerModal:bind(nil, "(", function()
  focusApplication("Firefox")
  webPickerModal:exit()
end)
webPickerModal:bind(nil, "»", function()
  focusApplication("Google Chrome")
  webPickerModal:exit()
end)

--[[ k = hs.hotkey.modal.new('cmd-shift', 'd')
function k:entered()
  hs.alert'Entered mode'
end
function k:exited()
  hs.alert'Exited mode'
end
k:bind('', 'escape', function()
  k:exit()
end)
k:bind('', 'J', 'Pressed J', function()
  print'let the record show that J was pressed'
end) ]]

-- //// QUICK SWITCHER

-- hs.hotkey.bind({"ctrl", "alt"}, "space", function()
--   if #focusHistory >= 2 then
--     local back = 1
--     while focusHistory[#focusHistory-back]:focus() == nil and back < historySize - 1 do
--       back = back + 1
--     end
--   end
-- end)

-- //// HELPERS

local windowTileWidthViewport = 0.4

function tileRight(windowTitle)
  local screenFrame = hs.screen.mainScreen():frame()
  screenFrame.x = screenFrame.x + screenFrame.w * windowTileWidthViewport
  screenFrame.w = (screenFrame.w * (1 - windowTileWidthViewport))
  hs.layout.apply({
    {
      nil,
      windowTitle,
      hs.screen.mainScreen(),
      nil,
      screenFrame,
      nil
    }
  })
end

function tileLeft(windowTitle) 
  local screenFrame = hs.screen.mainScreen():frame()
  screenFrame.w = screenFrame.w * windowTileWidthViewport - 1
  hs.layout.apply({
    {
      nil,
      windowTitle,
      hs.screen.mainScreen(),
      nil,
      screenFrame,
      nil
    }
  })
end

function maximize(windowTitle) 
  hs.layout.apply({
    {
      nil,
      windowTitle,
      hs.screen.mainScreen(),
      hs.layout.maximized,
      nil,
      nil
    }
  })
end

function focusApplication(name)
  local finder = hs.application.get(name)
  if finder then
    finder:activate()
    local fw = hs.window.focusedWindow()
    --[[ if fw == nil then
      finder:allWindows()[1]:focus()
    end ]]
    if fw and fw:isVisible() ~= true then
      fw:raise()
    end
    --[[ hs.printf(tostring(fw:isMinimized())) ]]
    --[[ if fw:isMinimized() then
      fw:unminimize()
    end ]]
  else
    local launchAlert = hs.alert("Launching "..name.."…")
    -- hs.alert.closeSpecific(launchAlert, 2)
    hs.application.open(name)
  end
end

--hs.notify.new({title="Hammerspoon", informativeText="Config file loaded"}):send()
  