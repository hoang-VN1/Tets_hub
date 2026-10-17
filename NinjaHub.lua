-- ============================================================
--  NINJA HUB v1.2 — Steal An Egg
--  UI: FluentPlus | Events: Nitro Race + Butterfly Bloom
--  Fix: AutoSteal forward-ref, Heartbeat leak, dropdown hook
-- ============================================================

-- ── LOAD THƯ VIỆN ──────────────────────────────────────────
local FLUENT_URLS = {
    "https://raw.githubusercontent.com/discoart/FluentPlus/refs/heads/main/release.lua",
    "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Fluent.lua",
}
local SAVE_URL  = "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"
local IFACE_URL = "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"

local function tryLoad(urls)
    if type(urls) == "string" then urls = {urls} end
    for _, url in ipairs(urls) do
        local ok, result = pcall(function()
            return loadstring(game:HttpGet(url, true))()
        end)
        if ok and result then return result end
        task.wait(0.2)
    end
    error("Không load được thư viện từ tất cả URL")
end

local Fluent, SaveManager, InterfaceManager
local loadOk, loadErr = pcall(function()
    Fluent           = tryLoad(FLUENT_URLS)
    SaveManager      = tryLoad(SAVE_URL)
    InterfaceManager = tryLoad(IFACE_URL)
end)

if not loadOk then
    local guiParent
    pcall(function() if gethui then guiParent = gethui() end end)
    guiParent = guiParent or game:GetService("CoreGui")
    local sg = Instance.new("ScreenGui")
    sg.Name = "NinjaHubError"
    sg.ResetOnSpawn = false
    sg.Parent = guiParent
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,0,0,80)
    lbl.Position = UDim2.new(0,0,0.42,0)
    lbl.BackgroundColor3 = Color3.fromRGB(15,0,0)
    lbl.TextColor3 = Color3.fromRGB(255,80,80)
    lbl.TextScaled = true
    lbl.Text = "🥷 Ninja Hub: Lỗi load thư viện\nKiểm tra HTTP Request và kết nối mạng\n" .. tostring(loadErr)
    lbl.Font = Enum.Font.GothamBold
    lbl.Parent = sg
    return
end

-- ── EXECUTOR DETECT ────────────────────────────────────────
local ExecName = "Unknown"
pcall(function()
    if identifyexecutor then
        ExecName = identifyexecutor()
    elseif syn and syn.request then
        ExecName = "Synapse X"
    elseif KRNL_LOADED then
        ExecName = "KRNL"
    elseif rconsoleprint then
        ExecName = "Script-Ware / Delta"
    elseif fluxus then
        ExecName = "Fluxus"
    elseif ronix then
        ExecName = "Ronix"
    end
end)

local function copyToClipboard(text)
    pcall(function()
        if setclipboard then setclipboard(text)
        elseif toclipboard then toclipboard(text)
        elseif Clipboard and Clipboard.set then Clipboard.set(text) end
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

-- ── HÀM TIỆN ÍCH ───────────────────────────────────────────
local function safeGet(root, path)
    local cur = root
    for _, name in ipairs(path) do
        if cur == nil then return nil end
        cur = cur:FindFirstChild(name)
    end
    return cur
end

local function readStat(statName)
    local ls = safeGet(player, {"leaderstats"})
    if not ls then return "N/A" end
    local v = ls:FindFirstChild(statName)
    return v and tostring(v.Value) or "N/A"
end

local function getSpeed()
    local ls = safeGet(player, {"leaderstats"})
    if ls then
        for _, name in ipairs({"Speed","SPD","Spd","speed"}) do
            local v = ls:FindFirstChild(name)
            if v then return tostring(v.Value) end
        end
    end
    if humanoid then
        return string.format("%.1f (WalkSpeed)", humanoid.WalkSpeed)
    end
    return "N/A"
end

local function getMoney()
    for _, name in ipairs({"Cash","Money","Coins","Gems","Gold","cash","money"}) do
        local v = readStat(name)
        if v ~= "N/A" then return name .. ": " .. v end
    end
    return "N/A"
end

-- ═══════════════════════════════════════════════════════════
--  AUTO STEAL ENGINE — khai báo TRƯỚC mọi tab để tránh forward-ref
-- ═══════════════════════════════════════════════════════════
local AutoSteal = {}
AutoSteal.Active      = false
AutoSteal.FlySpeed    = 120
AutoSteal.SafePos     = nil
AutoSteal.CatchAll    = false
AutoSteal.Status      = "Chờ..."
AutoSteal.TargetNames = {
    "RiftEgg", "Rift Egg",
    "ExtinctionEgg", "Extinction Egg",
    "LuminousEgg", "Luminous Egg",
    "ExperimentEgg", "Experiment #001 Egg", "Experiment #013 Egg",
}

-- stealLabel là ref đến Paragraph widget trong Eggs tab — gán sau khi tạo tab
local stealLabel = nil

local function isTargetEgg(name)
    local low = name:lower()
    for _, t in ipairs(AutoSteal.TargetNames) do
        if low == t:lower() then return true end
    end
    if AutoSteal.CatchAll then
        return low:find("egg") ~= nil
    end
    return false
end

local function findNearestEgg()
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local best, bestDist = nil, math.huge
    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") or obj:IsA("Model") then
                if isTargetEgg(obj.Name) then
                    local pos
                    if obj:IsA("Model") then
                        pos = obj.PrimaryPart and obj.PrimaryPart.Position
                            or obj:GetModelCFrame().Position
                    else
                        pos = obj.Position
                    end
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
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then if onDone then onDone(false) end return end

    local stepConn
    local arrived = false
    stepConn = RunService.Heartbeat:Connect(function(dt)
        pcall(function()
            local r2 = character and character:FindFirstChild("HumanoidRootPart")
            if not r2 then
                stepConn:Disconnect()
                if onDone then onDone(false) end
                return
            end
            local diff = targetPos - r2.Position
            local dist = diff.Magnitude
            if dist < 3 then
                arrived = true
                stepConn:Disconnect()
                if onDone then onDone(true) end
                return
            end
            local step   = math.min(AutoSteal.FlySpeed * dt, dist)
            local newPos = r2.Position + diff.Unit * step
            r2.CFrame    = CFrame.new(newPos, newPos + diff.Unit)
        end)
    end)
    task.delay(8, function()
        if not arrived then
            pcall(function() stepConn:Disconnect() end)
            if onDone then onDone(false) end
        end
    end)
end

local function setStealStatus(msg)
    AutoSteal.Status = msg
    if stealLabel then
        pcall(function() stealLabel:SetContent(msg) end)
    end
end

local function stealLoop()
    while AutoSteal.Active do
        pcall(function()
            local egg, dist = findNearestEgg()
            if egg then
                local ePos = getEggPosition(egg)
                setStealStatus(string.format("Bay tới: %s (%.0fm)", egg.Name, dist or 0))

                -- flyTo chạy async qua callback, dùng event để đồng bộ trong loop
                local done = false
                local success = false
                flyTo(ePos, function(ok)
                    success = ok
                    done    = true
                end)
                -- Chờ callback
                local waited = 0
                while not done and waited < 10 do
                    task.wait(0.1)
                    waited = waited + 0.1
                end

                if success then
                    pcall(function()
                        local cd = egg:FindFirstChildOfClass("ClickDetector")
                        if cd then fireclickdetector(cd) end
                        local pp = egg:FindFirstChildOfClass("ProximityPrompt")
                        if pp then fireproximityprompt(pp) end
                    end)
                    setStealStatus("Đã cướp! Bay về base...")
                    if AutoSteal.SafePos then
                        local done2 = false
                        flyTo(AutoSteal.SafePos, function() done2 = true end)
                        local w2 = 0
                        while not done2 and w2 < 10 do
                            task.wait(0.1)
                            w2 = w2 + 0.1
                        end
                    end
                    setStealStatus("Về base xong. Tìm trứng tiếp...")
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

-- ── CỬA SỔ CHÍNH ───────────────────────────────────────────
local Window = Fluent:CreateWindow({
    Title                  = "Ninja Hub",
    SubTitle               = "Steal An Egg  •  v1.2",
    TitleIcon              = "https://raw.githubusercontent.com/hoang-VN1/Tets/refs/heads/main/2374e4b898e74c1ff0183cbad39987bb.webp",
    Image                  = "https://raw.githubusercontent.com/hoang-VN1/Tets/refs/heads/main/2374e4b898e74c1ff0183cbad39987bb.webp",
    DropdownsOutsideWindow = true,
    Size                   = UDim2.fromOffset(500, 370),
    TabWidth               = 160,
    Acrylic                = true,
    Theme                  = "Dark",
    Search                 = true,
    MinimizeKey            = Enum.KeyCode.LeftControl,
    UserInfo               = false,
})

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

-- ═══════════════════════════════════════════════════════════
--  TAB 1: HOME
-- ═══════════════════════════════════════════════════════════
do
    local t = Tabs.Home

    t:AddSection({ Name = "⚡ Ninja Hub — Trạng thái" })

    local statusLabel = t:AddParagraph({ Title = "Trạng thái",  Content = "Đang tải..." })
    local moneyLabel  = t:AddParagraph({ Title = "Tiền tệ",     Content = getMoney()    })
    local speedLabel  = t:AddParagraph({ Title = "Speed",       Content = getSpeed()    })

    -- Throttle refresh đúng cách: dùng tick() thay vì task.wait() trong Heartbeat
    local lastRefresh = 0
    RunService.Heartbeat:Connect(function()
        local now = tick()
        if now - lastRefresh < 3 then return end
        lastRefresh = now
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
            "Ninja Hub v1.2 | Steal An Egg\nEvent: Nitro Race + Butterfly Bloom\nTác giả: hoang\n\n💻 Executor: %s\n🖥 Platform: %s",
            ExecName,
            UserInputService.TouchEnabled and "Mobile 📱" or "PC/Console 🖥"
        )
    })

    t:AddSection({ Name = "⌨️ Phím tắt (PC)" })

    t:AddParagraph({
        Title   = "Keybinds",
        Content = "Left Ctrl  — Thu gọn / Mở menu\nF5         — Làm mới stats\nF6         — Bật/tắt Auto Steal\nF7         — Server Hop ngay\nDelete     — Đóng Ninja Hub"
    })

    -- Keybinds — AutoSteal đã khai báo ở trên nên an toàn
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.F5 then
            pcall(function()
                moneyLabel:SetContent(getMoney())
                speedLabel:SetContent(getSpeed())
            end)
            Fluent:Notify({ Title = "Ninja Hub", Content = "Stats đã làm mới!", Duration = 2 })

        elseif input.KeyCode == Enum.KeyCode.F6 then
            AutoSteal.Active = not AutoSteal.Active
            Fluent:Notify({
                Title   = "Auto Steal",
                Content = AutoSteal.Active and "Đã bật!" or "Đã tắt!",
                Duration = 2
            })
            if AutoSteal.Active then task.spawn(stealLoop) end

        elseif input.KeyCode == Enum.KeyCode.F7 then
            Fluent:Notify({ Title = "Server Hop", Content = "Đang tìm server...", Duration = 2 })
            task.spawn(function()
                local ok, data = pcall(function()
                    return HttpService:JSONDecode(
                        game:HttpGet(string.format(
                            "https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=20",
                            game.PlaceId
                        ), true)
                    )
                end)
                if ok and data and data.data and #data.data > 0 then
                    table.sort(data.data, function(a,b)
                        return (a.playing or 99) < (b.playing or 99)
                    end)
                    pcall(function()
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, data.data[1].id, player)
                    end)
                end
            end)

        elseif input.KeyCode == Enum.KeyCode.Delete then
            pcall(function()
                local g = CoreGui:FindFirstChild("NinjaHubFloatingUI")
                if g then g:Destroy() end
            end)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════
--  TAB 2: EGGS
-- ═══════════════════════════════════════════════════════════
do
    local t = Tabs.Eggs

    t:AddSection({ Name = "🥚 Trứng" })

    local eggInfoLabel = t:AddParagraph({ Title = "Trứng trong tay", Content = "Đang kiểm tra..." })

    local function scanEggs()
        local found = {}
        pcall(function()
            if character then
                for _, obj in ipairs(character:GetChildren()) do
                    if obj.Name:lower():find("egg") then
                        table.insert(found, obj.Name)
                    end
                end
            end
            local bp = player:FindFirstChild("Backpack")
            if bp then
                for _, obj in ipairs(bp:GetChildren()) do
                    if obj.Name:lower():find("egg") then
                        table.insert(found, obj.Name)
                    end
                end
            end
        end)
        return #found > 0
            and table.concat(found, "\n")
            or "Không tìm thấy trứng\n(chưa xác minh path Instance)"
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

    -- Gán stealLabel ở đây — dùng được từ stealLoop vì stealLoop gọi setStealStatus
    stealLabel = t:AddParagraph({ Title = "Trạng thái", Content = "Chờ bật..." })

    t:AddToggle("AutoStealToggle", {
        Title    = "Bật Auto Steal",
        Desc     = "Tự bay tới trứng xịn và cướp về base",
        Default  = false,
        Callback = function(val)
            AutoSteal.Active = val
            if val then
                Fluent:Notify({ Title = "Auto Steal", Content = "Đã bật!", Duration = 3 })
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
        Callback = function(val) AutoSteal.FlySpeed = val end
    })

    t:AddToggle("CatchAllToggle", {
        Title    = "Bắt mọi trứng",
        Desc     = "Bật = cướp tất cả object có tên chứa 'egg'",
        Default  = false,
        Callback = function(val) AutoSteal.CatchAll = val end
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
                    Content = string.format("X:%.0f Y:%.0f Z:%.0f",
                        root.Position.X, root.Position.Y, root.Position.Z),
                    Duration = 3
                })
                setStealStatus("Base đã lưu ✅")
            else
                Fluent:Notify({ Title = "Lỗi", Content = "Không tìm thấy nhân vật!", Duration = 3 })
            end
        end
    })

    t:AddButton({
        Title    = "🔍 Quét tên trứng trong workspace",
        Desc     = "Liệt kê object có 'egg' (copy tên thật để điền vào script)",
        Callback = function()
            local found = {}
            pcall(function()
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj.Name:lower():find("egg") then
                        local key = obj.Name .. " [" .. obj.ClassName .. "]"
                        if not table.find(found, key) then
                            table.insert(found, key)
                        end
                        if #found >= 20 then break end
                    end
                end
            end)
            local txt = #found > 0
                and table.concat(found, "\n")
                or "Không tìm thấy — trứng chưa spawn?"
            setStealStatus("Eggs tìm thấy:\n" .. txt)
            Fluent:Notify({ Title = "Scan", Content = string.format("Tìm thấy %d objects", #found), Duration = 3 })
        end
    })

    t:AddSection({ Name = "📋 Danh sách trứng" })

    t:AddParagraph({
        Title   = "Các loại trứng",
        Content = "• Extinction Egg (Paid)\n• Luminous Egg (Store)\n• Rift Egg (Boss Event)\n• Experiment #001 Egg\n• Experiment #013 Egg\n• Cherry Blossom Egg\n• Monster Egg\n\n⚠ Tên Instance chưa xác minh — dùng Quét ở trên"
    })
end

-- ═══════════════════════════════════════════════════════════
--  TAB 3: PETS
-- ═══════════════════════════════════════════════════════════
do
    local t = Tabs.Pets

    local EggPetDB = {
        ["Rift Egg"] = {
            "Overlord", "Shadow Drake", "Void Wolf", "Rift Fox",
            "Eclipse Bear", "Phantom Cat", "Dark Serpent", "Null Bunny",
            "Abyss Turtle", "Glitch Deer", "Rift Dragon", "Void Phoenix",
            "Shadow Tiger", "Eclipse Lion", "Null Hydra", "Rift Overlord",
        },
        ["Extinction Egg"] = { "T-Rex", "Mammoth", "Saber Tooth", "Dodo", "Pterodactyl", "Triceratops" },
        ["Luminous Egg"]   = { "Luminous Cat", "Luminous Dog", "Luminous Fox", "Luminous Dragon", "Luminous Phoenix" },
        ["Experiment #001 Egg"] = { "Experiment #001", "Mutant Frog", "Lab Rat" },
        ["Experiment #013 Egg"] = { "Experiment #013", "Bio Wolf", "Toxic Snake" },
        ["Cherry Blossom Egg"]  = { "Crane", "Sakura Fox", "Petal Deer", "Blossom Bunny" },
        ["Monster Egg"]         = { "Hungry Frog", "Bloom Frog", "Spirit Bloom Frog" },
    }

    local petToEgg = {}
    for eggName, pets in pairs(EggPetDB) do
        for _, pet in ipairs(pets) do
            petToEgg[pet] = eggName
        end
    end

    local selectedEgg = nil
    local selectedPet = nil

    local eggNames = {}
    for k in pairs(EggPetDB) do table.insert(eggNames, k) end
    table.sort(eggNames)

    t:AddSection({ Name = "🐾 Chọn Pet Muốn Lấy" })

    local petStatusLabel = t:AddParagraph({ Title = "Đang nhắm tới", Content = "Chưa chọn pet" })

    -- Lấy pet list của egg đầu tiên để init dropdown pet
    selectedEgg = eggNames[1]
    local initPets = EggPetDB[selectedEgg] or {}

    -- Dropdown egg — dùng Callback, KHÔNG dùng .Changed (FluentPlus không có)
    t:AddDropdown("EggDropdown", {
        Title    = "Chọn loại trứng",
        Values   = eggNames,
        Default  = eggNames[1],
        Callback = function(val)
            selectedEgg = val
            selectedPet = nil
            petStatusLabel:SetContent("Đã chọn trứng: " .. val .. "\n→ Chọn pet bên dưới")
            -- Cập nhật AutoSteal target ngay khi đổi trứng
            AutoSteal.TargetNames = { val }
        end
    })

    -- Dropdown pet — toàn bộ danh sách phẳng vì FluentPlus không re-render values
    -- User chọn pet, script tự lấy egg tương ứng
    local allPetsFlat = {}
    for _, egg in ipairs(eggNames) do
        for _, pet in ipairs(EggPetDB[egg]) do
            table.insert(allPetsFlat, pet)
        end
    end

    t:AddDropdown("PetDropdown", {
        Title    = "Chọn pet muốn lấy",
        Values   = allPetsFlat,
        Default  = allPetsFlat[1],
        Callback = function(val)
            selectedPet = val
            local eggOfPet = petToEgg[val]
            selectedEgg    = eggOfPet or selectedEgg
            petStatusLabel:SetContent(
                string.format("🎯 Pet: %s\n📦 Trứng: %s", val, selectedEgg or "?")
            )
            AutoSteal.TargetNames = { selectedEgg or val }
        end
    })

    t:AddSection({ Name = "🥷 Auto Steal theo Pet" })

    local autoStealPetLabel = t:AddParagraph({ Title = "Trạng thái", Content = "Chưa bật" })

    t:AddToggle("AutoStealPetToggle", {
        Title    = "Tự động steal trứng có pet này",
        Desc     = "Chọn pet trước rồi bật — script tìm đúng trứng",
        Default  = false,
        Callback = function(val)
            AutoSteal.Active = val
            if val then
                if not selectedEgg then
                    Fluent:Notify({ Title = "Pets", Content = "Chọn pet trước!", Duration = 3 })
                    AutoSteal.Active = false
                    return
                end
                AutoSteal.TargetNames = { selectedEgg }
                autoStealPetLabel:SetContent("🟢 Đang steal: " .. selectedEgg)
                Fluent:Notify({
                    Title   = "Auto Steal Pet",
                    Content = "Đang tìm: " .. (selectedPet or selectedEgg),
                    Duration = 3
                })
                task.spawn(stealLoop)
            else
                autoStealPetLabel:SetContent("⚫ Đã dừng")
            end
        end
    })

    t:AddSection({ Name = "📋 Pets theo trứng" })

    t:AddParagraph({
        Title   = "Danh sách đầy đủ",
        Content =
            "🥚 Rift Egg (16): Overlord, Shadow Drake, Void Wolf...\n" ..
            "🦕 Extinction: T-Rex, Mammoth, Saber Tooth...\n" ..
            "✨ Luminous: Cat/Dog/Fox/Dragon/Phoenix\n" ..
            "🧪 Exp #001: Experiment, Mutant Frog, Lab Rat\n" ..
            "🧪 Exp #013: Experiment, Bio Wolf, Toxic Snake\n" ..
            "🌸 Cherry Blossom: Crane, Sakura Fox, Petal Deer\n" ..
            "👾 Monster: Hungry/Bloom/Spirit Frog\n\n" ..
            "⚠ Tên từ wiki — chưa xác minh Instance"
    })

    t:AddSection({ Name = "🏆 Win Pass Pets (Nitro Race)" })

    t:AddParagraph({
        Title   = "Phần thưởng",
        Content = "1 win   → Seahorse Racer\n5 wins  → Lizard Racer\n15 wins → Bird Racer\n21 wins → Cheetah Racer\n30 wins → Snail Racer\n\n✅ Xác minh từ Update 8"
    })
end

-- ═══════════════════════════════════════════════════════════
--  TAB 4: NITRO RACE
-- ═══════════════════════════════════════════════════════════
do
    local t = Tabs.Nitro

    t:AddSection({ Name = "🏎️ Nitro Race — Thông tin" })

    t:AddParagraph({
        Title   = "Cơ chế (đã xác minh)",
        Content = "• Race bắt đầu mỗi 30 phút\n• Thắng nhất: +1 Win, +2,500 Trophies\n• Trophies đổi: Boosters, Nitro Mutation (475T, 10%)\n• Win Pass: 5 pet độc quyền"
    })

    t:AddSection({ Name = "⏱ Đồng hồ đếm ngược" })

    local timerLabel   = t:AddParagraph({ Title = "Race tiếp theo", Content = "Bật để đếm ngược" })
    local timerActive  = false
    local timerStart   = 0
    local RACE_INTERVAL = 30 * 60
    -- Throttle timer — dùng tick() không dùng task.wait trong Heartbeat
    local lastTimerTick = 0
    local notifiedSoon  = false

    t:AddToggle("NitroTimer", {
        Title    = "Bật đồng hồ đếm ngược",
        Desc     = "Tính từ lúc bật — không đồng bộ với server",
        Default  = false,
        Callback = function(val)
            timerActive  = val
            notifiedSoon = false
            if val then
                timerStart = tick()
                Fluent:Notify({ Title = "Nitro Race", Content = "Bắt đầu đếm 30 phút!", Duration = 3 })
            else
                timerLabel:SetContent("Đã tắt")
            end
        end
    })

    RunService.Heartbeat:Connect(function()
        if not timerActive then return end
        local now = tick()
        if now - lastTimerTick < 1 then return end
        lastTimerTick = now
        pcall(function()
            local elapsed   = now - timerStart
            local remaining = RACE_INTERVAL - (elapsed % RACE_INTERVAL)
            local mins = math.floor(remaining / 60)
            local secs = math.floor(remaining % 60)
            timerLabel:SetContent(string.format("Race tiếp theo: %02d:%02d", mins, secs))
            if remaining <= 10 and not notifiedSoon then
                notifiedSoon = true
                Fluent:Notify({ Title = "🏎️ Nitro Race!", Content = "Race sắp bắt đầu!", Duration = 5 })
            end
            if remaining > 10 then notifiedSoon = false end
        end)
    end)

    t:AddSection({ Name = "📊 Theo dõi tiến trình" })

    local winCount   = 0
    local winLabel   = t:AddParagraph({ Title = "Wins hiện tại",     Content = "0 wins" })
    local trophyCount = 0
    local trophyLabel = t:AddParagraph({ Title = "Trophies tích lũy", Content = "0 Trophies" })

    local WIN_REWARDS = {
        {1, "Seahorse Racer"}, {5, "Lizard Racer"}, {15, "Bird Racer"},
        {21, "Cheetah Racer"}, {30, "Snail Racer"},
    }
    local function getNextReward(wins)
        for _, r in ipairs(WIN_REWARDS) do
            if wins < r[1] then
                return string.format(" → %d wins: %s", r[1], r[2])
            end
        end
        return " ✅ Win Pass hoàn tất!"
    end

    t:AddButton({
        Title    = "+1 Win",
        Desc     = "Ghi nhận một chiến thắng thủ công",
        Callback = function()
            winCount = winCount + 1
            winLabel:SetContent(winCount .. " wins" .. getNextReward(winCount))
        end
    })

    t:AddButton({
        Title    = "Reset wins",
        Callback = function()
            winCount = 0
            winLabel:SetContent("0 wins")
        end
    })

    t:AddButton({
        Title    = "+2500 Trophies",
        Desc     = "Ghi nhận Trophy từ một chiến thắng",
        Callback = function()
            trophyCount = trophyCount + 2500
            local nitros = math.floor(trophyCount / 475)
            trophyLabel:SetContent(string.format("%d Trophies  |  ~%d Nitro Mutation", trophyCount, nitros))
        end
    })

    t:AddSection({ Name = "ℹ️ Hướng dẫn" })

    t:AddParagraph({
        Title   = "Cách chơi",
        Content = "1. Chờ Race Portal mở (mỗi 30 phút)\n2. Vào portal để tham gia race\n3. Về nhất → Trophies + Win\n4. Dùng Trophies đổi Nitro Mutation (10%)\n5. Win Pass mở ở mốc 1/5/15/21/30 wins"
    })
end

-- ═══════════════════════════════════════════════════════════
--  TAB 5: BUTTERFLY BLOOM
-- ═══════════════════════════════════════════════════════════
do
    local t = Tabs.Butterfly

    t:AddSection({ Name = "🦋 Butterfly Bloom" })

    t:AddParagraph({
        Title   = "Cơ chế (đã xác minh)",
        Content = "• Khu vực: Enchanted Forest / Enchanted Tree\n• Lấy Butterfly Net từ bên trong cây\n• Bắt bướm → đổi lấy Enchanted Mutation (100%)\n\n⚠ Cooldown Butterfly Bloom chưa xác minh chính thức"
    })

    t:AddSection({ Name = "📍 Định vị" })

    local areaLabel = t:AddParagraph({ Title = "Enchanted Tree", Content = "Nhấn Tìm để quét workspace" })

    t:AddButton({
        Title    = "Tìm Enchanted Tree",
        Desc     = "Quét workspace tìm khu vực Butterfly Bloom",
        Callback = function()
            local found = {}
            pcall(function()
                for _, obj in ipairs(workspace:GetDescendants()) do
                    local n = obj.Name:lower()
                    if n:find("enchanted") or n:find("butterfly") or n:find("bloom") then
                        table.insert(found, string.format("%s (%s)", obj.Name, obj.ClassName))
                        if #found >= 10 then break end
                    end
                end
            end)
            if #found > 0 then
                areaLabel:SetContent(table.concat(found, "\n"))
            else
                areaLabel:SetContent("Không tìm thấy\n(event chưa active hoặc tên khác)")
            end
            Fluent:Notify({ Title = "Butterfly", Content = string.format("%d objects tìm thấy", #found), Duration = 3 })
        end
    })

    t:AddSection({ Name = "🦋 Đếm bướm" })

    local butterflyCount = 0
    local butterflyLabel = t:AddParagraph({ Title = "Bướm đã bắt", Content = "0 bướm" })

    t:AddButton({
        Title    = "+1 Butterfly",
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
        Content = "1. Đến Enchanted Forest\n2. Vào bên trong Enchanted Tree\n3. Lấy Butterfly Net\n4. Bắt bướm trong khu vực\n5. Đổi bướm → Enchanted Mutation (100%)"
    })
end

-- ═══════════════════════════════════════════════════════════
--  TAB 6: SERVER HOP
-- ═══════════════════════════════════════════════════════════
do
    local t        = Tabs.Server
    local PLACE_ID = game.PlaceId

    t:AddSection({ Name = "🌐 Server Hop" })

    t:AddParagraph({
        Title   = "Cách hoạt động",
        Content = "Lấy danh sách server từ Roblox API\nrồi tìm server ít người nhất.\n\n⚠ Không thể tạo server riêng — chỉ tìm server ít người nhất."
    })

    local serverStatusLabel = t:AddParagraph({ Title = "Trạng thái", Content = "Chưa bắt đầu" })

    local minPlayers = 3
    t:AddSlider("MinPlayersSlider", {
        Title    = "Vào server có tối đa N người",
        Min      = 1,
        Max      = 10,
        Default  = 3,
        Rounding = 0,
        Callback = function(val) minPlayers = val end
    })

    local function getServers(cursor)
        local url = string.format(
            "https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100%s",
            PLACE_ID,
            cursor and ("&cursor=" .. cursor) or ""
        )
        local ok, res = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(url, true))
        end)
        if ok and res then return res end
        return nil
    end

    local function findQuietServer()
        serverStatusLabel:SetContent("Đang tải danh sách server...")
        local cursor   = nil
        local attempts = 0
        local fallbackServers = nil

        repeat
            local data = getServers(cursor)
            if not data or not data.data then
                serverStatusLabel:SetContent("Lỗi lấy danh sách server")
                return nil
            end
            -- Lưu trang đầu để dùng làm fallback
            if not fallbackServers then
                fallbackServers = data.data
            end
            for _, srv in ipairs(data.data) do
                if (srv.playing or 0) <= minPlayers then
                    return srv.id, srv.playing or 0
                end
            end
            cursor   = data.nextPageCursor
            attempts = attempts + 1
            task.wait(0.5)
        until not cursor or attempts > 5

        -- Fallback: server ít người nhất trong trang đầu
        if fallbackServers and #fallbackServers > 0 then
            table.sort(fallbackServers, function(a,b) return (a.playing or 0) < (b.playing or 0) end)
            return fallbackServers[1].id, fallbackServers[1].playing or 0
        end
        return nil
    end

    t:AddButton({
        Title    = "🔍 Tìm & vào server ít người",
        Desc     = "Quét rồi teleport vào server ít người nhất",
        Callback = function()
            serverStatusLabel:SetContent("Đang quét...")
            task.spawn(function()
                local jobId, count = findQuietServer()
                if jobId then
                    serverStatusLabel:SetContent(
                        string.format("Tìm thấy: %d người — đang teleport...", count)
                    )
                    Fluent:Notify({ Title = "Server Hop", Content = string.format("Vào server %d người!", count), Duration = 3 })
                    task.wait(1.5)
                    pcall(function()
                        TeleportService:TeleportToPlaceInstance(PLACE_ID, jobId, player)
                    end)
                else
                    serverStatusLabel:SetContent("Không tìm được server phù hợp")
                    Fluent:Notify({ Title = "Server Hop", Content = "Không tìm được!", Duration = 3 })
                end
            end)
        end
    })

    t:AddSection({ Name = "🔄 Auto Hop" })

    local hopActive       = false
    local autoHopThreshold = 10

    t:AddSlider("AutoHopThresholdSlider", {
        Title    = "Hop khi server > N người",
        Min      = 2,
        Max      = 50,
        Default  = 10,
        Rounding = 0,
        Callback = function(val) autoHopThreshold = val end
    })

    t:AddToggle("AutoHopToggle", {
        Title    = "Bật Auto Hop",
        Desc     = "Tự chuyển server khi đông hơn ngưỡng",
        Default  = false,
        Callback = function(val)
            hopActive = val
            if val then
                Fluent:Notify({ Title = "Auto Hop", Content = "Đã bật!", Duration = 2 })
                task.spawn(function()
                    while hopActive do
                        task.wait(15)
                        if not hopActive then break end
                        pcall(function()
                            local current = #Players:GetPlayers()
                            if current > autoHopThreshold then
                                serverStatusLabel:SetContent(
                                    string.format("Server đông (%d người) — đang hop...", current)
                                )
                                local jobId, count = findQuietServer()
                                if jobId then
                                    task.wait(1)
                                    TeleportService:TeleportToPlaceInstance(PLACE_ID, jobId, player)
                                end
                            else
                                serverStatusLabel:SetContent(
                                    string.format("Server ổn (%d người)", current)
                                )
                            end
                        end)
                    end
                end)
            end
        end
    })

    t:AddSection({ Name = "📊 Server hiện tại" })

    local srvInfoLabel = t:AddParagraph({ Title = "Thông tin", Content = "Nhấn làm mới" })

    t:AddButton({
        Title    = "Làm mới thông tin",
        Callback = function()
            pcall(function()
                local jobId   = game.JobId
                local players = #Players:GetPlayers()
                srvInfoLabel:SetContent(string.format(
                    "JobId: %s\nSố người: %d\nPlace: %d",
                    jobId, players, PLACE_ID
                ))
                copyToClipboard(jobId)
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

    t:AddParagraph({
        Title   = "Lưu ý",
        Content = "WalkSpeed/JumpPower là client-side.\nServer có thể reset. Không can thiệp anti-cheat."
    })

    t:AddSlider("WalkSpeedSlider", {
        Title    = "WalkSpeed",
        Desc     = "Tốc độ di chuyển (mặc định: 16)",
        Min      = 1,
        Max      = 350,
        Default  = 16,
        Rounding = 0,
        Callback = function(val)
            pcall(function()
                local hum = character and character:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = val end
            end)
        end
    })

    t:AddSlider("JumpPowerSlider", {
        Title    = "JumpPower",
        Desc     = "Lực nhảy (mặc định: 50)",
        Min      = 1,
        Max      = 500,
        Default  = 50,
        Rounding = 0,
        Callback = function(val)
            pcall(function()
                local hum = character and character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.JumpPower  = val
                    hum.UseJumpPower = true
                end
            end)
        end
    })

    t:AddSection({ Name = "🔧 Công cụ" })

    local noclipConn
    t:AddToggle("NoclipToggle", {
        Title    = "NoClip",
        Desc     = "Xuyên tường (client-side)",
        Default  = false,
        Callback = function(val)
            if val then
                noclipConn = RunService.Stepped:Connect(function()
                    pcall(function()
                        if character then
                            for _, p in ipairs(character:GetDescendants()) do
                                if p:IsA("BasePart") then p.CanCollide = false end
                            end
                        end
                    end)
                end)
            else
                if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
                pcall(function()
                    if character then
                        for _, p in ipairs(character:GetDescendants()) do
                            if p:IsA("BasePart") then p.CanCollide = true end
                        end
                    end
                end)
            end
        end
    })

    local ijConn
    t:AddToggle("InfJumpToggle", {
        Title    = "Infinite Jump",
        Desc     = "Nhảy liên tục",
        Default  = false,
        Callback = function(val)
            if val then
                ijConn = UserInputService.JumpRequest:Connect(function()
                    pcall(function()
                        local hum = character and character:FindFirstChildOfClass("Humanoid")
                        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
                    end)
                end)
            else
                if ijConn then ijConn:Disconnect(); ijConn = nil end
            end
        end
    })

    t:AddButton({
        Title    = "Reset Speed",
        Desc     = "WalkSpeed 16, JumpPower 50",
        Callback = function()
            pcall(function()
                local hum = character and character:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = 16; hum.JumpPower = 50 end
            end)
            Fluent:Notify({ Title = "Movement", Content = "Đã reset!", Duration = 2 })
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
        Title    = "Hiệu ứng Acrylic",
        Default  = true,
        Callback = function(val) pcall(function() Window:SetAcrylic(val) end) end
    })

    t:AddSlider("UITransparency", {
        Title    = "Độ trong suốt UI",
        Min      = 0,
        Max      = 100,
        Default  = 0,
        Rounding = 0,
        Callback = function(val) pcall(function() Window:SetTransparency(val / 100) end) end
    })

    t:AddSection({ Name = "💾 Lưu cài đặt" })

    SaveManager:SetLibrary(Fluent)
    InterfaceManager:SetLibrary(Fluent)
    InterfaceManager:BuildInterfaceSection(t)
    SaveManager:BuildConfigSection(t)

    t:AddSection({ Name = "💬 Cộng đồng" })

    t:AddParagraph({ Title = "Discord", Content = "discord.gg/hzkP9m6h87" })

    t:AddButton({
        Title    = "📋 Copy link Discord",
        Desc     = "Sao chép discord.gg/hzkP9m6h87",
        Callback = function()
            copyToClipboard("https://discord.gg/hzkP9m6h87")
            Fluent:Notify({ Title = "Discord", Content = "Đã copy link Discord!", Duration = 3 })
        end
    })

    t:AddSection({ Name = "ℹ️ Thông tin" })

    t:AddParagraph({
        Title   = "Ninja Hub v1.2",
        Content = "Game: Steal An Egg\nEvent: Nitro Race + Butterfly Bloom\n⚠ Chỉ dùng trong môi trường cá nhân"
    })

    t:AddButton({
        Title    = "Đặt lại toàn bộ UI",
        Callback = function()
            pcall(function() SaveManager:ResetToDefaults() end)
            Fluent:Notify({ Title = "Settings", Content = "Đã đặt lại!", Duration = 2 })
        end
    })
end

-- ── LƯU CONFIG ─────────────────────────────────────────────
SaveManager:SetFolder("NinjaHub")
SaveManager:SetIgnoreIndexes({ "NoclipToggle", "InfJumpToggle", "AutoStealToggle", "AutoStealPetToggle", "AutoHopToggle" })
SaveManager:LoadAutoloadConfig()

-- ═══════════════════════════════════════════════════════════
--  NÚT NỔI TOGGLE + NÚT ĐÓNG
-- ═══════════════════════════════════════════════════════════
local guiParent
pcall(function() if gethui then guiParent = gethui() end end)
guiParent = guiParent or CoreGui

pcall(function()
    local old = guiParent:FindFirstChild("NinjaHubFloatingUI")
    if old then old:Destroy() end
end)

local floatGui = Instance.new("ScreenGui")
floatGui.Name           = "NinjaHubFloatingUI"
floatGui.ResetOnSpawn   = false
floatGui.IgnoreGuiInset = true
floatGui.DisplayOrder   = 999
floatGui.Parent = guiParent

local toggleBtn = Instance.new("ImageButton")
toggleBtn.Name             = "ToggleBtn"
toggleBtn.Size             = UDim2.fromOffset(72, 72)
toggleBtn.Position         = UDim2.new(0.04, 0, 0.22, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
toggleBtn.BorderSizePixel  = 0
toggleBtn.AutoButtonColor  = true
toggleBtn.Image            = "https://raw.githubusercontent.com/hoang-VN1/Tets/refs/heads/main/2374e4b898e74c1ff0183cbad39987bb.webp"
toggleBtn.ScaleType        = Enum.ScaleType.Fit
toggleBtn.Parent           = floatGui

local tc = Instance.new("UICorner")
tc.CornerRadius = UDim.new(0, 16)
tc.Parent = toggleBtn

local ts = Instance.new("UIStroke")
ts.Color     = Color3.fromRGB(120, 60, 220)
ts.Thickness = 2
ts.Parent    = toggleBtn

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
local dragStart, startPos, dragInputObj

toggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging     = true
        moved        = false
        dragStart    = input.Position
        startPos     = toggleBtn.Position
        dragInputObj = input
    end
end)

toggleBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then
        dragInputObj = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInputObj then
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

toggleBtn.Activated:Connect(function()
    if moved then moved = false; return end
    pcall(function() Window:Minimize() end)
end)

closeBtn.MouseButton1Click:Connect(function()
    Fluent:Notify({ Title = "Ninja Hub", Content = "Đang đóng...", Duration = 1 })
    task.wait(0.8)
    pcall(function() floatGui:Destroy() end)
    pcall(function()
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
    Title    = "🥷 Ninja Hub v1.2",
    Content  = "Đã tải thành công!\nSteal An Egg | Nitro Race | Butterfly Bloom",
    Duration = 4
})

Window:SelectTab(1)
