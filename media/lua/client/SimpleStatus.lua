local ssBar = require("ISSSBar")
local utils = require("ss.utils")

local infoBar = nil

local color = utils.color
local getUIText = utils.fn.getUIText
local getPColor = utils.fn.getPColor
local setFn = utils.fn.SetFn


local valueFn = {
    health = function(p)
        return round(p:getBodyDamage():getHealth())
    end,
    endurance = function(p)
        return round(p:getStats():getEndurance() * 100)
    end,
    fatigue = function(p)
        return round((p:getStats():getFatigue()) * 100)
    end,
    rest = function(p)
        return round((1 - p:getStats():getFatigue()) * 100)
    end,
    happy = function(p)
        return round(100 - p:getBodyDamage():getUnhappynessLevel())
    end,
    unhappy = function(p)
        return round(p:getBodyDamage():getUnhappynessLevel())
    end,
    boredom = function(p)
        return round(p:getBodyDamage():getBoredomLevel())
    end,
    hunger = function(p)
        return round((1 - p:getStats():getHunger()) * 100)
    end,
    thirst = function(p)
        return round((1 - p:getStats():getThirst()) * 100)
    end,
    calories = function(p)
        return round(p:getNutrition():getCalories(), 1)
    end,
    weight = function(p)
        return round(p:getNutrition():getWeight(), 1)
    end,
    carbohydrates = function(p)
        return round(p:getNutrition():getCarbohydrates(), 1)
    end,
    proteins = function(p)
        return round(p:getNutrition():getProteins(), 1)
    end,
    lipids = function(p)
        return round(p:getNutrition():getLipids(), 1)
    end,
    anger = function(p)
        return round(p:getStats():getAnger() * 100)
    end,
    pain = function(p)
        return round(p:getStats():getPain())
    end,
    panic = function(p)
        return round(p:getStats():getPanic())
    end,
    stress = function(p)
        return round(p:getStats():getStress() * 100)
    end,
    bodyTemp = function(p)
        local thermos = p:getBodyDamage():getThermoregulator()
        return round(thermos:getCoreTemperature(), 1)
    end,
    bodyHeatGen = function(p)
        local thermos = p:getBodyDamage():getThermoregulator()
        return round(thermos:getMetabolicRateReal(), 1)
    end,
    dirtiness = function(p)
        local visual = p:getHumanVisual()
        local v = 0
        for i = 1, BloodBodyPartType.MAX:index() do
            local part = BloodBodyPartType.FromIndex(i - 1)
            v = v + visual:getBlood(part) + visual:getDirt(part)
        end
        return v / (BloodBodyPartType.MAX:index() * 2)
    end,
    cleanliness = function(p)
        local visual = p:getHumanVisual()
        local v = 0
        for i = 1, BloodBodyPartType.MAX:index() do
            local part = BloodBodyPartType.FromIndex(i - 1)
            v = v + visual:getBlood(part) + visual:getDirt(part)
        end
        return 1 - v / (BloodBodyPartType.MAX:index() * 2)
    end
    -- fear = function(p)
    --     return round(p:getStats():getFear() * 100)
    -- end

}
local textFn = {
    proteins = function()
        local value = valueFn.proteins(getPlayer())
        local valueText = tostring(round(value, 1))
        if value >= 50 and value <= 300 then
            valueText = valueText .. "(x1.5)"
        elseif value <= -300 then
            valueText = valueText .. "(x0.7)"
        end
        return valueText

    end,
    weight = function()
        local value = valueFn.weight(getPlayer())
        local valueText = "-"
        if value then
            valueText = tostring(value)
            local p = getPlayer()
            if p:getNutrition():isIncWeight() or p:getNutrition():isIncWeightLot() or p:getNutrition():isDecWeight() then
                if p:getNutrition():isIncWeight() and not p:getNutrition():isIncWeightLot() then
                    valueText = valueText .. "  +"
                end
                if p:getNutrition():isIncWeightLot() then
                    valueText = valueText .. "  ++"
                end
                if p:getNutrition():isDecWeight() then
                    valueText = valueText .. "  -"
                end
            end
        end
        return valueText
    end,
    dirtiness = function()
        local value = valueFn.dirtiness(getPlayer())
        return tostring(round(value * 100, 1)) .. " %"
    end,
    cleanliness = function()
        local value = valueFn.cleanliness(getPlayer())
        return tostring(round(value * 100, 1)) .. " %"
    end,
    weight_capacity = function()
        local player = getPlayer()
        return tostring(round(player:getInventoryWeight(), 2)) .. " / " .. tostring(round(player:getMaxWeight(), 2))
    end
}
local percentFn = {
    proteins = function()
        local value = valueFn.proteins(getPlayer())
        return (value + 500) / 1500
    end,
    weight = function()
        return 1
    end,
    bodyTemp = function()
        local thermos = getPlayer():getBodyDamage():getThermoregulator()
        return thermos:getCoreTemperatureUI()
    end,
    bodyHeatGen = function()
        local thermos = getPlayer():getBodyDamage():getThermoregulator()
        return thermos:getHeatGenerationUI()
    end,
    dirtiness = function()
        return valueFn.dirtiness(getPlayer())
    end,
    cleanliness = function()
        return valueFn.cleanliness(getPlayer())
    end
}
local colorFn = {
    proteins = function()
        -- -500 -300 50 300 1000
        local value = valueFn.proteins(getPlayer())
        if value < -300 then
            return color.red
        elseif value < 50 then
            return getPColor(color.red, color.green, (value + 300) / 350)
        elseif value < 300 then
            return color.green
        elseif value < 700 then
            return getPColor(color.green, color.yellow, (value - 300) / 400)
        else
            return getPColor(color.yellow, color.red, (value - 700) / 300)
        end
    end,
    weight = function()
        local value = valueFn.weight(getPlayer())
        if value > 100 then
            return color.red
        elseif value > 85 then
            return getPColor(color.green, color.red, (value - 85) / 15)
        elseif value > 75 then
            return color.green
        elseif value > 50 then
            return getPColor(color.blue, color.green, (value - 50) / 25)
        else
            return color.blue
        end
    end,
    bodyTemp = function()
        local p = percentFn.bodyTemp()
        if p > 0.75 then
            return getPColor(color.yellow, color.red, (p - 0.75) * 4)
        elseif p > 0.5 then
            return getPColor(color.green, color.yellow, (p - 0.5) * 4)
        elseif p > 0.25 then
            return getPColor(color.cyan, color.green, (p - 0.25) * 4)
        else
            return getPColor(color.blue, color.cyan, p * 4)
        end

    end,
    bodyHeatGen = function()
        local p = percentFn.bodyHeatGen()
        if p > 0.75 then
            return getPColor(color.yellow, color.red, (p - 0.75) * 4)
        elseif p > 0.5 then
            return getPColor(color.green, color.yellow, (p - 0.5) * 4)
        elseif p > 0.25 then
            return getPColor(color.cyan, color.green, (p - 0.25) * 4)
        else
            return getPColor(color.blue, color.cyan, p * 4)
        end
    end,
    dirtiness = function()
        local value = valueFn.dirtiness(getPlayer())
        local c = color.white
        if value < 0.5 then
            c = getPColor(color.green, color.yellow, value * 2)
        else
            c = getPColor(color.yellow, color.red, (value * 2 - 1))
        end
        return c
    end,
    cleanliness = function()
        local value = valueFn.cleanliness(getPlayer())
        local c = color.white
        if value < 0.5 then
            c = getPColor(color.red, color.yellow, value * 2)
        else
            c = getPColor(color.yellow, color.green, (value * 2 - 1))
        end
        return c
    end,
    weight_capacity = function()
        local player = getPlayer()
        local p = player:getInventoryWeight() / player:getMaxWeight()
        if p > 1 then p = 1 end
        return getPColor(color.green, color.red, p)
    end

}

SimpleStatus = {
    VERSION = "1.221012.1",
    ss_barConfigs = {},

    valueFn = valueFn,
    textFn = textFn,
    percentFn = percentFn,
    colorFn = colorFn,

    isNewer = function(self, ver)
        if ver == self.VERSION then return true end
        local v = {}
        local v1 = {}
        for i in string.gmatch(self.VERSION, "([^.]+)") do
            table.insert(v, tonumber(i))
        end
        for i in string.gmatch(ver, "([^.]+)") do
            table.insert(v1, tonumber(i))
        end
        for i = 1, 3 do
            if v1[i] > v[i] then return true end
            if v1[i] < v[i] then return false end
        end
        return true
    end,
    addBar = function(self, barObj)
        if self.ss_barConfigs then
            table.insert(self.ss_barConfigs, barObj)
            self.ss_barConfigs[barObj.name or ''] = barObj
        end
    end
}

local bars = {
    { name = "health", title = getUIText("HEALTH"), valueFn = valueFn.health, ivalue = 100, shown = true },
    { name = "endurance", title = getUIText("ENDURANCE"), valueFn = valueFn.endurance, ivalue = 100, shown = true },
    { name = "hunger", title = getUIText("HUNGER"), valueFn = valueFn.hunger, ivalue = 100, shown = true },
    { name = "thirst", title = getUIText("THIRST"), valueFn = valueFn.thirst, ivalue = 100, shown = true },
    { name = "happy", title = getUIText("HAPPY"), valueFn = valueFn.happy, ivalue = 100, shown = false },

    { name = "fatigue", title = getUIText("FATIGUE"), valueFn = valueFn.fatigue, ivalue = 0, shown = true },
    { name = "boredom", title = getUIText("BOREDOM"), valueFn = valueFn.boredom, ivalue = 0, shown = false },
    { name = "pain", title = getUIText("PAIN"), valueFn = valueFn.pain, ivalue = 0, shown = false },
    { name = "panic", title = getUIText("PANIC"), valueFn = valueFn.panic, ivalue = 0, shown = true },
    { name = "stress", title = getUIText("STRESS"), valueFn = valueFn.stress, ivalue = 0, shown = false },
    { name = "anger", title = getUIText("ANGER"), valueFn = valueFn.anger, ivalue = 0, shown = false },

    { name = "calories", title = getUIText("CALORIES"), valueFn = valueFn.calories, type = "plain", shown = true, vs = { -2000, 1000, 3500 }, bg = true },
    -- { name = "weight", title = getUIText("WEIGHT"), valueFn = valueFn.weight, type = "plain", shown = true, vs = { 35, 80, 115 }, bg = true },
    { name = "weight", title = getUIText("WEIGHT"), type = "custom", shown = false, textFn = textFn.weight, colorFn = colorFn.weight, percentFn = percentFn.weight },
    { name = "proteins", title = getUIText("PROTEINS"), type = "custom", shown = false, textFn = textFn.proteins, colorFn = colorFn.proteins, percentFn = percentFn.proteins },
    { name = "carbohydrates", title = getUIText("CARBOHYDRATES"), valueFn = valueFn.carbohydrates, type = "plain", shown = false, vs = { -500, 0, 1000 }, pg = true },
    { name = "lipids", title = getUIText("LIPIDS"), valueFn = valueFn.lipids, type = "plain", shown = false, vs = { -500, 0, 1000 }, pg = true },

    { name = "bodytemp", title = getUIText("BODYTEMP"), valueFn = valueFn.bodyTemp, percentFn = percentFn.bodyTemp, colorFn = colorFn.bodyTemp, type = "temp", shown = true },
    { name = "bodyheatgen", title = getUIText("BODYHEATGEN"), valueFn = valueFn.bodyHeatGen, percentFn = percentFn.bodyHeatGen, colorFn = colorFn.bodyHeatGen, type = "temp", shown = false },

    { name = "dirtiness", title = getUIText("DIRTINESS"), type = "custom", shown = false, textFn = textFn.dirtiness, colorFn = colorFn.dirtiness, percentFn = percentFn.dirtiness },

    { name = "happy-v", title = getUIText("UNHAPPY"), valueFn = valueFn.unhappy, ivalue = 0 },
    { name = "fatigue-v", title = getUIText("REST"), valueFn = valueFn.rest, ivalue = 100 },
    { name = "dirtiness-v", title = getUIText("CLEANLINESS"), type = "custom", textFn = textFn.cleanliness, colorFn = colorFn.cleanliness, percentFn = percentFn.cleanliness },

    { name = "weight-capacity", title = getUIText("WEIGHT-CAPACITY"), type = "custom", textFn = textFn.weight_capacity, colorFn = colorFn.weight_capacity},
    -- may not used in game ?
    -- {name = "fear", title = getUIText("FEAR"), valueFn = valueFn.fear, ivalue = 0, shown = false},

    -- custom type example
    -- {name = "test", title = "TEST", type="custom", shown=true, ivalue=0, textFn=testTextFn, colorFn=testColorFn, percentFn=testPercentFn}
    --## TEST UNIQUE ##
    -- { name = "weight", title = getUIText("WEIGHT"), type = "custom", shown = false, textFn = function() return "0.0" end, colorFn = colorFn.weight, percentFn = percentFn.weight },

    --[[ API Usage
    ## normal type ##
    { 
        name = "health",                   used in config.json, should be unique
        title = getUIText("HEALTH"),       title shown on bar
        valueFn = valueFn.health,          return 0-100, 
        ivalue = 100,                      init value, bar color is green while init value  
        shown = true                       shown on bars, only used in first time
    }

    ## plain type ##
    { 
        name = "lipids",                   used in config.json, should be unique
        title = getUIText("LIPIDS"),       title shown on bar
        valueFn = valueFn.lipids,          stat value 
        type = "plain",                    always 'plain'
        shown = false,                     shown on bars, only used in first time
        vs = { -500, 0, 1000 },            value min, value init, value max ; used to generate color and bar length
        bg = false                         false: white background color ,default false  
        pg = true                          true: show progress ,default false  
    }

    ## temporary type ##
    { 
        name = "bodytemp",                 used in config.json, should be unique
        title = getUIText("BODYTEMP"),     title shown on bar
        valueFn = valueFn.bodyTemp,        stat value show on bars
        percentFn = percentFn.bodyTemp,    stat percent value, bar percent 
        type = "temp",                     always 'temp'
        shown = true                       shown on bars, only used in first time
    }

    ## custom type ##
    { 
        name = "proteins",                 used in config.json, should be unique
        title = getUIText("PROTEINS"),     title shown on bar
        type = "custom",                   always 'custom'
        shown = false,                     shown on bars, only used in first time
        textFn = textFn.proteins,          value text
        colorFn = colorFn.proteins,        bar color
        percentFn = percentFn.proteins     stat percent value, bar percent    
    }

    ]]
}
for _, bar in ipairs(bars) do
    SimpleStatus:addBar(bar)
end

local function showss()
    if not rawequal(infoBar, nil) then
        infoBar:setVisible(false)
        infoBar:removeFromUIManager()
    end
    local base_x = 20
    local base_y = 630

    local bars = {}
    local names = {}
    for i = #SimpleStatus.ss_barConfigs, 1, -1 do
        local bar = SimpleStatus.ss_barConfigs[i]
        if not setFn.setContains(names, bar.name) then
            setFn.addToSet(names, bar.name)
            table.insert(bars, 1, bar)
        end
    end

    infoBar = ssBar:new(base_x, base_y, getPlayer(), bars)
    infoBar:initialise()
    infoBar:addToUIManager()
end

local function handleKey(key)
    if infoBar then infoBar:handleKey(key) end
    return key
end

Events.OnCreatePlayer.Add(showss)
Events.OnKeyPressed.Add(handleKey)
