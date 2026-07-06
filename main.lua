local license = ... or {}
license.Key = script_key or license.Key or nil

repeat task.wait() until game:IsLoaded()
if shared.vape then shared.vape:Uninject() end

local vape
local loadstring = function(...)
    local res, err = loadstring(...)
    if err and vape then
        vape:CreateNotification('Vape', 'Failed to load : '..err, 30, 'alert')
    end
    return res
end

local queue_on_teleport = queue_on_teleport or function() end
local isfile = isfile or function(file)
    local suc, res = pcall(function() return readfile(file) end)
    return suc and res ~= nil and res ~= ''
end
local cloneref = cloneref or function(obj) return obj end

local playersService = cloneref(game:GetService('Players'))
local httpService = cloneref(game:GetService('HttpService'))

local function downloadFile(path, func)
    if not isfile(path) then
        local suc, res = pcall(function()
            return game:HttpGet('https://raw.githubusercontent.com/skidbetter/skidcat/'..readfile('catrewrite/profiles/commit.txt')..'/'..select(1, path:gsub('catrewrite/', '')), true)
        end)
        if not suc or res == '404: Not Found' then
            task.spawn(error, res or "Download failed")
        end
        if suc then
            if path:find('.lua') then
                res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n'..res
            end
            writefile(path, res)
        end
    end
    return (func or readfile)(path)
end

local function finishLoading()
    vape.Init = nil
    vape:Load()
    task.spawn(function()
        repeat
            vape:Save()
            task.wait(10)
        until not vape.Loaded
    end)

    local teleportedServers
    vape:Clean(playersService.LocalPlayer.OnTeleport:Connect(function()
        if (not teleportedServers) and (not shared.VapeIndependent) then
            teleportedServers = true
            local teleportScript = [[
loadstring(game:HttpGet('https://raw.githubusercontent.com/skidbetter/skidcat/'..readfile('catrewrite/profiles/commit.txt')..'/loader.lua', true), 'init')()
]]
            if shared.VapeDeveloper then
                teleportScript = 'shared.VapeDeveloper = true\n'..teleportScript
            end
            if shared.VapeCustomProfile then
                teleportScript = 'shared.VapeCustomProfile = "'..shared.VapeCustomProfile..'"\n'..teleportScript
            end
            queue_on_teleport(teleportScript)
        end
    end))

    if not shared.vapereload then
        if not vape.Categories then return end
        if vape.Categories.Main.Options['GUI bind indicator'].Enabled then
            if getgenv().catrole == 'HWID MISMATCH' then
                vape:CreateNotification('Cat', 'HWID MISMATCH, Go to the script panel to reset hwid', 25, 'alert')
                getgenv().catrole = ''
                task.wait(0.1)
            end
            vape:CreateNotification('Finished Loading', (getgenv().catname and `Authenticated as {getgenv().catname} with {getgenv().catrole}, ` or '').. (vape.VapeButton and 'Press the button in the top right' or 'Press '..table.concat(vape.Keybind, ' + '):upper())..' to open GUI', 5)
            task.delay(1, function()
                if shared.updated then
                    vape:CreateNotification('Cat', `Script has updated from {shared.updated} to {readfile('catrewrite/profiles/commit.txt')}`, 10, 'info')
                end
            end)
        end
    end
end

if not isfile('catrewrite/profiles/gui.txt') then
    writefile('catrewrite/profiles/gui.txt', 'new')
end
local gui = 'new'
if not isfolder('catrewrite/assets/'..gui) then
    makefolder('catrewrite/assets/'..gui)
end
if not isfile('catrewrite/profiles/commit.txt') then
    writefile('catrewrite/profiles/commit.txt', 'main')
end

getgenv().used_init = true
vape = loadstring(downloadFile('catrewrite/guis/'..gui..'.lua'), 'gui')(license)
_G.vape = vape
shared.vape = vape

if shared.maincat then
    playersService.LocalPlayer:Kick('Your script is outdated, Get new one at discord.gg/catvape')
    return
end

if not shared.VapeIndependent then
    loadstring(downloadFile('catrewrite/games/universal.lua'), 'universal')(license)
    if isfile('catrewrite/games/'..game.PlaceId..'.lua') then
        loadstring(readfile('catrewrite/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(license)
    else
        if not shared.VapeDeveloper then
            local suc, res = pcall(function()
                return game:HttpGet('https://raw.githubusercontent.com/skidbetter/skidcat/'..readfile('catrewrite/profiles/commit.txt')..'/games/'..game.PlaceId..'.lua', true)
            end)
            if suc and res ~= '404: Not Found' then
                loadstring(downloadFile('catrewrite/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(license)
            end
        end
    end
    loadstring(downloadFile('catrewrite/libraries/premium.lua'), 'premium')(license)
    finishLoading()
else
    vape.Init = finishLoading
    return vape
end
