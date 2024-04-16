local timeout = false
local function setTimeout(time)
    currentTimeout = true
    SetTimeout(time, function()
        currentTimeout = false
    end)
end
local function KeyboardInput(TextEntry, ExampleText, MaxStringLenght)
    AddTextEntry("FMMC_KEY_TIP1", TextEntry)
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLenght)
    blockinput = true
    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Wait(0)
    end
    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Wait(500)
        blockinput = false
        return result
    else
        Wait(500)
        blockinput = false
        return nil
    end
end

ESX = exports["es_extended"]:getSharedObject()

local bankMenu = RageUI.CreateMenu(_U("bank"), _U("bank_menu"))
local open = false

function RageUI.PoolMenus:Foltone()
	bankMenu.Closed = function()
		open = false
	end
	bankMenu:IsVisible(function(Items)
        Items:AddButton(_U("bank_balance"), nil, {RightLabel = "~g~"..ESX.PlayerData.Accounts["bank"].money.."$"}, function(onselected, onactive)
        end)
        Items:AddButton(_U("money"), nil, {RightLabel = "~g~"..ESX.PlayerData.Accounts["money"].money.."$"}, function(onselected, onactive)
        end)
        Items:AddButton(_U("withdraw"), nil, { RightLabel = "", IsDisabled = timout }, function(onselected, onactive)
            if onselected then
                setTimeout(500)
                local amount = KeyboardInput(_U("withdraw_amount"), "", 10)
                if amount then
                    amount = tonumber(amount)
                    if amount then
                        if amount > 0 and ESX.PlayerData.Accounts["bank"].money >= amount then
                            ESX.TriggerServerCallback("foltone_bank:withdrawMoney", function(ok)
                                if ok then
                                    Config.Notigication(_U("withdraw_success", amount))
                                else
                                    Config.Notigication(_U("withdraw_error"))
                                end
                            end, amount)
                        else
                            Config.Notigication(_U("invalid_amount"))
                        end
                    else
                        Config.Notigication(_U("invalid_amount"))
                    end
                end
            end
        end)
        Items:AddButton(_U("deposit"), nil, { RightLabel = "", IsDisabled = timout }, function(onselected, onactive)
            if onselected then
                setTimeout(500)
                local amount = KeyboardInput(_U("deposit_amount"), "", 10)
                if amount then
                    amount = tonumber(amount)
                    if amount then
                        if amount > 0 and ESX.PlayerData.Accounts["money"].money >= amount then
                            ESX.TriggerServerCallback("foltone_bank:depositMoney", function(ok)
                                if ok then
                                    Config.Notigication(_U("deposit_success", amount))
                                else
                                    Config.Notigication(_U("deposit_error"))
                                end
                            end, amount)
                        else
                            Config.Notigication(_U("invalid_amount"))
                        end
                    else
                        Config.Notigication(_U("invalid_amount"))
                    end
                end
            end
        end)
        Items:AddButton(_U("transfer"), nil, { RightLabel = "", IsDisabled = timout }, function(onselected, onactive)
            if onselected then
                setTimeout(500)
                local amount = KeyboardInput(_U("transfer_amount"), "", 10)
                if amount then
                    amount = tonumber(amount)
                    if amount then
                        if amount > 0 and ESX.PlayerData.Accounts["money"].money >= amount then
                            local target = KeyboardInput(_U("transfer_target"), "", 10)
                            if target then
                                target = tonumber(target)
                                if target then
                                    if target > 0 then
                                        ESX.TriggerServerCallback("foltone_bank:transferMoney", function(ok)
                                            if ok then
                                                Config.Notigication(_U("transfer_success", amount, target))
                                            else
                                                Config.Notigication(_U("transfer_error"))
                                            end
                                        end, amount, target)
                                    else
                                        Config.Notigication(_U("invalid_target"))
                                    end
                                else
                                    Config.Notigication(_U("invalid_target"))
                                end
                            end
                        else
                            Config.Notigication(_U("invalid_amount"))
                        end
                    else
                        Config.Notigication(_U("invalid_amount"))
                    end
                end
            end
        end)
    end, function(Panels)
	end)
end

CreateThread(function()
    while not ESX.PlayerLoaded do
        Wait(500)
    end
    local function CreateBlip(pos, sprite, size, color, name)
        local blip = AddBlipForCoord(pos)
        SetBlipSprite(blip, sprite)
        SetBlipScale(blip, size)
        SetBlipColour(blip, color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(name)
        EndTextCommandSetBlipName(blip)
    end
    for k, v in pairs(Config.BankPosition) do
        CreateBlip(v, 108, 0.8, 2, _U("bank"))
    end
    for k, v in pairs(Config.ATMPosition) do
        CreateBlip(v, 277, 0.4, 2, _U("atm"))
    end
    while true do
        local wait = 500
        local playerPed = PlayerPedId()
        local playerPos = GetEntityCoords(playerPed)
        for k, v in pairs(Config.BankPosition) do
            local distance = #(playerPos - v)
            if distance < 10 then
                wait = 0
                DrawMarker(1, v.x, v.y, v.z - 1, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 0, 255, 0, 200, 0, 0, 0, 0)
                if distance <= 1.5 then
                    ESX.ShowHelpNotification(_U("press_to_open"))
                    if IsControlJustPressed(0, 38) then
                        if not open then
                            ESX.TriggerServerCallback("foltone_bank:getPlayerAccounts", function(accounts)
                                ESX.PlayerData.accounts = accounts
                                RageUI.Visible(bankMenu, not RageUI.Visible(bankMenu))
                                open = true
                            end)
                        end
                    end
                elseif distance > 1.5 and open then
                    RageUI.Visible(bankMenu, false)
                    open = false
                end
            end
        end
        for k, v in pairs(Config.ATMPosition) do
            local distance = #(playerPos - v)
            if distance < 10 then
                wait = 0
                DrawMarker(1, v.x, v.y, v.z - 1, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 0, 255, 0, 200, 0, 0, 0, 0)
                if distance <= 1.5 then
                    ESX.ShowHelpNotification(_U("press_to_open"))
                    if IsControlJustPressed(0, 38) then
                        if not open then
                            ESX.TriggerServerCallback("foltone_bank:getPlayerAccounts", function(accounts)
                                ESX.PlayerData.accounts = accounts
                                RageUI.Visible(bankMenu, not RageUI.Visible(bankMenu))
                                open = true
                            end)
                        end
                    end
                elseif distance > 1.5 and open then
                    RageUI.Visible(bankMenu, false)
                    open = false
                end
            end
        end
        Wait(wait)
    end
end)

RegisterNetEvent("esx:playerLoaded")
AddEventHandler("esx:playerLoaded", function(xPlayer)
    ESX.PlayerLoaded = true
end)
RegisterNetEvent("esx:setAccountMoney")
AddEventHandler("esx:setAccountMoney", function(account)
    ESX.PlayerData.accounts[account.name].money = account.money
end)
