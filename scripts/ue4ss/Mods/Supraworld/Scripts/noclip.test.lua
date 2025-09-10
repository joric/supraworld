print("--- noclip.test ---")

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

local function removeBlockingVolumes()
    for _, actor in ipairs(FindAllOf("SupraEABlockingVolume_C") or {}) do
        if actor:IsValid() then
            -- actor:K2_DestroyActor()
            actor:SetActorEnableCollision(false)
        end
    end
end

local function getDebugCameraController()
    return FindFirstOf("DebugCameraController") or UEHelpers.GetPlayerController()
end

local function stop(pc)
    if not pc or not pc:IsValid() then return end
    if not pc.Pawn or not pc.Pawn:IsValid() then return end
    local p = pc.Pawn
    pc:DisableInput(pc)
    pc:SetActorTickEnabled(false)
    p.CharacterMovement:StopMovementImmediately()
    p:LaunchCharacter({X=0,Y=0,Z=0}, true, true)
    p.CharacterMovement:SetMovementMode(0, 0)
    p:SetActorEnableCollision(false)
    p.CharacterMovement.Velocity = {X=0,Y=0,Z=0}
    p.CharacterMovement.Acceleration = {X=0,Y=0,Z=0}
    p.CharacterMovement.GravityScale = 0.0
    p.CharacterMovement:SetComponentTickEnabled(false)
end

local function start(pc)
    if not pc or not pc:IsValid() then return end
    if not pc.Pawn or not pc.Pawn:IsValid() then return end
    local p = pc.Pawn
    p:LaunchCharacter({X=0,Y=0,Z=0}, true, true)
    p.CharacterMovement.GravityScale = 1.0
    p:SetActorEnableCollision(true)
    p.CharacterMovement:SetMovementMode(1, 0)
    p.CharacterMovement:SetComponentTickEnabled(true)
    pc:SetActorTickEnabled(true)
    pc:EnableInput(pc)
end

local function fillSuit()
    local suit = FindFirstOf("Equippable_SpongeSuit_C")
    if suit then
    suit:SetCurrentFill(100.0)
    end
end

local function toggleDebugCamera()
    local dc = getDebugCameraController()
    local pc = UEHelpers.GetPlayerController()

    if inDebugCamera then
        inDebugCamera = false
        cheatable(dc).CheatManager:DisableDebugCamera()
        -- start(dc)
        -- start(pc)
        -- may hang here if teleported to actor, or stuck in collison
    else
        inDebugCamera = true
        removeBlockingVolumes()
        -- stop(dc)
        -- stop(pc)
        cheatable(pc).CheatManager:EnableDebugCamera()
    end
end

local function teleportToTrace(CameraController, PlayerController)
    local GetKismetSystemLibrary = UEHelpers.GetKismetSystemLibrary
    local GetKismetMathLibrary = UEHelpers.GetKismetMathLibrary

    local PlayerPawn = PlayerController.Pawn
    local CameraManager = CameraController.PlayerCameraManager
    local StartVector = CameraManager:GetCameraLocation()
    local AddValue = GetKismetMathLibrary():Multiply_VectorInt(GetKismetMathLibrary():GetForwardVector(CameraManager:GetCameraRotation()), 50000.0)
    local EndVector = GetKismetMathLibrary():Add_VectorVector(StartVector, AddValue)
    local TraceColor = {
        ["R"] = 0,
        ["G"] = 0,
        ["B"] = 0,
        ["A"] = 0,
    }
    local TraceHitColor = TraceColor
    local EDrawDebugTrace_Type_None = 0
    local ETraceTypeQuery_TraceTypeQuery1 = 0
    local ActorsToIgnore = {
    }
    -- print("Doing line trace\n")
    local HitResult = {}
    local WasHit = GetKismetSystemLibrary():LineTraceSingle(
        PlayerPawn,
        StartVector,
        EndVector,
        ETraceTypeQuery_TraceTypeQuery1,
        false,
        ActorsToIgnore,
        EDrawDebugTrace_Type_None,
        HitResult,
        true,
        TraceColor,
        TraceHitColor,
        0.0
    )
    if WasHit then
        local loc = HitResult.ImpactPoint
        local rot = CameraManager:GetCameraRotation()

        -- local res = PlayerPawn:K2_TeleportTo(loc, rot) -- this sometimes fails because of sweep

        local res = PlayerPawn:K2_SetActorLocation(loc, false, {}, false)

        print("teleporting to", loc.X, loc.Y, loc.Z, rot, res)
    else
        print("hit failed")
    end
end



local function teleportPlayer()

    fillSuit()

    if not inDebugCamera then return end

    local pc = UEHelpers.GetPlayerController()
    local dc = getDebugCameraController()

    stop(pc)

    pc:ClientFlushLevelStreaming()
    pc:ClientForceGarbageCollection()

    dc:ClientFlushLevelStreaming()
    dc:ClientForceGarbageCollection()

    local throttleMs = 300
    ExecuteWithDelay(throttleMs, function()
        ExecuteInGameThread(function()
        ExecuteInGameThread(function()
        ExecuteInGameThread(function()
            if (os.clock() - (lastTime or 0)) * 1000 < throttleMs then return end
            lastTime = os.clock()

            local cam = dc.PlayerCameraManager

            -- pc.Pawn:K2_TeleportTo(cam:GetCameraLocation(), cam:GetCameraRotation()) -- camera position
            -- getDebugCameraController().CheatManager:Teleport() -- uses sweep, needs line of sight


            teleportToTrace(dc, pc) -- may hit hidden volumes

            start(pc)

        end)
        end)
        end)
    end)
end

RegisterKeyBind(Key.MIDDLE_MOUSE_BUTTON, toggleDebugCamera)
RegisterKeyBind(Key.LEFT_MOUSE_BUTTON, teleportPlayer)
