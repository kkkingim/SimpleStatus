local utils = require("ss.utils")
local getUIText = utils.fn.getUIText

return function()
    if getActivatedMods():contains("Urination") then

        local function round(num, numDecimalPlaces)
            local mult = 10^(numDecimalPlaces or 0)
            return math.floor(num * mult + 0.5) / mult
        end
    
        local valueFn = function(p)
            local u = p:getModData()["Urinate"]
            if (type(u) ~= "number") then
                u = 0.0
            end
            return round(u * 100 * 1.66667, 1)
        end
    
        SimpleStatus:addBar({ name = "mod-urination-u", title = getUIText("MOD_URINATION_U"), valueFn = valueFn, ivalue = 0, shown = true })
    end
end

