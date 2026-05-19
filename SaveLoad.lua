-- SaveLoad Module for Alert3z UI Library
-- Usage: local SaveLoad = loadstring(game:HttpGet("...", true))()

local HttpService = game:GetService("HttpService")

local SaveLoad = {}

-- ── Config ───────────────────────────────────────────
SaveLoad.Config = {
    Enabled  = true,           -- เปิด/ปิด ระบบ save ทั้งหมด
    FileName = "Alert3z",      -- ชื่อไฟล์ (ไม่ต้องใส่ .json)
    Folder   = "Alert3z",      -- ชื่อโฟลเดอร์ใน workspace
    AutoSave = true,           -- save อัตโนมัติทุกครั้งที่ค่าเปลี่ยน
    AutoLoad = true,           -- load อัตโนมัติตอน Init
    Notify   = true,           -- print แจ้งตอน save/load
}

-- ── Internal ─────────────────────────────────────────
local Options = {}  -- { flag = option_ref }

local function GetPath()
    return SaveLoad.Config.Folder .. "/" .. SaveLoad.Config.FileName .. ".json"
end

local function EnsureFolder()
    if not isfolder(SaveLoad.Config.Folder) then
        makefolder(SaveLoad.Config.Folder)
    end
end

local function EncodeValue(_Value)
    if typeof(_Value) == "Color3" then
        return {__type = "Color3", r = _Value.R, g = _Value.G, b = _Value.B}
    end
    return _Value
end

local function DecodeValue(_Value)
    if type(_Value) == "table" and _Value.__type == "Color3" then
        return Color3.new(_Value.r, _Value.g, _Value.b)
    end
    return _Value
end

-- ── Register option ──────────────────────────────────
-- เรียกตอนสร้าง option เพื่อให้ module รู้จัก
function SaveLoad:Register(_Flag, _Option)
    if not _Flag or not _Option then return end
    Options[_Flag] = _Option
end

-- ── Save ─────────────────────────────────────────────
function SaveLoad:Save(_Library)
    if not self.Config.Enabled then return end
    EnsureFolder()

    local _Data = {}
    for _Flag, _Value in next, _Library.flags do
        _Data[_Flag] = EncodeValue(_Value)
    end

    local _Ok, _Err = pcall(function()
        writefile(GetPath(), HttpService:JSONEncode(_Data))
    end)

    if _Ok then
        if self.Config.Notify then print("[SaveLoad] Saved →", GetPath()) end
    else
        warn("[SaveLoad] Save failed:", _Err)
    end
end

-- ── Load ─────────────────────────────────────────────
function SaveLoad:Load(_Library)
    if not self.Config.Enabled then return end
    if not isfile(GetPath()) then
        if self.Config.Notify then print("[SaveLoad] No save file found") end
        return
    end

    local _Ok, _Data = pcall(function()
        return HttpService:JSONDecode(readfile(GetPath()))
    end)

    if not _Ok then
        warn("[SaveLoad] Load failed: corrupted file")
        return
    end

    for _Flag, _Raw in next, _Data do
        local _Value = DecodeValue(_Raw)
        _Library.flags[_Flag] = _Value

        -- sync กลับไปที่ UI
        local _Option = Options[_Flag]
        if _Option then
            pcall(function()
                if _Option.SetState  then _Option:SetState(_Value)  end  -- toggle
                if _Option.SetValue  then _Option:SetValue(_Value)  end  -- slider, list, box
                if _Option.SetColor  then _Option:SetColor(_Value)  end  -- color
                if _Option.SetKey    then _Option:SetKey(_Value)    end  -- bind
            end)
        end
    end

    if self.Config.Notify then print("[SaveLoad] Loaded ←", GetPath()) end
end

-- ── Delete ───────────────────────────────────────────
function SaveLoad:Delete()
    if not isfile(GetPath()) then
        warn("[SaveLoad] No file to delete")
        return
    end
    pcall(function() delfile(GetPath()) end)
    if self.Config.Notify then print("[SaveLoad] Deleted:", GetPath()) end
end

-- ── Hook into library ────────────────────────────────
-- เรียกหลัง Library:Init() เพื่อ auto-hook callback ทุก option
function SaveLoad:Hook(_Library)
    if not self.Config.AutoSave then return end

    for _Flag, _Option in next, Options do
        local _OldCb = _Option.callback or function() end
        _Option.callback = function(...)
            _OldCb(...)
            self:Save(_Library)
        end
    end

    if self.Config.Notify then print("[SaveLoad] Hooked", _Library) end
end

return SaveLoad
