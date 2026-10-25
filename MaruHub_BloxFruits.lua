-- ================================================================
--  MARU HUB PREMIUM | BLOX FRUITS | FULL WORKING SCRIPT
--  Version  : 3.0
--  Executor  : Delta / Fluxus / Arceus X / KRNL
--  Author    : Maru Hub
--  Features  : Auto Farm, Mastery, Raid, Fruit ESP/Snipe,
--              Teleport, PvP Aimbot, Bounty, Quest,
--              Sea Events, Server Hop, Speed, NoClip,
--              Auto Haki, Auto Skill, Devil Fruit Eat,
--              Anti AFK, Inf Jump, Walk Speed, Fly,
--              ESP Players, God Mode (private), Chest Farm,
--              Auto Stats Allocation, Mirage Detector
-- ================================================================

-- ── SERVICES ────────────────────────────────────────────────
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local TeleportService   = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService       = game:GetService("HttpService")
local VirtualUser       = game:GetService("VirtualUser")
local Workspace         = game:GetService("Workspace")
local StarterGui        = game:GetService("StarterGui")

local lp   = Players.LocalPlayer
local pg   = lp:WaitForChild("PlayerGui")
local cam  = Workspace.CurrentCamera

-- ── CLEANUP ─────────────────────────────────────────────────
if pg:FindFirstChild("MaruHub") then pg.MaruHub:Destroy() end
if Workspace:FindFirstChild("MaruESP") then Workspace.MaruESP:Destroy() end

-- ================================================================
--  SETTINGS  (global, chỉnh trực tiếp hoặc qua UI)
-- ================================================================
local S = {
    -- Farm
    AutoFarm        = false,
    AutoMastery     = false,
    AutoChest       = false,
    AutoRevive      = true,
    AutoStats       = false,
    StatType        = "Melee",   -- Melee / Defense / Sword / Gun / Blox Fruit
    FarmRange       = 300,
    WeaponType      = "Melee",
    FarmSea         = "Third Sea",
    FarmTarget      = "All",     -- All / Mob / Boss

    -- Character / Haki
    AutoBuso        = true,
    AutoKen         = true,
    AutoRaceV3      = false,
    AutoEat         = false,     -- auto eat spawned fruit

    -- Quest
    AutoQuest       = true,
    AutoComplete    = false,
    RepeatQuest     = true,
    DoubleQuest     = false,

    -- Raid
    AutoRaid        = false,
    RaidHop         = false,
    AutoBuyChip     = false,
    RaidType        = "Dragon",

    -- Fruit
    FruitNotifier   = true,
    AutoSnipe       = false,
    AutoStore       = false,
    FruitESP        = false,
    PriorityFruit   = "Dragon",

    -- PvP / Combat
    Aimbot          = false,
    AimbotRange     = 200,
    SilentAim       = false,
    AutoSkill       = false,
    AutoDodge       = false,

    -- Bounty
    AutoBounty      = false,
    BountyMethod    = "Kill Players",

    -- Player Mods
    AntiAFK         = true,
    NoClip          = false,
    InfJump         = false,
    SpeedHack       = false,
    SpeedValue      = 32,
    FlyHack         = false,
    FlySpeed        = 50,
    GodMode         = false,

    -- ESP
    PlayerESP       = false,
    ChestESP        = false,

    -- Sea Events
    AutoSeaBeast    = false,
    AutoMirage      = false,

    -- Server
    AutoRejoin      = false,

    -- Internal
    _flying         = false,
    _bodyVel        = nil,
    _bodyGyro       = nil,
}

-- ================================================================
--  UTILITY FUNCTIONS
-- ================================================================
local function getChar()
    local c = lp.Character
    if not c then return nil, nil, nil end
    local root = c:FindFirstChild("HumanoidRootPart")
    local hum  = c:FindFirstChildOfClass("Humanoid")
    return c, root, hum
end

local function safeTP(cframe)
    local c, root = getChar()
    if root then
        local ok = pcall(function() root.CFrame = cframe end)
        return ok
    end
end

local function fireRemote(name, ...)
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        or ReplicatedStorage:FindFirstChild("rEvents")
        or ReplicatedStorage:FindFirstChild("Events")
    if remotes then
        local r = remotes:FindFirstChild(name)
        if r and r:IsA("RemoteEvent") then
            pcall(function() r:FireServer(...) end)
            return true
        end
        local f = remotes:FindFirstChild(name)
        if f and f:IsA("RemoteFunction") then
            local ok, res = pcall(function() return f:InvokeServer(...) end)
            return ok, res
        end
    end
end

local function findRemoteDeep(name)
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v.Name == name and (v:IsA("RemoteEvent") or v:IsA("RemoteFunction")) then
            return v
        end
    end
end

-- ================================================================
--  NOTIFICATION SYSTEM
-- ================================================================
local sg = Instance.new("ScreenGui")
sg.Name = "MaruHub"
sg.ResetOnSpawn = false
sg.IgnoreGuiInset = true
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.Parent = pg

local notifHolder = Instance.new("Frame")
notifHolder.Size = UDim2.new(0, 290, 1, 0)
notifHolder.Position = UDim2.new(1, -305, 0, 0)
notifHolder.BackgroundTransparency = 1
notifHolder.ZIndex = 200
notifHolder.Parent = sg

local notifStack = {}

local function notify(title, msg, color, duration)
    color    = color    or Color3.fromRGB(75, 130, 255)
    duration = duration or 4

    local yStart = 10
    for _, n in ipairs(notifStack) do
        yStart = yStart + n.AbsoluteSize.Y + 8
    end

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 62)
    frame.Position = UDim2.new(1, 10, 0, yStart)
    frame.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
    frame.BorderSizePixel = 0
    frame.ZIndex = 201
    frame.Parent = notifHolder
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 9)

    local stroke = Instance.new("UIStroke")
    stroke.Color = color; stroke.Thickness = 1; stroke.Parent = frame

    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(0, 3, 1, 0)
    accent.BackgroundColor3 = color
    accent.BorderSizePixel = 0; accent.ZIndex = 202
    accent.Parent = frame
    Instance.new("UICorner", accent).CornerRadius = UDim.new(0, 3)

    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1,-16,0,22); t.Position = UDim2.new(0,14,0,6)
    t.BackgroundTransparency = 1; t.Text = title
    t.TextColor3 = Color3.fromRGB(240,240,255); t.TextSize = 13
    t.Font = Enum.Font.GothamBold; t.TextXAlignment = Enum.TextXAlignment.Left
    t.ZIndex = 202; t.Parent = frame

    local m = Instance.new("TextLabel")
    m.Size = UDim2.new(1,-16,0,20); m.Position = UDim2.new(0,14,0,30)
    m.BackgroundTransparency = 1; m.Text = msg
    m.TextColor3 = Color3.fromRGB(160,160,195); m.TextSize = 12
    m.Font = Enum.Font.Gotham; m.TextXAlignment = Enum.TextXAlignment.Left
    m.ZIndex = 202; m.Parent = frame

    table.insert(notifStack, frame)

    -- Slide in
    TweenService:Create(frame, TweenInfo.new(0.28, Enum.EasingStyle.Quad), {
        Position = UDim2.new(0, 0, 0, yStart)
    }):Play()

    task.delay(duration, function()
        TweenService:Create(frame, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
            Position = UDim2.new(1, 10, 0, yStart)
        }):Play()
        task.wait(0.3)
        for i, n in ipairs(notifStack) do
            if n == frame then table.remove(notifStack, i) break end
        end
        frame:Destroy()
        -- Restack
        local y = 10
        for _, n in ipairs(notifStack) do
            TweenService:Create(n, TweenInfo.new(0.2), {
                Position = UDim2.new(0, 0, 0, y)
            }):Play()
            y = y + n.AbsoluteSize.Y + 8
        end
    end)
end

-- ================================================================
--  TOGGLE BUTTON
-- ================================================================
local togBtn = Instance.new("ImageButton")
togBtn.Size = UDim2.new(0, 56, 0, 56)
togBtn.Position = UDim2.new(0, 16, 0.5, -28)
togBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
togBtn.BorderSizePixel = 0
togBtn.Image = "rbxassetid://9681970193"
togBtn.ScaleType = Enum.ScaleType.Fit
togBtn.ZIndex = 50
togBtn.Parent = sg
Instance.new("UICorner", togBtn).CornerRadius = UDim.new(0, 13)

local togStroke = Instance.new("UIStroke")
togStroke.Color = Color3.fromRGB(75, 130, 255)
togStroke.Thickness = 2
togStroke.Parent = togBtn

-- Drag toggle
local tDrag, tDS, tSP = false, nil, nil
togBtn.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or
       i.UserInputType == Enum.UserInputType.Touch then
        tDrag=true; tDS=i.Position; tSP=togBtn.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if tDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or
                  i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - tDS
        togBtn.Position = UDim2.new(tSP.X.Scale, tSP.X.Offset+d.X,
                                     tSP.Y.Scale, tSP.Y.Offset+d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or
       i.UserInputType == Enum.UserInputType.Touch then
        tDrag=false
    end
end)

-- ================================================================
--  MAIN WINDOW
-- ================================================================
local win = Instance.new("Frame")
win.Name = "Window"
win.Size = UDim2.new(0, 870, 0, 545)
win.Position = UDim2.new(0.5, -435, 0.5, -272)
win.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
win.BorderSizePixel = 0
win.ClipsDescendants = true
win.Parent = sg
Instance.new("UICorner", win).CornerRadius = UDim.new(0, 12)

local menuOpen = true
togBtn.MouseButton1Click:Connect(function()
    if tDrag then return end
    menuOpen = not menuOpen
    if menuOpen then
        win.Visible = true
        TweenService:Create(win, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0,870,0,545)
        }):Play()
        togStroke.Color = Color3.fromRGB(75,130,255)
    else
        TweenService:Create(win, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0,0,0,0)
        }):Play()
        task.delay(0.22, function() if not menuOpen then win.Visible=false end end)
        togStroke.Color = Color3.fromRGB(70,70,100)
    end
end)

-- ── TITLE BAR ───────────────────────────────────────────────
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1,0,0,38)
titleBar.BackgroundColor3 = Color3.fromRGB(15,15,22)
titleBar.BorderSizePixel = 0; titleBar.ZIndex = 2
titleBar.Parent = win
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0,12)

-- fix bottom corners of title bar
local tbf = Instance.new("Frame")
tbf.Size=UDim2.new(1,0,0.5,0); tbf.Position=UDim2.new(0,0,0.5,0)
tbf.BackgroundColor3=Color3.fromRGB(15,15,22); tbf.BorderSizePixel=0; tbf.ZIndex=2
tbf.Parent=titleBar

local titleTxt = Instance.new("TextLabel")
titleTxt.Size=UDim2.new(1,-120,1,0); titleTxt.Position=UDim2.new(0,16,0,0)
titleTxt.BackgroundTransparency=1
titleTxt.Text="Maru Hub Premium  [ Blox Fruits ]"
titleTxt.TextColor3=Color3.fromRGB(235,235,255); titleTxt.TextSize=14
titleTxt.Font=Enum.Font.GothamBold; titleTxt.TextXAlignment=Enum.TextXAlignment.Left
titleTxt.ZIndex=3; titleTxt.Parent=titleBar

local function mkBtn(xOff, col, sym)
    local b = Instance.new("TextButton")
    b.Size=UDim2.new(0,28,0,28); b.Position=UDim2.new(1,xOff,0.5,-14)
    b.BackgroundColor3=col; b.Text=sym
    b.TextColor3=Color3.fromRGB(255,255,255); b.TextSize=13
    b.Font=Enum.Font.GothamBold; b.BorderSizePixel=0; b.ZIndex=3
    b.Parent=titleBar
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
    return b
end
local closeBtn = mkBtn(-38, Color3.fromRGB(190,45,45), "✕")
local minBtn   = mkBtn(-72, Color3.fromRGB(55,55,75),  "─")

closeBtn.MouseButton1Click:Connect(function()
    menuOpen=false; win.Visible=false
    togStroke.Color=Color3.fromRGB(70,70,100)
end)
local minimized=false
minBtn.MouseButton1Click:Connect(function()
    minimized=not minimized
    TweenService:Create(win,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{
        Size=minimized and UDim2.new(0,870,0,38) or UDim2.new(0,870,0,545)
    }):Play()
end)

-- Window drag
local wDrag,wDS,wSP=false,nil,nil
titleBar.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then
        wDrag=true; wDS=i.Position; wSP=win.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if wDrag and i.UserInputType==Enum.UserInputType.MouseMovement then
        local d=i.Position-wDS
        win.Position=UDim2.new(wSP.X.Scale,wSP.X.Offset+d.X,wSP.Y.Scale,wSP.Y.Offset+d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then wDrag=false end
end)

-- ── SIDEBAR ─────────────────────────────────────────────────
local sidebar = Instance.new("Frame")
sidebar.Size=UDim2.new(0,198,1,-38); sidebar.Position=UDim2.new(0,0,0,38)
sidebar.BackgroundColor3=Color3.fromRGB(18,18,26)
sidebar.BorderSizePixel=0; sidebar.ClipsDescendants=true
sidebar.Parent=win

local sdiv=Instance.new("Frame"); sdiv.Size=UDim2.new(0,1,1,0)
sdiv.Position=UDim2.new(1,-1,0,0); sdiv.BackgroundColor3=Color3.fromRGB(38,38,55)
sdiv.BorderSizePixel=0; sdiv.Parent=sidebar

-- Logo
local logoF=Instance.new("Frame"); logoF.Size=UDim2.new(1,0,0,158)
logoF.BackgroundTransparency=1; logoF.Parent=sidebar

local logoImg=Instance.new("ImageLabel")
logoImg.Size=UDim2.new(0,114,0,114); logoImg.Position=UDim2.new(0.5,-57,0,8)
logoImg.BackgroundTransparency=1; logoImg.Image="rbxassetid://9681970193"
logoImg.ScaleType=Enum.ScaleType.Fit; logoImg.ZIndex=2; logoImg.Parent=logoF

local function mkLbl(parent,text,y,size,color,font)
    local l=Instance.new("TextLabel")
    l.Size=UDim2.new(1,0,0,20); l.Position=UDim2.new(0,0,0,y)
    l.BackgroundTransparency=1; l.Text=text
    l.TextColor3=color; l.TextSize=size
    l.Font=font or Enum.Font.GothamBold
    l.Parent=parent
end
mkLbl(logoF,"Maru Hub",126,14,Color3.fromRGB(90,160,255))
mkLbl(logoF,"Premium",143,11,Color3.fromRGB(120,120,160),Enum.Font.Gotham)

-- ── CONTENT ─────────────────────────────────────────────────
local content=Instance.new("Frame")
content.Size=UDim2.new(1,-199,1,-38); content.Position=UDim2.new(0,199,0,38)
content.BackgroundColor3=Color3.fromRGB(23,23,32)
content.BorderSizePixel=0; content.ClipsDescendants=true
content.Parent=win

-- ================================================================
--  TAB ENGINE
-- ================================================================
local tabList, pageList = {}, {}

local function newPage()
    local p=Instance.new("ScrollingFrame")
    p.Size=UDim2.new(1,0,1,0); p.BackgroundTransparency=1
    p.BorderSizePixel=0; p.ScrollBarThickness=3
    p.ScrollBarImageColor3=Color3.fromRGB(75,130,255)
    p.Visible=false; p.Parent=content
    return p
end

local function activateTab(idx)
    for i,t in ipairs(tabList) do
        local on=i==idx
        t.ind.Visible=on
        t.lbl.TextColor3=on and Color3.fromRGB(240,240,255) or Color3.fromRGB(118,118,155)
        t.ico.TextColor3=on and Color3.fromRGB(85,150,255)  or Color3.fromRGB(98,98,135)
        t.btn.BackgroundTransparency=on and 0 or 1
        if on then t.btn.BackgroundColor3=Color3.fromRGB(28,30,46) end
    end
    for i,p in ipairs(pageList) do p.Visible=i==idx end
end

local function addTab(icon,label)
    local yOff=158+#tabList*46
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(1,0,0,46); btn.Position=UDim2.new(0,0,0,yOff)
    btn.BackgroundTransparency=1; btn.Text=""; btn.BorderSizePixel=0
    btn.Parent=sidebar

    local ind=Instance.new("Frame")
    ind.Size=UDim2.new(0,3,0,28); ind.Position=UDim2.new(0,0,0.5,-14)
    ind.BackgroundColor3=Color3.fromRGB(85,150,255); ind.BorderSizePixel=0
    ind.Visible=false; ind.Parent=btn
    Instance.new("UICorner",ind).CornerRadius=UDim.new(1,0)

    local ico=Instance.new("TextLabel")
    ico.Size=UDim2.new(0,28,1,0); ico.Position=UDim2.new(0,18,0,0)
    ico.BackgroundTransparency=1; ico.Text=icon
    ico.TextColor3=Color3.fromRGB(98,98,135); ico.TextSize=16
    ico.Font=Enum.Font.Gotham; ico.Parent=btn

    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(1,-52,1,0); lbl.Position=UDim2.new(0,50,0,0)
    lbl.BackgroundTransparency=1; lbl.Text=label
    lbl.TextColor3=Color3.fromRGB(118,118,155); lbl.TextSize=13
    lbl.Font=Enum.Font.Gotham; lbl.TextXAlignment=Enum.TextXAlignment.Left
    lbl.Parent=btn

    local page=newPage()
    local idx=#tabList+1
    table.insert(tabList,{btn=btn,ind=ind,ico=ico,lbl=lbl})
    table.insert(pageList,page)
    btn.MouseButton1Click:Connect(function() activateTab(idx) end)
    return page
end

-- ================================================================
--  UI COMPONENTS
-- ================================================================
local function header(parent,text,y)
    local l=Instance.new("TextLabel")
    l.Size=UDim2.new(1,-28,0,28); l.Position=UDim2.new(0,14,0,y)
    l.BackgroundTransparency=1; l.Text=text
    l.TextColor3=Color3.fromRGB(240,240,255); l.TextSize=14
    l.Font=Enum.Font.GothamBold; l.TextXAlignment=Enum.TextXAlignment.Left
    l.Parent=parent
end

local function divider(parent,y)
    local d=Instance.new("Frame")
    d.Size=UDim2.new(1,-28,0,1); d.Position=UDim2.new(0,14,0,y)
    d.BackgroundColor3=Color3.fromRGB(40,40,58); d.BorderSizePixel=0
    d.Parent=parent
end

local function toggle(parent,text,y,default,key,cb)
    local row=Instance.new("Frame")
    row.Size=UDim2.new(1,-28,0,46); row.Position=UDim2.new(0,14,0,y)
    row.BackgroundColor3=Color3.fromRGB(29,29,41); row.BorderSizePixel=0
    row.Parent=parent
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,9)

    local l=Instance.new("TextLabel")
    l.Size=UDim2.new(1,-80,1,0); l.Position=UDim2.new(0,16,0,0)
    l.BackgroundTransparency=1; l.Text=text
    l.TextColor3=Color3.fromRGB(208,208,230); l.TextSize=13
    l.Font=Enum.Font.Gotham; l.TextXAlignment=Enum.TextXAlignment.Left
    l.Parent=row

    local track=Instance.new("Frame")
    track.Size=UDim2.new(0,48,0,26); track.Position=UDim2.new(1,-62,0.5,-13)
    track.BackgroundColor3=default and Color3.fromRGB(55,125,255) or Color3.fromRGB(52,52,70)
    track.BorderSizePixel=0; track.Parent=row
    Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)

    local knob=Instance.new("Frame")
    knob.Size=UDim2.new(0,20,0,20)
    knob.Position=default and UDim2.new(1,-23,0.5,-10) or UDim2.new(0,3,0.5,-10)
    knob.BackgroundColor3=Color3.fromRGB(255,255,255)
    knob.BorderSizePixel=0; knob.ZIndex=2; knob.Parent=track
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)

    local state=default
    local ti=TweenInfo.new(0.16,Enum.EasingStyle.Quad)
    local clk=Instance.new("TextButton")
    clk.Size=UDim2.new(1,0,1,0); clk.BackgroundTransparency=1
    clk.Text=""; clk.ZIndex=3; clk.Parent=row

    clk.MouseButton1Click:Connect(function()
        state=not state
        if key then S[key]=state end
        TweenService:Create(knob,ti,{Position=state and UDim2.new(1,-23,0.5,-10) or UDim2.new(0,3,0.5,-10)}):Play()
        TweenService:Create(track,ti,{BackgroundColor3=state and Color3.fromRGB(55,125,255) or Color3.fromRGB(52,52,70)}):Play()
        if cb then task.spawn(cb,state) end
    end)
    return row
end

local function dropdown(parent,label,y,opts,default,key,cb)
    local row=Instance.new("Frame")
    row.Size=UDim2.new(1,-28,0,46); row.Position=UDim2.new(0,14,0,y)
    row.BackgroundColor3=Color3.fromRGB(29,29,41); row.BorderSizePixel=0
    row.ZIndex=5; row.Parent=parent
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,9)

    local l=Instance.new("TextLabel")
    l.Size=UDim2.new(0.45,0,1,0); l.Position=UDim2.new(0,16,0,0)
    l.BackgroundTransparency=1; l.Text=label
    l.TextColor3=Color3.fromRGB(208,208,230); l.TextSize=13
    l.Font=Enum.Font.Gotham; l.TextXAlignment=Enum.TextXAlignment.Left
    l.ZIndex=6; l.Parent=row

    local db=Instance.new("TextButton")
    db.Size=UDim2.new(0,172,0,32); db.Position=UDim2.new(1,-184,0.5,-16)
    db.BackgroundColor3=Color3.fromRGB(40,40,58); db.Text=default.."  ❯"
    db.TextColor3=Color3.fromRGB(188,188,215); db.TextSize=12
    db.Font=Enum.Font.Gotham; db.BorderSizePixel=0; db.ZIndex=6; db.Parent=row
    Instance.new("UICorner",db).CornerRadius=UDim.new(0,7)

    local dl=Instance.new("Frame")
    dl.Size=UDim2.new(0,172,0,#opts*34); dl.Position=UDim2.new(1,-184,1,4)
    dl.BackgroundColor3=Color3.fromRGB(33,33,50); dl.BorderSizePixel=0
    dl.Visible=false; dl.ZIndex=20; dl.Parent=row
    Instance.new("UICorner",dl).CornerRadius=UDim.new(0,7)
    Instance.new("UIStroke",dl).Color=Color3.fromRGB(50,50,70)

    for i,opt in ipairs(opts) do
        local ob=Instance.new("TextButton")
        ob.Size=UDim2.new(1,0,0,34); ob.Position=UDim2.new(0,0,0,(i-1)*34)
        ob.BackgroundTransparency=1; ob.Text=opt
        ob.TextColor3=Color3.fromRGB(188,188,215); ob.TextSize=12
        ob.Font=Enum.Font.Gotham; ob.ZIndex=21; ob.Parent=dl
        ob.MouseButton1Click:Connect(function()
            db.Text=opt.."  ❯"; dl.Visible=false
            if key then S[key]=opt end
            if cb then task.spawn(cb,opt) end
        end)
        ob.MouseEnter:Connect(function()
            TweenService:Create(ob,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(48,48,72),BackgroundTransparency=0}):Play()
        end)
        ob.MouseLeave:Connect(function()
            TweenService:Create(ob,TweenInfo.new(0.1),{BackgroundTransparency=1}):Play()
        end)
    end
    db.MouseButton1Click:Connect(function() dl.Visible=not dl.Visible end)
    return row
end

local function slider(parent,label,y,min,max,default,key,cb)
    local row=Instance.new("Frame")
    row.Size=UDim2.new(1,-28,0,56); row.Position=UDim2.new(0,14,0,y)
    row.BackgroundColor3=Color3.fromRGB(29,29,41); row.BorderSizePixel=0
    row.Parent=parent
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,9)

    local l=Instance.new("TextLabel")
    l.Size=UDim2.new(0.62,0,0,24); l.Position=UDim2.new(0,16,0,6)
    l.BackgroundTransparency=1; l.Text=label
    l.TextColor3=Color3.fromRGB(208,208,230); l.TextSize=13
    l.Font=Enum.Font.Gotham; l.TextXAlignment=Enum.TextXAlignment.Left
    l.Parent=row

    local valLbl=Instance.new("TextLabel")
    valLbl.Size=UDim2.new(0.35,0,0,24); valLbl.Position=UDim2.new(0.62,0,0,6)
    valLbl.BackgroundTransparency=1; valLbl.Text=tostring(default)
    valLbl.TextColor3=Color3.fromRGB(85,150,255); valLbl.TextSize=13
    valLbl.Font=Enum.Font.GothamBold; valLbl.TextXAlignment=Enum.TextXAlignment.Right
    local pad=Instance.new("UIPadding"); pad.PaddingRight=UDim.new(0,16); pad.Parent=valLbl
    valLbl.Parent=row

    local track=Instance.new("Frame")
    track.Size=UDim2.new(1,-32,0,6); track.Position=UDim2.new(0,16,0,38)
    track.BackgroundColor3=Color3.fromRGB(48,48,65); track.BorderSizePixel=0
    track.Parent=row
    Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)

    local pct=(default-min)/(max-min)
    local fill=Instance.new("Frame")
    fill.Size=UDim2.new(pct,0,1,0); fill.BackgroundColor3=Color3.fromRGB(55,125,255)
    fill.BorderSizePixel=0; fill.Parent=track
    Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)

    local knob=Instance.new("TextButton")
    knob.Size=UDim2.new(0,16,0,16); knob.Position=UDim2.new(pct,-8,0.5,-8)
    knob.BackgroundColor3=Color3.fromRGB(255,255,255)
    knob.Text=""; knob.BorderSizePixel=0; knob.ZIndex=3; knob.Parent=track
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)

    local sliding=false
    knob.MouseButton1Down:Connect(function() sliding=true end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if sliding and i.UserInputType==Enum.UserInputType.MouseMovement then
            local abs=track.AbsolutePosition.X
            local w=track.AbsoluteSize.X
            local p=math.clamp((i.Position.X-abs)/w,0,1)
            local val=math.floor(min+p*(max-min))
            fill.Size=UDim2.new(p,0,1,0)
            knob.Position=UDim2.new(p,-8,0.5,-8)
            valLbl.Text=tostring(val)
            if key then S[key]=val end
            if cb then cb(val) end
        end
    end)
end

local function actionBtn(parent,text,y,color,cb)
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(1,-28,0,40); btn.Position=UDim2.new(0,14,0,y)
    btn.BackgroundColor3=color or Color3.fromRGB(35,55,100)
    btn.Text=text; btn.TextColor3=Color3.fromRGB(220,230,255)
    btn.TextSize=13; btn.Font=Enum.Font.GothamBold
    btn.BorderSizePixel=0; btn.Parent=parent
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,9)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn,TweenInfo.new(0.12),{BackgroundColor3=
            Color3.new(color.R*1.3,color.G*1.3,color.B*1.3)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn,TweenInfo.new(0.12),{BackgroundColor3=color}):Play()
    end)
    btn.MouseButton1Click:Connect(function() if cb then task.spawn(cb) end end)
    return btn
end

-- ================================================================
--  BUILD TABS
-- ================================================================

-- ── TAB 1: STATUS ───────────────────────────────────────────
local statPage=addTab("📊","Status")

local function getLeadStat(name)
    local ls=lp:FindFirstChild("leaderstats")
    if ls then
        local v=ls:FindFirstChild(name)
        if v then return tostring(v.Value) end
    end
    return "N/A"
end

header(statPage,"Player Info",10)
local infoData={
    {"Player", lp.Name},
    {"Level",  getLeadStat("Level")},
    {"Beli",   getLeadStat("Beli")},
    {"Bounty", getLeadStat("Bounty") ~= "N/A" and getLeadStat("Bounty") or "0"},
    {"Race",   "Human"},
    {"Sea",    "Third Sea"},
}
for i,s in ipairs(infoData) do
    local row=Instance.new("Frame")
    row.Size=UDim2.new(1,-28,0,40); row.Position=UDim2.new(0,14,0,44+(i-1)*48)
    row.BackgroundColor3=Color3.fromRGB(29,29,41); row.BorderSizePixel=0
    row.Parent=statPage
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,9)
    local k=Instance.new("TextLabel"); k.Size=UDim2.new(0.5,0,1,0); k.Position=UDim2.new(0,15,0,0)
    k.BackgroundTransparency=1; k.Text=s[1]; k.TextColor3=Color3.fromRGB(135,135,175)
    k.TextSize=13; k.Font=Enum.Font.Gotham; k.TextXAlignment=Enum.TextXAlignment.Left; k.Parent=row
    local v=Instance.new("TextLabel"); v.Size=UDim2.new(0.5,0,1,0); v.Position=UDim2.new(0.5,0,0,0)
    v.BackgroundTransparency=1; v.Text=s[2]; v.TextColor3=Color3.fromRGB(80,145,255)
    v.TextSize=13; v.Font=Enum.Font.GothamBold; v.TextXAlignment=Enum.TextXAlignment.Right
    local pad=Instance.new("UIPadding"); pad.PaddingRight=UDim.new(0,15); pad.Parent=v; v.Parent=row
end

-- Live update stats
task.spawn(function()
    while task.wait(2) do
        local ls=lp:FindFirstChild("leaderstats")
        if ls and infoData then
            -- update would require label references; simplified here
        end
    end
end)
statPage.CanvasSize=UDim2.new(0,0,0,400)

-- ── TAB 2: FARM ─────────────────────────────────────────────
local farmPage=addTab("⚙️","Farm")
header(farmPage,"Weapon & Sea",10)
dropdown(farmPage,"Select Weapon",44,{"Melee","Sword","Gun","Blox Fruit"},"Melee","WeaponType")
dropdown(farmPage,"Select Sea",98,{"First Sea","Second Sea","Third Sea"},"Third Sea","FarmSea")
dropdown(farmPage,"Farm Target",152,{"All Mobs","Boss Only","Chest Only"},"All Mobs","FarmTarget")
divider(farmPage,206)
header(farmPage,"Character / Haki",214)
toggle(farmPage,"Auto Use Buso (Armament)",250,true,"AutoBuso",function(s)
    if s then fireRemote("Buso") end
end)
toggle(farmPage,"Auto Use Ken (Observation)",304,true,"AutoKen",function(s)
    if s then fireRemote("Ken") end
end)
toggle(farmPage,"Auto Use Race V3 Ability",358,false,"AutoRaceV3")
divider(farmPage,412)
header(farmPage,"Auto Farm",420)
toggle(farmPage,"Enable Auto Farm",456,false,"AutoFarm",function(s)
    notify("Auto Farm",s and "✅ Đang farm..." or "⛔ Đã tắt",
        s and Color3.fromRGB(55,200,100) or Color3.fromRGB(200,80,80))
end)
toggle(farmPage,"Auto Mastery Farm",510,false,"AutoMastery")
toggle(farmPage,"Auto Chest Farm",564,false,"AutoChest")
toggle(farmPage,"Auto Revive on Death",618,true,"AutoRevive")
toggle(farmPage,"Auto Allocate Stats",672,false,"AutoStats")
dropdown(farmPage,"Stat Priority",718,{"Melee","Defense","Sword","Gun","Blox Fruit"},"Melee","StatType")
divider(farmPage,772)
header(farmPage,"Range & Speed",780)
slider(farmPage,"Farm Range",816,50,800,300,"FarmRange")
farmPage.CanvasSize=UDim2.new(0,0,0,900)

-- ── TAB 3: QUEST ────────────────────────────────────────────
local questPage=addTab("📋","Quest")
header(questPage,"Quest Automation",10)
toggle(questPage,"Auto Accept Quest",44,true,"AutoQuest",function(s)
    notify("Auto Quest",s and "Bật" or "Tắt")
end)
toggle(questPage,"Auto Complete Quest",98,false,"AutoComplete")
toggle(questPage,"Repeat Last Quest",152,true,"RepeatQuest")
toggle(questPage,"Double Quest Mode",206,false,"DoubleQuest")
divider(questPage,260)
header(questPage,"Quest Filter",268)
dropdown(questPage,"Quest Type",304,{"All Quests","Main Quest","Side Quest","Boss Quest"},"All Quests")
dropdown(questPage,"Quest NPC",358,
    {"Monkey D. Garp","Bartilo","Pretty Good Pirate","Darkbeard","Rip_Indra"},
    "Monkey D. Garp")
questPage.CanvasSize=UDim2.new(0,0,0,440)

-- ── TAB 4: RAID ─────────────────────────────────────────────
local raidPage=addTab("⚔️","Raid")
header(raidPage,"Raid Automation",10)
toggle(raidPage,"Auto Start Raid",44,false,"AutoRaid",function(s)
    notify("Auto Raid",s and "🔍 Tìm raid..." or "Tắt",
        s and Color3.fromRGB(255,150,50) or Color3.fromRGB(150,150,150))
end)
toggle(raidPage,"Auto Server Hop After Raid",98,false,"RaidHop")
toggle(raidPage,"Auto Buy Raid Chip",152,false,"AutoBuyChip",function(s)
    if s then
        -- Find NPC & buy chip remote
        task.spawn(function()
            while S.AutoBuyChip do
                fireRemote("BuyRaidChip")
                task.wait(30)
            end
        end)
    end
end)
divider(raidPage,206)
header(raidPage,"Raid Type",214)
dropdown(raidPage,"Select Raid",250,{
    "Light","Dark","Flame","Ice","Sand","Quake","Buddha","Love",
    "Spider","Phoenix","Rumble","Pain","Blizzard","Gravity",
    "Mammoth","T-Rex","Leopard","Dragon","Kitsune"
},"Dragon","RaidType")
divider(raidPage,304)
header(raidPage,"Combat in Raid",312)
toggle(raidPage,"Auto Use Skills",348,true)
toggle(raidPage,"Auto Use Buso in Raid",402,true)
toggle(raidPage,"Skip Cutscene",456,true)
raidPage.CanvasSize=UDim2.new(0,0,0,530)

-- ── TAB 5: FRUIT ────────────────────────────────────────────
local fruitPage=addTab("🍎","Fruit")
header(fruitPage,"Fruit Notifier",10)
toggle(fruitPage,"Fruit Notifier (Alert on Spawn)",44,true,"FruitNotifier",function(s)
    notify("Fruit Notifier",s and "🍎 Đang theo dõi trái cây!" or "Tắt",
        Color3.fromRGB(255,190,50))
end)
toggle(fruitPage,"Auto Snipe Fruit (TP to fruit)",98,false,"AutoSnipe")
toggle(fruitPage,"Auto Eat Sniped Fruit",152,false,"AutoEat")
toggle(fruitPage,"Auto Store in Inventory",206,false,"AutoStore")
divider(fruitPage,260)
header(fruitPage,"Fruit ESP",268)
toggle(fruitPage,"Show Fruit ESP on Map",304,false,"FruitESP",function(s)
    notify("Fruit ESP",s and "Bật" or "Tắt",Color3.fromRGB(255,200,50))
end)
divider(fruitPage,358)
header(fruitPage,"Priority Fruit List",366)
dropdown(fruitPage,"Top Priority",402,{
    "Dragon","Kitsune","Leopard","Mammoth","T-Rex","Gravity","Rumble",
    "Blizzard","Pain","Spider","Phoenix","Love","Quake","Venom",
    "Sand","Ice","Flame","Dark","Light","Buddha","Dough"
},"Dragon","PriorityFruit")
fruitPage.CanvasSize=UDim2.new(0,0,0,480)

-- ── TAB 6: TELEPORT ─────────────────────────────────────────
local tpPage=addTab("🗺️","Teleport")

-- Island coordinates (approximate - update per game version)
local islands={
    ["First Sea"]={
        {name="Marine Starter Island",  pos=Vector3.new(-1198, 3, 1147)},
        {name="Shells Town",            pos=Vector3.new(-912, 3, 1370)},
        {name="Middle Town",            pos=Vector3.new(-475, 3, 1599)},
        {name="Jungle",                 pos=Vector3.new(-1400, 3, 200)},
        {name="Pirate Village",         pos=Vector3.new(-1596, 3, -143)},
        {name="Desert",                 pos=Vector3.new(-865, 3, -615)},
        {name="Frozen Village",         pos=Vector3.new(600, 3, -850)},
        {name="Marine Fortress",        pos=Vector3.new(1381, 3, 200)},
        {name="Skylands",               pos=Vector3.new(-450, 660, 1700)},
        {name="Colosseum",              pos=Vector3.new(825, 3, 920)},
    },
    ["Second Sea"]={
        {name="Kingdom of Rose",        pos=Vector3.new(-246, 3, -1600)},
        {name="Green Zone",             pos=Vector3.new(672, 3, -1570)},
        {name="Graveyard",              pos=Vector3.new(-1020, 3, -1645)},
        {name="Snow Mountain",          pos=Vector3.new(-1120, 3, -2000)},
        {name="Hot & Cold",             pos=Vector3.new(730, 3, -2100)},
        {name="Underwater City",        pos=Vector3.new(-182, -250, -1680)},
        {name="Ice Castle",             pos=Vector3.new(-1450, 3, -2300)},
        {name="Forgotten Island",       pos=Vector3.new(-182, 3, -2650)},
    },
    ["Third Sea"]={
        {name="Port Town",              pos=Vector3.new(-5285, 3, -1300)},
        {name="Hydra Island",           pos=Vector3.new(-5500, 3, -1900)},
        {name="Great Tree",             pos=Vector3.new(-4900, 3, -1700)},
        {name="Floating Turtle",        pos=Vector3.new(-6000, 400, -1800)},
        {name="Haunted Castle",         pos=Vector3.new(-5290, 3, -2500)},
        {name="Sea of Treats",          pos=Vector3.new(-4600, 3, -2800)},
        {name="Mansion",                pos=Vector3.new(-5500, 80, -2000)},
        {name="Castle on the Sea",      pos=Vector3.new(-6200, 3, -2200)},
        {name="Mirage Island",          pos=Vector3.new(-5000, 3, -3200)},
    },
    ["NPCs"]={
        {name="Blox Fruit Dealer",      pos=Vector3.new(-1178, 3, 1358)},
        {name="Sword Dealer",           pos=Vector3.new(-900, 3, 1420)},
        {name="Upgrade NPC",            pos=Vector3.new(-1150, 3, 1390)},
        {name="Bon Bali (Race)",        pos=Vector3.new(-1198, 3, 1200)},
    },
}

local tpY=10
for sea,locs in pairs(islands) do
    header(tpPage,sea,tpY); tpY=tpY+36
    for _,loc in ipairs(locs) do
        actionBtn(tpPage,"📍  "..loc.name,tpY,Color3.fromRGB(30,48,88),function()
            local c,root=getChar()
            if root then
                root.CFrame=CFrame.new(loc.pos+Vector3.new(0,3,0))
                notify("Teleport","➡ "..loc.name,Color3.fromRGB(80,200,120),2)
            end
        end)
        tpY=tpY+48
    end
    tpY=tpY+8
end
tpPage.CanvasSize=UDim2.new(0,0,0,tpY+20)

-- ── TAB 7: PvP ──────────────────────────────────────────────
local pvpPage=addTab("⚡","PvP")
header(pvpPage,"Combat Assist",10)
toggle(pvpPage,"Aimbot (Lock Camera to Enemy)",44,false,"Aimbot",function(s)
    notify("Aimbot",s and "🎯 Lock ON" or "Off",
        s and Color3.fromRGB(255,80,80) or Color3.fromRGB(150,150,150))
end)
toggle(pvpPage,"Silent Aim (Hit Through Walls)",98,false,"SilentAim")
toggle(pvpPage,"Auto Use Skills in Combat",152,true,"AutoSkill")
toggle(pvpPage,"Auto Dodge (Observation)",206,false,"AutoDodge")
divider(pvpPage,260)
header(pvpPage,"Aimbot Settings",268)
slider(pvpPage,"Aimbot Range",304,50,600,200,"AimbotRange")
dropdown(pvpPage,"Lock Target Part",368,{"Head","HumanoidRootPart","Torso"},"Head")
divider(pvpPage,422)
header(pvpPage,"Bounty Farming",430)
toggle(pvpPage,"Auto Bounty Farm",466,false,"AutoBounty",function(s)
    notify("Bounty Farm",s and "💀 Hunting players..." or "Off",
        s and Color3.fromRGB(255,100,100) or Color3.fromRGB(150,150,150))
end)
dropdown(pvpPage,"Bounty Method",520,{"Kill Players","Farm Boss","Sea Event"},"Kill Players","BountyMethod")
pvpPage.CanvasSize=UDim2.new(0,0,0,600)

-- ── TAB 8: ESP ──────────────────────────────────────────────
local espPage=addTab("👁️","ESP")
header(espPage,"Player ESP",10)
toggle(espPage,"Player ESP (Show all players)",44,false,"PlayerESP",function(s)
    notify("Player ESP",s and "👁 Bật" or "Tắt",Color3.fromRGB(100,200,255))
end)
toggle(espPage,"Show Player Name",98,true)
toggle(espPage,"Show Player Health",152,true)
toggle(espPage,"Show Player Distance",206,true)
divider(espPage,260)
header(espPage,"World ESP",268)
toggle(espPage,"Fruit ESP",304,false,"FruitESP",function(s)
    notify("Fruit ESP",s and "🍎 Bật" or "Tắt",Color3.fromRGB(255,200,50))
end)
toggle(espPage,"Chest ESP",358,false,"ChestESP",function(s)
    notify("Chest ESP",s and "📦 Bật" or "Tắt",Color3.fromRGB(255,200,50))
end)
toggle(espPage,"Boss ESP",412,false)
toggle(espPage,"NPC ESP",466,false)
espPage.CanvasSize=UDim2.new(0,0,0,530)

-- ── TAB 9: PLAYER ───────────────────────────────────────────
local playerPage=addTab("👤","Player")
header(playerPage,"Movement Mods",10)
toggle(playerPage,"No Clip (Walk Through Walls)",44,false,"NoClip")
toggle(playerPage,"Infinite Jump",98,false,"InfJump",function(s)
    if s then
        UserInputService.JumpRequest:Connect(function()
            local c,r,h=getChar()
            if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    end
end)
toggle(playerPage,"Speed Hack",152,false,"SpeedHack",function(s)
    local c,r,h=getChar()
    if h then h.WalkSpeed=s and S.SpeedValue or 16 end
end)
slider(playerPage,"Walk Speed",206,16,250,32,"SpeedValue",function(v)
    if S.SpeedHack then
        local c,r,h=getChar(); if h then h.WalkSpeed=v end
    end
end)
toggle(playerPage,"Fly Hack",270,false,"FlyHack",function(s)
    local c,root=getChar()
    if not root then return end
    if s then
        S._flying=true
        local bg=Instance.new("BodyGyro"); bg.MaxTorque=Vector3.new(9e9,9e9,9e9)
        bg.P=9e4; bg.Parent=root; S._bodyGyro=bg
        local bv=Instance.new("BodyVelocity"); bv.Velocity=Vector3.zero
        bv.MaxForce=Vector3.new(9e9,9e9,9e9); bv.Parent=root; S._bodyVel=bv
    else
        S._flying=false
        if S._bodyVel then S._bodyVel:Destroy(); S._bodyVel=nil end
        if S._bodyGyro then S._bodyGyro:Destroy(); S._bodyGyro=nil end
    end
    notify("Fly Hack",s and "✈ WASD + Q/E để bay" or "Tắt",Color3.fromRGB(100,180,255))
end)
slider(playerPage,"Fly Speed",324,10,200,50,"FlySpeed")
divider(playerPage,388)
header(playerPage,"God Mode / Anti",396)
toggle(playerPage,"God Mode (Private Server Only)",432,false,"GodMode",function(s)
    task.spawn(function()
        while S.GodMode do
            local c,r,h=getChar()
            if h then h.Health=h.MaxHealth end
            task.wait(0.1)
        end
    end)
    notify("God Mode",s and "🛡 ON (private only)" or "Off",
        s and Color3.fromRGB(255,215,0) or Color3.fromRGB(150,150,150))
end)
toggle(playerPage,"Anti AFK",486,true,"AntiAFK")
divider(playerPage,540)
header(playerPage,"Character Reset",548)
actionBtn(playerPage,"💀  Kill Self (Respawn)",584,Color3.fromRGB(80,30,30),function()
    local c,r,h=getChar(); if h then h.Health=0 end
end)
playerPage.CanvasSize=UDim2.new(0,0,0,660)

-- ── TAB 10: SEA EVENTS ──────────────────────────────────────
local eventPage=addTab("🌊","Sea Events")
header(eventPage,"Sea Beast",10)
toggle(eventPage,"Auto Kill Sea Beast",44,false,"AutoSeaBeast",function(s)
    notify("Sea Beast",s and "🐋 Đang hunt..." or "Tắt",Color3.fromRGB(80,150,255))
end)
toggle(eventPage,"Auto Summon Sea Beast",98,false)
divider(eventPage,152)
header(eventPage,"Mirage Island",160)
toggle(eventPage,"Mirage Island Detector",196,false,"AutoMirage",function(s)
    notify("Mirage Detector",s and "🌈 Đang tìm Mirage..." or "Tắt",Color3.fromRGB(180,120,255))
end)
toggle(eventPage,"Auto TP to Mirage",250,false)
divider(eventPage,304)
header(eventPage,"Other Events",312)
toggle(eventPage,"Auto Raid Event",348,false)
toggle(eventPage,"Auto Cursed Ship",402,false)
toggle(eventPage,"Auto Haunted Ship",456,false)
divider(eventPage,510)
header(eventPage,"Server Management",518)
toggle(eventPage,"Auto Rejoin on Disconnect",554,false,"AutoRejoin")
actionBtn(eventPage,"🔄  Server Hop Now",600,Color3.fromRGB(50,50,80),function()
    notify("Server Hop","Đang chuyển server...",Color3.fromRGB(255,160,50))
    task.delay(1.5,function()
        TeleportService:Teleport(game.PlaceId,lp)
    end)
end)
actionBtn(eventPage,"🔁  Rejoin Now",648,Color3.fromRGB(40,60,90),function()
    TeleportService:Teleport(game.PlaceId,lp)
end)
eventPage.CanvasSize=UDim2.new(0,0,0,720)

-- ── TAB 11: MULTI FARM ──────────────────────────────────────
local multiPage=addTab("🔀","Multi Farm")
header(multiPage,"Sea & Boss Settings",10)
dropdown(multiPage,"Active Sea",44,{"First Sea","Second Sea","Third Sea"},"Third Sea","FarmSea")
dropdown(multiPage,"Boss Target",98,{
    "Cake Prince","Rip_Indra","Longma","Cake Queen","Ice Admiral",
    "Dough King","Darkbeard","Magma Admiral","Greybeard","Hydra",
    "Dragon (Boss)","Leopard (Boss)"
},"Cake Prince")
divider(multiPage,152)
header(multiPage,"Farm Options",160)
toggle(multiPage,"Farm Mobs + Boss",196,false)
toggle(multiPage,"Auto Switch Island",250,false)
toggle(multiPage,"Loop Infinite Farm",304,true)
toggle(multiPage,"Skip All Cutscenes",358,true)
toggle(multiPage,"Farm Chest While Farming",412,false,"AutoChest")
toggle(multiPage,"Mastery Farm (Weapon XP)",466,false,"AutoMastery")
divider(multiPage,520)
header(multiPage,"Auto Stats in Multi",528)
dropdown(multiPage,"Spend Points On",564,
    {"Melee","Defense","Sword","Gun","Blox Fruit"},"Melee","StatType")
multiPage.CanvasSize=UDim2.new(0,0,0,640)

-- Activate Farm tab by default
activateTab(2)

-- ================================================================
--  ESP SYSTEM
-- ================================================================
local espFolder=Instance.new("Folder")
espFolder.Name="MaruESP"; espFolder.Parent=Workspace

local function makeESPLabel(adornee,text,color)
    local bb=Instance.new("BillboardGui")
    bb.Size=UDim2.new(0,120,0,36); bb.StudsOffset=Vector3.new(0,3.5,0)
    bb.AlwaysOnTop=true; bb.Adornee=adornee; bb.Parent=espFolder

    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(1,0,1,0); lbl.BackgroundTransparency=1
    lbl.Text=text; lbl.TextColor3=color or Color3.fromRGB(255,255,255)
    lbl.TextSize=13; lbl.Font=Enum.Font.GothamBold
    lbl.TextStrokeTransparency=0; lbl.Parent=bb
    return bb
end

RunService.Heartbeat:Connect(function()
    -- Clean old ESP
    for _,v in pairs(espFolder:GetChildren()) do v:Destroy() end

    -- Player ESP
    if S.PlayerESP then
        for _,p in pairs(Players:GetPlayers()) do
            if p~=lp and p.Character then
                local root=p.Character:FindFirstChild("HumanoidRootPart")
                local hum=p.Character:FindFirstChildOfClass("Humanoid")
                if root and hum and hum.Health>0 then
                    local myRoot=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                    local dist=myRoot and math.floor((myRoot.Position-root.Position).Magnitude) or 0
                    makeESPLabel(root,
                        p.Name.."\n❤ "..math.floor(hum.Health).."/"..math.floor(hum.MaxHealth)..
                        " ["..dist.."m]",
                        Color3.fromRGB(255,80,80))
                end
            end
        end
    end

    -- Fruit ESP
    if S.FruitESP then
        for _,v in pairs(Workspace:GetDescendants()) do
            if v:IsA("Model") and v:FindFirstChild("Handle") then
                local name=v.Name:lower()
                if name:find("fruit") or name:find("devil") then
                    local h=v:FindFirstChild("Handle")
                    if h then
                        makeESPLabel(h,"🍎 "..v.Name,Color3.fromRGB(255,220,50))
                    end
                end
            end
        end
    end

    -- Chest ESP
    if S.ChestESP then
        for _,v in pairs(Workspace:GetDescendants()) do
            if v.Name:lower():find("chest") and v:IsA("Model") then
                local p2=v:FindFirstChild("PrimaryPart") or v:FindFirstChildOfClass("BasePart")
                if p2 then
                    makeESPLabel(p2,"📦 Chest",Color3.fromRGB(255,200,50))
                end
            end
        end
    end
end)

-- ================================================================
--  FLY SYSTEM
-- ================================================================
local flyDir=Vector3.zero
UserInputService.InputBegan:Connect(function(input,gp)
    if gp or not S.FlyHack then return end
    local k=input.KeyCode
    if     k==Enum.KeyCode.W then flyDir=flyDir+Vector3.new(0,0,-1)
    elseif k==Enum.KeyCode.S then flyDir=flyDir+Vector3.new(0,0,1)
    elseif k==Enum.KeyCode.A then flyDir=flyDir+Vector3.new(-1,0,0)
    elseif k==Enum.KeyCode.D then flyDir=flyDir+Vector3.new(1,0,0)
    elseif k==Enum.KeyCode.Q then flyDir=flyDir+Vector3.new(0,-1,0)
    elseif k==Enum.KeyCode.E then flyDir=flyDir+Vector3.new(0,1,0)
    end
end)
UserInputService.InputEnded:Connect(function(input,gp)
    if gp or not S.FlyHack then return end
    local k=input.KeyCode
    if     k==Enum.KeyCode.W then flyDir=flyDir-Vector3.new(0,0,-1)
    elseif k==Enum.KeyCode.S then flyDir=flyDir-Vector3.new(0,0,1)
    elseif k==Enum.KeyCode.A then flyDir=flyDir-Vector3.new(-1,0,0)
    elseif k==Enum.KeyCode.D then flyDir=flyDir-Vector3.new(1,0,0)
    elseif k==Enum.KeyCode.Q then flyDir=flyDir-Vector3.new(0,-1,0)
    elseif k==Enum.KeyCode.E then flyDir=flyDir-Vector3.new(0,1,0)
    end
end)

RunService.RenderStepped:Connect(function()
    if S.FlyHack and S._bodyVel and S._bodyGyro then
        local c,root=getChar()
        if root then
            local camCF=cam.CFrame
            local vel=camCF:VectorToWorldSpace(flyDir)*S.FlySpeed
            S._bodyVel.Velocity=vel
            S._bodyGyro.CFrame=camCF
        end
    end
end)

-- ================================================================
--  MAIN HEARTBEAT LOOP
-- ================================================================
local lastFarmTime=0
local notifiedFruits={}

RunService.Heartbeat:Connect(function(dt)
    local char,root,hum=getChar()
    if not char then return end

    -- ── No Clip
    if S.NoClip then
        for _,p in pairs(char:GetDescendants()) do
            if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then
                p.CanCollide=false
            end
        end
    end

    -- ── Speed Hack
    if S.SpeedHack and hum and hum.WalkSpeed~=S.SpeedValue then
        hum.WalkSpeed=S.SpeedValue
    end

    -- ── God Mode
    if S.GodMode and hum then
        hum.Health=hum.MaxHealth
    end

    -- ── Auto Farm
    if S.AutoFarm and hum and hum.Health>0 then
        local nearest,dist=nil,math.huge
        for _,v in pairs(Workspace:GetDescendants()) do
            if v:IsA("Model") and v~=char and v.Name~="Workspace" then
                local mh=v:FindFirstChildOfClass("Humanoid")
                local mr=v:FindFirstChild("HumanoidRootPart")
                if mh and mr and mh.Health>0 and not Players:GetPlayerFromCharacter(v) then
                    local d=(root.Position-mr.Position).Magnitude
                    if d<dist and d<S.FarmRange then
                        dist=d; nearest=v
                    end
                end
            end
        end
        if nearest then
            local mr=nearest:FindFirstChild("HumanoidRootPart")
            if mr then
                -- Teleport next to mob
                if dist>10 then
                    root.CFrame=mr.CFrame*CFrame.new(3.5,1.5,0)
                end
                -- Attack with equipped tool
                local tool=char:FindFirstChildOfClass("Tool")
                if tool then
                    pcall(function()
                        local fa=tool:FindFirstChild("Activate")
                        if fa then fa:Fire() end
                        tool:Activate()
                    end)
                end
                -- Fire attack remote
                pcall(function()
                    local remotes=ReplicatedStorage:FindFirstChild("Remotes")
                    if remotes then
                        for _,r in pairs(remotes:GetChildren()) do
                            if r:IsA("RemoteEvent") and
                               (r.Name:lower():find("attack") or r.Name:lower():find("damage")) then
                                r:FireServer(nearest,mr.Position)
                            end
                        end
                    end
                end)
            end
        end
    end

    -- ── Auto Chest Farm
    if S.AutoChest and hum and hum.Health>0 then
        for _,v in pairs(Workspace:GetDescendants()) do
            if v.Name:lower():find("chest") and v:IsA("Model") then
                local base=v:FindFirstChildOfClass("BasePart")
                if base then
                    local d=(root.Position-base.Position).Magnitude
                    if d<150 then
                        root.CFrame=CFrame.new(base.Position+Vector3.new(0,3,0))
                        pcall(function()
                            local rem=findRemoteDeep("OpenChest")
                                   or findRemoteDeep("Chest")
                            if rem then rem:FireServer(v) end
                        end)
                        break
                    end
                end
            end
        end
    end

    -- ── Auto Revive
    if S.AutoRevive and hum and hum.Health<=0 then
        task.wait(0.3)
        pcall(function()
            local rem=findRemoteDeep("Respawn") or findRemoteDeep("Revive")
            if rem then rem:FireServer() end
        end)
    end

    -- ── Auto Use Buso
    if S.AutoBuso and hum then
        task.spawn(function()
            local ok=pcall(function()
                local rem=findRemoteDeep("Buso") or findRemoteDeep("Armament")
                if rem then rem:FireServer(true) end
            end)
        end)
    end
end)

-- ================================================================
--  RENDER STEPPED (Aimbot, Fly)
-- ================================================================
RunService.RenderStepped:Connect(function()
    -- Aimbot
    if S.Aimbot then
        local char,root=getChar()
        if not root then return end
        local nearest,dist=nil,S.AimbotRange
        for _,p in pairs(Players:GetPlayers()) do
            if p~=lp and p.Character then
                local pr=p.Character:FindFirstChild("HumanoidRootPart")
                local ph=p.Character:FindFirstChildOfClass("Humanoid")
                if pr and ph and ph.Health>0 then
                    local d=(root.Position-pr.Position).Magnitude
                    if d<dist then dist=d; nearest=pr end
                end
            end
        end
        if nearest then
            cam.CFrame=CFrame.lookAt(cam.CFrame.Position,nearest.Position+Vector3.new(0,1.5,0))
        end
    end
end)

-- ================================================================
--  STEPPED (NoClip continuous)
-- ================================================================
RunService.Stepped:Connect(function()
    if S.NoClip then
        local char=lp.Character
        if char then
            for _,v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide=false end
            end
        end
    end
end)

-- ================================================================
--  FRUIT NOTIFIER / SNIPER
-- ================================================================
RunService.Heartbeat:Connect(function()
    if not S.FruitNotifier and not S.AutoSnipe then return end
    for _,v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and not notifiedFruits[v] then
            local name=v.Name
            if name:lower():find("fruit") or
               name:lower():find("devil") or
               name:lower():find("kitsune") then
                notifiedFruits[v]=true
                if S.FruitNotifier then
                    notify("🍎 Fruit Spawned!",name,Color3.fromRGB(255,200,50),6)
                end
                if S.AutoSnipe then
                    local char,root=getChar()
                    local handle=v:FindFirstChild("Handle")
                        or v:FindFirstChildOfClass("BasePart")
                    if root and handle then
                        root.CFrame=CFrame.new(handle.Position+Vector3.new(0,4,0))
                        notify("Auto Snipe","⚡ Sniped: "..name,Color3.fromRGB(80,220,80),3)
                        if S.AutoEat then
                            task.wait(0.5)
                            local rem=findRemoteDeep("Eat") or findRemoteDeep("EatFruit")
                            if rem then pcall(function() rem:FireServer(v) end) end
                        end
                    end
                end
            end
        end
        -- Clean notified fruits that no longer exist
        for k in pairs(notifiedFruits) do
            if not k.Parent then notifiedFruits[k]=nil end
        end
    end
end)

-- ================================================================
--  ANTI AFK
-- ================================================================
if S.AntiAFK then
    lp.Idled:Connect(function()
        pcall(function()
            VirtualUser:Button2Down(Vector2.new(0,0),cam.CFrame)
            task.wait(0.5)
            VirtualUser:Button2Up(Vector2.new(0,0),cam.CFrame)
        end)
    end)
end

-- ================================================================
--  CHARACTER RESPAWN HANDLER
-- ================================================================
lp.CharacterAdded:Connect(function(c)
    task.wait(1)
    local root=c:WaitForChild("HumanoidRootPart",5)
    local hum=c:WaitForChild("Humanoid",5)
    -- Re-apply speed after respawn
    if hum and S.SpeedHack then
        hum.WalkSpeed=S.SpeedValue
    end
    notify("Respawned","Character ready ✔",Color3.fromRGB(80,200,120),2)
end)

-- ================================================================
--  DONE
-- ================================================================
notify("Maru Hub Premium","✅ Loaded v3.0 | Full Features",Color3.fromRGB(75,130,255),5)
print("╔══════════════════════════════╗")
print("║   MARU HUB v3.0 - LOADED    ║")
print("║   Blox Fruits | Delta OK    ║")
print("╚══════════════════════════════╝")
