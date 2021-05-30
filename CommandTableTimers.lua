local ScrollingTable = LibStub("ScrollingTable");

local function trackMission(missions, name, realm, missionID, endtime, xp, rewards)
    local temp = {
        ["name"] = name,
        ["realm"] = realm,
        ["missionID"] = missionID,
        ["endtime"] = endtime,
        ["xp"] = xp,
        ["rewards"] = rewards
    }

    table.insert(missions, temp)
end

local function removeMissions(missions, name, realm)
    local n = table.getn(missions)
    for i = n, 1, -1 do
        if missions[i]["name"] == name and missions[i]["realm"] == realm then
            table.remove(missions, i)
        end
    end
end

local function removeMission(missions, name, realm, missionID)
    local n = table.getn(missions)
    for i = n, 1, -1 do
        if missions[i]["name"] == name and missions[i]["realm"] == realm and missions[i]["missionID"] == missionID then
            table.remove(missions, i)
        end
    end
end

local function insertItemData(missions, itemID)
    local itemInfo = GetItemInfo(itemID)
    for i, v in ipairs(mission) do
    end
end

local function gold2string(rawgold)
    local c = rawgold % 100
    rawgold = math.floor(rawgold / 100)
    local s = rawgold % 100
    rawgold = math.floor(rawgold / 100)
    local g = rawgold

    local ret = ""

    if g > 0 then
        ret = g .. "g"
    end
    if s > 0 then
        ret = ret .. s .. "s"
    end
    if c > 0 then
        ret = ret .. c .. "c"
    end

    return ret
end

local function durationString(timestamp)
    if timestamp <= 0 then
        return "Done"
    end

    local hours = math.floor(timestamp / 3600)
    local minutes = math.floor(timestamp % 3600 / 60)
    local seconds = timestamp % 60

    local ret = ""
    if hours > 0 then
        ret = hours .. "h " .. minutes .. "m " .. seconds .. "s"
    elseif minutes > 0 then
        ret = minutes .. "m " .. seconds .. "s"
    else
        ret = seconds .. "s"
    end

    return ret
end

local function eventHandler(self, event, ...)
    local playerName = UnitName("player")
    local playerRealm = GetRealmName()

    if event == "ADDON_LOADED" then
        local addonName = ...

        if addonName == "CommandTableTimers" then
            if MissionTimers == nil then
                MissionTimers = {}
            end

            removeMissions(MissionTimers, playerName, playerRealm)

            local myMissions = C_Garrison.GetInProgressMissions(Enum.GarrisonFollowerType.FollowerType_9_0)
            if myMissions ~= nil then
                for i, v in pairs(myMissions) do
                    trackMission(MissionTimers, playerName, playerRealm, v.missionID, v.missionEndTime, v.xp, v.rewards)
                end
            end
        end
    elseif event == "GARRISON_MISSION_STARTED" then
        local garrFollowerTypeID, missionID = ...
        if garrFollowerTypeID == Enum.GarrisonFollowerType.FollowerType_9_0 then
            local missionInfo = C_Garrison.GetBasicMissionInfo(missionID)

            trackMission(MissionTimers, playerName, playerRealm, missionID, time() + missionInfo.durationSeconds, missionInfo.xp, missionInfo.rewards)
        end
    elseif event == "GARRISON_MISSION_COMPLETE_RESPONSE" then
        local missionID = ...
        removeMission(MissionTimers, playerName, playerRealm, missionID)
    elseif event == "ITEM_DATA_LOAD_RESULT" then
        local number, success = ...
        if success then
            --insertItemData(MissionTimers, number)
        end
    end
end

local f = CreateFrame("Frame", "CTTFrame", UIParent, "UIPanelDialogTemplate")
f:SetWidth(450)
f:SetHeight(400)
f:SetFrameStrata("FULLSCREEN_DIALOG")
f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)

f:EnableMouse(true)
f:EnableMouseWheel(true)

f:SetMovable(true)
f:SetResizable(true)
f:SetMinResize(100, 100)
f:RegisterForDrag("LeftButton")
f:SetScript("OnDragStart", f.StartMoving)
f:SetScript("OnDragStop", f.StopMovingOrSizing)

f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("GARRISON_MISSION_STARTED")
f:RegisterEvent("GARRISON_MISSION_COMPLETE_RESPONSE")
f:RegisterEvent("ITEM_DATA_LOAD_RESULT")
f:SetScript("OnEvent", eventHandler)

--local closeButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
--closeButton:SetPoint("BOTTOM", 0, 10)
--closeButton:SetWidth(70)
--closeButton:SetHeight(25)
--closeButton:SetText("CLOSE")
--closeButton:SetScript("OnClick", function(self)
    --HideParentPanel(self)
--end)
--f.closeButton = closeButton

tinsert(UISpecialFrames, "CTTFrame")

--f:Show()

local cols = {
    {
        ["name"] = "Character",
        ["width"] = 150,
        ["align"] = "LEFT",
        ["color"] = {
            ["r"] = 1.0,
            ["g"] = 1.0,
            ["b"] = 1.0,
            ["a"] = 1.0
        },
        ["colorargs"] = nil,
        ["bgcolor"] = {
            ["r"] = 0.0,
            ["g"] = 0.0,
            ["b"] = 0.0,
            ["a"] = 1.0
        },
        ["defaultsort"] = "asc",
    },
    {
        ["name"] = "Rewards",
        ["width"] = 150,
        ["align"] = "LEFT",
        ["color"] = {
            ["r"] = 1.0,
            ["g"] = 1.0,
            ["b"] = 1.0,
            ["a"] = 1.0
        },
        ["colorargs"] = nil,
        ["bgcolor"] = {
            ["r"] = 0.0,
            ["g"] = 0.0,
            ["b"] = 0.0,
            ["a"] = 1.0
        },
        ["defaultsort"] = "asc",
    },
    {
        ["name"] = "Time Left",
        ["width"] = 110,
        ["align"] = "LEFT",
        ["color"] = {
            ["r"] = 1.0,
            ["g"] = 1.0,
            ["b"] = 1.0,
            ["a"] = 1.0
        },
        ["colorargs"] = nil,
        ["bgcolor"] = {
            ["r"] = 0.0,
            ["g"] = 0.0,
            ["b"] = 0.0,
            ["a"] = 1.0
        },
        ["sortnext"] = 1,
        ["defaultsort"] = "asc",
        ["DoCellUpdate"] = function(rowFrame, frame, data, cols, row, realRow, column, fShow, table, class)
            if fShow then
			    local celldata = data[realRow][3]
                frame.text:SetText(durationString(celldata))
            else
                frame.text:SetText("")
            end
        end
    }
}

local st = ScrollingTable:CreateST(cols, 23, nil, nil, f);
st.frame:SetPoint("TOPLEFT", f, "TOPLEFT", 8, -42)
st.frame:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -5, 8)
st:EnableSelection(true)

SLASH_CTT1 = "/ctt"
SlashCmdList["CTT"] = function(msg)
    local offset = -30

    if MissionTimers ~= nil then
        local data = {}
        local now = time()
        for i, v in ipairs(MissionTimers) do
            local d = {
                v["name"] .. "-" .. v["realm"],
                "",
                (v["endtime"] > now) and (v["endtime"] - now) or 0
            }

            if v["rewards"][1]["title"] == "Bonus Follower XP" then
                d[2] = v["rewards"][1]["name"]
            elseif v["rewards"][1]["title"] == "Money Reward" then
                d[2] = gold2string(v["rewards"][1]["quantity"])
            elseif v["rewards"][1]["title"] == "Currency Reward" then
                local currency_info = C_CurrencyInfo.GetCurrencyInfo(v["rewards"][1]["currencyID"])
                d[2] = v["rewards"][1]["quantity"] .. " " .. currency_info.name
            elseif v["rewards"][1]["itemID"] ~= nil then
                --local rewardInfo = C_Garrison.GetBasicMissionInfo(v["missionID"])
                d[2] = v["rewards"][1]["itemLink"] .. "x" .. v["rewards"][1]["quantity"]
            end

            tinsert(data, d)
        end

        st:SetData(data, true)
        st:SortData()
    end

    CTTFrame:Show()
end