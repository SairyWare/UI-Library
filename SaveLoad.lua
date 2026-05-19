local HttpService = game:GetService("HttpService")

local SaveLoad = {}

SaveLoad.Config = {
    Enabled  = true,
    FileName = "default",
    Folder   = "Alert3z",
    AutoSave = true,
    AutoLoad = true,
    Notify   = true,
}

local Options = {}

local function GetPath()
    local _Name = SaveLoad.Config.FileName ~= "" and SaveLoad.Config.FileName or "default"
    return SaveLoad.Config.Folder .. "/" .. _Name .. ".json"
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

-- skip flag พวกนี้ตอน save
local SkipFlags = {
    SaveFileName = true,
    SaveBtn      = true,
    LoadBtn      = true,
    DeleteBtn    = true,
}

-- ── Wrap window ──────────────────────────────────────
-- เรียกครั้งเดียว ได้ window ที่ AddXxx แล้ว auto-register ในตัว
function SaveLoad:Wrap(_Library, _Window)
    local _Wrapped = {}

    local _AutoMethods = {
        "AddToggle", "AddSlider", "AddList",
        "AddBox", "AddColor", "AddBind"
    }

    -- copy method ที่ไม่ต้อง wrap
    for _K, _V in next, _Window do
        _Wrapped[_K] = _V
    end

    -- override method ที่ต้อง register
    for _, _Method in next, _AutoMethods do
        _Wrapped[_Method] = function(_Self, _Opt)
            local _Option = _Window[_Method](_Window, _Opt)
            if _Option and _Option.flag then
                Options[_Option.flag] = _Option
            end
            return _Option
        end
    end

    -- AddFolder ต้อง wrap ด้วยเพราะ return subfolder
    _Wrapped.AddFolder = function(_Self, _Title)
        local _Folder = _Window:AddFolder(_Title)
        return SaveLoad:Wrap(_Library, _Folder)
    end

    -- AddButton และ AddLabel ไม่มี state ไม่ต้อง register
    _Wrapped.AddButton = function(_Self, _Opt) return _Window:AddButton(_Opt) end
    _Wrapped.AddLabel  = function(_Self, _Opt) return _Window:AddLabel(_Opt)  end

    return _Wrapped
end

function SaveLoad:SetFileName(_Name)
    _Name = tostring(_Name):gsub('[\\/:*?"<>|]', ""):gsub("^%s+", ""):gsub("%s+$", "")
    self.Config.FileName = _Name ~= "" and _Name or "default"
    if self.Config.Notify then
        print("[SaveLoad] FileName →", self.Config.FileName)
    end
end

function SaveLoad:Save(_Library)
    if not self.Config.Enabled then return end
    EnsureFolder()

    local _Data = {}
    for _Flag, _Value in next, _Library.flags do
        if not SkipFlags[_Flag] then
            _Data[_Flag] = EncodeValue(_Value)
        end
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

function SaveLoad:Load(_Library)
    if not self.Config.Enabled then return end
    if not isfile(GetPath()) then
        if self.Config.Notify then print("[SaveLoad] No file:", GetPath()) end
        return
    end

    local _Ok, _Data = pcall(function()
        return HttpService:JSONDecode(readfile(GetPath()))
    end)

    if not _Ok then warn("[SaveLoad] Load failed: corrupted") return end

    for _Flag, _Raw in next, _Data do
        local _Value = DecodeValue(_Raw)
        _Library.flags[_Flag] = _Value

        local _Option = Options[_Flag]
        if _Option then
            pcall(function()
                if _Option.SetState then _Option:SetState(_Value) end
                if _Option.SetValue then _Option:SetValue(_Value) end
                if _Option.SetColor then _Option:SetColor(_Value) end
                if _Option.SetKey   then _Option:SetKey(_Value)   end
            end)
        end
    end

    if self.Config.Notify then print("[SaveLoad] Loaded ←", GetPath()) end
end

function SaveLoad:Delete()
    if not isfile(GetPath()) then
        warn("[SaveLoad] No file:", GetPath())
        return
    end
    pcall(function() delfile(GetPath()) end)
    if self.Config.Notify then print("[SaveLoad] Deleted:", GetPath()) end
end

function SaveLoad:Hook(_Library)
    if not self.Config.AutoSave then return end
    for _, _Option in next, Options do
        local _OldCb = _Option.callback or function() end
        _Option.callback = function(...)
            _OldCb(...)
            self:Save(_Library)
        end
    end
    if self.Config.Notify then print("[SaveLoad] AutoSave hooked") end
end

return SaveLoad
