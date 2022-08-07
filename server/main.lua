local sharedItems = exports['qbr-core']:GetItems()

RegisterNetEvent('kz-business:server:createBusiness', function(businessname, infos)
    local src = source
	local Player = exports['qbr-core']:GetPlayer(source)
	local job = Player.PlayerData.job.name

    if job == "unemployed" then
        exports.oxmysql:execute("SELECT `business` FROM kz_business WHERE business = ?", {businessname}, function(result)
            if result[1] then
                TriggerClientEvent('QBCore:Notify', src, 9, 'Erreur !', 2000, 0, 'mp_lobby_textures', 'cross', 'COLOR_WHITE')
            else 
                exports.oxmysql:insert("INSERT INTO kz_business (business, businessdata) VALUES (?,?)", {businessname, json.encode(infos)})
                exports['qbr-core']:AddJob(businessname, infos)
                Player.Functions.SetJob(businessname,3)
                TriggerClientEvent('QBCore:Notify', src, 7, "Nouveau business", 2000, "Vous avez créé un nouveau business")
                TriggerClientEvent('kz-business:client:Refresh', src)
            end
        end)
    else
        TriggerClientEvent('QBCore:Notify', src, 9, 'Vous êtes déja dans une entreprise !', 2000, 0, 'mp_lobby_textures', 'cross', 'COLOR_WHITE')
    end
end)


AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Wait(100)
        job = exports.oxmysql:executeSync("SELECT * FROM kz_business", {})
        if json.encode(job) == '[]' then 
            print('^2 kz-business - No Business in DB')
        else
            local jobTable = {}
            for i = 1, #job, 1 do
                jobTable[job[i]['business']] = json.decode(job[i]["businessdata"])
            end 
            exports['qbr-core']:AddJobs(jobTable)
            print('^2 kz-business - All business have been introduced in the core !')
        end
    end
end)

RegisterServerEvent("kz-business:server:getJobs")
AddEventHandler("kz-business:server:getJobs", function ()
    local src = source
	local Player = exports['qbr-core']:GetPlayer(source)
	local jobname = Player.PlayerData.job.name

    exports.oxmysql:execute("SELECT * FROM kz_business WHERE `business` LIKE '%".. jobname .."%'", {}, function(result)
        if result then
            TriggerClientEvent("kz-business:client:getJobs", src, result)
        end
    end)

    exports.oxmysql:execute("SELECT `qg`,`blips`,`business` FROM kz_business ", {}, function(result2)
        if result2 then
            TriggerClientEvent("kz-business:client:getJobsQG", src, result2)
        end
    end)
end)

exports['qbr-core']:AddCommand('setbusiness', 'Set A Players Job (Admin Only)', { { name = 'id', help = 'Player ID' }, { name = 'job', help = 'Job name' }, { name = 'grade', help = 'Grade' } }, true, function(source, args)
    local src = source
    local Player = exports['qbr-core']:GetPlayer(tonumber(args[1]))
    exports.oxmysql:execute("SELECT `business` FROM kz_business WHERE `id`=@id", {id = args[2]}, function(result)
        if result[1] then
            if Player then
                Player.Functions.SetJob(tostring(result[1].business), tonumber(args[3]))
            else
                TriggerClientEvent('QBCore:Notify', src, 9, "Pas en ligne", 5000, 0, 'mp_lobby_textures', 'cross', 'COLOR_WHITE')
            end
        end
    end)
end, 'admin')

RegisterNetEvent('kz-business:server:editRun', function(v)
    local src = source
	local Player = exports['qbr-core']:GetPlayer(source)
	local jobname = Player.PlayerData.job.name
    local boss = Player.PlayerData.job.isboss

    if boss then
        exports.oxmysql:execute('UPDATE kz_business SET type = ?, blips = ?, item_harvest = ?, item_process = ? WHERE business = ?',{v.id, v.blips, v.harvest, v.processing, jobname})
        TriggerClientEvent('QBCore:Notify', src, 7, "Edition", 2000, "Circuit edit")
        TriggerClientEvent('kz-business:client:Refresh', src)
    else
        TriggerClientEvent('QBCore:Notify', src, 9, 'Vous n\'êtes pas le boss !', 2000, 0, 'mp_lobby_textures', 'cross', 'COLOR_WHITE')
    end
end)

RegisterNetEvent('kz-business:server:editcoord', function(typec)
    local src = source
	local Player = exports['qbr-core']:GetPlayer(source)
	local jobname = Player.PlayerData.job.name
    local isBoss = Player.PlayerData.job.isboss
    local coord = GetEntityCoords(GetPlayerPed(src))

    if isBoss then
        if typec == 0 then
            exports.oxmysql:execute('UPDATE kz_business SET qg = ? WHERE business = ?',{json.encode(coord), jobname})
            TriggerClientEvent('QBCore:Notify', src, 7, "Edition", 2000, "Point qg")
        elseif typec == 1 then
            exports.oxmysql:execute('UPDATE kz_business SET harvest = ? WHERE business = ?',{json.encode(coord), jobname})
            TriggerClientEvent('QBCore:Notify', src, 7, "Edition", 2000, "Point harvest")
        elseif typec == 2 then
            exports.oxmysql:execute('UPDATE kz_business SET processing = ? WHERE business = ?',{json.encode(coord), jobname})
            TriggerClientEvent('QBCore:Notify', src, 7, "Edition", 2000, "Point processing")
        elseif typec == 3 then
            exports.oxmysql:execute('UPDATE kz_business SET sale = ? WHERE business = ?',{json.encode(coord), jobname})
            TriggerClientEvent('QBCore:Notify', src, 7, "Edition", 2000, "Point sale")
        end
        TriggerClientEvent('kz-business:client:Refresh', src)
    else
        TriggerClientEvent('QBCore:Notify', src, 9, 'Vous n\'êtes pas le patron de se business !', 2000, 0, 'mp_lobby_textures', 'cross', 'COLOR_WHITE')
    end
end)

-----------------------------------------

local Players = {}

local function Activity(source, itemRecolte, type, ItemTraitement, society)
    local src = source
	if Players[source] then
		local xPlayer = exports['qbr-core']:GetPlayer(src)
		if type == 1 then -- Recolte
            Citizen.Wait(1500)
            xPlayer.Functions.AddItem(itemRecolte, 1)
            TriggerClientEvent('inventory:client:ItemBox', src, sharedItems[itemRecolte], "add")
			Activity(source, itemRecolte, type, ItemTraitement, society)

        elseif type == 2 then -- Recolte
            if xPlayer.Functions.GetItemByName(itemRecolte) and xPlayer.Functions.GetItemByName(itemRecolte).amount >= 1 then
            Citizen.Wait(1500)
            xPlayer.Functions.RemoveItem(itemRecolte, 1)
            TriggerClientEvent('inventory:client:ItemBox', src, sharedItems[itemRecolte], "remove")
            xPlayer.Functions.AddItem(ItemTraitement, 1)
            TriggerClientEvent('inventory:client:ItemBox', src, sharedItems[ItemTraitement], "add")
			Activity(source, itemRecolte, type, ItemTraitement, society)
            else
                TriggerClientEvent('QBCore:Notify', src, 9, 'Vous n\'avez plus de matières première!', 1000, 0, 'mp_lobby_textures', 'cross', 'COLOR_WHITE')
            end
        elseif type == 3 then -- Recolte
            if xPlayer.Functions.GetItemByName(ItemTraitement) and xPlayer.Functions.GetItemByName(ItemTraitement).amount >= 1 then
                Citizen.Wait(1500)
                xPlayer.Functions.RemoveItem(ItemTraitement, 1)
                TriggerClientEvent('inventory:client:ItemBox', src, sharedItems[ItemTraitement], "remove")      
                xPlayer.Functions.AddMoney("cash", Config.MoneyforPlayer, "Run")          
                Activity(source, itemRecolte, type, ItemTraitement, society)
            else
                TriggerClientEvent('QBCore:Notify', src, 9, 'Vous n\'avez plus de matières première!', 1000, 0, 'mp_lobby_textures', 'cross', 'COLOR_WHITE')
            end
		else
            TriggerClientEvent('QBCore:Notify', src, 9, 'Erreur!', 5000, 0, 'mp_lobby_textures', 'cross', 'COLOR_WHITE')
		end
	end
end

RegisterServerEvent('kz-business:server:startActivity')
AddEventHandler('kz-business:server:startActivity', function(position, itemRecolte, type, ItemTraitement, society)
	if #(GetEntityCoords(GetPlayerPed(source)) - vector3(position.x, position.y, position.z)) < 100 then
		Players[source] = true
		Activity(source, itemRecolte, type, ItemTraitement, society)
	else
        TriggerClientEvent('QBCore:Notify', src, 9, 'Ne trichez pas!', 5000, 0, 'mp_lobby_textures', 'cross', 'COLOR_WHITE')
	end
end)

RegisterServerEvent('kz-business:server:stopActivity')
AddEventHandler('kz-business:server:stopActivity', function()
	Players[source] = false
end)

exports['qbr-core']:CreateCallback('kz-business:server:hasItem', function(source, cb, itemprocess, howmany)
    local src = source
    local Player = exports['qbr-core']:GetPlayer(src)
    
    local cc = 0
    if Player.Functions.GetItemByName(itemprocess) and Player.Functions.GetItemByName(itemprocess).amount >= tonumber(howmany) then
        cc = cc + tonumber(howmany)
    else
        TriggerClientEvent('QBCore:Notify', src, 9, "Vous n'avez pas les ressources nécessaires.", 2000, 0, 'mp_lobby_textures', 'cross', 'COLOR_WHITE')
        cb(false)
    end
    if cc >= tonumber(howmany) then
        cb(true)
    end
end)

RegisterServerEvent('kz-business:server:craft')
AddEventHandler('kz-business:server:craft', function(v, itemprocess, howmany)
    local src = source
    local Player = exports['qbr-core']:GetPlayer(src)

    if Player.Functions.AddItem(v.item, howmany) then
        Player.Functions.RemoveItem(itemprocess, howmany)
        TriggerClientEvent('inventory:client:ItemBox', src, sharedItems[itemprocess], "remove")
        TriggerClientEvent('inventory:client:ItemBox', src, sharedItems[v.item], "add")
        Player.Functions.AddMoney("cash", v.forPlayer * howmany, "troc")
    else
        TriggerClientEvent('QBCore:Notify', src, 9, "Cela risque d'être beaucoup trop lourd pour vous.", 2000, 0, 'mp_lobby_textures', 'cross', 'COLOR_WHITE')
    end
end)

exports['qbr-core']:CreateCallback('kz-business:server:CheckBusinessID', function(source, cb)
    local src = source
    local Player = exports['qbr-core']:GetPlayer(src)
	local Playerjob = Player.PlayerData.job.name

    exports.oxmysql:execute("SELECT `id` FROM kz_business WHERE `business` LIKE '%".. Playerjob .."%'", {}, function(result)
        if result[1] then
            cb(result)
        else
            cb(nil)
        end
    end)
end)