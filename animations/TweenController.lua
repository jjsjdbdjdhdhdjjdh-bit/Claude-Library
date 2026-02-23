local TweenService = game:GetService("TweenService")

local TweenController = {}

TweenController.fast = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
TweenController.med  = TweenInfo.new(0.20, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

function TweenController.tw(obj, info, props)
    TweenService:Create(obj, info, props):Play()
end

return TweenController
