-- ============================================================
--  NINJA HUB v1.0 — Steal An Egg
--  UI: FluentPlus | Events: Nitro Race + Butterfly Bloom
--  Môi trường: LocalScript qua Executor (Synapse / KRNL / Fluxus)
-- ============================================================

-- ── LOAD THƯ VIỆN ──────────────────────────────────────────
local Fluent         = loadstring(game:HttpGet("https://raw.githubusercontent.com/discoart/FluentPlus/refs/heads/main/release.lua"))()
local SaveManager    = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- ── SERVICES ───────────────────────────────────────────────
local Players        = game:GetService("Players")
local CoreGui        = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService     = game:GetService("RunService")
local TweenService   = game:GetService("TweenService")

local player         = Players.LocalPlayer
local character      = player.Character or player.CharacterAdded:Wait()
local humanoid       = character:FindFirstChildOfClass("Humanoid")

-- Cập nhật character khi respawn
player.CharacterAdded:Connect(function(char)
    character = char
    humanoid  = char:FindFirstChildOfClass("Humanoid")
end)

-- ── HÀM TIỆN ÍCH ───────────────────────────────────────────
local function safeGet(root, path)
    -- Traverse Instance path an toàn, trả nil nếu bất kỳ bước nào fail
    local cur = root
    for _, name in ipairs(path) do
        if cur == nil then return nil end
        cur = cur:FindFirstChild(name)
    end
    return cur
end

local function readStat(statName)
    -- Cố đọc leaderstats; trả "N/A" nếu không tìm thấy
    local ls = safeGet(player, {"leaderstats"})
    if not ls then return "N/A" end
    local v = ls:FindFirstChild(statName)
    return v and tostring(v.Value) or "N/A"
end

local function getSpeed()
    -- Speed trong Steal An Egg thường lưu trong leaderstats hoặc PlayerData
    -- Thử nhiều path phổ biến
    local ls = safeGet(player, {"leaderstats"})
    if ls then
        for _, name in ipairs({"Speed","SPD","Spd","speed"}) do
            local v = ls:FindFirstChild(name)
            if v then return tostring(v.Value) end
        end
    end
    -- Fallback: WalkSpeed của humanoid
    if humanoid then
        return string.format("%.1f (WalkSpeed)", humanoid.WalkSpeed)
    end
    return "N/A"
end

local function getMoney()
    for _, name in ipairs({"Cash","Money","Coins","Gems","Gold","cash","money"}) do
        local v = readStat(name)
        if v ~= "N/A" then return name..": "..v end
    end
    return "N/A"
end

-- ── CỬA SỔ CHÍNH ───────────────────────────────────────────
local Window = Fluent:CreateWindow({
    Title              = "Ninja Hub",
    SubTitle           = "Steal An Egg  •  v1.0",
    TitleIcon          = "https://raw.githubusercontent.com/hoang-VN1/Tets/refs/heads/main/2374e4b898e74c1ff0183cbad39987bb.webp",
    Image              = "https://raw.githubusercontent.com/hoang-VN1/Tets/refs/heads/main/2374e4b898e74c1ff0183cbad39987bb.webp",
    DropdownsOutsideWindow = true,
    Size               = UDim2.fromOffset(500, 370),
    TabWidth           = 160,
    Acrylic            = true,
    Theme              = "Dark",
    Search             = true,
    MinimizeKey        = Enum.KeyCode.LeftControl,
    UserInfo           = false,
})

-- ── TABS ────────────────────────────────────────────────────
local Tabs = {
    Home     = Window:AddTab({ Title = "Home",           Icon = "home"         }),
    Eggs     = Window:AddTab({ Title = "Eggs",           Icon = "egg"          }),
    Pets     = Window:AddTab({ Title = "Pets",           Icon = "paw-print"    }),
    Nitro    = Window:AddTab({ Title = "Nitro Race",     Icon = "zap"          }),
    Butterfly= Window:AddTab({ Title = "Butterfly",      Icon = "flower-2"     }),
    Movement = Window:AddTab({ Title = "Movement",       Icon = "move"         }),
    Settings = Window:AddTab({ Title = "Settings",       Icon = "settings"     }),
}

-- ═══════════════════════════════════════════════════════════
--  TAB 1: HOME
-- ═══════════════════════════════════════════════════════════
do
    local t = Tabs.Home

    t:AddSection({ Name = "⚡ Ninja Hub — Trạng thái" })

    local statusLabel = t:AddParagraph({
        Title = "Trạng thái",
        Content = "Đang tải dữ liệu nhân vật..."
    })

    local moneyLabel = t:AddParagraph({
        Title = "Tiền tệ",
        Content = getMoney()
    })

    local speedLabel = t:AddParagraph({
        Title = "Speed",
        Content = getSpeed()
    })

    -- Refresh stats mỗi 3 giây
    local refreshConn
    local refreshing = true
    refreshConn = RunService.Heartbeat:Connect(function()
        -- Throttle ~3s
        task.wait(3)
        if not refreshing then return end
        pcall(function()
            moneyLabel:SetContent(getMoney())
            speedLabel:SetContent(getSpeed())
            local hum = character and character:FindFirstChildOfClass("Humanoid")
            if hum then
                statusLabel:SetContent(string.format(
                    "Nhân vật: %s  |  HP: %.0f/%.0f",
                    player.Name, hum.Health, hum.MaxHealth
                ))
            else
                statusLabel:SetContent("Nhân vật chưa sẵn sàng")
            end
        end)
    end)

    t:AddSection({ Name = "🔧 Hub" })

    t:AddButton({
        Title   = "Làm mới thông số",
        Desc    = "Cập nhật tiền, speed và HP ngay lập tức",
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
        Content = "Ninja Hub v1.0 | Steal An Egg\nEvent: Nitro Race + Butterfly Bloom\nTác giả: hoang"
    })
end

-- ═══════════════════════════════════════════════════════════
--  AUTO STEAL ENGINE
-- ═══════════════════════════════════════════════════════════
local AutoSteal = {}
AutoSteal.Active    = false
AutoSteal.FlySpeed  = 120          -- tốc độ bay tới trứng
AutoSteal.SafePos   = nil          -- set khi bấm "Lưu base"
AutoSteal.Conn      = nil
AutoSteal.Status    = "Chờ..."

-- Tên trứng xịn cần stealerino — chỉnh lại sau khi xác minh trong game
AutoSteal.TargetNames = {
    "RiftEgg", "Rift Egg",
    "ExtinctionEgg", "Extinction Egg",
    "LuminousEgg", "Luminous Egg",
    "ExperimentEgg", "Experiment #001 Egg", "Experiment #013 Egg",
    -- Thêm tên thật sau khi quét workspace
}

local function isTargetEgg(name)
    local low = name:lower()
    for _, t in ipairs(AutoSteal.TargetNames) do
        if low == t:lower() then return true end
    end
    -- Fallback: bất kỳ object có "egg" trong tên (bật khi cần)
    if AutoSteal.CatchAll then
        return low:find("egg") ~= nil
    end
    return false
end
AutoSteal.CatchAll = false

local function findNearestEgg()
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local best, bestDist = nil, math.huge
    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") or obj:IsA("Model") then
                local name = obj.Name
                if isTargetEgg(name) then
                    local pos = obj:IsA("Model")
                        and (obj.PrimaryPart and obj.PrimaryPart.Position or obj:GetModelCFrame().Position)
                        or obj.Position
                    local d = (pos - root.Position).Magnitude
                    if d < bestDist then
                        best     = obj
                        bestDist = d
                    end
                end
            end
        end
    end)
    return best, bestDist
end

local function getEggPosition(egg)
    if egg:IsA("Model") then
        return egg.PrimaryPart and egg.PrimaryPart.Position
            or egg:GetModelCFrame().Position
    end
    return egg.Position
end

local function flyTo(targetPos, onDone)
    -- Teleport liên tiếp về phía target với FlySpeed
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then if onDone then onDone(false) end return end

    local stepConn
    local arrived = false
    stepConn = RunService.Heartbeat:Connect(function(dt)
        pcall(function()
            local r2 = character and character:FindFirstChild("HumanoidRootPart")
            if not r2 then stepConn:Disconnect(); if onDone then onDone(false) end; return end
            local diff = targetPos - r2.Position
            local dist = diff.Magnitude
            if dist < 3 then
                arrived = true
                stepConn:Disconnect()
                if onDone then onDone(true) end
                return
            end
            local step = math.min(AutoSteal.FlySpeed * dt, dist)
            local newPos = r2.Position + diff.Unit * step
            r2.CFrame = CFrame.new(newPos, newPos + diff.Unit)
        end)
    end)
    -- Timeout 8 giây
    task.delay(8, function()
        if not arrived then
            pcall(function() stepConn:Disconnect() end)
            if onDone then onDone(false) end
        end
    end)
end

local function returnToSafe(onDone)
    if AutoSteal.SafePos then
        flyTo(AutoSteal.SafePos, onDone)
    else
        -- Không có safe pos → đứng yên
        if onDone then onDone(true) end
    end
end

local stealLabel -- forward ref, gán sau khi tạo UI

local function stealLoop()
    while AutoSteal.Active do
        pcall(function()
            local egg, dist = findNearestEgg()
            if egg then
                local ePos = getEggPosition(egg)
                AutoSteal.Status = string.format("Bay tới: %s (%.0fm)", egg.Name, dist)
                if stealLabel then stealLabel:SetContent(AutoSteal.Status) end

                flyTo(ePos, function(ok)
                    if not ok then
                        AutoSteal.Status = "Không tới được — bỏ qua"
                        if stealLabel then stealLabel:SetContent(AutoSteal.Status) end
                        return
                    end
                    -- Thử touch/click pickup (cần xác minh cách game trigger)
                    pcall(function()
                        -- Cách 1: ClickDetector
                        local cd = egg:FindFirstChildOfClass("ClickDetector")
                            or egg:FindFirstDescendant and egg:FindFirstDescendant("ClickDetector")
                        if cd then
                            fireclickdetector(cd)
                        end
                        -- Cách 2: ProximityPrompt
                        local pp = egg:FindFirstChildOfClass("ProximityPrompt")
                            or (egg:FindFirstDescendant and egg:FindFirstDescendant("ProximityPrompt"))
                        if pp then
                            fireproximityprompt(pp)
                        end
                    end)
                    AutoSteal.Status = "Đã cướp! Bay về base..."
                    if stealLabel then stealLabel:SetContent(AutoSteal.Status) end

                    returnToSafe(function()
                        AutoSteal.Status = "Về base xong. Tìm trứng tiếp..."
                        if stealLabel then stealLabel:SetContent(AutoSteal.Status) end
                    end)
                end)
            else
                AutoSteal.Status = "Không có trứng xịn — đang quét..."
                if stealLabel then stealLabel:SetContent(AutoSteal.Status) end
            end
        end)
        task.wait(2) -- quét lại mỗi 2 giây
    end
    AutoSteal.Status = "Đã dừng"
    if stealLabel then stealLabel:SetContent(AutoSteal.Status) end
end

-- ═══════════════════════════════════════════════════════════
--  TAB 2: EGGS
-- ═══════════════════════════════════════════════════════════
do
    local t = Tabs.Eggs

    t:AddSection({ Name = "🥚 Trứng" })

    t:AddParagraph({
        Title   = "Lưu ý",
        Content = "Dữ liệu trứng phụ thuộc vào cấu trúc Instance game.\nNinja Hub sẽ hiển thị khi đọc được từ workspace."
    })

    -- Thử đọc trứng từ workspace
    local eggInfoLabel = t:AddParagraph({
        Title   = "Trứng trong tay",
        Content = "Đang kiểm tra..."
    })

    local function scanEggs()
        -- Steal An Egg thường để egg objects trong character hoặc một Folder riêng
        -- Đây là scan heuristic; cần xác minh thực tế trong game
        local found = {}
        pcall(function()
            -- Thử tìm trong character
            if character then
                for _, obj in ipairs(character:GetChildren()) do
                    if obj.Name:lower():find("egg") then
                        table.insert(found, obj.Name)
                    end
                end
            end
            -- Thử tìm trong Backpack
            local bp = player:FindFirstChild("Backpack")
            if bp then
                for _, obj in ipairs(bp:GetChildren()) do
                    if obj.Name:lower():find("egg") then
                        table.insert(found, obj.Name)
                    end
                end
            end
        end)
        if #found > 0 then
            return table.concat(found, "\n")
        end
        return "Không tìm thấy trứng\n(chưa xác minh path Instance)"
    end

    eggInfoLabel:SetContent(scanEggs())

    t:AddButton({
        Title    = "Quét trứng",
        Desc     = "Tìm trứng trong character và Backpack",
        Callback = function()
            eggInfoLabel:SetContent(scanEggs())
            Fluent:Notify({ Title = "Eggs", Content = "Đã quét!", Duration = 2 })
        end
    })

    -- ── AUTO STEAL UI ─────────────────────────────────────
    t:AddSection({ Name = "🥷 Auto Steal Eggs" })

    stealLabel = t:AddParagraph({
        Title   = "Trạng thái",
        Content = "Chờ bật..."
    })

    t:AddToggle("AutoStealToggle", {
        Title   = "Bật Auto Steal",
        Desc    = "Tự bay tới trứng xịn và cướp về base",
        Default = false,
        Callback = function(val)
            AutoSteal.Active = val
            if val then
                Fluent:Notify({ Title = "Auto Steal", Content = "Đã bật! Đang tìm trứng...", Duration = 3 })
                task.spawn(stealLoop)
            else
                Fluent:Notify({ Title = "Auto Steal", Content = "Đã tắt.", Duration = 2 })
            end
        end
    })

    t:AddSlider("FlySpeedSlider", {
        Title    = "Tốc độ bay",
        Desc     = "Studs/giây khi bay tới trứng",
        Min      = 20,
        Max      = 500,
        Default  = 120,
        Rounding = 0,
        Callback = function(val)
            AutoSteal.FlySpeed = val
        end
    })

    t:AddToggle("CatchAllToggle", {
        Title   = "Bắt mọi trứng",
        Desc    = "Bật = cướp tất cả trứng trong workspace (không lọc loại)",
        Default = false,
        Callback = function(val)
            AutoSteal.CatchAll = val
        end
    })

    t:AddButton({
        Title    = "📍 Lưu vị trí base",
        Desc     = "Ghi nhớ chỗ đứng hiện tại làm điểm trở về",
        Callback = function()
            local root = character and character:FindFirstChild("HumanoidRootPart")
            if root then
                AutoSteal.SafePos = root.Position
                Fluent:Notify({
                    Title   = "Base đã lưu",
                    Content = string.format("X:%.0f Y:%.0f Z:%.0f", root.Position.X, root.Position.Y, root.Position.Z),
                    Duration = 3
                })
                stealLabel:SetContent("Base đã lưu ✅")
            else
                Fluent:Notify({ Title = "Lỗi", Content = "Không tìm thấy nhân vật!", Duration = 3 })
            end
        end
    })

    t:AddButton({
        Title    = "🔍 Quét & hiện tên trứng",
        Desc     = "Liệt kê object có 'egg' trong workspace (copy để điền đúng tên)",
        Callback = function()
            local found = {}
            pcall(function()
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj.Name:lower():find("egg") then
                        local key = obj.Name .. " [" .. obj.ClassName .. "]"
                        if not table.find(found, key) then
                            table.insert(found, key)
                        end
                        if #found >= 15 then break end
                    end
                end
            end)
            local txt = #found > 0
                and table.concat(found, "\n")
                or "Không tìm thấy — trứng chưa spawn?"
            stealLabel:SetContent("Eggs tìm thấy:\n" .. txt)
        end
    })

    t:AddSection({ Name = "📋 Danh sách trứng (đã xác minh)" })

    t:AddParagraph({
        Title   = "Các loại trứng trong game",
        Content = "• Extinction Egg (Paid)\n• Luminous Egg (Store)\n• Rift Egg (Boss Event)\n• Experiment #001 Egg\n• Experiment #013 Egg\n• Cherry Blossom Egg\n\n⚠ Danh sách từ Update Log — chưa xác minh tên Instance thực tế"
    })
end

-- ═══════════════════════════════════════════════════════════
--  TAB 3: PETS
-- ═══════════════════════════════════════════════════════════
do
    local t = Tabs.Pets

    t:AddSection({ Name = "🐾 Thú cưng" })

    t:AddParagraph({
        Title   = "Lưu ý",
        Content = "Dữ liệu pet đọc từ PlayerData hoặc leaderstats.\nHiển thị khi game expose thông tin."
    })

    local petLabel = t:AddParagraph({
        Title   = "Pets đang hoạt động",
        Content = "Đang kiểm tra..."
    })

    local function scanPets()
        local found = {}
        pcall(function()
            -- Thử scan PlayerGui hoặc PlayerData
            local pd = player:FindFirstChild("PlayerData") or player:FindFirstChild("Data")
            if pd then
                local pets = pd:FindFirstChild("Pets") or pd:FindFirstChild("pets")
                if pets then
                    for _, p in ipairs(pets:GetChildren()) do
                        table.insert(found, p.Name)
                    end
                end
            end
        end)
        if #found > 0 then
            return table.concat(found, "\n")
        end
        return "Không đọc được pet data\n(path Instance chưa được xác minh)"
    end

    petLabel:SetContent(scanPets())

    t:AddButton({
        Title    = "Làm mới pets",
        Desc     = "Quét lại danh sách pet",
        Callback = function()
            petLabel:SetContent(scanPets())
            Fluent:Notify({ Title = "Pets", Content = "Đã làm mới!", Duration = 2 })
        end
    })

    t:AddSection({ Name = "🏆 Win Pass Pets (Nitro Race)" })

    t:AddParagraph({
        Title   = "Phần thưởng Win Pass",
        Content = "1 win   → Seahorse Racer\n5 wins  → Lizard Racer\n15 wins → Bird Racer\n21 wins → Cheetah Racer\n30 wins → Snail Racer\n\n✅ Đã xác minh từ Update 8 patch notes"
    })
end

-- ═══════════════════════════════════════════════════════════
--  TAB 4: NITRO RACE
-- ═══════════════════════════════════════════════════════════
do
    local t = Tabs.Nitro

    t:AddSection({ Name = "🏎️ Nitro Race — Thông tin sự kiện" })

    t:AddParagraph({
        Title   = "Cơ chế (đã xác minh)",
        Content = "• Race bắt đầu mỗi 30 phút\n• Thắng nhất: +1 Win, +2,500 Trophies\n• Trophies đổi lấy: Boosters, Nitro Mutation (475T, 10%)\n• Win Pass: 5 pet độc quyền\n• Mounts: dùng Shooting Star để biến pet thành mount"
    })

    -- Đồng hồ đếm ngược 30 phút
    t:AddSection({ Name = "⏱ Đồng hồ đếm ngược" })

    local timerLabel = t:AddParagraph({
        Title   = "Race tiếp theo",
        Content = "Nhấn bắt đầu để theo dõi"
    })

    local timerActive = false
    local timerStart  = 0
    local RACE_INTERVAL = 30 * 60 -- 30 phút

    t:AddToggle("NitroTimer", {
        Title   = "Bật đồng hồ đếm ngược",
        Desc    = "Tính từ lúc bật — không đồng bộ với server",
        Default = false,
        Callback = function(val)
            timerActive = val
            if val then
                timerStart = tick()
                Fluent:Notify({ Title = "Nitro Race", Content = "Bắt đầu đếm 30 phút!", Duration = 3 })
            else
                timerLabel:SetContent("Đã tắt")
            end
        end
    })

    -- Cập nhật timer
    RunService.Heartbeat:Connect(function()
        if not timerActive then return end
        task.wait(1)
        pcall(function()
            local elapsed = tick() - timerStart
            local remaining = RACE_INTERVAL - (elapsed % RACE_INTERVAL)
            local mins = math.floor(remaining / 60)
            local secs = math.floor(remaining % 60)
            timerLabel:SetContent(string.format("Race tiếp theo: %02d:%02d", mins, secs))
            if remaining <= 10 then
                Fluent:Notify({ Title = "🏎️ Nitro Race!", Content = "Race sắp bắt đầu!", Duration = 5 })
            end
        end)
    end)

    t:AddSection({ Name = "📊 Theo dõi tiến trình" })

    -- Counter số wins
    local winCount = 0
    local winLabel = t:AddParagraph({
        Title   = "Wins hiện tại",
        Content = "0 wins"
    })

    t:AddButton({
        Title    = "+1 Win",
        Desc     = "Ghi nhận một chiến thắng thủ công",
        Callback = function()
            winCount = winCount + 1
            local nextReward = ""
            if winCount < 1  then nextReward = " → 1 win: Seahorse Racer"
            elseif winCount < 5  then nextReward = " → 5 wins: Lizard Racer"
            elseif winCount < 15 then nextReward = " → 15 wins: Bird Racer"
            elseif winCount < 21 then nextReward = " → 21 wins: Cheetah Racer"
            elseif winCount < 30 then nextReward = " → 30 wins: Snail Racer"
            else nextReward = " ✅ Win Pass hoàn tất!" end
            winLabel:SetContent(string.format("%d wins%s", winCount, nextReward))
        end
    })

    t:AddButton({
        Title    = "Reset wins",
        Desc     = "Đặt lại bộ đếm về 0",
        Callback = function()
            winCount = 0
            winLabel:SetContent("0 wins")
        end
    })

    local trophyCount = 0
    local trophyLabel = t:AddParagraph({
        Title   = "Trophies tích lũy",
        Content = "0 Trophies"
    })

    t:AddButton({
        Title    = "+2500 Trophies (1 win)",
        Desc     = "Ghi nhận Trophy từ một chiến thắng",
        Callback = function()
            trophyCount = trophyCount + 2500
            local nitros = math.floor(trophyCount / 475)
            trophyLabel:SetContent(string.format(
                "%d Trophies  |  Đủ mua ~%d Nitro Mutation",
                trophyCount, nitros
            ))
        end
    })

    t:AddSection({ Name = "ℹ️ Hướng dẫn tham gia" })

    t:AddParagraph({
        Title   = "Cách chơi",
        Content = "1. Chờ Race Portal mở (mỗi 30 phút)\n2. Vào portal để tham gia race\n3. Tránh chướng ngại vật, về nhất\n4. Dùng Trophies đổi Nitro Mutation (10%)\n5. Win Pass mở khi đạt mốc 1/5/15/21/30 wins"
    })
end

-- ═══════════════════════════════════════════════════════════
--  TAB 5: BUTTERFLY BLOOM
-- ═══════════════════════════════════════════════════════════
do
    local t = Tabs.Butterfly

    t:AddSection({ Name = "🦋 Butterfly Bloom — Thông tin sự kiện" })

    t:AddParagraph({
        Title   = "Cơ chế (đã xác minh)",
        Content = "• Khu vực: Enchanted Forest / Enchanted Tree\n• Lấy Butterfly Net từ bên trong cây\n• Bắt bướm → đổi lấy Enchanted Mutation\n• Enchanted Mutation: 100% hoạt động\n\n⚠ Thời gian cooldown Butterfly Bloom chưa xác minh chính thức"
    })

    t:AddSection({ Name = "📍 Định vị khu vực" })

    local areaLabel = t:AddParagraph({
        Title   = "Enchanted Tree",
        Content = "Đang tìm trong workspace..."
    })

    t:AddButton({
        Title    = "Tìm Enchanted Tree",
        Desc     = "Quét workspace tìm khu vực Butterfly Bloom",
        Callback = function()
            local found = {}
            pcall(function()
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj.Name:lower():find("enchanted") or obj.Name:lower():find("butterfly") or obj.Name:lower():find("bloom") then
                        table.insert(found, string.format("%s (%s)", obj.Name, obj.ClassName))
                        if #found >= 8 then break end
                    end
                end
            end)
            if #found > 0 then
                areaLabel:SetContent("Tìm thấy:\n" .. table.concat(found, "\n"))
            else
                areaLabel:SetContent("Không tìm thấy Object liên quan\n(có thể event chưa active hoặc tên khác)")
            end
        end
    })

    t:AddSection({ Name = "🦋 Đếm bướm" })

    local butterflyCount = 0
    local butterflyLabel = t:AddParagraph({
        Title   = "Bướm đã bắt",
        Content = "0 bướm"
    })

    t:AddButton({
        Title    = "+1 Butterfly",
        Desc     = "Ghi nhận một con bướm đã bắt",
        Callback = function()
            butterflyCount = butterflyCount + 1
            butterflyLabel:SetContent(string.format("%d bướm đã bắt", butterflyCount))
        end
    })

    t:AddButton({
        Title    = "Reset đếm",
        Callback = function()
            butterflyCount = 0
            butterflyLabel:SetContent("0 bướm")
        end
    })

    t:AddSection({ Name = "ℹ️ Hướng dẫn" })

    t:AddParagraph({
        Title   = "Cách chơi",
        Content = "1. Đến khu vực Enchanted Forest\n2. Vào bên trong Enchanted Tree\n3. Lấy Butterfly Net\n4. Bắt bướm xuất hiện trong khu vực\n5. Đổi bướm lấy Enchanted Mutation (100%)\n\n⚠ Tỷ lệ xuất hiện bướm chưa được ghi nhận chính thức"
    })
end

-- ═══════════════════════════════════════════════════════════
--  TAB 6: MOVEMENT
-- ═══════════════════════════════════════════════════════════
do
    local t = Tabs.Movement

    t:AddSection({ Name = "🏃 Di chuyển" })

    t:AddParagraph({
        Title   = "Lưu ý",
        Content = "Thay đổi WalkSpeed/JumpPower là client-side.\nServer có thể reset. Không can thiệp anti-cheat."
    })

    -- WalkSpeed slider
    local currentWS = 16
    t:AddSlider("WalkSpeedSlider", {
        Title   = "WalkSpeed",
        Desc    = "Tốc độ di chuyển (mặc định: 16)",
        Min     = 1,
        Max     = 350,
        Default = 16,
        Rounding = 0,
        Callback = function(val)
            currentWS = val
            pcall(function()
                local hum = character and character:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = val end
            end)
        end
    })

    -- JumpPower slider
    t:AddSlider("JumpPowerSlider", {
        Title   = "JumpPower",
        Desc    = "Lực nhảy (mặc định: 50)",
        Min     = 1,
        Max     = 500,
        Default = 50,
        Rounding = 0,
        Callback = function(val)
            pcall(function()
                local hum = character and character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.JumpPower = val
                    hum.UseJumpPower = true
                end
            end)
        end
    })

    t:AddSection({ Name = "🔧 Công cụ" })

    -- NoClip (toggle)
    local noclipActive = false
    local noclipConn
    t:AddToggle("NoclipToggle", {
        Title   = "NoClip",
        Desc    = "Xuyên tường (client-side, có thể bị phát hiện)",
        Default = false,
        Callback = function(val)
            noclipActive = val
            if val then
                noclipConn = RunService.Stepped:Connect(function()
                    pcall(function()
                        if character then
                            for _, p in ipairs(character:GetDescendants()) do
                                if p:IsA("BasePart") then
                                    p.CanCollide = false
                                end
                            end
                        end
                    end)
                end)
            else
                if noclipConn then noclipConn:Disconnect() end
                pcall(function()
                    if character then
                        for _, p in ipairs(character:GetDescendants()) do
                            if p:IsA("BasePart") then
                                p.CanCollide = true
                            end
                        end
                    end
                end)
            end
        end
    })

    -- Infinite Jump
    local ijConn
    t:AddToggle("InfJumpToggle", {
        Title   = "Infinite Jump",
        Desc    = "Nhảy liên tục khi giữ phím nhảy",
        Default = false,
        Callback = function(val)
            if val then
                ijConn = UserInputService.JumpRequest:Connect(function()
                    pcall(function()
                        local hum = character and character:FindFirstChildOfClass("Humanoid")
                        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
                    end)
                end)
            else
                if ijConn then ijConn:Disconnect() end
            end
        end
    })

    t:AddButton({
        Title    = "Reset Speed",
        Desc     = "Đặt lại WalkSpeed và JumpPower về mặc định",
        Callback = function()
            pcall(function()
                local hum = character and character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.WalkSpeed  = 16
                    hum.JumpPower  = 50
                end
            end)
            Fluent:Notify({ Title = "Movement", Content = "Đã reset về mặc định!", Duration = 2 })
        end
    })
end

-- ═══════════════════════════════════════════════════════════
--  TAB 7: SETTINGS
-- ═══════════════════════════════════════════════════════════
do
    local t = Tabs.Settings

    t:AddSection({ Name = "⚙️ Giao diện" })

    t:AddToggle("AcrylicToggle", {
        Title   = "Hiệu ứng Acrylic",
        Desc    = "Nền mờ cho cửa sổ",
        Default = true,
        Callback = function(val)
            pcall(function() Window:SetAcrylic(val) end)
        end
    })

    t:AddSlider("UITransparency", {
        Title   = "Độ trong suốt UI",
        Min     = 0,
        Max     = 100,
        Default = 0,
        Rounding = 0,
        Callback = function(val)
            pcall(function() Window:SetTransparency(val / 100) end)
        end
    })

    t:AddSection({ Name = "🔑 Phím tắt" })

    t:AddParagraph({
        Title   = "Phím thu gọn",
        Content = "Left Control — thu gọn / mở lại cửa sổ\nNút nổi — chạm để mở lại"
    })

    t:AddSection({ Name = "💾 Lưu cài đặt" })

    SaveManager:SetLibrary(Fluent)
    InterfaceManager:SetLibrary(Fluent)
    InterfaceManager:BuildInterfaceSection(t)
    SaveManager:BuildConfigSection(t)

    t:AddSection({ Name = "ℹ️ Thông tin" })

    t:AddParagraph({
        Title   = "Ninja Hub",
        Content = "Phiên bản: 1.0\nGame: Steal An Egg\nTác giả: hoang\nEvent: Nitro Race + Butterfly Bloom\n\n⚠ Chỉ dùng trong môi trường cá nhân"
    })

    t:AddSection({ Name = "💬 Cộng đồng" })

    t:AddParagraph({
        Title   = "Discord",
        Content = "discord.gg/hzkP9m6h87"
    })

    t:AddButton({
        Title    = "📋 Copy link Discord",
        Desc     = "Sao chép discord.gg/hzkP9m6h87 vào clipboard",
        Callback = function()
            pcall(function()
                if setclipboard then
                    setclipboard("https://discord.gg/hzkP9m6h87")
                    Fluent:Notify({ Title = "Discord", Content = "Đã copy link Discord!", Duration = 3 })
                else
                    Fluent:Notify({ Title = "Discord", Content = "discord.gg/hzkP9m6h87\n(executor không hỗ trợ clipboard)", Duration = 4 })
                end
            end)
        end
    })

    t:AddButton({
        Title    = "Đặt lại toàn bộ UI",
        Desc     = "Khôi phục về cài đặt mặc định",
        Callback = function()
            pcall(function() SaveManager:ResetToDefaults() end)
            Fluent:Notify({ Title = "Settings", Content = "Đã đặt lại!", Duration = 2 })
        end
    })
end

-- ── LƯU CONFIG ─────────────────────────────────────────────
SaveManager:SetFolder("NinjaHub")
SaveManager:SetIgnoreIndexes({ "NoclipToggle", "InfJumpToggle" })
SaveManager:LoadAutoloadConfig()

-- ═══════════════════════════════════════════════════════════
--  NÚT NỔI TOGGLE + NÚT ĐÓNG UI
-- ═══════════════════════════════════════════════════════════
local parent2
pcall(function() if gethui then parent2 = gethui() end end)
parent2 = parent2 or CoreGui

-- Dọn GUI cũ nếu có
pcall(function()
    local old = parent2:FindFirstChild("NinjaHubFloatingUI")
    if old then old:Destroy() end
end)

local floatGui = Instance.new("ScreenGui")
floatGui.Name           = "NinjaHubFloatingUI"
floatGui.ResetOnSpawn   = false
floatGui.IgnoreGuiInset = true
floatGui.DisplayOrder   = 999
pcall(function() floatGui.Parent = parent2 end)
if not floatGui.Parent then floatGui.Parent = player:WaitForChild("PlayerGui") end

-- ── NÚT NỔI (mở lại khi bị thu gọn) ───────────────────────
local toggleBtn = Instance.new("ImageButton")
toggleBtn.Name            = "ToggleBtn"
toggleBtn.Size            = UDim2.fromOffset(72, 72)
toggleBtn.Position        = UDim2.new(0.04, 0, 0.22, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
toggleBtn.BorderSizePixel = 0
toggleBtn.AutoButtonColor = true
toggleBtn.Image           = "https://raw.githubusercontent.com/hoang-VN1/Tets/refs/heads/main/2374e4b898e74c1ff0183cbad39987bb.webp"
toggleBtn.ScaleType       = Enum.ScaleType.Fit
toggleBtn.Parent          = floatGui

local tc = Instance.new("UICorner")
tc.CornerRadius = UDim.new(0, 16)
tc.Parent = toggleBtn
local ts = Instance.new("UIStroke")
ts.Color     = Color3.fromRGB(120, 60, 220)
ts.Thickness = 2
ts.Parent = toggleBtn

-- ── NÚT ĐÓNG (X nhỏ góc phải nút nổi) ─────────────────────
local closeBtn = Instance.new("TextButton")
closeBtn.Name             = "CloseBtn"
closeBtn.Size             = UDim2.fromOffset(22, 22)
closeBtn.Position         = UDim2.new(1, -6, 0, -6)
closeBtn.AnchorPoint      = Vector2.new(1, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 60)
closeBtn.Text             = "✕"
closeBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize         = 13
closeBtn.Font             = Enum.Font.GothamBold
closeBtn.BorderSizePixel  = 0
closeBtn.Parent           = toggleBtn

local cc = Instance.new("UICorner")
cc.CornerRadius = UDim.new(0, 11)
cc.Parent = closeBtn

-- ── DRAG NÚT NỔI ───────────────────────────────────────────
local dragging, moved = false, false
local dragStart, startPos, dragInput

toggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        moved    = false
        dragStart = input.Position
        startPos  = toggleBtn.Position
        dragInput = input
    end
end)

toggleBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then moved = true end
        toggleBtn.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Tap toggle = Minimize/Restore
toggleBtn.Activated:Connect(function()
    if moved then moved = false; return end
    pcall(function() Window:Minimize() end)
end)

-- Nút X = Destroy toàn bộ UI
closeBtn.MouseButton1Click:Connect(function()
    Fluent:Notify({ Title = "Ninja Hub", Content = "Đang đóng...", Duration = 1 })
    task.wait(0.8)
    pcall(function() floatGui:Destroy() end)
    pcall(function()
        -- Tìm và destroy cửa sổ Fluent
        for _, gui in ipairs(CoreGui:GetChildren()) do
            if gui.Name:lower():find("fluent") or gui.Name:lower():find("ninja") then
                gui:Destroy()
            end
        end
        local pGui = player:FindFirstChild("PlayerGui")
        if pGui then
            for _, gui in ipairs(pGui:GetChildren()) do
                if gui.Name:lower():find("fluent") or gui.Name:lower():find("ninja") then
                    gui:Destroy()
                end
            end
        end
    end)
end)

-- ── THÔNG BÁO KHỞI ĐỘNG ────────────────────────────────────
task.wait(0.5)
Fluent:Notify({
    Title   = "🥷 Ninja Hub",
    Content = "Đã tải! Steal An Egg v1.0\nNitro Race + Butterfly Bloom",
    Duration = 4
})

Window:SelectTab(1)
