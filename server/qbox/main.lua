local adapter = {}

function adapter:boot()
    return true
end

function adapter:getNeeds(_)
    return {}
end

DFHUD.ServerFrameworkAdapters.qbx = adapter

