local utf8 = require("utf8")
local json  = require("engine.lib.json")
local coreFuncs = require("coreFuncs")
local startupManager = require("engine.startup_manager")

Lighter = require("engine.lib.lighterlib")()
InputManager = require("engine.input_manager")
SoundManager = require("engine.sound_manager")
Globals = require("engine.globals")
Assets = require("assets")
MenuUIOffset = 0
RealMenuUIOffset = 0
CurrentScene = nil
Scenes = {}
OldSceneName = ""
MapChanged = false
DevConsoleOpen = false
GamePaused = false

function love.mousemoved()
    InputManager:setInputTypeTo("keyboard")
end

function love.wheelmoved(_, y)
    InputManager:setInputTypeTo("keyboard")
    --Scrolling in various alt menus (TODO: Improve?)
    if CurrentScene.settings and (CurrentScene.settings.menu == "keys" or CurrentScene.settings.menu == "video" or CurrentScene.settings.menu == "gameplay") then
        local menu = CurrentScene.settings.keysMenu
        if CurrentScene.settings.menu == "video" then menu = CurrentScene.settings.videoMenu end
        if CurrentScene.settings.menu == "gameplay" then menu = CurrentScene.settings.gameplayMenu end
        menu.realY = menu.realY + 35*y
        if menu.realY > 0 then menu.realY = 0 end
        if menu.realY < 540-menu.length then menu.realY = 540-menu.length end
    end
    --Infinite menu scrolling
    if CurrentScene.extras ~= nil then
        if CurrentScene.extras.infiniteMenu.UIComponent.enabled then
            local menu = CurrentScene.extras.infiniteMenu
            menu.realY = menu.realY + 35*y
            if menu.realY > 0 then menu.realY = 0 end
            if menu.realY < 540-menu.length then menu.realY = 540-menu.length end
        end
    end
    --Achivements menu scrolling
    if CurrentScene.achievements ~= nil then
        if CurrentScene.achievements.open then
            local menu = CurrentScene.achievements
            --menu.UIComponent.scrollbar.value = menu.UIComponent.scrollbar.value - y/20
            menu.realY = menu.realY + 35*y
            if menu.realY > 0 then menu.realY = 0 end
            if menu.realY < 540-menu.length then menu.realY = 540-menu.length end
        end
    end
    --Changelog menu scrolling
    if CurrentScene.changelog ~= nil then
        if CurrentScene.changelog.open then
            local menu = CurrentScene.changelog
            --menu.UIComponent.scrollbar.value = menu.UIComponent.scrollbar.value - y/20
            menu.realY = menu.realY + 35*y
            if menu.realY > 0 then menu.realY = 0 end
            if menu.realY < 540-menu.length then menu.realY = 540-menu.length end
        end
    end
    --Load game menu scrolling
    if CurrentScene.loadGameMenu ~= nil then
        if CurrentScene.loadGameMenu.open then
            local menu = CurrentScene.loadGameMenu
            --menu.UIComponent.scrollbar.value = menu.UIComponent.scrollbar.value - y/20
            menu.realY = menu.realY + 35*y
            if menu.realY > 0 then menu.realY = 0 end
            if menu.realY < 540-menu.length then menu.realY = 540-menu.length end
        end
    end

    --Ingame zooming
    if not GamePaused and CurrentScene.name == "Game" and (CurrentScene.mapCreator.allowZoom or GetGlobal("freecam") > 0) then
        local camController = CurrentScene.camera.script
        if y > 0 then
            camController.playerManualZoom = camController.playerManualZoom + 0.1
            if camController.playerManualZoom > 2.5 then camController.playerManualZoom = 2.5 end
        elseif y < 0 then
            camController.playerManualZoom = camController.playerManualZoom - 0.1
            if camController.playerManualZoom < 0.01 then camController.playerManualZoom = 0.01 end
        end
    end

    --[[Ingame slot switching
    if not GamePaused and CurrentScene.name == "Game" and not love.keyboard.isDown("lctrl") and CurrentScene.player.health > 0 then
        local player = CurrentScene.player
        local oldSlot = player.inventory.slot
        player.inventory.previousSlot = player.inventory.slot
        player.inventory.slot = player.inventory.slot - y
        if player.inventory.slot > 3 then player.inventory.slot = 1 end
        if player.inventory.slot < 1 then player.inventory.slot = 3 end
        --Update hand offset
        if oldSlot ~= player.inventory.slot and player.inventory.weapons[oldSlot] ~= player.inventory.weapons[player.inventory.slot] then
            player.handOffset = -15
        end
        --Cancel reload if slot switching is done
        if oldSlot ~= player.inventory.slot then
            player.reloading = false
            local weapon = player.inventory.weapons[player.inventory.previousSlot]
            if weapon ~= nil then
                SoundManager:stopSound(Assets.sounds["reload_" .. string.lower(weapon.name)])
            end
        end
    end
    ]]--
    
    --DevConsole scrolling
    local console = CurrentScene.devConsole
    if not console then return end
    if console.open then
        if y > 0 then
            console.logOffset = console.logOffset - 1
            if console.logOffset < 0 then console.logOffset = 0 end
        elseif y < 0 then
            console.logOffset = console.logOffset + 1
            if console.logOffset > #console.logs then console.logOffset = #console.logs end
        end
    end
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
    --Open map directly if given
    if table.contains(arg, "--map") then
        local i = table.contains(arg, "--map", true)
        startScene = LoadScene(GAME_DIRECTORY .. "/assets/scenes/game.json")
        SetScene(startScene)
        startScene.mapCreator.script:loadMap(arg[i+1])
        return
    end
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
