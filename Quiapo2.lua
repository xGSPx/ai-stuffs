local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

-- --- CONFIG & PATHS ---
local BOX_PATH = workspace.DeliverySystem.YouCanDeleteTheseObjects:WaitForChild("CardBoardBox")
local DELIV = workspace.DeliverySystem.DontDeleteTheseObjects
local targetPart = DELIV:WaitForChild("TargetPart")
local jobPart = DELIV:WaitForChild("GetJobPart")
local jobPrompt = jobPart:WaitForChild("ProximityPrompt")

local farmActive = false

-- --- DELTA GUI ---
local sg = Instance.new("ScreenGui", LP.PlayerGui)
local btn = Instance.new("TextButton", sg)
btn.Size = UDim2.new(0, 200, 0, 50)
btn.Position = UDim2.new(0.05, 0, 0.4, 0)
btn.Text = "INVIS-FARM: OFF"
btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
btn.TextColor3 = Color3.new(1, 1, 1)
btn.Draggable = true

btn.MouseButton1Click:Connect(function()
    farmActive = not farmActive
    btn.Text = farmActive and "INVIS-FARM: ON" or "INVIS-FARM: OFF"
    btn.BackgroundColor3 = farmActive and Color3.fromRGB(200, 80, 0) or Color3.fromRGB(30, 30, 30)
end)

-- --- THE STEALTH ENGINE ---
task.spawn(function()
    while true do
        task.wait(0.1)
        local char = LP.Character
        local torso = char and (char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"))
        local head = char and char:FindFirstChild("Head")
        local backpack = LP:FindFirstChild("Backpack")
        
        if farmActive and torso and head and backpack then
            -- 1. CLOAKING: Put Torso inside the Box model
            -- This makes your hitbox stay 'inside' the delivery assets
            torso.CFrame = BOX_PATH.CFrame
            
            -- 2. FORCE INVENTORY: Move any 'Package' from Character to Backpack
            for _, item in pairs(char:GetChildren()) do
                if item:IsA("Tool") and (item.Name:lower():find("package") or item.Name:lower():find("box")) then
                    item.Parent = backpack -- Hide it from hands
                end
            end
            
            -- 3. INTERACTION: Reach out from Head position
            -- This allows you to walk around while the server thinks you're touching things
            jobPrompt.MaxActivationDistance = 50 -- Large reach so you can move
            fireproximityprompt(jobPrompt)
            
            -- Fire the touch sell (Head position used for magnitude checks)
            firetouchinterest(head, targetPart, 0)
            firetouchinterest(head, targetPart, 1)
            
            -- 4. MOVEMENT FIX: Snap Torso back to Head after the hit
            -- This ensures you don't get stuck in the box while trying to walk
            task.wait(0.05)
            torso.CFrame = head.CFrame * CFrame.new(0, -1, 0)
        end
    end
end)
