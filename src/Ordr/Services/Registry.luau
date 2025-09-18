--!strict
-- @author : BakedAleska
-- @date : 09/17/2025

-- "In seeking the unattainable, simplicity only gets in the way."

--[[
@Description : 
]]

--------------
-- SERVICES --
--------------
local RunService = game:GetService("RunService")

-------------
-- MODULES --
-------------

---------------
-- VARIABLES --
---------------
local IsServer = RunService:IsServer()

--> Declare
local Registry = {}
Registry.__index = Registry

function Registry.new()
	local self = setmetatable({
		--Hierarchy = {}, --> Holds hierarchy, is initialized in run time only on the server.
		Execution = {}, --> Holds command execution (this table is empty on the client.)
		Info = {}, --> Holds command info (this table is empty on the server.)=
	}, Registry)

	return self
end

function Registry:InitializeHierarchy(List: { string })
	if not IsServer then
		warn("[Registry : Hierarchy] Cannot be run on the client due to safety concerns.")
		return
	end

	self.Hierarchy = List
end

function Registry:InitializeGroups(List: { [number]: string })
	if not IsServer then
		warn("[Registry : ConfigureLevelGroups] Cannot run on the client due to safety concerns.")
		return
	end

	self.Groups = self.Groups or {}

	for Id, Name in pairs(List) do
		self.Groups[Id] = Name
	end
end

function Registry:Can(Player: Player, Command: string): boolean
	if not IsServer then
		warn("[Registry : Can] Cannot be run on the client due to safety concerns.")
		return false
	end

	if not self.Hierarchy then
		warn("[Registry : Can] No valid hierarchy set up.")
		return false
	end

	local Cmd = self.Execution[Command]
	if not Cmd then
		warn("[Registry : Can] Cannot find a valid command corresponding to name:", Command)
		return false
	end

	local RequiredLevel = Cmd.Level or "Player"
	local PlayerGroup = (self.Groups and self.Groups[Player.UserId]) or "Player"

	local RequiredIndex = table.find(self.Hierarchy, RequiredLevel)
	local PlayerIndex = table.find(self.Hierarchy, PlayerGroup)

	if not RequiredIndex or not PlayerIndex then
		warn("[Registry : Can] Invalid group in hierarchy")
		return false
	end

	return PlayerIndex >= RequiredIndex
end

function Registry:SetActivationKeys(Keys: { Enum.KeyCode })
	if not Keys or type(Keys) ~= "table" then
		warn("[Registry:SetActivationKeys] Invalid keys table")
		return
	end

	self.ActivationKeys = {}

	for _, Key in ipairs(Keys) do
		if typeof(Key) == "EnumItem" and Key.EnumType == Enum.KeyCode then
			self.ActivationKeys[Key] = true
		else
			warn("[Registry:SetActivationKeys] Invalid key:", Key)
		end
	end
end

function Registry:RegisterExecution(Table: { [string]: { Run: (...any) -> (), Level: string } })
	if not IsServer then
		warn("[Registry : RegisterExecution] Cannot run on client.")
		return
	end

	if type(Table) ~= "table" then
		warn("[Registry : RegisterExecution] Invalid table provided")
		return
	end

	for Name, Data in pairs(Table) do
		if type(Data.Run) ~= "function" then
			warn("[Registry : RegisterExecution] Run must be a function for command:", Name)
		else
			self.Execution[Name] = {
				Run = Data.Run,
				Level = Data.Level or "Player",
			}
		end
	end
end

function Registry:RegisterInfo(Table: {
	[string]: { Description: string, Level: string?, Aliases: { string }?, Parameters: { [number]: any }? },
})
	if type(Table) ~= "table" then
		warn("[Registry : RegisterInfo] Invalid table provided")
		return
	end

	for Name, Data in pairs(Table) do
		self.Info[Name] = Data
	end
end

return Registry

-----------
-- TYPES --
-----------
