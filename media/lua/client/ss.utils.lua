local json = require("ss.json")

local utils = {}

utils.color = {
    red = { 1, 0, 0 },
    green = { 0, 1, 0 },
    blue = { 0, 0, 1 },
    yellow = { 1, 1, 0 },
    cyan = { 0, 1, 1 },
    white = { 1, 1, 1 },
    black = { 0, 0, 0 },
}


utils.fn = {}

utils.fn.getUIText = function(t)
    return getText("IGUI_SS_BARTITLE_" .. t)
end

utils.fn.getPColor = function(fcolor, tcolor, p)
    local r = fcolor[1] + (tcolor[1] - fcolor[1]) * p
    local g = fcolor[2] + (tcolor[2] - fcolor[2]) * p
    local b = fcolor[3] + (tcolor[3] - fcolor[3]) * p
    return { r, g, b }
end

utils.fn.getStrWidth = function(str)
    return getTextManager():MeasureStringX(UIFont.Small, str)
end

utils.fn.loadConfig = function()
    local file, _ = getModFileReader("simpleStatus", "config.json", true)
    if file == nil then return nil end

    local contents = file:readLine()
    file:close()
    if contents == "" or contents == nil then return nil end

    return json.decode(contents)
end

utils.fn.saveConfig = function(config)
    local file, _ = getModFileWriter("simpleStatus", "config.json", true, false)
    if file == nil then return nil end

    local contents = json.encode(config)
    file:write(contents)
    file:close()
end

utils.fn.maxWidthOfStrs = function(strs)
    local maxl = 0
    for _, str in ipairs(strs) do
        local l = utils.fn.getStrWidth(str)
        if l > maxl then maxl = l end
    end
    return maxl
end

utils.fn.getTempStr = function(temp)
    local c = getCore():getOptionDisplayAsCelsius()
    local unit = string.char(176) .. "C"
    if not c then
        temp = temp * 1.8 + 32
        unit = string.char(176) .. "F"
    end
    temp = round((temp * 10.0) / 10, 1)
    return tostring(temp) .. " " .. unit
end


utils.fn.SetFn = {
    addToSet = function(set, key)
        set[key] = true
    end,
    removeFromSet = function(set, key)
        set[key] = nil
    end,
    setContains = function(set, key)
        return set[key] ~= nil
    end
}

return utils
