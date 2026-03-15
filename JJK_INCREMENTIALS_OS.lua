local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LP = Players.LocalPlayer
local Data = LP:WaitForChild("JJKData")
local Remotes = RS:WaitForChild("JJKRemotes")

-- State Management
_G.AutoRollCT = false
_G.AutoRollStyle = false
_G.AutoRollTrait = false
_G.AutoFarm = false

local SessionStart = tick()
local GainedPrestige = 0
local LastPrestigeVal = Data.Prestige.Value

-- Rarity Target Lists (Based on your Tier List images)
local S_Plus_CTs = {"Star Rage", "Idle Transfiguration", "Comedian", "Cursed Spirit Manipulation"}
local S_Tier_Styles = {"Jujutsu Sorcerer", "Heavenly Tyrant"}
local S_Tier_Traits = {"Spiritually Gifted", "Physically Gifted", "Ryomen's Vessel", "Perfect Body"}

-- Instant Unlock Side Panel Logic
Data.OwnsCTBag.Value = true
Data.OwnsInstantRoll.Value = true

-- UI Setup
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 260, 0, 360)
Main.Position = UDim2.new(0.1, 0, 0.5, -180) -- Side panel placement
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true

local function createToggle(text, pos, var, color)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = pos
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    btn.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    btn.Font = Enum.Font.Code
    
    btn.MouseButton1Click:Connect(function()
        _G[var] = not _G[var]
        btn.BackgroundColor3 = _G[var] and (color or Color3.fromRGB(0, 150, 100)) or Color3.fromRGB(30, 30, 35)
        btn.TextColor3 = _G[var] and Color3.new(1, 1, 1) or Color3.new(0.8, 0.8, 0.8)
    end)
end

-- UI Labels
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "NEXUS v28 | JJK"
Title.TextColor3 = Color3.fromRGB(0, 200, 255)
Title.BackgroundTransparency = 1

local InfoLabel = Instance.new("TextLabel", Main)
InfoLabel.Size = UDim2.new(1, -20, 0, 60)
InfoLabel.Position = UDim2.new(0, 10, 0.75, 0)
InfoLabel.Text = "Uptime: 00:00:00\nPrestige: 0\nGained: 0"
InfoLabel.TextColor3 = Color3.new(1, 1, 1)
InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
InfoLabel.BackgroundTransparency = 1

-- Toggles
createToggle("INFINITE CT ROLL", UDim2.new(0.05, 0, 0.15, 0), "AutoRollCT", Color3.fromRGB(150, 0, 200))
createToggle("STRICT STYLE ROLL", UDim2.new(0.05, 0, 0.28, 0), "AutoRollStyle")
createToggle("STRICT TRAIT ROLL", UDim2.new(0.05, 0, 0.41, 0), "AutoRollTrait")
createToggle("START PRESTIGE FARM", UDim2.new(0.05, 0, 0.58, 0), "AutoFarm", Color3.fromRGB(200, 50, 50))

-- [[ LOGIC CORES ]]

-- 1. Infinite CT Roller (S+ Only)
task.spawn(function()
    while task.wait(0.1) do
        if _G.AutoRollCT then
            -- We don't stop even if we hit S+, because you have a bag.
            -- This keeps hunting for Cursed Rarity CTs to store.
            Remotes.RerollCT:FireServer()
        end
    end
end)

-- 2. Strict Rollers (Style/Trait)
task.spawn(function()
    while task.wait(0.3) do
        if _G.AutoRollStyle then
            if not table.find(S_Tier_Styles, Data.FightingStyle.Value) then
                Remotes.RerollStyle:FireServer()
            else
                _G.AutoRollStyle = false -- Found S Tier, Stop.
            end
        end
        
        if _G.AutoRollTrait then
            if not table.find(S_Tier_Traits, Data.Trait.Value) then
                Remotes.RerollTrait:FireServer()
            else
                _G.AutoRollTrait = false -- Found S Tier, Stop.
            end
        end
    end
end)

-- 3. Prestige Core
task.spawn(function()
    while task.wait(0.15) do
        if _G.AutoFarm then
            Remotes.GradeUp:FireServer()
            Remotes.Prestige:FireServer()
            Remotes.ResolveCombat:InvokeServer("Special Grade Boss", "Eso & Kechizu")
        end
    end
end)

-- 4. Stats Thread
RunService.Heartbeat:Connect(function()
    local elapsed = tick() - SessionStart
    local h, m, s = elapsed/3600, (elapsed/60)%60, elapsed%60
    
    if Data.Prestige.Value > LastPrestigeVal then
        GainedPrestige = GainedPrestige + (Data.Prestige.Value - LastPrestigeVal)
        LastPrestigeVal = Data.Prestige.Value
    end
    
    InfoLabel.Text = string.format(
        "Uptime: %02d:%02d:%02d\nTotal Prestige: %d\nSession Gained: %d",
        h, m, s, Data.Prestige.Value, GainedPrestige
    )
end)
