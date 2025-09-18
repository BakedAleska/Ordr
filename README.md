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
return {
    ["Kick"] = {
        Description = "Kick a player.",
        Level = "Moderator",
        Aliases = { "Remove", "Force" },
        Parameters = {
            {
                Name = "Player",
                Description = "The player who will be kicked.",
                List = "Players",
                Alternate = { "All" },
            },
            {
                Name = "Reason",
                Description = "Optional reason for kicking.",
            }
        }
    }
}
