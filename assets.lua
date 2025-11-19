local assets = {
    images = {};
    sounds = {};
    fonts = {};
    defaultImages = {};
    defaultSounds = {};
    mapImages = {};
    mapSounds = {};
}

function assets:unloadSceneAssets()
    --remove images
    for k, v in pairs(assets.images) do
        assets.images[k]:release()
        assets.images[k] = nil
    end
    assets.images = {}
    --remove sounds
    for k, v in pairs(assets.sounds) do
        assets.sounds[k]:stop()
        assets.sounds[k]:release()
        assets.sounds[k] = nil
    end
    assets.sounds = {}
end

function assets:unloadMapAssets()
    --remove images
    for k, v in pairs(assets.mapImages) do
        assets.mapImages[k]:release()
        assets.mapImages[k] = nil
    end
    assets.mapImages = {}
    --remove sounds
    for k, v in pairs(assets.mapSounds) do
        assets.mapSounds[k]:stop()
        assets.mapSounds[k]:release()
        assets.mapSounds[k] = nil
    end
    assets.mapSounds = {}
end

function assets.load()
    assets.defaultSounds.button_click = love.audio.newSource(GAME_DIRECTORY .. "/assets/sounds/button_click.wav", "static")
    assets.defaultSounds.button_hover = love.audio.newSource(GAME_DIRECTORY .. "/assets/sounds/button_hover.wav", "static")
    --assets.defaultSounds.save = love.audio.newSource("desolation/assets/sounds/save.wav", "static")
    assets.defaultImages.missing_texture = love.graphics.newImage("engine/assets/missing_texture.png")
    --[[assets.defaultImages.controller_hints_ps = love.graphics.newImage("desolation/assets/images/controller_hints/ps.png")
    assets.cursors = {
        default = love.mouse.newCursor("desolation/assets/images/cursor_default.png", 0, 0);
        unarmed = love.mouse.newCursor("desolation/assets/images/cursor_unarmed.png", 6, 6);
        combat = love.mouse.newCursor("desolation/assets/images/cursor_combat.png", 18, 18);
        reload = love.mouse.newCursor("desolation/assets/images/cursor_reload.png", 18, 18);
    }
    ]]--
end

return assets