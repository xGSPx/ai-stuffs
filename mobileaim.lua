-- // CONFIG
local SETTINGS = {
    FOV = 150,
    SMOOTH = 0.2,
    AUTO_SHOOT = true,
    TEAM_CHECK = false,
    CIRCLE_COLOR = Color3.fromRGB(255, 255, 255),
    NAME_COLOR = Color3.fromRGB(0, 255, 150)
}

-- // SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera

-- // DRAWING - FOV CIRCLE
local fov_circle = Drawing.new("Circle")
fov_circle.Thickness = 1
fov_circle.Transparency = 1
fov_circle.Color = SETTINGS.CIRCLE_COLOR

-- // CHECK IF HOLDING TOOL
local function isHoldingTool()
    local char = lp.Character
    return char and char:FindFirstChildOfClass("Tool") ~= nil
end

-- // UTILS
local function getNearest()
    local target, closest = nil, SETTINGS.FOV
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("Head") then
            if SETTINGS.TEAM_CHECK and p.Team == lp.Team then continue end
            
            local pos, onScreen = cam:WorldToViewportPoint(p.Character.Head.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)).Magnitude
                if dist < closest then
                    closest = dist
                    target = p.Character.Head
                end
            end
        end
    end
    return target
end

-- // NAME ESP
local function createESP(p)
    local text = Drawing.new("Text")
    text.Visible = false
    text.Center = true
    text.Outline = true
    text.Font = 2
    text.Size = 14
    text.Color = SETTINGS.NAME_COLOR

    RunService.RenderStepped:Connect(function()
        if p.Character and p.Character:FindFirstChild("Head") then
            local pos, onScreen = cam:WorldToViewportPoint(p.Character.Head.Position)
            if onScreen then
                text.Position = Vector2.new(pos.X, pos.Y - 30)
                text.Text = p.DisplayName or p.Name
                text.Visible = true
            else text.Visible = false end
        else text.Visible = false end
        if not p.Parent then text:Remove() end
    end)
end

for _, p in pairs(Players:GetPlayers()) do if p ~= lp then createESP(p) end end
Players.PlayerAdded:Connect(createESP)

-- // MAIN RENDER LOOP
RunService.RenderStepped:Connect(function()
    fov_circle.Radius = SETTINGS.FOV
    fov_circle.Position = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
    fov_circle.Visible = isHoldingTool() -- Only show FOV when weapon is out

    -- Only run Aim/Shoot if a tool is equipped
    if isHoldingTool() then
        local target = getNearest()
        if target then
            -- 1. Auto Aim
            local targetCF = CFrame.new(cam.CFrame.Position, target.Position)
            cam.CFrame = cam.CFrame:Lerp(targetCF, SETTINGS.SMOOTH)
            
            -- 2. Auto Shoot
            if SETTINGS.AUTO_SHOOT then
                VIM:SendMouseButtonEvent(cam.ViewportSize.X/2, cam.ViewportSize.Y/2, 0, true, game, 0)
                task.wait()
                VIM:SendMouseButtonEvent(cam.ViewportSize.X/2, cam.ViewportSize.Y/2, 0, false, game, 0)
            end
        end
    end
end)
