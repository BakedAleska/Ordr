--!nonstrict
-- @author : BakedAleska
-- @date : 09/18/2025

--------------
-- SERVICES --
--------------
local RunService = game:GetService("RunService")

------------
-- IMPORT --
------------
local Parser = require(script.Parent.Parser)

--> Declare
local Command = {
	Registry = nil,
}

function Command:Execute(Player: Player, Cmd: string): boolean
	if RunService:IsClient() then
		return false
	end

	if not self.Registry or not self.Registry.Execution then
		return false
	end

	local Parsed = Parser:Parse(Cmd)
	local Execution = self.Registry.Execution[Parsed.Command]

	if not Execution then
		return false
	end

	if not self.Registry:Can(Player, Parsed.Command) then
		return false
	end

	local Matched = Parser:Match(self.Registry, Parsed.Command, Parsed.Args)

	Execution.Run(Player, table.unpack(Matched))

	return true
end

return Command
