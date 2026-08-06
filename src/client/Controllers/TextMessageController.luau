local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

local Net = ReplicatedStorage:WaitForChild("Net") :: Folder
local TextMessageEvent = Net:WaitForChild("TextMessage") :: RemoteEvent

local general = TextChatService:WaitForChild("TextChannels").RBXGeneral :: TextChannel

local TextMessageController = {}

function TextMessageController:Load()
	TextMessageEvent.OnClientEvent:Connect(function(textMessage: string)
		general:DisplaySystemMessage(textMessage)
	end)
end

return TextMessageController
