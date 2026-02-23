local TweenService = game:GetService("TweenService")

local TweenController = {}

<<<<<<< HEAD
TweenController.fast = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
TweenController.med  = TweenInfo.new(0.20, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

function TweenController.tw(obj, info, props)
    TweenService:Create(obj, info, props):Play()
=======
TweenController.Spring = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
TweenController.Smooth = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
TweenController.Bounce = TweenInfo.new(0.35, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
TweenController.Out = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
TweenController.Fast = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

function TweenController:Play(instance, info, properties)
    local tween = TweenService:Create(instance, info, properties)
    tween:Play()
    return tween
end

function TweenController:FadeIn(instance, time)
    instance.Visible = true
    if instance:IsA("CanvasGroup") then
        instance.GroupTransparency = 1
        self:Play(instance, TweenInfo.new(time or 0.2), {GroupTransparency = 0})
    elseif instance.BackgroundTransparency ~= nil then
        instance.BackgroundTransparency = 1
        self:Play(instance, TweenInfo.new(time or 0.2), {BackgroundTransparency = 0})
    end
end

function TweenController:FadeOut(instance, time)
    local tween
    if instance:IsA("CanvasGroup") then
        tween = self:Play(instance, TweenInfo.new(time or 0.2), {GroupTransparency = 1})
    elseif instance.BackgroundTransparency ~= nil then
        tween = self:Play(instance, TweenInfo.new(time or 0.2), {BackgroundTransparency = 1})
    end
    if tween then
        tween.Completed:Connect(function()
            instance.Visible = false
        end)
    else
        instance.Visible = false
    end
>>>>>>> 68fce3efb4a4e03149113b2568733617304d9375
end

return TweenController
