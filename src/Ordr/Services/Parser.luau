--!nonstrict
-- @author : BakedAleska
-- @date : 09/18/2025

--> Declare
local Parser = {}

-----------------------
-- PRIVATE FUNCTIONS --
-----------------------
local function Coerce_Argument(Arg: string, Type: string)
	if Type == "Player" then
		local Players = game:GetService("Players")
		return Players:FindFirstChild(Arg)
	elseif Type == "Part" then
		return workspace:FindFirstChild(Arg)
	elseif Type == "Vector3" then
		local x, y, z = string.match(Arg, "([^,]+),([^,]+),([^,]+)")
		if x and y and z then
			return Vector3.new(tonumber(x), tonumber(y), tonumber(z))
		end
		return nil
	else
		if Type == "string" then
			return Arg
		elseif Type == "number" then
			return tonumber(Arg)
		elseif Type == "boolean" then
			return Arg == "true"
		end
	end

	return nil
end

----------------------
-- PUBLIC FUNCTIONS --
----------------------
function Parser:Parse(Command: string)
	local Result = { Command = nil, Args = {} }
	if not Command or Command == "" then
		return Result
	end

	local Index = 1
	for Token in Command:gmatch("%S+") do
		Token = Token:gsub('^"(.*)"$', "%1")
		if Index == 1 then
			Result.Command = Token
		else
			table.insert(Result.Args, Token)
		end
		Index += 1
	end
	return Result
end

function Parser:Match(Registry: any, Command: string, Args): any?
	local Parameters = Registry.Info[Command].Parameters

	local Arguments = {}

	for Index, Arg in pairs(Args) do
		local Parameter = Parameters[Index]

		if not Parameter then
			print("No parameter found at index", Index)
			continue
		end

		local Alternate = false
		if Parameter.Alternate then
			for _, Alt in ipairs(Parameter.Alternate) do
				if Arg == Alt then
					table.insert(Arguments, Arg)
					Alternate = true
					break
				end
			end
		end

		if not Alternate then
			local Coerced = Coerce_Argument(Arg, Parameter.Type)
			if not Coerced then
				warn("[Parser] Failed to coerce type.")
				return
			else
				table.insert(Arguments, Coerced)
			end
		end
	end

	return Arguments
end

return Parser
