QBCore = nil
TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)

local NumberCharset = {}
local Charset = {}

for i = 48,  57 do table.insert(NumberCharset, string.char(i)) end

for i = 65,  90 do table.insert(Charset, string.char(i)) end
for i = 97, 122 do table.insert(Charset, string.char(i)) end

-- Code

QBCore.Functions.CreateCallback('qb-cardealer:server:getBank',function(source, cb, type)
    exports['ghmattimysql']:execute('SELECT money from society WHERE name = "cardealer" ',function(result)
    local balance = math.floor(result[1].money)
    cb(balance)
    end)
end)

QBCore.Functions.CreateCallback('qb-cardealer:server:getOnlinePlayers',function(source,cb)
    local players = {}
    for k, v in pairs(QBCore.Functions.GetPlayers()) do
        local Player = QBCore.Functions.GetPlayer(v)
        if Player ~= nil then
            players[Player.PlayerData.citizenid] = {}
            table.insert(players,{
                citizenid = Player.PlayerData.citizenid,
                job = Player.PlayerData.job,
                charinfo = Player.PlayerData.charinfo
            })            
        end
    end
    cb(players)
end)

QBCore.Functions.CreateCallback('qb-cardealer:server:getStock',function(source,cb,name)
    local model = name
    local vehicle = {}
    exports['ghmattimysql']:execute('SELECT stock, price from cardealer_stock WHERE vehicle = "'..model..'"',function(result)
        local stock = result[1].stock
        local price = result[1].price
        table.insert(vehicle, stock)
        table.insert(vehicle, price)
        cb(vehicle)
    end)
end)

QBCore.Functions.CreateCallback('qb-cardealer:server:getEmployees', function(source,cb)
    local employees = {}
    for k, v in pairs(QBCore.Functions.GetPlayers()) do
        local Player = QBCore.Functions.GetPlayer(v)
        if Player ~= nil then
            if Player.PlayerData.job.name == "cardealer" then
                employees[Player.PlayerData.citizenid] = {}
                table.insert(employees,{
                    citizenid = Player.PlayerData.citizenid,
                    job = Player.PlayerData.job,
                    charinfo = Player.PlayerData.charinfo
                })
            end
        end
    end
    cb(employees)
end)

QBCore.Functions.CreateCallback('qb-cardealer:server:getPrice',function(source,cb,name)
    local model = name
    exports['ghmattimysql']:execute('SELECT price from cardealer_stock WHERE vehicle = "'..model..'"',function(result)
        local price = result[1]
        cb(price)
    end)
end)

RegisterNetEvent('qb-cardealer:server:setJob')
AddEventHandler('qb-cardealer:server:setJob',function(citizenid,grade,job)
    local Player = QBCore.Functions.GetPlayerByCitizenId(citizenid)
    if Player ~= nil then -- player exists
        Player.Functions.SetJob(job,tonumber(grade))
    end
end)

RegisterServerEvent('qb-cardealer:server:buyStock')
AddEventHandler('qb-cardealer:server:buyStock',function(model)
    local Player = QBCore.Functions.GetPlayer(source)
    local stock = 0
    local price = 0
    local balance = 0
    exports['ghmattimysql']:execute('SELECT stock, price from cardealer_stock WHERE vehicle = "'..model..'"',function(result)
        stock = result[1].stock
        price = result[1].price
    end)
    Wait(200)
    stock = stock + 1
    exports['ghmattimysql']:execute('UPDATE cardealer_stock SET stock = '..stock..' WHERE vehicle = "'..model..'"',function(result)
    end)
    Wait(200)
    exports['ghmattimysql']:execute('SELECT money from society WHERE name = "cardealer" ',function(result)
        balance = math.floor(result[1].money)
    end)
    Wait(200)
    balance = balance - price
    Wait(200)
    exports['ghmattimysql']:execute('UPDATE society SET money = '..balance..' WHERE (name = "cardealer")',function(result)
    end)
end)

RegisterServerEvent('qb-cardealer:server:withdrawBank')
AddEventHandler('qb-cardealer:server:withdrawBank',function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(source)
    local bank
    exports['ghmattimysql']:execute('SELECT money from society WHERE name = "cardealer" ',function(result)
        bank = math.floor(result[1].money)
    end)
    Wait(200)
    local newBalance = (bank - amount)
    if amount <= bank then
        --notify client
        TriggerClientEvent('QBCore:Notify', src, "You withdrew "..amount, "success")	
        --give bank money
        Player.Functions.AddMoney('bank',amount, "Cardealer bank")
        --update database
        exports['ghmattimysql']:execute('UPDATE society SET money = '..newBalance..' WHERE (name = "cardealer")',function(result)
        end)
    else
        TriggerClientEvent('QBCore:Notify',src,"There is not enough money on the bank account.","error")
    end
end)

RegisterServerEvent('qb-cardealer:server:depositBank')
AddEventHandler('qb-cardealer:server:depositBank',function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(source)
    local sourceBank = Player.PlayerData.money.bank
    local bank
    exports['ghmattimysql']:execute('SELECT money from society WHERE name = "cardealer" ',function(result)
        bank = math.floor(result[1].money)
    end)
    Wait(200)
    local newBalance = (bank + amount)
    if amount <= sourceBank then
        --notify client
        TriggerClientEvent('QBCore:Notify', src, "You deposited "..amount, "success")	
        --take bank money
        Player.Functions.RemoveMoney('bank',amount, "Cardealer bank")
        --update database
        exports['ghmattimysql']:execute('UPDATE society SET money = '..newBalance..' WHERE (name = "cardealer")',function(result)
        end)
    else
        TriggerClientEvent('QBCore:Notify',src,"There is not enough money on your bank account.","error")
    end
end)

RegisterNetEvent('qb-cardealer:server:setOwner')
AddEventHandler('qb-cardealer:server:setOwner', function(vehmodel, hash, target,job)
    local src = source
    local inStock = false
    exports['ghmattimysql']:execute('SELECT stock from '..job..'_stock WHERE vehicle = "'..vehmodel..'"',function(result)
        local stock = result[1].stock
        while result == nil do
            Wait(1)
        end
        if stock > 0 then
            inStock = true
        end
    end)
    Wait(200)
    if inStock == true then
        local buyer = QBCore.Functions.GetPlayer(GetPlayerIdentifiers(target)[1])
        local seller = QBCore.Functions.GetPlayer(GetPlayerIdentifiers(src)[1])
        local newplate = GeneratePlate()
        newplate = newplate:gsub("%s+", "")
        TriggerClientEvent("vehiclekeys:client:SetOwner",target,newplate)
        TriggerClientEvent('qb-cardealer:client:setOwner',src,newplate)
        QBCore.Functions.ExecuteSql(false, "INSERT INTO `player_vehicles` (`steam`, `citizenid`, `vehicle`, `hash`, `mods`, `plate`, `state`) VALUES ('"..buyer.PlayerData.steam.."', '"..buyer.PlayerData.citizenid.."', '"..vehmodel.."', '"..hash.."', '{}', '"..newplate.."', 0)")
        -- UPDATE STOCK -1
        QBCore.Functions.ExecuteSql(false, 'UPDATE '..job..'_stock SET stock = stock - 1 WHERE (vehicle = "'..vehmodel..'")')
        -- EMAIL
    else
        TriggerClientEvent('QBCore:Notify',src,"Vehicle not in stock.","error")
    end
end)

QBCore.Commands.Add("Sellcar","Sell a car from the showroom", {{name = "ID", help = "Player ID"}} , false, function(source,args)
    local sourcePlayer = QBCore.Functions.GetPlayer(source)
    local targetPlayer = QBCore.Functions.GetPlayer(tonumber(args[1]))

    if sourcePlayer.PlayerData.job.name == "cardealer" then
        target = args[1]
        targetName = targetPlayer.PlayerData.name
        job = sourcePlayer.PlayerData.job.name
        TriggerClientEvent('qb-cardealer:client:sellConfirm',source,target,targetName, job)
    end
end)

QBCore.Commands.Add("Testdrive", "Testdrive a car", {} , false, function(source,args)
    local sourcePlayer = QBCore.Functions.GetPlayer(source)
    local job = sourcePlayer.PlayerData.job.name
    if job == "cardealer" then
        TriggerClientEvent("qb-cardealer:client:testdrive",source)
    else
        TriggerClientEvent('QBCore:Notify',source,"This is only for vehicle salesmen","error")
    end
end)

function GeneratePlate()
    local plate = tostring(GetRandomNumber(1)) .. GetRandomLetter(2) .. tostring(GetRandomNumber(3)) .. GetRandomLetter(2)
    QBCore.Functions.ExecuteSql(true, "SELECT * FROM `player_vehicles` WHERE `plate` = '"..plate.."'", function(result)
        while (result[1] ~= nil) do
            plate = tostring(GetRandomNumber(1)) .. GetRandomLetter(2) .. tostring(GetRandomNumber(3)) .. GetRandomLetter(2)
        end
        return plate
    end)
    return plate:upper()
end

function GetRandomNumber(length)
	Citizen.Wait(1)
	math.randomseed(GetGameTimer())
	if length > 0 then
		return GetRandomNumber(length - 1) .. NumberCharset[math.random(1, #NumberCharset)]
	else
		return ''
	end
end

function GetRandomLetter(length)
	Citizen.Wait(1)
	math.randomseed(GetGameTimer())
	if length > 0 then
		return GetRandomLetter(length - 1) .. Charset[math.random(1, #Charset)]
	else
		return ''
	end
end