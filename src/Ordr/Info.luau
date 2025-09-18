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
				Alternate = { "All" }, --> Essentially you can either type the name of the player from the list, or the alternate argument of "All"
			},
			{
				Name = "Reason",
				Type = "string",
				Description = "The reason displayed when the player is kicked.",
				Optional = true, --> This parameter is optional.
			},
		},
	},

	["Bring"] = {
		Description = "Bring a player to yourself.",
		Level = "Junior Moderator",
		Aliases = { "Grab" },
		Parameters = {
			{
				Name = "Target",
				Description = "The target who will be grabbed.",
				List = "Players",
				Type = "Player",
				Alternate = { "All" },
			},
		},
	},

	["Kill"] = {
		Description = "Kill the specified target.",
		Level = "Moderator",
		Aliases = { "Reset", "Refresh", "Respawn" },
		Parameters = {
			{
				Name = "Victim",
				Description = "The player who will be killed.",
				List = "Players",
				Type = "Player",
				Alternate = { "All" },
			},
		},
	},
}
