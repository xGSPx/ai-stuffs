local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("JJKRemotes")

-- Wave Watcher Setup
local WaveStat = LP:WaitForChild("JJKData"):WaitForChild("InfiniteRaidBestWave")
local InitialWave = WaveStat.Value

-- Modern GUI Setup
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 180, 0, 250)
Main.Position = UDim2.new(0.5, -90, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "UNLOCKED SPEED"
Title.TextColor3 = Color3.fromRGB(255, 50, 50)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold

local List = Instance.new("UIListLayout", Main)
List.Padding = UDim.new(0, 5)
List.HorizontalAlignment = Enum.HorizontalAlignment.Center

local Toggles = { Raid = false, Prestige = false, AntiBan = true }

local function CreateBtn(name, key)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.BackgroundColor3 = Toggles[key] and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(30, 30, 35)
    btn.Text = name
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamMedium
    Instance.new("UICorner", btn)
    
    btn.MouseButton1Click:Connect(function()
        Toggles[key] = not Toggles[key]
        btn.BackgroundColor3 = Toggles[key] and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(30, 30, 35)
    end)
end

CreateBtn("SPAM PRESTIGE", "Prestige")
CreateBtn("SPAM RAID", "Raid")
CreateBtn("WAVE PROTECTOR", "AntiBan")

-- The "No Holding Back" Loop
RunService.Heartbeat:Connect(function()
    -- 1. WAVE PROTECTION (Highest Priority)
    if Toggles.AntiBan and WaveStat.Value ~= InitialWave then
        Remotes.InfiniteRaidAction:FireServer("Died")
        InitialWave = WaveStat.Value -- Update to current so it doesn't loop-kill if you restart
    end

    -- 2. PRESTIGE/GRADE SPAM (As fast as possible)
    if Toggles.Prestige then
        task.spawn(function()
            Remotes.GradeUp:FireServer()
            Remotes.Prestige:FireServer()
        end)
    end

    -- 3. RAID SPAM
    if Toggles.Raid then
        task.spawn(function()
            Remotes.InfiniteRaidAction:FireServer("WaveComplete")
            Remotes.StartRaid:FireServer("__INFINITE__")
        end)
    end
end)
