-- ==========================================
-- NAVIS V2 - CUSTOM NEON UI (Tabs + Neon Red Outline + More Scripts)
-- ==========================================

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera

-- Cheat Variables
local flying = false
local speed = 50
local noclip = false
local infJump = false
local isAimbotting = false
local espEnabled = false
local godModeEnabled = false
local isFullbright = false
local spinbotEnabled = false
local spinSpeed = 25
local hitboxEnabled = false
local hitboxSize = 10

local flyCtrl = {f = 0, b = 0, l = 0, r = 0}
local lastCtrl = {f = 0, b = 0, l = 0, r = 0}
local bg, bv
local aimbotLoop
local espHighlights = {}

-- Original Lighting State
local origAmbient = lighting.Ambient
local origOutdoorAmbient = lighting.OutdoorAmbient
local origBrightness = lighting.Brightness
local origClockTime = lighting.ClockTime

-- Helper to make text Neon White
local function MakeTextNeonWhite(textObj)
    textObj.TextColor3 = Color3.fromRGB(255, 255, 255)
    local textGlow = Instance.new("UIStroke")
    textGlow.Parent = textObj
    textGlow.Color = Color3.fromRGB(255, 255, 255)
    textGlow.Thickness = 0.5
    textGlow.Transparency = 0.1
end

-- ==========================================
-- UI CONSTRUCTION
-- ==========================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NavisV2_Neon"
ScreenGui.ResetOnSpawn = false

local success, err = pcall(function()
    ScreenGui.Parent = game:GetService("CoreGui")
end)
if not success then
    ScreenGui.Parent = player:WaitForChild("PlayerGui")
end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "Main"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -200)
MainFrame.Size = UDim2.new(0, 450, 0, 450)
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- THE NEON RED OUTLINE YOU REQUESTED
local MainGlow = Instance.new("UIStroke")
MainGlow.Parent = MainFrame
MainGlow.Color = Color3.fromRGB(255, 0, 0) -- Neon Red
MainGlow.Thickness = 2.5
MainGlow.Transparency = 0.1

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, 0, 0, 45)
Title.Font = Enum.Font.GothamBold
Title.Text = "NAVIS Cheats V2 "
Title.TextSize = 18
MakeTextNeonWhite(Title)

local TitleGlow = Instance.new("UIStroke")
TitleGlow.Parent = Title
TitleGlow.Color = Color3.fromRGB(255, 0, 0) -- Match neon red
TitleGlow.Thickness = 1
TitleGlow.Transparency = 0.3

-- Tab Bar
local TabBar = Instance.new("Frame")
TabBar.Parent = MainFrame
TabBar.BackgroundTransparency = 1
TabBar.Position = UDim2.new(0, 15, 0, 45)
TabBar.Size = UDim2.new(1, -30, 0, 35)

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.Parent = TabBar
TabListLayout.FillDirection = Enum.FillDirection.Horizontal
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 5)

local PagesFolder = Instance.new("Folder")
PagesFolder.Parent = MainFrame

local activeTabBtn = nil
local activePage = nil

-- Function to create a Tab
local function CreateTab(name)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Parent = TabBar
    tabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    tabBtn.Size = UDim2.new(0.33, -3, 1, 0)
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.Text = name
    tabBtn.TextSize = 14
    MakeTextNeonWhite(tabBtn)
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 6)
    tabCorner.Parent = tabBtn
    
    local tabGlow = Instance.new("UIStroke")
    tabGlow.Parent = tabBtn
    tabGlow.Color = Color3.fromRGB(255, 0, 0)
    tabGlow.Thickness = 1
    tabGlow.Transparency = 0.5
    
    local page = Instance.new("ScrollingFrame")
    page.Parent = PagesFolder
    page.BackgroundTransparency = 1
    page.Position = UDim2.new(0, 15, 0, 90)
    page.Size = UDim2.new(1, -30, 1, -105)
    page.ScrollBarThickness = 4
    page.CanvasSize = UDim2.new(0, 0, 0, 600)
    page.BorderSizePixel = 0
    page.ScrollBarImageColor3 = Color3.fromRGB(255, 0, 0)
    page.Visible = false
    
    local pageLayout = Instance.new("UIListLayout")
    pageLayout.Parent = page
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pageLayout.Padding = UDim.new(0, 10)
    
    tabBtn.MouseButton1Click:Connect(function()
        if activeTabBtn then
            activeTabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
            activeTabBtn.UIStroke.Transparency = 0.5
            activeTabBtn.UIStroke.Thickness = 1
            activePage.Visible = false
        end
        activeTabBtn = tabBtn
        activePage = page
        
        tabBtn.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
        tabGlow.Transparency = 0
        tabGlow.Thickness = 2
        page.Visible = true
    end)
    
    if not activePage then
        activeTabBtn = tabBtn
        activePage = page
        tabBtn.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
        tabGlow.Transparency = 0
        tabGlow.Thickness = 2
        page.Visible = true
    end
    
    return page
end

-- ==========================================
-- UI ELEMENT GENERATORS
-- ==========================================

local function CreateToggle(parentPage, name, glowColor, callback)
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Parent = parentPage
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Size = UDim2.new(1, -10, 0, 40)
    ToggleBtn.Font = Enum.Font.GothamSemibold
    ToggleBtn.Text = name .. " [OFF]"
    ToggleBtn.TextSize = 14
    MakeTextNeonWhite(ToggleBtn)
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = ToggleBtn
    
    local BtnGlow = Instance.new("UIStroke")
    BtnGlow.Parent = ToggleBtn
    BtnGlow.Color = glowColor
    BtnGlow.Thickness = 1.5
    BtnGlow.Transparency = 0.5
    
    local state = false
    ToggleBtn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            ToggleBtn.Text = name .. " [ON]"
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(20 + (glowColor.R*40), 20 + (glowColor.G*40), 25 + (glowColor.B*40))
            BtnGlow.Thickness = 2.5
            BtnGlow.Transparency = 0
        else
            ToggleBtn.Text = name .. " [OFF]"
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
            BtnGlow.Thickness = 1.5
            BtnGlow.Transparency = 0.5
        end
        callback(state)
    end)
end

local function CreateSlider(parentPage, name, min, max, default, glowColor, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Parent = parentPage
    SliderFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    SliderFrame.Size = UDim2.new(1, -10, 0, 50)
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 6)
    SliderCorner.Parent = SliderFrame
    
    local SliderGlow = Instance.new("UIStroke")
    SliderGlow.Parent = SliderFrame
    SliderGlow.Color = glowColor
    SliderGlow.Thickness = 1.5
    SliderGlow.Transparency = 0.3
    
    local Label = Instance.new("TextLabel")
    Label.Parent = SliderFrame
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 15, 0, 5)
    Label.Size = UDim2.new(1, -30, 0, 20)
    Label.Font = Enum.Font.GothamSemibold
    Label.Text = name .. ": " .. tostring(default)
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    MakeTextNeonWhite(Label)
    
    local Track = Instance.new("Frame")
    Track.Parent = SliderFrame
    Track.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    Track.Position = UDim2.new(0, 15, 0, 30)
    Track.Size = UDim2.new(1, -30, 0, 10)
    Track.BorderSizePixel = 0
    
    local TrackCorner = Instance.new("UICorner")
    TrackCorner.CornerRadius = UDim.new(1, 0)
    TrackCorner.Parent = Track
    
    local TrackGlow = Instance.new("UIStroke")
    TrackGlow.Parent = Track
    TrackGlow.Color = glowColor
    TrackGlow.Thickness = 1
    TrackGlow.Transparency = 0.4
    
    local Fill = Instance.new("Frame")
    Fill.Parent = Track
    Fill.BackgroundColor3 = glowColor
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BorderSizePixel = 0
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = Fill
    
    local dragging = false
    
    local function updateSlider(input)
        local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        Fill.Size = UDim2.new(pos, 0, 1, 0)
        local value = math.floor(min + ((max - min) * pos))
        Label.Text = name .. ": " .. tostring(value)
        callback(value)
    end
    
    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateSlider(input)
        end
    end)
    
    userInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    userInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
end

-- ==========================================
-- TABS & CHEATS SETUP
-- ==========================================
local CombatTab = CreateTab("Combat")
local MovementTab = CreateTab("Movement")
local MiscTab = CreateTab("Misc / Visuals")

-- COMBAT SCRIPTS
CreateToggle(CombatTab, "Aimbot (Hold RMB)", Color3.fromRGB(255, 50, 50), function(state)
    isAimbotting = state
end)

CreateToggle(CombatTab, "ESP (Red Box)", Color3.fromRGB(255, 0, 0), function(state)
    espEnabled = state
end)

CreateToggle(CombatTab, "God Mode", Color3.fromRGB(255, 215, 0), function(state)
    godModeEnabled = state
    if state and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.MaxHealth = math.huge
        player.Character.Humanoid.Health = math.huge
    end
end)

CreateToggle(CombatTab, "Hitbox Expander", Color3.fromRGB(200, 50, 255), function(state)
    hitboxEnabled = state
end)

CreateSlider(CombatTab, "Hitbox Size", 2, 50, 10, Color3.fromRGB(200, 50, 255), function(val)
    hitboxSize = val
end)


-- MOVEMENT SCRIPTS
CreateToggle(MovementTab, "Flight Mode", Color3.fromRGB(255, 0, 128), function(state)
    if state then
        local char = player.Character or player.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        local hum = char:WaitForChild("Humanoid")
        flying = true
        bg = Instance.new("BodyGyro", hrp)
        bg.P = 9e4
        bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
        bg.cframe = hrp.CFrame
        bv = Instance.new("BodyVelocity", hrp)
        bv.velocity = Vector3.new(0, 0.1, 0)
        bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
        hum.PlatformStand = true
    else
        flying = false
        if bg then bg:Destroy() end
        if bv then bv:Destroy() end
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.PlatformStand = false
        end
    end
end)

CreateToggle(MovementTab, "Infinite Jump", Color3.fromRGB(0, 255, 128), function(state)
    infJump = state
end)

CreateToggle(MovementTab, "Noclip", Color3.fromRGB(128, 0, 255), function(state)
    noclip = state
end)

CreateSlider(MovementTab, "WalkSpeed", 16, 300, 16, Color3.fromRGB(255, 255, 0), function(val)
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = val
    end
end)

CreateSlider(MovementTab, "JumpPower", 50, 300, 50, Color3.fromRGB(0, 128, 255), function(val)
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.UseJumpPower = true
        player.Character.Humanoid.JumpPower = val
    end
end)

CreateSlider(MovementTab, "Flight Speed", 10, 500, 50, Color3.fromRGB(255, 128, 0), function(val)
    speed = val
end)


-- MISC / VISUALS SCRIPTS
CreateToggle(MiscTab, "Fullbright", Color3.fromRGB(255, 255, 255), function(state)
    isFullbright = state
    if state then
        origAmbient = lighting.Ambient
        origOutdoorAmbient = lighting.OutdoorAmbient
        origBrightness = lighting.Brightness
        origClockTime = lighting.ClockTime
        lighting.Ambient = Color3.new(1, 1, 1)
        lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        lighting.Brightness = 2
        lighting.ClockTime = 12
    else
        lighting.Ambient = origAmbient
        lighting.OutdoorAmbient = origOutdoorAmbient
        lighting.Brightness = origBrightness
        lighting.ClockTime = origClockTime
    end
end)

CreateToggle(MiscTab, "Spinbot", Color3.fromRGB(0, 255, 255), function(state)
    spinbotEnabled = state
end)

CreateSlider(MiscTab, "Spin Speed", 10, 150, 25, Color3.fromRGB(0, 255, 255), function(val)
    spinSpeed = val
end)

CreateSlider(MiscTab, "Field of View (FOV)", 70, 120, 70, Color3.fromRGB(0, 255, 100), function(val)
    Camera.FieldOfView = val
end)

-- ==========================================
-- RUNSERVICE LOOPS AND INPUT BINDINGS
-- ==========================================

runService.RenderStepped:Connect(function()
    -- AIMBOT
    if isAimbotting and userInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local closestDist = math.huge
        local target = nil
        for _, plyr in pairs(Players:GetPlayers()) do
            if plyr ~= player and plyr.Character and plyr.Character:FindFirstChild("Head") and plyr.Character.Humanoid.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(plyr.Character.Head.Position)
                if onScreen then
                    local dist = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        target = plyr
                    end
                end
            end
        end
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end
    
    -- ESP
    for _, plyr in pairs(Players:GetPlayers()) do
        if plyr ~= player then
            if espEnabled and plyr.Character and plyr.Character:FindFirstChild("Humanoid") and plyr.Character.Humanoid.Health > 0 then
                if not espHighlights[plyr] then
                    local hl = Instance.new("Highlight")
                    hl.Name = "ESP"
                    hl.FillTransparency = 1
                    hl.OutlineColor = Color3.fromRGB(255, 0, 0)
                    hl.OutlineTransparency = 0
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Parent = plyr.Character
                    espHighlights[plyr] = hl
                elseif espHighlights[plyr].Parent ~= plyr.Character then
                    espHighlights[plyr].Parent = plyr.Character
                end
            else
                if espHighlights[plyr] then
                    espHighlights[plyr]:Destroy()
                    espHighlights[plyr] = nil
                end
            end
        end
    end

    -- GOD MODE
    if godModeEnabled and player.Character and player.Character:FindFirstChild("Humanoid") then
        local hum = player.Character.Humanoid
        if hum.Health < hum.MaxHealth then
            hum.MaxHealth = math.huge
            hum.Health = math.huge
        end
    end
    
    -- FULLBRIGHT
    if isFullbright then
        lighting.Ambient = Color3.new(1, 1, 1)
        lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    end
    
    -- SPINBOT
    if spinbotEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = player.Character.HumanoidRootPart
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(spinSpeed), 0)
    end
    
    -- FLIGHT MOVEMENT
    if flying and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.Humanoid.Health > 0 then
        if flyCtrl.l + flyCtrl.r ~= 0 or flyCtrl.f + flyCtrl.b ~= 0 then
            bv.velocity = ((Camera.CFrame.LookVector * (flyCtrl.f + flyCtrl.b)) + ((Camera.CFrame * CFrame.new(flyCtrl.l + flyCtrl.r, (flyCtrl.f + flyCtrl.b) * 0.2, 0).Position) - Camera.CFrame.Position)) * speed
            lastCtrl = {f = flyCtrl.f, b = flyCtrl.b, l = flyCtrl.l, r = flyCtrl.r}
        elseif (flyCtrl.l + flyCtrl.r) == 0 and (flyCtrl.f + flyCtrl.b) == 0 and speed ~= 0 then
            bv.velocity = Vector3.new(0, 0, 0)
        end
        bg.cframe = Camera.CFrame
    end
    
    -- HITBOX EXPANDER
    for _, plyr in pairs(Players:GetPlayers()) do
        if plyr ~= player and plyr.Character and plyr.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = plyr.Character.HumanoidRootPart
            if hitboxEnabled then
                hrp.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                hrp.Transparency = 0.5
                hrp.CanCollide = false
            else
                hrp.Size = Vector3.new(2, 2, 1) -- default R6 size, works fine for resetting most R15 as well
                hrp.Transparency = 1
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(plyr)
    if espHighlights[plyr] then
        espHighlights[plyr]:Destroy()
        espHighlights[plyr] = nil
    end
end)

-- INPUT BINDS
userInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.K then
            ScreenGui.Enabled = not ScreenGui.Enabled
        end
    end
end)

mouse.KeyDown:Connect(function(key)
    key = key:lower()
    if key == "w" then flyCtrl.f = 1
    elseif key == "s" then flyCtrl.b = -1
    elseif key == "a" then flyCtrl.l = -1
    elseif key == "d" then flyCtrl.r = 1
    end
end)

mouse.KeyUp:Connect(function(key)
    key = key:lower()
    if key == "w" then flyCtrl.f = 0
    elseif key == "s" then flyCtrl.b = 0
    elseif key == "a" then flyCtrl.l = 0
    elseif key == "d" then flyCtrl.r = 0
    end
end)

-- Infinite Jump Request
userInputService.JumpRequest:Connect(function()
    if infJump and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid:ChangeState("Jumping")
    end
end)

-- Noclip Physics
runService.Stepped:Connect(function()
    if noclip and player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)
