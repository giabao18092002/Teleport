local PlaceID = game.PlaceId
local AllIDs = {}
local foundAnything = ""
local actualHour = os.date("!*t").hour
local Deleted = false
local loop = game:GetService("RunService").RenderStepped
local File = pcall(function()
	AllIDs = game:GetService('HttpService'):JSONDecode(readfile("ServerHop.json"))
end)
if not File then
	table.insert(AllIDs, actualHour)
	writefile("ServerHop.json", game:GetService('HttpService'):JSONEncode(AllIDs))
end
function TPReturner()
	local Site;
	if foundAnything == "" then
		Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100'))
	else
		Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100&cursor=' .. foundAnything))
	end
	local ID = ""
	if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then
		foundAnything = Site.nextPageCursor
	end
	local num = 0;
	for i,v in pairs(Site.data) do
		local Possible = true
		ID = tostring(v.id)
		if tonumber(v.maxPlayers) > tonumber(v.playing) and tonumber(v.playing) > 18  then
			for _,Existing in pairs(AllIDs) do
				if num ~= 0 then
					if ID == tostring(Existing) then
						Possible = false
					end
				else
					if tonumber(actualHour) ~= tonumber(Existing) then
						local delFile = pcall(function()
							delfile("ServerHop.json")
							AllIDs = {}
							table.insert(AllIDs, actualHour)
						end)
					end
				end
				num = num + 1
			end
			if Possible == true then
				table.insert(AllIDs,ID)
				wait()
				pcall(function()
					writefile("ServerHop.json", game:GetService('HttpService'):JSONEncode(AllIDs))
					game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, ID, game.Players.LocalPlayer)
				end)
				loop:Wait()
			end
		end
	end
end
function Teleport()
	while true do
		pcall(function()
			TPReturner()
			if foundAnything ~= "" then
				TPReturner()
			end
		end)
		loop:Wait()
	end
end
return Teleport
