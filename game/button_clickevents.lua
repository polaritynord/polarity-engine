local json = require "engine.lib.json"
local clickEvents = {}

--UI buttons
function clickEvents.redHover(element)
    local delta = love.timer.getDelta()
    element.color[2] = element.color[2] + (-element.color[2])*8*delta
    element.color[3] = element.color[3] + (-element.color[3])*8*delta
end

function clickEvents.redUnhover(element)
    local delta = love.timer.getDelta()
    element.color[2] = element.color[2] + (1-element.color[2])*8*delta
    element.color[3] = element.color[3] + (1-element.color[3])*8*delta
end

function clickEvents.fadeIn(element)
    local delta = love.timer.getDelta()
    element.color[4] = element.color[4] + (1-element.color[4])*8*delta
end

function clickEvents.fadeOut(element)
    local delta = love.timer.getDelta()
    element.color[4] = element.color[4] + (0.5-element.color[4])*8*delta
end

function clickEvents.defaultHoverEvent(element)
    local delta = love.timer.getDelta()
    element.hoverOffset = element.hoverOffset + (14-element.hoverOffset) * 27 * delta
    if element.mouseHovering or InputManager.inputType == "joystick" then return end
    SoundManager:playSound(Assets.defaultSounds["button_hover"], Settings.vol_sfx)
end

function clickEvents.defaultUnhoverEvent(element)
    local delta = love.timer.getDelta()
    element.hoverOffset = element.hoverOffset + (0-element.hoverOffset) * 27 * delta
end

return clickEvents