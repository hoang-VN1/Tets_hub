-- RealKid Hub - Hop Farm (Standalone)
-- Independent version extracted from the original Hop section.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local request = (syn and syn.request) or (http and http.request) or http_request or request
if type(request) ~= "function" then
    warn("HTTP request function is not available in this environment.")
    return
end

pcall(function()
    ReplicatedStorage:WaitForChild("__ServerBrowser", 10)
end)

local ok, result3 = pcall(function()
    local response4 = game:HttpGet("https://raw.githubusercontent.com/tlredz/Library/refs/heads/main/redz-V5-remake/main.luau")
    return loadstring(response4)()
end)

if not ok or type(result3) ~= "table" or type(result3.MakeWindow) ~= "function" then
    warn("Không thể tải thư viện UI Hop Farm.")
    return
end

pcall(function() makefolder("realkid_hop_data") end)
pcall(function() makefolder("realkid_hop_data\\" .. Players.LocalPlayer.Name) end)

local Window2 = result3:MakeWindow({
    Title = "RealKid Hub",
    ScriptFolder = "realkid_hop_data\\" .. Players.LocalPlayer.Name,
    SubTitle = "Menu Hop"
})

local Tab7 = Window2:MakeTab({ Title = "Auto Hop" })
Tab7:AddSection("Auto Hop")
Tab7:AddDropdown({
	Name = "Select Event",
	Flag = "SelectedAutoHopEvent",
	Options = {
		"Fruits",
		"Berries",
		"Pink Pig Berry",
		"Red Cherry Berry",
		"White Cloud Berry",
		"Server 4 Hours",
		"Pirate Raid",
		"Haki Colors",
		"Rip Indra",
		"Dough King",
		"Cake Queen",
		"Cake Prince",
		"Elite Hunter",
		"Darkbeard",
		"Cursed Captain",
		"Tyrant of Skies",
		"Soul Reaper",
		"Mirage Island",
		"Kitsune Island",
		"Prehistoric Island",
		"Near Full Moon",
		"Full Moon",
		"Legendary Swords",
		"Factory Raid",
		"Sweet Chalice",
		"Fist of Darkness",
		"God's Chalice"
	},
	Callback = function(state, arg106)
	end
})
Tab7:AddToggle({
	Name = "Auto Hop Selected Event",
	Default = false,
	Flag = "AutoHopSelectedEvent",
	Callback = function(state, arg108)
		if state then
			task.spawn(function(...)
				task.wait(0.5)
				Window2:Notify({ Title = "Auto Hop", Content = "Chưa chọn sự kiện", Duration = 3 })
			end)
		end
	end
})
local Tab8 = Window2:MakeTab({ Title = "Fruits" })
Tab8:AddSection("Săn Trái Hop")
Tab8:AddButton({
	Name = "Làm mới danh sách",
	Debounce = 5,
	Callback = function(state, arg110)
		Window2:Notify({ Title = "Đang quét", Content = "Đang tải dữ liệu...", Duration = 2 })
		if state then
			local encoded = HttpService:UrlEncode("AllFruits")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded })
			end)
		else
			local encoded2 = HttpService:UrlEncode("AllFruits")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded2 })
			end)
		end
		task.wait()
		Window2:Notify({ Title = "Trống", Content = "Hiện tại không có server nào hoạt động", Duration = 3 })
	end
})
local Tab9 = Window2:MakeTab({ Title = "Berries" })
Tab9:AddSection("Săn Berry")
Tab9:AddButton({
	Name = "Làm mới danh sách",
	Debounce = 5,
	Callback = function(state, arg112)
		Window2:Notify({ Title = "Đang quét", Content = "Đang tải dữ liệu...", Duration = 2 })
		if state then
			local encoded3 = HttpService:UrlEncode("Berries")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded3 })
			end)
		else
			local encoded4 = HttpService:UrlEncode("Berries")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded4 })
			end)
		end
		task.wait()
		Window2:Notify({ Title = "Trống", Content = "Hiện tại không có server nào hoạt động", Duration = 3 })
	end
})
local Tab10 = Window2:MakeTab({ Title = "Server 4 Hours" })
Tab10:AddSection("Server đủ 4 tiếng")
Tab10:AddButton({
	Name = "Làm mới danh sách",
	Debounce = 5,
	Callback = function(state, arg114)
		Window2:Notify({ Title = "Đang quét", Content = "Đang tải dữ liệu...", Duration = 2 })
		if state then
			local encoded5 = HttpService:UrlEncode("Server 4 Hours")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded5 })
			end) --[=[  ]=]
		else
			local encoded6 = HttpService:UrlEncode("Server 4 Hours")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded6 })
			end)
		end
		task.wait()
		Window2:Notify({ Title = "Trống", Content = "Hiện tại không có server nào hoạt động", Duration = 3 })
	end
})
local Tab11 = Window2:MakeTab({ Title = "Pirate Raid" })
Tab11:AddSection("Săn Hải Tặc")
Tab11:AddButton({
	Name = "Làm mới danh sách",
	Debounce = 5,
	Callback = function(state, arg116)
		Window2:Notify({ Title = "Đang quét", Content = "Đang tải dữ liệu...", Duration = 2 })
		if state then
			local encoded7 = HttpService:UrlEncode("Pirate Raid")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded7 })
			end)
		else
			local encoded8 = HttpService:UrlEncode("Pirate Raid")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded8 })
			end)
		end
		task.wait()
		Window2:Notify({ Title = "Trống", Content = "Hiện tại không có server nào hoạt động", Duration = 3 })
	end
})
local Tab12 = Window2:MakeTab({ Title = "Haki Colors" })
Tab12:AddSection("Săn Công Thức Haki Màu")
Tab12:AddButton({
	Name = "Làm mới danh sách",
	Debounce = 5,
	Callback = function(state, arg118)
		Window2:Notify({ Title = "Đang quét", Content = "Đang tải dữ liệu...", Duration = 2 })
		if state then
			local encoded9 = HttpService:UrlEncode("Snow White")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded9 })
			end)
			task.wait()
			local encoded10 = HttpService:UrlEncode("Pure Red")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded10 })
			end)
			task.wait()
			local encoded11 = HttpService:UrlEncode("Winter Sky")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded11 })
			end)
		else
			local encoded12 = HttpService:UrlEncode("Snow White")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded12 })
			end)
			task.wait()
			local encoded13 = HttpService:UrlEncode("Pure Red")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded13 })
			end)
			task.wait()
			local encoded14 = HttpService:UrlEncode("Winter Sky")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded14 })
			end)
		end -- 
		task.wait()
		Window2:Notify({ Title = "Trống", Content = "Hiện tại không có server nào hoạt động", Duration = 3 })
	end
})
local Tab13 = Window2:MakeTab({ Title = "Rip Indra" })
Tab13:AddSection("Rip Indra")
Tab13:AddButton({
	Name = "Làm mới danh sách",
	Debounce = 5,
	Callback = function(state, arg120)
		Window2:Notify({ Title = "Đang quét", Content = "Đang tải dữ liệu...", Duration = 2 })
		if state then
			local encoded15 = HttpService:UrlEncode("Rip_Indra")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded15 })
			end)
			task.wait()
			local encoded16 = HttpService:UrlEncode("rip_indra")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded16 })
			end)
			task.wait()
			local encoded17 = HttpService:UrlEncode("rip_indra True Form")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded17 })
			end)
		else
			local encoded18 = HttpService:UrlEncode("Rip_Indra")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded18 })
			end)
			task.wait()
			local encoded19 = HttpService:UrlEncode("rip_indra")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded19 })
			end)
			task.wait()
			local encoded20 = HttpService:UrlEncode("rip_indra True Form")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded20 })
			end)
		end
		task.wait()
		Window2:Notify({ Title = "Trống", Content = "Hiện tại không có server nào hoạt động", Duration = 3 })
	end
})
local Tab14 = Window2:MakeTab({ Title = "Dough King" })
Tab14:AddSection("Dough King")
Tab14:AddButton({
	Name = "Làm mới danh sách",
	Debounce = 5,
	Callback = function(state, arg122)
		Window2:Notify({ Title = "Đang quét", Content = "Đang tải dữ liệu...", Duration = 2 })
		if state then
			local encoded21 = HttpService:UrlEncode("Dough King")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded21 })
			end)
		else
			local encoded22 = HttpService:UrlEncode("Dough King")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded22 })
			end)
		end
		task.wait()
		Window2:Notify({ Title = "Trống", Content = "Hiện tại không có server nào hoạt động", Duration = 3 })
	end
})
local Tab15 = Window2:MakeTab({ Title = "Cake Queen" })
Tab15:AddSection("Cake Queen")
Tab15:AddButton({
	Name = "Làm mới danh sách",
	Debounce = 5,
	Callback = function(state, arg124)
		Window2:Notify({ Title = "Đang quét", Content = "Đang tải dữ liệu...", Duration = 2 })
		if state then
			local encoded23 = HttpService:UrlEncode("Cake Queen")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded23 })
			end)
		else
			local encoded24 = HttpService:UrlEncode("Cake Queen")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded24 })
			end)
		end
		task.wait()
		Window2:Notify({ Title = "Trống", Content = "Hiện tại không có server nào hoạt động", Duration = 3 })
	end
})
local Tab16 = Window2:MakeTab({ Title = "Cake Prince" })
Tab16:AddSection("Cake Prince")
Tab16:AddButton({
	Name = "Làm mới danh sách",
	Debounce = 5,
	Callback = function(state, arg126)
		Window2:Notify({ Title = "Đang quét", Content = "Đang tải dữ liệu...", Duration = 2 })
		if state then
			local encoded25 = HttpService:UrlEncode("Cake Prince")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded25 })
			end)
		else
			local encoded26 = HttpService:UrlEncode("Cake Prince")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded26 })
			end)
		end
		task.wait()
		Window2:Notify({ Title = "Trống", Content = "Hiện tại không có server nào hoạt động", Duration = 3 })
	end
})
local Tab17 = Window2:MakeTab({ Title = "Elite Hunter" })
Tab17:AddSection("Elite Hunter")
Tab17:AddButton({
	Name = "Làm mới danh sách",
	Debounce = 5,
	Callback = function(state, arg128)
		Window2:Notify({ Title = "Đang quét", Content = "Đang tải dữ liệu...", Duration = 2 })
		if state then
			local encoded27 = HttpService:UrlEncode("Diablo")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded27 })
			end)
			task.wait()
			local encoded28 = HttpService:UrlEncode("Deandre")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded28 })
			end)
			task.wait()
			local encoded29 = HttpService:UrlEncode("Urban")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded29 })
			end)
		else
			local encoded30 = HttpService:UrlEncode("Diablo")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded30 })
			end)
			task.wait()
			local encoded31 = HttpService:UrlEncode("Deandre")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded31 })
			end)
			task.wait()
			local encoded32 = HttpService:UrlEncode("Urban")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded32 })
			end)
		end
		task.wait()
		Window2:Notify({ Title = "Trống", Content = "Hiện tại không có server nào hoạt động", Duration = 3 })
	end
})
local Tab18 = Window2:MakeTab({ Title = "Darkbeard" })
Tab18:AddSection("Darkbeard")
Tab18:AddButton({
	Name = "Làm mới danh sách",
	Debounce = 5,
	Callback = function(state, arg130)
		Window2:Notify({ Title = "Đang quét", Content = "Đang tải dữ liệu...", Duration = 2 })
		if state then
			local encoded33 = HttpService:UrlEncode("Darkbeard")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded33 })
			end)
		else
			local encoded34 = HttpService:UrlEncode("Darkbeard")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded34 })
			end)
		end
		task.wait()
		Window2:Notify({ Title = "Trống", Content = "Hiện tại không có server nào hoạt động", Duration = 3 })
	end
})
local Tab19 = Window2:MakeTab({ Title = "Cursed Captain" })
Tab19:AddSection("Cursed Captain")
Tab19:AddButton({
	Name = "Làm mới danh sách",
	Debounce = 5,
	Callback = function(state, arg132)
		Window2:Notify({ Title = "Đang quét", Content = "Đang tải dữ liệu...", Duration = 2 })
		if state then
			local encoded35 = HttpService:UrlEncode("Cursed Captain")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded35 })
			end)
		else
			local encoded36 = HttpService:UrlEncode("Cursed Captain")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded36 })
			end)
		end
		task.wait()
		Window2:Notify({ Title = "Trống", Content = "Hiện tại không có server nào hoạt động", Duration = 3 })
	end
})
local Tab20 = Window2:MakeTab({ Title = "Tyrant of Skies" })
Tab20:AddSection("Tyrant of the Skies")
Tab20:AddButton({
	Name = "Làm mới danh sách",
	Debounce = 5,
	Callback = function(state, arg134)
		Window2:Notify({ Title = "Đang quét", Content = "Đang tải dữ liệu...", Duration = 2 })
		if state then
			local encoded37 = HttpService:UrlEncode("Tyrant of the Skies")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded37 })
			end)
		else
			local encoded38 = HttpService:UrlEncode("Tyrant of the Skies")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded38 })
			end)
		end
		task.wait()
		Window2:Notify({ Title = "Trống", Content = "Hiện tại không có server nào hoạt động", Duration = 3 })
	end
})
local Tab21 = Window2:MakeTab({ Title = "Soul Reaper" })
Tab21:AddSection("Soul Reaper")
Tab21:AddButton({
	Name = "Làm mới danh sách",
	Debounce = 5,
	Callback = function(state, arg136)
		Window2:Notify({ Title = "Đang quét", Content = "Đang tải dữ liệu...", Duration = 2 })
		if state then
			local encoded39 = HttpService:UrlEncode("Soul Reaper")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded39 })
			end)
		else
			local encoded40 = HttpService:UrlEncode("Soul Reaper")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded40 })
			end)
		end
		task.wait()
		Window2:Notify({ Title = "Trống", Content = "Hiện tại không có server nào hoạt động", Duration = 3 })
	end
})
local Tab22 = Window2:MakeTab({ Title = "Mirage Island" })
Tab22:AddSection("Mirage Island")
Tab22:AddButton({
	Name = "Làm mới danh sách",
	Debounce = 5,
	Callback = function(state, arg138)
		Window2:Notify({ Title = "Đang quét", Content = "Đang tải dữ liệu...", Duration = 2 })
		if state then
			local encoded41 = HttpService:UrlEncode("Mirage Island")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded41 })
			end)
			task.wait()
			local encoded42 = HttpService:UrlEncode("MysticIsland")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded42 })
			end)
		else
			local encoded43 = HttpService:UrlEncode("Mirage Island")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded43 })
			end)
			task.wait()
			local encoded44 = HttpService:UrlEncode("MysticIsland")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded44 })
			end)
		end
		task.wait()
		Window2:Notify({ Title = "Trống", Content = "Hiện tại không có server nào hoạt động", Duration = 3 })
	end
})
local Tab23 = Window2:MakeTab({ Title = "Kitsune Island" })
Tab23:AddSection("Kitsune Island")
Tab23:AddButton({
	Name = "Làm mới danh sách",
	Debounce = 5,
	Callback = function(state, arg140)
		Window2:Notify({ Title = "Đang quét", Content = "Đang tải dữ liệu...", Duration = 2 })
		if state then
			local encoded45 = HttpService:UrlEncode("Kitsune Island")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded45 })
			end)
			task.wait()
			local encoded46 = HttpService:UrlEncode("KitsuneIsland")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded46 })
			end)
		else
			local encoded47 = HttpService:UrlEncode("Kitsune Island")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded47 })
			end)
			task.wait()
			local encoded48 = HttpService:UrlEncode("KitsuneIsland")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded48 })
			end)
		end
		task.wait()
		Window2:Notify({ Title = "Trống", Content = "Hiện tại không có server nào hoạt động", Duration = 3 })
	end
})
local Tab24 = Window2:MakeTab({ Title = "Prehistoric Island" })
Tab24:AddSection("Prehistoric Island")
Tab24:AddButton({
	Name = "Làm mới danh sách",
	Debounce = 5,
	Callback = function(state, arg142)
		Window2:Notify({ Title = "Đang quét", Content = "Đang tải dữ liệu...", Duration = 2 })
		if state then
			local encoded49 = HttpService:UrlEncode("Prehistoric Island")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded49 })
			end)
			task.wait()
			local encoded50 = HttpService:UrlEncode("PrehistoricIsland")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded50 })
			end)
		else
			local encoded51 = HttpService:UrlEncode("Prehistoric Island")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded51 })
			end)
			task.wait()
			local encoded52 = HttpService:UrlEncode("PrehistoricIsland")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded52 })
			end)
		end
		task.wait()
		Window2:Notify({ Title = "Trống", Content = "Hiện tại không có server nào hoạt động", Duration = 3 })
	end
})
local Tab25 = Window2:MakeTab({ Title = "Near Full Moon" })
Tab25:AddSection("Sắp Trăng Tròn")
Tab25:AddButton({
	Name = "Làm mới danh sách",
	Debounce = 5,
	Callback = function(state, arg144)
		Window2:Notify({ Title = "Đang quét", Content = "Đang tải dữ liệu...", Duration = 2 })
		if state then
			local encoded53 = HttpService:UrlEncode("Near Full Moon")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded53 })
			end)
		else
			local encoded54 = HttpService:UrlEncode("Near Full Moon")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded54 })
			end)
		end
		task.wait()
		Window2:Notify({ Title = "Trống", Content = "Hiện tại không có server nào hoạt động", Duration = 3 })
	end
})
local Tab26 = Window2:MakeTab({ Title = "Full Moon" })
Tab26:AddSection("Đang Trăng Tròn")
Tab26:AddButton({
	Name = "Làm mới danh sách",
	Debounce = 5,
	Callback = function(state, arg146)
		Window2:Notify({ Title = "Đang quét", Content = "Đang tải dữ liệu...", Duration = 2 })
		if state then
			local encoded55 = HttpService:UrlEncode("Full Moon 5/5")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded55 })
			end)
		else
			local encoded56 = HttpService:UrlEncode("Full Moon 5/5")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded56 })
			end)
		end
		task.wait()
		Window2:Notify({ Title = "Trống", Content = "Hiện tại không có server nào hoạt động", Duration = 3 })
	end
})
local Tab27 = Window2:MakeTab({ Title = "Legendary Swords" })
Tab27:AddSection("Legendary Swords (Sea 2)")
Tab27:AddButton({
	Name = "Làm mới danh sách",
	Debounce = 5,
	Callback = function(state, arg148)
		Window2:Notify({ Title = "Đang quét", Content = "Đang tải dữ liệu...", Duration = 2 })
		if state then
			local encoded57 = HttpService:UrlEncode("Shizu")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded57 })
			end)
			task.wait()
			local encoded58 = HttpService:UrlEncode("Oroshi")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded58 })
			end)
			task.wait()
			local encoded59 = HttpService:UrlEncode("Saishi")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded59 })
			end)
		else
			local encoded60 = HttpService:UrlEncode("Shizu")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded60 })
			end)
			task.wait()
			local encoded61 = HttpService:UrlEncode("Oroshi")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded61 })
			end)
			task.wait()
			local encoded62 = HttpService:UrlEncode("Saishi")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded62 })
			end)
		end --[=[  ]=]
		task.wait()
		Window2:Notify({ Title = "Trống", Content = "Hiện tại không có server nào hoạt động", Duration = 3 })
	end
})
local Tab28 = Window2:MakeTab({ Title = "Factory Raid" })
Tab28:AddSection("Săn Nhà Máy")
Tab28:AddButton({
	Name = "Làm mới danh sách",
	Debounce = 5,
	Callback = function(state, arg150)
		Window2:Notify({ Title = "Đang quét", Content = "Đang tải dữ liệu...", Duration = 2 })
		if state then
			local encoded63 = HttpService:UrlEncode("Core")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded63 })
			end)
			task.wait()
			local encoded64 = HttpService:UrlEncode("Factory Core")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded64 })
			end)
		else
			local encoded65 = HttpService:UrlEncode("Core")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded65 })
			end)
			task.wait()
			local encoded66 = HttpService:UrlEncode("Factory Core")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded66 })
			end)
		end
		task.wait()
		Window2:Notify({ Title = "Trống", Content = "Hiện tại không có server nào hoạt động", Duration = 3 })
	end
})
local Tab29 = Window2:MakeTab({ Title = "Sweet Chalice" })
Tab29:AddSection("Sweet Chalice")
Tab29:AddButton({
	Name = "Làm mới danh sách",
	Debounce = 5,
	Callback = function(state, arg152)
		Window2:Notify({ Title = "Đang quét", Content = "Đang tải dữ liệu...", Duration = 2 })
		if state then
			local encoded67 = HttpService:UrlEncode("Sweet Chalice")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded67 })
			end)
		else
			local encoded68 = HttpService:UrlEncode("Sweet Chalice")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded68 })
			end)
		end
		task.wait()
		Window2:Notify({ Title = "Trống", Content = "Hiện tại không có server nào hoạt động", Duration = 3 })
	end
})
local Tab30 = Window2:MakeTab({ Title = "Fist of Darkness" })
Tab30:AddSection("Fist of Darkness")
Tab30:AddButton({
	Name = "Làm mới danh sách",
	Debounce = 5,
	Callback = function(state, arg154)
		Window2:Notify({ Title = "Đang quét", Content = "Đang tải dữ liệu...", Duration = 2 })
		if state then
			local encoded69 = HttpService:UrlEncode("Fist of Darkness")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded69 })
			end) -- 
		else
			local encoded70 = HttpService:UrlEncode("Fist of Darkness")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded70 })
			end)
		end
		task.wait()
		Window2:Notify({ Title = "Trống", Content = "Hiện tại không có server nào hoạt động", Duration = 3 })
	end
})
local Tab31 = Window2:MakeTab({ Title = "God's Chalice" })
Tab31:AddSection("God's Chalice")
Tab31:AddButton({
	Name = "Làm mới danh sách",
	Debounce = 5,
	Callback = function(state, arg156)
		Window2:Notify({ Title = "Đang quét", Content = "Đang tải dữ liệu...", Duration = 2 })
		if state then
			local encoded71 = HttpService:UrlEncode("God's Chalice")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded71 })
			end)
		else
			local encoded72 = HttpService:UrlEncode("God's Chalice")
			task.spawn(function(...)
				request({ Method = "GET", Url = "https://realkidapi.online/api.php" .. "?placeId=" .. "0" .. "&target=" .. encoded72 })
			end)
		end
		task.wait()
		Window2:Notify({ Title = "Trống", Content = "Hiện tại không có server nào hoạt động", Duration = 3 })
	end
})
