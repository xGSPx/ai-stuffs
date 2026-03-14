-- [[ ABYSSAL V3: RAW TOGGLE FIX ]] --
local player = game:GetService("Players").LocalPlayer
local sg = Instance.new("ScreenGui", player.PlayerGui)
sg.Name = "TitanToggleFix"

-- State
_G.VacuumEnabled = true

-- The Button (This IS the toggle)
local btn = Instance.new("TextButton", sg)
btn.Size = UDim2.new(0, 200, 0, 50)
btn.Position = UDim2.new(0.5, -100, 0.2, 0)
btn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
btn.Text = "VACUUM: ON"
btn.TextColor3 = Color3.new(1,1,1)
btn.Font = Enum.Font.SourceSansBold
btn.TextSize = 20
btn.Draggable = true -- Standard JJSploit drag

-- Toggle Logic
btn.MouseButton1Click:Connect(function()
    _G.VacuumEnabled = not _G.VacuumEnabled
    if _G.VacuumEnabled then
        btn.Text = "VACUUM: ON"
        btn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    else
        btn.Text = "VACUUM: OFF"
        btn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    end
end)

-- The Collection Loop
task.spawn(function()
    while task.wait(0.2) do
        if _G.VacuumEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character.HumanoidRootPart
            
            pcall(function()
                -- 1. Scan Debris (Models or Parts)
                for _, item in pairs(workspace.Debris:GetChildren()) do
                    -- This finds the "TouchPart" even if it's hidden in a model
                    local touch = item:FindFirstChild("Collider") or item:FindFirstChild("Handle") or item:IsA("BasePart") and item
                    if touch then
                        firetouchinterest(root, touch, 0)
                        task.wait()
                        firetouchinterest(root, touch, 1)
                    end
                end

                -- 2. Scan Obby Coins [5] (Specific Index)
                local obbyFolder = workspace.Environment.Obby.Coins:GetChildren()
                local targetCoin = obbyFolder[5]
                if targetCoin then
                    local touch = targetCoin:FindFirstChild("Collider") or targetCoin:FindFirstChild("Handle") or targetCoin:IsA("BasePart") and targetCoin
                    if touch then
                        firetouchinterest(root, touch, 0)
                        task.wait()
                        firetouchinterest(root, touch, 1)
                    end
                end
            end)
        end
    end
end)
