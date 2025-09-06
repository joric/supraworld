local ok, mod = pcall(require, "localdebug")
if ok then return end

local UEHelpers = require("UEHelpers")

local function removeBlockingVolumes()
    for _, actor in ipairs(FindAllOf("SupraEABlockingVolume_C") or {}) do
        if actor:IsValid() then
            actor:SetActorEnableCollision(false)
            -- actor:K2_DestroyActor()
        end
    end
end

local function getDebugCameraController()
    local pc = FindFirstOf("DebugCameraController")
    if pc and pc.CheatManager and not pc.CheatManager:IsValid() then
        pc.CheatManager = StaticConstructObject(StaticFindObject("/Script/Engine.CheatManager"), pc)
    end
    return pc or UEHelpers.GetPlayerController()
end

local function toggleDebugCamera()
    if inDebugCamera then
        inDebugCamera = false
        getDebugCameraController().CheatManager:DisableDebugCamera()
    else
        inDebugCamera = true
        removeBlockingVolumes()
        UEHelpers.GetPlayerController().CheatManager:EnableDebugCamera()
    end
end

local function teleportPlayer()
    if not inDebugCamera then return end
    local throttleMs = 250
    ExecuteWithDelay(throttleMs, function()
        ExecuteInGameThread(function()
            if (os.clock() - (lastTime or 0)) * 1000 < throttleMs then return end
            lastTime = os.clock()
            local pc = UEHelpers.GetPlayerController()
            local cam = getDebugCameraController().PlayerCameraManager
            pc.Pawn:K2_TeleportTo(cam:GetCameraLocation(), cam:GetCameraRotation())
        end)
    end)
end

RegisterKeyBind(Key.MIDDLE_MOUSE_BUTTON, toggleDebugCamera)
RegisterKeyBind(Key.LEFT_MOUSE_BUTTON, teleportPlayer)
