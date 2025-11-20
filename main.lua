local utf8 = require("utf8")
local json  = require("engine.lib.json")
local coreFuncs = require("coreFuncs")
local startupManager = require("engine.startup_manager")

Lighter = require("engine.lib.lighterlib")()
InputManager = require("engine.input_manager")
SoundManager = require("engine.sound_manager")
Globals = require("engine.globals")
Assets = require("assets")
CurrentScene = nil
Scenes = {}
OldSceneName = ""
GamePaused = false

function love.mousemoved()
    InputManager:setInputTypeTo("keyboard")
end

function love.wheelmoved(_, y)
    InputManager:setInputTypeTo("keyboard")
end

function love.keypressed(key, unicode)
    --console shit
    local console = CurrentScene.devConsole
    local consoleUI
    if console then
        consoleUI = console.UIComponent
    else consoleUI = nil end
    InputManager:setInputTypeTo("keyboard")
    -- Fullscreen key
    if table.contains(InputManager:getKeys("fullscreen"), key) then
        --fullscreen = not fullscreen
        --love.window.setMode(love.window.getDesktopDimensions())
        love.window.setFullscreen(not love.window.getFullscreen(), "desktop")
        --Switch the fullscreen option in the settings too
        Settings.fullscreen = love.window.getFullscreen()
        if CurrentScene.settings ~= nil then
            CurrentScene.settings.videoMenu.UIComponent.fullscreenBox.toggled = love.window.getFullscreen()
        end

        --love.window.setFullscreen(fullscreen, "desktop")
        -- Set window dimensions to default
        if not love.window.getFullscreen() then
            local res = Settings.resolution_options[Settings.resolution]
            love.window.setMode(res[1], res[2], {})
        end
    end

    --Take screenshot key
    if table.contains(InputManager:getKeys("screenshot"), key) then
        love.graphics.captureScreenshot("screenshots/" .. os.date("%Y.%m.%d %H.%m.%S") .. ".png")
        ConsoleLog("Screenshot saved at " .. love.filesystem.getRealDirectory("screenshots"))
    end
end

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.audio.setDistanceModel("linearclamped")
    startupManager:load()
    InputManager:loadBindingFile()
    Assets.load()
    love.keyboard.setKeyRepeat(true)
    love.window.setVSync(Settings.vsync)

    local startScene = nil
    --Open up the default scene (or the scene given in args)
    local infoData = json.decode(love.filesystem.read(GAME_DIRECTORY .. "/info.json"))
    if table.contains(arg, "--scene") then
        local i = table.contains(arg, "--scene", true)
        startScene = LoadScene(GAME_DIRECTORY .. "/assets/scenes/" .. arg[i+1] .. ".json")
    else
        startScene = LoadScene(infoData.startScene)
    end
    SetScene(startScene)
end

function love.update(delta)
    ScreenWidth, ScreenHeight = love.graphics.getDimensions()
    if CurrentScene == nil then return end
    CurrentScene:update(delta)
    love.window.setVSync(Settings.vsync)
end

function love.draw()
    if CurrentScene == nil then return end
    if CurrentScene.name ~= OldSceneName then
        OldSceneName = CurrentScene.name
        return
    end
    if MapChanged then
        MapChanged = false
        return
    end
    CurrentScene:draw()
end
