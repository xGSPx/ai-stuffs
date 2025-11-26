-- // Settings \\ --
local MAX_DISTANCE = 1000       -- Distance to scan
local AUTO_KILL_ENABLED = true  -- Start ON/OFF
local TOGGLE_KEY = Enum.KeyCode.K
local SCAN_RATE = 2.0           -- How often to look for NEW mobs (Seconds) - High value = Less Lag
local TARGET_FOLDER = workspace.Game.Inimigos -- Change this if mobs are in a folder like workspace.Mobs

-- // Services \\ --
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- // Variables \\ --
local LocalPlayer = Players.LocalPlayer
local ValidTargets = {} -- Caches targets to prevent laggy scanning

-- // UI Creation (Mobile Optimized) \\ --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OptimizedKillUI"
ScreenGui.ResetOnSpawn = false
-- Parent to CoreGui for PC, PlayerGui for Mobile executors if CoreGui fails
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 150, 0, 80) -- Small compact size
MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
MainFrame.Active = true
MainFrame.Draggable = true -- Essential for Mobile
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Text = "Auto-Kill"
Title.Size = UDim2.new(1, 0, 0, 25)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Parent = MainFrame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "Toggle"
ToggleBtn.Size = UDim2.new(0.9, 0, 0.5, 0)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
ToggleBtn.BackgroundColor3 = AUTO_KILL_ENABLED and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(180, 50, 50)
ToggleBtn.Text = AUTO_KILL_ENABLED and "Status: ON" or "Status: OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 16
ToggleBtn.Parent = MainFrame

-- // Core Functions \\ --

-- Update UI Status
local function UpdateUI()
    if AUTO_KILL_ENABLED then
        ToggleBtn.Text = "Status: ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
    else
        ToggleBtn.Text = "Status: OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    end
end

-- Efficiently Check if a model is a valid NPC
local function IsValidMob(model)
    if not model or not model:IsA("Model") or model == LocalPlayer.Character then return false end
    
    local hum = model:FindFirstChildOfClass("Humanoid")
    local root = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso") or model:FindFirstChild("Head")
    
    -- Check if alive and valid
    if hum and root and hum.Health > 0 then
        return true, hum, root
    end
    return false
end

-- Thread 1: Scanner (Slow Loop - Prevents Lag)
-- This only runs every few seconds to find targets
task.spawn(function()
    while true do
        local newTargets = {}
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        
        if myRoot then
            -- optimization: GetChildren is much faster than GetDescendants
            for _, child in ipairs(TARGET_FOLDER:GetChildren()) do
                local isMob, hum, root = IsValidMob(child)
                if isMob then
                    local dist = (myRoot.Position - root.Position).Magnitude
                    if dist <= MAX_DISTANCE then
                        table.insert(newTargets, {Model = child, Hum = hum, Root = root})
                    end
                end
            end
            ValidTargets = newTargets -- Update the cache
        end
        task.wait(SCAN_RATE)
    end
end)

-- Thread 2: Killer (Fast Loop - Responsiveness)
-- This runs every frame but only processes the pre-found targets
RunService.Heartbeat:Connect(function()
    if not AUTO_KILL_ENABLED then return end

    for _, data in ipairs(ValidTargets) do
        local hum = data.Hum
        
        -- Logic: If mob exists, is alive, and damaged (Current < Max)
        if hum and hum.Health > 0 and hum.Health < hum.MaxHealth then
            hum.Health = 0
            -- Optional: Break joints for instant death physics
            -- if data.Model then data.Model:BreakJoints() end
        end
    end
end)

-- // Inputs \\ --

-- Toggle Button (Mobile/Mouse)
ToggleBtn.MouseButton1Click:Connect(function()
    AUTO_KILL_ENABLED = not AUTO_KILL_ENABLED
    UpdateUI()
end)

-- Keyboard Toggle
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == TOGGLE_KEY then
        AUTO_KILL_ENABLED = not AUTO_KILL_ENABLED
        UpdateUI()
    end
end)

print("Optimized Auto-Kill Loaded.")