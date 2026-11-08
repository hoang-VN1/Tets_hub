-- ============================================================
-- NINJA HUB — Blox Fruits Halloween Event Hub
-- File: Ninja_Hub.lua
-- Target: Roblox executor (Synapse X / KRNL / Delta / Fluxus)
-- Platform: Android primary, PC compatible
-- Author: NINJA HUB Project
-- ============================================================
-- PROBE NOTICE:
-- Sections marked [PROBE REQUIRED] contain placeholder values.
-- Run the EXPLORER UTILITIES section first (bottom of file),
-- read the output in executor console, then fill in the
-- Constants block before enabling any task.
-- ============================================================

local NinjaHub = {}

-- ============================================================
-- SERVICES
-- ============================================================
local Players         = game:GetService("Players")
local RunService      = game:GetService("RunService")
local TweenService    = game:GetService("TweenService")
local UserInputService= game:GetService("UserInputService")
local Workspace       = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")
local Character   = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid         = Character:WaitForChild("Humanoid")

-- ============================================================
-- CONSTANTS — [PROBE REQUIRED] slots marked with TODO
-- ============================================================
local C = {
    -- UI
    HUB_NAME        = "NINJA HUB",
    ACCENT_ORANGE   = Color3.fromRGB(255, 120, 0),
    ACCENT_PURPLE   = Color3.fromRGB(140, 60, 220),
    BG_BLACK        = Color3.fromRGB(12, 12, 12),
    BG_DARK         = Color3.fromRGB(20, 20, 20),
    TEXT_WHITE      = Color3.fromRGB(240, 240, 240),
    TEXT_DIM        = Color3.fromRGB(160, 160, 160),
    CORNER_RADIUS   = UDim.new(0, 20),

    -- Movement
    MOVE_TIMEOUT    = 8,      -- seconds before giving up on a walk
    HOUSE_COOLDOWN  = 30,     -- seconds before re-visiting a house
    INTERACT_RANGE  = 6,      -- studs from door to trigger interact

    -- Candy
    -- TODO: Verify attribute name on LocalPlayer or leaderstats
    -- Run explorer utility, look for "Candy", "Halloween_Candy", etc.
    CANDY_ATTRIBUTE = "Candy",          -- [PROBE REQUIRED]
    CANDY_LEADERSTATS_KEY = "Candy",    -- [PROBE REQUIRED]

    -- Trick or Treat: House/Door detection
    -- TODO: Inspect Workspace for house models during Halloween event
    -- Common patterns: model named "House", folder "HalloweenHouses",
    -- doors tagged with CollectionService tag "HalloweenDoor"
    HOUSE_FOLDER_PATH  = {"Workspace", "Map", "HalloweenHouses"}, -- [PROBE REQUIRED]
    DOOR_TAG           = "HalloweenDoor",   -- [PROBE REQUIRED] CollectionService tag
    DOOR_PART_NAME     = "Door",             -- [PROBE REQUIRED] part name inside house model
    DOOR_PROMPT_NAME   = "ProximityPrompt", -- usually standard

    -- Trick or Treat: Interaction remote
    -- TODO: Fire explorer utility to find RemoteEvents fired on door interact
    TRICK_REMOTE_PATH  = {"ReplicatedStorage", "Events", "TrickOrTreat"}, -- [PROBE REQUIRED]

    -- Boss detection
    -- TODO: Find boss model name that spawns at doors
    BOSS_MODEL_NAMES   = {"DoorBoss", "HalloweenBoss"}, -- [PROBE REQUIRED]
    BOSS_HEALTH_PATH   = {"Humanoid", "Health"},

    -- Mini game GUI
    -- TODO: Find the ScreenGui that appears for mini games
    MINIGAME_GUI_NAME  = "MiniGameGui",     -- [PROBE REQUIRED]
    CARD_FRAME_NAME    = "CardFrame",        -- [PROBE REQUIRED]
    DOOR_FRAME_NAME    = "DoorFrame",        -- [PROBE REQUIRED]

    -- Great Pumpkin
    -- TODO: Verify quest NPC name and remote
    GP_QUEST_NPC       = "GreatPumpkinNPC", -- [PROBE REQUIRED]
    GP_REMOTE_PATH     = {"ReplicatedStorage", "Events", "GreatPumpkin"}, -- [PROBE REQUIRED]
    GP_ITEM_NAME       = "PumpkinCorn",     -- [PROBE REQUIRED] required quest item

    -- Pumpkin Farm
    -- TODO: Find collectible pumpkin models in Workspace
    PUMPKIN_TAG        = "CollectiblePumpkin", -- [PROBE REQUIRED] CollectionService tag
    PUMPKIN_REMOTE_PATH= {"ReplicatedStorage", "Events", "CollectPumpkin"}, -- [PROBE REQUIRED]
}

-- ============================================================
-- STATE
-- ============================================================
local State = {
    running         = false,
    activeTask      = nil,       -- "trick" | "pumpkin" | "farm" | nil
    taskThreads     = {},        -- active coroutines keyed by task id
    connections     = {},        -- RBXScriptConnections to disconnect on stop

    -- Trick or Treat
    visitedHouses   = {},        -- [house model] = timestamp
    trickEnabled    = false,
    bossCheckEnabled= true,
    miniGameEnabled = true,

    -- Great Pumpkin
    gpEnabled       = false,

    -- Pumpkin Farm
    farmEnabled     = false,

    -- UI
    expanded        = false,
    statusText      = "Chờ lệnh",
    candyCount      = "--",
}

-- ============================================================
-- UTILITY
-- ============================================================
local U = {}

function U.getDescendantPath(root, path)
    local node = root
    for _, key in ipairs(path) do
        if node == nil then return nil end
        if key == "Workspace" then node = Workspace
        elseif key == "ReplicatedStorage" then node = game:GetService("ReplicatedStorage")
        elseif key == "Players" then node = Players
        else
            local found = node:FindFirstChild(key)
            if not found then return nil end
            node = found
        end
    end
    return node
end

function U.setStatus(text)
    State.statusText = text
    if NinjaHub.UI and NinjaHub.UI.statusLabel then
        NinjaHub.UI.statusLabel.Text = text
    end
end

function U.readCandy()
    -- Try leaderstats first
    local ls = LocalPlayer:FindFirstChild("leaderstats")
    if ls then
        local c = ls:FindFirstChild(C.CANDY_LEADERSTATS_KEY)
        if c then return tostring(c.Value) end
    end
    -- Try attribute
    local ok, val = pcall(function()
        return LocalPlayer:GetAttribute(C.CANDY_ATTRIBUTE)
    end)
    if ok and val ~= nil then return tostring(val) end
    return "--"
end

function U.updateCandyDisplay()
    State.candyCount = U.readCandy()
    if NinjaHub.UI and NinjaHub.UI.candyLabel then
        NinjaHub.UI.candyLabel.Text = "🍬 Candy: " .. State.candyCount
    end
end

function U.walkTo(position, timeout)
    timeout = timeout or C.MOVE_TIMEOUT
    Character = LocalPlayer.Character
    if not Character then return false end
    HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    Humanoid         = Character:FindFirstChild("Humanoid")
    if not HumanoidRootPart or not Humanoid then return false end

    Humanoid:MoveTo(position)
    local start = tick()
    local reached = false

    local conn
    conn = Humanoid.MoveToFinished:Connect(function(success)
        if conn then conn:Disconnect() end
        reached = success
    end)

    while not reached and (tick() - start) < timeout do
        task.wait(0.1)
    end
    if conn then pcall(function() conn:Disconnect() end) end
    return reached
end

function U.distanceTo(part)
    Character = LocalPlayer.Character
    if not Character then return math.huge end
    local root = Character:FindFirstChild("HumanoidRootPart")
    if not root then return math.huge end
    return (root.Position - part.Position).Magnitude
end

function U.fireRemote(pathTable, ...)
    local remote = U.getDescendantPath(game, pathTable)
    if remote and (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
        if remote:IsA("RemoteEvent") then
            remote:FireServer(...)
        else
            return remote:InvokeServer(...)
        end
        return true
    end
    return false
end

function U.triggerProximityPrompt(prompt)
    -- Attempt to trigger a ProximityPrompt via FireProximityPrompt if available
    if fireclickdetector then
        -- some executors expose this
    end
    -- Standard: use the internal trigger path
    local ok = pcall(function()
        local uis = game:GetService("VirtualInputManager") or UserInputService
        -- executor method if available
        if fireproximityprompt then
            fireproximityprompt(prompt)
        end
    end)
    return ok
end

function U.stopAllTasks()
    State.activeTask = nil
    State.trickEnabled = false
    State.gpEnabled    = false
    State.farmEnabled  = false

    for id, thread in pairs(State.taskThreads) do
        if coroutine.status(thread) ~= "dead" then
            -- signal stop; threads check State.activeTask == their id
        end
    end
    State.taskThreads = {}

    for _, conn in ipairs(State.connections) do
        pcall(function() conn:Disconnect() end)
    end
    State.connections = {}

    U.setStatus("Đã dừng")
    U.updateCandyDisplay()
end

-- ============================================================
-- TASK MANAGER — only one main task at a time
-- ============================================================
local TaskManager = {}

function TaskManager.startTask(id, fn)
    -- Stop existing main task
    if State.activeTask and State.activeTask ~= id then
        U.stopAllTasks()
    end
    State.activeTask = id
    local thread = coroutine.create(fn)
    State.taskThreads[id] = thread
    task.spawn(function()
        local ok, err = coroutine.resume(thread)
        if not ok then
            U.setStatus("Lỗi: " .. tostring(err))
        end
    end)
end

function TaskManager.isActive(id)
    return State.activeTask == id
end

-- ============================================================
-- MINI GAME HANDLER
-- ============================================================
local MiniGame = {}

function MiniGame.detect()
    -- Look for the mini game GUI appearing in PlayerGui
    local gui = PlayerGui:FindFirstChild(C.MINIGAME_GUI_NAME)
    return gui ~= nil
end

function MiniGame.getType(gui)
    if gui:FindFirstChild(C.CARD_FRAME_NAME, true) then
        return "card_match"
    elseif gui:FindFirstChild(C.DOOR_FRAME_NAME, true) then
        return "door_guess"
    end
    return "unknown"
end

-- Card matching: memory-based pair detection
function MiniGame.solveCardMatch(gui)
    U.setStatus("Đang ghép lá bài...")
    local cardFrame = gui:FindFirstChild(C.CARD_FRAME_NAME, true)
    if not cardFrame then
        U.setStatus("Không tìm thấy khung lá bài")
        return false
    end

    -- [PROBE REQUIRED]
    -- Cards are likely ImageLabels or Buttons inside cardFrame.
    -- Each card has a "face" value revealed on first click.
    -- Strategy: click all once to reveal, then match pairs.
    -- This stub records revealed values by card index.

    local cards = {}
    local revealed = {} -- [index] = value_string

    for i, child in ipairs(cardFrame:GetChildren()) do
        if child:IsA("GuiButton") or child:IsA("ImageLabel") then
            cards[i] = child
        end
    end

    if #cards == 0 then
        U.setStatus("Không tìm thấy lá bài")
        return false
    end

    -- Phase 1: reveal all
    for i, card in ipairs(cards) do
        -- Click card to reveal
        local ok = pcall(function()
            if card:IsA("GuiButton") then
                card.MouseButton1Click:Fire()
            end
        end)
        task.wait(0.4)
        -- Read revealed value — [PROBE REQUIRED]: adjust property name
        local val = card:GetAttribute("CardValue") or card.Name
        revealed[i] = val
    end

    -- Phase 2: find pairs and click them in sequence
    local paired = {}
    for i = 1, #revealed do
        if not paired[i] then
            for j = i + 1, #revealed do
                if not paired[j] and revealed[i] == revealed[j] then
                    paired[i] = true
                    paired[j] = true
                    -- Select pair
                    pcall(function() cards[i].MouseButton1Click:Fire() end)
                    task.wait(0.3)
                    pcall(function() cards[j].MouseButton1Click:Fire() end)
                    task.wait(0.6)
                    break
                end
            end
        end
    end

    U.setStatus("Hoàn thành ghép lá bài")
    return true
end

-- Door guess: watch NPC movement
function MiniGame.solveDoorGuess(gui)
    U.setStatus("Đang đoán cửa...")
    local doorFrame = gui:FindFirstChild(C.DOOR_FRAME_NAME, true)
    if not doorFrame then
        U.setStatus("Không tìm thấy khung cửa")
        return false
    end

    -- [PROBE REQUIRED]
    -- The game shows NPC entering a door. The correct door index
    -- is typically stored as an attribute or the NPC's target door button
    -- becomes highlighted. This stub watches for a "CorrectDoor" attribute
    -- or a highlighted button.

    local correctDoor = nil
    local deadline = tick() + 5

    while tick() < deadline and not correctDoor do
        for _, child in ipairs(doorFrame:GetChildren()) do
            if child:IsA("GuiButton") then
                -- Check for highlight or attribute
                local attr = child:GetAttribute("IsCorrect")
                    or child:GetAttribute("CorrectDoor")
                if attr then
                    correctDoor = child
                    break
                end
                -- Fallback: check BackgroundColor change
                if child.BackgroundColor3 ~= Color3.fromRGB(255,255,255)
                   and child.BackgroundColor3 ~= Color3.fromRGB(0,0,0) then
                    correctDoor = child
                    break
                end
            end
        end
        task.wait(0.1)
    end

    if correctDoor then
        pcall(function() correctDoor.MouseButton1Click:Fire() end)
        U.setStatus("Đã chọn cửa")
        return true
    else
        U.setStatus("Không nhận diện được cửa — bỏ qua mini game")
        return false
    end
end

function MiniGame.handle()
    if not State.miniGameEnabled then return false end
    local gui = PlayerGui:FindFirstChild(C.MINIGAME_GUI_NAME)
    if not gui then return false end

    local mgType = MiniGame.getType(gui)
    if mgType == "card_match" then
        return MiniGame.solveCardMatch(gui)
    elseif mgType == "door_guess" then
        return MiniGame.solveDoorGuess(gui)
    else
        U.setStatus("Mini game không xác định — bỏ qua")
        return false
    end
end

-- ============================================================
-- BOSS IN DOOR HANDLER
-- ============================================================
local BossHandler = {}

function BossHandler.detectAtDoor(doorPart)
    if not State.bossCheckEnabled then return false end
    -- Look for boss model near the door
    for _, bossName in ipairs(C.BOSS_MODEL_NAMES) do
        local boss = Workspace:FindFirstChild(bossName, true)
        if boss then
            local bossRoot = boss:FindFirstChild("HumanoidRootPart")
                or boss:FindFirstChildWhichIsA("Part")
            if bossRoot then
                local dist = (bossRoot.Position - doorPart.Position).Magnitude
                if dist < 20 then
                    return true, boss
                end
            end
        end
    end
    return false
end

function BossHandler.assist(boss)
    U.setStatus("Phát hiện boss trong cửa!")
    -- Move toward boss and auto-attack
    -- [PROBE REQUIRED]: Blox Fruits combat remotes vary by version.
    -- For now, move into range; actual attack remote needs verification.
    local root = boss:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local hp = boss:FindFirstChild("Humanoid")
    while hp and hp.Health > 0 and TaskManager.isActive("trick") do
        U.walkTo(root.Position + Vector3.new(0, 0, -4), 3)
        -- Placeholder: attempt nearest attack key
        -- Real implementation needs verified combat remote
        task.wait(0.5)
        if hp.Health <= 0 then break end
    end
    U.setStatus("Boss đã xử lý")
end

-- ============================================================
-- TASK: TRICK OR TREAT
-- ============================================================
local TrickOrTreat = {}

function TrickOrTreat.getHouses()
    -- Collect interactable house models
    local houses = {}

    -- Method A: CollectionService tag
    local ok, tagged = pcall(function()
        return game:GetService("CollectionService"):GetTagged(C.DOOR_TAG)
    end)
    if ok and #tagged > 0 then
        for _, obj in ipairs(tagged) do
            -- obj might be the door part itself or the house model
            local houseModel = obj:IsA("Model") and obj or obj:FindFirstAncestorOfClass("Model")
            if houseModel and not houses[houseModel] then
                houses[houseModel] = true
            end
        end
        local list = {}
        for model, _ in pairs(houses) do table.insert(list, model) end
        return list
    end

    -- Method B: Folder path
    local folder = U.getDescendantPath(game, C.HOUSE_FOLDER_PATH)
    if folder then
        for _, child in ipairs(folder:GetChildren()) do
            if child:IsA("Model") then
                table.insert(houses, child)
            end
        end
        return houses
    end

    return {}
end

function TrickOrTreat.getDoorPart(houseModel)
    -- Look for ProximityPrompt or a part named "Door"
    local door = houseModel:FindFirstChild(C.DOOR_PART_NAME, true)
    if door then return door end

    -- Fallback: any part with a ProximityPrompt
    for _, desc in ipairs(houseModel:GetDescendants()) do
        if desc:IsA("ProximityPrompt") then
            return desc.Parent
        end
    end
    return houseModel:FindFirstChildOfClass("Part")
end

function TrickOrTreat.pickNextHouse(houses)
    local now = tick()
    local best, bestDist = nil, 0  -- maximize distance (prefer far houses)
    Character = LocalPlayer.Character
    if not Character then return nil end
    local root = Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    for _, house in ipairs(houses) do
        local door = TrickOrTreat.getDoorPart(house)
        if door then
            local lastVisit = State.visitedHouses[house]
            if not lastVisit or (now - lastVisit) > C.HOUSE_COOLDOWN then
                local dist = (root.Position - door.Position).Magnitude
                if dist > bestDist then
                    bestDist = dist
                    best = house
                end
            end
        end
    end
    return best
end

function TrickOrTreat.interactDoor(doorPart)
    U.setStatus("Đang gõ cửa...")
    -- Try ProximityPrompt trigger
    local prompt = doorPart:FindFirstChildOfClass("ProximityPrompt")
        or doorPart:FindFirstChild(C.DOOR_PROMPT_NAME, true)

    if prompt then
        local triggered = U.triggerProximityPrompt(prompt)
        if triggered then
            task.wait(0.5)
            return true
        end
    end

    -- Fallback: fire the interaction remote
    local fired = U.fireRemote(C.TRICK_REMOTE_PATH)
    if fired then
        task.wait(0.5)
        return true
    end

    U.setStatus("Không thể tương tác cửa — [PROBE REQUIRED]")
    return false
end

function TrickOrTreat.run()
    U.setStatus("Bắt đầu Trick or Treat...")

    while TaskManager.isActive("trick") do
        Character = LocalPlayer.Character
        if not Character then task.wait(1) continue end
        Humanoid = Character:FindFirstChild("Humanoid")
        if Humanoid and Humanoid.Health <= 0 then
            U.setStatus("Nhân vật đã chết — đang chờ hồi sinh...")
            task.wait(3)
            continue
        end

        U.setStatus("Đang tìm nhà...")
        local houses = TrickOrTreat.getHouses()

        if #houses == 0 then
            U.setStatus("Không tìm thấy nhà — [PROBE REQUIRED] kiểm tra HOUSE_FOLDER_PATH")
            task.wait(5)
            continue
        end

        local house = TrickOrTreat.pickNextHouse(houses)
        if not house then
            U.setStatus("Tất cả nhà đã thăm — đang chờ cooldown...")
            task.wait(10)
            continue
        end

        local door = TrickOrTreat.getDoorPart(house)
        if not door then
            State.visitedHouses[house] = tick()
            continue
        end

        -- Move to door
        U.setStatus("Đang bay đến nhà...")
        local arrived = U.walkTo(door.Position + Vector3.new(0, 0, 3), C.MOVE_TIMEOUT)
        if not arrived then
            U.setStatus("Không thể đến nhà — thử nhà tiếp theo")
            State.visitedHouses[house] = tick() - C.HOUSE_COOLDOWN + 5
            continue
        end

        -- Boss check before knocking
        if State.bossCheckEnabled then
            U.setStatus("Đang kiểm tra boss...")
            local hasBoss, boss = BossHandler.detectAtDoor(door)
            if hasBoss then
                BossHandler.assist(boss)
                if not TaskManager.isActive("trick") then break end
            end
        end

        -- Knock
        local knocked = TrickOrTreat.interactDoor(door)
        State.visitedHouses[house] = tick()

        if knocked then
            task.wait(0.8)
            -- Mini game check
            if State.miniGameEnabled then
                local hasMG = MiniGame.detect()
                if hasMG then
                    U.setStatus("Đang xử lý mini game...")
                    MiniGame.handle()
                    task.wait(1)
                end
            end

            U.setStatus("Đang thu thập Candy...")
            task.wait(0.5)
            U.updateCandyDisplay()
        end

        task.wait(0.3)
    end

    U.setStatus("Trick or Treat đã dừng")
end

-- ============================================================
-- TASK: GREAT PUMPKIN
-- ============================================================
local GreatPumpkin = {}

function GreatPumpkin.run()
    U.setStatus("Bắt đầu Great Pumpkin...")

    -- [PROBE REQUIRED]: Verify quest mechanic before full implementation.
    -- Steps to verify in-game:
    -- 1. Find NPC name that starts Great Pumpkin quest
    -- 2. Confirm required items / quest conditions
    -- 3. Find the RemoteEvent fired when summoning / completing quest
    -- 4. Find boss spawn location / model name

    local npc = Workspace:FindFirstChild(C.GP_QUEST_NPC, true)
    if not npc then
        U.setStatus("Không tìm thấy NPC Great Pumpkin — [PROBE REQUIRED]")
        return
    end

    -- Check required item in inventory
    -- [PROBE REQUIRED]: adjust to real inventory check method
    local hasItem = false
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        hasItem = backpack:FindFirstChild(C.GP_ITEM_NAME) ~= nil
    end

    if not hasItem then
        U.setStatus("Thiếu vật phẩm: " .. C.GP_ITEM_NAME)
        return
    end

    U.setStatus("Đang làm nhiệm vụ Great Pumpkin...")

    while TaskManager.isActive("pumpkin") do
        -- Move to NPC, interact, handle boss
        local npcRoot = npc:FindFirstChild("HumanoidRootPart")
            or npc:FindFirstChildOfClass("Part")
        if npcRoot then
            U.walkTo(npcRoot.Position + Vector3.new(0, 0, -3), C.MOVE_TIMEOUT)
        end

        -- Fire quest remote
        U.fireRemote(C.GP_REMOTE_PATH)
        task.wait(2)

        -- [PROBE REQUIRED]: Detect when boss spawns and fight it
        -- For now, status update and wait
        U.setStatus("Chờ boss Great Pumpkin xuất hiện...")
        task.wait(5)

        if not TaskManager.isActive("pumpkin") then break end
    end

    U.setStatus("Great Pumpkin đã dừng")
end

-- ============================================================
-- TASK: PUMPKIN FARM
-- ============================================================
local PumpkinFarm = {}

function PumpkinFarm.getPumpkins()
    local pumpkins = {}

    -- Method A: CollectionService tag
    local ok, tagged = pcall(function()
        return game:GetService("CollectionService"):GetTagged(C.PUMPKIN_TAG)
    end)
    if ok then
        for _, p in ipairs(tagged) do
            if p:IsA("BasePart") or p:IsA("Model") then
                table.insert(pumpkins, p)
            end
        end
        return pumpkins
    end

    -- Method B: Search workspace for pumpkin-named parts
    for _, desc in ipairs(Workspace:GetDescendants()) do
        if desc.Name:lower():find("pumpkin") and desc:IsA("BasePart") then
            table.insert(pumpkins, desc)
        end
    end

    return pumpkins
end

function PumpkinFarm.collectPumpkin(pumpkin)
    local part = pumpkin:IsA("BasePart") and pumpkin
        or pumpkin:FindFirstChildOfClass("Part")
    if not part then return false end

    U.walkTo(part.Position, C.MOVE_TIMEOUT)
    task.wait(0.3)

    -- Try proximity prompt first
    local prompt = part:FindFirstChildOfClass("ProximityPrompt")
    if prompt then
        U.triggerProximityPrompt(prompt)
        task.wait(0.5)
        return true
    end

    -- Fire collection remote
    local fired = U.fireRemote(C.PUMPKIN_REMOTE_PATH, pumpkin)
    task.wait(0.5)
    return fired
end

function PumpkinFarm.run()
    U.setStatus("Bắt đầu Pumpkin Farm...")

    while TaskManager.isActive("farm") do
        Character = LocalPlayer.Character
        if not Character then task.wait(1) continue end
        Humanoid = Character:FindFirstChild("Humanoid")
        if Humanoid and Humanoid.Health <= 0 then
            U.setStatus("Nhân vật đã chết — chờ hồi sinh...")
            task.wait(3)
            continue
        end

        local pumpkins = PumpkinFarm.getPumpkins()
        if #pumpkins == 0 then
            U.setStatus("Không tìm thấy Pumpkin — [PROBE REQUIRED]")
            task.wait(5)
            continue
        end

        U.setStatus("Đang thu thập Pumpkin... (" .. #pumpkins .. " còn lại)")

        for _, pumpkin in ipairs(pumpkins) do
            if not TaskManager.isActive("farm") then break end
            PumpkinFarm.collectPumpkin(pumpkin)
            U.updateCandyDisplay()
        end

        task.wait(1)
    end

    U.setStatus("Pumpkin Farm đã dừng")
end

-- ============================================================
-- UI — DYNAMIC ISLAND
-- ============================================================
local UI = {}

function UI.build()
    -- Remove existing instance
    local existing = PlayerGui:FindFirstChild("NinjaHub_Island")
    if existing then existing:Destroy() end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NinjaHub_Island"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = PlayerGui

    -- ---- Collapsed pill ----
    local pill = Instance.new("Frame")
    pill.Name = "Pill"
    pill.Size = UDim2.new(0, 220, 0, 44)
    pill.Position = UDim2.new(0.5, -110, 0, 10)
    pill.BackgroundColor3 = C.BG_BLACK
    pill.BorderSizePixel = 0
    pill.ZIndex = 10
    pill.Parent = screenGui

    local pillCorner = Instance.new("UICorner")
    pillCorner.CornerRadius = C.CORNER_RADIUS
    pillCorner.Parent = pill

    local pillStroke = Instance.new("UIStroke")
    pillStroke.Color = C.ACCENT_ORANGE
    pillStroke.Thickness = 1.5
    pillStroke.Parent = pill

    -- Hub name label
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(0, 90, 1, 0)
    nameLabel.Position = UDim2.new(0, 8, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = C.HUB_NAME
    nameLabel.TextColor3 = C.ACCENT_ORANGE
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.ZIndex = 11
    nameLabel.Parent = pill

    -- Candy label (collapsed)
    local candyLabel = Instance.new("TextLabel")
    candyLabel.Name = "CandyLabel"
    candyLabel.Size = UDim2.new(0, 110, 1, 0)
    candyLabel.Position = UDim2.new(0, 95, 0, 0)
    candyLabel.BackgroundTransparency = 1
    candyLabel.Text = "🍬 --"
    candyLabel.TextColor3 = C.TEXT_WHITE
    candyLabel.TextScaled = true
    candyLabel.Font = Enum.Font.Gotham
    candyLabel.TextXAlignment = Enum.TextXAlignment.Left
    candyLabel.ZIndex = 11
    candyLabel.Parent = pill

    -- ---- Expanded panel ----
    local panel = Instance.new("Frame")
    panel.Name = "Panel"
    panel.Size = UDim2.new(0, 280, 0, 300)
    panel.Position = UDim2.new(0.5, -140, 0, 60)
    panel.BackgroundColor3 = C.BG_DARK
    panel.BorderSizePixel = 0
    panel.Visible = false
    panel.ZIndex = 9
    panel.Parent = screenGui

    local panelCorner = Instance.new("UICorner")
    panelCorner.CornerRadius = UDim.new(0, 14)
    panelCorner.Parent = panel

    local panelStroke = Instance.new("UIStroke")
    panelStroke.Color = C.ACCENT_PURPLE
    panelStroke.Thickness = 1.2
    panelStroke.Parent = panel

    -- Status label in panel
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, -16, 0, 28)
    statusLabel.Position = UDim2.new(0, 8, 0, 8)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Chờ lệnh"
    statusLabel.TextColor3 = C.ACCENT_PURPLE
    statusLabel.TextScaled = true
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.ZIndex = 10
    statusLabel.Parent = panel

    -- Candy label in panel
    local panelCandyLabel = Instance.new("TextLabel")
    panelCandyLabel.Name = "PanelCandyLabel"
    panelCandyLabel.Size = UDim2.new(1, -16, 0, 24)
    panelCandyLabel.Position = UDim2.new(0, 8, 0, 38)
    panelCandyLabel.BackgroundTransparency = 1
    panelCandyLabel.Text = "🍬 Candy: --"
    panelCandyLabel.TextColor3 = C.ACCENT_ORANGE
    panelCandyLabel.TextScaled = true
    panelCandyLabel.Font = Enum.Font.GothamBold
    panelCandyLabel.TextXAlignment = Enum.TextXAlignment.Left
    panelCandyLabel.ZIndex = 10
    panelCandyLabel.Parent = panel

    -- ---- Button factory ----
    local buttonY = 70
    local function makeToggleButton(parent, labelText, toggleFn)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -16, 0, 36)
        btn.Position = UDim2.new(0, 8, 0, buttonY)
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        btn.BorderSizePixel = 0
        btn.Text = labelText .. ": OFF"
        btn.TextColor3 = C.TEXT_WHITE
        btn.TextScaled = true
        btn.Font = Enum.Font.Gotham
        btn.ZIndex = 10
        btn.Parent = parent
        buttonY = buttonY + 42

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn

        local active = false
        btn.MouseButton1Click:Connect(function()
            active = not active
            btn.Text = labelText .. ": " .. (active and "ON" or "OFF")
            btn.BackgroundColor3 = active
                and Color3.fromRGB(180, 80, 0)
                or  Color3.fromRGB(35, 35, 35)
            toggleFn(active)
        end)

        return btn
    end

    -- Trick or Treat
    makeToggleButton(panel, "Trick or Treat", function(on)
        if on then
            State.trickEnabled = true
            TaskManager.startTask("trick", TrickOrTreat.run)
        else
            if State.activeTask == "trick" then
                State.activeTask = nil
            end
            State.trickEnabled = false
            U.setStatus("Trick or Treat đã dừng")
        end
    end)

    -- Boss trong cửa (sub-option, no task switch)
    makeToggleButton(panel, "Boss trong cửa", function(on)
        State.bossCheckEnabled = on
    end)

    -- Mini Game (sub-option)
    makeToggleButton(panel, "Mini Game", function(on)
        State.miniGameEnabled = on
    end)

    -- Great Pumpkin
    makeToggleButton(panel, "Great Pumpkin", function(on)
        if on then
            State.gpEnabled = true
            TaskManager.startTask("pumpkin", GreatPumpkin.run)
        else
            if State.activeTask == "pumpkin" then
                State.activeTask = nil
            end
            State.gpEnabled = false
        end
    end)

    -- Pumpkin Farm
    makeToggleButton(panel, "Pumpkin Farm", function(on)
        if on then
            State.farmEnabled = true
            TaskManager.startTask("farm", PumpkinFarm.run)
        else
            if State.activeTask == "farm" then
                State.activeTask = nil
            end
            State.farmEnabled = false
        end
    end)

    -- STOP ALL
    local stopBtn = Instance.new("TextButton")
    stopBtn.Size = UDim2.new(1, -16, 0, 38)
    stopBtn.Position = UDim2.new(0, 8, 0, buttonY)
    stopBtn.BackgroundColor3 = Color3.fromRGB(180, 20, 20)
    stopBtn.BorderSizePixel = 0
    stopBtn.Text = "⛔ STOP ALL"
    stopBtn.TextColor3 = C.TEXT_WHITE
    stopBtn.TextScaled = true
    stopBtn.Font = Enum.Font.GothamBold
    stopBtn.ZIndex = 10
    stopBtn.Parent = panel

    local stopCorner = Instance.new("UICorner")
    stopCorner.CornerRadius = UDim.new(0, 8)
    stopCorner.Parent = stopBtn

    stopBtn.MouseButton1Click:Connect(function()
        U.stopAllTasks()
        -- Reset all toggle buttons visual
        for _, child in ipairs(panel:GetChildren()) do
            if child:IsA("TextButton") and child.Name ~= "StopBtn" then
                child.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                local labelEnd = child.Text:find(":")
                if labelEnd then
                    child.Text = child.Text:sub(1, labelEnd) .. " OFF"
                end
            end
        end
    end)

    panel.Size = UDim2.new(0, 280, 0, buttonY + 54)

    -- ---- Expand / Collapse toggle ----
    pill.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
            State.expanded = not State.expanded
            panel.Visible = State.expanded
            pillStroke.Color = State.expanded and C.ACCENT_PURPLE or C.ACCENT_ORANGE
        end
    end)

    -- ---- Draggable pill ----
    local dragging, dragStart, startPos
    pill.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos  = pill.Position
        end
    end)
    pill.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.Touch or
            input.UserInputType == Enum.UserInputType.MouseMove) then
            local delta = input.Position - dragStart
            pill.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
            panel.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X - 30,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y + 54
            )
        end
    end)
    pill.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- ---- Expose labels to state updater ----
    NinjaHub.UI = {
        statusLabel = statusLabel,
        candyLabel  = panelCandyLabel,
        pillCandy   = candyLabel,
    }

    -- Override setStatus to also update collapsed pill
    local origSetStatus = U.setStatus
    function U.setStatus(text)
        State.statusText = text
        if NinjaHub.UI then
            if NinjaHub.UI.statusLabel then
                NinjaHub.UI.statusLabel.Text = text
            end
        end
    end

    function U.updateCandyDisplay()
        State.candyCount = U.readCandy()
        local display = "🍬 Candy: " .. State.candyCount
        if NinjaHub.UI then
            if NinjaHub.UI.candyLabel  then NinjaHub.UI.candyLabel.Text  = display end
            if NinjaHub.UI.pillCandy   then NinjaHub.UI.pillCandy.Text   = "🍬 " .. State.candyCount end
        end
    end

    return screenGui
end

-- ============================================================
-- CANDY AUTO-UPDATE
-- ============================================================
local function startCandyWatcher()
    -- Poll candy every 2 seconds
    task.spawn(function()
        while true do
            task.wait(2)
            U.updateCandyDisplay()
        end
    end)

    -- Also watch leaderstats changed event
    local ls = LocalPlayer:WaitForChild("leaderstats", 5)
    if ls then
        local candyStat = ls:WaitForChild(C.CANDY_LEADERSTATS_KEY, 5)
        if candyStat then
            local conn = candyStat.Changed:Connect(function()
                U.updateCandyDisplay()
            end)
            table.insert(State.connections, conn)
        end
    end
end

-- ============================================================
-- CHARACTER RESPAWN HANDLER
-- ============================================================
local function handleRespawn()
    LocalPlayer.CharacterAdded:Connect(function(char)
        Character        = char
        HumanoidRootPart = char:WaitForChild("HumanoidRootPart", 10)
        Humanoid         = char:WaitForChild("Humanoid", 10)
        U.setStatus("Nhân vật hồi sinh — tiếp tục...")
    end)
end

-- ============================================================
-- EXPLORER UTILITIES
-- Run these once to find real paths. Print output to console.
-- Comment out after verification.
-- ============================================================
local Explorer = {}

function Explorer.dumpCandyPath()
    print("=== CANDY PATH DUMP ===")
    local ls = LocalPlayer:FindFirstChild("leaderstats")
    if ls then
        for _, v in ipairs(ls:GetChildren()) do
            print("leaderstats child:", v.Name, v.ClassName,
                  v:IsA("IntValue") and v.Value or "")
        end
    else
        print("No leaderstats found")
    end

    print("Player attributes:")
    for k, v in pairs(LocalPlayer:GetAttributes()) do
        print(" Attribute:", k, "=", v)
    end
end

function Explorer.dumpHouseFolder()
    print("=== WORKSPACE TOP-LEVEL ===")
    for _, child in ipairs(Workspace:GetChildren()) do
        print(child.Name, child.ClassName)
    end
end

function Explorer.dumpTagged()
    print("=== COLLECTION SERVICE TAGS ===")
    local cs = game:GetService("CollectionService")
    local tags = cs:GetAllTags()
    if tags then
        for _, tag in ipairs(tags) do
            local items = cs:GetTagged(tag)
            if #items > 0 then
                print(tag, "→", #items, "objects")
            end
        end
    end
end

function Explorer.dumpRemoteEvents()
    print("=== REMOTEEVENTS (ReplicatedStorage) ===")
    local rs = game:GetService("ReplicatedStorage")
    local function scan(obj, depth)
        if depth > 4 then return end
        for _, child in ipairs(obj:GetChildren()) do
            if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
                print(string.rep("  ", depth) .. child.Name .. " [" .. child.ClassName .. "]")
            end
            scan(child, depth + 1)
        end
    end
    scan(rs, 0)
end

function Explorer.dumpMiniGameGUI()
    print("=== PLAYERGUI CONTENTS ===")
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        print(gui.Name, gui.ClassName, gui.Enabled)
        for _, child in ipairs(gui:GetChildren()) do
            print("  ", child.Name, child.ClassName)
        end
    end
end

function Explorer.runAll()
    Explorer.dumpCandyPath()
    Explorer.dumpHouseFolder()
    Explorer.dumpTagged()
    Explorer.dumpRemoteEvents()
    Explorer.dumpMiniGameGUI()
    print("=== EXPLORER COMPLETE — fill Constants block from output ===")
end

-- Expose for manual call: Explorer.runAll() in executor console
NinjaHub.Explorer = Explorer

-- ============================================================
-- INIT
-- ============================================================
function NinjaHub.init()
    State.running = true
    UI.build()
    startCandyWatcher()
    handleRespawn()
    U.setStatus("NINJA HUB sẵn sàng")
    U.updateCandyDisplay()
    print("[NINJA HUB] Loaded. Run NinjaHub.Explorer.runAll() to dump game paths.")
    print("[NINJA HUB] Fill Constants block (C) with verified paths before enabling tasks.")
end

NinjaHub.init()

