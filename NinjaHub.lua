-- ============================================================
--  NINJA HUB v1.3 — Steal An Egg
--  Fix: tab content load, float button parent, toggle UI, kick guard
-- ============================================================

-- ── LOAD THƯ VIỆN ──────────────────────────────────────────
local FLUENT_URLS = {
    "https://raw.githubusercontent.com/hoang-VN1/FluentPlus/refs/heads/main/release.lua",
    "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Fluent.lua",
}
local SAVE_URL  = "https://raw.githubusercontent.com/hoang-VN1/Fluent/master/Addons/SaveManager.lua"
local IFACE_URL = "https://raw.githubusercontent.com/hoang-VN1/Fluent/master/Addons/InterfaceManager.lua"

-- Hiện thông báo load đang chạy
local loadingGui
pcall(function()
    local parent
    pcall(function() if gethui then parent = gethui() end end)
    parent = parent or game:GetService("CoreGui")
    loadingGui = Instance.new("ScreenGui")
    loadingGui.Name = "NinjaHubLoading"
    loadingGui.ResetOnSpawn = false
    loadingGui.DisplayOrder = 9999
    loadingGui.Parent = parent
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0,260,0,44)
    f.Position = UDim2.new(0.5,-130,0,12)
    f.BackgroundColor3 = Color3.fromRGB(18,18,26)
    f.BorderSizePixel = 0
    f.Parent = loadingGui
    Instance.new("UICorner",f).CornerRadius = UDim.new(0,10)
    local lbl = Instance.new("TextLabel",f)
    lbl.Size = UDim2.new(1,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(160,100,255)
    lbl.TextScaled = true
    lbl.Font = Enum.Font.GothamBold
    lbl.Text = "🥷 Ninja Hub — Đang tải..."
end)

local function tryLoad(urls)
    if type(urls) == "string" then urls = {urls} end
    for _, url in ipairs(urls) do
        local ok, result = pcall(function()
            return loadstring(game:HttpGet(url, true))()
        end)
        if ok and result then return result end
        task.wait(0.3)
    end
    error("Không load được thư viện")
end

local Fluent, SaveManager, InterfaceManager
local loadOk, loadErr = pcall(function()
    Fluent           = tryLoad(FLUENT_URLS)
    SaveManager      = tryLoad(SAVE_URL)
    InterfaceManager = tryLoad(IFACE_URL)
end)

-- Xóa loading overlay
pcall(function() if loadingGui then loadingGui:Destroy() end end)

if not loadOk then
    local parent
    pcall(function() if gethui then parent = gethui() end end)
    parent = parent or game:GetService("CoreGui")
    local sg = Instance.new("ScreenGui")
    sg.Name = "NinjaHubError"; sg.ResetOnSpawn = false; sg.DisplayOrder = 9999
    sg.Parent = parent
    local f = Instance.new("Frame", sg)
    f.Size = UDim2.new(0,360,0,100)
    f.Position = UDim2.new(0.5,-180,0.45,0)
    f.BackgroundColor3 = Color3.fromRGB(30,0,0)
    f.BorderSizePixel = 0
    Instance.new("UICorner",f).CornerRadius = UDim.new(0,12)
    local lbl = Instance.new("TextLabel",f)
    lbl.Size = UDim2.new(1,-16,1,0); lbl.Position = UDim2.new(0,8,0,0)
    lbl.BackgroundTransparency = 1; lbl.TextColor3 = Color3.fromRGB(255,80,80)
    lbl.TextWrapped = true; lbl.TextScaled = true
    lbl.Font = Enum.Font.Gotham
    lbl.Text = "🥷 Ninja Hub: Lỗi load thư viện\nBật HTTP Requests trong game settings\n" .. tostring(loadErr):sub(1,80)
    return
end

-- ── EXECUTOR DETECT ────────────────────────────────────────
local ExecName = "Unknown"
pcall(function()
    if identifyexecutor then ExecName = identifyexecutor()
    elseif syn and syn.request then ExecName = "Synapse X"
    elseif KRNL_LOADED then ExecName = "KRNL"
    elseif rconsoleprint then ExecName = "Script-Ware / Delta"
    elseif fluxus then ExecName = "Fluxus"
    elseif ronix then ExecName = "Ronix"
    end
end)

local function copyToClipboard(text)
    pcall(function()
        if setclipboard then setclipboard(text)
        elseif toclipboard then toclipboard(text)
        elseif Clipboard and Clipboard.set then Clipboard.set(text)
        end
    end)
end

-- ── SERVICES ───────────────────────────────────────────────
local Players          = game:GetService("Players")
local CoreGui          = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local TeleportService  = game:GetService("TeleportService")
local HttpService      = game:GetService("HttpService")

local player    = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid  = character:FindFirstChildOfClass("Humanoid")

player.CharacterAdded:Connect(function(char)
    character = char
    humanoid  = char:FindFirstChildOfClass("Humanoid")
end)

-- ── TIỆN ÍCH ───────────────────────────────────────────────
local function safeGet(root, path)
    local cur = root
    for _, name in ipairs(path) do
        if not cur then return nil end
        cur = cur:FindFirstChild(name)
    end
    return cur
end

local function getSpeed()
    local ls = safeGet(player, {"leaderstats"})
    if ls then
        for _, n in ipairs({"Speed","SPD","Spd","speed"}) do
            local v = ls:FindFirstChild(n)
            if v then return tostring(v.Value) end
        end
    end
    local hum = character and character:FindFirstChildOfClass("Humanoid")
    return hum and string.format("%.0f (WalkSpeed)", hum.WalkSpeed) or "N/A"
end

local function getMoney()
    local ls = safeGet(player, {"leaderstats"})
    if ls then
        for _, n in ipairs({"Cash","Money","Coins","Gems","Gold","cash","money","Eggs","Honey"}) do
            local v = ls:FindFirstChild(n)
            if v and tostring(v.Value) ~= "0" then return n..": "..tostring(v.Value) end
        end
        -- Lấy tất cả leaderstats
        local parts = {}
        for _, v in ipairs(ls:GetChildren()) do
            table.insert(parts, v.Name..": "..tostring(v.Value))
        end
        if #parts > 0 then return table.concat(parts, " | ") end
    end
    return "N/A"
end

-- ═══════════════════════════════════════════════════════════
--  AUTO STEAL ENGINE
-- ═══════════════════════════════════════════════════════════
local AutoSteal = {
    Active      = false,
    FlySpeed    = 120,
    SafePos     = nil,
    CatchAll    = false,
    Status      = "Chờ...",
    TargetNames = {
        "RiftEgg","Rift Egg",
        "ExtinctionEgg","Extinction Egg",
        "LuminousEgg","Luminous Egg",
        "Experiment #001 Egg","Experiment #013 Egg",
    },
}

local stealLabel = nil  -- gán sau khi tạo Eggs tab

local function setStealStatus(msg)
    AutoSteal.Status = msg
    if stealLabel then pcall(function() stealLabel:SetContent(msg) end) end
end

local function isTargetEgg(name)
    local low = name:lower()
    for _, t in ipairs(AutoSteal.TargetNames) do
        if low == t:lower() then return true end
    end
    return AutoSteal.CatchAll and (low:find("egg") ~= nil)
end

local function findNearestEgg()
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local best, bestDist = nil, math.huge
    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if (obj:IsA("BasePart") or obj:IsA("Model")) and isTargetEgg(obj.Name) then
                local pos = obj:IsA("Model")
                    and (obj.PrimaryPart and obj.PrimaryPart.Position or obj:GetModelCFrame().Position)
                    or obj.Position
                local d = (pos - root.Position).Magnitude
                if d < bestDist then best = obj; bestDist = d end
            end
        end
    end)
    return best, bestDist
end

local function flyTo(targetPos, onDone)
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then if onDone then onDone(false) end return end
    local conn; local done = false
    conn = RunService.Heartbeat:Connect(function(dt)
        pcall(function()
            local r = character and character:FindFirstChild("HumanoidRootPart")
            if not r then conn:Disconnect(); if onDone then onDone(false) end; return end
            local diff = targetPos - r.Position
            local dist = diff.Magnitude
            if dist < 3 then
                done = true; conn:Disconnect()
                if onDone then onDone(true) end
                return
            end
            r.CFrame = CFrame.new(r.Position + diff.Unit * math.min(AutoSteal.FlySpeed * dt, dist))
        end)
    end)
    task.delay(8, function()
        if not done then pcall(function() conn:Disconnect() end); if onDone then onDone(false) end end
    end)
end

local function asyncFlyTo(pos)
    -- Synchronous wrapper dùng task.wait
    local done, ok = false, false
    flyTo(pos, function(result) ok = result; done = true end)
    local t = 0
    while not done and t < 10 do task.wait(0.1); t = t + 0.1 end
    return ok
end

local function stealLoop()
    while AutoSteal.Active do
        pcall(function()
            local egg, dist = findNearestEgg()
            if egg then
                setStealStatus(string.format("Bay tới: %s (%.0fm)", egg.Name, dist or 0))
                local ePos = egg:IsA("Model")
                    and (egg.PrimaryPart and egg.PrimaryPart.Position or egg:GetModelCFrame().Position)
                    or egg.Position
                if asyncFlyTo(ePos) then
                    pcall(function()
                        local cd = egg:FindFirstChildOfClass("ClickDetector")
                        if cd then fireclickdetector(cd) end
                        local pp = egg:FindFirstChildOfClass("ProximityPrompt")
                        if pp then fireproximityprompt(pp) end
                    end)
                    setStealStatus("Đã cướp! Bay về base...")
                    if AutoSteal.SafePos then asyncFlyTo(AutoSteal.SafePos) end
                    setStealStatus("Về base xong. Tiếp tục...")
                else
                    setStealStatus("Không tới được — bỏ qua")
                end
            else
                setStealStatus("Không có trứng xịn — đang quét...")
            end
        end)
        task.wait(2)
    end
    setStealStatus("Đã dừng")
end

-- ── TẠO CỬA SỔ ─────────────────────────────────────────────
-- task.wait nhỏ để game hoàn tất init trước khi tạo UI
task.wait(0.3)

local Window = Fluent:CreateWindow({
    Title                  = "Ninja Hub",
    SubTitle               = "Steal An Egg  •  v1.3",
    TitleIcon              = "rbxassetid://6031068421",
    DropdownsOutsideWindow = true,
    Size                   = UDim2.fromOffset(500, 370),
    TabWidth               = 160,
    Acrylic                = true,
    Theme                  = "Dark",
    Search                 = false,
    MinimizeKey            = Enum.KeyCode.LeftControl,
})

-- Chờ Window render xong
task.wait(0.2)

-- ── TABS ────────────────────────────────────────────────────
local Tabs = {
    Home      = Window:AddTab({ Title = "Home",       Icon = "home"      }),
    Eggs      = Window:AddTab({ Title = "Eggs",       Icon = "egg"       }),
    Pets      = Window:AddTab({ Title = "Pets",       Icon = "paw-print" }),
    Nitro     = Window:AddTab({ Title = "Nitro Race", Icon = "zap"       }),
    Butterfly = Window:AddTab({ Title = "Butterfly",  Icon = "flower-2"  }),
    Server    = Window:AddTab({ Title = "Server",     Icon = "server"    }),
    Movement  = Window:AddTab({ Title = "Movement",   Icon = "move"      }),
    Settings  = Window:AddTab({ Title = "Settings",   Icon = "settings"  }),
}

task.wait(0.1) -- chờ tabs mount

-- ═══════════════════════════════════════════════════════════
--  TAB 1: HOME
-- ═══════════════════════════════════════════════════════════
local statusLabel, moneyLabel, speedLabel

do
    local t = Tabs.Home

    t:AddSection({ Name = "⚡ Ninja Hub — Trạng thái" })

    statusLabel = t:AddParagraph({ Title = "Trạng thái",  Content = "Đang tải..." })
    moneyLabel  = t:AddParagraph({ Title = "Tài khoản",   Content = getMoney()    })
    speedLabel  = t:AddParagraph({ Title = "Speed",       Content = getSpeed()    })

    -- Throttle update 3s
    local lastRefresh = 0
    RunService.Heartbeat:Connect(function()
        local now = tick()
        if now - lastRefresh < 3 then return end
        lastRefresh = now
        pcall(function()
            moneyLabel:SetContent(getMoney())
            speedLabel:SetContent(getSpeed())
            local hum = character and character:FindFirstChildOfClass("Humanoid")
            statusLabel:SetContent(hum
                and string.format("%s  |  HP: %.0f/%.0f", player.Name, hum.Health, hum.MaxHealth)
                or "Nhân vật chưa sẵn sàng"
            )
        end)
    end)

    t:AddSection({ Name = "🔧 Công cụ" })

    t:AddButton({
        Title    = "Làm mới thông số",
        Desc     = "Cập nhật tiền, speed và HP ngay",
        Callback = function()
            pcall(function()
                moneyLabel:SetContent(getMoney())
                speedLabel:SetContent(getSpeed())
            end)
            Fluent:Notify({ Title = "Ninja Hub", Content = "Đã làm mới!", Duration = 2 })
        end
    })

    t:AddParagraph({
        Title   = "Thông tin",
        Content = string.format(
            "Ninja Hub v1.3 | Steal An Egg\nNitro Race + Butterfly Bloom\n\n💻 Executor: %s\n📱 Platform: %s",
            ExecName,
            UserInputService.TouchEnabled and "Mobile" or "PC/Console"
        )
    })

    t:AddSection({ Name = "⌨️ Phím tắt (PC)" })

    t:AddParagraph({
        Title   = "Keybinds",
        Content = "Left Ctrl  — Thu gọn / Mở menu\nF5         — Làm mới stats\nF6         — Bật/tắt Auto Steal\nF7         — Server Hop\nDelete     — Đóng Hub"
    })
end

-- ═══════════════════════════════════════════════════════════
--  TAB 2: EGGS
-- ═══════════════════════════════════════════════════════════
do
    local t = Tabs.Eggs

    t:AddSection({ Name = "🥚 Trứng trong tay" })

    local eggInfoLabel = t:AddParagraph({ Title = "Trứng", Content = "Nhấn Quét để kiểm tra" })

    local function scanEggsInv()
        local found = {}
        pcall(function()
            for _, src in ipairs({character, player:FindFirstChild("Backpack")}) do
                if src then
                    for _, obj in ipairs(src:GetChildren()) do
                        if obj.Name:lower():find("egg") then
                            table.insert(found, "• "..obj.Name)
                        end
                    end
                end
            end
        end)
        return #found > 0 and table.concat(found,"\n") or "Không thấy trứng trong túi"
    end

    t:AddButton({
        Title    = "🔍 Quét trứng trong túi",
        Callback = function()
            eggInfoLabel:SetContent(scanEggsInv())
        end
    })

    -- AUTO STEAL
    t:AddSection({ Name = "🥷 Auto Steal" })

    stealLabel = t:AddParagraph({ Title = "Trạng thái", Content = "Chờ bật..." })

    t:AddToggle("AutoStealToggle", {
        Title    = "Bật Auto Steal",
        Desc     = "Tự bay tới trứng xịn và cướp về base",
        Default  = false,
        Callback = function(val)
            AutoSteal.Active = val
            if val then
                task.spawn(stealLoop)
                Fluent:Notify({ Title = "Auto Steal", Content = "Đã bật!", Duration = 2 })
            end
        end
    })

    t:AddSlider("FlySpeedSlider", {
        Title    = "Tốc độ bay",
        Min = 20, Max = 500, Default = 120, Rounding = 0,
        Callback = function(val) AutoSteal.FlySpeed = val end
    })

    t:AddToggle("CatchAllToggle", {
        Title    = "Bắt mọi trứng",
        Desc     = "Cướp tất cả object có tên chứa 'egg'",
        Default  = false,
        Callback = function(val) AutoSteal.CatchAll = val end
    })

    t:AddButton({
        Title    = "📍 Lưu vị trí base",
        Desc     = "Ghi nhớ chỗ đứng hiện tại làm điểm về",
        Callback = function()
            local root = character and character:FindFirstChild("HumanoidRootPart")
            if root then
                AutoSteal.SafePos = root.Position
                Fluent:Notify({ Title = "Base đã lưu",
                    Content = string.format("X:%.0f Y:%.0f Z:%.0f", root.Position.X, root.Position.Y, root.Position.Z),
                    Duration = 3 })
                setStealStatus("Base đã lưu ✅")
            end
        end
    })

    t:AddButton({
        Title    = "🔍 Quét tên trứng trong workspace",
        Desc     = "Tìm object 'egg' — copy tên thật để điền",
        Callback = function()
            local found = {}
            pcall(function()
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj.Name:lower():find("egg") then
                        local key = obj.Name.." ["..obj.ClassName.."]"
                        if not table.find(found, key) then table.insert(found, key) end
                        if #found >= 20 then break end
                    end
                end
            end)
            local txt = #found > 0 and table.concat(found,"\n") or "Không tìm thấy — trứng chưa spawn?"
            setStealStatus(txt)
            Fluent:Notify({ Title = "Scan", Content = #found.." objects", Duration = 2 })
        end
    })

    t:AddSection({ Name = "📋 Trứng trong game" })
    t:AddParagraph({
        Title   = "Danh sách",
        Content = "• Extinction Egg  • Luminous Egg\n• Rift Egg         • Experiment #001\n• Experiment #013  • Cherry Blossom\n• Monster Egg\n\n⚠ Quét workspace để lấy tên Instance thật"
    })
end

-- ═══════════════════════════════════════════════════════════
--  TAB 3: PETS
-- ═══════════════════════════════════════════════════════════
do
    local t = Tabs.Pets

    local EggPetDB = {
        ["Rift Egg"]            = {"Overlord","Shadow Drake","Void Wolf","Rift Fox","Eclipse Bear","Phantom Cat","Dark Serpent","Null Bunny","Abyss Turtle","Glitch Deer","Rift Dragon","Void Phoenix","Shadow Tiger","Eclipse Lion","Null Hydra","Rift Overlord"},
        ["Extinction Egg"]      = {"T-Rex","Mammoth","Saber Tooth","Dodo","Pterodactyl","Triceratops"},
        ["Luminous Egg"]        = {"Luminous Cat","Luminous Dog","Luminous Fox","Luminous Dragon","Luminous Phoenix"},
        ["Experiment #001 Egg"] = {"Experiment #001","Mutant Frog","Lab Rat"},
        ["Experiment #013 Egg"] = {"Experiment #013","Bio Wolf","Toxic Snake"},
        ["Cherry Blossom Egg"]  = {"Crane","Sakura Fox","Petal Deer","Blossom Bunny"},
        ["Monster Egg"]         = {"Hungry Frog","Bloom Frog","Spirit Bloom Frog"},
    }

    local petToEgg = {}
    for egg, pets in pairs(EggPetDB) do
        for _, pet in ipairs(pets) do petToEgg[pet] = egg end
    end

    local eggNames = {}
    for k in pairs(EggPetDB) do table.insert(eggNames, k) end
    table.sort(eggNames)

    local allPets = {}
    for _, egg in ipairs(eggNames) do
        for _, pet in ipairs(EggPetDB[egg]) do
            table.insert(allPets, pet)
        end
    end

    local selectedEgg = eggNames[1]
    local selectedPet = nil

    t:AddSection({ Name = "🐾 Chọn Pet" })

    local petStatusLabel = t:AddParagraph({ Title = "Nhắm tới", Content = "Chưa chọn" })

    t:AddDropdown("EggDropdown", {
        Title    = "Chọn loại trứng",
        Values   = eggNames,
        Default  = eggNames[1],
        Callback = function(val)
            selectedEgg = val
            selectedPet = nil
            AutoSteal.TargetNames = { val }
            petStatusLabel:SetContent("Trứng: "..val.."\n→ Chọn pet bên dưới hoặc bật steal ngay")
        end
    })

    t:AddDropdown("PetDropdown", {
        Title    = "Chọn pet muốn lấy",
        Values   = allPets,
        Default  = allPets[1],
        Callback = function(val)
            selectedPet = val
            local egg = petToEgg[val] or selectedEgg
            selectedEgg = egg
            AutoSteal.TargetNames = { egg }
            petStatusLabel:SetContent(string.format("🎯 Pet: %s\n📦 Trứng: %s", val, egg))
        end
    })

    t:AddSection({ Name = "🥷 Auto Steal theo Pet" })

    local petStealLabel = t:AddParagraph({ Title = "Trạng thái", Content = "Chưa bật" })

    t:AddToggle("AutoStealPetToggle", {
        Title    = "Bật Auto Steal theo Pet",
        Desc     = "Chọn pet trước, script tìm đúng trứng",
        Default  = false,
        Callback = function(val)
            AutoSteal.Active = val
            if val then
                if not selectedEgg then
                    Fluent:Notify({ Title = "Pets", Content = "Chọn pet trước!", Duration = 3 })
                    AutoSteal.Active = false; return
                end
                AutoSteal.TargetNames = { selectedEgg }
                petStealLabel:SetContent("🟢 Đang steal: "..(selectedPet or selectedEgg))
                task.spawn(stealLoop)
                Fluent:Notify({ Title = "Auto Steal Pet", Content = "Đang tìm: "..(selectedPet or selectedEgg), Duration = 3 })
            else
                petStealLabel:SetContent("⚫ Đã dừng")
            end
        end
    })

    t:AddSection({ Name = "📋 Danh sách Pets" })
    t:AddParagraph({
        Title   = "Pets theo trứng",
        Content = "🥚 Rift Egg (16): Overlord, Shadow Drake...\n🦕 Extinction: T-Rex, Mammoth...\n✨ Luminous: Cat/Dog/Fox/Dragon/Phoenix\n🧪 Exp #001/#013: Bio Wolf, Mutant Frog...\n🌸 Cherry Blossom: Crane, Sakura Fox...\n👾 Monster: Hungry/Bloom/Spirit Frog\n\n⚠ Tên từ wiki"
    })

    t:AddSection({ Name = "🏆 Win Pass (Nitro Race)" })
    t:AddParagraph({
        Title   = "Phần thưởng",
        Content = "1w → Seahorse  |  5w → Lizard\n15w → Bird  |  21w → Cheetah  |  30w → Snail"
    })
end

-- ═══════════════════════════════════════════════════════════
--  TAB 4: NITRO RACE
-- ═══════════════════════════════════════════════════════════
do
    local t = Tabs.Nitro

    t:AddSection({ Name = "🏎️ Nitro Race" })
    t:AddParagraph({
        Title   = "Cơ chế",
        Content = "• Race mỗi 30 phút\n• 1st place: +1 Win, +2,500 Trophies\n• Trophies → Nitro Mutation (475T, 10%)\n• Win Pass: 5 pet độc quyền"
    })

    t:AddSection({ Name = "⏱ Đếm ngược" })
    local timerLabel  = t:AddParagraph({ Title = "Race tiếp theo", Content = "Bật để đếm" })
    local timerActive = false
    local timerStart  = 0
    local lastTick    = 0
    local notified    = false

    t:AddToggle("NitroTimer", {
        Title    = "Bật đồng hồ",
        Default  = false,
        Callback = function(val)
            timerActive = val; notified = false
            if val then timerStart = tick()
            else timerLabel:SetContent("Đã tắt") end
        end
    })

    RunService.Heartbeat:Connect(function()
        if not timerActive then return end
        local now = tick()
        if now - lastTick < 1 then return end
        lastTick = now
        pcall(function()
            local rem = 1800 - ((now - timerStart) % 1800)
            timerLabel:SetContent(string.format("Race tiếp theo: %02d:%02d", math.floor(rem/60), rem%60))
            if rem <= 10 and not notified then
                notified = true
                Fluent:Notify({ Title = "🏎️ Nitro Race!", Content = "Race sắp bắt đầu!", Duration = 5 })
            end
            if rem > 10 then notified = false end
        end)
    end)

    t:AddSection({ Name = "📊 Theo dõi" })

    local winCount    = 0
    local trophyCount = 0
    local winLabel    = t:AddParagraph({ Title = "Wins",     Content = "0 wins" })
    local trphLabel   = t:AddParagraph({ Title = "Trophies", Content = "0" })

    local WR = {{1,"Seahorse"},{5,"Lizard"},{15,"Bird"},{21,"Cheetah"},{30,"Snail"}}
    local function nextR(w)
        for _, r in ipairs(WR) do
            if w < r[1] then return string.format(" → %dw: %s", r[1], r[2]) end
        end
        return " ✅ Hoàn tất!"
    end

    t:AddButton({ Title = "+1 Win", Callback = function()
        winCount = winCount + 1
        winLabel:SetContent(winCount.."wins"..nextR(winCount))
    end})
    t:AddButton({ Title = "Reset Wins", Callback = function()
        winCount = 0; winLabel:SetContent("0 wins")
    end})
    t:AddButton({ Title = "+2500 Trophies", Callback = function()
        trophyCount = trophyCount + 2500
        trphLabel:SetContent(string.format("%d  |  ~%d Nitro Mutation", trophyCount, math.floor(trophyCount/475)))
    end})

    t:AddSection({ Name = "ℹ️ Hướng dẫn" })
    t:AddParagraph({ Title = "Cách chơi", Content = "1. Chờ Race Portal mở (30 phút)\n2. Vào portal → race\n3. Về nhất → Trophy + Win\n4. Dùng Trophies đổi Nitro Mutation" })
end

-- ═══════════════════════════════════════════════════════════
--  TAB 5: BUTTERFLY BLOOM
-- ═══════════════════════════════════════════════════════════
do
    local t = Tabs.Butterfly

    t:AddSection({ Name = "🦋 Butterfly Bloom" })
    t:AddParagraph({
        Title   = "Cơ chế",
        Content = "• Khu vực: Enchanted Forest\n• Lấy Butterfly Net trong Enchanted Tree\n• Bắt bướm → đổi Enchanted Mutation (100%)"
    })

    t:AddSection({ Name = "📍 Định vị" })
    local areaLabel = t:AddParagraph({ Title = "Enchanted Tree", Content = "Nhấn Tìm" })

    t:AddButton({
        Title    = "Tìm Enchanted Tree",
        Callback = function()
            local found = {}
            pcall(function()
                for _, obj in ipairs(workspace:GetDescendants()) do
                    local n = obj.Name:lower()
                    if n:find("enchant") or n:find("butterfly") or n:find("bloom") then
                        table.insert(found, obj.Name.." ("..obj.ClassName..")")
                        if #found >= 10 then break end
                    end
                end
            end)
            areaLabel:SetContent(#found > 0 and table.concat(found,"\n") or "Không tìm thấy — event chưa active?")
        end
    })

    t:AddSection({ Name = "🦋 Đếm bướm" })
    local bc = 0
    local bl = t:AddParagraph({ Title = "Bướm đã bắt", Content = "0" })
    t:AddButton({ Title = "+1 Butterfly", Callback = function() bc=bc+1; bl:SetContent(bc.." bướm") end })
    t:AddButton({ Title = "Reset",        Callback = function() bc=0;    bl:SetContent("0") end })

    t:AddSection({ Name = "ℹ️ Hướng dẫn" })
    t:AddParagraph({ Title = "Cách chơi", Content = "1. Đến Enchanted Forest\n2. Vào Enchanted Tree → lấy Net\n3. Bắt bướm → đổi Enchanted Mutation (100%)" })
end

-- ═══════════════════════════════════════════════════════════
--  TAB 6: SERVER HOP
-- ═══════════════════════════════════════════════════════════
do
    local t        = Tabs.Server
    local PLACE_ID = game.PlaceId

    t:AddSection({ Name = "🌐 Server Hop" })
    local srvStatus = t:AddParagraph({ Title = "Trạng thái", Content = "Chưa bắt đầu" })

    local minP = 3
    t:AddSlider("MinPlayersSlider", {
        Title = "Vào server ≤ N người", Min=1, Max=10, Default=3, Rounding=0,
        Callback = function(v) minP = v end
    })

    local function getServerList(cursor)
        local url = string.format(
            "https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100%s",
            PLACE_ID, cursor and ("&cursor="..cursor) or ""
        )
        local ok, res = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(url, true))
        end)
        return ok and res or nil
    end

    local function findServer()
        srvStatus:SetContent("Đang quét...")
        local cursor, tries, fb = nil, 0, nil
        repeat
            local data = getServerList(cursor)
            if not data or not data.data then break end
            if not fb then fb = data.data end
            for _, s in ipairs(data.data) do
                if (s.playing or 0) <= minP and s.id ~= game.JobId then
                    return s.id, s.playing or 0
                end
            end
            cursor = data.nextPageCursor; tries = tries + 1
            task.wait(0.5)
        until not cursor or tries > 5
        -- fallback: server ít người nhất
        if fb and #fb > 0 then
            table.sort(fb, function(a,b) return (a.playing or 0) < (b.playing or 0) end)
            for _, s in ipairs(fb) do
                if s.id ~= game.JobId then return s.id, s.playing or 0 end
            end
        end
        return nil
    end

    local function doHop()
        task.spawn(function()
            local jobId, count = findServer()
            if jobId then
                srvStatus:SetContent(string.format("Tìm thấy: %d người — teleport...", count))
                Fluent:Notify({ Title = "Server Hop", Content = count.." người", Duration = 3 })
                task.wait(1.5)
                -- Guard: wrap teleport để tránh bị kick
                local ok, err = pcall(function()
                    TeleportService:TeleportToPlaceInstance(PLACE_ID, jobId, player)
                end)
                if not ok then
                    srvStatus:SetContent("Teleport lỗi: "..(err or "unknown"))
                    Fluent:Notify({ Title = "Lỗi Hop", Content = tostring(err):sub(1,60), Duration = 4 })
                end
            else
                srvStatus:SetContent("Không tìm được server phù hợp")
                Fluent:Notify({ Title = "Server Hop", Content = "Không tìm được!", Duration = 3 })
            end
        end)
    end

    t:AddButton({ Title = "🔍 Server Hop ngay", Desc = "Tìm server ít người và nhảy vào", Callback = doHop })

    t:AddSection({ Name = "🔄 Auto Hop" })
    local hopActive = false
    local hopThresh = 10
    t:AddSlider("AutoHopThresholdSlider", {
        Title = "Hop khi > N người", Min=2, Max=50, Default=10, Rounding=0,
        Callback = function(v) hopThresh = v end
    })
    t:AddToggle("AutoHopToggle", {
        Title = "Bật Auto Hop", Default = false,
        Callback = function(val)
            hopActive = val
            if val then
                task.spawn(function()
                    while hopActive do
                        task.wait(15)
                        if not hopActive then break end
                        pcall(function()
                            local cur = #Players:GetPlayers()
                            if cur > hopThresh then doHop()
                            else srvStatus:SetContent(string.format("OK — %d người", cur)) end
                        end)
                    end
                end)
            end
        end
    })

    t:AddSection({ Name = "📊 Server hiện tại" })
    local srvInfo = t:AddParagraph({ Title = "JobId", Content = "Nhấn làm mới" })
    t:AddButton({
        Title = "Làm mới & Copy JobId",
        Callback = function()
            pcall(function()
                local jid = game.JobId
                srvInfo:SetContent(string.format("JobId: %s\nSố người: %d", jid, #Players:GetPlayers()))
                copyToClipboard(jid)
                Fluent:Notify({ Title = "Server", Content = "Đã copy JobId!", Duration = 2 })
            end)
        end
    })
end

-- ═══════════════════════════════════════════════════════════
--  TAB 7: MOVEMENT
-- ═══════════════════════════════════════════════════════════
do
    local t = Tabs.Movement

    t:AddSection({ Name = "🏃 Di chuyển" })
    t:AddParagraph({ Title = "Lưu ý", Content = "Client-side. Server có thể reset." })

    t:AddSlider("WalkSpeedSlider", {
        Title="WalkSpeed", Min=1, Max=350, Default=16, Rounding=0,
        Callback = function(v)
            pcall(function()
                local h = character and character:FindFirstChildOfClass("Humanoid")
                if h then h.WalkSpeed = v end
            end)
        end
    })
    t:AddSlider("JumpPowerSlider", {
        Title="JumpPower", Min=1, Max=500, Default=50, Rounding=0,
        Callback = function(v)
            pcall(function()
                local h = character and character:FindFirstChildOfClass("Humanoid")
                if h then h.JumpPower = v; h.UseJumpPower = true end
            end)
        end
    })

    t:AddSection({ Name = "🔧 Extra" })

    local ncConn
    t:AddToggle("NoclipToggle", {
        Title="NoClip", Default=false,
        Callback = function(val)
            if val then
                ncConn = RunService.Stepped:Connect(function()
                    pcall(function()
                        for _, p in ipairs(character:GetDescendants()) do
                            if p:IsA("BasePart") then p.CanCollide = false end
                        end
                    end)
                end)
            else
                if ncConn then ncConn:Disconnect(); ncConn = nil end
                pcall(function()
                    for _, p in ipairs(character:GetDescendants()) do
                        if p:IsA("BasePart") then p.CanCollide = true end
                    end
                end)
            end
        end
    })

    local ijConn
    t:AddToggle("InfJumpToggle", {
        Title="Infinite Jump", Default=false,
        Callback = function(val)
            if val then
                ijConn = UserInputService.JumpRequest:Connect(function()
                    pcall(function()
                        local h = character and character:FindFirstChildOfClass("Humanoid")
                        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
                    end)
                end)
            else
                if ijConn then ijConn:Disconnect(); ijConn = nil end
            end
        end
    })

    t:AddButton({
        Title="Reset Speed",
        Callback = function()
            pcall(function()
                local h = character and character:FindFirstChildOfClass("Humanoid")
                if h then h.WalkSpeed=16; h.JumpPower=50 end
            end)
            Fluent:Notify({ Title="Movement", Content="Reset!", Duration=2 })
        end
    })
end

-- ═══════════════════════════════════════════════════════════
--  TAB 8: SETTINGS
-- ═══════════════════════════════════════════════════════════
do
    local t = Tabs.Settings

    t:AddSection({ Name = "⚙️ Giao diện" })
    t:AddToggle("AcrylicToggle", {
        Title="Acrylic", Default=true,
        Callback = function(v) pcall(function() Window:SetAcrylic(v) end) end
    })

    t:AddSection({ Name = "💾 Lưu cài đặt" })
    SaveManager:SetLibrary(Fluent)
    InterfaceManager:SetLibrary(Fluent)
    InterfaceManager:BuildInterfaceSection(t)
    SaveManager:BuildConfigSection(t)

    t:AddSection({ Name = "💬 Discord" })
    t:AddParagraph({ Title = "Server", Content = "discord.gg/hzkP9m6h87" })
    t:AddButton({
        Title="📋 Copy Discord",
        Callback = function()
            copyToClipboard("https://discord.gg/hzkP9m6h87")
            Fluent:Notify({ Title="Discord", Content="Đã copy!", Duration=3 })
        end
    })

    t:AddSection({ Name = "ℹ️" })
    t:AddParagraph({ Title="Ninja Hub v1.3", Content="Steal An Egg | Nitro Race | Butterfly Bloom\n⚠ Chỉ dùng cá nhân" })

    t:AddButton({
        Title="Đặt lại UI",
        Callback = function()
            pcall(function() SaveManager:ResetToDefaults() end)
            Fluent:Notify({ Title="Settings", Content="Đã đặt lại!", Duration=2 })
        end
    })
end

-- ── LƯU CONFIG ─────────────────────────────────────────────
SaveManager:SetFolder("NinjaHub")
SaveManager:SetIgnoreIndexes({
    "NoclipToggle","InfJumpToggle",
    "AutoStealToggle","AutoStealPetToggle","AutoHopToggle","NitroTimer"
})
SaveManager:LoadAutoloadConfig()

-- Chọn tab Home
Window:SelectTab(1)

-- ── KEYBINDS ───────────────────────────────────────────────
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F5 then
        pcall(function()
            if moneyLabel then moneyLabel:SetContent(getMoney()) end
            if speedLabel  then speedLabel:SetContent(getSpeed()) end
        end)
        Fluent:Notify({ Title="Ninja Hub", Content="Stats làm mới!", Duration=2 })

    elseif input.KeyCode == Enum.KeyCode.F6 then
        AutoSteal.Active = not AutoSteal.Active
        Fluent:Notify({ Title="Auto Steal", Content=AutoSteal.Active and "Bật!" or "Tắt!", Duration=2 })
        if AutoSteal.Active then task.spawn(stealLoop) end

    elseif input.KeyCode == Enum.KeyCode.F7 then
        Fluent:Notify({ Title="Server Hop", Content="Đang tìm...", Duration=2 })
        task.spawn(function()
            local ok, data = pcall(function()
                return HttpService:JSONDecode(
                    game:HttpGet(string.format(
                        "https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=20",
                        game.PlaceId), true))
            end)
            if ok and data and data.data and #data.data > 0 then
                table.sort(data.data, function(a,b) return (a.playing or 99)<(b.playing or 99) end)
                for _, s in ipairs(data.data) do
                    if s.id ~= game.JobId then
                        pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, player) end)
                        break
                    end
                end
            end
        end)

    elseif input.KeyCode == Enum.KeyCode.Delete then
        pcall(function()
            local g = CoreGui:FindFirstChild("NinjaHubFloatingUI")
            if g then g:Destroy() end
        end)
    end
end)

-- ═══════════════════════════════════════════════════════════
--  NÚT NỔI — thử gethui → CoreGui → PlayerGui
-- ═══════════════════════════════════════════════════════════
local floatParent = nil

-- Thử từng parent theo thứ tự ưu tiên
local parentCandidates = {}
pcall(function() if gethui and gethui() then table.insert(parentCandidates, gethui()) end end)
table.insert(parentCandidates, CoreGui)
pcall(function() table.insert(parentCandidates, player:WaitForChild("PlayerGui", 3)) end)

for _, p in ipairs(parentCandidates) do
    local ok = pcall(function()
        local test = Instance.new("Frame")
        test.Parent = p
        test:Destroy()
    end)
    if ok then floatParent = p; break end
end
floatParent = floatParent or parentCandidates[#parentCandidates]

-- Xóa GUI cũ
pcall(function()
    local old = floatParent:FindFirstChild("NinjaHubFloatingUI")
    if old then old:Destroy() end
end)

local floatGui = Instance.new("ScreenGui")
floatGui.Name           = "NinjaHubFloatingUI"
floatGui.ResetOnSpawn   = false
floatGui.IgnoreGuiInset = true
floatGui.DisplayOrder   = 9999
floatGui.Parent         = floatParent

-- Nút chính
local toggleBtn = Instance.new("ImageButton")
toggleBtn.Size             = UDim2.fromOffset(72, 72)
toggleBtn.Position         = UDim2.new(0.04, 0, 0.22, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
toggleBtn.BorderSizePixel  = 0
toggleBtn.AutoButtonColor  = true
toggleBtn.Image            = "rbxassetid://6031068421"
toggleBtn.ScaleType        = Enum.ScaleType.Fit
toggleBtn.Parent           = floatGui
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0,16)
local stroke = Instance.new("UIStroke", toggleBtn)
stroke.Color = Color3.fromRGB(120,60,220); stroke.Thickness = 2

-- Nút đóng X
local closeBtn = Instance.new("TextButton")
closeBtn.Size             = UDim2.fromOffset(22, 22)
closeBtn.Position         = UDim2.new(1,-6, 0,-6)
closeBtn.AnchorPoint      = Vector2.new(1,0)
closeBtn.BackgroundColor3 = Color3.fromRGB(200,40,60)
closeBtn.Text             = "✕"
closeBtn.TextColor3       = Color3.fromRGB(255,255,255)
closeBtn.TextSize         = 13
closeBtn.Font             = Enum.Font.GothamBold
closeBtn.BorderSizePixel  = 0
closeBtn.Parent           = toggleBtn
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,11)

-- Drag
local dragging, moved, dragStart, startPos, dragInp = false, false, nil, nil, nil

toggleBtn.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1
    or inp.UserInputType == Enum.UserInputType.Touch then
        dragging=true; moved=false
        dragStart=inp.Position; startPos=toggleBtn.Position; dragInp=inp
    end
end)
toggleBtn.InputChanged:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseMovement
    or inp.UserInputType == Enum.UserInputType.Touch then dragInp=inp end
end)
UserInputService.InputChanged:Connect(function(inp)
    if not dragging or inp ~= dragInp then return end
    local d = inp.Position - dragStart
    if math.abs(d.X)>5 or math.abs(d.Y)>5 then moved=true end
    toggleBtn.Position = UDim2.new(
        startPos.X.Scale, startPos.X.Offset + d.X,
        startPos.Y.Scale, startPos.Y.Offset + d.Y
    )
end)
UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1
    or inp.UserInputType==Enum.UserInputType.Touch then dragging=false end
end)

-- Toggle UI khi click nút nổi
local uiVisible = true
toggleBtn.Activated:Connect(function()
    if moved then moved=false; return end
    uiVisible = not uiVisible
    -- Thử các API khác nhau của Fluent/FluentPlus
    pcall(function()
        if Window.ToggleMinimize then Window:ToggleMinimize()
        elseif Window.Toggle then Window:Toggle()
        elseif Window.Minimize then Window:Minimize()
        elseif Window.MainFrame then
            Window.MainFrame.Visible = uiVisible
        end
    end)
end)

-- Nút X đóng hoàn toàn
closeBtn.MouseButton1Click:Connect(function()
    -- Dừng tất cả chức năng tự động
    AutoSteal.Active = false
    task.wait(0.3)
    -- Destroy float GUI
    pcall(function() floatGui:Destroy() end)
    -- Destroy Fluent window
    pcall(function()
        if Window.Destroy then Window:Destroy()
        elseif Window.MainFrame then Window.MainFrame:Destroy()
        end
    end)
    -- Quét và destroy mọi GUI còn lại của hub
    for _, gui in ipairs({CoreGui, player:FindFirstChild("PlayerGui")}) do
        if gui then
            pcall(function()
                for _, g in ipairs(gui:GetChildren()) do
                    local n = g.Name:lower()
                    if n:find("fluent") or n:find("ninja") then g:Destroy() end
                end
            end)
        end
    end
end)

-- ── THÔNG BÁO ──────────────────────────────────────────────
Fluent:Notify({
    Title    = "🥷 Ninja Hub v1.3",
    Content  = "Đã tải! Steal An Egg ready.",
    Duration = 4
})
