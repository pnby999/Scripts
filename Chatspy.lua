ENABLE = true
SPYLOCALPLAYER = true
PUBLIC = false
PUBLICITALICS = true
PRIVATE = {
	Color = Color3.fromRGB(0, 255, 255); 
	Font = Enum.Font.GothamBlack;
	TextSize = 15;
}

local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local saymsg = game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest")
local getmsg = game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("OnMessageDoneFiltering")
local instance = (_G.chatSpyInstance or 0) + 1
_G.chatSpyInstance = instance

local function Command(p, msg)
	if _G.chatSpyInstance == instance then
		if p == player and msg:lower():sub(1,4) == "/spy" then
			ENABLE = not ENABLE
			wait(0.3)
			PRIVATE.Text = "[CHAT SPY "..(ENABLE and "EN" or "DIS").."ABLED]"
			StarterGui:SetCore("ChatMakeSystemMessage", PRIVATE)
		elseif ENABLE and (SPYLOCALPLAYER == true or p~=player) then
			msg = msg:gsub("[\n\r]",''):gsub("\t",' '):gsub("[ ]+",' ')
			local hidden = true
			local conn = getmsg.OnClientEvent:Connect(function(packet, channel)
				if packet.SpeakerUserId == p.UserId and packet.Message == msg:sub(#msg-#packet.Message+1) and (channel == "All" or (channel == "Team" and PUBLIC == false and Players[packet.FromSpeaker].Team == player.Team)) then
					hidden = false
				end
			end)
			wait(1)
			conn:Disconnect()
			if hidden and ENABLE then
				if PUBLIC then
					saymsg:FireServer((PUBLICITALICS and "/me " or '').."[CHAT SPY] [".. p.Name .."]: "..msg,"All")
				else
					PRIVATE.Text = "[Lucifer | Chat Spy] [".. p.Name .."]: "..msg
					StarterGui:SetCore("ChatMakeSystemMessage", PRIVATE)
				end
			end
		end
	end
end

for _,p in ipairs(Players:GetPlayers()) do
	p.Chatted:Connect(function(msg) 
		Command(p,msg) 
	end)
end

Players.PlayerAdded:Connect(function(p)
	p.Chatted:Connect(function(msg) 
		Command(p,msg) 
	end)
end)

PRIVATE.Text = "[CHAT SPY "..(ENABLE and "EN" or "DIS").."ABLED]"
StarterGui:SetCore("ChatMakeSystemMessage", PRIVATE)
local chatFrame = player.PlayerGui.Chat.Frame
chatFrame.ChatChannelParentFrame.Visible = true
chatFrame.ChatBarParentFrame.Position = chatFrame.ChatChannelParentFrame.Position+UDim2.new(UDim.new(),chatFrame.ChatChannelParentFrame.Size.Y)

local http_request = http_request or request or syn.request;
local a = {
	['cmd'] = 'INVITE_BROWSER',
	['args'] = {
		["code"] = '2DPYrHfZ2B'
	},
	['nonce'] = game:GetService('HttpService'):GenerateGUID(true)
}

http_request({
	Url = 'http://127.0.0.1:6463/rpc?v=1',
	Method = 'POST',
	Headers = {
		['Content-Type'] = 'application/json',
		['Origin'] = 'https://discord.com'
	},
	Body = game:GetService('HttpService'):JSONEncode(a)
})
