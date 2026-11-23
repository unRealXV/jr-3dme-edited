local T = Translation.Langs[Config.Language] or Translation.Langs.English

local function LogsActive()
    local hook = Config.Logs and Config.Logs.Webhook
    return Config.Logs and Config.Logs.Enable and type(hook) == "string" and hook ~= ""
end

local function Sanitize(str)
    str = tostring(str or "")
    str = str:sub(1, Config.Logs.MaxLength or 1000)
    str = str:gsub("([\\`*_~|>])", "\\%1")
    str = str:gsub("@", "@\226\128\139")
    return str
end

local function SendWebhookMessage(title, message)
    PerformHttpRequest(Config.Logs.Webhook, function() end, 'POST', json.encode({
        username = Config.Logs.Name,
        avatar_url = Config.Logs.Avatar,
        allowed_mentions = { parse = {} }, -- niemals jemanden anpingen
        embeds = {
            {
                color = Config.Logs.Color,
                author = {
                    name = Config.Logs.Name,
                    icon_url = Config.Logs.Logo
                },
                title = title,
                description = message,
                footer = {
                    text = Config.Logs.FooterText .. " - " .. os.date("%d.%m.%Y %H:%M:%S"),
                    icon_url = Config.Logs.FooterLogo,
                },
            },
        },
    }), { ['Content-Type'] = 'application/json' })
end

local lastUse = {}
local lastNotify = {}

AddEventHandler('playerDropped', function()
    lastUse[source] = nil
    lastNotify[source] = nil
end)

local function CleanText(text)
    if type(text) ~= "string" then return nil end

    text = text:gsub("%c", " ")
    text = text:gsub("~", "")
    text = text:gsub("^%s+", ""):gsub("%s+$", "")
    if text == "" then return nil end

    local len = utf8.len(text)
    if not len then return nil end         -- ungueltiges UTF-8

    local max = Config.MaxLength or 100
    if len > max then
        text = text:sub(1, utf8.offset(text, max + 1) - 1)
    end

    return text
end

local function SendToNearby(src, cmdType, text, distance)
    local srcPed = GetPlayerPed(src)

    -- Ped nicht gefunden: Text wenigstens dem Sender selbst zeigen
    if not srcPed or srcPed == 0 then
        TriggerClientEvent('jr-3dme:triggerDisplay', src, cmdType, text, src)
        return
    end

    local origin = GetEntityCoords(srcPed)
    local maxDist = (distance or 50) ^ 2 

    for _, id in ipairs(GetPlayers()) do
        local target = tonumber(id)
        local ped = GetPlayerPed(target)

        if ped and ped ~= 0 then
            local c = GetEntityCoords(ped)
            local dx, dy, dz = c.x - origin.x, c.y - origin.y, c.z - origin.z

            if target == src or (dx * dx + dy * dy + dz * dz) < maxDist then
                TriggerClientEvent('jr-3dme:triggerDisplay', target, cmdType, text, src)
            end
        end
    end
end

RegisterServerEvent('jr-3dme:shareDisplay')
AddEventHandler('jr-3dme:shareDisplay', function(cmdType, text)
    local src = source

    local cfg = type(cmdType) == "string" and Config.Commands[cmdType]
    if not cfg or not cfg.Enabled then return end

    text = CleanText(text)
    if not text then return end

    local now = GetGameTimer()
    local delay = (Config.Delay or 5) * 1000
    if lastUse[src] and (now - lastUse[src]) < delay then
        -- Meldung hoechstens einmal pro Sekunde schicken
        if not lastNotify[src] or (now - lastNotify[src]) >= 1000 then
            lastNotify[src] = now
            local remaining = math.ceil((delay - (now - lastUse[src])) / 1000)
            TriggerClientEvent('jr-3dme:notify', src, string.format(T.Cooldown, remaining))
        end
        return
    end

    lastUse[src] = now

    SendToNearby(src, cmdType, text, cfg.Distance)

    if LogsActive() then
        local message = "**" .. Sanitize(GetPlayerName(src)) .. "** " .. T.Said .. " " .. Sanitize(text)
        SendWebhookMessage(T[cmdType] or cmdType, message)
    end
end)local T = Translation.Langs[Config.Language] or Translation.Langs.English

-- Logs nur aktiv, wenn eingeschaltet UND eine Webhook-URL eingetragen ist
local function LogsActive()
    local hook = Config.Logs and Config.Logs.Webhook
    return Config.Logs and Config.Logs.Enable and type(hook) == "string" and hook ~= ""
end

-- Discord-Markdown und Erwaehnungen (@everyone, @here, <@id>) entschaerfen
local function Sanitize(str)
    str = tostring(str or "")
    str = str:sub(1, Config.Logs.MaxLength or 1000)
    str = str:gsub("([\\`*_~|>])", "\\%1")
    str = str:gsub("@", "@\226\128\139") -- Zero-Width-Space nach dem @
    return str
end

local function SendWebhookMessage(title, message)
    PerformHttpRequest(Config.Logs.Webhook, function() end, 'POST', json.encode({
        username = Config.Logs.Name,
        avatar_url = Config.Logs.Avatar,
        allowed_mentions = { parse = {} }, -- niemals jemanden anpingen
        embeds = {
            {
                color = Config.Logs.Color,
                author = {
                    name = Config.Logs.Name,
                    icon_url = Config.Logs.Logo
                },
                title = title,
                description = message,
                footer = {
                    text = Config.Logs.FooterText .. " - " .. os.date("%d.%m.%Y %H:%M:%S"),
                    icon_url = Config.Logs.FooterLogo,
                },
            },
        },
    }), { ['Content-Type'] = 'application/json' })
end

local lastUse = {}
local lastNotify = {}

AddEventHandler('playerDropped', function()
    lastUse[source] = nil
    lastNotify[source] = nil
end)

-- Text pruefen und bereinigen, gibt nil zurueck wenn ungueltig
local function CleanText(text)
    if type(text) ~= "string" then return nil end

    text = text:gsub("%c", " ")            
    text = text:gsub("~", "")              
    text = text:gsub("^%s+", ""):gsub("%s+$", "")
    if text == "" then return nil end

    local len = utf8.len(text)
    if not len then return nil end         -- ungueltiges UTF-8

    local max = Config.MaxLength or 100
    if len > max then
        text = text:sub(1, utf8.offset(text, max + 1) - 1)
    end

    return text
end

local function SendToNearby(src, cmdType, text, distance)
    local srcPed = GetPlayerPed(src)

    -- Ped nicht gefunden: Text wenigstens dem Sender selbst zeigen
    if not srcPed or srcPed == 0 then
        TriggerClientEvent('jr-3dme:triggerDisplay', src, cmdType, text, src)
        return
    end

    local origin = GetEntityCoords(srcPed)
    local maxDist = (distance or 50) ^ 2 -- Meter -> quadrierte Distanz

    for _, id in ipairs(GetPlayers()) do
        local target = tonumber(id)
        local ped = GetPlayerPed(target)

        if ped and ped ~= 0 then
            local c = GetEntityCoords(ped)
            local dx, dy, dz = c.x - origin.x, c.y - origin.y, c.z - origin.z

            if target == src or (dx * dx + dy * dy + dz * dz) < maxDist then
                TriggerClientEvent('jr-3dme:triggerDisplay', target, cmdType, text, src)
            end
        end
    end
end

RegisterServerEvent('jr-3dme:shareDisplay')
AddEventHandler('jr-3dme:shareDisplay', function(cmdType, text)
    local src = source

    -- Befehl muss existieren und aktiviert sein
    local cfg = type(cmdType) == "string" and Config.Commands[cmdType]
    if not cfg or not cfg.Enabled then return end

    text = CleanText(text)
    if not text then return end

    local now = GetGameTimer()
    local delay = (Config.Delay or 5) * 1000
    if lastUse[src] and (now - lastUse[src]) < delay then
        -- Meldung hoechstens einmal pro Sekunde schicken
        if not lastNotify[src] or (now - lastNotify[src]) >= 1000 then
            lastNotify[src] = now
            local remaining = math.ceil((delay - (now - lastUse[src])) / 1000)
            TriggerClientEvent('jr-3dme:notify', src, string.format(T.Cooldown, remaining))
        end
        return
    end

    lastUse[src] = now

    SendToNearby(src, cmdType, text, cfg.Distance)

    if LogsActive() then
        local message = "**" .. Sanitize(GetPlayerName(src)) .. "** " .. T.Said .. " " .. Sanitize(text)
        SendWebhookMessage(T[cmdType] or cmdType, message)
    end
end)