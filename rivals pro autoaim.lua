-- MODEL 1.0 (REVISION B) - DEBUG ENABLED
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local SETTINGS = {
    FOV = 150,
    SMOOTH = 1, -- Instant
    KEY = Enum.UserInputType.MouseButton2
}

local aiming = false

-- FOV VISUAL
local fov = Drawing.new("Circle")
fov.Visible = true
fov.Thickness = 1
fov.Radius = SETTINGS.FOV
fov.Color = Color3.fromRGB(255, 255, 255)

local function getClosest()
    local mouse = UserInputService:GetMouseLocation()
    local target = nil
    local dist = SETTINGS.FOV

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            -- Check for Head or Torso safely
            local part = p.Character:FindFirstChild("Head") or p.Character:FindFirstChild("UpperTorso")
            
            if part then
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local magnitude = (Vector2.new(pos.X, pos.Y) - mouse).Magnitude
                    if magnitude < dist then
                        dist = magnitude
                        target = pos
                    end
                end
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    local mouse = UserInputService:GetMouseLocation()
    fov.Position = mouse

    if aiming then
        local target = getClosest()
        if target then
            -- Attempting relative move
            local dx = (target.X - mouse.X) * SETTINGS.SMOOTH
            local dy = (target.Y - mouse.Y) * SETTINGS.SMOOTH
            
            -- Testing for JJSploit specific movement support
            if mousemoverel then
                mousemoverel(dx, dy)
            else
                warn("Your executor does not support mousemoverel!")
            end
        end
    end
end)

UserInputService.InputBegan:Connect(function(i)
    if i.UserInputType == SETTINGS.KEY then aiming = true end
end)

UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == SETTINGS.KEY then aiming = false end
end)

print("--- AIM 1.0 DEBUG STARTED ---")
