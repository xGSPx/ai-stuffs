-- // Services \\ --
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

-- // Settings \\ --
local Settings = {
    AutoFarm = false,
    TeleportDelay = 0, -- Speed between chests (Lower = Faster)
    ChestFolder = Workspace:WaitForChild("Game"):WaitForChild("Chests")
}

-- // Variables \\ --
local LocalPlayer = Players.LocalPlayer

-- // UI Creation (Mobile Friendly) \\ --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ChestFarmUI"
ScreenGui.ResetOnSpawn = false
-- Safe Parent for Mobile Executors
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 180, 0, 130)
MainFrame.Position = UDim2.new(0.5, -90, 0.3, 0) -- Center Screen
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Header
local Title = Instance.new("TextLabel")
Title.Text = "CHEST FARM"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Parent = MainFrame

-- Status
local StatusLbl = Instance.new("TextLabel")
StatusLbl.Text = "Status: IDLE"
StatusLbl.Size = UDim2.new(1, 0, 0, 20)
StatusLbl.Position = UDim2.new(0, 0, 0, 35)
StatusLbl.BackgroundTransparency = 1
StatusLbl.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusLbl.Font = Enum.Font.Gotham
StatusLbl.TextSize = 12
StatusLbl.Parent = MainFrame

-- Toggle Button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 160, 0, 35)
ToggleBtn.Position = UDim2.new(0, 10, 0, 60)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
ToggleBtn.Text = "START FARM"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 14
ToggleBtn.Parent = MainFrame
local BtnCorner = Instance.new("UICorner")
BtnCorner.Parent = ToggleBtn

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 160, 0, 20)
CloseBtn.Position = UDim2.new(0, 10, 0, 100)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
CloseBtn.Text = "Close GUI"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.Gotham
CloseBtn.TextSize = 11
CloseBtn.Parent = MainFrame

-- // Logic Functions \\ --

-- Helper: Find the "Body" of the chest to TP to
local function GetChestRoot(model)
    if model:IsA("Model") then
        return model.PrimaryPart or model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Part") or model:FindFirstChildWhichIsA("BasePart")
    elseif model:IsA("BasePart") then
        return model
    end
    return nil
end

-- Helper: Press 'E' automatically
local function AttemptOpen(chest)
    if not chest then return end
    
    -- Look for ProximityPrompt
    local prompt = chest:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt then
        fireproximityprompt(prompt) -- Built-in executor function
    end
end

-- Main Loop
task.spawn(function()
    while true do
        if Settings.AutoFarm then
            local chests = Settings.ChestFolder:GetChildren()
            
            if #chests == 0 then
                StatusLbl.Text = "No Chests Found"
                StatusLbl.TextColor3 = Color3.fromRGB(255, 150, 0)
            else
                for _, chest in ipairs(chests) do
                    if not Settings.AutoFarm then break end
                    
                    local root = GetChestRoot(chest)
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    
                    if root and hrp then
                        StatusLbl.Text = "Collecting..."
                        StatusLbl.TextColor3 = Color3.fromRGB(100, 255, 100)

                        -- 1. Teleport (3 studs above)
                        hrp.CFrame = root.CFrame * CFrame.new(0, 3, 0)
                        hrp.Velocity = Vector3.zero -- Stop falling
                        
                        -- 2. Interact
                        task.wait(0.1)
                        AttemptOpen(chest)
                        
                        -- 3. Wait for collection
                        task.wait(Settings.TeleportDelay)
                    end
                end
            end
        else
            StatusLbl.Text = "Status: IDLE"
            StatusLbl.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
        task.wait(0.5)
    end
end)

-- // Connections \\ --

ToggleBtn.MouseButton1Click:Connect(function()
    Settings.AutoFarm = not Settings.AutoFarm
    if Settings.AutoFarm then
        ToggleBtn.Text = "STOP FARM"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    else
        ToggleBtn.Text = "START FARM"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    Settings.AutoFarm = false
    ScreenGui:Destroy()
end)

-- Notify
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "Script Loaded",
        Text = "Chest Farm Ready!",
        Duration = 3
    })
end)