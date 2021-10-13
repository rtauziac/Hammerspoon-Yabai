require("hs.ipc")


--# constants
super = "⌃⌥"
empty_table = {}
windowCornerRadius = 10


--# images
local images = require("images")


local windowAction = require("windowAction")
windowAction.new(super, hs.keycodes.map["y"], "swap", images.swap)  --["y"]
windowAction.new(super, hs.keycodes.map["n"], "warp", images.warp)  --["n"]
windowAction.new(super, hs.keycodes.map["h"], "stack", images.stack)  --["h"]


--# canvas elements
local canvases = {
  winFocusRect = hs.canvas.new({ x = 0, y = 0, w = 100, h = 100 }),
}


local focus_ = {
  --hideTimer = nil
}


--# helpers
function yabai(args, completion)
  local yabai_output = ""
  local yabai_error = ""
  -- Runs in background very fast
  local yabai_task = hs.task.new("/usr/local/bin/yabai",nil, function(task, stdout, stderr)
    --print("stdout:"..stdout, "stderr:"..stderr)
    if stdout ~= nil then yabai_output = yabai_output..stdout end
    if stderr ~= nil then yabai_error = yabai_error..stderr end
    return true
  end, args)
  if type(completion) == "function" then
    yabai_task:setCallback(function() completion(yabai_output, yabai_error) end)
  end
  yabai_task:start()
end


function delayed(fn, delay)
  return hs.timer.delayed.new(delay, fn):start()
end


toasts = {
  main = nil
}
function killToast(params)
  params = params or empty_table
  local name = params.name or "main"
  if toasts[name] ~= nil then
    hs.alert.closeSpecific(toasts[name], params.fadeOutDuration or 0.1)
    toasts[name] = nil
  end
end
function toast(str, time, params)
  killToast(params)
  params = params or empty_table
  local name = params.name or "main"
  --local toast = toasts[name]
  toasts[name] = hs.alert(str, {
    fillColor = { white = 0, alpha = 0.4 },
    strokeColor = { white = 0, alpha = 0 },
    strokeWidth = 0,
    textColor = { white = 1, alpha = 1 },
    radius = 0,
    padding = 6,
    atScreenEdge = 0,
    fadeInDuration = 0.1,
    fadeOutDuration = params.fadeOutDuration or 0.1
  }, time or 0.6)
end


--# Main chooser
local mainChooser = hs.chooser.new(function(option)
  if option ~= nil then
    if option.action == "reload" then
      hs.reload()
    elseif option.action == "toggle_gap" then
      yabai({"-m", "space", "--toggle", "padding"}, function() yabai({"-m", "space", "--toggle", "gap"}) end)
    end
  end
end):choices({
  {
    text = "Toggle Gap",
    subText = "Toggles padding and gaps around the current space",
    action = "toggle_gap"
  },
  {
    text = "Reload",
    subText = "Reload Hammerspoon configuration",
    action = "reload"
  },
})


--# bindings

--# reload config
hs.hotkey.bind(super, hs.keycodes.map["return"], nil, function() hs.reload() end)  --["return"]
--# open main chooser
hs.hotkey.bind(super, hs.keycodes.map["space"], nil, function() mainChooser:show() end)  --["space"]


--# set layout under mouse
hs.hotkey.bind(super, hs.keycodes.map["1"], function() yabai({"-m", "space", "mouse", "--layout", "bsp"}, function() toast("🖖") end) end)  --["1"]
hs.hotkey.bind(super, hs.keycodes.map["2"], function() yabai({"-m", "space", "mouse", "--layout", "stack"}, function() toast("📚") end) end)  --["2"]
hs.hotkey.bind(super, hs.keycodes.map["3"], function() yabai({"-m", "space", "mouse", "--layout", "float"}, function() toast("☁️") end) end)  --["3"]


--# rotate space
hs.hotkey.bind(super, hs.keycodes.map["."], function() yabai({"-m", "space", "--rotate", "270"}, function() toast("🔲🔁") end) end)  --["."]


--# focus fullscreen
hs.hotkey.bind(super, hs.keycodes.map["m"], function() yabai({"-m", "window", "--toggle", "zoom-fullscreen"}) end)  --["m"]
--hs.hotkey.bind(super, hs.keycodes.map[","], function() yabai({"-m", "window", "--toggle", "zoom-parent"}) end) -- not so useful  --[","]


--# toggle float layout for window
hs.hotkey.bind(super, hs.keycodes.map["/"], function() yabai({"-m", "window", "--toggle", "float"}) toast("🎚☁️") end)  --["/"]


--# change window stack focus
hs.hotkey.bind(super, hs.keycodes.map["t"], function() yabai({"-m", "window", "--focus", "stack.next"}, function() toast("📚↥") end) end)  --["t"]
hs.hotkey.bind(super, hs.keycodes.map["g"], function() yabai({"-m", "window", "--focus", "stack.prev"}, function() toast("📚↧") end) end)  --["g"]


--# change window focus to direction
hs.hotkey.bind(super, hs.keycodes.map[";"], function() yabai({"-m", "window", "--focus", "east"}) end)  --[";"]
hs.hotkey.bind(super, hs.keycodes.map["j"], function() yabai({"-m", "window", "--focus", "west"}) end)  --["j"]
hs.hotkey.bind(super, hs.keycodes.map["l"], function() yabai({"-m", "window", "--focus", "north"}) end)  --["l"]
hs.hotkey.bind(super, hs.keycodes.map["k"], function() yabai({"-m", "window", "--focus", "south"}) end)  --["k"]


--# bsp ratio
hs.hotkey.bind(super, hs.keycodes.map["7"], function() yabai({"-m", "window", "--ratio", "abs:0.38"}) toast("🔲⅓") end)  --["7"]
hs.hotkey.bind(super, hs.keycodes.map["8"], function() yabai({"-m", "window", "--ratio", "abs:0.5"}) toast("🔲½") end)  --["8"]
hs.hotkey.bind(super, hs.keycodes.map["9"], function() yabai({"-m", "window", "--ratio", "abs:0.62"}) toast("🔲⅔") end)  --["9"]
hs.hotkey.bind(super, hs.keycodes.map["-"], function() yabai({"-m", "space", "--balance"}) toast("🔲⚖️") end)  --["-"]


--# modals

local focus_display_mod = hs.hotkey.modal.new(super, hs.keycodes.map["v"])  --["v"]
local insert_window_modal = hs.hotkey.modal.new(super, hs.keycodes.map["tab"])  --["tab"]
local move_display_modal = hs.hotkey.modal.new(super, hs.keycodes.map["b"])  --["b"]
local resize_window_modal = hs.hotkey.modal.new()

--# focus display
function focus_display_mod:entered()
  toast("🖥🧭", true, { name = "modal" })
end
function focus_display_mod:exited()
  killToast({ name = "modal" })
end
focus_display_mod:bind("", hs.keycodes.map["escape"], function() focus_display_mod:exit() end)  --["escape"]
focus_display_mod:bind(super, hs.keycodes.map[";"], function() yabai({"-m", "display", "--focus", "next"}, function() delayed(function() toast("🖥➡️") end, 0.1) end) focus_display_mod:exit() end)  --[";"]
focus_display_mod:bind(super, hs.keycodes.map["j"], function() yabai({"-m", "display", "--focus", "prev"}, function() delayed(function() toast("🖥⬅️") end, 0.1) end) focus_display_mod:exit() end)  --["j"]


--# insert window rule
--# insert window rule functions
function insert_window_modal:entered()
  toast("🔲🌱 ", true, { name = "modal" })
end
function insert_window_modal:exited()
  killToast({ name = "modal" })
end
insert_window_modal:bind("", hs.keycodes.map["escape"], function() insert_window_modal:exit() end)  --["escape"]
insert_window_modal:bind(super, hs.keycodes.map[";"], function() yabai({"-m", "window", "--insert", "east"}) end)  --[";"]
insert_window_modal:bind(super, hs.keycodes.map["j"], function() yabai({"-m", "window", "--insert", "west"}) end)  --["j"]
insert_window_modal:bind(super, hs.keycodes.map["l"], function() yabai({"-m", "window", "--insert", "north"}) end)  --["l"]
insert_window_modal:bind(super, hs.keycodes.map["k"], function() yabai({"-m", "window", "--insert", "south"}) end)  --["k"]
insert_window_modal:bind(super, hs.keycodes.map["h"], function() yabai({"-m", "window", "--insert", "stack"}) end)  --["h"]
insert_window_modal:bind(super, hs.keycodes.map["tab"], function() insert_window_modal:exit() resize_window_modal:enter() end)  --["tab"]


--# send window to display
local move_display_ = {
  selected = nil
}
function move_display_modal:entered()
  yabai({"-m", "query", "--windows", "--window"},
    function(out)
      local window = hs.json.decode(out)
      if (window ~= nil) then
        --print(hs.inspect(hs.json.decode(out)))
        move_display_.selected = window
        toast("🔲🖥", true, { name = "move_display" })
      end
    end
  )
end
function move_display_modal:exited()
  move_display_.selected = nil
  killToast({ name = "move_display" })
end
move_display_modal:bind(super, hs.keycodes.map[";"],  --[";"]
  function()
    if (move_display_.selected ~= nil) then
      yabai({"-m", "window", "--display", "next"},
        function()
          move_display_modal:exit()
        end
      )
    end
  end
)
move_display_modal:bind(super, hs.keycodes.map["j"],  --["j"]
  function()
    if (move_display_.selected ~= nil) then
      yabai({"-m", "window", "--display", "prev"},
        function()
          move_display_modal:exit()
        end
      )
    end
  end
)
move_display_modal:bind("", hs.keycodes.map["escape"], function() move_display_modal:exit() end)  --["escape"]


--# resize window
local resize_window = {
  size = 20,
  horizontalEdge = nil, -- 1 is for right, -1 is for left
  verticalEdge = nil -- 1 is for bottom, -1 is for top
}
function resize_window_modal:entered()
  toast("🔲↔️", true, { name = "resize_window" })
end
function resize_window_modal:exited()
  resize_window.horizontalEdge = nil
  resize_window.verticalEdge = nil
  killToast({ name = "resize_window" })
end
resize_window_modal:bind(super, hs.keycodes.map[";"], function()  --[";"]
  if resize_window.horizontalEdge == nil then
    resize_window.horizontalEdge = 1
  end
  if resize_window.horizontalEdge == 1 then
    -- grow from right
    print("grow from right")
    yabai({"-m", "window", "--resize", "right:"..resize_window.size..":0"}, function(out, err) print(out, err) end)
  else
    -- shrink from left
    print("shrink from left")
    yabai({"-m", "window", "--resize", "left:"..resize_window.size..":0"}, function(out, err) print(out, err) end)
  end
end)
resize_window_modal:bind(super, hs.keycodes.map["j"], function()  --["j"]
  if resize_window.horizontalEdge == nil then
    resize_window.horizontalEdge = -1
  end
  if resize_window.horizontalEdge == 1 then
    -- shrink from right
    print("shrink from right")
    yabai({"-m", "window", "--resize", "right:-"..resize_window.size..":0"}, function(out, err) print(out, err) end)
  else
    -- grow from left
    print("grow from left")
    yabai({"-m", "window", "--resize", "left:-"..resize_window.size..":0"}, function(out, err) print(out, err) end)
  end
end)
resize_window_modal:bind(super, hs.keycodes.map["k"], function()  --["k"]
  if resize_window.verticalEdge == nil then
    resize_window.verticalEdge = 1
  end
  if resize_window.verticalEdge == 1 then
    -- grow from bottom
    print("grow from bottom")
    yabai({"-m", "window", "--resize", "bottom:0:"..resize_window.size}, function(out, err) print(out, err) end)
  else
    -- shrink from top
    print("shrink from top")
    yabai({"-m", "window", "--resize", "top:0:"..resize_window.size}, function(out, err) print(out, err) end)
  end
end)
resize_window_modal:bind(super, hs.keycodes.map["l"], function()  --["l"]
  if resize_window.verticalEdge == nil then
    resize_window.verticalEdge = -1
  end
  if resize_window.verticalEdge == 1 then
    -- shrink from bottom
    print("shrink from bottom")
    yabai({"-m", "window", "--resize", "bottom:0:-"..resize_window.size}, function(out, err) print(out, err) end)
  else
    -- grow from top
    print("grow from top")
    yabai({"-m", "window", "--resize", "top:0:-"..resize_window.size}, function(out, err) print(out, err) end)
  end
end)
resize_window_modal:bind("", hs.keycodes.map["escape"], function() resize_window_modal:exit() end)  --["escape"]


--# debug
hs.hotkey.bind(super, hs.keycodes.map["§"], function() yabai({"-m", "query", "--windows", "--window"}, function(out) print(out) end) toast("🐞") end)  --["§"]


--# window focus listener
currentFocus = nil
function onWindowFocusChanged(window_id)
  getFocusedWindow(function(win)
    if win ~= nil then
      if currentFocus == nil or currentFocus.id ~= win.id then
        currentFocus = win
        --deleteBorder()
        createBorder(win)
      end
    else
      currentFocus = nil
      deleteBorder()
    end
  end)
end


function onWindowResized(window_id)
  if currentFocus ~= nil and currentFocus.id == window_id then
    getWindow(currentFocus.id,
      function(win)
        --deleteBorder()
        createBorder(win)
      end
    )
  end
end


function onWindowMoved(window_id)
  if currentFocus ~= nil and currentFocus.id == window_id then
    getWindow(currentFocus.id,
      function(win)
        --deleteBorder()
        createBorder(win)
      end
    )
  end 
end


function createBorder(win)
  if win == nil or canvases.winFocusRect == nil then
    return 
  end
  canvases.winFocusRect:topLeft({ x = win.frame.x - 2, y = win.frame.y - 2 })
  canvases.winFocusRect:size({ w = win.frame.w + 4, h = win.frame.h + 4 })
  local borderColor = { red = 0.8, green = 0.8, blue = 0.2 , alpha = 0.6 }
  local zoomed = win["zoom-fullscreen"] == 1
  if zoomed then
    borderColor = { red = 0.8, green = 0.2, blue = 0.2 , alpha = 0.6 }
  end
  canvases.winFocusRect:replaceElements({
    type = "rectangle",
    action = "stroke",
    strokeColor = borderColor,
    strokeWidth = 4,
    --strokeDashPattern = { 60, 40 },
    roundedRectRadii = { xRadius = windowCornerRadius, yRadius = windowCornerRadius },
    padding = 2
  })
  canvases.winFocusRect:show()
end
function deleteBorder(fadeTime)
  canvases.winFocusRect:hide()
end


--# query
function getFocusedWindow(callback)
  yabai({"-m", "query", "--windows"},
    function(out, err)
      if out == nil or type(out) ~= "string" or string.len(out) == 0 then
        callback(nil)
      else
        out = string.gsub(out, ":inf,", ":0.0,")
        local json = "{\"windows\":"..out.."}"
        --print(json)
        local json_obj = hs.json.decode(json)
        if json_obj ~= nil then
          local windows = json_obj.windows
          for i, win in ipairs(windows) do
            if win.focused == 1 then
              callback(win)
              return
            end
          end
          callback(nil)
        else
          getFocusedWindow(callback)
        end
      end
    end
  )
end


function getWindow(window_id, callback)
  yabai({"-m", "query", "--windows", "--window", tostring(window_id)},
    function(out, err)
      if out == nil or string.len(out) == 0 then
        callback(nil)
      else
        --print("json|"..out.."|len"..string.len(out))
        local win = hs.json.decode(out)
        callback(win)
      end
    end
  )
end


--# install cli
hs.ipc.cliInstall()


-- calls made by yabai frow cli, see .yabairc
yabaidirectcall = {
  window_focused = function(window_id) -- called when another window from the current app is focused
    onWindowFocusChanged(window_id)
  end,
  application_activated = function(process_id) -- called when a window from a different app is focused. Doesn’t exclude a window_focused call.
    onWindowFocusChanged(window_id)
  end,
  window_resized = function(window_id) -- called when a window changes dimensions
    onWindowResized(window_id)
  end,
  window_moved = function(window_id) -- called when a window is moved
    onWindowMoved(window_id)
  end
}


--# start yabai
--os.execute("/usr/local/bin/yabai")
-- so far I start yabai by hand from terminal so I can see logs

--toast("Hello world", 1)

onWindowFocusChanged(nil) -- show borders of focused window at startup
