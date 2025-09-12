-- see https://github.com/joric/supraworld/wiki/Modding for details

local function suitRefill()
    local suit = FindFirstOf("Equippable_SpongeSuit_C")
    if suit and suit:IsValid() then
        suit:SetCurrentFill(1.0)
    end
end

RegisterKeyBind(Key.R, suitRefill)
