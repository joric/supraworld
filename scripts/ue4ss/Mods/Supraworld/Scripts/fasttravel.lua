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

ExecuteWithDelay(250, function()
ExecuteInGameThread(function()
ExecuteInGameThread(function()

    print('--- teleporting ---')

    local widget = FindFirstOf("SW_PlayerMapWidget_C")

    if widget and widget:IsValid() then

        local pc = UEHelpers.GetPlayerController()
        local ploc = {X=0, Y=0, Z=0}
        local rot = {}

        if pc and pc:IsValid() and pc.Pawn and pc.Pawn:IsValid() then
            ploc = pc.Pawn:K2_GetActorLocation()
            rot = pc.Pawn:K2_GetActorRotation()
            -- printv('ploc', ploc)
        end


        local virtualMap = {}
        local mapLocation = {}
        local ok = widget:GetMousePositionOnVirtualMap(virtualMap, mapLocation)
        printv('vmap', virtualMap)
        printv('mloc', mapLocation)

        local worldX, worldY = 0, 0

        -- magic to calculate worldX and WorldY from vmap/mloc, tloc must match corresponding vmap/mloc

        worldX = (mapLocation.X - 0.5) * 200000 - 16500
        worldY = (mapLocation.Y - 0.5) * 200000 - 16500

        -- magic ends here

        local tloc = {X = worldX, Y = worldY}
        printv("tloc:", tloc)

        local location = {X=tloc.X, Y=tloc.Y, Z=5000}

        local loc = getFloorLocation(pc.Pawn, location)

        printv('teleporting to', loc)

        pc.Pawn:K2_TeleportTo(loc, rot)


        --[[
            Example data (can be a little delta) vmap may be irrelevant

            vmap       0.4     0.67391304347826
            mloc       0.56446549651226        0.59674398117968
            tloc       -3612.85009765625   2852.310546875

            vmap       0.63229166666667        0.55978260869565
            mloc       0.60627799817374        0.58690023078852
            tloc        4782.294921875 858.2172241210938

            vmap       0.8078125       0.41521739130435
            mloc       0.63787174942917        0.57443148029306
            tloc       11050 -1600

            vmap       0.6359375       0.69565217391304
            mloc       0.60693424819982        0.59861898125418
            tloc       4881.12841796875 3223.8759765625
        ]]

    else
        print("widget not found")
    end

    end)
    end)
    end)
end


RegisterKeyBind(Key.Z, fastTravel)
