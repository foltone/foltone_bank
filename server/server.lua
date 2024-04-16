ESX = exports["es_extended"]:getSharedObject()

ESX.RegisterServerCallback("foltone_bank:getPlayerAccounts", function(source, cb)
    cb(ESX.GetPlayerFromId(source).xPlayer.getAccounts())
end)

ESX.RegisterServerCallback("foltone_bank:withdrawMoney", function(source, cb, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getAccounts()["money"].money >= amount then
        xPlayer.removeAccountMoney("money", amount)
        cb(true)
    else
        cb(false)
    end
end)

ESX.RegisterServerCallback("foltone_bank:depositMoney", function(source, cb, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getMoney() >= amount then
        xPlayer.removeMoney(amount)
        xPlayer.addAccountMoney("money", amount)
        cb(true)
    else
        cb(false)
    end
end)

ESX.RegisterServerCallback("foltone_bank:transferMoney", function(source, cb, amount, target)
    local xPlayer = ESX.GetPlayerFromId(source)
    local players = ESX.GetPlayers()
    local targetPlayer = nil
    for i = 1, #players do
        if players[i] == target then
            targetPlayer = ESX.GetPlayerFromId(target)
            break
        end
    end
    if targetPlayer then
        if xPlayer.getAccounts()["money"].money >= amount then
            xPlayer.removeAccountMoney("money", amount)
            targetPlayer.addAccountMoney("money", amount)
            cb(true)
        else
            cb(false)
        end
    else
        cb(false)
    end
end)
