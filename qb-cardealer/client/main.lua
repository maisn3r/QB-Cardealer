QBCore = nil
PlayerJob = {}
PlayerName = {}
isLoggedIn = {}
inRange = false
bank = 0

Citizen.CreateThread(function()
    while QBCore == nil do
        TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)
        Citizen.Wait(200)
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    QBCore.Functions.GetPlayerData(function(PlayerData)
        PlayerJob = PlayerData.job
        PlayerName = PlayerData.name
        isLoggedIn = true
    end)
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate')
AddEventHandler('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
end)

AddEventHandler('onClientResourceStart',function()
    Citizen.CreateThread(function()
        while true do
            if QBCore ~= nil and QBCore.Functions.GetPlayerData ~= nil then
                QBCore.Functions.GetPlayerData(function(PlayerData)
                if PlayerData.job then
                    isLoggedIn = true
                    PlayerJob = PlayerData.job
                    PlayerName = PlayerData.name
                end
                end)
                break
            end
            Citizen.Wait(500)
        end
        Citizen.Wait(500)
    end)
end)

-- show menus
Citizen.CreateThread(function()
    while true do
        local pos = GetEntityCoords(PlayerPedId())
        local dist = #(pos - vector3(-795.86,-220.81, 37.07))

        if dist < 50 and PlayerJob.name == "cardealer" then
            local menuDist = #(pos - vector3(Config.Locations["menu"].coords.x, Config.Locations["menu"].coords.y, Config.Locations["menu"].coords.z))
            local bossDist = #(pos - vector3(Config.Locations["boss"].coords.x, Config.Locations["boss"].coords.y, Config.Locations["boss"].coords.z))
            local garageDist = #(pos - vector3(Config.Locations["garage"].coords.x, Config.Locations["garage"].coords.y, Config.Locations["garage"].coords.z))

            --Normal Menu Distance
            if menuDist < 1 then
                DrawText3Ds(Config.Locations["menu"].coords.x, Config.Locations["menu"].coords.y, Config.Locations["menu"].coords.z, "[E] Open Menu")
                if IsControlJustPressed(0, Keys["E"]) then
                    if IsControlJustPressed(0, Keys["E"]) then
                        QBCore.Functions.Progressbar("Opening laptop", "Booting systems...", 2000, false, true, {
                            disableMovement = true,
                            disableCarMovement = true,
                            disableMouse = false,
                            disableCombat = true,
                        }, {}, {}, {}, function() -- Done
                            ClearPedTasks(PlayerPedId())
                            normalMenu()
                            Menu.hidden = not Menu.hidden
                        end, function() -- Cancel
                            ClearPedTasks(PlayerPedId())
                            QBCore.Functions.Notify("Cancelled..", "error")
                        end)
                    end
                end
                Menu.renderGUI()
            end

            --Boss Menu GRADE 2 MAKEN
            if bossDist < 1 and PlayerJob.gradelabel == "Manager" and PlayerJob.name == "cardealer" then
                DrawText3Ds(Config.Locations["boss"].coords.x, Config.Locations["boss"].coords.y, Config.Locations["boss"].coords.z, "[E] Boss Menu")
                if IsControlJustPressed(0, Keys["E"]) then
                    if IsControlJustPressed(0, Keys["E"]) then
                        QBCore.Functions.Progressbar("Opening laptop", "Booting systems...", 2000, false, true, {
                            disableMovement = true,
                            disableCarMovement = true,
                            disableMouse = false,
                            disableCombat = true,
                        }, {}, {}, {}, function() -- Done
                            ClearPedTasks(PlayerPedId())
                            bossMenu()
                            Menu.hidden = not Menu.hidden
                        end, function() -- Cancel
                            ClearPedTasks(PlayerPedId())
                            QBCore.Functions.Notify("Cancelled..", "error")
                        end)
                    end
                end
                Menu.renderGUI()
            end

            --Garage Distance (in and out vehicle, store, open)
            if garageDist < 5 then
                if IsPedOnFoot(PlayerPedId()) then
                    DrawText3Ds(Config.Locations["garage"].coords.x, Config.Locations["garage"].coords.y, Config.Locations["garage"].coords.z, "[E] Open Garage")
                    if IsControlJustPressed(0, Keys["E"]) then
                        if IsControlJustPressed(0, Keys["E"]) then
                        GarageMenu()
                        Menu.hidden = not Menu.hidden
                        end
                    end
                else
                    DrawText3Ds(Config.Locations["garage"].coords.x, Config.Locations["garage"].coords.y, Config.Locations["garage"].coords.z, "[E] Store Vehicle")
                    if IsControlJustPressed(0, Keys["E"]) then
                        --store vehicle
                        DeleteVehicle(GetVehiclePedIsIn(PlayerPedId()))
                    end
                end
                Menu.renderGUI()
            end
        else
            Citizen.Wait(2000)
        end
        Citizen.Wait(1)
    end
end)

-- menus
function normalMenu()
    MenuTitle = "Luxury Autos"
    ClearMenu()
    Menu.addButton("Vehicles","vehicleMenu",nil)
    Menu.addButton("Showroom","showroomMenu",nil)
    Menu.addButton("Close Menu","CloseMenu", nil)
end

function GarageMenu()
    ClearMenu()
    Menu.addButton("Flatbed", "SpawnListVehicle", "flatbed") 
    Menu.addButton("Close Menu", "CloseMenu", nil) 
end

function SpawnListVehicle(model)
    local coords = {
        x = Config.Locations["garage"].coords.x,
        y = Config.Locations["garage"].coords.y,
        z = Config.Locations["garage"].coords.z,
        h = Config.Locations["garage"].coords.h,
    }
    local plate = "CD"..math.random(111111, 999999)
    QBCore.Functions.SpawnVehicle(model, function(veh)
        SetVehicleNumberPlateText(veh, "CARD"..tostring(math.random(1000, 9999)))
        SetEntityHeading(veh, coords.h)
        exports['qb-hud']:SetFuel(veh, 100.0)
        Menu.hidden = true
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(veh))
        SetVehicleEngineOn(veh, true, true)
    end, coords, true)
end

function showroomMenu()
    MenuTitle = "Showroom"
    ClearMenu()
    Menu.addButton("Clear Showroom","clearShowroom",nil)
    for k,v in pairs(Config.Vehicles) do
        Menu.addButton(k,"showroomBrand",k)
    end
    Menu.addButton("Back","normalMenu",nil)
end

function showroomBrand(brand)
    MenuTitle = "Showroom brands"
    ClearMenu()
    for i=1,#Config.Vehicles[brand], 1 do
        local model = Config.Vehicles[brand][i]
        Menu.addButton(QBCore.Shared.Vehicles[model]["brand"].." "..QBCore.Shared.Vehicles[model]["name"],"showroomPos",model)
    end
    Menu.addButton("Back","showroomMenu",nil)
end

function showroomPos(model)
    MenuTitle = "Place Showroom veh"
    ClearMenu()
    Menu.addButton("Display 1","spawnVeh",{model,"display1"})
    Menu.addButton("Display 2","spawnVeh",{model,"display2"})
    Menu.addButton("Display 3","spawnVeh",{model,"display3"})
    Menu.addButton("Display 4","spawnVeh",{model,"display4"})
    Menu.addButton("Display 5","spawnVeh",{model,"display5"})
    Menu.addButton("Back","showroomMenu",nil)
end

function spawnVeh(input)
    local model = input[1]
    local display = input[2]
    local vehinarea = QBCore.Functions.GetVehiclesInArea(vector3(Config.Locations[display].coords.x,Config.Locations[display].coords.y,Config.Locations[display].coords.z), 1)
    if #vehinarea ~= 0 then
        QBCore.Functions.DeleteVehicle(vehinarea[1])
    end
    QBCore.Functions.SpawnVehicle(model, function(veh)
        SetEntityCoords(veh,Config.Locations[display].coords.x,Config.Locations[display].coords.y,Config.Locations[display].coords.z)
        SetEntityHeading(veh,Config.Locations[display].coords.h)
        SetVehicleNumberPlateText(veh,"FORSALE")
        FreezeEntityPosition(veh,true)
    end)
end

function clearShowroom()
    for k,v in pairs(Config.Locations) do
        local vehinarea = QBCore.Functions.GetVehiclesInArea(vector3(Config.Locations[k].coords.x,Config.Locations[k].coords.y,Config.Locations[k].coords.z), 1)
        if #vehinarea ~= 0 then
            QBCore.Functions.DeleteVehicle(vehinarea[1])
        end
    end
    QBCore.Functions.Notify("Showroom Cleared","success",2500)
end

function vehicleMenu()
    MenuTitle = "Vehicles"
    ClearMenu()
    for k,v in pairs(Config.Vehicles) do
        Menu.addButton(k,"normalModelMenu",k)
    end
    Menu.addButton("Back","normalMenu",nil)
end

function normalModelMenu(brand)
    MenuTitle = brand
    local stock
    local price
    ClearMenu()
    for i=1,#Config.Vehicles[brand], 1 do
        local model = Config.Vehicles[brand][i]
        QBCore.Functions.TriggerCallback('qb-cardealer:server:getStock', function(result)
            stock = json.decode(json.encode(result[1]))  
            price = (json.decode(json.encode(result[2])))*1.1
        end,model)
        Citizen.Wait(250)
        Menu.addButton(QBCore.Shared.Vehicles[model]["brand"].." "..QBCore.Shared.Vehicles[model]["name"],"normalSelectedModel",model,"Stock: "..stock,"Price: "..price)
    end
    Menu.addButton("Back","vehicleMenu",nil)
end

function normalSelectedModel(model)
    local vehinarea = QBCore.Functions.GetVehiclesInArea(vector3(-783.7782, -223.7653, 36.482498), 1)
    if #vehinarea ~= 0 then
        QBCore.Functions.DeleteVehicle(vehinarea[1])
    end
    QBCore.Functions.SpawnVehicle(model, function(veh)
        SetEntityCoords(veh,Config.Locations["platform"].coords.x,Config.Locations["platform"].coords.y,Config.Locations["platform"].coords.z)
        SetEntityHeading(veh,Config.Locations["platform"].coords.h)
        SetVehicleNumberPlateText(veh,"FORSALE")
        FreezeEntityPosition(veh,true)
    end)
end

function bossMenu()
    QBCore.Functions.TriggerCallback('qb-cardealer:server:getBank',function(result)
        bank = result
    end)
    Citizen.Wait(200)
    MenuTitle = "Boss"
    ClearMenu()
    Menu.addButton("Employee List","openEmployee",nil)
    Menu.addButton("Hire Person","openHire",nil)
    Menu.addButton("Order Vehicle","openOrder",nil)
    Menu.addButton("Bank Account ($ "..bank..")","openBank",nil)
    Menu.addButton("Close Menu", "CloseMenu", nil)
end

-- Menu Functions
function openBank()
    MenuTitle = "Bank Account"
    ClearMenu()
    Menu.addButton("Deposit","bankTransaction","deposit")
    Menu.addButton("Withdraw","bankTransaction","withdraw")
    Menu.addButton("Back","bossMenu",nil)
end

function bankTransaction(args)
    if args == "withdraw" then 
        -- get amount
        DisplayOnscreenKeyboard(1, "", "", "", "", "", "", 20)
        while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
            Citizen.Wait(7)
        end
        local amount = tonumber(GetOnscreenKeyboardResult())
        --withdraw
        if amount ~= nil then

            QBCore.Functions.Progressbar("Wiring", "Transaction...", 4000, false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }, {}, {}, {}, function() -- Done
                ClearPedTasks(PlayerPedId())
                TriggerServerEvent('qb-cardealer:server:withdrawBank',amount)
                Menu.hidden = not Menu.hidden
            end, function() -- Cancel
                ClearPedTasks(PlayerPedId())
                QBCore.Functions.Notify("Cancelled..", "error")
            end)
        else
            QBCore.Functions.Notify("Incorrect input","error")
        end

    else if args == "deposit" then
        --get amount
        DisplayOnscreenKeyboard(1, "", "", "", "", "", "", 20)
        while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
            Citizen.Wait(7)
        end
        local amount = tonumber(GetOnscreenKeyboardResult())
        --deposit
        if amount ~= nil then
            QBCore.Functions.Progressbar("Wiring", "Transaction...", 4000, false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }, {}, {}, {}, function() -- Done
                ClearPedTasks(PlayerPedId())
                TriggerServerEvent('qb-cardealer:server:depositBank',amount)
                Menu.hidden = not Menu.hidden
            end, function() -- Cancel
                ClearPedTasks(PlayerPedId())
                QBCore.Functions.Notify("Cancelled..", "error")
            end)
        else
            QBCore.Functions.Notify("Incorrect input","error")
        end
    end
    end
end

-- SALE EVENTS/FUNCTIONS
RegisterNetEvent('qb-cardealer:client:sellConfirm')
AddEventHandler('qb-cardealer:client:sellConfirm',function(target,targetName,job)
    if PlayerJob.name == "cardealer" then
        if IsPedInAnyVehicle(PlayerPedId(), false) then
            local veh = GetVehiclePedIsIn(PlayerPedId())
            local props = QBCore.Functions.GetVehicleProperties(veh)
            local hash = props.model
            local plate = GetVehicleNumberPlateText(veh)
            local vehmodel
            if plate == "FORSALE " then
                for k,v in pairs(Config.Vehicles) do
                    for i=1,#Config.Vehicles[k], 1 do
                        local model = Config.Vehicles[k][i]
                        if hash == GetHashKey(model) then
                            vehmodel = Config.Vehicles[k][i]
                        end
                    end
                end
                -- SET OWNER
                TriggerServerEvent('qb-cardealer:server:setOwner',vehmodel,hash,target,job)
            else 
                QBCore.Functions.Notify("This vehicle is not for sale","error")
            end
        end
    end
end)

RegisterNetEvent('qb-cardealer:client:setOwner')
AddEventHandler('qb-cardealer:client:setOwner',function(plate)
    local veh = GetVehiclePedIsIn(PlayerPedId())
    SetVehicleNumberPlateText(veh,plate:gsub("%s+", ""))
    --SetVehicleEngineOn(veh, true, true)
    FreezeEntityPosition(veh,false)
end)

--TESTDRIVE
RegisterNetEvent('qb-cardealer:client:testdrive')
AddEventHandler('qb-cardealer:client:testdrive',function()
    local veh = GetVehiclePedIsIn(PlayerPedId())
    local plate = GetVehicleNumberPlateText(veh)
    if plate == "FORSALE " then
        SetVehicleNumberPlateText(veh,"TESTCAR1")
        TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(veh))
        SetVehicleEngineOn(veh, true, true)
        FreezeEntityPosition(veh,false)
        local props = QBCore.Functions.GetVehicleProperties(veh)
        local hash = props.model
        local vehmodel = "fixt uw sharedlua"
        for k,v in pairs(Config.Vehicles) do
            for i=1,#Config.Vehicles[k], 1 do
                local model = Config.Vehicles[k][i]
                if hash == GetHashKey(model) then
                    vehmodel = Config.Vehicles[k][i]
                end
            end
        end
    else
        QBCore.Functions.Notify("You can't do that with this vehicle","error")
    end
end)

-- MENU FUNCTIONS

function openEmployee()
    MenuTitle = "Employee List"
    ClearMenu()
    QBCore.Functions.TriggerCallback('qb-cardealer:server:getEmployees',function(employees)
        for i=1, #employees, 1 do
            local job = json.decode(json.encode(employees[i].job))
            local charInfo = json.decode(json.encode(employees[i].charinfo))
            Menu.addButton(charInfo.firstname.." "..charInfo.lastname..": "..job.gradelabel,"firepromote",employees[i])
        end
    end)
    Citizen.Wait(100)
    Menu.addButton("Back","bossMenu",nil)
end

function firepromote(employee)
    MenuTitle = "Fire or promote"
    ClearMenu()
    Menu.addButton("Promote","promote",employee)
    Menu.addButton("Demote","demote",employee)
    Menu.addButton("Fire","fire",employee)
    Menu.addButton("Back","openEmployee",nil)
end

function promote(employee)
    MenuTitle = "Promote"
    ClearMenu()
    Menu.addButton("Confirm","confirmedPromote",employee)
    Menu.addButton("Back","firepromote",employee)
end

function demote(employee)
    MenuTitle = "demote"
    ClearMenu()
    Menu.addButton("Confirm","confirmedDemote",employee)
    Menu.addButton("Back","firepromote",employee)
end

function fire(employee)
    MenuTitle = "Fire"
    ClearMenu()
    Menu.addButton("Confirm","confirmedFire",employee)
    Menu.addButton("Back","openEmployee",employee)
end

function confirmedPromote(employee)
    local citizenid = employee.citizenid
    local grade = employee.job.gradelabel
    if grade == "Manager" then
    -- kan nie promoten eee
        QBCore.Functions.Notify("You cannot promote a Manager","error")
    else
        TriggerServerEvent('qb-cardealer:server:setJob',citizenid,2,"cardealer")
        QBCore.Functions.Notify("You successfully promoted "..employee.citizenid,"success")
        Menu.hidden = true
        ClearMenu()
    end
end

function confirmedDemote(employee)
    local citizenid = employee.citizenid
    local grade = employee.job.gradelabel
    if grade == "Manager" then
        TriggerServerEvent('qb-cardealer:server:setJob',citizenid,1,"cardealer")
        QBCore.Functions.Notify("You successfully demoted "..employee.citizenid,"success")
        Menu.hidden = true
        ClearMenu()
    else
        QBCore.Functions.Notify("You cannot demote a salesman, only fire","error")
    end
end

function confirmedFire(employee)
    local citizenid = employee.citizenid
    TriggerServerEvent('qb-cardealer:server:setJob',citizenid,1,"unemployed")
    QBCore.Functions.Notify("You successfully fired "..employee.citizenid,"success")
    Menu.hidden = true
    ClearMenu()
end

function openHire()
    MenuTitle = "Hire Employee"
    ClearMenu()
    QBCore.Functions.TriggerCallback('qb-cardealer:server:getOnlinePlayers',function(players)
        for i=1, #players, 1 do
            local job = json.decode(json.encode(players[i].job.name))
            local charInfo = json.decode(json.encode(players[i].charinfo))
            local citizenid = json.decode(json.encode(players[i].citizenid))
            if job == "unemployed" then
                Menu.addButton(charInfo.firstname.." "..charInfo.lastname..": "..citizenid,"Hire",players[i])
            end
        end
    end)
    Citizen.Wait(100)
    Menu.addButton("Back","bossMenu",nil)
end

function Hire(player)
    MenuTItle = "Hire Employee"
    ClearMenu()
    Menu.addButton("Confirm","confirmedHire",player)
    Menu.addButton("Back","openHire",nil)
end

function confirmedHire(player)
    local citizenid = player.citizenid
    MenuTItle = "Hire Employee"
    ClearMenu()
    TriggerServerEvent('qb-cardealer:server:setJob',citizenid,1,"cardealer")
    QBCore.Functions.Notify("You succesfully hired "..player.citizenid,"success")
    ClearMenu()
    Menu.hidden = true
end

function openOrder()
    MenuTitle = "Order Vehicle"
    ClearMenu()
    for k,v in pairs(Config.Vehicles) do
        Menu.addButton(k,"ModelMenu",k)
    end
    Menu.addButton("Back","bossMenu",nil)
end

function ModelMenu(brand)
    MenuTitle = brand
    local stock = 0
    local price = 0
    ClearMenu()
    for i=1,#Config.Vehicles[brand], 1 do
        local model = Config.Vehicles[brand][i]
        QBCore.Functions.TriggerCallback('qb-cardealer:server:getStock', function(result)
            stock = json.decode(json.encode(result[1]))  
            price = json.decode(json.encode(result[2]))
        end,model)
        Citizen.Wait(200)
        Menu.addButton(QBCore.Shared.Vehicles[model]["brand"].." "..QBCore.Shared.Vehicles[model]["name"],"confirmOrder",model,"Stock: "..stock,"Price: "..price)
    end
    Menu.addButton("Back","openOrder",nil)
end

function confirmOrder(vehicle)
    MenuTitle = "Confirm Order"
    ClearMenu()
    Menu.addButton("Confirm","order",vehicle)
    Menu.addButton("Back","bossMenu",nil)
end

function order(vehicle)
    local price = 0
    QBCore.Functions.TriggerCallback('qb-cardealer:server:getBank',function(result)
        bank = result
    end)
    QBCore.Functions.TriggerCallback('qb-cardealer:server:getPrice', function(result)
        price = result.price
    end,vehicle)
    Citizen.Wait(200)
    if bank < price then
        QBCore.Functions.Notify("Your business account does not have enough money.","error")
    else 
        QBCore.Functions.Notify("You succesfully ordered a "..QBCore.Shared.Vehicles[vehicle]["brand"].." "..QBCore.Shared.Vehicles[vehicle]["name"].." for "..price,"success")
        Menu.hidden = true
        ClearMenu()
        -- ORDER VEHICLE UPDATE DATABASE, REMOVE MONEY BANK
        QBCore.Functions.Progressbar("Order Vehicle", "Ordering vehicle...", 6000, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {}, {}, {}, function() -- Done
            TriggerServerEvent('qb-cardealer:server:buyStock', vehicle)
            ClearPedTasks(PlayerPedId())
        end, function() -- Cancel
            ClearPedTasks(PlayerPedId())
            QBCore.Functions.Notify("Cancelled..", "error")
        end)
    end
end

CloseMenu = function()
    Menu.hidden = true
    currentGarage = nil
    ClearMenu()
end

ClearMenu = function()
	Menu = {}
	Menu.GUI = {}
	Menu.buttonCount = 0
	Menu.selection = 0
end

function noSpace(str)
    local normalisedString = string.gsub(str, "%s+", "")
    return normalisedString
end

function DrawText3Ds(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

--blip -795.8639, -220.8166, 37.079658
Citizen.CreateThread(function()
    local blip = AddBlipForCoord(-795.86 , -220.81 , 37.07)
	SetBlipSprite(blip, 225)
	SetBlipDisplay(blip, 4)
	SetBlipScale(blip, 0.7)
	SetBlipAsShortRange(blip, true)
	SetBlipColour(blip, 74)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentSubstringPlayerName("Luxury Autos")
	EndTextCommandSetBlipName(blip)
end)