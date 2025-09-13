local UEHelpers = require("UEHelpers")

local function createTextWidget(text)
    local gi = UEHelpers.GetGameInstance()

    local hud = StaticConstructObject(StaticFindObject("/Script/UMG.UserWidget"), gi, FName("HUDWidget"))
    hud.WidgetTree = StaticConstructObject(StaticFindObject("/Script/UMG.WidgetTree"), hud, FName("HUDWidgetTree"))

    local canvas = StaticConstructObject(StaticFindObject("/Script/UMG.CanvasPanel"), hud.WidgetTree, FName("HUDCanvas"))
    hud.WidgetTree.RootWidget = canvas

    local vbox = StaticConstructObject(StaticFindObject("/Script/UMG.VerticalBox"), canvas, FName("HUDVBox"))
    local block = StaticConstructObject(StaticFindObject("/Script/UMG.TextBlock"), vbox, FName("MyTextBlock"))

    vbox:AddChildToVerticalBox(block)

    hud:SetVisibility(0)
    hud:AddToViewport(99)

    block:SetText(FText(text)) -- everything is valid but it crashes here

    -- local ksl = StaticFindObject("/Script/Engine.Default__KismetSystemLibrary")
    -- ksl:PrintString(nil, "Hello from PrintString", true, false, {R=0,G=1,B=0,A=1}, 5.0, "")
    -- local engine = FindFirstOf("Engine")
    -- engine:AddOnScreenDebugMessage(-1, 5.0, FColor(255,0,0,255), "Hello from DebugMessage")
    -- local pc = UEHelpers.GetPlayerController()
    -- pc:ClientMessage("Hello from ClientMessage", "None", 3.0)

end

local function showText()
    ExecuteWithDelay(250, function()
        ExecuteInGameThread(function()
            createTextWidget('Hello, World!')
        end)
    end)
end

RegisterKeyBind(Key.Z, {ModifierKey.CONTROL}, showText)
