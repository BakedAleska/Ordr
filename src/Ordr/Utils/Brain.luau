--------------
-- SERVICES --
--------------
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local IsServer = RunService:IsServer()

------------
-- IMPORTS --
------------
local Execution = require(ReplicatedStorage.Ordr.Execution)
local Info = require(ReplicatedStorage.Ordr.Info)
local Network = require(script.Parent.Network)
local Registry = require(ReplicatedStorage.Ordr.Services.Registry)

local RegistryInstance = Registry.new()

local Brain = {}

if IsServer then
	---------
	-- SERVER
	---------
	Network.Init()

	-- Set up hierarchy
	RegistryInstance:InitializeHierarchy({
		"Players",
		"Junior Moderator",
		"Moderator",
		"Owner",
	})

	-- Assign groups to specific user IDs
	RegistryInstance:InitializeGroups({
		[2288684740] = "Moderator", -- The_Pho3n1x
		[5106100492] = "Owner", -- L0rses
		[32084843] = "Moderator", -- TrollarchOffice
		[42513679] = "Junior Moderator", -- Blight
	})

	-- Register command execution module
	RegistryInstance:RegisterExecution(Execution)
	RegistryInstance:RegisterInfo(Info)

	local Command = require(ReplicatedStorage.Ordr.Services.Command)
	Command.Registry = RegistryInstance
	-- Handle incoming commands
	Network.Receive("Command", function(Player: Player, Cmd: string)
		Command:Execute(Player, Cmd)
	end)
else
	---------
	-- CLIENT
	---------
	Network.Init()

	local Player = Players.LocalPlayer

	-- Set up interface
	local Create = require(ReplicatedStorage.Ordr.Interface.Create)
	local Display = Create()
	Display.Parent = Player.PlayerGui

	-- Register command info and activation keys
	RegistryInstance:RegisterInfo(Info)
	RegistryInstance:SetActivationKeys({ Enum.KeyCode.F2 })

	-- Set up controller
	local Controller = require(ReplicatedStorage.Ordr.Interface.Controller)
	Controller.Registry = RegistryInstance
end

return Brain
