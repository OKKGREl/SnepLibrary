print("Snep Library - Okkg ... LOADED!")

--[[
    Snep Library - Okkg
    Copyright (c) 2025 okkg
    MIT License: https://opensource.org/licenses/MIT
    AI training prohibited without written permission.
--]]

local json = require("json")  -- json.lua by rxi (MIT)
local UEHelpers = require("UEHelpers")

-- Save file related functions

function GetSaveFileLocation()
    local info = debug.getinfo(1, "S")
    local script_path = info.source:gsub("^@", "")
    local script_dir = script_path:match("(.*[\\/])")
    script_dir = script_dir .. "SaveFiles\\"
    return script_dir
end

---@param saveGame UVeinSaveGame -- Can Be Nil
function CheckSave(saveGame)
    if saveGame == nil then
        ---@class UVeinSaveGame
        local VeinSaveGame = FindFirstOf("VeinSaveGame")

        if VeinSaveGame:IsValid() then
            local name = VeinSaveGame:GetSaveFilename():ToString()

            if tostring(name) == nil or tostring(name) == "" then print("No save") return end

            if SaveExists(tostring(name)) then
                ReadSaveData(tostring(name))
                print("Reading data.")
            else
                SaveData(tostring(name))
                print("Saving data.")
            end
        end
    else
        ---@type UVeinSaveGame
        local save = saveGame

        local name = save.SaveName:ToString()

        if SaveExists(tostring(name)) then
            ReadSaveData(tostring(name))
            print("Reading data.")
        else
            SaveData(tostring(name))
            print("Saving data.")
        end
    end
end

---@param name string
function SaveExists(name)
    local filename = name .. ".txt"
    local file = io.open(GetSaveFileLocation() .. filename,'r')
    if file~=nil then io.close(file) return true else return false end
end

---@param name string
function SaveData(name, savefiledata)
    local filename = name .. ".txt"
    local file = assert(io.open(GetSaveFileLocation() .. filename,'w'))
    file:write(json.encode(savefiledata))
    file:close()
end

---@param name string
function ReadSaveData(name)
    local filename = name .. ".txt"
    local file, err = io.open(GetSaveFileLocation() .. filename,'r')
    if file then
        local savefiledata = json.decode(file:read("*a"))
        file:close()
        return savefiledata
    else
        print("error:", err)
    end
end

-- Time functions

---@param text string
function PMtoMilitaryTime(text)
    local hour, min, period = text:match("(%d+):(%d+)%s*(%a+)")

    hour = tonumber(hour)
    min = tonumber(min)

    if period == "AM" and hour == 12 then
        hour = 0
    elseif period == "PM" and hour ~= 12 then
        hour = hour + 12
    end

    return hour .. ":" .. min
end

---@param text string
function PMToMinutes(text)
    local hour, min, period = text:match("(%d+):(%d+)%s*(%a+)")

    hour = tonumber(hour)
    min = tonumber(min)

    if period == "AM" and hour == 12 then
        hour = 0
    elseif period == "PM" and hour ~= 12 then
        hour = hour + 12
    end

    return tonumber(hour) * 60 + tonumber(min)
end

function GetTime()
    -- ---@class UTimeComponent
    --local timecomp = FindFirstOf("TimeComponent")

    ---@class UClockUserWidget
    local clock = FindFirstOf("ClockUserWidget")

    if clock:IsValid() then
        local time = PMToMinutes(clock:GetTimeText():ToString())
        return time
    else
        print("Couldnt get time!")
    end
end


function IsInMainMenu()
    local Player = UEHelpers.GetPlayerController()

    if not Player:IsValid() then
        return false
    end

    local pawn = Player:GetFName():ToString()
    if string.find(pawn, "BP_MainMenuPlayerController_C") then
        return true
    end

    return false
end
