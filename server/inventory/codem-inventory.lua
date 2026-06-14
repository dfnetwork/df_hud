DFHUD.ServerInventoryAdapters['codem-inventory'] = {
    hasItem = function(source, itemName)
        local ok, item = pcall(function()
            return exports['codem-inventory']:GetItemByName(source, itemName)
        end)

        if not ok or type(item) ~= 'table' then
            return false
        end

        return (tonumber(item.amount or item.count) or 0) > 0
    end,
}

