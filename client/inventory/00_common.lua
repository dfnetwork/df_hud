local function getInventoryItemCount(items, itemName)
    if type(items) ~= 'table' then
        return 0
    end

    local direct = items[itemName]
    if type(direct) == 'table' then
        return tonumber(direct.count or direct.amount or direct.quantity or (type(direct.slot) == 'table' and direct.slot.count)) or 0
    end

    for key, entry in pairs(items) do
        if type(entry) == 'table' then
            local name = entry.name or entry.item or entry.fullid or key
            if name == itemName then
                return tonumber(entry.count or entry.amount or entry.quantity) or 0
            end
        elseif key == itemName then
            return tonumber(entry) or 0
        end
    end

    return 0
end

DFHUD.getInventoryItemCount = getInventoryItemCount

