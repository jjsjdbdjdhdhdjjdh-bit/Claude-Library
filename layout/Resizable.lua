local UserInputService = game:GetService("UserInputService")
<<<<<<< HEAD

local function makeResizable(frame, handle, minSize, maxSize)
    minSize = minSize or Vector2.new(100, 100)
    maxSize = maxSize or Vector2.new(9999, 9999)

    local dragging = false
    local dragStart, startSize

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startSize = frame.AbsoluteSize
        end
    end)

    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            local newSize = startSize + Vector2.new(delta.X, delta.Y)
            
            newSize = Vector2.new(
                math.clamp(newSize.X, minSize.X, maxSize.X),
                math.clamp(newSize.Y, minSize.Y, maxSize.Y)
            )
            
            frame.Size = UDim2.new(0, newSize.X, 0, newSize.Y)
=======
local Resizable = {}

function Resizable.Enable(frame, handle, minSize, onResize)
    local resizing = false
    local startPos, startSize
    local min = minSize or Vector2.new(100, 100)
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            startPos = input.Position
            startSize = frame.AbsoluteSize
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    resizing = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and resizing then
            local delta = input.Position - startPos
            local newX = math.max(min.X, startSize.X + delta.X)
            local newY = math.max(min.Y, startSize.Y + delta.Y)
            frame.Size = UDim2.new(0, newX, 0, newY)
            if onResize then
                onResize(newX, newY)
            end
>>>>>>> 68fce3efb4a4e03149113b2568733617304d9375
        end
    end)
end

<<<<<<< HEAD
return makeResizable
=======
return Resizable
>>>>>>> 68fce3efb4a4e03149113b2568733617304d9375
