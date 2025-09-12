-- see https://github.com/joric/supraworld/wiki/Modding for details

local UEHelpers = require("UEHelpers")

-- fixes ue4ss toggledebugcamera issue, see https://github.com/UE4SS-RE/RE-UE4SS/issues/514
local function cheatable(PlayerController)
    if not PlayerController.CheatManager:IsValid() then
        print("Restoring CheatManager")
        local CheatManagerClass = StaticFindObject("/Script/Engine.CheatManager")
        if CheatManagerClass:IsValid() then
            local CreatedCheatManager = StaticConstructObject(CheatManagerClass, PlayerController)
            if CreatedCheatManager:IsValid() then
                PlayerController.CheatManager = CreatedCheatManager
            end
        end
    end
    return PlayerController
end

NotifyOnNewObject("/Script/Engine.PlayerController", function(PlayerController)
    return cheatable(PlayerController)
end)

local function getDebugCameraController()
    return FindFirstOf("DebugCameraController") or UEHelpers.GetPlayerController()
end

local function toggleDebugCamera()
    local dc = getDebugCameraController()
    local pc = UEHelpers.GetPlayerController()

    if inDebugCamera then
        inDebugCamera = false
        cheatable(dc).CheatManager:DisableDebugCamera()
    else
        inDebugCamera = true
        cheatable(pc).CheatManager:EnableDebugCamera()
    end
end

local function teleportToTrace(PlayerPawn)
    local cam = getDebugCameraController().PlayerCameraManager
    local rot = cam:GetCameraRotation()
    local loc = getImpactPoint(PlayerPawn, cam:GetCameraLocation(), rot)
    loc.Z = loc.Z + 100 -- above the ground
    local res = PlayerPawn:K2_SetActorLocation(loc, false, {}, false)
end

local function teleportPlayer()
    if not inDebugCamera then return end

    local pc = UEHelpers.GetPlayerController()
    local cam = getDebugCameraController().PlayerCameraManager

    pc:ClientFlushLevelStreaming()
    pc:ClientForceGarbageCollection()

    local throttleMs = 250
    ExecuteWithDelay(throttleMs, function()
        ExecuteInGameThread(function()
            if (os.clock() - (lastTime or 0)) * 1000 < throttleMs then return end
            lastTime = os.clock()
            -- pc.Pawn:K2_TeleportTo(cam:GetCameraLocation(), cam:GetCameraRotation()) -- teleport to camera position
            -- getDebugCameraController().CheatManager:Teleport() -- built in teleport, needs line of sight
            teleportToTrace(pc.Pawn) -- teleport to impact point, may hit hidden volumes
        end)
    end)
end

RegisterKeyBind(Key.MIDDLE_MOUSE_BUTTON, toggleDebugCamera)
RegisterKeyBind(Key.LEFT_MOUSE_BUTTON, teleportPlayer)
