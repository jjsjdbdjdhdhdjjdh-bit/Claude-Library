local UILib = require(script.Parent.UILib)

local Win = UILib.Window.new({
    Title = "Claude UI",
    Width = 940,
    Height = 620
})

Win:Init(UILib.Notification)
Win:Mount()

UILib.Notification.New({
    Title = "UILib",
    Text = "Interface carregada com sucesso.",
    Duration = 4
})
