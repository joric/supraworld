print("--- fast travel ---")

local UEHelpers = require("UEHelpers")
local GetKismetSystemLibrary = UEHelpers.GetKismetSystemLibrary

local function getFloorHeight(PlayerPawn, location)
    local StartVector = {X=location.X, Y=location.Y, Z=10000}
    local EndVector = {X=location.X, Y=location.Y, Z=-10000}

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
        return  HitResult.ImpactPoint.Z
    end

    return location.Z
end

local function fastTravel()
    for _, actor in ipairs(FindAllOf("SupraEABlockingVolume_C") or {}) do
        if actor:IsValid() then
            actor:SetActorEnableCollision(false)
        end
    end

    local pc = UEHelpers.GetPlayerController()
    if not pc or not pc:IsValid() or not pc.Pawn or not pc.Pawn:IsValid() then
        print('invalid player controller')
        return
    end

    -- these lines really help
    pc:ClientFlushLevelStreaming()
    pc:ClientForceGarbageCollection()

    local p = pc.Pawn
    local ploc = p:K2_GetActorLocation()
    local rot = p:K2_GetActorRotation()

    ExecuteWithDelay(250, function()
    ExecuteInGameThread(function()

    print('--- teleporting ---')

    local widget = FindFirstOf("SW_PlayerMapWidget_C")

    if widget and widget:IsValid() then
        local virtualMap = {}
        local mapLocation = {}
        local ok = widget:GetMousePositionOnVirtualMap(virtualMap, mapLocation)

        if ok and virtualMap.X ~= 0.0 or virtualMap.Y ~= 0.0 then

            local worldX = (mapLocation.X - 0.5) * 200000 - 16500
            local worldY = (mapLocation.Y - 0.5) * 200000 - 16500

            local loc = {X = worldX, Y = worldY, Z = 5000}

            p:SetActorEnableCollision(false)

            p:K2_TeleportTo({X = loc.X, Y = loc.Y, Z = getFloorHeight(p, loc) + 100}, rot)

            p:SetActorEnableCollision(true)

            local comp = FindFirstOf("PlayerMapComponent_C")
            if comp and comp:IsValid() then
                comp:UpdatePlayerLocationAndFog()
            end

        else
            print('vmap is 0, cannnot teleport, try again')
        end

    else
        print("widget not found")
    end

    end)
    end)
end


RegisterKeyBind(Key.Z, fastTravel)
