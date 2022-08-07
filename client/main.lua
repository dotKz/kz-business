-------------------------------------------------------------------------------------------
-- Var
-------------------------------------------------------------------------------------------

JOBS = {}
BlipsPos = {}
business = nil
typec = nil
local Activity = false
local WaitActivity = false
local sharedItems = exports['qbr-core']:GetItems()

-------------------------------------------------------------------------------------------
-- Commands
-------------------------------------------------------------------------------------------

RegisterCommand('createbusiness', function()
    TriggerEvent('kz-business:client:openMenu')
end)

RegisterCommand('+business_refresh', function()
    TriggerServerEvent("kz-business:server:getJobs")
end)

RegisterCommand('business', function()
    TriggerEvent("kz-business:client:EditBusiness")
end)

-------------------------------------------------------------------------------------------
-- Function
-------------------------------------------------------------------------------------------

function DrawText3Ds(x, y, z, text)
    local onScreen,_x,_y=GetScreenCoordFromWorldCoord(x, y, z)
    SetTextScale(0.35, 0.35)
    SetTextFontForCurrentCommand(9)
    SetTextColor(255, 255, 255, 215)
    local str = CreateVarString(10, "LITERAL_STRING", text, Citizen.ResultAsLong())
    SetTextCentre(1)
    DisplayText(str,_x,_y)
end

function noSpace(str)
    local normalisedString = string.gsub(str, "%s+", "")
    return normalisedString
  end


-------------------------------------------------------------------------------------------
-- Menu
-------------------------------------------------------------------------------------------

RegisterNetEvent('kz-business:client:EditRun', function()
    local EditRunMenu = {
        {
            header = "| Choisir un run |",
            isMenuHeader = true
        },
    }
    for _,v in pairs(Config.Run) do
        --[[local text = ""
        for n = 1, #v.craft do
            text = text .." - "..v.craft[n].item.. "<br>"
        end]]--
        EditRunMenu[#EditRunMenu+1] = {
            header = v.id.." - "..v.label,
            txt = "Type de trocs : ".. v.desc,
            params = {
                isServer = true,
                event = "kz-business:server:editRun",
                args = v,
            }
        }
    end
    EditRunMenu[#EditRunMenu+1] = {
        header = "⬅ Quitter",
        txt = "",
        params = {
        event = "kz-crafting:client:closemenu",
        }
    }
    exports['qbr-menu']:openMenu(EditRunMenu)
end)


RegisterNetEvent("kz-business:client:EditBusiness", function()
    exports['qbr-core']:GetPlayerData(function(PlayerData)
        local EditBusinessMenu = {
            {
                header = "| Options Business |",
                txt = "Nom du business : "..PlayerData.job.label,
                isMenuHeader = true,
            },
        }

        EditBusinessMenu[#EditBusinessMenu+1] = {
            header = "> Definir Type de circuit",
            txt = "N° de circuit actuel : " ..typec,
            params = {
                event = "kz-business:client:EditRun",
            }
        }

        EditBusinessMenu[#EditBusinessMenu+1] = {
            header = "> Definir un point",
            txt = "Définir les points (QG/Récolte/Traitement/Vente)",
            params = {
                event = "kz-business:client:EditPoint",
            }
        }

        EditBusinessMenu[#EditBusinessMenu+1] = {
            header = "> Gestion du personnel",
            txt = "Recruter / Virer gérer vos employés",
            params = {
                event = "kz-business:client:EditRun",
            }
        }

        EditBusinessMenu[#EditBusinessMenu+1] = {
            header = "⬅ Fermer",
            txt = "",
            params = {
                event = "qbr-menu:closeMenu",
            }
        }

        exports['qbr-menu']:openMenu(EditBusinessMenu)
    end)
end)

RegisterNetEvent("kz-business:client:EditPoint", function()
    exports['qbr-core']:GetPlayerData(function(PlayerData)
        local EditPointMenu = {
            {
                header = "| Options Business |",
                txt = "Vos points doivent avoir un minimum de distance entre eux, et de la cohérence !",
                isMenuHeader = true,
            },
        }

        EditPointMenu[#EditPointMenu+1] = {
            header = "> Definir le point : QG",
            txt = "Le QG est l'endroit pour faire vos trocs, accéder aux stocks, etc...",
            params = {
                isServer = true,
                event = "kz-business:server:editcoord",
                args = 0
            }
        }

        EditPointMenu[#EditPointMenu+1] = {
            header = "> Definir le point : Récolte",
            txt = "Le point de récolte est l'endroit pour récolter vos matières premières",
            params = {
                isServer = true,
                event = "kz-business:server:editcoord",
                args = 1
            }
        }

        EditPointMenu[#EditPointMenu+1] = {
            header = "> Definir le point : Traitement",
            txt = "Utiliser vos matières premières pour en faire un produit transformer",
            params = {
                isServer = true,
                event = "kz-business:server:editcoord",
                args = 2
            }
        }

        EditPointMenu[#EditPointMenu+1] = {
            header = "> Definir le point : Vente",
            txt = "Vente de produits transformer, une partie va à l'employé, le reste à l'entreprise",
            params = {
                isServer = true,
                event = "kz-business:server:editcoord",
                args = 3
            }
        }
        if Config.UseKzCart then
            EditPointMenu[#EditPointMenu+1] = {
                header = "> Definir le point : Spawn chariot",
                txt = "Défini le point de spawn lors de la sortie d'un chariot",
                params = {
                    isServer = true,
                    event = "kz-business:server:editcoord",
                    args = 4
                }
            }
        end

        EditPointMenu[#EditPointMenu+1] = {
            header = "⬅ Fermer",
            txt = "",
            params = {
                event = "qbr-menu:closeMenu",
            }
        }

        exports['qbr-menu']:openMenu(EditPointMenu)
    end)
end)

RegisterNetEvent("kz-business:client:PNJMenu", function(i, itemprocess)
    exports['qbr-core']:GetPlayerData(function(PlayerData)
        local PNJMenu = {
            {
                header = "| QG Menu |",
                txt = "Nom du business : "..PlayerData.job.label,
                isMenuHeader = true,
            },
        }

        if Config.UseKzCart then
            PNJMenu[#PNJMenu+1] = {
                header = "> Sortir un chariot",
                txt = "Les chariots sont ceux dont l'entreprise en est propriétaire",
                params = {
                    event = "",
                }
            }
        end

        PNJMenu[#PNJMenu+1] = {
            header = "> Faire du troc",
            txt = "Utilise la matière première transformé pour obtenir d'autres items",
            params = {
                event = "kz-business:client:TrocMenu",
                args = {i = i, itemprocess = itemprocess,}
            }
        }

        PNJMenu[#PNJMenu+1] = {
            header = "> Ouvrir le coffre",
            txt = "Déposer / Retirer des objets du coffre d'entreprise",
            params = {
                event = "kz-business:client:BusinessInventory",
            }
        }

        PNJMenu[#PNJMenu+1] = {
            header = "⬅ Fermer",
            txt = "",
            params = {
                event = "qbr-menu:closeMenu",
            }
        }

        exports['qbr-menu']:openMenu(PNJMenu)
    end)
end)

RegisterNetEvent("kz-business:client:TrocMenu", function(data)
    --print(data.i)
    --print(data.itemprocess)
    if data.i then
        local TrocMenu = {
            {
                header = "Item de troc : "..sharedItems[data.itemprocess].label,
                isMenuHeader = true
            },
        }
        for _,v in pairs(Config.Run[data.i].craft) do
            TrocMenu[#TrocMenu+1] = {
                header = "<img src=nui://qbr-inventory/html/images/"..sharedItems[v.item].image.." width=20px> ‎ ‎ "..sharedItems[v.item].label,
                txt = "Pour 1x "..sharedItems[v.item].label.." vous gagnerez $"..v.forPlayer,
                params = {
                    event = "kz-business:client:HowManyCraft",
                    args = {v = v, itemprocess = data.itemprocess,}
                }
            }
        end
        TrocMenu[#TrocMenu+1] = {
            header = "⬅ Quitter",
            txt = "",
            params = {
            event = "kz-crafting:client:closemenu",
            }
        }
        exports['qbr-menu']:openMenu(TrocMenu)
    end
end)

-------------------------------------------------------------------------------------------
-- Input
-------------------------------------------------------------------------------------------

RegisterNetEvent('kz-business:client:openMenu', function()
    local pos = GetEntityCoords(PlayerPedId())
    local createbusiness = exports['qbr-input']:ShowInput({
        header = "Création d'une entreprise",
        submitText = "Valider!",
        inputs = {
            {
                text = "Nom de l'entreprise", -- name of the job
                name = "businessname", 
                type = "text", 
                isRequired = true 
            },
            {
                text = "[0] - Nom du rang",
                name = "rank0", 
                type = "text", 
                isRequired = true 
            },
            {
                text = "[1] - Nom du rang",
                name = "rank1", 
                type = "text", 
                isRequired = true 
            },
            {
                text = "[2] - Nom du rang", 
                name = "rank2", 
                type = "text", 
                isRequired = true 
            },
            {
                text = "[3] - Nom du rang", 
                name = "rank3", 
                type = "text", 
                isRequired = true 
            },
        },
    })

    if createbusiness ~= nil then
		local infos = {
			label = createbusiness.businessname,
            defaultDuty = true, -- Because ... QBCore
		    offDutyPay = false, -- Because ... QBCore
			grades = {
	            ['0'] = {
	                name = createbusiness.rank0,
                    payment = 0, -- Because ... QBCore
	            },
				['1'] = {
	                name = createbusiness.rank1,
                    payment = 0, -- Because ... QBCore
	            },
				['2'] = {
	                name = createbusiness.rank2,
                    payment = 0, -- Because ... QBCore
	            },
	            ['3'] = {
	                name = createbusiness.rank3,
                    payment = 0 ,-- Because ... QBCore
                    isboss = true
	            },
	        },
		}
        if #createbusiness.businessname <= 2 then
            exports['qbr-core']:Notify(9, 'Le nombre de caractères minimum n\'est pas atteint', 2000, 0, 'mp_lobby_textures', 'cross', 'COLOR_WHITE')
        else
		    TriggerServerEvent('kz-business:server:createBusiness', noSpace(createbusiness.businessname:lower()), infos)
        end
    end
end)

RegisterNetEvent('kz-business:client:HowManyCraft', function(data)
    local howmanycraft = exports['qbr-input']:ShowInput({
        header = "Craft : "..sharedItems[data.v.item].label,
        submitText = "Valider!",
        inputs = {
            {
                text = "Combien en voulez vous ?",
                name = "howmany", 
                type = "number", 
                isRequired = true 
            },
        },
    })

    if howmanycraft ~= nil then
        TriggerEvent('kz-business:client:Craft', data.v, data.itemprocess, howmanycraft.howmany)
    end
end)


-------------------------------------------------------------------------------------------
-- Events
-------------------------------------------------------------------------------------------

AddEventHandler('onClientResourceStart', function(resName)
    Wait(500)
    if resName ~= GetCurrentResourceName() then
		return
	end
    if LocalPlayer.state['isLoggedIn'] then
        TriggerServerEvent("kz-business:server:getJobs")
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    TriggerServerEvent("kz-business:server:getJobs")
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function()
    TriggerServerEvent("kz-business:server:getJobs")
end)

RegisterNetEvent('kz-business:client:Refresh')
AddEventHandler('kz-business:client:Refresh', function()
    TriggerServerEvent("kz-business:server:getJobs")
end)

RegisterNetEvent("kz-business:client:getJobs")
AddEventHandler("kz-business:client:getJobs", function(listJobs)
    JOBS = listJobs
    Citizen.CreateThread(function()
        for _, item in pairs(JOBS) do
            business = item.business
            typec = item.type

            style = GetHashKey("BLIP_STYLE_TEAM_WAYPOINT")

            if item.harvest then
                print("Chargement Blips récolte")
                h = json.decode(item.harvest)
                local blips_h = N_0x554d9d53f696d002(1664425300, h.x,h.y,h.z)
                SetBlipSprite(blips_h, 2714453272, 1)
                SetBlipScale(blips_h, 0.025)
                Citizen.InvokeNative(0xEDD964B7984AC291, blips_h, style)
            end

            if item.processing then 
                print("Chargement Blips traitement")
                p = json.decode(item.processing)
                local blips_p = N_0x554d9d53f696d002(1664425300, p.x,p.y,p.z)
                SetBlipSprite(blips_p, 2714453272, 1)
                SetBlipScale(blips_p, 0.025)
                Citizen.InvokeNative(0xEDD964B7984AC291, blips_p, style)
            end

            if item.sale then 
                print("Chargement Blips vente")
                s = json.decode(item.sale)
                local blips_s = N_0x554d9d53f696d002(1664425300, s.x,s.y,s.z)
                SetBlipSprite(blips_s, 2714453272, 1)
                SetBlipScale(blips_s, 0.025)
                Citizen.InvokeNative(0xEDD964B7984AC291, blips_s, style)
            end
        end
    end)
end)

RegisterNetEvent("kz-business:client:getJobsQG")
AddEventHandler("kz-business:client:getJobsQG", function(QG)
    Citizen.CreateThread(function()
        for _, item in pairs(QG) do
            if item.qg then
            coord = json.decode(item.qg)
            style = GetHashKey("BLIP_STYLE_TEAM_WAYPOINT")
            blipstype = GetHashKey(item.blips)
            local blips = N_0x554d9d53f696d002(1664425300, coord.x, coord.y, coord.z)
            SetBlipSprite(blips, blipstype, 1)
            SetBlipScale(blips, 0.2)
            Citizen.InvokeNative(0xEDD964B7984AC291, blips, style)
            Citizen.InvokeNative(0x9CB1A1623062F402, tonumber(blips), "[Business] "..item.business)
            end
        end
    end)
end)


RegisterNetEvent("kz-business:client:Craft")
AddEventHandler("kz-business:client:Craft", function(v, itemprocess, howmany)
    exports['qbr-core']:TriggerCallback('kz-business:server:hasItem', function(has) 
        if has then
            exports['qbr-core']:Progressbar("craft", "Craft en cours", Config.Timetocraft*howmany, false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }, {}, {}, {}, function() end)
            Wait(Config.Timetocraft*howmany)
            TriggerServerEvent('kz-business:server:craft', v, itemprocess, howmany)
            --ClearPedTasks(PlayerPedId())
        end
    end, itemprocess, howmany)
end)

RegisterNetEvent('kz-business:client:BusinessInventory', function()
    exports['qbr-core']:TriggerCallback('kz-business:server:CheckBusinessID', function(result) 
        if result == nil then
            exports['qbr-core']:Notify(9, "Erreur", 2000, 0, 'mp_lobby_textures', 'cross', 'COLOR_WHITE')
        else
            for k, v in pairs(result) do
                TriggerServerEvent("inventory:server:OpenInventory", "stash", "Business_"..v.id, { maxweight = 400000, slots = 25, })
                TriggerEvent("inventory:client:SetCurrentStash", "Business_"..v.id)
            end
        end
    end)
end)


-------------------------------------------------------------------------------------------
-- Citizen
-------------------------------------------------------------------------------------------

Citizen.CreateThread(function()
    while true do
        local Open = false
        
        for k,v in pairs(JOBS) do
            --print(v.business)
            exports['qbr-core']:GetPlayerData(function(PlayerData)
            PlayerJob = PlayerData.job
                if PlayerJob.name == v.business then

                    if v.harvest then
                        h = json.decode(v.harvest)
                        if Vdist2(GetEntityCoords(PlayerPedId(), false), vector3(h.x,h.y,h.z)) < 30 then
                            Open = true
                            if not Activity then
                                if not WaitActivity then
                                    DrawText3Ds(h.x, h.y, h.z, "~e~[J]~q~ - Recolter")
                                    if IsControlJustPressed(1,0xF3830D8E) then
                                        Activity = true
                                        WaitActivity = true
                                        TriggerServerEvent('kz-business:server:startActivity', h, v.item_harvest, 1, '0', PlayerJob.name)
                                    end
                                else
                                    exports['qbr-core']:Notify(9, 'Merci de ne pas allez trop vite', 5000, 0, 'mp_lobby_textures', 'cross', 'COLOR_WHITE')
                                end
                            else
                                DrawText3Ds(h.x, h.y, h.z, "~e~[J]~q~ - pour arrêter l\'activité")
                                if IsControlJustPressed(1,0xF3830D8E) then
                                    Activity = false
                                    TriggerServerEvent('kz-business:server:stopActivity')
                                    Wait(5000)
                                    WaitActivity = falwse
                                end
                            end
                        end

                        if Vdist2(GetEntityCoords(PlayerPedId(), false), vector3(h.x,h.y,h.z)) > 30 and Vdist2(GetEntityCoords(PlayerPedId(), false), vector3(h.x,h.y,h.z)) < 35 then
                            Activity = false
                            TriggerServerEvent('kz-business:server:stopActivity')
                            Wait(5000)
                            WaitActivity = false
                        end
                    end


                    if v.processing then
                        p = json.decode(v.processing)
                        if Vdist2(GetEntityCoords(PlayerPedId(), false), vector3(p.x,p.y,p.z)) < 30 then
                            Open = true
                            if not Activity then
                                if not WaitActivity then
                                    DrawText3Ds(p.x, p.y, p.z, "~e~[J]~q~ - Traiter")
                                    if IsControlJustPressed(1,0xF3830D8E) then
                                        Activity = true
                                        WaitActivity = true
                                        TriggerServerEvent('kz-business:server:startActivity', p, v.item_harvest, 2, v.item_process, PlayerJob.name)
                                    end
                                else
                                    exports['qbr-core']:Notify(9, 'Merci de ne pas allez trop vite', 5000, 0, 'mp_lobby_textures', 'cross', 'COLOR_WHITE')
                                end
                            else
                                DrawText3Ds(p.x, p.y, p.z, "~e~[J]~q~ - pour arrêter l\'activité")
                                if IsControlJustPressed(1,0xF3830D8E) then
                                    Activity = false
                                    TriggerServerEvent('kz-business:server:stopActivity')
                                    Wait(5000)
                                    WaitActivity = falwse
                                end
                            end
                        end

                        if Vdist2(GetEntityCoords(PlayerPedId(), false), vector3(p.x,p.y,p.z)) > 30 and Vdist2(GetEntityCoords(PlayerPedId(), false), vector3(p.x,p.y,p.z)) < 35 then
                            Activity = false
                            TriggerServerEvent('kz-business:server:stopActivity')
                            Wait(5000)
                            WaitActivity = false
                        end
                    end


                    if v.sale then
                        s = json.decode(v.sale)
                        if Vdist2(GetEntityCoords(PlayerPedId(), false), vector3(s.x,s.y,s.z)) < 30 then
                            Open = true
                            if not Activity then
                                if not WaitActivity then
                                    DrawText3Ds(s.x, s.y, s.z, "~e~[J]~q~ - Vendre")
                                    if IsControlJustPressed(1,0xF3830D8E) then
                                        Activity = true
                                        WaitActivity = true
                                        TriggerServerEvent('kz-business:server:startActivity', s, v.item_harvest, 3, v.item_process, PlayerJob.name)
                                    end
                                else
                                    exports['qbr-core']:Notify(9, 'Merci de ne pas allez trop vite', 5000, 0, 'mp_lobby_textures', 'cross', 'COLOR_WHITE')
                                end
                            else
                                DrawText3Ds(s.x, s.y, s.z, "~e~[J]~q~ - pour arrêter l\'activité")
                                if IsControlJustPressed(1,0xF3830D8E) then
                                    Activity = false
                                    TriggerServerEvent('kz-business:server:stopActivity')
                                    Wait(5000)
                                    WaitActivity = falwse
                                end
                            end
                        end

                        if Vdist2(GetEntityCoords(PlayerPedId(), false), vector3(s.x,s.y,s.z)) > 30 and Vdist2(GetEntityCoords(PlayerPedId(), false), vector3(s.x,s.y,s.z)) < 35 then
                            Activity = false
                            TriggerServerEvent('kz-business:server:stopActivity')
                            Wait(5000)
                            WaitActivity = false
                        end
                    end


                    if v.qg then
                        q = json.decode(v.qg)
                        if Vdist2(GetEntityCoords(PlayerPedId(), false), vector3(q.x,q.y,q.z)) < 30 then
                            Open = true
                            if not Activity then
                                if not WaitActivity then
                                    for i = 1, #Config.Run do
                                        if Config.Run[i].id == v.type then
                                            DrawText3Ds(q.x, q.y, q.z, "~e~[J]~q~ - Troc")
                                            if IsControlJustPressed(1,0xF3830D8E) then
                                                TriggerEvent('kz-business:client:PNJMenu', i, v.item_process)
                                            end
                                        end
                                    end
                                else
                                    exports['qbr-core']:Notify(9, 'Merci de ne pas allez trop vite', 5000, 0, 'mp_lobby_textures', 'cross', 'COLOR_WHITE')
                                end
                            end
                        end
                    end

                end
            end)
        end
                
        if Open then
          Wait(0)
      else
          Wait(1000)
      end
    end
end)

