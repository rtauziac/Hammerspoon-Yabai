local c = require("hs.canvas")
local json = require("hs.json")
local yabai = require("yabai")

local windowAction = {
    new = function(modKeys, key, action, image)
        local a = {
            action = action,
            selected = nil,
            icon = image
        }
        a.modal = hs.hotkey.modal.new(modKeys, key)
        function a.modal:entered()
            yabai({"-m", "query", "--windows", "--window"}, function(out)
                local window = json.decode(out)
                if window ~= nil then
                    a.selected = window
                    a:showOverlay()
                else
                    a.modal:exit()
                end
            end)
        end
        function a.modal:exited()
            a.selected = nil
            a:hideOverlay()
        end
        a.modal:bind(modKeys, key, function()
            yabai({"-m", "window", "--" .. a.action, tostring(a.selected.id)}, function()
                yabai({"-m", "window", "--focus", tostring(a.selected.id)}, function()
                    a.modal:exit()
                end)
            end)
        end)
        a.modal:bind(nil, hs.keycodes.map["escape"], function()
            a.modal:exit()
        end)
        a.canvas = c.new({
            x = 0,
            y = 0,
            w = 100,
            h = 100
        }):replaceElements({
            type = "image",
            image = a.icon,
            imageScaling = "none"
        }, {
            type = "rectangle",
            action = "fill",
            fillColor = {
                white = 1,
                alpha = 0.66
            },
            roundedRectRadii = {
                xRadius = windowCornerRadius,
                yRadius = windowCornerRadius
            },
            compositeRule = "plusDarker"
        })
        function a:showOverlay()
            self.canvas:topLeft({
                x = self.selected.frame.x,
                y = self.selected.frame.y
            }):size({
                w = self.selected.frame.w,
                h = self.selected.frame.h
            }):show()
        end
        function a:hideOverlay()
            self.canvas:hide()
        end
        return a
    end
}
return windowAction