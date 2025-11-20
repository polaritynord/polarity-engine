--This is a script component file.
local script = ENGINE_COMPONENTS.scriptComponent.new()

--load() function runs when the object having this component is added to the scene.
function script:load()
    local object = self.parent --The object which the component is attached to
    local ui = object.UIComponent --Object's UI Component, which we added in game/scenes/sample_scene.json
    --Adding a text label:
    ui:newTextLabel(
        {
            text = "Hello world";
        }
    )
end

--update() function runs every frame. "delta" is the time between frames.
function script:update(delta)
    
end

return script