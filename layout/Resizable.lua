local UserInputService = game:GetService("UserInputService")

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
        end
    end)
end

return makeResizable
