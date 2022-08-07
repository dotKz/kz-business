-- Last line replace


-- Listen to Shared being updated
RegisterNetEvent('QBCore:Client:OnSharedUpdate', function(tableName, key, value)
    QBShared[tableName][key] = value
    --TriggerEvent('QBCore:Client:UpdateObject')
end)

RegisterNetEvent('QBCore:Client:OnSharedUpdateMultiple', function(tableName, values)
    for key, value in pairs(values) do
        QBShared[tableName][key] = value
    end
    --TriggerEvent('QBCore:Client:UpdateObject')
end)
