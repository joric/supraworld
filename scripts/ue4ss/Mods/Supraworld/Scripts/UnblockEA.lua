-- see https://github.com/joric/supraworld/wiki/Modding for details

local function unblockEA()
    for _, actor in ipairs(FindAllOf("SupraEABlockingVolume_C") or {}) do
        if actor:IsValid() then
            -- actor:K2_DestroyActor()
            actor:SetActorEnableCollision(false)
        end
    end
end

RegisterHook("/Script/Engine.PlayerController:ClientRestart", function(self)
    unblockEA()
end)
