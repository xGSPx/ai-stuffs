-- [[ CONFIG SECTION ]] --
local SETTINGS = {
    HitRate = 1/7,
    Rarities = {"OG", "God", "Secret"},
    TweenSpeed = 65
}

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

local Toggles = {Reach = false, BlockAura = false, AutoTween = false}
local BestTarget = nil

-- 1. UI SETUP
local ScreenGui = Instance.new("ScreenGui", CoreGui)
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 200, 0, 260)
Main.Position = UDim2.new(0.5, -100, 0.1, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.Active = true Main.Draggable = true
Instance.new("UICorner", Main)

-- Sidebar for Lucky Blocks
local SidePanel = Instance.new("ScrollingFrame", Main)
SidePanel.Size = UDim2.new(0, 150, 1, 0)
SidePanel.Position = UDim2.new(1, 5, 0, 0)
SidePanel.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
SidePanel.CanvasSize = UDim2.new(0, 0, 0, 0)
SidePanel.ScrollBarThickness = 4
SidePanel.Visible = false
Instance.new("UICorner", SidePanel)

local SideTitle = Instance.new("TextLabel", SidePanel)
SideTitle.Size = UDim2.new(1, 0, 0, 30)
SideTitle.Text = "LUCKY BLOCKS"
SideTitle.TextColor3 = Color3.new(1, 0.8, 0)
SideTitle.BackgroundTransparency = 1
SideTitle.Font = Enum.Font.GothamBold

local UIList = Instance.new("UIListLayout", SidePanel)
UIList.Padding = UDim.new(0, 5)
UIList.SortOrder = Enum.SortOrder.LayoutOrder

-- Header
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 30)
Header.BackgroundColor3 = Color3.fromRGB(85, 0, 255)
Instance.new("UICorner", Header)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, 0, 1, 0)
Title.Text = "NEXUS V29 | 0006yrss"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 11
Title.BackgroundTransparency = 1

local function createBtn(name, pos, toggleKey, parent)
    local b = Instance.new("TextButton", parent or Main)
    b.Size = UDim2.new(0.9, 0, 0, 30)
    b.Position = pos
    b.Text = name .. (toggleKey and ": OFF" or "")
    b.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 10
    Instance.new("UICorner", b)
    if toggleKey then
        b.MouseButton1Click:Connect(function()
            Toggles[toggleKey] = not Toggles[toggleKey]
            b.Text = name .. (Toggles[toggleKey] and ": ON" or ": OFF")
            b.BackgroundColor3 = Toggles[toggleKey] and Color3.fromRGB(100, 0, 255) or Color3.fromRGB(25, 25, 25)
        end)
    end
    return b
end

createBtn("GLOBAL REACH", UDim2.new(0.05, 0, 0.15, 0), "Reach")
createBtn("MASS AURA", UDim2.new(0.05, 0, 0.30, 0), "BlockAura")
createBtn("TWEEN TO SAMMY", UDim2.new(0.05, 0, 0.45, 0), "AutoTween")

local LBListBtn = createBtn("LUCKY LIST >>", UDim2.new(0.05, 0, 0.60, 0))
LBListBtn.MouseButton1Click:Connect(function() SidePanel.Visible = not SidePanel.Visible end)

local TPBtn = Instance.new("TextButton", Main)
TPBtn.Size = UDim2.new(0.9, 0, 0, 35)
TPBtn.Position = UDim2.new(0.05, 0, 0.75, 0)
TPBtn.Text = "SCANNING..."
TPBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Instance.new("UICorner", TPBtn)

-- 2. LUCKY BLOCK LISTER LOGIC
local function updateLuckyList()
    for _, child in pairs(SidePanel:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    local luckyFolder = workspace:FindFirstChild("LuckyBlocks")
    if not luckyFolder then return end
    
    local uniqueNames = {}
    for _, lb in pairs(luckyFolder:GetChildren()) do
        if not uniqueNames[lb.Name] then
            uniqueNames[lb.Name] = lb
            local b = Instance.new("TextButton", SidePanel)
            b.Size = UDim2.new(0.9, 0, 0, 25)
            b.Text = lb.Name
            b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            b.TextColor3 = Color3.new(1, 1, 1)
            b.Font = Enum.Font.Gotham
            b.TextSize = 9
            Instance.new("UICorner", b)
            
            b.MouseButton1Click:Connect(function()
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                local target = luckyFolder:FindFirstChild(lb.Name)
                if hrp and target then
                    hrp.CFrame = target:GetPivot() * CFrame.new(0, 3, 0)
                end
            end)
        end
    end
    SidePanel.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y + 40)
end

task.spawn(function()
    while task.wait(5) do updateLuckyList() end
end)

-- 3. MAIN LOOP
task.spawn(function()
    local Remote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("DamageBlockEvent")
    
    while true do
        task.wait(SETTINGS.HitRate)
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        
        -- Mass Block Aura + Sammy Focus
        if Toggles.BlockAura then
            -- Kill Sammy first
            if workspace:FindFirstChild("HeartbreakerSammyRig") then
                Remote:FireServer(workspace.HeartbreakerSammyRig)
            end
            -- Then clear lucky blocks
            local lucky = workspace:FindFirstChild("LuckyBlocks")
            if lucky then
                for _, block in pairs(lucky:GetChildren()) do
                    Remote:FireServer(block)
                end
            end
        end

        -- Sammy Tween
        if Toggles.AutoTween and hrp and workspace:FindFirstChild("HeartbreakerSammyRig") then
            local targetPos = workspace.HeartbreakerSammyRig:GetPivot().Position
            if (hrp.Position - targetPos).Magnitude > 5 then
                local tInfo = TweenInfo.new((hrp.Position - targetPos).Magnitude/SETTINGS.TweenSpeed, Enum.EasingStyle.Linear)
                TweenService:Create(hrp, tInfo, {CFrame = CFrame.new(targetPos + Vector3.new(0, 5, 0))}):Play()
            end
        end

        -- Reach Logic
        if Toggles.Reach then
            local bat = char and char:FindFirstChild("Bat")
            if bat and bat:FindFirstChild("Handle") then
                for _, p in ipairs(game.Players:GetPlayers()) do
                    if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        firetouchinterest(p.Character.HumanoidRootPart, bat.Handle, 0)
                        firetouchinterest(p.Character.HumanoidRootPart, bat.Handle, 1)
                    end
                end
            end
        end
    end
end)
