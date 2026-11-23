local DICT = "feeds"         -- Textur-Dictionary
local TEXT_HEIGHT = 1.0         

local displays = {}             
local loopRunning = false

for cmdType, cfg in pairs(Config.Commands) do
    if cfg.Enabled then
        RegisterCommand(cfg.Command, function(_, args)
            TriggerServerEvent('jr-3dme:shareDisplay', cmdType, table.concat(args, ' '))
        end, false)
    end
end

-- notify change here --

local function Notify(msg)
    local mode = Config.Notify

    if mode == "vorp" then
        TriggerEvent("vorp:TipRight", msg, 4000)
    elseif mode == "chat" then
        TriggerEvent('chat:addMessage', { color = { 255, 80, 80 }, args = { "JR-3DME", msg } })
    end
end

----------------------------------------------------------------------------
RegisterNetEvent('jr-3dme:notify')
AddEventHandler('jr-3dme:notify', function(msg)
    if type(msg) == "string" then
        Notify(msg)
    end
end)

local function DrawText3D(x, y, z, text, color, drawBackground)
    local onScreen, _x, _y = GetScreenCoordFromWorldCoord(x, y, z)
    if not onScreen then return end

    local str = CreateVarString(10, "LITERAL_STRING", text, Citizen.ResultAsLong())
    local factor = (utf8.len(text) or #text) / 225

    SetTextScale(0.30, 0.30)
    SetTextFontForCurrentCommand(1)
    SetTextColor(color[1], color[2], color[3], color[4])
    SetTextCentre(1)
    DisplayText(str, _x, _y)

    if drawBackground then
        DrawSprite(DICT, "toast_bg", _x, _y + 0.0125, 0.015 + factor, 0.03, 0.1, 20, 20, 20, 200, 0)
    end
end

local function StartLoop()
    if loopRunning then return end
    loopRunning = true

    CreateThread(function()
        while next(displays) do
            Wait(0)

            local dictLoaded = HasStreamedTextureDictLoaded(DICT)
            if not dictLoaded then
                RequestStreamedTextureDict(DICT, false)
            end

            local now = GetGameTimer()
            local myCoords = GetEntityCoords(PlayerPedId())

            for id, d in pairs(displays) do
                if now >= d.endTime then
                    displays[id] = nil
                else
                    local player = GetPlayerFromServerId(id)

                    if player ~= -1 then
                        local ped = GetPlayerPed(player)

                        if DoesEntityExist(ped) then
                            local c = GetEntityCoords(ped)
                            local dx, dy, dz = c.x - myCoords.x, c.y - myCoords.y, c.z - myCoords.z

                            if (dx * dx + dy * dy + dz * dz) < d.maxDist then
                                DrawText3D(c.x, c.y, c.z + TEXT_HEIGHT, d.text, d.color, dictLoaded)
                            end
                        end
                    end
                end
            end
        end

        loopRunning = false
    end)
end

RegisterNetEvent('jr-3dme:triggerDisplay')
AddEventHandler('jr-3dme:triggerDisplay', function(cmdType, text, serverId)
    local cfg = Config.Commands[cmdType]
    if not cfg or type(text) ~= "string" or type(serverId) ~= "number" then return end

    displays[serverId] = {
        text = string.format(cfg.Format, text),
        endTime = GetGameTimer() + cfg.DisplayTime,
        maxDist = (cfg.Distance or 50) ^ 2, -- Meter -> quadrierte Distanz
        color = cfg.Color,
    }

    StartLoop()
end)