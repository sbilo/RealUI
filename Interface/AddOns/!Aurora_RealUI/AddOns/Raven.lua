local _, mods = ...

mods["PLAYER_LOGIN"]["Raven"] = function(self, F, C)
    --print("Raven", F, C)
    local SpiralBorder = RealUI:GetModule("SpiralBorder")

    local iconInset = 3
    local barFrames = {
        PlayerDebuffs = true,
        TargetDebuffs = true,
    }
    local iconFrames = {
        PlayerBuffs = true,
        TargetBuffs = true,
        ClassBuffs = true,
    }
    local barBackgroundPositions = {
        PlayerDebuffs = {tx = -2, ty = 1, bx = -3, by = -1},
        TargetDebuffs = {tx = 2, ty = 1, bx = 1, by = -1},
    }

    local function AttachBarBackground(bg, bar)
        -- Create or show Background
        if not bar.frame.bd then 
            bar.frame.bd = F.CreateBDFrame(bar.frame, 0.5)
            bar.frame.bd.lastGroup = ""

            -- Truncate bar names
            hooksecurefunc(bar.labelText, "SetText", function(self)
                if self.inHook then return end
                self.inHook = true
                local label = self:GetText()
                if strlen(label) > 22 then
                    self:SetText(strsub(label, 1, 21).."..")
                end
                self.inHook = false
            end)
        else
            bar.frame.bd:Show()
        end
        
        -- Position for specific bar groups
        if (bar.frame.bd.lastGroup ~= bg.name) then
            bar.frame.bd:ClearAllPoints()
            bar.frame.bd:SetPoint("TOPLEFT", bar.frame, barBackgroundPositions[bg.name].tx, barBackgroundPositions[bg.name].ty)
            bar.frame.bd:SetPoint("BOTTOMRIGHT", bar.frame, barBackgroundPositions[bg.name].bx, barBackgroundPositions[bg.name].by)
        end
        bar.frame.bd.lastGroup = bg.name
    end

    -- Hook Raven frame creation
    local Nest_CreateBar_ = Raven.Nest_CreateBar
    Raven.Nest_CreateBar = function(bg, name)
        local bar = Nest_CreateBar_(bg, name)
        bar.frame:Show()
        bar.container:Show()

        -- Bars
        if barFrames[bg.name] then
            if bar.frame.ssID then SpiralBorder:RemoveSpiral(bar, bar.frame.ssID, true) end
            AttachBarBackground(bg, bar)
        -- Icons
        elseif iconFrames[bg.name] then
            if bar.frame.bd then bar.frame.bd:Hide() end
            SpiralBorder:AttachSpiral(bar, iconInset, true)
        -- Untouched Bar Groups
        else
            if bar.frame.ssID then SpiralBorder:RemoveSpiral(bar, bar.frame.ssID, true) end
            if bar.frame.bd then bar.frame.bd:Hide() end
        end
        
        return bar
    end
    
    local Nest_DeleteBar_ = Raven.Nest_DeleteBar
    Raven.Nest_DeleteBar = function(bg, bar)
        -- Would be nice to keep them attached, but Raven recycles frames for Icons AND Bars and intermixes them
        if bar.frame.ssID then SpiralBorder:RemoveSpiral(bar, bar.frame.ssID, true) end
        bar.endTime = nil

        bar.frame:Hide()
        bar.container:Hide()
        Nest_DeleteBar_(bg, bar)
    end

    -- Skin Fonts
    local RavenDefaults = Raven.db.global.Defaults
    local pixelFont = RealUI.media.font.pixel.large[1]
    RavenDefaults.timeFont = pixelFont
    RavenDefaults.labelFont = pixelFont
    RavenDefaults.iconFont = pixelFont
    Raven:UpdateAllBarGroups()
end
