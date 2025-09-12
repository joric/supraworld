-- https://github.com/joric/supraworld/wiki/Modding

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
    if not inDebugCamera then
        inDebugCamera = true
        cheatable(UEHelpers.GetPlayerController()).CheatManager:EnableDebugCamera()
    else
        inDebugCamera = false
        cheatable(getDebugCameraController()).CheatManager:DisableDebugCamera()
    end
end

local function teleportToTrace(PlayerPawn)
    local cam = getDebugCameraController().PlayerCameraManager
    local loc = getImpactPoint(PlayerPawn, cam:GetCameraLocation(), cam:GetCameraRotation())
    loc.Z = loc.Z + 100 -- above the ground
    local res = PlayerPawn:K2_SetActorLocation(loc, false, {}, false)
end

local function teleportPlayer()
    if not inDebugCamera then return end

    local pc = UEHelpers.GetPlayerController()
    local cam = getDebugCameraController().PlayerCameraManager

    pc:ClientFlushLevelStreaming()
    pc:ClientForceGarbageCollection()

    local throttleMs = 350
    ExecuteWithDelay(throttleMs, function()
        ExecuteInGameThread(function()
        ExecuteInGameThread(function()
            if (os.clock() - (lastTime or 0)) * 1000 < throttleMs then return end
            lastTime = os.clock()
            -- pc.Pawn:K2_TeleportTo(cam:GetCameraLocation(), cam:GetCameraRotation()) -- teleport to debug camera position
            -- getDebugCameraController().CheatManager:Teleport() -- built-in teleport console command, needs line of sight
            teleportToTrace(pc.Pawn) -- teleport to impact point, may hit hidden volumes
        end)
        end)
    end)
end

RegisterKeyBind(Key.MIDDLE_MOUSE_BUTTON, toggleDebugCamera)
RegisterKeyBind(Key.LEFT_MOUSE_BUTTON, teleportPlayer)
