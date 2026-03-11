local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local JJKData = LocalPlayer:WaitForChild("JJKData")
local PrestigeValue = JJKData:WaitForChild("Prestige")

-- Configuration & Stats
_G.AutoFarm = false
local SessionStart = tick()
local SessionPrestigeCount = 0
local LastPrestigeValue = PrestigeValue.Value

-- Create UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JJK_Ultimate_Tracker"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 220)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -110)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- UI Elements Helper
local function createLabel(text, pos, parent, color)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 20)
    lbl.Position = pos
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = color or Color3.new(1, 1, 1)
    lbl.Text = text
    lbl.Font = Enum.Font.Code
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
    return lbl
end

local Title = createLabel(">> JJK STATS TRACKER", UDim2.new(0, 10, 0, 10), MainFrame, Color3.fromRGB(0, 255, 150))
local TimeLabel = createLabel("Uptime: 00:00:00", UDim2.new(0, 10, 0, 40), MainFrame)
local TotalLabel = createLabel("Total: " .. PrestigeValue.Value, UDim2.new(0, 10, 0, 65), MainFrame)
local SessionLabel = createLabel("Gained: 0", UDim2.new(0, 10, 0, 90), MainFrame)
local PPHLabel = createLabel("Rate: 0/hr", UDim2.new(0, 10, 0, 115), MainFrame, Color3.fromRGB(255, 200, 0))

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.8, 0, 0, 35)
ToggleBtn.Position = UDim2.new(0.1, 0, 0.7, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
ToggleBtn.Text = "OFFLINE"
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.Parent = MainFrame

-- Minimize Button for Mobile
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 20, 0, 20)
MinBtn.Position = UDim2.new(1, -25, 0, 5)
MinBtn.Text = "-"
MinBtn.Parent = MainFrame
MinBtn.MouseButton1Click:Connect(function()
    for _, v in pairs(MainFrame:GetChildren()) do
        if v:IsA("TextLabel") or v:IsA("TextButton") then
            if v ~= MinBtn and v ~= Title then v.Visible = not v.Visible end
        end
    end
    MainFrame.Size = MainFrame.Size == UDim2.new(0, 220, 0, 220) and UDim2.new(0, 220, 0, 35) or UDim2.new(0, 220, 0, 220)
end)

-- Formatting Logic
local function formatTime(s)
    return string.format("%02d:%02d:%02d", s/3600, (s/60)%60, s%60)
end

-- Update Loop (UI Only)
task.spawn(function()
    while task.wait(1) do
        if _G.AutoFarm then
            local elapsed = tick() - SessionStart
            TimeLabel.Text = "Uptime: " .. formatTime(elapsed)
            
            -- Calculate Rate (Prestige Per Hour)
            local rate = math.floor((SessionPrestigeCount / elapsed) * 3600)
            PPHLabel.Text = "Rate: " .. rate .. "/hr"
        end
    end
end)

-- Stat Tracking
PrestigeValue.Changed:Connect(function(newVal)
    TotalLabel.Text = "Total: " .. newVal
    if newVal > LastPrestigeValue then
        SessionPrestigeCount = SessionPrestigeCount + (newVal - LastPrestigeValue)
        SessionLabel.Text = "Gained: " .. SessionPrestigeCount
    end
    LastPrestigeValue = newVal
end)

-- Core Execution Logic
local function executeRemotes()
    local remotes = ReplicatedStorage:WaitForChild("JJKRemotes")
    local args = {"Special Grade Boss", "Eso & Kechizu"}

    while _G.AutoFarm do
        task.spawn(function()
            remotes.GradeUp:FireServer()
            remotes.Prestige:FireServer()
            remotes.ResolveCombat:InvokeServer(unpack(args))
        end)
        task.wait(0.15)
    end
end

ToggleBtn.MouseButton1Click:Connect(function()
    _G.AutoFarm = not _G.AutoFarm
    if _G.AutoFarm then
        SessionStart = tick()
        SessionPrestigeCount = 0
        SessionLabel.Text = "Gained: 0"
        ToggleBtn.Text = "ACTIVE"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        task.spawn(executeRemotes)
    else
        ToggleBtn.Text = "OFFLINE"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    end
end)
