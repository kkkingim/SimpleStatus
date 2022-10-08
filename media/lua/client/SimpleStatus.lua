local ssBar = require("ISSSBar");

local infoBar = nil;

local function getUIText(t)
    return getText("IGUI_SS_BARTITLE_" .. t)
end

local function healthValueFn(p)
    return round(p:getBodyDamage():getHealth())
end

local function enduranceValueFn(p)
    return round(p:getStats():getEndurance() * 100)
end

local function fatigueValueFn(p)
    return round((p:getStats():getFatigue()) * 100)
end

local function happyValueFn(p)
    return round(100 - p:getBodyDamage():getUnhappynessLevel())
end

local function boredomValueFn(p)
    return round(p:getBodyDamage():getBoredomLevel())
end

local function hungerValueFn(p)
    return round((1 - p:getStats():getHunger()) * 100)
end

local function thirstValueFn(p)
    return round((1 - p:getStats():getThirst()) * 100)
end

local function caloriesValueFn(p)
    return round(p:getNutrition():getCalories(), 1)
end

local function weightValueFn(p)
    return round(p:getNutrition():getWeight(), 1)
end

local function carbohydratesValueFn(p)
    return round(p:getNutrition():getCarbohydrates(), 1)
end

local function proteinsValueFn(p)
    return round(p:getNutrition():getProteins(), 1)
end

local function lipidsValueFn(p)
    return round(p:getNutrition():getLipids(), 1)
end

local function angerValueFn(p)
    return round(p:getStats():getAnger() * 100)
end

-- local function fearValueFn(p)
--     return round(p:getStats():getFear() * 100)
-- end


local function painValueFn(p)
    return round(p:getStats():getPain())
end

local function panicValueFn(p)
    return round(p:getStats():getPanic())
end

local function stressValueFn(p)
    return round(p:getStats():getStress() * 100)
end

local function bodyTempValueFn(p)
    local thermos = p:getBodyDamage():getThermoregulator()
    return round(thermos:getCoreTemperature(), 1), thermos:getCoreTemperatureUI()
end

local function bodyHeatGenValueFn(p)
    local thermos = p:getBodyDamage():getThermoregulator()
    return round(thermos:getMetabolicRateReal(), 1), thermos:getHeatGenerationUI()
end

--[[

local function testTextFn()
    return tostring(round(getPlayer():getStats():getEndurance() * 100)) .. " %"
end

local function testColorFn()
    return {1, 1, 0}
end

local function testPercentFn()
    return 0.5
end

]]

ss_barConfigs = {
    { name = "health", title = getUIText("HEALTH"), valueFn = healthValueFn, ivalue = 100, shown = true },
    { name = "endurance", title = getUIText("ENDURANCE"), valueFn = enduranceValueFn, ivalue = 100, shown = true },
    { name = "hunger", title = getUIText("HUNGER"), valueFn = hungerValueFn, ivalue = 100, shown = true },
    { name = "thirst", title = getUIText("THIRST"), valueFn = thirstValueFn, ivalue = 100, shown = true },
    { name = "happy", title = getUIText("HAPPY"), valueFn = happyValueFn, ivalue = 100, shown = false },

    { name = "fatigue", title = getUIText("FATIGUE"), valueFn = fatigueValueFn, ivalue = 0, shown = true },
    { name = "boredom", title = getUIText("BOREDOM"), valueFn = boredomValueFn, ivalue = 0, shown = false },
    { name = "pain", title = getUIText("PAIN"), valueFn = painValueFn, ivalue = 0, shown = false },
    { name = "panic", title = getUIText("PANIC"), valueFn = panicValueFn, ivalue = 0, shown = true },
    { name = "stress", title = getUIText("STRESS"), valueFn = stressValueFn, ivalue = 0, shown = false },
    { name = "anger", title = getUIText("ANGER"), valueFn = angerValueFn, ivalue = 0, shown = false },

    { name = "calories", title = getUIText("CALORIES"), valueFn = caloriesValueFn, type = "plain", shown = true, vs = { -2000, 1000, 3500 } },
    { name = "weight", title = getUIText("WEIGHT"), valueFn = weightValueFn, type = "plain", shown = true, vs = { 45, 80, 115 } },
    { name = "proteins", title = getUIText("PROTEINS"), valueFn = proteinsValueFn, type = "plain", shown = false, vs = { -500, 175, 1000 } },
    { name = "carbohydrates", title = getUIText("CARBOHYDRATES"), valueFn = carbohydratesValueFn, type = "plain", shown = false, vs = { -500, 0, 1000 }, bg = false },
    { name = "lipids", title = getUIText("LIPIDS"), valueFn = lipidsValueFn, type = "plain", shown = false, vs = { -500, 0, 1000 }, bg = false },

    { name = "bodytemp", title = getUIText("BODYTEMP"), valueFn = bodyTempValueFn, type = "temp", shown = true },
    { name = "bodyheatgen", title = getUIText("BODYHEATGEN"), valueFn = bodyHeatGenValueFn, type = "temp", shown = false },

    -- may not used in game ?
    -- {name = "fear", title = getUIText("FEAR"), valueFn = fearValueFn, ivalue = 0, shown = false},

    -- custom type example
    -- {name = "test", title = "TEST", type="custom", shown=true, ivalue=0, textFn=testTextFn, colorFn=testColorFn, percentFn=testPercentFn}

};

local function showss()
    if not rawequal(infoBar, nil) then
        infoBar:setVisible(false);
        infoBar:removeFromUIManager();
    end
    local base_x = 20;
    local base_y = 630;

    infoBar = ssBar:new(base_x, base_y, getPlayer(), ss_barConfigs);
    infoBar:initialise();
    infoBar:addToUIManager();
end

Events.OnCreatePlayer.Add(showss);
