--[[
local http_request = http_request or request or HttpPost or syn.request
local sus = {}
lplayer = game:GetService("Players").LocalPlayer
local httpservice = game:GetService("HttpService")
if not http_request then 
	lplayer:kick("Unsupported Executor")
	return
end

game:GetService('Players').PlayerAdded:Connect(function(player)
	player.Changed:connect(function(change)
		if change == "UserId" or change == "Name" then
			lplayer:Kick("\n[Built in RAYX Security KICK 3]\n DO NOT Alter User Information.\n[Built in RAYX security, relaunch script without altering user information. eg: Username/UserId]"); return;
		end
	end)
end)

local function getDataByUsername(username, maxAttempts)
	for i=1, maxAttempts do
		local success, res = pcall(function() 
			local re = http_request({
				Url = 'https://api.roblox.com/users/get-by-username?username='..username,
				Method = 'GET',
				Headers = {
					['Content-Type'] = 'application/json'
				}
			})
			return re
		end)
		if success and res.Success then
			return httpservice:JSONDecode(res['Body']);
		end
		warn("Unexpected error unpacking data: RETRYING "..i.."...")
	end
	lplayer:Kick("Unexpected error while loading RAYX! (check your internet connection)");
	return
end
local function compareUser(user)
	local character = user.Character or user.CharacterAdded:Wait()
	return not (user.UserId ~= tonumber(user.CharacterAppearance:split("userId=")[2]) or character.Name ~= user.Name)
end
local function checkUserOutfit(user, maxAttempts)
	for i=1, maxAttempts do
		local success, value = pcall(function()
			repeat wait() until user.Character
			local character = user.Character or user.CharacterAdded:Wait()
			local bruh = game.Players:GetHumanoidDescriptionFromUserId(user.UserId) 
			local loc = character:FindFirstChild('Humanoid'):GetAppliedDescription()
			return bruh.Face == loc.Face and bruh.Head == loc.Head and bruh.Pants == loc.Pants and bruh.Shirt == loc.Shirt and bruh.Torso == loc.Torso and bruh.LeftArm == loc.LeftArm and bruh.RightArm == loc.RightArm and bruh.LeftLeg == loc.LeftLeg and bruh.RightLeg == loc.RightLeg and bruh.HeadColor == loc.HeadColor and bruh.TorsoColor == loc.TorsoColor and bruh.LeftArmColor == loc.LeftArmColor and bruh.LeftLegColor == loc.LeftLegColor and bruh.FallAnimation == loc.FallAnimation and bruh.GraphicTShirt == loc.GraphicTShirt and bruh.IdleAnimation == loc.IdleAnimation and bruh.JumpAnimation == loc.JumpAnimation and bruh.RightArmColor == loc.RightArmColor and bruh.RightLegColor == loc.RightLegColor and bruh.SwimAnimation == loc.SwimAnimation and bruh.WalkAnimation == loc.WalkAnimation and bruh.ClimbAnimation == loc.ClimbAnimation
		end)
		if success then return value end
		warn("Unexpected error unpacking data: RETRYING "..i.."...")
	end
	lplayer:Kick("Unexpected error while loading RAYX! (check your internet connection)");
	return
end
local function checkOnlineStatus(UserId, maxAttempts)
	for i=1, maxAttempts do
		local successC, resC = pcall(function() 
			local re = http_request({
				Url = 'https://api.roblox.com/users/'..UserId..'/onlinestatus/',
				Method = 'GET',
				Headers = {
					['Content-Type'] = 'application/json'
				}
			})
			return re
		end)
		if successC and resC.Success then
			return httpservice:JSONDecode(resC['Body']);
		end
		warn("Unexpected error unpacking data: RETRYING "..i.."...")
	end
	lplayer:Kick("Unexpected error while loading RAYX! (Rejoin/Check your internet connection)");
end
local function checkForSus(user, maxAttempts)
	local status = checkOnlineStatus(user.UserId, maxAttempts)
	local outfitCheck = checkUserOutfit(user, maxAttempts)
	local char = lplayer.Character or lplayer.CharacterAdded
	if not (status.IsOnline or status.LastLocation:split(' ')[1] ~= 'Offline') or not outfitCheck then
		print('sus found')
		if user == lplayer then char:FindFirstChild('Humanoid').Parent = nil; char.Parent = nil; end
		sus[user] = user.CharacterAdded:connect(function(character)
			if character.Name == user.Name then
				sus[user]:Disconnect()
				sus[user] = nil
			else
				lplayer:Kick("\n[Built in RAYX Security KICK 199]\n DO NOT Alter User Information.\n[Built in RAYX security, relaunch script without altering user information. eg: Username/UserId]"); sus[user]:Disconnect(); sus[user] = nil;
			end
		end)
		return
	end
end
local function checkValidity(user, maxRetry)
	local data = getDataByUsername(user.Name, maxRetry)
	if data.Id ~= user.UserId or data.Username ~= user.Name then return false; end
	user.Changed:connect(function(change)
		if change == "UserId" or change == "Name" then
			lplayer:Kick("\n[Built in RAYX Security KICK 2]\n DO NOT Alter User Information.\n[Built in RAYX security, relaunch script without altering user information. eg: Username/UserId]"); return true;
		end
	end)
	task.spawn(function()
		checkForSus(user, 32)
	end)
	return compareUser(user)
end

for _,v in pairs(game:GetService("Players"):GetPlayers()) do
	task.spawn(function()
		local comparison = compareUser(v)
		if not comparison then return lplayer:Kick("\n[Built in RAYX Security KICK 0]\n DO NOT Alter User Information.\n[Built in RAYX security, relaunch script without altering user information. eg: Username/UserId]") end
	end)
	local check = checkValidity(v, 32)
	wait()
	if not check then lplayer:Kick("\n[Built in RAYX Security KICK 1]\n DO NOT Alter User Information.\n[Built in RAYX security, relaunch script without altering user information. eg: Username/UserId]") return; end
end


game:GetService('Players').PlayerChatted:Connect(function(PlayerChatType, sender, message, recipient)
	local conn = getmsg.OnClientEvent:Connect(function(packet, channel)
		if packet.SpeakerUserId ~= sender.UserId and packet.Message == message:sub(#message-#packet.Message+1) and (channel == "All" or (channel == "Team" and game:GetService('Players')[packet.FromSpeaker].Team == sender.Team)) then
			lplayer:Kick("\n[Built in RAYX Security KICK 2]\n DO NOT Alter User Information.\n[Built in RAYX security, relaunch script without altering user information. eg: Username/UserId]")
		end
	end)
	wait(1)
	conn:Disconnect()
end)
]]--
