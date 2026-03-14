-- [[ ABYSSAL V3: MOBILE TOGGLE GUI ]] --
-- Features: Draggable, Mobile Compatible, Auto-Vacuum Toggle

local player = game:GetService("Players").LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Toggle State
_G.VacuumActive = true

-- UI Creation
local sg = Instance.new("ScreenGui", player.PlayerGui)
sg.Name = "AbyssalToggle"
sg.ResetOnSpawn = false

local btn = Instance.new("TextButton", sg)
btn.Size = UDim2.new(0, 100, 0, 40)
btn.Position = UDim2.new(0.5, -50, 0.1, 0)
btn.BackgroundColor3 = Color3.fromRGB(40, 200, 80) -- Start Green
btn.Text = "VACUUM: ON"
btn.TextColor3 = Color3.white
btn.Font = Enum.Font.Code
btn.BorderSizePixel = 2

-- Draggable Logic (Mobile Friendly)
local dragging, dragInput, dragStart, startPos
btn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = btn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

btn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Toggle Function
btn.MouseButton1Click:Connect(function()
    _G.VacuumActive = not _G.VacuumActive
    if _G.VacuumActive then
        btn.Text = "VACUUM: ON"
        btn.BackgroundColor3 = Color3.fromRGB(40, 200, 80)
    else
        btn.Text = "VACUUM: OFF"
        btn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
    end
end)

-- The Core Vacuum Logic
local function touchTarget(part)
    if part and rootPart and _G.VacuumActive then
        firetouchinterest(rootPart, part, 0)
        task.wait()
        firetouchinterest(rootPart, part, 1)
    end
end

task.spawn(function()
    while task.wait(0.2) do
        if _G.VacuumActive then
            pcall(function()
                -- 1. Scan Debris
                for _, item in ipairs(workspace.Debris:GetChildren()) do
                    if item.Name == "Coin" or item:FindFirstChild("Collider") then
                        local tp = item:FindFirstChild("Collider") or item:FindFirstChildOfClass("Part") or item:FindFirstChildOfClass("MeshPart")
                        touchTarget(tp)
                    end
                end
                
                -- 2. Scan Obby Index [5]
                local obby = workspace:FindFirstChild("Environment") and workspace.Environment.Obby.Coins
                if obby then
                    local target = obby:GetChildren()[5]
                    if target then
                        local tp = target:FindFirstChild("Collider") or target:FindFirstChildOfClass("Part")
                        touchTarget(tp)
                    end
                end
            end)
        end
    end
end)
