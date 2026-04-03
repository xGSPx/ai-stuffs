local RunService = game:GetService("RunService")
local LP = game.Players.LocalPlayer

-- Your Exact Coordinates & Rotation
local TARGET_CF = CFrame.new(321, -2.67, -485) * CFrame.Angles(0, math.rad(90), 0)

-- Paths
local DELIV = workspace:WaitForChild("DeliverySystem"):WaitForChild("DontDeleteTheseObjects")
local targetPart = DELIV:WaitForChild("TargetPart")
local jobPart = DELIV:WaitForChild("GetJobPart")
local jobPrompt = jobPart:WaitForChild("ProximityPrompt")

local autoActive = false

-- --- DELTA GUI ---
local sg = Instance.new("ScreenGui", LP.PlayerGui)
local btn = Instance.new("TextButton", sg)
btn.Size = UDim2.new(0, 200, 0, 50)
btn.Position = UDim2.new(0.05, 0, 0.4, 0)
btn.Text = "SURFACE AUTO: OFF"
btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
btn.TextColor3 = Color3.new(1, 1, 1)
btn.Draggable = true

btn.MouseButton1Click:Connect(function()
    autoActive = not autoActive
    btn.Text = autoActive and "SURFACE AUTO: ON" or "SURFACE AUTO: OFF"
    btn.BackgroundColor3 = autoActive and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(35, 35, 35)
end)

-- --- THE LOCK ENGINE ---
RunService.PreSimulation:Connect(function()
    if autoActive and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LP.Character.HumanoidRootPart
        local hum = LP.Character:FindFirstChild("Humanoid")
        
        -- 1. HARD POSITION & ROTATION LOCK
        hrp.CFrame = TARGET_CF
        hrp.Velocity = Vector3.new(0, 0, 0)
        hrp.RotVelocity = Vector3.new(0, 0, 0)
        
        -- 2. PREVENT FALLING/TRIPPING
        if hum then 
            hum:ChangeState(Enum.HumanoidStateType.Physics) 
        end
    end
end)

-- --- THE INTERACTION LOOP ---
task.spawn(function()
    while true do
        task.wait(0.1)
        if autoActive and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LP.Character.HumanoidRootPart
            
            -- Trigger Job Pickup
            if fireproximityprompt then
                fireproximityprompt(jobPrompt)
            else
                jobPrompt:InputHoldBegin()
                task.wait(0.1)
                jobPrompt:InputHoldEnd()
            end
            
            -- Trigger Delivery (Touch)
            firetouchinterest(hrp, targetPart, 0)
            firetouchinterest(hrp, targetPart, 1)
        end
    end
end)
