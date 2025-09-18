# Ordr
Ordr is a lightweight, extensible moderator panel for Roblox — inspired by [evaera’s Cmdr](https://github.com/evaera/Cmdr).  
It provides a consistent way to register, parse, and execute commands securely, with execution logic kept on the server.

This is my first attempt at releasing something like this publicly, so any and all constructive criticism is appreciated!

---

## Features
- Permission levels for controlling who can run each command  
- Extensible command system with clear parameter definitions  
- Argument parsing with support for aliases and alternate values  
- Server-sided execution with a minimal client layer  
- Modular and easy to expand with custom commands  

---

## Example Command

```lua
--!nonstrict

local Players = game:GetService("Players")

-- Execution (Execution/Kick.lua)
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
}

-- Info (Info/Kick.lua)
return {
	["Kick"] = {
		Description = "Kick a player.",
		Level = "Moderator", --> Refers to the minimum level needed to run this command.
		Aliases = { "Remove", "Force" },
		Parameters = {
			{
				Name = "Target",
				Description = "The target who will be kicked.",
				List = "Players",
				Type = "Player",
				Alternate = { "All" }, --> Either type a player’s name or the alternate argument "All".
			},
			{
				Name = "Reason",
				Type = "string",
				Description = "The reason displayed when the player is kicked.",
				Optional = true, --> This parameter is optional.
			},
		},
	}
}
