--!nonstrict
-- Network Module
-- Author: BakedAleska
-- Date: 09/18/2025

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local IsServer = RunService:IsServer()
local EVENT_NAME = "OrdrRemoteEvent"
local FUNCTION_NAME = "OrdrRemoteFunction"

local Network = {}
Network.__index = Network

-- Singleton tables
local Hooks = {}
local Cache = {}

-- Remotes folder in ReplicatedStorage
local Folder = ReplicatedStorage:FindFirstChild("OrdrRemotes")
if not Folder then
	Folder = Instance.new("Folder")
	Folder.Name = "OrdrRemotes"
	Folder.Parent = ReplicatedStorage
end

-- Utility to get or create Remote
local function Get(Name: string, Class: "RemoteEvent" | "RemoteFunction")
	if Cache[Name] and Cache[Name].Parent then
		return Cache[Name]
	end

	local Remote = Folder:FindFirstChild(Name)
	if not Remote then
		Remote = Instance.new(Class)
		Remote.Name = Name
		Remote.Parent = Folder
	end

	Cache[Name] = Remote
	return Remote
end

-- Initialize remotes and connections
function Network.Init()
	local Event = Get(EVENT_NAME, "RemoteEvent") :: RemoteEvent
	local Function = Get(FUNCTION_NAME, "RemoteFunction") :: RemoteFunction

	if IsServer then
		Event.OnServerEvent:Connect(function(Player, Hook, ...)
			local Handler = Hooks[Hook]
			if Handler and Handler.Event then
				Handler.Event(Player, ...)
			end
		end)

		Function.OnServerInvoke = function(Player, Hook, ...)
			local Handler = Hooks[Hook]
			if Handler and Handler.Function then
				return Handler.Function(Player, ...)
			end
			return nil
		end
	else
		Event.OnClientEvent:Connect(function(Hook, ...)
			local Handler = Hooks[Hook]
			if Handler and Handler.Event then
				Handler.Event(...)
			end
		end)

		Function.OnClientInvoke = function(Hook, ...)
			local Handler = Hooks[Hook]
			if Handler and Handler.Function then
				return Handler.Function(...)
			end
			return nil
		end
	end
end

-- Client → Server
function Network.Send(Hook: string, ...)
	local Remote = Get(EVENT_NAME, "RemoteEvent") :: RemoteEvent
	Remote:FireServer(Hook, ...)
end

-- Server → Client
function Network.Broadcast(Hook: string, ...)
	local Remote = Get(EVENT_NAME, "RemoteEvent") :: RemoteEvent
	Remote:FireAllClients(Hook, ...)
end

-- Hooks
function Network.Receive(Hook: string, Callback: (...any) -> ())
	Hooks[Hook] = Hooks[Hook] or {}
	Hooks[Hook].Event = Callback
end

function Network.Handle(Hook: string, Callback: (Player, ...any) -> any)
	Hooks[Hook] = Hooks[Hook] or {}
	Hooks[Hook].Function = Callback
end

-- Optional: Fetch for ServerInvoke
function Network.Fetch(Hook: string, ...)
	local Remote = Get(FUNCTION_NAME, "RemoteFunction") :: RemoteFunction
	return Remote:InvokeServer(Hook, ...)
end

function Network.Flush()
	table.clear(Hooks)
	table.clear(Cache)
end

return Network
