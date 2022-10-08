local ssBar = ISPanel:derive("ssBar")
local json = require("ss.json")

local lineHeight = getTextManager():getFontHeight(UIFont.Small);

local colorRed = { 1, 0, 0 };
local colorGreen = { 0, 1, 0 };
local colorBlue = { 0, 0, 1 };
local colorYellow = { 1, 1, 0 };
local colorWhite = { 1, 1, 1 };

local function getUIText(t)
    return getText("IGUI_SS_BARTITLE_" .. t)
end

local function getPColor(fcolor, tcolor, p)
    local r = fcolor[1] + (tcolor[1] - fcolor[1]) * p;
    local g = fcolor[2] + (tcolor[2] - fcolor[2]) * p;
    local b = fcolor[3] + (tcolor[3] - fcolor[3]) * p;

    return { r, g, b }
end

function ssBar:getShownCount()
    local shown_count = 0;
    for _, v in pairs(self.config.shownConfig) do
        if v then shown_count = shown_count + 1 end
    end
    return shown_count;
end

function ssBar:loadConfig()
    local file, _ = getModFileReader("simpleStatus", "config.json", true)
    if file == nil then return nil end

    local contents = file:readLine();
    file:close();
    if contents == "" or contents == nil then return nil end

    return json.decode(contents)

    -- local config = player:getModData()["ss_config"]
    -- return config
end

function ssBar:saveConfig(config)
    local file, _ = getModFileWriter("simpleStatus", "config.json", true, false)
    if file == nil then return nil end

    local contents = json.encode(config);
    file:write(contents);
    file:close();

    -- self.player:getModData()["ss_config"] = self.config
end

function ssBar:optClick(name)
    self.config.shownConfig[name] = not self.config.shownConfig[name];

    local count = self:getShownCount();
    local w = self.barLen + 6;
    local h = (self.config.barWidth + 3) * count + 3;

    if self.config.isVertical then
        w, h = h, w;
        h = h + self.config.barWidth - 3;
    end

    self:setWidth(w);
    self:setHeight(h);

    self:saveConfig(self.config);
end

function ssBar:optClickVertical()
    self.config.isVertical = not self.config.isVertical;
    
    local count = self:getShownCount();
    local w = self.barLen + 6;
    local h = (self.config.barWidth + 3) * count + 3;

    if self.config.isVertical then
        w, h = h, w;
        h = h + self.config.barWidth - 3;
    end

    self:setWidth(w);
    self:setHeight(h);

    self:saveConfig(self.config);
end

function ssBar:drawTextWithShadow(text, x, y)
    self:drawText(text, x + 1, y, 0.0, 0.0, 0.0, 0.66, UIFont.Small);
    self:drawText(text, x, y + 1, 0.0, 0.0, 0.0, 0.66, UIFont.Small);
    self:drawText(text, x - 1, y, 0.0, 0.0, 0.0, 0.66, UIFont.Small);
    self:drawText(text, x, y - 1, 0.0, 0.0, 0.0, 0.66, UIFont.Small);

    self:drawText(text, x + 1, y + 1, 0.0, 0.0, 0.0, 0.66, UIFont.Small);
    self:drawText(text, x + 1, y - 1, 0.0, 0.0, 0.0, 0.66, UIFont.Small);
    self:drawText(text, x - 1, y + 1, 0.0, 0.0, 0.0, 0.66, UIFont.Small);
    self:drawText(text, x - 1, y - 1, 0.0, 0.0, 0.0, 0.66, UIFont.Small);

    self:drawText(text, x, y, 1.0, 1.0, 1.0, 1.0, UIFont.Small);
end

function ssBar:drawTempBar(percent, i)
    -- horizontal bar, maybe there is an vertical one
    local gradientTex = getTexture("media/ui/BodyInsulation/heatbar_horz");
    local highlightTex = getTexture("media/ui/BodyInsulation/gradient_highlight");
    local radius = 10;
    local darkAlpha = 0.6;

    local barw = self.config.barWidth;
    local barl = self.barLen;
    local y = (barw + 3) * i - barw;

    -- draw heatbar
    self:drawTextureScaled(gradientTex, 3, y, barl, barw, 1.0, 1.0, 1.0, 1.0);

    -- draw stat
    local valOffset = percent * barl;
    valOffset = round(PZMath.clampFloat(valOffset, radius, barl - radius));
    if valOffset > radius then
        self:drawTextureScaled(nil, 3, y, valOffset - radius, barw, darkAlpha, 0.0, 0.0, 0.0);
    end
    if valOffset < barl - radius then
        self:drawTextureScaled(nil, 3 + valOffset + radius, y, barl - valOffset - radius, barw, darkAlpha, 0.0, 0.0, 0.0);
    end
    local highlightTexX = round(PZMath.clampFloat(valOffset - radius + 3, 3, 3 + barl - radius * 2));
    self:drawTextureScaled(highlightTex, highlightTexX, y, 2 * radius, barw, darkAlpha, 0.0, 0.0, 0.0);
end

function ssBar:getBarColor(value, ivalue)
    -- value in range(0, 100)
    -- ivalue is 0 or 100
    local color = colorGreen;
    if ivalue == 0 then value = 100 - value end

    if value > 75 then
        color = getPColor(colorGreen, colorYellow, 1 - (value - 75) / 25);
    elseif value > 25 then
        color = getPColor(colorYellow, colorRed, 1 - (value - 25) / 50);
    else
        color = colorRed;
    end
    return color;

end

function ssBar:getHoverBar(onebarw)
    local x = getMouseX()
    local y = getMouseY()
    local bar = {
        x = self.x,
        y = self.y,
        w = self.width,
        h = self.height,
    }
    if x <= bar.x or y <= bar.y or x >= bar.x + bar.w or y >= bar.y + bar.h then return nil end
    x = x - bar.x;
    y = y - bar.y;

    local xp = 0;
    local index = 1;
    while xp < bar.w do
        xp = xp + 3;
        if x >= xp and x <= xp + onebarw then
            return index, x, y;
        end
        index = index + 1;
        xp = xp + onebarw;
    end
    return nil;
end

function ssBar:renderHBars()
    local bars = {};
    for _, v in ipairs(self.barConfigs) do
        if self.config.shownConfig[v.name] then table.insert(bars, v) end
    end

    for i, v in ipairs(bars) do
        local title = v.title;
        local valueFn = v.valueFn;
        local ivalue = v.ivalue;
        local barType = v.type;
        local barName = v.name;

        local value = 0;
        if valueFn then value = valueFn(self.player) end
        local valueText = "-";

        -- bar line left-top
        local y = (self.config.barWidth + 3) * i - self.config.barWidth;
        local textX = round(self.barLen * self.stp) + 3;

        if not barType then
            -- nomal bar
            local valueFlow = nil;
            if value > 100 then
                valueFlow = round(value - 100);
                value = 100;
            end
            local p = value / 100;
            local rectw = round(p * self.barLen);
            local color = self:getBarColor(value, ivalue);

            if value then
                valueText = tostring(value);
            end
            if valueFlow then
                valueText = valueText .. "(" .. tostring(valueFlow) .. ")";
            end
            valueText = valueText .. " / 100";


            self:drawRectStatic(3, y, rectw, self.config.barWidth, 0.66, color[1], color[2], color[3]);

            self:drawTextWithShadow(title, 3, y);
            self:drawTextWithShadow(valueText, textX, y);

        elseif barType == "temp" then
            -- temp-like bar
            local p = 0.5;
            value, p = valueFn(self.player);
            if value then valueText = tostring(round(value, 1)) end

            self:drawTempBar(p, i);
            self:drawTextWithShadow(title, 3, y);
            self:drawTextWithShadow(valueText, textX, y);

        elseif barType == "plain" then
            local vs = v.vs;

            local v1 = vs[1];
            local v2 = vs[2];
            local v3 = vs[3];
            local vmin = v1 + (v2 - v1) * 0.3;
            local vmax = v2 + (v3 - v2) * 0.7;

            local color = {};

            if value > vmax then
                color = colorRed;
            elseif value > v2 then
                local p = (value - v2) / (vmax - v2);
                color = getPColor(colorGreen, colorRed, p);
            elseif value > vmin then
                local p = (v2 - value) / (v2 - vmin);
                color = getPColor(colorGreen, colorBlue, p);
            else
                color = colorBlue;
            end
            if v1 == v2 and v2 == v3 then
                color = colorWhite;
            end
            local barl = self.barLen;

            if v.bg == false then
                barl = round((value - v1) / (v3 - v1) * barl);
                color = colorWhite;
            end
            self:drawRectStatic(3, y, barl, self.config.barWidth, 0.66, color[1], color[2], color[3]);

            if value then valueText = tostring(value) end
            if barName == "proteins" then
                if value >= 50 and value <= 300 then
                    valueText = valueText .. "(x1.5)";
                elseif value <= -300 then
                    valueText = valueText .. "(x0.7)";
                end
            end
            self:drawTextWithShadow(title, 3, y);
            self:drawTextWithShadow(valueText, textX, y);

        elseif barType == "custom" then
            local color = nil;
            if v.colorFn then color = v.colorFn() end
            local p = nil;
            if v.percentFn then p = v.percentFn() end
            if v.textFn then valueText = v.textFn() or "-" end
            if p then
                if color == nil then
                    color = self:getBarColor(p * 100, v.ivalue or 100);
                end
                local barl = round(p * self.barLen);
                self:drawRectStatic(3, y, barl, lineHeight, 0.66, color[1], color[2], color[3]);
                self:drawTextWithShadow(valueText, textX, y);
            else
                self:drawTextWithShadow("ERROR", textX, y);
            end
            self:drawTextWithShadow(title, 3, y);
        end
    end


end

function ssBar:renderVBars()
    local bars = {};
    for _, v in ipairs(self.barConfigs) do
        if self.config.shownConfig[v.name] then table.insert(bars, v) end
    end
    local barw = self.config.barWidth;

    for i, v in ipairs(bars) do

        local x = (barw + 3) * i - barw;

        -- draw the icons
        local tex = getTexture("media/ui/ss-" .. v.name .. ".png");
        if not tex then tex = getTexture("media/ui/ss-unknow.png") end
        self:drawTextureScaled(tex, x, self.barLen + 3, barw, barw, 1.0, 1.0, 1.0, 1.0);

        -- draw bars
        if not v.type then
            -- local title = v.title;
            local value = v.valueFn(self.player);
            if value > 100 then value = 100 end
            local ivalue = v.ivalue;

            local valueP = value / 100;
            local barl = round(valueP * self.barLen);

            local color = self:getBarColor(value, ivalue);

            self:drawRectStatic(x, self.barLen - barl + 3, barw, barl, 0.66, color[1], color[2], color[3]);

        elseif v.type == "plain" then
            local vs = v.vs;
            local value = v.valueFn(self.player);

            local v1 = vs[1];
            local v2 = vs[2];
            local v3 = vs[3];
            local vmin = v1 + (v2 - v1) * 0.3;
            local vmax = v2 + (v3 - v2) * 0.7;

            local color = {};

            if value > vmax then
                color = colorRed;
            elseif value > v2 then
                local p = (value - v2) / (vmax - v2);
                color = getPColor(colorGreen, colorRed, p);
            elseif value > vmin then
                local p = (v2 - value) / (v2 - vmin);
                color = getPColor(colorGreen, colorBlue, p);
            else
                color = colorBlue;
            end
            if v1 == v2 and v2 == v3 then
                color = colorWhite;
            end
            local barl = self.barLen;

            -- bg == false, bar percent instead
            if v.bg == false then
                barl = round((value - v1) / (v3 - v1) * barl);
                color = colorWhite;
            end
            self:drawRectStatic(x, self.barLen + 3 - barl, barw, barl, 0.66, color[1], color[2], color[3]);

        elseif v.type == "temp" then
            local _, p = v.valueFn(self.player);
            
            -- get temp color
            local color = {};
            if p > 0.7 then
                color = colorRed;
            elseif p > 0.5 then
                color = getPColor(colorGreen, colorRed, (p - 0.5) / 0.2);
            elseif p > 0.3 then
                color = getPColor(colorBlue, colorGreen, (p - 0.3) / 0.2);
            else
                color = colorBlue;
            end

            self:drawRectStatic(x, 3, barw, self.barLen, 0.66, color[1], color[2], color[3]);
        elseif v.type == "custom" then
            local color = nil;
            if v.colorFn then color = v.colorFn() end
            local p = nil;
            if v.percentFn then p = v.percentFn() end
            if p then
                if color == nil then
                    color = self:getBarColor(p * 100, v.ivalue or 100);
                end
                local barl = round(p * self.barLen);
                self:drawRectStatic(x, self.barLen + 3 - barl, barw, barl, 0.66, color[1], color[2], color[3]);
            end

        end
        -- show tooltip
        local index, tooltipx, tooltipy = self:getHoverBar(barw);
        if index then
            local bar = bars[index];
            local tooltip = "";

            if bar.type and bar.type == "custom" then
                local valueText = "-";
                if bar.textFn ~= nil then valueText = bar.textFn() or valueText end
                tooltip = bar.title .. " : " .. valueText;
            else
                local valueText = "-";
                local value = bar.valueFn(self.player);
                local valueFlow = nil;

                if value > 100 and not bar.type then
                    valueFlow = round(value - 100);
                    value = 100;
                end
                if value then
                    valueText = tostring(value);
                end
                if valueFlow then
                    valueText = valueText .. "(" .. tostring(valueFlow) .. ")";
                end
                if bar.name == "proteins" then
                    if value >= 50 and value <= 300 then
                        valueText = valueText .. "(x1.5)";
                    elseif value <= -300 then
                        valueText = valueText .. "(x0.7)";
                    end
                end
                tooltip = bar.title .. " : " .. valueText;
            end
            if tooltip ~= "" then
                self:drawTextWithShadow(tooltip, tooltipx - 5, tooltipy - lineHeight - 5);
            end
        end
    end
end

function ssBar:prerender()
    ISPanel.prerender(self);

    if self.config.isVertical then
        self:renderVBars()
    else
        self:renderHBars()
    end
end

function ssBar:onMouseUp(x, y)
    ISPanel.onMouseUp(self, x, y)
    self.config.pos = { self.x, self.y }

    self:saveConfig(self.config)
end

function ssBar:onRightMouseUp(x, y)
    ISPanel.onRightMouseUp(self, x, y)
    if not (self.player or {}).getPlayerNum then return end

    local contextMenu = ISContextMenu.get(self.player:getPlayerNum(), getMouseX() + 5, getMouseY() + 5);
    local configOpts = contextMenu:addOption("[ " .. getUIText("O_OPTION") .. " ]", self, nil);
    local configContectMenu = ISContextMenu:getNew(contextMenu);
    contextMenu:addSubMenu(configOpts, configContectMenu);

    local isv = configContectMenu:addOption(getUIText("O_VERTICAL"), self, self.optClickVertical);
    isv.checkMark = self.config.isVertical;

    for _, i in ipairs(self.barConfigs) do
        local o = contextMenu:addOption(i.title, self, self.optClick, i.name);
        o.checkMark = self.config.shownConfig[i.name]
    end

end

function ssBar:new(x, y, player, barConfigs)
    --region: set barL and stats text pos
    local fontsize = getCore():getOptionFontSize();
    if fontsize <= 2 then fontsize = 2 end
    fontsize = fontsize - 1;

    local lang = Translator.getLanguage():name();

    -- fontSizeFix for ES, DE
    if (lang == "ES" or lang == "DE") and getCore():getOptionFontSize() == 2 then
        fontsize = 2
    end

    local wAndStps = {
        EN = {
            [1] = { 150, 0.5 },
            [2] = { 230, 0.5 }
        },
        CN = {
            [1] = { 130, 0.4 },
            [2] = { 190, 0.4 }
        },
        KO = {
            [1] = { 145, 0.4 },
            [2] = { 205, 0.4 }
        },
        ES = {
            [1] = { 150, 0.5 },
            [2] = { 230, 0.55 }
        },
        RU = {
            [1] = { 180, 0.5 },
            [2] = { 180, 0.5 }
        },
        DE = {
            [1] = { 180, 0.6 },
            [2] = { 250, 0.6 }
        }
    }
    if wAndStps[lang] == nil then lang = "EN" end
    if wAndStps[lang][fontsize] == nil then fontsize = 2 end

    local barL = wAndStps[lang][fontsize][1];
    local stp = wAndStps[lang][fontsize][2];
    --endregion

    -- load config
    local config = self:loadConfig();

    local barWidth = lineHeight;
    if config and config.barWidth ~= nil then
        barWidth = config.barWidth;
    end
    if config and config.pos ~= nil then
        x = config.pos[1];
        y = config.pos[2];
    end
    local isVertical = false;
    if config and config.isVertical ~= nil then
        isVertical = config.isVertical;
    end

    local shownConfig = {};

    if config and config.shownConfig ~= nil then
        shownConfig = config.shownConfig
    end

    for _, i in ipairs(barConfigs) do
        if shownConfig[i.name] == nil then
            shownConfig[i.name] = i.shown;
        end
    end


    local shown_count = 0;

    for _, v in pairs(shownConfig) do
        if v then shown_count = shown_count + 1 end
    end

    local w = barL + 6;
    local h = (barWidth + 3) * shown_count + 3;

    if isVertical then
        w, h = h, w;
        h = h + barWidth - 3;
    end

    local o = ISPanel:new(x, y, w, h);
    setmetatable(o, self);
    self.__index = self;

    o.moveWithMouse = true;

    o.player = player;
    o.stp = stp;
    o.barLen = barL;

    o.barConfigs = barConfigs;
    o.config = {
        pos = { x, y },
        barWidth = barWidth,
        isVertical = isVertical,
        shownConfig = shownConfig
    }
    o:saveConfig(o.config);
    return o;
end

return ssBar
