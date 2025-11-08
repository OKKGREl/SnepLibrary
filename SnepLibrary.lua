print("Snep Library - Okkg ... LOADED!")


local SnepLibrary = {}

local Version = 3

local OccupationSlots = 0
local HairSlots = 0


--[[
    Snep Library - Okkg
    Copyright (c) 2025 okkg
    MIT License: https://opensource.org/licenses/MIT
    AI training prohibited without written permission.
--]]

local json = require("json")  -- json.lua by rxi (MIT)
local UEHelpers = require("UEHelpers")


local console = UEHelpers.GetKismetSystemLibrary(false)


--Custom game settings for zombies
---@return UGameplaySetting
function SnepLibrary.AddCustomGameZombieOption()

    ---@class UMainMenuWidget
    local MainMenu = FindFirstOf("WBP_MainMenu_C")

    ---@class UGameplaySetting
    local item = nil

    if MainMenu:IsValid() then

        ---@class UGameplaySetting
        item = MainMenu.ZombieOptions.Slots[4]
        if item then
            print(item)
            item.Label = FText("Ypeeee")
            MainMenu.ZombieOptions.Slots[20] = item
            print("Added Item!")
            return item
        else
            print("Item is nil!")
            return item
        end
    else
        print("Couldnt get CharacterCreationBP!")
        return item
    end
end

-- Custom Occupations
---@return UOccupationData
function SnepLibrary.AddCustomOccupation()

    ---@class UCharacterCreationWidget
    local CharacterCreationBP = FindFirstOf("WBP_CharacterCreation_C")

    ---@class UOccupationData
    local item = nil

    if CharacterCreationBP:IsValid() then
        ---@class UOccupationData   
        local tempitem = CharacterCreationBP.OccupationList.Slots[4]

        ---@class UOccupationData
        item = StaticConstructObject(StaticFindObject("/Script/Vein.OccupationData.Class"), CharacterCreationBP)

        item.Occupation = tempitem.Occupation

        if item then
            print(item)
            OccupationSlots = OccupationSlots + 1
            -- starts at 29
            CharacterCreationBP.OccupationList.ListItems[29 + OccupationSlots] = item
            print("Added Item!")
            return item
        else
            print("Item is nil!")
            return item
        end
    else
        print("Couldnt get CharacterCreationBP!")
        return item
    end
end

-- Custom Hair
---@return UHairData
function SnepLibrary.AddCustomHair()
    ---@class UCharacterCreationWidget
    local CharacterCreationBP = FindFirstOf("WBP_CharacterCreation_C")

    ---@class UHairData
    local hair = nil

    if CharacterCreationBP:IsValid() then

        ---@class UHairData
        hair = CharacterCreationBP.Hairs.Slots[1]

        if hair then
            print(hair)

            HairSlots = HairSlots + 1
            CharacterCreationBP.Hairs.Slots[21 + HairSlots] = item
            print("Added Item!")

            return hair
        else
            return hair
        end
    else
        print("Couldnt get CharacterCreationBP!")
        return hair
    end
end



-- Save file related functions

-- Create a SaveFiles folder in your mods path.
---@param info debuginfo
function SnepLibrary.GetSaveFileLocation(info)
    local script_path = info.source:gsub("^@", "")
    local script_dir = script_path:match("(.*[\\/])")
    script_dir = script_dir .. "SaveFiles\\"
    return script_dir
end

---@param saveGame UVeinSaveGame -- Can Be Nil
---@param savefiledata table
---@param info debuginfo
function SnepLibrary.CheckForSave(saveGame, savefiledata, info)
    if saveGame == nil then
        ---@class UVeinSaveGame
        local VeinSaveGame = FindFirstOf("VeinSaveGame")

        if VeinSaveGame:IsValid() then
            local name = VeinSaveGame:GetSaveFilename():ToString()

            if tostring(name) == nil or tostring(name) == "" then print("No save") return end

            if SnepLibrary.DoesSaveExist(tostring(name),info) then
                SnepLibrary.ReadSaveData(tostring(name),info)
                print("Reading data.")
            else
                SnepLibrary.SaveData(tostring(name), savefiledata,info)
                print("Saving data.")
            end
        end
    else
        ---@type UVeinSaveGame
        local save = saveGame

        local name = save.SaveName:ToString()

        if SnepLibrary.DoesSaveExist(tostring(name),info) then
            SnepLibrary.ReadSaveData(tostring(name),info)
            print("Reading data.")
        else
            SnepLibrary.SaveData(tostring(name), savefiledata,info)
            print("Saving data.")
        end
    end
end

---@param name string
---@param info debuginfo
function SnepLibrary.DoesSaveExist(name, info)
    local filename = name .. ".txt"
    local file = io.open(SnepLibrary.GetSaveFileLocation(info) .. filename,'r')
    if file~=nil then io.close(file) return true else return false end
end

---@param name string
---@param savefiledata table
---@param info debuginfo
function SnepLibrary.SaveData(name, savefiledata, info)
    local filename = name .. ".txt"
    local file = assert(io.open(SnepLibrary.GetSaveFileLocation(info) .. filename,'w'))
    file:write(json.encode(savefiledata))
    file:close()
end

---@param name string
---@param info debuginfo
function SnepLibrary.ReadSaveData(name, info)
    local filename = name .. ".txt"
    local file, err = io.open(SnepLibrary.GetSaveFileLocation(info) .. filename,'r')
    if file then
        local savefiledata = json.decode(file:read("*a"))
        file:close()
        return savefiledata
    else
        print("Error! ", err)
    end
end


-- Time functions

---@param text string
function SnepLibrary.PMtoMilitaryTime(text)
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
function SnepLibrary.PMToMinutes(text)
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

function SnepLibrary.GetTime()
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

-- Sandbox settings (oh god)

---@param value float
function SnepLibrary.SetZombieSpawnMultiplier(value)
    local val = console:ExecuteConsoleCommand(UEHelpers.GetWorld(), "vein.AISpawner.SpawnCapMultiplierZombie ".. value)
end

function SnepLibrary.GetZombieSpawnMultiplier()
    local val = console:GetConsoleVariableFloatValue("vein.AISpawner.SpawnCapMultiplierZombie")
    return val
end

---@param value float
function SnepLibrary.SetZombieSightMultiplier(value)
    local val = console:ExecuteConsoleCommand(UEHelpers.GetWorld(), "vein.Zombies.SightMultiplier ".. value)
end

function SnepLibrary.GetZombieSightMultiplier()
    local val = console:GetConsoleVariableFloatValue("vein.Zombies.SightMultiplier")
    return val
end

---@param value float
function SnepLibrary.SetZombieHearingMultiplier(value)
    local val = console:ExecuteConsoleCommand(UEHelpers.GetWorld(), "vein.Zombies.HearingMultiplier ".. value)
end

function SnepLibrary.GetZombieHearingMultiplier()
    local val = console:GetConsoleVariableFloatValue("vein.Zombies.HearingMultiplier")
    return val
end

---@param value float
function SnepLibrary.SetZombieSpeedMultiplier(value)
    local val = console:ExecuteConsoleCommand(UEHelpers.GetWorld(), "vein.Zombies.SpeedMultiplier ".. value)
end

function SnepLibrary.GetZombieSpeedMultiplier()
    local val = console:GetConsoleVariableFloatValue("vein.Zombies.SpeedMultiplier")
    return val
end

---@param value float
function SnepLibrary.SetZombieDamageMultiplier(value)
    local val = console:ExecuteConsoleCommand(UEHelpers.GetWorld(), "vein.Zombies.DamageMultiplier ".. value)
end

function SnepLibrary.GetZombieDamageMultiplier()
    local val = console:GetConsoleVariableFloatValue("vein.Zombies.DamageMultiplier")
    return val
end

---@param value float
function SnepLibrary.SetXPMultiplier(value)
    local val = console:ExecuteConsoleCommand(UEHelpers.GetWorld(), "vein.Stats.XPMultiplier ".. value)
end

function SnepLibrary.GetXPMultiplier()
    local val = console:GetConsoleVariableFloatValue("vein.Stats.XPMultiplier")
    return val
end


-- Horde Functions

---@param character AVeinPlayerCharacter
---@param type EHordeType
function SnepLibrary.TriggerHorde(character, type)

    if not character:IsValid() then return print("Nil player character.") end

    ---@class UAISpawnerSubsystem
    local AISpawnerSubsystem = FindFirstOf("AISpawnerSubsystem")

    if not AISpawnerSubsystem:IsValid() then
        print("Cant find AISpawnerSubsystem.")
        return
    end

    AISpawnerSubsystem:TriggerHorde(character, type)
end



-- Misc Functions

---@param text string
function SnepLibrary.SendServerMessage(text)
    ---@class AVeinGameStateBase
    local VeinGameStateBase = FindFirstOf("VeinGameStateBase")

    if not VeinGameStateBase:IsValid() then
        print("Cant find VeinGameStateBase.")
        return
    end

    VeinGameStateBase:BroadcastServerMessage(text)
end



function SnepLibrary.IsInMainMenu()
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

return SnepLibrary