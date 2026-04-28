local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera

-- // CONFIGURATION // --
local CONFIG = {
    FOV_RADIUS = 50,               -- Updated to 50 per request
    FOV_COLOR = Color3.new(1, 0, 0), -- Pure Red
    FOV_THICKNESS = 2,             
    AUTO_TEAM_CHECK = true,        
}

local LocalPlayer = Players.LocalPlayer
local Remote = ReplicatedStorage:WaitForChild("BridgeNet2"):WaitForChild("dataRemoteEvent")

-- // UI SETUP // --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MobileScriptHub"
ScreenGui.Parent = CoreGui
ScreenGui.IgnoreGuiInset = true -- Ensures circle aligns with the actual screen center

-- Toggle Button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ToggleButton.Position = UDim2.new(0.05, 0, 0.4, 0)
ToggleButton.Size = UDim2.new(0, 120, 0, 50)
ToggleButton.Text = "AUTO: OFF"
ToggleButton.TextColor3 = Color3.new(1, 0, 0)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 18

local UICornerBtn = Instance.new("UICorner")
UICornerBtn.CornerRadius = UDim.new(0, 😎
UICornerBtn.Parent = ToggleButton

-- Hollow FOV Circle Border
local FOVFrame = Instance.new("Frame")
FOVFrame.Name = "FOV_Circle"
FOVFrame.Parent = ScreenGui
FOVFrame.BackgroundTransparency = 1 
FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FOVFrame.Position = UDim2.new(0.5, 0, 0.5, 0) -- Centered on your white dot
FOVFrame.Size = UDim2.new(0, CONFIG.FOV_RADIUS * 2, 0, CONFIG.FOV_RADIUS * 2)

local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = CONFIG.FOV_THICKNESS
UIStroke.Color = CONFIG.FOV_COLOR
UIStroke.Parent = FOVFrame

local UICornerFOV = Instance.new("UICorner")
UICornerFOV.CornerRadius = UDim.new(1, 0)
UICornerFOV.Parent = FOVFrame

local _Toggled = false
ToggleButton.MouseButton1Click:Connect(function()
    _Toggled = not _Toggled
    ToggleButton.Text = _Toggled and "AUTO: ON" or "AUTO: OFF"
    ToggleButton.TextColor3 = _Toggled and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
end)

-- // TARGETING LOGIC // --
local function isInsideFOV(position)
    local screenPos, onScreen = Camera:WorldToViewportPoint(position)
    if onScreen then
        -- Centers check exactly where your white dot is
        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local distance = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
        return distance <= CONFIG.FOV_RADIUS
    end
    return false
end

local function getValidTarget()
    local closestTarget = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local char = player.Character
            local head = char.Head
            
            local isTeammate = CONFIG.AUTO_TEAM_CHECK and player.Team == LocalPlayer.Team and player.Team ~= nil
            local inSafezone = char:FindFirstChildOfClass("ForceField")
            local isAlive = char:FindFirstChildOfClass("Humanoid") and char.Humanoid.Health > 0
            
            if not isTeammate and not inSafezone and isAlive then
                if isInsideFOV(head.Position) then
                    local screenPos, _ = Camera:WorldToViewportPoint(head.Position)
                    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    local distToCenter = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    
                    if distToCenter < shortestDistance then
                        closestTarget = player
                        shortestDistance = distToCenter
                    end
                end
            end
        end
    end
    return closestTarget
end

-- // MAIN LOOP // --
RunService.RenderStepped:Connect(function()
    if not _Toggled then return end
    
    local target = getValidTarget()
    if target then
        local head = target.Character.Head
        
        local args = {
            [1] = {
                [1] = {
                    ["char"] = LocalPlayer.Character,
                    ["hitPart"] = head,
                    ["hitPosition"] = head.Position,
                    ["hitId"] = math.random(1000000, 9999999),
                    ["cameraPos"] = Camera.CFrame.Position,
                    ["cameraDir"] = Camera.CFrame.LookVector,
                    ["timestamp"] = tick(),
                    ["hitType"] = "Hit"
                },
                [2] = "\n",
                [3] = {
                    ["hitPart"] = head,
                    ["hitPosition"] = head.Position,
                    ["hitType"] = "Replicate"
                },
                [4] = "\n"
            }
        }
        
        Remote:FireServer(unpack(args))
    end
end)
