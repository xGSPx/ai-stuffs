-- [[ GLOWZERODEV | NO-ERROR SCRIPT ]] --
local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local Stealables = workspace:WaitForChild("StealableItems")

local Toggles = {}
Toggles.Reach = false

local PRIORITY = {["Secret"] = 1, ["Mythical"] = 2}
local COLORS = {["Secret"] = Color3.fromRGB(255, 0, 100), ["Mythical"] = Color3.fromRGB(255, 0, 0)}

-- 1. DRAG LOGIC (Simplified for Compatibility)
local function Drag(obj)
    local dragToggle, dragStart, startPos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragToggle = true
            dragStart = input.Position
            startPos = obj.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragToggle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragToggle = false
        end
    end)
end

-- 2. UI CREATION
local MobileGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local ToggleBtn = Instance.new("TextButton", MobileGui)
ToggleBtn.Size = UDim2.new(0, 45, 0, 45)
ToggleBtn.Position = UDim2.new(0, 15, 0.5, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 100)
ToggleBtn.Text = "GZ"
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
Drag(ToggleBtn)

local Main = Instance.new("Frame", MobileGui)
Main.Size = UDim2.new(0, 200, 0, 280)
Main.Position = UDim2.new(0.5, -100, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.Visible = true
Instance.new("UICorner", Main)
Drag(Main)

local Brand = Instance.new("TextLabel", Main)
Brand.Size = UDim2.new(1, 0, 0, 30)
Brand.Text = "GlowZeroDev"
Brand.TextColor3 = Color3.fromRGB(255, 0, 100)
Brand.BackgroundTransparency = 1

local ReachBtn = Instance.new("TextButton", Main)
ReachBtn.Size = UDim2.new(0.9, 0, 0, 30)
ReachBtn.Position = UDim2.new(0.05, 0, 0.12, 0)
ReachBtn.Text = "SAFE REACH: OFF"
ReachBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ReachBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", ReachBtn)

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(0.9, 0, 0.65, 0)
Scroll.Position = UDim2.new(0.05, 0, 0.25, 0)
Scroll.BackgroundTransparency = 1
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding = UDim.new(0, 3)
Layout.SortOrder = Enum.SortOrder.LayoutOrder

-- 3. GLOBAL REACH (Anti-Self, Anti-Friend, Non-Nesting)
local function DoReach()
    local char = player.Character
    local tool = char and (char:FindFirstChild("Bat") or player.Backpack:FindFirstChild("Bat"))
    local handle = tool and tool:FindFirstChild("Handle")
    
    if handle then
        local players = game.Players:GetPlayers()
        for i = 1, #players do
            local p = players[i]
            if p ~= player and not player:IsFriendsWith(p.UserId) then
                local root = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    firetouchinterest(root, handle, 0)
                    firetouchinterest(root, handle, 1)
                end
            end
        end
    end
end

-- 4. SNIPER SYNC
local function Sync(item)
    local bill = item:WaitForChild("InGamePetBillboard", 10)
    if not bill then return end
    local r = bill:WaitForChild("Rarity", 5)
    local n = bill:WaitForChild("NameLbl", 5)
    
    if r and n and (string.find(r.Text, "Mythical") or string.find(r.Text, "Secret")) then
        local btn = Instance.new("TextButton", Scroll)
        btn.Name = item.Name
        btn.Size = UDim2.new(1, 0, 0, 35)
        btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        btn.Text = r.Text .. "\n" .. n.Text
        btn.TextColor3 = COLORS[r.Text] or Color3.new(1, 1, 1)
        btn.LayoutOrder = PRIORITY[r.Text] or 99
        Instance.new("UICorner", btn)

        btn.MouseButton1Click:Connect(function()
            if player.Character then player.Character:PivotTo(item:GetPivot() * CFrame.new(0, 5, 0)) end
        end)
    end
end

-- 5. RUNTIME TRIGGERS
ToggleBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

ReachBtn.MouseButton1Click:Connect(function()
    Toggles.Reach = not Toggles.Reach
    ReachBtn.Text = "REACH: " .. (Toggles.Reach and "ON" or "OFF")
    ReachBtn.BackgroundColor3 = Toggles.Reach and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(30, 30, 30)
end)

-- Main Loop
spawn(function()
    while true do
        wait(0.2)
        if Toggles.Reach == true then
            DoReach()
        end
    end
end)

local current = Stealables:GetChildren()
for i = 1, #current do Sync(current[i]) end
Stealables.ChildAdded:Connect(Sync)
Stealables.ChildRemoved:Connect(function(c)
    local b = Scroll:FindFirstChild(c.Name)
    if b then b:Destroy() end
end)
