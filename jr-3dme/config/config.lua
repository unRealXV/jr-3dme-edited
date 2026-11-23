Config = {}

Config.Language = "German"                             -- English, Dutch, German

Config.MaxLength = 100                                  -- max length of the message
Config.Notify = "vorp"                                  -- you can add your own notify system in client.lua default is vorp, chat or none

Config.Commands = {
    Me = {
        Enabled = true,                                 -- false
        Command = "me",                                 -- /me
        Distance = 50,                                  -- display distance
        DisplayTime = 7000,                             -- display time
        Format = "* %s *",                              -- how it should be displayed
        Color = { 255, 143, 0, 255 },                   -- color of the message
    },
    Do = {
        Enabled = true,
        Command = "do",                                 -- /do whatever you wanna do
        Distance = 50,
        DisplayTime = 7000,
        Format = "* %s *",
        Color = { 100, 180, 255, 255 },
    },
    Status = {
        Enabled = true,
        Command = "status",                                -- status like /status drunk
        Distance = 30,
        DisplayTime = 700000,
        Format = "* %s *",
        Color = { 200, 200, 200, 255 },
    },
    -- add more commands as you wish
}