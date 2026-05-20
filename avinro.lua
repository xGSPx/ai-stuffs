getgenv().AutoFarmLoop = false
getgenv().SpamMultiplier = 5 -- Number of times it fires per frame. Increase/decrease based on device lag.

local workspace = game:GetService("Workspace")
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")

local localPlayer = players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- Cache detectors
local dumpster = workspace:WaitForChild("Dumpster")
local delivery = dumpster:WaitForChild("Delivery"):WaitForChild("ClickDetector", 5)
local sell = dumpster:WaitForChild("Sell"):WaitForChild("ClickDetector", 5)

if not (delivery and sell) then
    warn("ClickDetectors not found! Check path.")
    return
end

-- Clean up any existing instance of this GUI before running
if playerGui:FindFirstChild("ToggleFarmGUI") then
    playerGui.ToggleFarmGUI:Destroy()
end

-- ============================================================================
-- GUI CREATION
-- ============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ToggleFarmGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = playerGui

-- Main Draggable Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 160, 0, 90)
MainFrame.Position = UDim2.new(0.5, -80, 0.4, -45)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Toggle Button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(1, -16, 0, 40)
ToggleButton.Position = UDim2.new(0, 8, 0, 8)
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255) -- Default Blue (OFF)
ToggleButton.Text = "AUTO: OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 16
ToggleButton.Parent = MainFrame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 6)
ButtonCorner.Parent = ToggleButton

-- Delete GUI Button
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(1, -16, 0, 24)
CloseButton.Position = UDim2.new(0, 8, 0, 54)
CloseButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
CloseButton.Text = "Delete GUI"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.SourceSans
CloseButton.TextSize = 14
CloseButton.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

-- ============================================================================
-- OVERCLOCKED AUTOMATION & TOGGLE LOGIC
-- ============================================================================
local farmConnection

local function startLoop()
    if farmConnection then farmConnection:Disconnect() end
    
    -- Fires on every hardware frame step
    farmConnection = runService.Heartbeat:Connect(function()
        if not getgenv().AutoFarmLoop then
            if farmConnection then farmConnection:Disconnect() end
            return
        end
        
        -- Nested loop to spam multiple execution hits per single frame
        for i = 1, getgenv().SpamMultiplier do
            fireclickdetector(delivery)
            fireclickdetector(sell)
        end
    end)
end

ToggleButton.MouseButton1Click:Connect(function()
    getgenv().AutoFarmLoop = not getgenv().AutoFarmLoop
    
    if getgenv().AutoFarmLoop then
        ToggleButton.Text = "HYPER: ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113) -- Green
        startLoop()
    else
        ToggleButton.Text = "AUTO: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255) -- Blue
        if farmConnection then farmConnection:Disconnect() end
    end
end)

-- Delete UI Cleaning
CloseButton.MouseButton1Click:Connect(function()
    getgenv().AutoFarmLoop = false
    if farmConnection then farmConnection:Disconnect() end
    ScreenGui:Destroy()
end)

-- ============================================================================
-- MOBILE-FRIENDLY DRAG SCRIPT
-- ============================================================================
local dragging
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

userInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)
