-- --- SETTINGS & BLACKLIST ---
local BLACKLIST = {
    [5468326457]=1, [1387217966]=1, [9919748526]=1, [1833959139]=1, 
    [1870244789]=1, [8218607896]=1, [8569031753]=1, [8297151423]=1, 
    [4863220260]=1, [9612183766]=1, [3285179945]=1
}

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local DELIV = workspace:WaitForChild("DeliverySystem"):WaitForChild("DontDeleteTheseObjects")
local Target = DELIV:WaitForChild("TargetPart")
local Prompt = DELIV:WaitForChild("GetJobPart"):WaitForChild("ProximityPrompt")

local active = false

-- --- FAST KICK ---
local function check(p) if BLACKLIST[p.UserId] then LP:Kick("Staff Detected") end end
Players.PlayerAdded:Connect(check)
for _, p in ipairs(Players:GetPlayers()) do check(p) end

-- --- MINIMAL UI ---
local sg = Instance.new("ScreenGui", LP.PlayerGui)
local btn = Instance.new("TextButton", sg)
btn.Size = UDim2.new(0, 150, 0, 40)
btn.Position = UDim2.new(0, 10, 0.5, 0)
btn.Text = "FARM: OFF"
btn.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
btn.TextColor3 = Color3.new(1, 1, 1)

local walletLabel = Instance.new("TextLabel", sg)
walletLabel.Size = UDim2.new(0, 150, 0, 20)
walletLabel.Position = UDim2.new(0, 10, 0.5, 45)
walletLabel.Text = "Wallet: $0"
walletLabel.BackgroundTransparency = 1
walletLabel.TextColor3 = Color3.new(0, 1, 0)

-- --- FAST WALLET UPDATER ---
local function updateWallet()
    local s = LP:FindFirstChild("leaderstats") or LP:FindFirstChild("leaderboard")
    local w = s and (s:FindFirstChild("Wallet") or s:FindFirstChild("Cash"))
    if w then 
        walletLabel.Text = "Wallet: $" .. w.Value 
        w:GetPropertyChangedSignal("Value"):Connect(function()
            walletLabel.Text = "Wallet: $" .. w.Value
        end)
    end
end
task.spawn(updateWallet)

-- --- TOGGLE ---
btn.MouseButton1Click:Connect(function()
    active = not active
    btn.Text = active and "FARM: ON" or "FARM: OFF"
    btn.BackgroundColor3 = active and Color3.new(0, 0.4, 0) or Color3.new(0.1, 0.1, 0.1)
end)

-- --- LIGHT PASSIVE LOOP ---
task.spawn(function()
    while true do
        task.wait(0.1) -- Fast cycle
        if active and LP.Character then
            local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                -- Remote Job Pickup (Only if we don't have a package)
                if not LP.Character:FindFirstChild("Package") then
                    fireproximityprompt(Prompt)
                end
                
                -- Remote Delivery (Always fire touch interest)
                firetouchinterest(hrp, Target, 0)
                firetouchinterest(hrp, Target, 1)
            end
        end
    end
end)
