-- https://github.com/joric/supraworld/wiki/Modding

local function skipCutscene()
    for _, player in ipairs(FindAllOf("LevelSequencePlayer") or {}) do
        if player:IsValid() then
            player:Stop()
        end
    end

end

RegisterKeyBind(Key.SPACE, skipCutscene)
