--!nonstrict

local Players = game:GetService("Players")

return {
	["Kick"] = {
		Level = "Moderator",
		Run = function(Executor: Player, Target: Player, Text: string?)
			local Reason = Text or "No reason provided"

			if typeof(Target) == "string" and Target == "All" then
				for _, Listed in pairs(Players:GetPlayers()) do
					Listed:Kick("Kicked by: " .. Executor.Name .. " | Reason: " .. Reason)
				end
				return
			end

			Target:Kick("Kicked by: " .. Executor.Name .. " | Reason: " .. Reason)
		end,
	},
	["Bring"] = {
		Level = "Junior Moderator",
		Run = function(Executor: Player, Target: Player)
			local ExecutorCharacter = Executor.Character :: Model

			if typeof(Target) == "string" and Target == "All" then
				for _, Listed in pairs(Players:GetPlayers()) do
					local TargetCharacter = Listed.Character :: Model
					TargetCharacter:PivotTo(ExecutorCharacter:GetPivot())
				end
				return
			end

			local TargetCharacter = Target.Character :: Model
			TargetCharacter:PivotTo(ExecutorCharacter:GetPivot())
		end,
	},
	["Kill"] = {
		Level = "Moderator",
		Run = function(_, Target: Player)
			if typeof(Target) == "string" and Target == "All" then
				for _, Listed in pairs(Players:GetPlayers()) do
					Listed:LoadCharacter()
				end
				return
			end

			Target:LoadCharacter()
		end,
	},
}
