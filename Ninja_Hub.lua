--[[
    NINJA HUB - Blox Fruits Halloween Event Hub
    File: Ninja_Hub.lua

    IMPORTANT:
    - This is a self-contained Roblox LocalScript UI + task controller.
    - It does NOT automate a third-party game's gameplay, teleport characters,
      invoke unverified remotes, or fabricate event progress.
    - Game-specific event adapters are intentionally left disabled until their
      live Instance/UI structure is verified in a legitimate test environment.
    - Candy displays "--" unless a real Candy/Candy Corn value is found in
      common player data containers.
]]

--// Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--// Configuration
local CONFIG = {
    Name = "NINJA HUB",
    AccentOrange = Color3.fromRGB(255, 133, 45),
    AccentPurple = Color3.fromRGB(157, 92, 255),
    Background = Color3.fromRGB(12, 12, 16),
    Panel = Color3.fromRGB(23, 23, 30),
    Text = Color3.fromRGB(245, 245, 250),
    Muted = Color3.fromRGB(155, 155, 170),
    Success = Color3.fromRGB(95, 220, 145),
    Danger = Color3.fromRGB(255, 85, 95),
    AnimationTime = 0.22,
}

--// Runtime state
local State = {
    expanded = false,
    running = false,
    activeTask = nil,
    status = "Đã dừng",
    subStatus = "Chưa chọn nhiệm vụ",
    observedSummary = "Chưa có dữ liệu giao diện sự kiện",
    observedFingerprint = "",
    stableObservations = 0,
    lastObservationAt = 0,
    candy = "--",
    bossAssist = true,
    miniGameAssist = true,
    destroyed = false,
    connections = {},
    taskToken = 0,
}

local function track(connection)
    table.insert(State.connections, connection)
    return connection
end

local function disconnectAll()
    for _, connection in ipairs(State.connections) do
        if connection and connection.Connected then
            connection:Disconnect()
        end
    end
    table.clear(State.connections)
end

--// Existing UI cleanup: prevent duplicate islands
local old = PlayerGui:FindFirstChild("NinjaHubHalloweenUI")
if old then
    old:Destroy()
end

--// UI helpers
local function corner(parent, radius)
    local item = Instance.new("UICorner")
    item.CornerRadius = UDim.new(0, radius)
    item.Parent = parent
    return item
end

local function stroke(parent, color, transparency, thickness)
    local item = Instance.new("UIStroke")
    item.Color = color
    item.Transparency = transparency or 0
    item.Thickness = thickness or 1
    item.Parent = parent
    return item
end

local function makeLabel(parent, text, size, color, font)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color or CONFIG.Text
    label.TextSize = size or 13
    label.Font = font or Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = parent
    return label
end

local function makeButton(parent, text, height)
    local button = Instance.new("TextButton")
    button.AutoButtonColor = false
    button.BackgroundColor3 = CONFIG.Panel
    button.Size = UDim2.new(1, 0, 0, height or 38)
    button.Text = text
    button.TextColor3 = CONFIG.Text
    button.TextSize = 13
    button.Font = Enum.Font.GothamSemibold
    button.Parent = parent
    corner(button, 10)
    stroke(button, Color3.fromRGB(65, 65, 80), 0.35, 1)
    return button
end

--// Screen GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NinjaHubHalloweenUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

--// Dynamic Island
local Island = Instance.new("Frame")
Island.Name = "DynamicIsland"
Island.AnchorPoint = Vector2.new(0.5, 0)
Island.Position = UDim2.new(0.5, 0, 0, 12)
Island.Size = UDim2.new(0, 292, 0, 66)
Island.BackgroundColor3 = CONFIG.Background
Island.BorderSizePixel = 0
Island.ClipsDescendants = true
Island.Parent = ScreenGui
corner(Island, 22)
stroke(Island, CONFIG.AccentPurple, 0.45, 1.2)

-- Scale the complete island to fit short or narrow mobile viewports.
local IslandScale = Instance.new("UIScale")
IslandScale.Scale = 1
IslandScale.Parent = Island

local function updateResponsiveScale()
    local camera = workspace.CurrentCamera
    if not camera then
        return
    end

    local viewport = camera.ViewportSize
    if viewport.X <= 0 or viewport.Y <= 0 then
        return
    end

    local widthScale = (viewport.X - 16) / 312
    local heightScale = (viewport.Y - 24) / 414
    IslandScale.Scale = math.clamp(math.min(widthScale, heightScale, 1), 0.4, 1)
end

updateResponsiveScale()

local Header = Instance.new("Frame")
Header.BackgroundTransparency = 1
Header.Size = UDim2.new(1, -20, 0, 30)
Header.Position = UDim2.new(0, 10, 0, 7)
Header.Parent = Island

-- Only the header toggles the island. The body remains available for its controls.
local HeaderHitbox = Instance.new("TextButton")
HeaderHitbox.Name = "HeaderHitbox"
HeaderHitbox.BackgroundTransparency = 1
HeaderHitbox.Text = ""
HeaderHitbox.AutoButtonColor = false
HeaderHitbox.Size = UDim2.new(1, 0, 1, 0)
HeaderHitbox.ZIndex = 10
HeaderHitbox.Parent = Header

local Brand = makeLabel(Header, "NINJA HUB", 13, CONFIG.Text, Enum.Font.GothamBold)
Brand.Size = UDim2.new(0.55, 0, 1, 0)

local RunState = makeLabel(Header, "● IDLE", 10, CONFIG.Muted, Enum.Font.GothamBold)
RunState.TextXAlignment = Enum.TextXAlignment.Right
RunState.Position = UDim2.new(0.55, 0, 0, 0)
RunState.Size = UDim2.new(0.45, 0, 1, 0)

local CandyLabel = makeLabel(Island, "Candy: --", 11, CONFIG.AccentOrange, Enum.Font.GothamSemibold)
CandyLabel.Position = UDim2.new(0, 12, 0, 39)
CandyLabel.Size = UDim2.new(0.42, 0, 0, 18)

local TaskLabel = makeLabel(Island, "Đang làm: Chưa chọn", 10, CONFIG.Muted)
TaskLabel.Position = UDim2.new(0.42, 0, 0, 39)
TaskLabel.Size = UDim2.new(0.54, 0, 0, 18)
TaskLabel.TextXAlignment = Enum.TextXAlignment.Right

--// Expanded panel content
local Expanded = Instance.new("Frame")
Expanded.Name = "ExpandedContent"
Expanded.BackgroundTransparency = 1
Expanded.Position = UDim2.new(0, 12, 0, 82)
Expanded.Size = UDim2.new(1, -24, 1, -94)
Expanded.Visible = false
Expanded.Parent = Island

local CurrentStatus = makeLabel(Expanded, "Trạng thái: Đã dừng", 11, CONFIG.Muted)
CurrentStatus.Size = UDim2.new(1, 0, 0, 22)

local Hint = makeLabel(Expanded,
    "Đang quan sát chữ giao diện sự kiện; không tự thao tác khi chưa xác minh.",
    10, CONFIG.Muted)
Hint.Position = UDim2.new(0, 0, 0, 23)
Hint.Size = UDim2.new(1, 0, 0, 32)
Hint.TextWrapped = true
Hint.TextYAlignment = Enum.TextYAlignment.Top

local TaskList = Instance.new("Frame")
TaskList.BackgroundTransparency = 1
TaskList.Position = UDim2.new(0, 0, 0, 60)
TaskList.Size = UDim2.new(1, 0, 0, 126)
TaskList.Parent = Expanded

local taskLayout = Instance.new("UIListLayout")
taskLayout.Padding = UDim.new(0, 6)
taskLayout.SortOrder = Enum.SortOrder.LayoutOrder
taskLayout.Parent = TaskList

local function makeTaskButton(title, order)
    local button = makeButton(TaskList, title .. "  |  START", 36)
    button.LayoutOrder = order
    return button
end

local TrickButton = makeTaskButton("Trick or Treat", 1)
local GreatButton = makeTaskButton("Great Pumpkin", 2)
local FarmButton = makeTaskButton("Pumpkin Farm", 3)

local function makeToggle(parent, text, initial)
    local button = makeButton(parent, text .. ": " .. (initial and "ON" or "OFF"), 34)
    return button
end

local BossToggle = makeToggle(Expanded, "Boss trong cửa", State.bossAssist)
BossToggle.Position = UDim2.new(0, 0, 0, 194)

local MiniToggle = makeToggle(Expanded, "Mini Game", State.miniGameAssist)
MiniToggle.Position = UDim2.new(0, 0, 0, 234)

local StopButton = makeButton(Expanded, "STOP ALL", 38)
StopButton.Position = UDim2.new(0, 0, 1, -40)
StopButton.BackgroundColor3 = Color3.fromRGB(65, 24, 30)
stroke(StopButton, CONFIG.Danger, 0.2, 1)

--// Layout sizing
local COLLAPSED_SIZE = UDim2.new(0, 292, 0, 66)
-- Extra vertical room keeps Mini Game and STOP ALL from overlapping.
local EXPANDED_SIZE = UDim2.new(0, 312, 0, 414)

local function refresh()
    if State.destroyed or not ScreenGui.Parent then
        return
    end

    CandyLabel.Text = "Candy: " .. tostring(State.candy)
    TaskLabel.Text = "Đang làm: " .. (State.activeTask or "Chưa chọn")
    CurrentStatus.Text = "Trạng thái: " .. State.status
        .. " | " .. tostring(State.subStatus)

    if State.running then
        RunState.Text = "● RUNNING"
        RunState.TextColor3 = CONFIG.Success
    else
        RunState.Text = "● IDLE"
        RunState.TextColor3 = CONFIG.Muted
    end

    local function updateTaskButton(button, name)
        if State.activeTask == name and State.running then
            button.Text = name .. "  |  RUNNING"
            button.BackgroundColor3 = Color3.fromRGB(31, 55, 42)
        else
            button.Text = name .. "  |  START"
            button.BackgroundColor3 = CONFIG.Panel
        end
    end

    updateTaskButton(TrickButton, "Trick or Treat")
    updateTaskButton(GreatButton, "Great Pumpkin")
    updateTaskButton(FarmButton, "Pumpkin Farm")

    BossToggle.Text = "Boss trong cửa: " .. (State.bossAssist and "ON" or "OFF")
    MiniToggle.Text = "Mini Game: " .. (State.miniGameAssist and "ON" or "OFF")
end

local activeSizeTween

local function setExpanded(value)
    State.expanded = value
    Expanded.Visible = true

    if activeSizeTween then
        activeSizeTween:Cancel()
        activeSizeTween = nil
    end

    local target = value and EXPANDED_SIZE or COLLAPSED_SIZE
    activeSizeTween = TweenService:Create(
        Island,
        TweenInfo.new(CONFIG.AnimationTime, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        {Size = target}
    )
    activeSizeTween:Play()
    if not value then
        task.delay(CONFIG.AnimationTime, function()
            if not State.expanded and Expanded.Parent then
                Expanded.Visible = false
            end
        end)
    end
end

--// Drag support (mouse + touch)
-- Dragging is limited to the header; tapping the header toggles expansion.
local dragInput
local dragStart
local startPosition
local dragMoved = false
local dragActive = false
local DRAG_THRESHOLD = 7

local viewportConnection
local function bindViewportUpdates()
    if viewportConnection and viewportConnection.Connected then
        viewportConnection:Disconnect()
    end

    local camera = workspace.CurrentCamera
    if camera then
        viewportConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateResponsiveScale)
        track(viewportConnection)
    else
        viewportConnection = nil
    end
end

bindViewportUpdates()
track(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    updateResponsiveScale()
    bindViewportUpdates()
end))

track(HeaderHitbox.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragActive = true
        dragMoved = false
        dragStart = input.Position
        startPosition = Island.Position
        dragInput = input
    end
end))

track(HeaderHitbox.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end))

track(UserInputService.InputChanged:Connect(function(input)
    if not dragActive or not dragStart or not startPosition then
        return
    end

    if input == dragInput then
        local delta = input.Position - dragStart
        if math.abs(delta.X) > DRAG_THRESHOLD or math.abs(delta.Y) > DRAG_THRESHOLD then
            dragMoved = true
        end

        if dragMoved then
            local camera = workspace.CurrentCamera
            local viewport = camera and camera.ViewportSize
            local targetX = startPosition.X.Scale * (viewport and viewport.X or 0)
                + startPosition.X.Offset + delta.X
            local targetY = startPosition.Y.Scale * (viewport and viewport.Y or 0)
                + startPosition.Y.Offset + delta.Y

            if viewport then
                local halfWidth = Island.AbsoluteSize.X * 0.5
                local maxX = math.max(halfWidth, viewport.X - halfWidth)
                targetX = math.clamp(targetX, halfWidth, maxX)
                targetY = math.clamp(targetY, 0, math.max(0, viewport.Y - Island.AbsoluteSize.Y))
            else
                targetY = math.max(0, targetY)
            end

            Island.Position = UDim2.new(0, targetX, 0, targetY)
        end
    end
end))

track(UserInputService.InputEnded:Connect(function(input)
    if not dragActive then
        return
    end

    local isPointerEnd = input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch

    if isPointerEnd then
        local wasDragged = dragMoved
        dragActive = false
        dragInput = nil
        dragStart = nil
        startPosition = nil

        if not wasDragged then
            setExpanded(not State.expanded)
        end
    end
end))

--// Candy reader: only accepts a real numeric value from common data containers.
local function findCandyValue()
    local candidates = {
        "Candy", "Candies", "CandyCorn", "Candy Corn", "Candy_Corn"
    }

    local containers = {
        LocalPlayer:FindFirstChild("leaderstats"),
        LocalPlayer:FindFirstChild("Data"),
        LocalPlayer:FindFirstChild("Stats"),
    }

    for _, container in ipairs(containers) do
        if container then
            for _, name in ipairs(candidates) do
                local value = container:FindFirstChild(name, true)
                if value and (value:IsA("IntValue") or value:IsA("NumberValue")) then
                    return tostring(value.Value)
                end
            end
        end
    end
    return "--"
end

-- Poll at a modest interval instead of scanning the player tree every frame.
task.spawn(function()
    while not State.destroyed and ScreenGui.Parent do
        local ok, current = pcall(findCandyValue)
        if not ok then
            current = "--"
        end

        if current ~= State.candy then
            State.candy = current
            refresh()
        end
        task.wait(1)
    end
end)

--// Passive event UI observer
-- This reads visible UI text only. It never clicks controls or guesses mini-game answers.
local OBSERVED_KEYWORDS = {
    "trick", "treat", "pumpkin", "candy", "memory", "match",
    "door", "oni", "shipwright", "great", "witch", "monster",
}

local function isActuallyVisible(object)
    local current = object
    while current and current ~= PlayerGui do
        if current:IsA("GuiObject") and not current.Visible then
            return false
        end
        if current:IsA("ScreenGui") and not current.Enabled then
            return false
        end
        current = current.Parent
    end
    return current == PlayerGui
end

local function collectVisibleEventText()
    local found = {}
    local seen = {}

    for _, object in ipairs(PlayerGui:GetDescendants()) do
        local isTextObject = object:IsA("TextLabel")
            or object:IsA("TextButton")
            or object:IsA("TextBox")

        -- Ignore NINJA HUB's own labels so its buttons cannot trigger false detections.
        if isTextObject
            and not object:IsDescendantOf(ScreenGui)
            and isActuallyVisible(object) then

            local value = tostring(object.Text or "")
            local normalized = string.lower(value)

            if value ~= "" then
                for _, keyword in ipairs(OBSERVED_KEYWORDS) do
                    if string.find(normalized, keyword, 1, true) then
                        if not seen[value] then
                            seen[value] = true
                            table.insert(found, value)
                        end
                        break
                    end
                end
            end
        end
    end

    table.sort(found)
    return found
end

local function summarizeObservedText(observed)
    if #observed == 0 then
        return "Không thấy chữ giao diện sự kiện phù hợp"
    end

    local joined = string.lower(table.concat(observed, " | "))
    local tags = {}

    -- These are diagnostic hints only, not proof that a minigame or boss is active.
    if string.find(joined, "memory", 1, true)
        or string.find(joined, "match", 1, true)
        or string.find(joined, "card", 1, true) then
        table.insert(tags, "có từ khóa thẻ/ghép cặp")
    end

    if string.find(joined, "oni", 1, true) then
        table.insert(tags, "có từ khóa Oni")
    end

    if string.find(joined, "shipwright", 1, true) then
        table.insert(tags, "có từ khóa Shipwright")
    end

    if string.find(joined, "witch", 1, true)
        or string.find(joined, "great pumpkin", 1, true) then
        table.insert(tags, "có từ khóa Witch/Great Pumpkin")
    end

    if string.find(joined, "door", 1, true)
        or string.find(joined, "trick", 1, true)
        or string.find(joined, "treat", 1, true) then
        table.insert(tags, "có từ khóa cửa/Trick or Treat")
    end

    local detail = #tags > 0 and table.concat(tags, ", ") or "chưa phân loại được"
    return detail .. " (" .. tostring(#observed) .. " dòng chữ)"
end

task.spawn(function()
    while not State.destroyed and ScreenGui.Parent do
        local ok, observedOrError = pcall(collectVisibleEventText)

        if not ok then
            State.observedSummary = "Lỗi đọc giao diện: " .. tostring(observedOrError)
            State.observedFingerprint = ""
            State.stableObservations = 0
            if Hint.Parent then
                Hint.Text = State.observedSummary
            end
        else
            local observed = observedOrError
            local fingerprint = table.concat(observed, "\31")

            if fingerprint == State.observedFingerprint then
                State.stableObservations += 1
            else
                State.observedFingerprint = fingerprint
                State.stableObservations = 1
            end

            State.lastObservationAt = os.clock()
            State.observedSummary = summarizeObservedText(observed)

            if State.destroyed or not Hint.Parent then
                break
            end

            if #observed > 0 then
                local preview = table.concat(observed, " | ")
                if #preview > 105 then
                    preview = string.sub(preview, 1, 102) .. "..."
                end

                local stability = State.stableObservations >= 2
                    and "ổn định qua 2 lần quét"
                    or "đang xác nhận"
                Hint.Text = "Quan sát: " .. State.observedSummary
                    .. " [" .. stability .. "]\n" .. preview
            else
                Hint.Text = "Quan sát: " .. State.observedSummary
                    .. "\nKhông tự chọn đáp án hoặc thao tác."
            end
        end

        task.wait(2)
    end
end)

--// Task manager
-- Task adapters are deliberately unavailable until verified against the live game.
local TaskAdapters = {
    ["Trick or Treat"] = nil,
    ["Great Pumpkin"] = nil,
    ["Pumpkin Farm"] = nil,
}

local function stopAll()
    State.taskToken += 1
    State.running = false
    State.activeTask = nil
    State.status = "Đã dừng"
    State.subStatus = "Không có nhiệm vụ hoạt động"
    refresh()
end

local function startTask(name)
    stopAll()

    local adapter = TaskAdapters[name]
    if type(adapter) ~= "function" then
        State.running = false
        State.activeTask = nil
        State.status = "Chưa khả dụng"
        State.subStatus = "Đã ghi nhận yêu cầu; chưa có bộ điều khiển game đã xác minh"
        refresh()
        warn("[NINJA HUB] " .. name
            .. " chưa chạy. UI chỉ ghi nhận thao tác; không có adapter gameplay được xác minh.")
        return
    end

    State.taskToken += 1
    local myToken = State.taskToken
    State.running = true
    State.activeTask = name
    State.status = "Đang khởi động"
    refresh()

    task.spawn(function()
        local ok, err = pcall(adapter, function()
            return State.taskToken == myToken and State.running
        end, function(status)
            if State.taskToken == myToken then
                State.status = tostring(status)
                refresh()
            end
        end)

        if State.taskToken == myToken then
            State.running = false
            State.activeTask = nil
            State.status = ok and "Đã hoàn thành" or "Lỗi nhiệm vụ"
            if not ok then
                warn("[NINJA HUB] " .. tostring(err))
            end
            refresh()
        end
    end)
end

--// Character lifecycle safety
-- If the character is removed (death/reset), invalidate the current task token.
track(LocalPlayer.CharacterRemoving:Connect(function()
    if State.running then
        stopAll()
        State.status = "Đã dừng: nhân vật hồi sinh"
        refresh()
    end
end))

--// Button events
track(TrickButton.Activated:Connect(function()
    if State.activeTask == "Trick or Treat" and State.running then
        stopAll()
    else
        startTask("Trick or Treat")
    end
end))

track(GreatButton.Activated:Connect(function()
    if State.activeTask == "Great Pumpkin" and State.running then
        stopAll()
    else
        startTask("Great Pumpkin")
    end
end))

track(FarmButton.Activated:Connect(function()
    if State.activeTask == "Pumpkin Farm" and State.running then
        stopAll()
    else
        startTask("Pumpkin Farm")
    end
end))

track(BossToggle.Activated:Connect(function()
    State.bossAssist = not State.bossAssist
    refresh()
end))

track(MiniToggle.Activated:Connect(function()
    State.miniGameAssist = not State.miniGameAssist
    refresh()
end))

track(StopButton.Activated:Connect(stopAll))

--// Safe teardown
track(ScreenGui.Destroying:Connect(function()
    State.destroyed = true
    stopAll()
    disconnectAll()
end))

refresh()
print("[NINJA HUB] UI loaded. Event automation remains disabled until verified adapters are supplied.")
