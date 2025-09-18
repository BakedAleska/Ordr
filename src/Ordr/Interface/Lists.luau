local Players = game:GetService("Players")

return {
	["Players"] = function()
		local Received = {}
		for _, P in ipairs(Players:GetPlayers()) do
			table.insert(Received, P.Name)
		end
		return Received
	end,
}
