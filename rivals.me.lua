-- // CONFIGURATION
local PROFILES = {
    ["Normal"] = {
        FOV = 120,
        SMOOTH = 0.4, -- The Pro Glide
        STYLE = "50/50",
        COLOR = Color3.fromRGB(0, 255, 255)
    },
    ["Sniper"] = {
        FOV = 40,
        SMOOTH = 1.0, -- Direct Snap
        STYLE = "Head",
        COLOR = Color3.fromRGB(255, 50, 50)
    }
}

local SETTINGS = {
    AIM_KEY = Enum.UserInputType.MouseButton2,
    TOGGLE_KEY = Enum.KeyCode.E,
    ESP_COLOR = Color3.fromRGB(255, 255, 255),
    TEAM_CHECK = false
}

-- // SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- // GLOBALS & CLEANUP
local currentMode = "Normal"
local aiming = false
_G.AimConnections = _G.AimConnections or {}
_G.ESPLines = _G.ESPLines or {}

local function stop()
    for _, v in pairs(_G.AimConnections) do pcall(function() v:Disconnect() end) end
    if _G.AimFOV then _G.AimFOV:Remove() end
    if _G.ClassicGui then _G.ClassicGui:Destroy() end
end
stop()

-- // MINIMALIST GUI (First Indicator Style)
local ScreenGui = Instance.new("ScreenGui", CoreGui)
_G.ClassicGui = ScreenGui

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 140, 0, 45)
Frame.Position = UDim2.new(0.1, 0, 0.1, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.Active = true; Frame.Draggable = true
Instance.new("UICorner", Frame)

local ModeText = Instance.new("TextLabel", Frame)
ModeText.Size = UDim2.new(1, -30, 1, 0)
ModeText.Position = UDim2.new(0, 10, 0, 0)
ModeText.BackgroundTransparency = 1
ModeText.TextColor3 = PROFILES[currentMode].COLOR
ModeText.Text = "MODE: " .. currentMode
ModeText.Font = Enum.Font.GothamBold; ModeText.TextSize = 14; ModeText.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", Frame)
CloseBtn.Size = UDim2.new(0, 20, 0, 20); CloseBtn.Position = UDim2.new(1, -25, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0); CloseBtn.Text = "X"; CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
Instance.new("UICorner", CloseBtn)

-- // AIM LOGIC
local fov = Drawing.new("Circle")
fov.Visible = true; fov.Thickness = 1; _G.AimFOV = fov

local function getTarget()
    local mouse = UserInputService:GetMouseLocation()
    local conf = PROFILES[currentMode]
    local target, closest = nil, conf.FOV
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            if SETTINGS.TEAM_CHECK and p.Team == LocalPlayer.Team then continue end
            
            local partName = (conf.STYLE == "Head") and "Head" or (math.random(1,100) > 50 and "UpperTorso" or "Head")
            local part = p.Character:FindFirstChild(partName) or p.Character:FindFirstChild("HumanoidRootPart")
            
            if part then
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - mouse).Magnitude
                    if dist < closest then closest = dist; target = pos end
                end
            end
        end
    end
    return target
end

-- // RENDER LOOP
local Bones = {{"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}}

local main = RunService.RenderStepped:Connect(function()
    local mouse = UserInputService:GetMouseLocation()
    local conf = PROFILES[currentMode]
    
    fov.Position = mouse; fov.Radius = conf.FOV; fov.Color = conf.COLOR

    if aiming then
        local t = getTarget()
        if t and mousemoverel then
            local rawX = (t.X - mouse.X)
            local rawY = (t.Y - mouse.Y)
            
            local moveX = rawX * conf.SMOOTH
            local moveY = rawY * conf.SMOOTH
            
            -- NORMAL MODE FRICTION FIX: 
            -- If movement is too small to trigger executor, we force a 1.2 pixel "nudge"
            if math.abs(moveX) < 1 and math.abs(rawX) > 1 then moveX = (rawX > 0 and 1.2 or -1.2) end
            if math.abs(moveY) < 1 and math.abs(rawY) > 1 then moveY = (rawY > 0 and 1.2 or -1.2) end
            
            mousemoverel(moveX, moveY)
        end
    end

    -- SKELETON ESP
    for _, p in pairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        if not _G.ESPLines[p] then
            _G.ESPLines[p] = {}
            for i=1, #Bones do _G.ESPLines[p][i] = Drawing.new("Line") end
        end
        local char = p.Character
        local lines = _G.ESPLines[p]
        local isVis = false
        if char and char:FindFirstChild("HumanoidRootPart") then
            isVis = true
            for i, b in pairs(Bones) do
                local p1, p2 = char:FindFirstChild(b[1]), char:FindFirstChild(b[2])
                if p1 and p2 then
                    local pos1, v1 = Camera:WorldToViewportPoint(p1.Position)
                    local pos2, v2 = Camera:WorldToViewportPoint(p2.Position)
                    if v1 and v2 then
                        lines[i].Visible = true; lines[i].From = Vector2.new(pos1.X, pos1.Y); lines[i].To = Vector2.new(pos2.X, pos2.Y); lines[i].Color = SETTINGS.ESP_COLOR
                    else lines[i].Visible = false end
                else lines[i].Visible = false end
            end
        end
        if not isVis then for _, l in pairs(lines) do l.Visible = false end end
    end
end)

-- // INPUTS
table.insert(_G.AimConnections, main)
table.insert(_G.AimConnections, UserInputService.InputBegan:Connect(function(i, gpe)
    if gpe then return end
    if i.UserInputType == SETTINGS.AIM_KEY then aiming = true end
    if i.KeyCode == SETTINGS.TOGGLE_KEY then
        currentMode = (currentMode == "Normal") and "Sniper" or "Normal"
        ModeText.Text = "MODE: " .. currentMode
        ModeText.TextColor3 = PROFILES[currentMode].COLOR
    end
end))
table.insert(_G.AimConnections, UserInputService.InputEnded:Connect(function(i) if i.UserInputType == SETTINGS.AIM_KEY then aiming = false end end))

print("--- MODEL 3.3 LOADED: NORMAL MODE FIXED ---")
