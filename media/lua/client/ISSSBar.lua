local ssBar = ISPanel:derive("ssBar")

local utils = require("ss.utils")

local lineHeight = getTextManager():getFontHeight(UIFont.Small)

local color = utils.color
local minOpacityPercentage = 10
local defaultMainOpacityPercentage = 65
local mainOpacity = defaultMainOpacityPercentage / 100
local getUIText = utils.fn.getUIText
local getPColor = utils.fn.getPColor
local loadConfig = utils.fn.loadConfig
local saveConfig = utils.fn.saveConfig
local getStrWidth = utils.fn.getStrWidth
local getTempStr = utils.fn.getTempStr


local function initConfig(config, x, y, barConfigs)
    config = config or {}
    config.barWidth = config.barWidth or lineHeight
    config.pos = config.pos or { x, y }
    config.toggleKey = config.toggleKey or 43
    config.isVertical = config.isVertical or false
    config.opacity = config.opacity or defaultMainOpacityPercentage
    config.shownConfig = config.shownConfig or {}

    for _, i in ipairs(barConfigs) do
        if config.shownConfig[i.name] == nil then
            config.shownConfig[i.name] = i.shown
        end
    end
    return config
end

function ssBar:drawTextWithShadow(text, x, y)
    self:drawText(text, x + 1, y, 0.0, 0.0, 0.0, mainOpacity, UIFont.Small)
    self:drawText(text, x, y + 1, 0.0, 0.0, 0.0, mainOpacity, UIFont.Small)
    self:drawText(text, x - 1, y, 0.0, 0.0, 0.0, mainOpacity, UIFont.Small)
    self:drawText(text, x, y - 1, 0.0, 0.0, 0.0, mainOpacity, UIFont.Small)

    self:drawText(text, x + 1, y + 1, 0.0, 0.0, 0.0, mainOpacity, UIFont.Small)
    self:drawText(text, x + 1, y - 1, 0.0, 0.0, 0.0, mainOpacity, UIFont.Small)
    self:drawText(text, x - 1, y + 1, 0.0, 0.0, 0.0, mainOpacity, UIFont.Small)
    self:drawText(text, x - 1, y - 1, 0.0, 0.0, 0.0, mainOpacity, UIFont.Small)

    self:drawText(text, x, y, 1.0, 1.0, 1.0, mainOpacity, UIFont.Small)
end

function ssBar:getBarColor(value, ivalue)
    -- value in range [0, 100]
    -- ivalue is 0 or 100
    local c = color.green
    if ivalue == 0 then value = 100 - value end

    if value > 75 then
        c = getPColor(color.yellow, color.green, (value - 75) / 25)
    elseif value > 25 then
        c = getPColor(color.red, color.yellow, (value - 25) / 50)
    else
        c = color.red
    end
    return c

end

function ssBar:prepareBarInfo()
    local barInfo = {}
    -- title, valueText, color, percent, type, name

    local bars = {}
    for _, i in ipairs(self.barConfigs) do
        if self.config.shownConfig[i.name] then table.insert(bars, i) end
    end

    for _, i in ipairs(bars) do
        local title = i.title
        local name = i.name
        local ivalue = i.ivalue
        local _type = i.type

        local value = nil
        if i.valueFn then value = i.valueFn(self.player) end
        local percent = 1
        local text = "-"
        local c = color.white

        if _type == nil then
            local valueFlow = nil
            if value then
                if value > 100 then
                    valueFlow, value = round(value - 100), 100
                end
                percent = value / 100
            end
            if value and ivalue then
                c = self:getBarColor(value, ivalue)
            end
            if value then text = tostring(value) end
            if valueFlow then text = text .. "(" .. valueFlow .. ")" end
            text = text .. " / 100"
        end
        if _type == "plain" then
            local vs = i.vs

            local v1 = vs[1] or 0
            local v2 = vs[2] or 100
            local v3 = vs[3] or 100

            if i.pg == true and vs ~= nil then
                if value < v1 then
                    percent = 0
                elseif value > v3 then
                    percent = 1
                else
                    percent = (value - v1) / (v3 - v1)
                end

            end
            if i.bg == true and vs ~= nil then
                local vmin = v1 + (v2 - v1) * 0.3
                local vmax = v2 + (v3 - v2) * 0.7
                if value > vmax then
                    c = color.red
                elseif value > v2 then
                    local p = (value - v2) / (vmax - v2)
                    c = getPColor(color.green, color.red, p)
                elseif value > vmin then
                    local p = (v2 - value) / (v2 - vmin)
                    c = getPColor(color.green, color.blue, p)
                else
                    c = color.blue
                end
            end

            if value then text = tostring(value) end
        end
        if _type == "temp" then
            if value then
                if name == "bodytemp" then
                    text = getTempStr(value)
                else
                    text = tostring(value)
                end
            end

        end
        -- if _type == "custom" then pass end
        if i.percentFn then percent = i:percentFn() or percent end
        if i.textFn then text = i:textFn() or text end
        if i.colorFn then c = i:colorFn() or c end

        table.insert(barInfo, { title, text, c, percent, _type, name })
    end
    self.barInfo = barInfo

end

function ssBar:adjustWindowSize()
    local count = #self.barInfo

    for _, i in ipairs(self.barInfo) do
        local l = getStrWidth(i[1]) + 10
        if l > self.titleLength then self.titleLength = l end
        l = getStrWidth(i[2])
        if l > self.textLength then self.textLength = l end
    end

    self.barLength = self.textLength + self.titleLength

    local w = self.barLength + 6
    local h = (self.config.barWidth + 3) * count + 3

    if self.config.isVertical then
        w = h
        self.barLength = 150
        h = self.barLength + self.config.barWidth + 9
    end

    self:setWidth(w)
    self:setHeight(h)
end

function ssBar:optClick(name)
    self.config.shownConfig[name] = not self.config.shownConfig[name]
    self:prepareBarInfo()
    self:adjustWindowSize()
    saveConfig(self.config)
end

function ssBar:optClickVertical()
    self.config.isVertical = not self.config.isVertical
    self:adjustWindowSize()
    saveConfig(self.config)
end

function ssBar:drawTempBar(percent, i)
    -- horizontal bar, maybe there is an vertical one
    local gradientTex = getTexture("media/ui/BodyInsulation/heatbar_horz")
    local highlightTex = getTexture("media/ui/BodyInsulation/gradient_highlight")
    local radius = 20
    local darkAlpha = 0.75 * mainOpacity

    local barw = self.config.barWidth
    local barl = self.barLength
    local y = (barw + 3) * i - barw

    -- draw heatbar
    self:drawTextureScaled(gradientTex, 3, y, barl, barw, mainOpacity, 1.0, 1.0, 1.0)

    -- draw stat
    local valOffset = percent * barl
    valOffset = round(PZMath.clampFloat(valOffset, radius, barl - radius))
    if valOffset > radius then
        self:drawTextureScaled(nil, 3, y, valOffset - radius, barw, darkAlpha, 0.0, 0.0, 0.0)
    end
    if valOffset < barl - radius then
        self:drawTextureScaled(nil, 3 + valOffset + radius, y, barl - valOffset - radius, barw, darkAlpha, 0.0, 0.0, 0.0)
    end
    local highlightTexX = round(PZMath.clampFloat(valOffset - radius + 3, 3, 3 + barl - radius * 2))
    self:drawTextureScaled(highlightTex, highlightTexX, y, 2 * radius, barw, darkAlpha, 0.0, 0.0, 0.0)
end

function ssBar:getHoverBar(barw)
    local x = getMouseX()
    local y = getMouseY()
    local bar = {
        x = self.x,
        y = self.y,
        w = self.width,
        h = self.height,
    }
    if x <= bar.x or y <= bar.y or x >= bar.x + bar.w or y >= bar.y + bar.h then return nil end
    x = x - bar.x
    y = y - bar.y

    local xp = 0
    local index = 1
    while xp < bar.w do
        xp = xp + 3
        if x >= xp and x <= xp + barw then
            return index, x, y
        end
        index = index + 1
        xp = xp + barw
    end
    return nil
end

function ssBar:renderHBars()
    local barInfo = self.barInfo
    -- title, valueText, color, percent, _type, name

    for i, v in ipairs(barInfo) do
        local title = v[1]
        local valueText = v[2]
        local c = v[3]
        local percent = v[4]
        local _type = v[5]

        local rectw = round(percent * self.barLength)
        local y = (self.config.barWidth + 3) * i - self.config.barWidth
        local textX = self.barLength - getStrWidth(valueText) - 3

        if _type == "temp" then
            self:drawTempBar(percent, i)
        else
            self:drawRectStatic(3, y, rectw, self.config.barWidth, mainOpacity, c[1], c[2], c[3])
        end
        self:drawTextWithShadow(title, 3, y)
        self:drawTextWithShadow(valueText, textX, y)

    end
end

function ssBar:renderVBars()
    local barInfo = self.barInfo
    -- title, valueText, color, percent, _type, name

    for i, v in ipairs(barInfo) do
        local c = v[3]
        local percent = v[4]
        local _type = v[5]
        local name = v[6]

        if _type == "temp" then percent = 1 end

        local x = (self.config.barWidth + 3) * i - self.config.barWidth
        local recth = round(percent * self.barLength)

        local tex = getTexture("media/ui/ss-" .. name .. ".png")
        if not tex then tex = getTexture("media/ui/ss-unknow.png") end
        self:drawTextureScaled(tex, x, self.barLength + 6, self.config.barWidth, self.config.barWidth, mainOpacity, 1.0, 1.0, 1.0)

        self:drawRectStatic(x, self.barLength - recth + 3, self.config.barWidth, recth, mainOpacity, c[1], c[2], c[3])
    end

    -- show tooltip
    local index, tooltipx, tooltipy = self:getHoverBar(self.config.barWidth)
    if index then
        local bar = barInfo[index]

        local title = bar[1]
        local valueText = bar[2]

        local tooltip = title .. " : " .. valueText

        if tooltip ~= "" then
            self:drawTextWithShadow(tooltip, tooltipx - 5, tooltipy - self.config.barWidth - 5)
        end
    end
end

function ssBar:prerender()
    ISPanel.prerender(self)
    self:prepareBarInfo()
    if self.config.isVertical then
        self:renderVBars()
    else
        self:renderHBars()
    end
end

function ssBar:onMouseUp(x, y)
    ISPanel.onMouseUp(self, x, y)
    self.config.pos = { self.x, self.y }
    saveConfig(self.config)
end

function ssBar:onRightMouseUp(x, y)
    ISPanel.onRightMouseUp(self, x, y)
    if not (self.player or {}).getPlayerNum then return end

    local contextMenu = ISContextMenu.get(self.player:getPlayerNum(), getMouseX() + 5, getMouseY() + 5)

    --toggles
    local configOpts = contextMenu:addOption("[ " .. getUIText("O_OPTION") .. " ]", self, nil)
    local configOptsMenu = ISContextMenu:getNew(contextMenu)
    contextMenu:addSubMenu(configOpts, configOptsMenu)
    local optionVertical = configOptsMenu:addOption(getUIText("O_VERTICAL"), self, self.optClickVertical)
    optionVertical.checkMark = self.config.isVertical

    --opacities
    local configOpacity = contextMenu:addOption ( "[ " .. getUIText("O_OPACITY") .. " ]" , self , nil)
    local configOpacityMenu = ISContextMenu:getNew(contextMenu)
    contextMenu:addSubMenu ( configOpacity , configOpacityMenu )
    for i = minOpacityPercentage,100,5 do
        local o = configOpacityMenu:addOption ( i .. "%" , self , self.setMainOpacity , i )
        o.checkMark = i == self.config.opacity
    end

    --show/hide bars
    for _, i in ipairs(self.barConfigs) do
        local o = contextMenu:addOption(i.title, self, self.optClick, i.name)
        o.checkMark = self.config.shownConfig[i.name]
    end

end

function ssBar:setMainOpacity ( opacity )
    opacity = math.max ( minOpacityPercentage , math.min ( tonumber ( opacity ) or defaultMainOpacityPercentage , 100 ) )
    self.config.opacity = opacity
    mainOpacity = opacity / 100
    self.backgroundColor.a = 0.5 * mainOpacity  --ISPanel default BG alpha is 0.5
    self.borderColor.a = mainOpacity            --ISPanel default border alpha is 1.0
end

function ssBar:handleKey(key)
    if (isShiftKeyDown() and key == self.config.toggleKey) then
        self.shown = not self.shown
        if self.shown then
            self:setVisible(true)
            self:addToUIManager()
        else
            self:setVisible(false)
            self:removeFromUIManager()
        end
    end
end


function ssBar:new(x, y, player, barConfigs)
    -- load config
    local config = loadConfig()
    config = initConfig(config, x, y, barConfigs)

    local o = ISPanel:new(config.pos[1], config.pos[2], 0, 0)
    setmetatable(o, self)
    self.__index = self

    o.moveWithMouse = true

    o.player = player
    o.barConfigs = barConfigs

    o.config = config
    saveConfig(o.config)

    o.barInfo     = {}
    o.titleLength = 50
    o.textLength  = 50
    o.barLength   = 100
    o:setMainOpacity ( config.opacity )

    o.shown = true

    o:prepareBarInfo()
    o:adjustWindowSize()
    return o
end

return ssBar
