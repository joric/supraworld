local UEHelpers = require("UEHelpers")
local GetKismetSystemLibrary = UEHelpers.GetKismetSystemLibrary

print("--- fast travel ---")

local function printv(title, v)
    if v then
        if v.Z then
            print(title, v.X, v.Y, v.Z)
        else
            print(title, v.X, v.Y)
        end
    else
        print("nil vector")
    end
end

local function getFloorLocation(PlayerPawn, location)

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
        print('floor found at', HitResult.ImpactPoint.Z)
        return  HitResult.ImpactPoint
    end

    return location
end



local function fastTravel()

    local pc = UEHelpers.GetPlayerController()
    if not pc or not pc:IsValid() or not pc.Pawn or not pc.Pawn:IsValid() then
        print('failed local controller')
        return
    end

    local ploc = {X=0, Y=0, Z=0}
    local rot = {}
    local p = pc.Pawn
    ploc = p:K2_GetActorLocation()
    rot = p:K2_GetActorRotation()

    ExecuteWithDelay(500, function()
    ExecuteInGameThread(function()

    print('--- teleporting ---')

    local widget = FindFirstOf("SW_PlayerMapWidget_C")

    if widget and widget:IsValid() then

        local virtualMap = {}
        local mapLocation = {}
        local ok = widget:GetMousePositionOnVirtualMap(virtualMap, mapLocation)

        printv('vmap', virtualMap)
        printv('mloc', mapLocation)

        if ok and virtualMap.X ~= 0.0 or virtualMap.Y ~= 0.0 then

            local worldX, worldY = 0, 0

            -- magic to calculate worldX and WorldY from vmap/mloc, tloc must match corresponding vmap/mloc

            worldX = (mapLocation.X - 0.5) * 200000 - 16500
            worldY = (mapLocation.Y - 0.5) * 200000 - 16500

            -- magic ends here

            local tloc = {X = worldX, Y = worldY}
            printv("tloc:", tloc)

            local location = {X=tloc.X, Y=tloc.Y, Z=5000}

            p:SetActorEnableCollision(false)

            local loc = getFloorLocation(p, location)

            printv('teleporting to', loc)

            p:K2_TeleportTo(loc, rot)

            p:SetActorEnableCollision(true)

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
