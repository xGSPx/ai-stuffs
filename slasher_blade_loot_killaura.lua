-- // Settings \\ --
local Settings = {
    Range = 80,              -- Max distance to include mobs (Keep this realistic to avoid bans)
    AttackDelay = 0.1,       -- How fast to fire the remote
    DebugMode = true         -- Print how many mobs you are hitting
}

-- // Services \\ --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- // Variables \\ --
local LocalPlayer = Players.LocalPlayer
local Farming = false

-- // UI Creation \\ --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MassAttackUI"
ScreenGui.ResetOnSpawn = false
if CoreGui:FindFirstChild("MassAttackUI") then CoreGui.MassAttackUI:Destroy() end
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 250, 0, 130)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -65)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Text = "AOE Mass Farm"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Parent = MainFrame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 230, 0, 40)
ToggleBtn.Position = UDim2.new(0, 10, 0, 40)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 70)
ToggleBtn.Text = "Start Mass Attack"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 14
ToggleBtn.Parent = MainFrame

local DestroyBtn = Instance.new("TextButton")
DestroyBtn.Size = UDim2.new(0, 230, 0, 25)
DestroyBtn.Position = UDim2.new(0, 10, 0, 90)
DestroyBtn.BackgroundColor3 = Color3.fromRGB(140, 40, 40)
DestroyBtn.Text = "Delete GUI"
DestroyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
DestroyBtn.Font = Enum.Font.Gotham
DestroyBtn.TextSize = 12
DestroyBtn.Parent = MainFrame

-- // Logic Functions \\ --

-- Helper to get the Remote safely
local function GetRemote()
    return ReplicatedStorage:FindFirstChild("Remote") 
        and ReplicatedStorage.Remote:FindFirstChild("Event") 
        and ReplicatedStorage.Remote.Event:FindFirstChild("Combat") 
        and ReplicatedStorage.Remote.Event.Combat:FindFirstChild("M1")
end

-- Helper to process a folder
local function ProcessFolder(folder, rootPart, targetTable)
    if not folder then return end
    
    for _, mob in pairs(folder:GetChildren()) do
        if mob:IsA("Model") and mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChild("Humanoid") then
            if mob.Humanoid.Health > 0 then
                local dist = (rootPart.Position - mob.HumanoidRootPart.Position).Magnitude
                
                -- Only add to list if within range
                if dist <= Settings.Range then
                    table.insert(targetTable, mob.Name) -- The Name is the ID
                end
            end
        end
    end
end

local function MassAttackLoop()
    while true do
        task.wait(Settings.AttackDelay)
        
        if Farming then
            local Character = LocalPlayer.Character
            local Root = Character and Character:FindFirstChild("HumanoidRootPart")
            local Remote = GetRemote()

            if Root and Remote then
                -- 1. Create the empty table that will hold ALL mob IDs
                local allTargets = {}

                -- 2. Check workspace.Live.Mob
                local Live = Workspace:FindFirstChild("Live")
                if Live then
                    ProcessFolder(Live:FindFirstChild("Mob"), Root, allTargets)
                    ProcessFolder(Live:FindFirstChild("MobModel"), Root, allTargets)
                end

                -- 3. Fire Remote if we found targets
                if #allTargets > 0 then
                    
                    -- Construct the arguments exactly as you requested:
                    -- index [1] is the table containing all the IDs.
                    local args = {
                        [1] = allTargets 
                    }
                    
                    if Settings.DebugMode then
                        print("Hitting " .. #allTargets .. " mobs at once.")
                    end

                    pcall(function()
                        Remote:FireServer(unpack(args))
                    end)
                end
            end
        end
    end
end

-- // Connections \\ --

ToggleBtn.MouseButton1Click:Connect(function()
    Farming = not Farming
    if Farming then
        ToggleBtn.Text = "Stop Farm"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    else
        ToggleBtn.Text = "Start Mass Attack"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 70)
    end
end)

DestroyBtn.MouseButton1Click:Connect(function()
    Farming = false
    ScreenGui:Destroy()
end)

-- Start
task.spawn(MassAttackLoop)