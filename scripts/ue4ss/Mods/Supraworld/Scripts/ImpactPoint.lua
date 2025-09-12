local UEHelpers = require("UEHelpers")

-- uses PlayerPawn as a world context object
function getImpactPoint(PlayerPawn, StartVector, Rotation)
    local AddValue = UEHelpers.GetKismetMathLibrary():Multiply_VectorInt(UEHelpers.GetKismetMathLibrary():GetForwardVector(Rotation), 50000.0)
    local EndVector = UEHelpers.GetKismetMathLibrary():Add_VectorVector(StartVector, AddValue)
    local Color, HitResult = {R=0, G=0, B=0, A=0}, {}
    local WasHit = UEHelpers.GetKismetSystemLibrary():LineTraceSingle(PlayerPawn, StartVector, EndVector, 0, false, {}, 0, HitResult, true, Color, Color, 0.0)
    if WasHit then return HitResult.ImpactPoint end
    return {X=0, Y=0, Z=0}
end

