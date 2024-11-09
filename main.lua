local musicFuncs = require("musicdetector")

function events.render(delta)
    local height = musicFuncs.returnDimensions().y
    if musicFuncs.returnNow() and not renderer:isFirstPerson() then
        nameplate.ENTITY:setPivot(0, (player:getEyeHeight() + 0.4 + height/64 + height/100), 0)
    elseif not renderer:isFirstPerson() then
        nameplate.ENTITY:setPivot(0, player:getEyeHeight() + 0.7, 0)
    end
    nameplate.ENTITY:setScale(models.model:getScale())
end