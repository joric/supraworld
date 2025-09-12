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

    -- these lines really help
    pc:ClientFlushLevelStreaming()
    pc:ClientForceGarbageCollection()

    ExecuteWithDelay(250, function()
        ExecuteInGameThread(function()
            local widget = FindFirstOf("SW_PlayerMapWidget_C")

            if widget and widget:IsValid() then
                local virtualMap = {}
                local mapLocation = {}
                local ok = widget:GetMousePositionOnVirtualMap(virtualMap, mapLocation)

                if ok and virtualMap.X ~= 0.0 or virtualMap.Y ~= 0.0 then

                    local worldX = (mapLocation.X - 0.5) * 200000 - 16500
                    local worldY = (mapLocation.Y - 0.5) * 200000 - 16500
                    local floorHeight = getFloorHeight(pc.Pawn, worldX, worldY)
                    local loc = {X = worldX, Y = worldY, Z = floorHeight + 100} -- 1 meter above ground

                    pc.Pawn:K2_TeleportTo(loc, pc.Pawn:K2_GetActorRotation())

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

RegisterKeyBind(Key.F, fastTravel)
