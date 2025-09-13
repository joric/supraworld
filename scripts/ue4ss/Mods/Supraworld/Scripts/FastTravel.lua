-- https://github.com/joric/supraworld/wiki/Modding

local UEHelpers = require("UEHelpers")

local function getFloorHeight(PlayerPawn, worldX, worldY)
    local StartVector = {X = worldX, Y = worldY, Z = 10000}
    local Rotation = { Pitch = -90, Yaw = 0, Roll = 0 } -- points down
    return getImpactPoint(PlayerPawn, StartVector, Rotation).Z
end

local function fastTravel()
    local pc = UEHelpers.GetPlayerController()
    if not pc or not pc:IsValid() or not pc.Pawn or not pc.Pawn:IsValid() then
        return
    end

    pc:ClientFlushLevelStreaming()
    pc:ClientForceGarbageCollection()

    ExecuteWithDelay(250, function()
        ExecuteInGameThread(function()

            local widget = FindFirstOf("SW_PlayerMapWidget_C")
            if not widget or not widget:IsValid() then
                widget = FindFirstOf("PlayerMapWidget_C") -- sl/siu
            end
            if not widget or not widget:IsValid() then return end

            local mapActor = FindFirstOf("PlayerMapActor_C")
            if not mapActor or not mapActor:IsValid() then return end

            local size = mapActor.MapWorldSize
            local cx = mapActor.MapWorldCenter.X
            local cy = mapActor.MapWorldCenter.Y

            local virtualMap = {}
            local mapLocation = {}
            local ok = widget:GetMousePositionOnVirtualMap(virtualMap, mapLocation)

            if ok and virtualMap.X ~= 0.0 or virtualMap.Y ~= 0.0 then
                local worldX = (mapLocation.X - 0.5) * size + cx
                local worldY = (mapLocation.Y - 0.5) * size + cy
                local floorHeight = getFloorHeight(pc.Pawn, worldX, worldY)
                local loc = {X = worldX, Y = worldY, Z = floorHeight + 100} -- above ground

                pc.Pawn:K2_TeleportTo(loc, pc.Pawn:K2_GetActorRotation())

                local comp = FindFirstOf("PlayerMapComponent_C")
                if comp and comp:IsValid() then
                    comp:UpdatePlayerLocationAndFog()
                end
            else
                print('vmap is 0, cannnot teleport, try again')
            end

        end)
    end)
end

RegisterKeyBind(Key.F, fastTravel)
