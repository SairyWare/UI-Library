--[[
    SairyLib UI Library — Reconstructed Engine
    Extracted & Engineered for SairyWare
    Author: Alert3z / SairyWare
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local function SafeCloneRef(InstanceObj)
    if cloneref then
        return cloneref(InstanceObj)
    end
    return InstanceObj
end

local function GetParentGui()
    if gethui then
        return gethui()
    end
    local Success, Result = pcall(function()
        return SafeCloneRef(CoreGui)
    end)
    if Success and Result then
        return Result
    end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local function ParseColor(Value, Fallback)
    if typeof(Value) == "Color3" then
        return Value
    elseif type(Value) == "string" then
        local CleanHex = Value:gsub("^#", "")
        if #CleanHex == 6 or #CleanHex == 3 then
            local Ok, Parsed = pcall(Color3.fromHex, "#" .. CleanHex)
            if Ok and typeof(Parsed) == "Color3" then
                return Parsed
            end
        end
    end
    return Fallback
end

local DefaultPalette = {
    WindowBg = Color3.fromRGB(12, 16, 23),
    SidebarBg = Color3.fromRGB(15, 20, 28),
    CardBg = Color3.fromRGB(21, 28, 39),
    InnerCardBg = Color3.fromRGB(16, 21, 30),
    StrokeBorder = Color3.fromRGB(32, 43, 59),
    StrokeHover = Color3.fromRGB(54, 72, 98),
    Accent = Color3.fromRGB(115, 167, 202),
    AccentDarkText = Color3.fromRGB(10, 19, 27),
    TextPrimary = Color3.fromRGB(231, 237, 246),
    TextSecondary = Color3.fromRGB(134, 150, 170),
    MutedDark = Color3.fromRGB(31, 41, 56),
    IslandBg = Color3.fromRGB(6, 8, 12),
    IslandStroke = Color3.fromRGB(37, 43, 54),
    ActiveGreen = Color3.fromRGB(83, 215, 144),
    HeaderGradientTop = Color3.fromRGB(20, 24, 31),
    HeaderGradientBottom = Color3.fromRGB(67, 96, 117),
    NotifySuccess = Color3.fromRGB(150, 220, 170),
    NotifyWarning = Color3.fromRGB(240, 176, 108),
    NotifyError = Color3.fromRGB(240, 120, 120),
    NotifyInfo = Color3.fromRGB(115, 167, 202)
}

local function NormalizeTheme(RawTheme)
    RawTheme = RawTheme or {}
    local WindowBg = ParseColor(RawTheme.WindowBg or RawTheme.Background, DefaultPalette.WindowBg)
    local InnerCardBg = ParseColor(RawTheme.InnerCardBg or RawTheme.Surface, WindowBg:Lerp(Color3.new(0, 0, 0), 0.12))
    local CardBg = ParseColor(RawTheme.CardBg or RawTheme.Surface2 or RawTheme.Button, WindowBg:Lerp(Color3.new(1, 1, 1), 0.06))
    local StrokeBorder = ParseColor(RawTheme.StrokeBorder or RawTheme.Stroke or RawTheme.Outline, WindowBg:Lerp(Color3.new(1, 1, 1), 0.14))
    local Accent = ParseColor(RawTheme.Accent or RawTheme.Icon, DefaultPalette.Accent)
    local TextPrimary = ParseColor(RawTheme.TextPrimary or RawTheme.Text, DefaultPalette.TextPrimary)
    local TextSecondary = ParseColor(RawTheme.TextSecondary or RawTheme.Muted or RawTheme.Placeholder, TextPrimary:Lerp(WindowBg, 0.45))
    local MutedDark = ParseColor(RawTheme.MutedDark or RawTheme.Surface3, CardBg:Lerp(StrokeBorder, 0.5))
    local IsLightTheme = (WindowBg.R + WindowBg.G + WindowBg.B) > 1.8

    local HeaderTop = ParseColor(RawTheme.HeaderGradientTop, WindowBg:Lerp(Color3.new(0, 0, 0), IsLightTheme and 0.04 or 0.12))
    local HeaderBottom = ParseColor(RawTheme.HeaderGradientBottom, Accent:Lerp(WindowBg, 0.48))

    return {
        WindowBg = WindowBg,
        SidebarBg = ParseColor(RawTheme.SidebarBg, WindowBg:Lerp(InnerCardBg, 0.5)),
        CardBg = CardBg,
        InnerCardBg = InnerCardBg,
        StrokeBorder = StrokeBorder,
        StrokeHover = ParseColor(RawTheme.StrokeHover, StrokeBorder:Lerp(Accent, 0.35)),
        Accent = Accent,
        AccentDarkText = ParseColor(RawTheme.AccentDarkText or RawTheme.AccentDark, ((Accent.R + Accent.G + Accent.B) > 1.9) and Color3.fromRGB(16, 20, 28) or Color3.fromRGB(255, 255, 255)),
        TextPrimary = TextPrimary,
        TextSecondary = TextSecondary,
        MutedDark = MutedDark,
        IslandBg = ParseColor(RawTheme.IslandBg, IsLightTheme and CardBg or WindowBg:Lerp(Color3.new(0, 0, 0), 0.55)),
        IslandStroke = ParseColor(RawTheme.IslandStroke, StrokeBorder),
        ActiveGreen = ParseColor(RawTheme.ActiveGreen or RawTheme.Success, DefaultPalette.ActiveGreen),
        HeaderGradientTop = HeaderTop,
        HeaderGradientBottom = HeaderBottom,
        NotifySuccess = ParseColor(RawTheme.NotifySuccess or RawTheme.Success, DefaultPalette.ActiveGreen),
        NotifyWarning = ParseColor(RawTheme.NotifyWarning or RawTheme.Warning, DefaultPalette.NotifyWarning),
        NotifyError = ParseColor(RawTheme.NotifyError or RawTheme.Error, DefaultPalette.NotifyError),
        NotifyInfo = ParseColor(RawTheme.NotifyInfo or RawTheme.Info, Accent),
        Rainbow = RawTheme.Rainbow == true
    }
end

-- Built-in Themes
local BuiltInThemes = {
    ["Sairy Blue"] = NormalizeTheme({
        Background = "#0C1017", SidebarBg = "#0F141C", Surface = "#10151E", Surface2 = "#151C27", Surface3 = "#1F2938",
        Stroke = "#202B3B", StrokeHover = "#364862", Accent = "#73A7CA", AccentDark = "#0A131B", Text = "#E7EDF6",
        Muted = "#8696AA", IslandBg = "#06080C", IslandStroke = "#252B36", ActiveGreen = "#53D790",
        HeaderGradientTop = "#14181F", HeaderGradientBottom = "#436075", Success = "#96DCAA", Warning = "#F0B06C", Error = "#F07878"
    }),
    ["Revolution"] = NormalizeTheme({
        Background = "#1A1A1A", SidebarBg = "#140D0D", Surface = "#240808", Surface2 = "#221010", Surface3 = "#2B0000",
        Stroke = "#3B0606", StrokeHover = "#8B0000", Accent = "#FF4500", AccentDark = "#FFFFFF", Text = "#FFFFFF",
        Muted = "#A88C8C", IslandBg = "#120606", IslandStroke = "#4A0A0A", ActiveGreen = "#53D790",
        HeaderGradientTop = "#1A0A0A", HeaderGradientBottom = "#8B0000", Success = "#53D790", Warning = "#FFB020", Error = "#FF3B3B"
    }),
    ["Sairy Neox"] = NormalizeTheme({
        Background = "#1A112F", SidebarBg = "#140D26", Surface = "#1D1336", Surface2 = "#23183E", Surface3 = "#2D1F50",
        Stroke = "#322456", StrokeHover = "#6046A3", Accent = "#8C74D5", AccentDark = "#FFFFFF", Text = "#FFFFFF",
        Muted = "#A89EC9", IslandBg = "#110B21", IslandStroke = "#3D2B6B", ActiveGreen = "#53D790",
        HeaderGradientTop = "#140D26", HeaderGradientBottom = "#5A4499", Success = "#53D790", Warning = "#F0B06C", Error = "#FF5C77"
    }),
    ["Sairy Blood"] = NormalizeTheme({
        Background = "#0F0A0B", SidebarBg = "#130B0C", Surface = "#180B0D", Surface2 = "#1D1012", Surface3 = "#2B0C10",
        Stroke = "#380D11", StrokeHover = "#8B0000", Accent = "#E03131", AccentDark = "#FFFFFF", Text = "#F7EAEA",
        Muted = "#A68386", IslandBg = "#090506", IslandStroke = "#4A1014", ActiveGreen = "#53D790",
        HeaderGradientTop = "#170B0D", HeaderGradientBottom = "#7A0D14", Success = "#53D790", Warning = "#F0B06C", Error = "#FF4D4D"
    }),
    ["Default"] = NormalizeTheme({
        Background = "#141014", Surface = "#181318", Surface2 = "#1C161C", Surface3 = "#2A242B",
        Stroke = "#282029", StrokeHover = "#58465A", Accent = "#EBC7F6", AccentDark = "#18121A", Text = "#E9E5EA", Muted = "#8A7F8B"
    }),
    ["Midnight"] = NormalizeTheme({
        Background = "#0E1016", Surface = "#12151C", Surface2 = "#161922", Surface3 = "#242936",
        Stroke = "#202430", StrokeHover = "#465068", Accent = "#96B4FF", AccentDark = "#0C101C", Text = "#E2E6F0", Muted = "#7A8399"
    }),
    ["Midnight Blue"] = NormalizeTheme({
        Background = "#12121A", Surface = "#1A1C26", Surface2 = "#242A38", Surface3 = "#3A465B",
        Stroke = "#364254", StrokeHover = "#536782", Accent = "#64B4DC", AccentDark = "#0B1D2A", Text = "#E8EEF7", Muted = "#A0AFC4"
    }),
    ["Amethyst Blue"] = NormalizeTheme({
        Background = "#071A2E", Surface = "#0B233B", Surface2 = "#102E4B", Surface3 = "#254B6C",
        Stroke = "#285377", StrokeHover = "#40739B", Accent = "#5CABE8", AccentDark = "#061828", Text = "#D7E9FA", Muted = "#9BB8D0"
    }),
    ["Amethyst"] = NormalizeTheme({
        Background = "#19151F", Surface = "#231D2C", Surface2 = "#30283B", Surface3 = "#49405A",
        Stroke = "#5F5270", StrokeHover = "#806C97", Accent = "#B396E8", AccentDark = "#1B102B", Text = "#F1EAF9", Muted = "#BBADCC"
    }),
    ["Amethyst Dark"] = NormalizeTheme({
        Background = "#160D23", Surface = "#20132F", Surface2 = "#2B1B3F", Surface3 = "#4B3563",
        Stroke = "#513963", StrokeHover = "#77558E", Accent = "#B779F4", AccentDark = "#180B28", Text = "#F0E4FA", Muted = "#B7A0CB"
    }),
    ["Crimson Dark"] = NormalizeTheme({
        Background = "#1B1015", Surface = "#27161C", Surface2 = "#351E26", Surface3 = "#59353F",
        Stroke = "#68424B", StrokeHover = "#92606B", Accent = "#FF6B73", AccentDark = "#290E14", Text = "#F9E6EA", Muted = "#C5A3AC"
    }),
    ["Neon Crimson"] = NormalizeTheme({
        Background = "#130C14", Surface = "#1F111E", Surface2 = "#2C1827", Surface3 = "#4B2C42",
        Stroke = "#63374C", StrokeHover = "#8C4D67", Accent = "#FF5A8A", AccentDark = "#240C18", Text = "#FFE8F1", Muted = "#C9A1B5"
    }),
    ["Neon Orange"] = NormalizeTheme({
        Background = "#18100B", Surface = "#241910", Surface2 = "#322316", Surface3 = "#513B27",
        Stroke = "#694B30", StrokeHover = "#927048", Accent = "#FF9A52", AccentDark = "#2B1608", Text = "#FFEEE0", Muted = "#CAB299"
    }),
    ["Ember"] = NormalizeTheme({
        Background = "#14100D", Surface = "#191410", Surface2 = "#1E1813", Surface3 = "#2E251E",
        Stroke = "#2A221B", StrokeHover = "#604C3A", Accent = "#FFBE8C", AccentDark = "#1C120A", Text = "#F0E8E2", Muted = "#928171"
    }),
    ["Aqua"] = NormalizeTheme({
        Background = "#101D21", Surface = "#17292E", Surface2 = "#20363C", Surface3 = "#35535A",
        Stroke = "#3E6066", StrokeHover = "#5B8389", Accent = "#6ED6CF", AccentDark = "#092A2B", Text = "#E6F5F4", Muted = "#A5C6C4"
    }),
    ["Moss"] = NormalizeTheme({
        Background = "#0F120F", Surface = "#131713", Surface2 = "#171C17", Surface3 = "#252C25",
        Stroke = "#212821", StrokeHover = "#485848", Accent = "#B0DEAA", AccentDark = "#0E160E", Text = "#E4EAE3", Muted = "#798877"
    }),
    ["Sakura"] = NormalizeTheme({
        Background = "#21171E", Surface = "#2B1D27", Surface2 = "#372632", Surface3 = "#594350",
        Stroke = "#775865", StrokeHover = "#9B7888", Accent = "#FCD1D7", AccentDark = "#301921", Text = "#FFF0F4", Muted = "#C6A4B4"
    }),
    ["Rose"] = NormalizeTheme({
        Background = "#150E11", Surface = "#1A1215", Surface2 = "#1F1519", Surface3 = "#302228",
        Stroke = "#2C1E24", StrokeHover = "#644250", Accent = "#FFAAC3", AccentDark = "#1E0C12", Text = "#F0E4E8", Muted = "#957C85"
    }),
    ["Mono"] = NormalizeTheme({
        Background = "#101011", Surface = "#141415", Surface2 = "#18181A", Surface3 = "#28282B",
        Stroke = "#242427", StrokeHover = "#505056", Accent = "#E6E6EB", AccentDark = "#121214", Text = "#E8E8EC", Muted = "#828288"
    }),
    ["Dark"] = NormalizeTheme({
        Background = "#171A20", Surface = "#1E232C", Surface2 = "#272E39", Surface3 = "#3B4655",
        Stroke = "#434E60", StrokeHover = "#61738C", Accent = "#60CDFF", AccentDark = "#081E2B", Text = "#F1F5FA", Muted = "#AEBACB"
    }),
    ["Darker"] = NormalizeTheme({
        Background = "#0E1117", Surface = "#141922", Surface2 = "#1B2230", Surface3 = "#303B4D",
        Stroke = "#39475B", StrokeHover = "#586C89", Accent = "#78B4DD", AccentDark = "#0A1928", Text = "#E6EDF5", Muted = "#A2AEC0"
    }),
    ["Dark Typewriter"] = NormalizeTheme({
        Background = "#211E1B", Surface = "#282420", Surface2 = "#312C26", Surface3 = "#454036",
        Stroke = "#635748", StrokeHover = "#86745C", Accent = "#8CBD91", AccentDark = "#122118", Text = "#EDE4D7", Muted = "#B6A895"
    }),
    ["VSC Dark High Contrast"] = NormalizeTheme({
        Background = "#000000", Surface = "#080B10", Surface2 = "#111720", Surface3 = "#303B4B",
        Stroke = "#FFFFFF", StrokeHover = "#C9D6E6", Accent = "#569CD6", AccentDark = "#061323", Text = "#F3F7FC", Muted = "#B2BDCB"
    }),
    ["Light"] = NormalizeTheme({
        Background = "#EEF1F6", Surface = "#F8FAFC", Surface2 = "#FFFFFF", Surface3 = "#DCE3EC",
        Stroke = "#BAC5D4", StrokeHover = "#8D9BB0", Accent = "#0067C0", AccentDark = "#FEFEFF", Text = "#172033", Muted = "#55647A"
    }),
    ["Rainbow"] = NormalizeTheme({
        Background = "#0C1017", SidebarBg = "#0F141C", Surface = "#10151E", Surface2 = "#151C27", Surface3 = "#1F2938",
        Stroke = "#202B3B", StrokeHover = "#465068", Accent = "#61BEF2", AccentDark = "#182836", Text = "#E7EDF6", Muted = "#8696AA",
        Rainbow = true
    })
}

local SairyColors = {}
for Key, Value in pairs(BuiltInThemes["Sairy Blue"]) do
    SairyColors[Key] = Value
end

local SairyAssets = {
    BrandLogo = "rbxassetid://124664081509852",
    SearchIcon = "rbxassetid://121018724060431",
    WindowShadow = "rbxassetid://6014261993",
    ResizeCorner = "rbxassetid://120997033468887",
    DropdownChevron = "rbxassetid://134243273101015",
    Checkmark = "rbxassetid://93898873302694",
    ToggleGlow = "rbxassetid://8992230677",
    ActionArrow = "rbxassetid://92473583511724",
    DefaultTabIcon = "rbxassetid://10723407389"
}

local SairyLib = {
    ActiveWindows = {},
    Themes = BuiltInThemes,
    ThemeName = "Sairy Blue",
    ThemeChangeListeners = {},
    TweenTime = 0.22
}

local function CopyPaletteIntoActive(PaletteTable)
    for Key, Value in pairs(PaletteTable) do
        SairyColors[Key] = Value
    end
end

local function NotifyThemeListeners(Instant)
    for _, Listener in ipairs(SairyLib.ThemeChangeListeners) do
        task.spawn(Listener, Instant)
    end
end

function SairyLib:AddTheme(Name, ThemeTable)
    if type(Name) ~= "string" or Name == "" then
        return nil
    end
    local Normalized = NormalizeTheme(ThemeTable)
    SairyLib.Themes[Name] = Normalized
    return Normalized
end

function SairyLib:GetThemes()
    local Names = {}
    for Name in pairs(SairyLib.Themes) do
        table.insert(Names, Name)
    end
    table.sort(Names)
    return Names
end

function SairyLib:SetTheme(NameOrTable, Instant)
    local TargetTheme = nil
    local ResolvedName = SairyLib.ThemeName

    if type(NameOrTable) == "string" then
        TargetTheme = SairyLib.Themes[NameOrTable]
        if not TargetTheme then
            for ExistingName, Palette in pairs(SairyLib.Themes) do
                if ExistingName:lower() == NameOrTable:lower() then
                    TargetTheme = Palette
                    ResolvedName = ExistingName
                    break
                end
            end
        else
            ResolvedName = NameOrTable
        end
    elseif type(NameOrTable) == "table" then
        TargetTheme = NormalizeTheme(NameOrTable)
        ResolvedName = NameOrTable.Name or "Custom"
    end

    if not TargetTheme then
        return false
    end

    SairyLib.ThemeName = ResolvedName
    CopyPaletteIntoActive(TargetTheme)
    NotifyThemeListeners(Instant)
    return true
end

function SairyLib:GetTheme()
    return SairyLib.ThemeName, SairyColors
end

local NotifyColorNames = {
    purple = Color3.fromRGB(164, 99, 255),
    cyan = Color3.fromRGB(56, 189, 248),
    crimson = Color3.fromRGB(224, 49, 49),
    gold = Color3.fromRGB(255, 204, 77),
    rose = Color3.fromRGB(255, 107, 158),
    sairy = Color3.fromRGB(255, 69, 0),
    revolution = Color3.fromRGB(255, 69, 0),
    orange = Color3.fromRGB(255, 154, 82),
    pink = Color3.fromRGB(255, 170, 195),
    mint = Color3.fromRGB(83, 215, 144),
    aqua = Color3.fromRGB(110, 214, 207),
    blue = Color3.fromRGB(100, 180, 220)
}

local function ResolveNotifyStyle(NotifyConfig)
    local RawType = tostring(NotifyConfig.Type or NotifyConfig.Style or "Info")
    local LowerType = RawType:lower()
    local LabelText = NotifyConfig.Tag or RawType:upper()
    local AccentColor = SairyColors.Accent

    if LowerType == "success" or LowerType == "ok" then
        LabelText = NotifyConfig.Tag or "SUCCESS"
        AccentColor = SairyColors.NotifySuccess or SairyColors.ActiveGreen
    elseif LowerType == "warning" or LowerType == "warn" then
        LabelText = NotifyConfig.Tag or "WARNING"
        AccentColor = SairyColors.NotifyWarning
    elseif LowerType == "error" or LowerType == "danger" or LowerType == "fail" then
        LabelText = NotifyConfig.Tag or "ERROR"
        AccentColor = SairyColors.NotifyError
    elseif LowerType == "info" or LowerType == "accent" then
        LabelText = NotifyConfig.Tag or "INFO"
        AccentColor = SairyColors.Accent
    elseif NotifyColorNames[LowerType] then
        AccentColor = NotifyColorNames[LowerType]
    end

    local CustomColor = NotifyConfig.Color or NotifyConfig.AccentColor
    if CustomColor ~= nil then
        if type(CustomColor) == "string" and NotifyColorNames[CustomColor:lower()] then
            AccentColor = NotifyColorNames[CustomColor:lower()]
        else
            AccentColor = ParseColor(CustomColor, AccentColor)
        end
    end

    return AccentColor, LabelText, (LowerType == "info" or LowerType == "accent") and CustomColor == nil
end

local function Tween(Object, Properties, CustomTime, CustomStyle, CustomDirection)
    local Info = TweenInfo.new(
        CustomTime or SairyLib.TweenTime,
        CustomStyle or Enum.EasingStyle.Quad,
        CustomDirection or Enum.EasingDirection.Out
    )
    local Animation = TweenService:Create(Object, Info, Properties)
    Animation:Play()
    return Animation
end

local function ApplyCardHover(InteractiveObj, StrokeObj)
    InteractiveObj.MouseEnter:Connect(function()
        Tween(StrokeObj, { Color = SairyColors.StrokeHover }, 0.16)
    end)
    InteractiveObj.MouseLeave:Connect(function()
        Tween(StrokeObj, { Color = SairyColors.StrokeBorder }, 0.16)
    end)
end

local function FormatKeyName(KeyCodeEnum)
    if typeof(KeyCodeEnum) ~= "EnumItem" then
        return tostring(KeyCodeEnum)
    end
    local Map = {
        RightControl = "RCtrl",
        LeftControl = "LCtrl",
        RightShift = "RShift",
        LeftShift = "LShift",
        RightAlt = "RAlt",
        LeftAlt = "LAlt",
        Backquote = "~",
        Return = "Enter"
    }
    return Map[KeyCodeEnum.Name] or KeyCodeEnum.Name
end

local function SafeCallback(Callback, ...)
    local Ok, Err = pcall(Callback, ...)
    if not Ok then
        warn("[SairyLib] Callback error:", Err)
    end
end

function SairyLib:CreateWindow(WindowConfig)
    WindowConfig = WindowConfig or {}
    if WindowConfig.Theme then
        SairyLib:SetTheme(WindowConfig.Theme, true)
    end
    local TitleText = WindowConfig.Title or "SairyLib"
    local SubTitleText = WindowConfig.SubTitle or "[ SairyWare ]"
    local BrandIconId = WindowConfig.Icon or SairyAssets.BrandLogo
    local WindowSize = WindowConfig.Size or UDim2.fromOffset(480, 360)
    local MinWindowSize = WindowConfig.MinSize or Vector2.new(400, 300)
    local MaxWindowSize = WindowConfig.MaxSize or Vector2.new(860, 640)
    local ToggleKey = WindowConfig.ToggleKey or Enum.KeyCode.RightControl
    local KeepOnScreen = WindowConfig.KeepOnScreen ~= false
    local HoldSeconds = 0.32

    local ParentContainer = GetParentGui()
    for _, Existing in ipairs(ParentContainer:GetChildren()) do
        if Existing.Name == "SairyLib_UI" and Existing:IsA("ScreenGui") then
            Existing:Destroy()
        end
    end

    local Connections = {}
    local Destroyed = false
    local function TrackConnection(Connection)
        table.insert(Connections, Connection)
        return Connection
    end

    local ThemeBindings = {}
    local ThemeUpdaters = {}
    local function BindTheme(Obj, Prop, Role)
        if SairyColors[Role] then
            Obj[Prop] = SairyColors[Role]
        end
        table.insert(ThemeBindings, { Obj = Obj, Prop = Prop, Role = Role })
    end
    local function AddThemeUpdater(Fn)
        table.insert(ThemeUpdaters, Fn)
    end
    local function RefreshWindowTheme(Instant, AccentOnly)
        if Destroyed then return end
        for i = #ThemeBindings, 1, -1 do
            local Entry = ThemeBindings[i]
            if not Entry.Obj or not Entry.Obj.Parent then
                table.remove(ThemeBindings, i)
            elseif not AccentOnly or Entry.Role == "Accent" or Entry.Role == "AccentDarkText" or Entry.Role == "NotifyInfo" then
                local TargetColor = SairyColors[Entry.Role]
                if TargetColor then
                    if Instant then
                        Entry.Obj[Entry.Prop] = TargetColor
                    else
                        Tween(Entry.Obj, { [Entry.Prop] = TargetColor }, 0.2)
                    end
                end
            end
        end
        for i = #ThemeUpdaters, 1, -1 do
            local Ok, Keep = pcall(ThemeUpdaters[i], Instant)
            if not Ok or Keep == false then
                table.remove(ThemeUpdaters, i)
            end
        end
    end

    local function ThemeListener(Instant)
        RefreshWindowTheme(Instant, false)
    end
    table.insert(SairyLib.ThemeChangeListeners, ThemeListener)

    do
        local RainbowAcc = 0
        local RainbowHue = 0
        TrackConnection(RunService.Heartbeat:Connect(function(Dt)
            if Destroyed or not SairyColors.Rainbow then return end
            RainbowAcc += Dt
            if RainbowAcc < 0.05 then return end
            RainbowHue = (RainbowHue + RainbowAcc * 0.14) % 1
            RainbowAcc = 0
            local CycleAccent = Color3.fromHSV(RainbowHue, 0.72, 0.96)
            SairyColors.Accent = CycleAccent
            SairyColors.NotifyInfo = CycleAccent
            SairyColors.HeaderGradientBottom = CycleAccent:Lerp(SairyColors.WindowBg, 0.48)
            SairyColors.AccentDarkText = ((CycleAccent.R + CycleAccent.G + CycleAccent.B) > 1.9) and Color3.fromRGB(16, 20, 28) or Color3.fromRGB(255, 255, 255)
            RefreshWindowTheme(true, true)
        end))
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SairyLib_UI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 999
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = ParentContainer

    table.insert(SairyLib.ActiveWindows, ScreenGui)

    -- Notifications Holder (Bottom-Right)
    local NotificationHolder = Instance.new("Frame")
    NotificationHolder.Name = "Notifications"
    NotificationHolder.Size = UDim2.new(0, 280, 1, -40)
    NotificationHolder.Position = UDim2.new(1, -20, 1, -20)
    NotificationHolder.AnchorPoint = Vector2.new(1, 1)
    NotificationHolder.BackgroundTransparency = 1
    NotificationHolder.ZIndex = 40
    NotificationHolder.Parent = ScreenGui

    local NotificationLayout = Instance.new("UIListLayout")
    NotificationLayout.Padding = UDim.new(0, 6)
    NotificationLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    NotificationLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    NotificationLayout.SortOrder = Enum.SortOrder.LayoutOrder
    NotificationLayout.Parent = NotificationHolder

    -- Window Frame (Container)
    local WindowFrame = Instance.new("Frame")
    WindowFrame.Name = "Window"
    WindowFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    WindowFrame.Size = WindowSize
    WindowFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    WindowFrame.BackgroundTransparency = 1
    WindowFrame.Visible = true
    WindowFrame.Parent = ScreenGui

    -- Responsive Scale
    local WindowScale = Instance.new("UIScale")
    WindowScale.Name = "UIScale"
    WindowScale.Scale = 0.92
    WindowScale.Parent = WindowFrame

    local Camera = workspace.CurrentCamera
    local BaseScale = 1
    local function ComputeFitScale()
        local Viewport = ScreenGui.AbsoluteSize
        if Viewport.X <= 0 or Viewport.Y <= 0 then
            Viewport = Camera and Camera.ViewportSize or Vector2.new(800, 600)
        end
        local CurrentSize = WindowFrame.Size
        local ScaleX = (Viewport.X - 24) / math.max(CurrentSize.X.Offset, 1)
        local ScaleY = (Viewport.Y - 44) / math.max(CurrentSize.Y.Offset, 1)
        if Viewport.Y < 480 or Viewport.X < 650 then
            BaseScale = math.clamp(math.min(ScaleX, ScaleY), 0.70, 0.94)
        else
            BaseScale = math.clamp(math.min(ScaleX, ScaleY), 0.75, 1)
        end
        return BaseScale
    end

    local function ClampWindowToScreen()
        if not KeepOnScreen or Destroyed then return end
        local GuiSize = ScreenGui.AbsoluteSize
        if GuiSize.X <= 0 or GuiSize.Y <= 0 then return end
        local HalfW = (WindowFrame.Size.X.Offset * BaseScale) * 0.5
        local HalfH = (WindowFrame.Size.Y.Offset * BaseScale) * 0.5
        local AbsCenterX = WindowFrame.Position.X.Scale * GuiSize.X + WindowFrame.Position.X.Offset
        local AbsCenterY = WindowFrame.Position.Y.Scale * GuiSize.Y + WindowFrame.Position.Y.Offset
        local Margin = 8
        local MinX = math.min(HalfW + Margin, GuiSize.X * 0.5)
        local MaxX = math.max(GuiSize.X - HalfW - Margin, GuiSize.X * 0.5)
        local MinY = math.min(HalfH + Margin, GuiSize.Y * 0.5)
        local MaxY = math.max(GuiSize.Y - HalfH - Margin, GuiSize.Y * 0.5)
        local ClampedX = math.clamp(AbsCenterX, MinX, MaxX)
        local ClampedY = math.clamp(AbsCenterY, MinY, MaxY)
        WindowFrame.Position = UDim2.fromOffset(ClampedX, ClampedY)
    end

    ComputeFitScale()
    WindowScale.Scale = BaseScale * 0.93

    -- Window Drop Shadow
    local WindowShadow = Instance.new("ImageLabel")
    WindowShadow.Name = "Shadow"
    WindowShadow.Size = UDim2.new(1, 50, 1, 50)
    WindowShadow.Position = UDim2.new(0, -25, 0, -25)
    WindowShadow.BackgroundTransparency = 1
    WindowShadow.Image = SairyAssets.WindowShadow
    WindowShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    WindowShadow.ImageTransparency = 1
    WindowShadow.ScaleType = Enum.ScaleType.Slice
    WindowShadow.SliceCenter = Rect.new(49, 49, 450, 450)
    WindowShadow.ZIndex = 0
    WindowShadow.Parent = WindowFrame

    -- Body (CanvasGroup for Fade Animations)
    local Body = Instance.new("CanvasGroup")
    Body.Name = "Body"
    Body.Size = UDim2.new(1, 0, 1, 0)
    BindTheme(Body, "BackgroundColor3", "WindowBg")
    Body.BorderSizePixel = 0
    Body.ClipsDescendants = true
    Body.GroupTransparency = 1
    Body.Parent = WindowFrame

    local BodyCorner = Instance.new("UICorner")
    BodyCorner.CornerRadius = UDim.new(0, 10)
    BodyCorner.Parent = Body

    local BodyStroke = Instance.new("UIStroke")
    BindTheme(BodyStroke, "Color", "StrokeBorder")
    BodyStroke.Thickness = 1
    BodyStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    BodyStroke.Parent = Body

    -- Top Hairline Glow
    local TopHairline = Instance.new("Frame")
    TopHairline.Name = "TopHairline"
    TopHairline.Size = UDim2.new(1, 0, 0, 1)
    TopHairline.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TopHairline.BackgroundTransparency = 0.93
    TopHairline.BorderSizePixel = 0
    TopHairline.ZIndex = 5
    TopHairline.Parent = Body

    -- Bottom-Right Resize Grip Handle
    local ResizeGrip = Instance.new("Frame")
    ResizeGrip.Name = "ResizeGrip"
    ResizeGrip.Size = UDim2.new(0, 32, 0, 32)
    ResizeGrip.Position = UDim2.new(1, 4, 1, 4)
    ResizeGrip.AnchorPoint = Vector2.new(0.5, 0.5)
    ResizeGrip.BackgroundTransparency = 1
    ResizeGrip.ZIndex = 6
    ResizeGrip.Parent = WindowFrame

    local ResizeIcon = Instance.new("ImageLabel")
    ResizeIcon.Size = UDim2.new(0, 96, 0, 96)
    ResizeIcon.Position = UDim2.new(0.5, -16, 0.5, -16)
    ResizeIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    ResizeIcon.BackgroundTransparency = 1
    ResizeIcon.Image = SairyAssets.ResizeCorner
    BindTheme(ResizeIcon, "ImageColor3", "Accent")
    ResizeIcon.ImageTransparency = 0.8
    ResizeIcon.Parent = ResizeGrip

    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 170, 1, 0)
    Sidebar.BackgroundTransparency = 1
    Sidebar.Parent = Body

    -- Sidebar Divider
    local SidebarDivider = Instance.new("Frame")
    SidebarDivider.Name = "Divider"
    SidebarDivider.Size = UDim2.new(0, 1, 1, 0)
    SidebarDivider.Position = UDim2.new(0, 170, 0, 0)
    BindTheme(SidebarDivider, "BackgroundColor3", "StrokeBorder")
    SidebarDivider.BorderSizePixel = 0
    SidebarDivider.Parent = Body

    -- Content Area
    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.Size = UDim2.new(1, -171, 1, 0)
    Content.Position = UDim2.new(0, 171, 0, 0)
    Content.BackgroundTransparency = 1
    Content.ClipsDescendants = true
    Content.Parent = Body

    -- Smooth Transition Overlay CanvasGroups
    local TransitionOut = Instance.new("CanvasGroup")
    TransitionOut.Name = "TransitionOut"
    TransitionOut.Size = UDim2.new(1, 0, 1, 0)
    TransitionOut.Position = UDim2.new(0, 0, 0, 0)
    TransitionOut.BackgroundTransparency = 1
    TransitionOut.GroupTransparency = 1
    TransitionOut.Visible = false
    TransitionOut.Parent = Content

    local TransitionIn = Instance.new("CanvasGroup")
    TransitionIn.Name = "TransitionIn"
    TransitionIn.Size = UDim2.new(1, 0, 1, 0)
    TransitionIn.Position = UDim2.new(0, 0, 0, 0)
    TransitionIn.BackgroundTransparency = 1
    TransitionIn.GroupTransparency = 0
    TransitionIn.Visible = false
    TransitionIn.Parent = Content

    -- Sidebar Header (Brand Card)
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, -16, 0, 64)
    Header.Position = UDim2.new(0, 8, 0, 8)
    Header.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Header.BorderSizePixel = 0
    Header.Parent = Sidebar

    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.Name = "SairyBrandCorner"
    HeaderCorner.CornerRadius = UDim.new(0, 10)
    HeaderCorner.Parent = Header

    local HeaderStroke = Instance.new("UIStroke")
    HeaderStroke.Name = "SairyBrandBorder"
    BindTheme(HeaderStroke, "Color", "StrokeBorder")
    HeaderStroke.Thickness = 1
    HeaderStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    HeaderStroke.Parent = Header

    local HeaderGradient = Instance.new("UIGradient")
    HeaderGradient.Name = "SairyBrandGradient"
    HeaderGradient.Rotation = 90
    local function SyncHeaderGradient()
        HeaderGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, SairyColors.HeaderGradientTop),
            ColorSequenceKeypoint.new(1, SairyColors.HeaderGradientBottom)
        })
    end
    SyncHeaderGradient()
    AddThemeUpdater(SyncHeaderGradient)
    HeaderGradient.Parent = Header

    -- Brand Logo
    local LogoHolder = Instance.new("Frame")
    LogoHolder.Name = "SairyBrandLogoHolder"
    LogoHolder.Size = UDim2.new(0, 46, 0, 46)
    LogoHolder.Position = UDim2.new(0, 9, 0, 9)
    LogoHolder.BackgroundTransparency = 1
    LogoHolder.ClipsDescendants = true
    LogoHolder.Parent = Header

    local LogoImg = Instance.new("ImageLabel")
    LogoImg.Size = UDim2.new(1.2, 0, 1.2, 0)
    LogoImg.Position = UDim2.new(0.5, 0, 0.5, 0)
    LogoImg.AnchorPoint = Vector2.new(0.5, 0.5)
    LogoImg.BackgroundTransparency = 1
    LogoImg.Image = BrandIconId
    LogoImg.ScaleType = Enum.ScaleType.Fit
    LogoImg.Parent = LogoHolder

    local BrandTitle = Instance.new("TextLabel")
    BrandTitle.Size = UDim2.new(1, -72, 0, 17)
    BrandTitle.Position = UDim2.new(0, 64, 0, 16)
    BrandTitle.BackgroundTransparency = 1
    BrandTitle.Font = Enum.Font.GothamBold
    BrandTitle.Text = TitleText
    BindTheme(BrandTitle, "TextColor3", "TextPrimary")
    BrandTitle.TextSize = 13
    BrandTitle.TextTruncate = Enum.TextTruncate.AtEnd
    BrandTitle.TextXAlignment = Enum.TextXAlignment.Left
    BrandTitle.Parent = Header

    local BrandSub = Instance.new("TextLabel")
    BrandSub.Size = UDim2.new(1, -72, 0, 13)
    BrandSub.Position = UDim2.new(0, 64, 0, 35)
    BrandSub.BackgroundTransparency = 1
    BrandSub.Font = Enum.Font.GothamMedium
    BrandSub.Text = SubTitleText
    BindTheme(BrandSub, "TextColor3", "TextSecondary")
    BrandSub.TextSize = 9
    BrandSub.TextTruncate = Enum.TextTruncate.AtEnd
    BrandSub.TextXAlignment = Enum.TextXAlignment.Left
    BrandSub.Parent = Header

    -- Search Bar
    local SearchFrame = Instance.new("Frame")
    SearchFrame.Name = "SairySearch"
    SearchFrame.Size = UDim2.new(1, -16, 0, 34)
    SearchFrame.Position = UDim2.new(0, 8, 0, 80)
    BindTheme(SearchFrame, "BackgroundColor3", "CardBg")
    SearchFrame.BorderSizePixel = 0
    SearchFrame.Parent = Sidebar

    local SearchCorner = Instance.new("UICorner")
    SearchCorner.CornerRadius = UDim.new(0, 8)
    SearchCorner.Parent = SearchFrame

    local SearchStroke = Instance.new("UIStroke")
    BindTheme(SearchStroke, "Color", "StrokeBorder")
    SearchStroke.Thickness = 1
    SearchStroke.Transparency = 0.2
    SearchStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    SearchStroke.Parent = SearchFrame

    local SearchIcon = Instance.new("ImageLabel")
    SearchIcon.Size = UDim2.new(0, 14, 0, 14)
    SearchIcon.Position = UDim2.new(0, 10, 0.5, 0)
    SearchIcon.AnchorPoint = Vector2.new(0, 0.5)
    SearchIcon.BackgroundTransparency = 1
    SearchIcon.Image = SairyAssets.SearchIcon
    BindTheme(SearchIcon, "ImageColor3", "TextSecondary")
    SearchIcon.Parent = SearchFrame

    local SearchInput = Instance.new("TextBox")
    SearchInput.Name = "SearchInput"
    SearchInput.Size = UDim2.new(1, -42, 1, 0)
    SearchInput.Position = UDim2.new(0, 32, 0, 0)
    SearchInput.BackgroundTransparency = 1
    SearchInput.Font = Enum.Font.BuilderSans
    SearchInput.PlaceholderText = "Search..."
    BindTheme(SearchInput, "PlaceholderColor3", "TextSecondary")
    SearchInput.Text = ""
    BindTheme(SearchInput, "TextColor3", "TextPrimary")
    SearchInput.TextSize = 12
    SearchInput.TextXAlignment = Enum.TextXAlignment.Left
    SearchInput.ClearTextOnFocus = false
    SearchInput.Parent = SearchFrame

    SearchInput.Focused:Connect(function()
        Tween(SearchStroke, { Color = SairyColors.Accent, Transparency = 0 }, 0.16)
        Tween(SearchIcon, { ImageColor3 = SairyColors.Accent }, 0.16)
    end)
    SearchInput.FocusLost:Connect(function()
        Tween(SearchStroke, { Color = SairyColors.StrokeBorder, Transparency = 0.2 }, 0.16)
        Tween(SearchIcon, { ImageColor3 = SairyColors.TextSecondary }, 0.16)
    end)

    -- Tabs Scrolling Frame (Exact 16px Horizontal Padding)
    local TabsScroll = Instance.new("ScrollingFrame")
    TabsScroll.Name = "Tabs"
    TabsScroll.Size = UDim2.new(1, 0, 1, -158)
    TabsScroll.Position = UDim2.new(0, 0, 0, 122)
    TabsScroll.BackgroundTransparency = 1
    TabsScroll.BorderSizePixel = 0
    TabsScroll.ScrollBarThickness = 2
    BindTheme(TabsScroll, "ScrollBarImageColor3", "Accent")
    TabsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    TabsScroll.Parent = Sidebar

    local TabsPadding = Instance.new("UIPadding")
    TabsPadding.PaddingTop = UDim.new(0, 4)
    TabsPadding.PaddingBottom = UDim.new(0, 4)
    TabsPadding.PaddingLeft = UDim.new(0, 16)
    TabsPadding.PaddingRight = UDim.new(0, 16)
    TabsPadding.Parent = TabsScroll

    local TabsLayout = Instance.new("UIListLayout")
    TabsLayout.Padding = UDim.new(0, 4)
    TabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabsLayout.Parent = TabsScroll

    -- Active Tab Left Indicator Bar
    local TabIndicator = Instance.new("Frame")
    TabIndicator.Name = "TabIndicator"
    TabIndicator.Size = UDim2.new(0, 3, 0, 18)
    TabIndicator.Position = UDim2.new(0, 6, 0, 136)
    BindTheme(TabIndicator, "BackgroundColor3", "Accent")
    TabIndicator.BorderSizePixel = 0
    TabIndicator.Visible = false
    TabIndicator.Parent = Sidebar

    local IndCorner = Instance.new("UICorner")
    IndCorner.CornerRadius = UDim.new(1, 0)
    IndCorner.Parent = TabIndicator

    -- Bottom Keybind Hint (Shown when tabs don't overflow)
    local KeyHintFrame = Instance.new("Frame")
    KeyHintFrame.Name = "KeyHint"
    KeyHintFrame.Size = UDim2.new(1, -44, 0, 22)
    KeyHintFrame.Position = UDim2.new(0, 22, 1, -36)
    KeyHintFrame.BackgroundTransparency = 1
    KeyHintFrame.Visible = true
    KeyHintFrame.Parent = Sidebar

    local KeyChip = Instance.new("Frame")
    KeyChip.Name = "KeyChip"
    KeyChip.Size = UDim2.new(0, 0, 0, 22)
    KeyChip.AutomaticSize = Enum.AutomaticSize.X
    BindTheme(KeyChip, "BackgroundColor3", "InnerCardBg")
    KeyChip.BorderSizePixel = 0
    KeyChip.Parent = KeyHintFrame

    local KeyChipCorner = Instance.new("UICorner")
    KeyChipCorner.CornerRadius = UDim.new(0, 5)
    KeyChipCorner.Parent = KeyChip

    local KeyChipStroke = Instance.new("UIStroke")
    BindTheme(KeyChipStroke, "Color", "StrokeBorder")
    KeyChipStroke.Thickness = 1
    KeyChipStroke.Parent = KeyChip

    local KeyChipPad = Instance.new("UIPadding")
    KeyChipPad.PaddingLeft = UDim.new(0, 7)
    KeyChipPad.PaddingRight = UDim.new(0, 7)
    KeyChipPad.Parent = KeyChip

    local KeyChipLabel = Instance.new("TextLabel")
    KeyChipLabel.Size = UDim2.new(0, 0, 1, 0)
    KeyChipLabel.AutomaticSize = Enum.AutomaticSize.X
    KeyChipLabel.BackgroundTransparency = 1
    KeyChipLabel.Font = Enum.Font.BuilderSansMedium
    KeyChipLabel.Text = FormatKeyName(ToggleKey)
    BindTheme(KeyChipLabel, "TextColor3", "TextSecondary")
    KeyChipLabel.TextSize = 11
    KeyChipLabel.Parent = KeyChip

    -- SairyScrollHint Pill Button (Shown when tabs overflow downward)
    local ScrollHintBtn = Instance.new("TextButton")
    ScrollHintBtn.Name = "SairyScrollHint"
    ScrollHintBtn.Size = UDim2.new(0, 42, 0, 22)
    ScrollHintBtn.Position = UDim2.new(0.5, 0, 1, -7)
    ScrollHintBtn.AnchorPoint = Vector2.new(0.5, 1)
    BindTheme(ScrollHintBtn, "BackgroundColor3", "CardBg")
    ScrollHintBtn.BackgroundTransparency = 0.15
    ScrollHintBtn.BorderSizePixel = 0
    ScrollHintBtn.Text = ""
    ScrollHintBtn.AutoButtonColor = false
    ScrollHintBtn.Visible = false
    ScrollHintBtn.ZIndex = 4
    ScrollHintBtn.Parent = Sidebar

    local ScrollHintCorner = Instance.new("UICorner")
    ScrollHintCorner.CornerRadius = UDim.new(1, 0)
    ScrollHintCorner.Parent = ScrollHintBtn

    local ChevronLeft = Instance.new("Frame")
    ChevronLeft.Name = "SairyScrollChevron"
    ChevronLeft.Size = UDim2.new(0, 9, 0, 2)
    ChevronLeft.Position = UDim2.new(0.5, -3, 0.5, 0)
    ChevronLeft.AnchorPoint = Vector2.new(0.5, 0.5)
    ChevronLeft.Rotation = 40
    BindTheme(ChevronLeft, "BackgroundColor3", "Accent")
    ChevronLeft.BorderSizePixel = 0
    ChevronLeft.Parent = ScrollHintBtn
    Instance.new("UICorner", ChevronLeft).CornerRadius = UDim.new(1, 0)

    local ChevronRight = Instance.new("Frame")
    ChevronRight.Name = "SairyScrollChevron"
    ChevronRight.Size = UDim2.new(0, 9, 0, 2)
    ChevronRight.Position = UDim2.new(0.5, 3, 0.5, 0)
    ChevronRight.AnchorPoint = Vector2.new(0.5, 0.5)
    ChevronRight.Rotation = -40
    BindTheme(ChevronRight, "BackgroundColor3", "Accent")
    ChevronRight.BorderSizePixel = 0
    ChevronRight.Parent = ScrollHintBtn
    Instance.new("UICorner", ChevronRight).CornerRadius = UDim.new(1, 0)

    local function UpdateScrollHint()
        local Remaining = TabsScroll.AbsoluteCanvasSize.Y - TabsScroll.AbsoluteWindowSize.Y - TabsScroll.CanvasPosition.Y
        local HasMore = Remaining > 6
        ScrollHintBtn.Visible = HasMore
        KeyHintFrame.Visible = not HasMore
    end

    ScrollHintBtn.MouseButton1Click:Connect(function()
        local TargetY = math.min(
            TabsScroll.CanvasPosition.Y + 84,
            math.max(0, TabsScroll.AbsoluteCanvasSize.Y - TabsScroll.AbsoluteWindowSize.Y)
        )
        Tween(TabsScroll, { CanvasPosition = Vector2.new(0, TargetY) }, 0.2)
    end)

    -- Dragging Window on Header
    do
        local Dragging = false
        local DragInput = nil
        local DragStart = nil
        local StartPos = nil

        Header.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                Dragging = true
                DragStart = Input.Position
                StartPos = WindowFrame.Position
                Input.Changed:Connect(function()
                    if Input.UserInputState == Enum.UserInputState.End then
                        Dragging = false
                        ClampWindowToScreen()
                    end
                end)
            end
        end)

        Header.InputChanged:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                DragInput = Input
            end
        end)

        TrackConnection(UserInputService.InputChanged:Connect(function(Input)
            if Dragging and Input == DragInput then
                local Delta = Input.Position - DragStart
                WindowFrame.Position = UDim2.new(
                    StartPos.X.Scale,
                    StartPos.X.Offset + Delta.X,
                    StartPos.Y.Scale,
                    StartPos.Y.Offset + Delta.Y
                )
            end
        end))
    end

    -- Forward declaration for Indicator updater & Island Actions updater
    local UpdateIndicatorPosition
    local RefreshIslandActivities

    -- Resizing Window via Bottom-Right Grip
    do
        local Resizing = false
        local ResizeStartPos = nil
        local StartSize = nil

        ResizeGrip.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                Resizing = true
                ResizeStartPos = Input.Position
                StartSize = Vector2.new(WindowFrame.Size.X.Offset, WindowFrame.Size.Y.Offset)
                Tween(ResizeIcon, { ImageTransparency = 0.35 }, 0.14)
                Input.Changed:Connect(function()
                    if Input.UserInputState == Enum.UserInputState.End then
                        Resizing = false
                        Tween(ResizeIcon, { ImageTransparency = 0.8 }, 0.18)
                        ClampWindowToScreen()
                    end
                end)
            end
        end)

        ResizeGrip.MouseEnter:Connect(function()
            if not Resizing then
                Tween(ResizeIcon, { ImageTransparency = 0.45 }, 0.14)
            end
        end)
        ResizeGrip.MouseLeave:Connect(function()
            if not Resizing then
                Tween(ResizeIcon, { ImageTransparency = 0.8 }, 0.14)
            end
        end)

        TrackConnection(UserInputService.InputChanged:Connect(function(Input)
            if Resizing and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
                local ScaleFactor = math.max(WindowScale.Scale, 0.5)
                local Delta = (Input.Position - ResizeStartPos) / ScaleFactor
                local NewW = math.clamp(math.round(StartSize.X + Delta.X), MinWindowSize.X, MaxWindowSize.X)
                local NewH = math.clamp(math.round(StartSize.Y + Delta.Y), MinWindowSize.Y, MaxWindowSize.Y)
                WindowFrame.Size = UDim2.fromOffset(NewW, NewH)
                if UpdateIndicatorPosition then UpdateIndicatorPosition(true) end
                UpdateScrollHint()
            end
        end))
    end

    -- Open / Close Window State
    local IsWindowOpen = true
    local ToggleGeneration = 0
    local OpenInterfaceBtn

    -- Viewport Scale Updates
    TrackConnection(ScreenGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        local NewScale = ComputeFitScale()
        if IsWindowOpen then
            WindowScale.Scale = NewScale
        end
        ClampWindowToScreen()
        UpdateScrollHint()
    end))

    local function SetWindowVisible(VisibleState)
        IsWindowOpen = VisibleState
        ToggleGeneration += 1
        local Gen = ToggleGeneration
        ComputeFitScale()

        if OpenInterfaceBtn then
            OpenInterfaceBtn.Text = IsWindowOpen and "Close Interface" or "Open Interface"
        end

        if VisibleState then
            WindowFrame.Visible = true
            Tween(WindowScale, { Scale = BaseScale }, 0.24, Enum.EasingStyle.Back)
            Tween(Body, { GroupTransparency = 0 }, 0.20)
            Tween(WindowShadow, { ImageTransparency = 0.5 }, 0.22)
        else
            Tween(WindowScale, { Scale = BaseScale * 0.93 }, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            Tween(WindowShadow, { ImageTransparency = 1 }, 0.16)
            local FadeTween = Tween(Body, { GroupTransparency = 1 }, 0.16)
            FadeTween.Completed:Connect(function()
                if not IsWindowOpen and ToggleGeneration == Gen and not Destroyed then
                    WindowFrame.Visible = false
                end
            end)
        end
    end

    -- Trigger opening animation on first launch
    task.defer(function()
        ClampWindowToScreen()
        local IntroTween = Tween(WindowScale, { Scale = BaseScale }, 0.26, Enum.EasingStyle.Back)
        Tween(Body, { GroupTransparency = 0 }, 0.22)
        Tween(WindowShadow, { ImageTransparency = 0.5 }, 0.24)
        IntroTween.Completed:Connect(function()
            if not Destroyed and UpdateIndicatorPosition then
                UpdateIndicatorPosition(true)
            end
        end)
    end)

    TrackConnection(UserInputService.InputBegan:Connect(function(Input, GameProcessed)
        if not GameProcessed and Input.KeyCode == ToggleKey then
            SetWindowVisible(not IsWindowOpen)
        end
    end))

    -- =========================================================================
    -- Dynamic Island System (SAIRYTG Capsule + LogoBubble + IslandDetails)
    -- =========================================================================
    local IslandContainer = Instance.new("TextButton")
    IslandContainer.Name = "SAIRYTG"
    IslandContainer.Size = UDim2.new(0, 168, 0, 60)
    IslandContainer.Position = UDim2.new(0, 24, 0, 32)
    IslandContainer.BackgroundTransparency = 1
    IslandContainer.Text = ""
    IslandContainer.AutoButtonColor = false
    IslandContainer.ZIndex = 30
    IslandContainer.Parent = ScreenGui

    local ContainerScale = Instance.new("UIScale")
    ContainerScale.Scale = 1
    ContainerScale.Parent = IslandContainer

    -- Main Pill Capsule
    local IslandPill = Instance.new("CanvasGroup")
    IslandPill.Name = "Island"
    IslandPill.Size = UDim2.new(0, 156, 0, 50)
    IslandPill.Position = UDim2.new(0.5, 0, 0.5, 0)
    IslandPill.AnchorPoint = Vector2.new(0.5, 0.5)
    BindTheme(IslandPill, "BackgroundColor3", "IslandBg")
    IslandPill.BorderSizePixel = 0
    IslandPill.Parent = IslandContainer

    local IslandCorner = Instance.new("UICorner")
    IslandCorner.CornerRadius = UDim.new(0, 25)
    IslandCorner.Parent = IslandPill

    local IslandStroke = Instance.new("UIStroke")
    BindTheme(IslandStroke, "Color", "IslandStroke")
    IslandStroke.Thickness = 1
    IslandStroke.Transparency = 0.12
    IslandStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    IslandStroke.Parent = IslandPill

    local IslandLogo = Instance.new("ImageLabel")
    IslandLogo.Name = "Logo"
    IslandLogo.Size = UDim2.new(0, 26, 0, 26)
    IslandLogo.Position = UDim2.new(0, 14, 0, 12)
    IslandLogo.BackgroundTransparency = 1
    IslandLogo.Image = BrandIconId
    IslandLogo.ScaleType = Enum.ScaleType.Fit
    IslandLogo.Parent = IslandPill

    local IslandTitle = Instance.new("TextLabel")
    IslandTitle.Name = "Title"
    IslandTitle.Size = UDim2.new(0, 74, 0, 50)
    IslandTitle.Position = UDim2.new(0, 48, 0, 0)
    IslandTitle.BackgroundTransparency = 1
    IslandTitle.Font = Enum.Font.GothamMedium
    IslandTitle.Text = TitleText
    BindTheme(IslandTitle, "TextColor3", "TextPrimary")
    IslandTitle.TextSize = 14
    IslandTitle.TextTruncate = Enum.TextTruncate.AtEnd
    IslandTitle.TextXAlignment = Enum.TextXAlignment.Left
    IslandTitle.Parent = IslandPill

    local ActivityHalo = Instance.new("Frame")
    ActivityHalo.Name = "ActivityHalo"
    ActivityHalo.Size = UDim2.new(0, 16, 0, 16)
    ActivityHalo.Position = UDim2.new(1, -24, 0.5, 0)
    ActivityHalo.AnchorPoint = Vector2.new(0.5, 0.5)
    ActivityHalo.BackgroundColor3 = SairyColors.ActiveGreen
    ActivityHalo.BackgroundTransparency = 0.65
    ActivityHalo.BorderSizePixel = 0
    ActivityHalo.Parent = IslandPill
    Instance.new("UICorner", ActivityHalo).CornerRadius = UDim.new(0, 20)

    local ActivityDot = Instance.new("Frame")
    ActivityDot.Name = "ActivityDot"
    ActivityDot.Size = UDim2.new(0, 7, 0, 7)
    ActivityDot.Position = UDim2.new(1, -24, 0.5, 0)
    ActivityDot.AnchorPoint = Vector2.new(0.5, 0.5)
    ActivityDot.BackgroundColor3 = SairyColors.ActiveGreen
    ActivityDot.BorderSizePixel = 0
    ActivityDot.Parent = IslandPill
    Instance.new("UICorner", ActivityDot).CornerRadius = UDim.new(0, 8)

    local HoldProgress = Instance.new("Frame")
    HoldProgress.Name = "HoldProgress"
    HoldProgress.Size = UDim2.new(0, 0, 0, 2)
    HoldProgress.Position = UDim2.new(0.5, 0, 1, -3)
    HoldProgress.AnchorPoint = Vector2.new(0.5, 1)
    BindTheme(HoldProgress, "BackgroundColor3", "Accent")
    HoldProgress.BorderSizePixel = 0
    HoldProgress.Parent = IslandPill
    Instance.new("UICorner", HoldProgress).CornerRadius = UDim.new(1, 0)

    -- Docked Compact LogoBubble Mode
    local LogoBubble = Instance.new("Frame")
    LogoBubble.Name = "LogoBubble"
    LogoBubble.Size = UDim2.new(0, 50, 0, 50)
    LogoBubble.Position = UDim2.new(0, 6, 0.5, 0)
    LogoBubble.AnchorPoint = Vector2.new(0, 0.5)
    BindTheme(LogoBubble, "BackgroundColor3", "IslandBg")
    LogoBubble.BorderSizePixel = 0
    LogoBubble.Visible = false
    LogoBubble.Parent = IslandContainer
    Instance.new("UICorner", LogoBubble).CornerRadius = UDim.new(0, 25)

    local BubbleStroke = Instance.new("UIStroke")
    BindTheme(BubbleStroke, "Color", "IslandStroke")
    BubbleStroke.Thickness = 1
    BubbleStroke.Transparency = 0.12
    BubbleStroke.Parent = LogoBubble

    local BubbleLogo = Instance.new("ImageLabel")
    BubbleLogo.Name = "Logo"
    BubbleLogo.Size = UDim2.new(0, 28, 0, 28)
    BubbleLogo.Position = UDim2.new(0.5, 0, 0.5, 0)
    BubbleLogo.AnchorPoint = Vector2.new(0.5, 0.5)
    BubbleLogo.BackgroundTransparency = 1
    BubbleLogo.Image = BrandIconId
    BubbleLogo.ScaleType = Enum.ScaleType.Fit
    BubbleLogo.Parent = LogoBubble

    -- Expanded IslandDetails Panel (350 x 228)
    local IslandDetails = Instance.new("CanvasGroup")
    IslandDetails.Name = "IslandDetails"
    IslandDetails.Size = UDim2.new(0, 350, 0, 228)
    IslandDetails.Position = UDim2.new(0.5, 0, 0, 4)
    IslandDetails.AnchorPoint = Vector2.new(0.5, 0)
    BindTheme(IslandDetails, "BackgroundColor3", "WindowBg")
    IslandDetails.BorderSizePixel = 0
    IslandDetails.GroupTransparency = 1
    IslandDetails.Visible = false
    IslandDetails.ZIndex = 35
    IslandDetails.Parent = IslandContainer

    local DetailsCorner = Instance.new("UICorner")
    DetailsCorner.CornerRadius = UDim.new(0, 28)
    DetailsCorner.Parent = IslandDetails

    local DetailsStroke = Instance.new("UIStroke")
    BindTheme(DetailsStroke, "Color", "StrokeBorder")
    DetailsStroke.Thickness = 1
    DetailsStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    DetailsStroke.Parent = IslandDetails

    local DetailsScale = Instance.new("UIScale")
    DetailsScale.Scale = 0.88
    DetailsScale.Parent = IslandDetails

    local DetailsDragHeader = Instance.new("Frame")
    DetailsDragHeader.Name = "DragHeader"
    DetailsDragHeader.Size = UDim2.new(1, 0, 0, 70)
    DetailsDragHeader.BackgroundTransparency = 1
    DetailsDragHeader.Parent = IslandDetails

    local DetailsHeading = Instance.new("TextLabel")
    DetailsHeading.Name = "Heading"
    DetailsHeading.Size = UDim2.new(1, -152, 0, 21)
    DetailsHeading.Position = UDim2.new(0, 22, 0, 18)
    DetailsHeading.BackgroundTransparency = 1
    DetailsHeading.Font = Enum.Font.GothamMedium
    DetailsHeading.Text = TitleText
    BindTheme(DetailsHeading, "TextColor3", "TextPrimary")
    DetailsHeading.TextSize = 17
    DetailsHeading.TextTruncate = Enum.TextTruncate.AtEnd
    DetailsHeading.TextXAlignment = Enum.TextXAlignment.Left
    DetailsHeading.Parent = IslandDetails

    local DetailsSubtitle = Instance.new("TextLabel")
    DetailsSubtitle.Name = "Subtitle"
    DetailsSubtitle.Size = UDim2.new(1, -152, 0, 18)
    DetailsSubtitle.Position = UDim2.new(0, 22, 0, 44)
    DetailsSubtitle.BackgroundTransparency = 1
    DetailsSubtitle.Font = Enum.Font.GothamMedium
    DetailsSubtitle.Text = "0 Enabled · 0 Available"
    BindTheme(DetailsSubtitle, "TextColor3", "TextSecondary")
    DetailsSubtitle.TextSize = 12
    DetailsSubtitle.TextTruncate = Enum.TextTruncate.AtEnd
    DetailsSubtitle.TextXAlignment = Enum.TextXAlignment.Left
    DetailsSubtitle.Parent = IslandDetails

    -- Player Avatar Thumbnail inside IslandDetails
    local PlayerAvatar = Instance.new("ImageLabel")
    PlayerAvatar.Name = "PlayerProfile"
    PlayerAvatar.Size = UDim2.new(0, 36, 0, 36)
    PlayerAvatar.Position = UDim2.new(1, -70, 0, 10)
    PlayerAvatar.AnchorPoint = Vector2.new(0.5, 0)
    BindTheme(PlayerAvatar, "BackgroundColor3", "CardBg")
    PlayerAvatar.BorderSizePixel = 0
    PlayerAvatar.ScaleType = Enum.ScaleType.Crop
    PlayerAvatar.Image = string.format("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150", LocalPlayer.UserId)
    PlayerAvatar.Parent = IslandDetails
    Instance.new("UICorner", PlayerAvatar).CornerRadius = UDim.new(0.5, 0)

    local AvatarStroke = Instance.new("UIStroke")
    BindTheme(AvatarStroke, "Color", "StrokeBorder")
    AvatarStroke.Thickness = 1
    AvatarStroke.Parent = PlayerAvatar

    local DisplayNameLabel = Instance.new("TextLabel")
    DisplayNameLabel.Name = "DisplayName"
    DisplayNameLabel.Size = UDim2.new(0, 108, 0, 16)
    DisplayNameLabel.Position = UDim2.new(1, -124, 0, 49)
    DisplayNameLabel.BackgroundTransparency = 1
    DisplayNameLabel.Font = Enum.Font.GothamMedium
    DisplayNameLabel.Text = LocalPlayer.Name
    BindTheme(DisplayNameLabel, "TextColor3", "TextSecondary")
    DisplayNameLabel.TextSize = 11
    DisplayNameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    DisplayNameLabel.Parent = IslandDetails

    local ActivitiesScroll = Instance.new("ScrollingFrame")
    ActivitiesScroll.Name = "Activities"
    ActivitiesScroll.Size = UDim2.new(1, -32, 0, 76)
    ActivitiesScroll.Position = UDim2.new(0, 16, 0, 76)
    ActivitiesScroll.BackgroundTransparency = 1
    ActivitiesScroll.BorderSizePixel = 0
    ActivitiesScroll.ScrollBarThickness = 3
    BindTheme(ActivitiesScroll, "ScrollBarImageColor3", "StrokeBorder")
    ActivitiesScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    ActivitiesScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ActivitiesScroll.Parent = IslandDetails

    local ActivitiesLayout = Instance.new("UIListLayout")
    ActivitiesLayout.Padding = UDim.new(0, 6)
    ActivitiesLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ActivitiesLayout.Parent = ActivitiesScroll

    local EmptyActivitiesLabel = Instance.new("TextLabel")
    EmptyActivitiesLabel.Name = "Empty"
    EmptyActivitiesLabel.Size = UDim2.new(1, -44, 0, 44)
    EmptyActivitiesLabel.Position = UDim2.new(0, 22, 0, 82)
    EmptyActivitiesLabel.BackgroundTransparency = 1
    EmptyActivitiesLabel.Font = Enum.Font.GothamMedium
    EmptyActivitiesLabel.Text = "No Enabled Functions"
    BindTheme(EmptyActivitiesLabel, "TextColor3", "TextSecondary")
    EmptyActivitiesLabel.TextSize = 14
    EmptyActivitiesLabel.Visible = true
    EmptyActivitiesLabel.Parent = IslandDetails

    local DetailsActions = Instance.new("Frame")
    DetailsActions.Name = "Actions"
    DetailsActions.Size = UDim2.new(1, -32, 0, 44)
    DetailsActions.Position = UDim2.new(0, 16, 1, -16)
    DetailsActions.AnchorPoint = Vector2.new(0, 1)
    DetailsActions.BackgroundTransparency = 1
    DetailsActions.Parent = IslandDetails

    OpenInterfaceBtn = Instance.new("TextButton")
    OpenInterfaceBtn.Name = "OpenInterface"
    OpenInterfaceBtn.Size = UDim2.new(0.68, -4, 1, 0)
    OpenInterfaceBtn.Position = UDim2.new(0, 0, 0, 0)
    BindTheme(OpenInterfaceBtn, "BackgroundColor3", "Accent")
    OpenInterfaceBtn.BorderSizePixel = 0
    OpenInterfaceBtn.Font = Enum.Font.GothamMedium
    OpenInterfaceBtn.Text = IsWindowOpen and "Close Interface" or "Open Interface"
    BindTheme(OpenInterfaceBtn, "TextColor3", "AccentDarkText")
    OpenInterfaceBtn.TextSize = 13
    OpenInterfaceBtn.AutoButtonColor = false
    OpenInterfaceBtn.Parent = DetailsActions
    Instance.new("UICorner", OpenInterfaceBtn).CornerRadius = UDim.new(0, 12)
    local OpenBtnScale = Instance.new("UIScale", OpenInterfaceBtn)

    local CloseDetailsBtn = Instance.new("TextButton")
    CloseDetailsBtn.Name = "CloseDetails"
    CloseDetailsBtn.Size = UDim2.new(0.32, -4, 1, 0)
    CloseDetailsBtn.Position = UDim2.new(0.68, 4, 0, 0)
    BindTheme(CloseDetailsBtn, "BackgroundColor3", "CardBg")
    CloseDetailsBtn.BorderSizePixel = 0
    CloseDetailsBtn.Font = Enum.Font.GothamMedium
    CloseDetailsBtn.Text = "Close"
    BindTheme(CloseDetailsBtn, "TextColor3", "TextPrimary")
    CloseDetailsBtn.TextSize = 13
    CloseDetailsBtn.AutoButtonColor = false
    CloseDetailsBtn.Parent = DetailsActions
    Instance.new("UICorner", CloseDetailsBtn).CornerRadius = UDim.new(0, 12)
    local CloseBtnScale = Instance.new("UIScale", CloseDetailsBtn)

    OpenInterfaceBtn.MouseEnter:Connect(function() Tween(OpenBtnScale, { Scale = 1.025 }, 0.12) end)
    OpenInterfaceBtn.MouseLeave:Connect(function() Tween(OpenBtnScale, { Scale = 1 }, 0.12) end)
    CloseDetailsBtn.MouseEnter:Connect(function() Tween(CloseBtnScale, { Scale = 1.025 }, 0.12) end)
    CloseDetailsBtn.MouseLeave:Connect(function() Tween(CloseBtnScale, { Scale = 1 }, 0.12) end)

    local IslandExpanded = false
    local function ClampIslandDetailsToScreen()
        local GuiSize = ScreenGui.AbsoluteSize
        if GuiSize.X <= 0 or GuiSize.Y <= 0 then return end
        local PanelW, PanelH = 350 * 0.96, 228 * 0.96
        local CenterX = IslandContainer.Position.X.Offset + IslandContainer.Size.X.Offset * 0.5
        local OffsetY = IslandContainer.Position.Y.Offset
        local NewX = math.clamp(CenterX - IslandContainer.Size.X.Offset * 0.5, math.max(12, PanelW * 0.5 - 70), math.max(12, GuiSize.X - PanelW * 0.5 - 98))
        local NewY = math.clamp(OffsetY, 8, math.max(8, GuiSize.Y - PanelH - 16))
        if IslandExpanded then
            IslandContainer.Position = UDim2.fromOffset(NewX, NewY)
        end
    end

    local function SetIslandExpanded(ExpandState)
        if IslandExpanded == ExpandState then return end
        IslandExpanded = ExpandState
        if ExpandState then
            if RefreshIslandActivities then RefreshIslandActivities() end
            OpenInterfaceBtn.Text = IsWindowOpen and "Close Interface" or "Open Interface"
            IslandPill.Visible = false
            LogoBubble.Visible = false
            IslandDetails.Visible = true
            ClampIslandDetailsToScreen()
            DetailsScale.Scale = 0.88
            IslandDetails.GroupTransparency = 1
            Tween(DetailsScale, { Scale = 0.96 }, 0.22, Enum.EasingStyle.Back)
            Tween(IslandDetails, { GroupTransparency = 0 }, 0.18)
        else
            Tween(DetailsScale, { Scale = 0.88 }, 0.16)
            local FadeOut = Tween(IslandDetails, { GroupTransparency = 1 }, 0.15)
            FadeOut.Completed:Connect(function()
                if not IslandExpanded and not Destroyed then
                    IslandDetails.Visible = false
                    IslandPill.Visible = true
                end
            end)
        end
    end

    OpenInterfaceBtn.MouseButton1Click:Connect(function()
        SetWindowVisible(not IsWindowOpen)
        SetIslandExpanded(false)
    end)

    CloseDetailsBtn.MouseButton1Click:Connect(function()
        SetIslandExpanded(false)
    end)

    -- Island Activity Tracking
    local RegisteredToggles = {}
    RefreshIslandActivities = function()
        for _, Child in ipairs(ActivitiesScroll:GetChildren()) do
            if Child.Name == "ActivityRow" then
                Child:Destroy()
            end
        end

        local EnabledCount = 0
        local TotalCount = #RegisteredToggles

        for _, Entry in ipairs(RegisteredToggles) do
            if Entry.GetState() then
                EnabledCount += 1

                local Row = Instance.new("Frame")
                Row.Name = "ActivityRow"
                Row.Size = UDim2.new(1, -5, 0, 70)
                BindTheme(Row, "BackgroundColor3", "InnerCardBg")
                Row.BorderSizePixel = 0
                Row.Parent = ActivitiesScroll
                Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 14)

                local RowTitle = Instance.new("TextLabel")
                RowTitle.Name = "Title"
                RowTitle.Size = UDim2.new(1, -116, 0, 21)
                RowTitle.Position = UDim2.new(0, 14, 0, 9)
                RowTitle.BackgroundTransparency = 1
                RowTitle.Font = Enum.Font.GothamMedium
                RowTitle.Text = Entry.Title
                BindTheme(RowTitle, "TextColor3", "TextPrimary")
                RowTitle.TextSize = 14
                RowTitle.TextTruncate = Enum.TextTruncate.AtEnd
                RowTitle.TextXAlignment = Enum.TextXAlignment.Left
                RowTitle.Parent = Row

                local RowDetail = Instance.new("TextLabel")
                RowDetail.Name = "Detail"
                RowDetail.Size = UDim2.new(1, -116, 0, 18)
                RowDetail.Position = UDim2.new(0, 14, 0, 34)
                RowDetail.BackgroundTransparency = 1
                RowDetail.Font = Enum.Font.GothamMedium
                RowDetail.Text = Entry.TabName .. " · " .. (Entry.Desc ~= "" and Entry.Desc or "Active")
                BindTheme(RowDetail, "TextColor3", "TextSecondary")
                RowDetail.TextSize = 11
                RowDetail.TextTruncate = Enum.TextTruncate.AtEnd
                RowDetail.TextXAlignment = Enum.TextXAlignment.Left
                RowDetail.Parent = Row

                local ValueBtn = Instance.new("TextButton")
                ValueBtn.Name = "Value"
                ValueBtn.Size = UDim2.new(0, 78, 0, 44)
                ValueBtn.Position = UDim2.new(1, -90, 0.5, -22)
                BindTheme(ValueBtn, "BackgroundColor3", "CardBg")
                ValueBtn.BorderSizePixel = 0
                ValueBtn.Font = Enum.Font.GothamMedium
                ValueBtn.Text = "On"
                BindTheme(ValueBtn, "TextColor3", "ActiveGreen")
                ValueBtn.TextSize = 13
                ValueBtn.AutoButtonColor = false
                ValueBtn.Parent = Row
                Instance.new("UICorner", ValueBtn).CornerRadius = UDim.new(0, 12)
                local ValScale = Instance.new("UIScale", ValueBtn)

                ValueBtn.MouseEnter:Connect(function() Tween(ValScale, { Scale = 1.04 }, 0.1) end)
                ValueBtn.MouseLeave:Connect(function() Tween(ValScale, { Scale = 1 }, 0.1) end)
                ValueBtn.MouseButton1Click:Connect(function()
                    Entry.SetState(false)
                end)
            end
        end

        DetailsSubtitle.Text = string.format("%d Enabled · %d Available", EnabledCount, TotalCount)
        EmptyActivitiesLabel.Visible = (EnabledCount == 0)
        Tween(ActivityDot, {
            BackgroundColor3 = EnabledCount > 0 and SairyColors.ActiveGreen or SairyColors.Accent
        }, 0.2)
        ActivityHalo.BackgroundColor3 = EnabledCount > 0 and SairyColors.ActiveGreen or SairyColors.Accent
    end

    AddThemeUpdater(function(Instant)
        local AnyActive = false
        for _, Entry in ipairs(RegisteredToggles) do
            if Entry.GetState() then
                AnyActive = true
                break
            end
        end
        local TargetDot = AnyActive and SairyColors.ActiveGreen or SairyColors.Accent
        if Instant then
            ActivityDot.BackgroundColor3 = TargetDot
        else
            Tween(ActivityDot, { BackgroundColor3 = TargetDot }, 0.2)
        end
        ActivityHalo.BackgroundColor3 = TargetDot
    end)

    -- ActivityHalo Continuous Breathing Pulse
    do
        local PulseClock = 0
        TrackConnection(RunService.Heartbeat:Connect(function(Dt)
            if Destroyed then return end
            PulseClock += Dt * 2.6
            local Wave = (math.sin(PulseClock) + 1) * 0.5
            ActivityHalo.BackgroundTransparency = 0.52 + Wave * 0.34
            local HaloPx = 14 + Wave * 4
            ActivityHalo.Size = UDim2.fromOffset(HaloPx, HaloPx)
        end))
    end

    -- SAIRYTG Drag + Tap + Hold (0.32s) -> Expand IslandDetails / Compact Edge Dock
    do
        local Pressing = false
        local Moving = false
        local HoldTriggered = false
        local PressStartPos = nil
        local ContainerStartPos = nil
        local HoldGen = 0

        local function ResetHoldBar()
            HoldGen += 1
            Tween(HoldProgress, { Size = UDim2.new(0, 0, 0, 2) }, 0.12)
        end

        local function HandleIslandInputBegan(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                Pressing = true
                Moving = false
                HoldTriggered = false
                PressStartPos = Input.Position
                ContainerStartPos = IslandContainer.Position
                HoldGen += 1
                local ThisHold = HoldGen

                Tween(ContainerScale, { Scale = 0.96 }, 0.1)
                if not IslandExpanded then
                    Tween(HoldProgress, { Size = UDim2.new(0, 82, 0, 2) }, HoldSeconds, Enum.EasingStyle.Linear)
                    task.delay(HoldSeconds, function()
                        if Pressing and not Moving and HoldGen == ThisHold and not Destroyed then
                            HoldTriggered = true
                            ResetHoldBar()
                            Tween(ContainerScale, { Scale = 1 }, 0.15, Enum.EasingStyle.Back)
                            SetIslandExpanded(true)
                        end
                    end)
                end

                Input.Changed:Connect(function()
                    if Input.UserInputState == Enum.UserInputState.End and Pressing then
                        Pressing = false
                        ResetHoldBar()
                        Tween(ContainerScale, { Scale = 1 }, 0.18, Enum.EasingStyle.Back)

                        if not Moving and not HoldTriggered then
                            if not IslandExpanded then
                                SetWindowVisible(not IsWindowOpen)
                            end
                        elseif Moving then
                            -- Snap to LogoBubble only if tucked hard against left edge (< 8px) and not expanded
                            local GuiSize = ScreenGui.AbsoluteSize
                            if GuiSize.X > 0 and GuiSize.Y > 0 then
                                local PosX = math.clamp(IslandContainer.Position.X.Offset, 4, GuiSize.X - 60)
                                local PosY = math.clamp(IslandContainer.Position.Y.Offset, 8, GuiSize.Y - 64)
                                if not IslandExpanded and PosX <= 8 then
                                    IslandContainer.Position = UDim2.fromOffset(4, PosY)
                                    IslandPill.Visible = false
                                    LogoBubble.Visible = true
                                else
                                    LogoBubble.Visible = false
                                    if not IslandExpanded then
                                        IslandPill.Visible = true
                                    end
                                    local MaxRight = math.max(8, GuiSize.X - IslandContainer.Size.X.Offset - 8)
                                    IslandContainer.Position = UDim2.fromOffset(math.clamp(PosX, 8, MaxRight), PosY)
                                end
                            end
                        end
                    end
                end)
            elseif Input.UserInputType == Enum.UserInputType.MouseButton2 then
                SetIslandExpanded(not IslandExpanded)
            end
        end

        IslandContainer.InputBegan:Connect(HandleIslandInputBegan)
        DetailsDragHeader.InputBegan:Connect(HandleIslandInputBegan)

        TrackConnection(UserInputService.InputChanged:Connect(function(Input)
            if Pressing and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
                local Delta = Input.Position - PressStartPos
                if Delta.Magnitude > 6 then
                    Moving = true
                    ResetHoldBar()
                    if LogoBubble.Visible then
                        LogoBubble.Visible = false
                        if not IslandExpanded then IslandPill.Visible = true end
                    end
                    IslandContainer.Position = UDim2.new(
                        ContainerStartPos.X.Scale,
                        ContainerStartPos.X.Offset + Delta.X,
                        ContainerStartPos.Y.Scale,
                        ContainerStartPos.Y.Offset + Delta.Y
                    )
                end
            end
        end))
    end

    -- =========================================================================
    -- Window Public API Object
    -- =========================================================================
    local WindowHandler = {
        Tabs = {},
        ActiveTab = nil,
        Gui = ScreenGui,
        Frame = WindowFrame
    }

    local TransitionGen = 0

    UpdateIndicatorPosition = function(Instant)
        local Active = WindowHandler.ActiveTab
        if not Active or not Active.Button.Visible then
            TabIndicator.Visible = false
            return
        end
        local ScaleFactor = math.max(WindowScale.Scale, 0.5)
        local RelY = (Active.Button.AbsolutePosition.Y - Sidebar.AbsolutePosition.Y) / ScaleFactor + 10
        local TabsTop = (TabsScroll.AbsolutePosition.Y - Sidebar.AbsolutePosition.Y) / ScaleFactor
        local TabsBottom = TabsTop + (TabsScroll.AbsoluteSize.Y / ScaleFactor)
        if RelY < TabsTop - 4 or RelY > TabsBottom - 12 then
            TabIndicator.Visible = false
            return
        end
        TabIndicator.Visible = true
        local TargetPos = UDim2.new(0, 6, 0, RelY)
        if Instant then
            TabIndicator.Position = TargetPos
        else
            Tween(TabIndicator, { Position = TargetPos }, 0.2)
        end
    end

    TrackConnection(TabsScroll:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
        UpdateIndicatorPosition(true)
        UpdateScrollHint()
    end))

    TrackConnection(TabsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        UpdateScrollHint()
        UpdateIndicatorPosition(true)
    end))

    -- Sidebar Search Filtering
    SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
        local Query = SearchInput.Text:lower()
        for _, TabRecord in ipairs(WindowHandler.Tabs) do
            if Query == "" or TabRecord.Title:lower():find(Query, 1, true) then
                TabRecord.Button.Visible = true
            else
                TabRecord.Button.Visible = false
            end
        end
        task.defer(function()
            UpdateIndicatorPosition(true)
            UpdateScrollHint()
        end)
    end)

    function WindowHandler:SetToggleKey(NewKey)
        ToggleKey = NewKey
        KeyChipLabel.Text = FormatKeyName(NewKey)
    end

    function WindowHandler:SetTitle(NewTitle)
        TitleText = tostring(NewTitle or TitleText)
        BrandTitle.Text = TitleText
        IslandTitle.Text = TitleText
        DetailsHeading.Text = TitleText
    end

    function WindowHandler:SetSubtitle(NewSub)
        SubTitleText = tostring(NewSub or SubTitleText)
        BrandSub.Text = SubTitleText
    end

    function WindowHandler:Toggle(State)
        if State == nil then
            SetWindowVisible(not IsWindowOpen)
        else
            SetWindowVisible(State == true)
        end
    end

    function WindowHandler:SetTheme(NameOrTable, Instant)
        return SairyLib:SetTheme(NameOrTable, Instant)
    end

    function WindowHandler:GetTheme()
        return SairyLib:GetTheme()
    end

    function WindowHandler:GetThemes()
        return SairyLib:GetThemes()
    end

    function WindowHandler:Notify(NotifyConfig)
        NotifyConfig = NotifyConfig or {}
        local Title = NotifyConfig.Title or "Notice"
        local Msg = NotifyConfig.Content or NotifyConfig.Text or NotifyConfig.Message or ""
        local Duration = NotifyConfig.Duration or 3
        local IconId = NotifyConfig.Icon or NotifyConfig.Image
        local AccentColor, TagText, FollowsThemeAccent = ResolveNotifyStyle(NotifyConfig)

        -- Trim excess notifications (>4)
        local CurrentNotifs = {}
        for _, Child in ipairs(NotificationHolder:GetChildren()) do
            if Child:IsA("CanvasGroup") then
                table.insert(CurrentNotifs, Child)
            end
        end
        if #CurrentNotifs >= 4 then
            CurrentNotifs[1]:Destroy()
        end

        local Card = Instance.new("CanvasGroup")
        Card.Name = "SairyNotification"
        Card:SetAttribute("NotifyType", TagText)
        Card.Size = UDim2.new(1, 0, 0, 0)
        Card.AutomaticSize = Enum.AutomaticSize.Y
        BindTheme(Card, "BackgroundColor3", "CardBg")
        Card.BorderSizePixel = 0
        Card.GroupTransparency = 1
        Card.Parent = NotificationHolder

        Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)
        local CardStroke = Instance.new("UIStroke")
        CardStroke.Color = SairyColors.StrokeBorder:Lerp(AccentColor, 0.42)
        CardStroke.Thickness = 1
        CardStroke.Parent = Card

        local AccentGlow = Instance.new("ImageLabel")
        AccentGlow.Name = "Glow"
        AccentGlow.Size = UDim2.new(0, 96, 1, 20)
        AccentGlow.Position = UDim2.new(0, -32, 0.5, 0)
        AccentGlow.AnchorPoint = Vector2.new(0, 0.5)
        AccentGlow.BackgroundTransparency = 1
        AccentGlow.Image = SairyAssets.ToggleGlow
        AccentGlow.ImageColor3 = AccentColor
        AccentGlow.ImageTransparency = 0.84
        AccentGlow.ZIndex = 0
        AccentGlow.Parent = Card

        local AccentStrip = Instance.new("Frame")
        AccentStrip.Name = "AccentStrip"
        AccentStrip.Size = UDim2.new(0, 3, 1, -14)
        AccentStrip.Position = UDim2.new(0, 8, 0.5, 0)
        AccentStrip.AnchorPoint = Vector2.new(0, 0.5)
        AccentStrip.BackgroundColor3 = AccentColor
        AccentStrip.BorderSizePixel = 0
        AccentStrip.Parent = Card
        Instance.new("UICorner", AccentStrip).CornerRadius = UDim.new(1, 0)

        local InnerWrap = Instance.new("Frame")
        InnerWrap.Size = UDim2.new(1, 0, 0, 0)
        InnerWrap.AutomaticSize = Enum.AutomaticSize.Y
        InnerWrap.BackgroundTransparency = 1
        InnerWrap.Parent = Card

        local InnerPad = Instance.new("UIPadding")
        InnerPad.PaddingTop = UDim.new(0, 10)
        InnerPad.PaddingBottom = UDim.new(0, 12)
        InnerPad.PaddingLeft = UDim.new(0, 18)
        InnerPad.PaddingRight = UDim.new(0, 12)
        InnerPad.Parent = InnerWrap

        local InnerLayout = Instance.new("UIListLayout")
        InnerLayout.Padding = UDim.new(0, 4)
        InnerLayout.SortOrder = Enum.SortOrder.LayoutOrder
        InnerLayout.Parent = InnerWrap

        local TopRow = Instance.new("Frame")
        TopRow.Name = "TopRow"
        TopRow.Size = UDim2.new(1, 0, 0, 18)
        TopRow.BackgroundTransparency = 1
        TopRow.LayoutOrder = 1
        TopRow.Parent = InnerWrap

        local TagBadge = Instance.new("Frame")
        TagBadge.Name = "TypeBadge"
        TagBadge.Size = UDim2.new(0, 0, 0, 17)
        TagBadge.AutomaticSize = Enum.AutomaticSize.X
        TagBadge.Position = UDim2.new(1, 0, 0.5, 0)
        TagBadge.AnchorPoint = Vector2.new(1, 0.5)
        TagBadge.BackgroundColor3 = AccentColor:Lerp(SairyColors.CardBg, 0.82)
        TagBadge.BorderSizePixel = 0
        TagBadge.Parent = TopRow
        Instance.new("UICorner", TagBadge).CornerRadius = UDim.new(0, 5)

        local TagStroke = Instance.new("UIStroke")
        TagStroke.Color = AccentColor
        TagStroke.Transparency = 0.55
        TagStroke.Thickness = 1
        TagStroke.Parent = TagBadge

        local TagPad = Instance.new("UIPadding")
        TagPad.PaddingLeft = UDim.new(0, 6)
        TagPad.PaddingRight = UDim.new(0, 6)
        TagPad.Parent = TagBadge

        local TagLbl = Instance.new("TextLabel")
        TagLbl.Name = "TagText"
        TagLbl.Size = UDim2.new(0, 0, 1, 0)
        TagLbl.AutomaticSize = Enum.AutomaticSize.X
        TagLbl.BackgroundTransparency = 1
        TagLbl.Font = Enum.Font.GothamBold
        TagLbl.Text = TagText
        TagLbl.TextColor3 = AccentColor
        TagLbl.TextSize = 9
        TagLbl.Parent = TagBadge

        local TitleLeftOffset = 0
        if IconId then
            local IconImg = Instance.new("ImageLabel")
            IconImg.Name = "Icon"
            IconImg.Size = UDim2.new(0, 14, 0, 14)
            IconImg.Position = UDim2.new(0, 0, 0.5, 0)
            IconImg.AnchorPoint = Vector2.new(0, 0.5)
            IconImg.BackgroundTransparency = 1
            IconImg.Image = IconId
            IconImg.ImageColor3 = AccentColor
            IconImg.Parent = TopRow
            TitleLeftOffset = 20
        end

        local TitleLbl = Instance.new("TextLabel")
        TitleLbl.Name = "Title"
        TitleLbl.Size = UDim2.new(1, -(TitleLeftOffset + 82), 1, 0)
        TitleLbl.Position = UDim2.new(0, TitleLeftOffset, 0, 0)
        TitleLbl.BackgroundTransparency = 1
        TitleLbl.Font = Enum.Font.GothamBold
        TitleLbl.Text = Title
        BindTheme(TitleLbl, "TextColor3", "TextPrimary")
        TitleLbl.TextSize = 13
        TitleLbl.TextTruncate = Enum.TextTruncate.AtEnd
        TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
        TitleLbl.Parent = TopRow

        if Msg ~= "" then
            local BodyLbl = Instance.new("TextLabel")
            BodyLbl.Name = "Content"
            BodyLbl.Size = UDim2.new(1, 0, 0, 0)
            BodyLbl.AutomaticSize = Enum.AutomaticSize.Y
            BodyLbl.BackgroundTransparency = 1
            BodyLbl.Font = Enum.Font.BuilderSans
            BodyLbl.Text = Msg
            BindTheme(BodyLbl, "TextColor3", "TextSecondary")
            BodyLbl.TextSize = 12
            BodyLbl.TextWrapped = true
            BodyLbl.TextXAlignment = Enum.TextXAlignment.Left
            BodyLbl.LayoutOrder = 2
            BodyLbl.Parent = InnerWrap
        end

        local TimerBar = Instance.new("Frame")
        TimerBar.Name = "TimerBar"
        TimerBar.Size = UDim2.new(1, 0, 0, 2)
        TimerBar.Position = UDim2.new(0, 0, 1, -2)
        TimerBar.BackgroundColor3 = AccentColor
        TimerBar.BorderSizePixel = 0
        TimerBar.Parent = Card

        AddThemeUpdater(function()
            if not Card.Parent then return false end
            local LiveAccent = FollowsThemeAccent and SairyColors.Accent or AccentColor
            AccentStrip.BackgroundColor3 = LiveAccent
            AccentGlow.ImageColor3 = LiveAccent
            TimerBar.BackgroundColor3 = LiveAccent
            TagLbl.TextColor3 = LiveAccent
            TagStroke.Color = LiveAccent
            TagBadge.BackgroundColor3 = LiveAccent:Lerp(SairyColors.CardBg, 0.82)
            CardStroke.Color = SairyColors.StrokeBorder:Lerp(LiveAccent, 0.42)
        end)

        local ClickClose = Instance.new("TextButton")
        ClickClose.Size = UDim2.new(1, 0, 1, 0)
        ClickClose.BackgroundTransparency = 1
        ClickClose.Text = ""
        ClickClose.Parent = Card

        local Closed = false
        local function Dismiss()
            if Closed or not Card.Parent then return end
            Closed = true
            local Out = Tween(Card, { GroupTransparency = 1 }, 0.18)
            Out.Completed:Connect(function()
                if Card then Card:Destroy() end
            end)
        end

        ClickClose.MouseButton1Click:Connect(Dismiss)

        Tween(Card, { GroupTransparency = 0 }, 0.2)
        Tween(TimerBar, { Size = UDim2.new(0, 0, 0, 2) }, Duration, Enum.EasingStyle.Linear)
        task.delay(Duration, Dismiss)
        return Card
    end

    function WindowHandler:Destroy()
        if Destroyed then return end
        Destroyed = true
        for Index, Listener in ipairs(SairyLib.ThemeChangeListeners) do
            if Listener == ThemeListener then
                table.remove(SairyLib.ThemeChangeListeners, Index)
                break
            end
        end
        for _, Conn in ipairs(Connections) do
            pcall(function() Conn:Disconnect() end)
        end
        table.clear(Connections)
        table.clear(ThemeBindings)
        table.clear(ThemeUpdaters)
        local WinIdx = table.find(SairyLib.ActiveWindows, ScreenGui)
        if WinIdx then
            table.remove(SairyLib.ActiveWindows, WinIdx)
        end
        if SairyLib.LatestWindow == WindowHandler then
            SairyLib.LatestWindow = nil
        end
        ScreenGui:Destroy()
    end

    -- =========================================================================
    -- Tab Builder
    -- =========================================================================
    function WindowHandler:Tab(TabConfig)
        TabConfig = TabConfig or {}
        local TabTitle = TabConfig.Title or "Tab"
        local TabDesc = TabConfig.Desc or TabConfig.Description or (TabTitle .. " settings and features.")
        local TabIconId = TabConfig.Icon or SairyAssets.DefaultTabIcon

        local TabButton = Instance.new("TextButton")
        TabButton.Name = TabTitle
        TabButton.Size = UDim2.new(1, 0, 0, 38)
        TabButton.BackgroundColor3 = SairyColors.CardBg
        TabButton.BackgroundTransparency = 1
        TabButton.BorderSizePixel = 0
        TabButton.Text = ""
        TabButton.AutoButtonColor = false
        TabButton.Parent = TabsScroll
        BindTheme(TabButton, "BackgroundColor3", "CardBg")

        local TabBtnCorner = Instance.new("UICorner")
        TabBtnCorner.CornerRadius = UDim.new(0, 8)
        TabBtnCorner.Parent = TabButton

        local TabBtnStroke = Instance.new("UIStroke")
        TabBtnStroke.Color = SairyColors.StrokeBorder
        TabBtnStroke.Thickness = 1
        TabBtnStroke.Transparency = 1
        TabBtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        TabBtnStroke.Parent = TabButton
        BindTheme(TabBtnStroke, "Color", "StrokeBorder")

        local TabIcon = Instance.new("ImageLabel")
        TabIcon.Size = UDim2.new(0, 16, 0, 16)
        TabIcon.Position = UDim2.new(0, 12, 0.5, 0)
        TabIcon.AnchorPoint = Vector2.new(0, 0.5)
        TabIcon.BackgroundTransparency = 1
        TabIcon.Image = TabIconId
        TabIcon.ImageColor3 = SairyColors.TextSecondary
        TabIcon.Parent = TabButton

        local TabLabel = Instance.new("TextLabel")
        TabLabel.Size = UDim2.new(1, -44, 1, 0)
        TabLabel.Position = UDim2.new(0, 36, 0, 0)
        TabLabel.BackgroundTransparency = 1
        TabLabel.Font = Enum.Font.BuilderSansMedium
        TabLabel.Text = TabTitle
        TabLabel.TextColor3 = SairyColors.TextSecondary
        TabLabel.TextSize = 14
        TabLabel.TextTruncate = Enum.TextTruncate.AtEnd
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabLabel.Parent = TabButton

        -- Tab Content Page
        local TabPage = Instance.new("Frame")
        TabPage.Name = TabTitle
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.BackgroundTransparency = 1
        TabPage.Visible = false
        TabPage.Parent = Content

        -- Tab Header Banner
        local TabHeader = Instance.new("Frame")
        TabHeader.Name = "SairyTabHeader"
        TabHeader.Size = UDim2.new(1, 0, 0, 60)
        TabHeader.BackgroundTransparency = 1
        TabHeader.Parent = TabPage

        local TabHeaderIcon = Instance.new("ImageLabel")
        TabHeaderIcon.Name = "Icon"
        TabHeaderIcon.Size = UDim2.new(0, 26, 0, 26)
        TabHeaderIcon.Position = UDim2.new(0, 17, 0, 17)
        TabHeaderIcon.BackgroundTransparency = 1
        TabHeaderIcon.Image = TabIconId
        TabHeaderIcon.ImageColor3 = SairyColors.TextPrimary
        TabHeaderIcon.Parent = TabHeader
        BindTheme(TabHeaderIcon, "ImageColor3", "TextPrimary")

        local TabHeaderTitle = Instance.new("TextLabel")
        TabHeaderTitle.Size = UDim2.new(1, -90, 0, 14)
        TabHeaderTitle.Position = UDim2.new(0, 54, 0, 17)
        TabHeaderTitle.BackgroundTransparency = 1
        TabHeaderTitle.Font = Enum.Font.GothamBold
        TabHeaderTitle.Text = TabTitle
        TabHeaderTitle.TextColor3 = SairyColors.TextPrimary
        TabHeaderTitle.TextSize = 14
        TabHeaderTitle.TextTruncate = Enum.TextTruncate.AtEnd
        TabHeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
        TabHeaderTitle.Parent = TabHeader
        BindTheme(TabHeaderTitle, "TextColor3", "TextPrimary")

        local TabHeaderDesc = Instance.new("TextLabel")
        TabHeaderDesc.Size = UDim2.new(1, -90, 0, 12)
        TabHeaderDesc.Position = UDim2.new(0, 54, 0, 33)
        TabHeaderDesc.BackgroundTransparency = 1
        TabHeaderDesc.Font = Enum.Font.Gotham
        TabHeaderDesc.Text = TabDesc
        TabHeaderDesc.TextColor3 = SairyColors.TextSecondary
        TabHeaderDesc.TextSize = 11
        TabHeaderDesc.TextTruncate = Enum.TextTruncate.AtEnd
        TabHeaderDesc.TextXAlignment = Enum.TextXAlignment.Left
        TabHeaderDesc.Parent = TabHeader
        BindTheme(TabHeaderDesc, "TextColor3", "TextSecondary")

        local TabHeaderDivider = Instance.new("Frame")
        TabHeaderDivider.Name = "Divider"
        TabHeaderDivider.Size = UDim2.new(1, 0, 0, 1)
        TabHeaderDivider.Position = UDim2.new(0, 0, 1, -1)
        TabHeaderDivider.BackgroundColor3 = SairyColors.StrokeBorder
        TabHeaderDivider.BorderSizePixel = 0
        TabHeaderDivider.Parent = TabHeader
        BindTheme(TabHeaderDivider, "BackgroundColor3", "StrokeBorder")

        -- Tab Content ScrollingFrame (Exact 24px side padding, 8px list padding)
        local PageScroll = Instance.new("ScrollingFrame")
        PageScroll.Name = "ScrollingFrame"
        PageScroll.Size = UDim2.new(1, 0, 1, -70)
        PageScroll.Position = UDim2.new(0, 0, 0, 70)
        PageScroll.BackgroundTransparency = 1
        PageScroll.BorderSizePixel = 0
        PageScroll.ScrollBarThickness = 2
        PageScroll.ScrollBarImageColor3 = SairyColors.Accent
        PageScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        PageScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        PageScroll.Parent = TabPage
        BindTheme(PageScroll, "ScrollBarImageColor3", "Accent")

        local PagePadding = Instance.new("UIPadding")
        PagePadding.PaddingTop = UDim.new(0, 2)
        PagePadding.PaddingBottom = UDim.new(0, 24)
        PagePadding.PaddingLeft = UDim.new(0, 24)
        PagePadding.PaddingRight = UDim.new(0, 24)
        PagePadding.Parent = PageScroll

        local ScrollLayout = Instance.new("UIListLayout")
        ScrollLayout.Padding = UDim.new(0, 8)
        ScrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ScrollLayout.Parent = PageScroll

        local TabRecord = {
            Button = TabButton,
            Page = TabPage,
            Stroke = TabBtnStroke,
            Label = TabLabel,
            Icon = TabIcon,
            Title = TabTitle
        }
        table.insert(WindowHandler.Tabs, TabRecord)

        AddThemeUpdater(function(Instant)
            local IsActive = (WindowHandler.ActiveTab == TabRecord)
            local LabelTarget = IsActive and SairyColors.TextPrimary or SairyColors.TextSecondary
            local IconTarget = IsActive and SairyColors.Accent or SairyColors.TextSecondary
            if Instant then
                TabLabel.TextColor3 = LabelTarget
                TabIcon.ImageColor3 = IconTarget
            else
                Tween(TabLabel, { TextColor3 = LabelTarget }, 0.16)
                Tween(TabIcon, { ImageColor3 = IconTarget }, 0.16)
            end
        end)

        -- Tab Button Hover Trick
        TabButton.MouseEnter:Connect(function()
            if WindowHandler.ActiveTab ~= TabRecord then
                Tween(TabButton, { BackgroundTransparency = 0.4 }, 0.14)
                Tween(TabLabel, { TextColor3 = SairyColors.TextPrimary }, 0.14)
            end
        end)
        TabButton.MouseLeave:Connect(function()
            if WindowHandler.ActiveTab ~= TabRecord then
                Tween(TabButton, { BackgroundTransparency = 1 }, 0.14)
                Tween(TabLabel, { TextColor3 = SairyColors.TextSecondary }, 0.14)
            end
        end)

        local function ActivateTab()
            if WindowHandler.ActiveTab == TabRecord then return end
            local PreviousTab = WindowHandler.ActiveTab
            WindowHandler.ActiveTab = TabRecord

            for _, Item in ipairs(WindowHandler.Tabs) do
                if Item ~= TabRecord then
                    Tween(Item.Button, { BackgroundTransparency = 1 }, 0.18)
                    Tween(Item.Stroke, { Transparency = 1 }, 0.18)
                    Tween(Item.Label, { TextColor3 = SairyColors.TextSecondary }, 0.18)
                    Tween(Item.Icon, { ImageColor3 = SairyColors.TextSecondary }, 0.18)
                end
            end

            Tween(TabButton, { BackgroundTransparency = 0 }, 0.18)
            Tween(TabBtnStroke, { Transparency = 0 }, 0.18)
            Tween(TabLabel, { TextColor3 = SairyColors.TextPrimary }, 0.18)
            Tween(TabIcon, { ImageColor3 = SairyColors.Accent }, 0.18)

            task.defer(function()
                UpdateIndicatorPosition(PreviousTab == nil)
            end)

            if not PreviousTab then
                TabPage.Visible = true
                return
            end

            -- Two-Layer CanvasGroup Crossfade + Slide Transition
            TransitionGen += 1
            local Gen = TransitionGen

            -- Settle any mid-flight previous transition pages back safely
            for _, Child in ipairs(TransitionOut:GetChildren()) do
                Child.Visible = false
                Child.Parent = Content
            end
            for _, Child in ipairs(TransitionIn:GetChildren()) do
                Child.Visible = false
                Child.Parent = Content
            end

            PreviousTab.Page.Parent = TransitionOut
            PreviousTab.Page.Visible = true
            TransitionOut.Visible = true
            TransitionOut.Position = UDim2.new(0, 0, 0, 0)
            TransitionOut.GroupTransparency = 0

            TabPage.Parent = TransitionIn
            TabPage.Visible = true
            TransitionIn.Visible = true
            TransitionIn.Position = UDim2.new(0, 0, 0, 10)
            TransitionIn.GroupTransparency = 1

            local OutTween = Tween(TransitionOut, { Position = UDim2.new(0, 0, 0, -10), GroupTransparency = 1 }, 0.15)
            local InTween = Tween(TransitionIn, { Position = UDim2.new(0, 0, 0, 0), GroupTransparency = 0 }, 0.20)

            OutTween.Completed:Connect(function()
                if TransitionGen == Gen and not Destroyed then
                    PreviousTab.Page.Visible = false
                    PreviousTab.Page.Parent = Content
                    TransitionOut.Visible = false
                end
            end)
            InTween.Completed:Connect(function()
                if TransitionGen == Gen and not Destroyed then
                    TabPage.Parent = Content
                    TabPage.Visible = true
                    TransitionIn.Visible = false
                end
            end)
        end

        TabButton.MouseButton1Click:Connect(ActivateTab)

        if #WindowHandler.Tabs == 1 then
            ActivateTab()
        end

        task.defer(UpdateScrollHint)

        local TabHandler = {
            Page = PageScroll
        }

        -- SairySection (Section Divider)
        function TabHandler:Section(SectionTitle)
            local SectionFrame = Instance.new("Frame")
            SectionFrame.Name = "SairySection"
            SectionFrame.Size = UDim2.new(1, 0, 0, 28)
            SectionFrame.BackgroundTransparency = 1
            SectionFrame.Parent = PageScroll

            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Name = "Title"
            TitleLabel.Size = UDim2.new(1, 0, 0, 20)
            TitleLabel.Position = UDim2.new(0, 2, 0, 8)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Font = Enum.Font.GothamMedium
            TitleLabel.Text = SectionTitle or "Section"
            TitleLabel.TextColor3 = SairyColors.TextSecondary
            BindTheme(TitleLabel, "TextColor3", "TextSecondary")
            TitleLabel.TextSize = 12
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.Parent = SectionFrame

            return SectionFrame
        end

        -- SairyLib Paragraph (Auto-Sizing Multi-Line Info Card)
        function TabHandler:Paragraph(ParagraphConfig)
            ParagraphConfig = ParagraphConfig or {}
            local Title = ParagraphConfig.Title or "Information"
            local BodyText = ParagraphConfig.Content or ParagraphConfig.Desc or ""

            local ParaCard = Instance.new("Frame")
            ParaCard.Name = Title
            ParaCard.Size = UDim2.new(1, 0, 0, 0)
            ParaCard.AutomaticSize = Enum.AutomaticSize.Y
            ParaCard.BackgroundColor3 = SairyColors.CardBg
            ParaCard.BorderSizePixel = 0
            ParaCard.Parent = PageScroll
            BindTheme(ParaCard, "BackgroundColor3", "CardBg")

            Instance.new("UICorner", ParaCard).CornerRadius = UDim.new(0, 8)
            local Stroke = Instance.new("UIStroke")
            Stroke.Color = SairyColors.StrokeBorder
            Stroke.Thickness = 1
            Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            Stroke.Parent = ParaCard
            BindTheme(Stroke, "Color", "StrokeBorder")

            local Pad = Instance.new("UIPadding")
            Pad.PaddingTop = UDim.new(0, 11)
            Pad.PaddingBottom = UDim.new(0, 12)
            Pad.PaddingLeft = UDim.new(0, 14)
            Pad.PaddingRight = UDim.new(0, 14)
            Pad.Parent = ParaCard

            local List = Instance.new("UIListLayout")
            List.Padding = UDim.new(0, 4)
            List.SortOrder = Enum.SortOrder.LayoutOrder
            List.Parent = ParaCard

            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Name = "Title"
            TitleLabel.Size = UDim2.new(1, 0, 0, 14)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Font = Enum.Font.BuilderSansMedium
            TitleLabel.Text = Title
            TitleLabel.TextColor3 = SairyColors.TextPrimary
            TitleLabel.TextSize = 14
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.LayoutOrder = 1
            TitleLabel.Parent = ParaCard
            BindTheme(TitleLabel, "TextColor3", "TextPrimary")

            local ContentLabel = Instance.new("TextLabel")
            ContentLabel.Name = "Content"
            ContentLabel.Size = UDim2.new(1, 0, 0, 0)
            ContentLabel.AutomaticSize = Enum.AutomaticSize.Y
            ContentLabel.BackgroundTransparency = 1
            ContentLabel.Font = Enum.Font.BuilderSans
            ContentLabel.Text = BodyText
            ContentLabel.TextColor3 = SairyColors.TextSecondary
            ContentLabel.TextSize = 13
            ContentLabel.TextWrapped = true
            ContentLabel.TextXAlignment = Enum.TextXAlignment.Left
            ContentLabel.LayoutOrder = 2
            ContentLabel.Parent = ParaCard
            BindTheme(ContentLabel, "TextColor3", "TextSecondary")

            return {
                Set = function(_, NewCfg)
                    if type(NewCfg) == "table" then
                        if NewCfg.Title then TitleLabel.Text = tostring(NewCfg.Title) end
                        if NewCfg.Content or NewCfg.Desc then
                            ContentLabel.Text = tostring(NewCfg.Content or NewCfg.Desc)
                        end
                    end
                end,
                Instance = ParaCard
            }
        end

        -- SairyLib Toggle (Authentic Card + Track Glow + Island Sync)
        function TabHandler:Toggle(ToggleConfig)
            ToggleConfig = ToggleConfig or {}
            local Title = ToggleConfig.Title or "Toggle"
            local Desc = ToggleConfig.Desc or ""
            local State = ToggleConfig.Default or false
            local Callback = ToggleConfig.Callback or function() end

            local ToggleCard = Instance.new("TextButton")
            ToggleCard.Name = Title
            ToggleCard.Size = UDim2.new(1, 0, 0, 70)
            ToggleCard.BackgroundColor3 = SairyColors.CardBg
            ToggleCard.BorderSizePixel = 0
            ToggleCard.Text = ""
            ToggleCard.AutoButtonColor = false
            ToggleCard.Parent = PageScroll
            BindTheme(ToggleCard, "BackgroundColor3", "CardBg")

            Instance.new("UICorner", ToggleCard).CornerRadius = UDim.new(0, 8)
            local CardStroke = Instance.new("UIStroke")
            CardStroke.Color = SairyColors.StrokeBorder
            CardStroke.Thickness = 1
            CardStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            CardStroke.Parent = ToggleCard
            BindTheme(CardStroke, "Color", "StrokeBorder")

            ApplyCardHover(ToggleCard, CardStroke)

            local CardTitle = Instance.new("TextLabel")
            CardTitle.Name = "Title"
            CardTitle.Size = UDim2.new(1, -80, 0, 18)
            CardTitle.Position = UDim2.new(0, 14, 0, 16)
            CardTitle.BackgroundTransparency = 1
            CardTitle.Font = Enum.Font.BuilderSansMedium
            CardTitle.Text = Title
            CardTitle.TextColor3 = SairyColors.TextPrimary
            CardTitle.TextSize = 14
            CardTitle.TextTruncate = Enum.TextTruncate.AtEnd
            CardTitle.TextXAlignment = Enum.TextXAlignment.Left
            CardTitle.Parent = ToggleCard
            BindTheme(CardTitle, "TextColor3", "TextPrimary")

            local CardDesc = Instance.new("TextLabel")
            CardDesc.Name = "Desc"
            CardDesc.Size = UDim2.new(1, -80, 0, 17)
            CardDesc.Position = UDim2.new(0, 14, 0, 36)
            CardDesc.BackgroundTransparency = 1
            CardDesc.Font = Enum.Font.BuilderSans
            CardDesc.Text = Desc
            CardDesc.TextColor3 = SairyColors.TextSecondary
            CardDesc.TextSize = 13
            CardDesc.TextTruncate = Enum.TextTruncate.AtEnd
            CardDesc.TextXAlignment = Enum.TextXAlignment.Left
            CardDesc.Parent = ToggleCard
            BindTheme(CardDesc, "TextColor3", "TextSecondary")

            local function GetKnobActiveColor()
                local AccentColor = SairyColors.Accent
                if (AccentColor.R + AccentColor.G + AccentColor.B) > 2.2 then
                    return SairyColors.AccentDarkText
                end
                return Color3.fromRGB(255, 255, 255)
            end

            -- Pill Switch Track
            local SwitchTrack = Instance.new("Frame")
            SwitchTrack.Name = "Track"
            SwitchTrack.Size = UDim2.new(0, 44, 0, 24)
            SwitchTrack.Position = UDim2.new(1, -14, 0.5, 0)
            SwitchTrack.AnchorPoint = Vector2.new(1, 0.5)
            SwitchTrack.BackgroundColor3 = State and SairyColors.Accent or SairyColors.MutedDark
            SwitchTrack.BorderSizePixel = 0
            SwitchTrack.Parent = ToggleCard
            Instance.new("UICorner", SwitchTrack).CornerRadius = UDim.new(1, 0)

            local TrackStroke = Instance.new("UIStroke")
            TrackStroke.Color = SairyColors.StrokeBorder
            TrackStroke.Thickness = 1
            TrackStroke.Parent = SwitchTrack
            BindTheme(TrackStroke, "Color", "StrokeBorder")

            local TrackGlow = Instance.new("ImageLabel")
            TrackGlow.Name = "Glow"
            TrackGlow.Size = UDim2.new(1, 24, 1, 24)
            TrackGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
            TrackGlow.AnchorPoint = Vector2.new(0.5, 0.5)
            TrackGlow.BackgroundTransparency = 1
            TrackGlow.Image = SairyAssets.ToggleGlow
            TrackGlow.ImageColor3 = SairyColors.Accent
            TrackGlow.ImageTransparency = State and 0.55 or 1
            TrackGlow.Parent = SwitchTrack
            BindTheme(TrackGlow, "ImageColor3", "Accent")

            local SwitchKnob = Instance.new("Frame")
            SwitchKnob.Name = "Knob"
            SwitchKnob.Size = UDim2.new(0, 18, 0, 18)
            SwitchKnob.Position = State and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
            SwitchKnob.AnchorPoint = Vector2.new(0, 0.5)
            SwitchKnob.BackgroundColor3 = State and GetKnobActiveColor() or SairyColors.TextSecondary
            SwitchKnob.BorderSizePixel = 0
            SwitchKnob.Parent = SwitchTrack
            Instance.new("UICorner", SwitchKnob).CornerRadius = UDim.new(1, 0)

            AddThemeUpdater(function(Instant)
                local TargetTrack = State and SairyColors.Accent or SairyColors.MutedDark
                local TargetKnob = State and GetKnobActiveColor() or SairyColors.TextSecondary
                if Instant then
                    SwitchTrack.BackgroundColor3 = TargetTrack
                    SwitchKnob.BackgroundColor3 = TargetKnob
                else
                    Tween(SwitchTrack, { BackgroundColor3 = TargetTrack }, 0.16)
                    Tween(SwitchKnob, { BackgroundColor3 = TargetKnob }, 0.16)
                end
            end)

            local function UpdateVisual(NewState)
                if NewState then
                    Tween(SwitchTrack, { BackgroundColor3 = SairyColors.Accent }, 0.18)
                    Tween(SwitchKnob, { Position = UDim2.new(1, -21, 0.5, 0), BackgroundColor3 = GetKnobActiveColor() }, 0.18, Enum.EasingStyle.Back)
                    Tween(TrackGlow, { ImageTransparency = 0.55 }, 0.22)
                else
                    Tween(SwitchTrack, { BackgroundColor3 = SairyColors.MutedDark }, 0.18)
                    Tween(SwitchKnob, { Position = UDim2.new(0, 3, 0.5, 0), BackgroundColor3 = SairyColors.TextSecondary }, 0.18)
                    Tween(TrackGlow, { ImageTransparency = 1 }, 0.18)
                end
            end

            local function SetState(NewState)
                State = NewState == true
                UpdateVisual(State)
                RefreshIslandActivities()
                SafeCallback(Callback, State)
            end

            table.insert(RegisteredToggles, {
                Title = Title,
                Desc = Desc,
                TabName = TabTitle,
                GetState = function() return State end,
                SetState = SetState
            })
            RefreshIslandActivities()

            if State then
                task.defer(SafeCallback, Callback, State)
            end

            ToggleCard.MouseButton1Click:Connect(function()
                SetState(not State)
            end)

            return {
                Set = SetState,
                Get = function() return State end,
                Instance = ToggleCard
            }
        end

        -- SairyLib Slider (Exact 88px Card + Click-to-Type Value Badge + Track Glow)
        function TabHandler:Slider(SliderConfig)
            SliderConfig = SliderConfig or {}
            local Title = SliderConfig.Title or "Slider"
            local Desc = SliderConfig.Desc or ""
            local Min = SliderConfig.Min or 0
            local Max = SliderConfig.Max or 100
            local Step = SliderConfig.Increment or SliderConfig.Step or 1
            local Suffix = SliderConfig.Suffix or ""
            local CurrentValue = math.clamp(SliderConfig.Default or Min, Min, Max)
            local Callback = SliderConfig.Callback or function() end

            local SliderCard = Instance.new("Frame")
            SliderCard.Name = Title
            SliderCard.Size = UDim2.new(1, 0, 0, 88)
            SliderCard.BackgroundColor3 = SairyColors.CardBg
            SliderCard.BorderSizePixel = 0
            SliderCard.Parent = PageScroll
            BindTheme(SliderCard, "BackgroundColor3", "CardBg")

            Instance.new("UICorner", SliderCard).CornerRadius = UDim.new(0, 8)
            local CardStroke = Instance.new("UIStroke")
            CardStroke.Color = SairyColors.StrokeBorder
            CardStroke.Thickness = 1
            CardStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            CardStroke.Parent = SliderCard
            BindTheme(CardStroke, "Color", "StrokeBorder")

            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Name = "Title"
            TitleLabel.Size = UDim2.new(1, -120, 0, 18)
            TitleLabel.Position = UDim2.new(0, 14, 0, 12)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Font = Enum.Font.BuilderSansMedium
            TitleLabel.Text = Title
            TitleLabel.TextColor3 = SairyColors.TextPrimary
            TitleLabel.TextSize = 14
            TitleLabel.TextTruncate = Enum.TextTruncate.AtEnd
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.Parent = SliderCard
            BindTheme(TitleLabel, "TextColor3", "TextPrimary")

            local DescLabel = Instance.new("TextLabel")
            DescLabel.Name = "Desc"
            DescLabel.Size = UDim2.new(1, -28, 0, 17)
            DescLabel.Position = UDim2.new(0, 14, 0, 31)
            DescLabel.BackgroundTransparency = 1
            DescLabel.Font = Enum.Font.BuilderSans
            DescLabel.Text = Desc
            DescLabel.TextColor3 = SairyColors.TextSecondary
            DescLabel.TextSize = 13
            DescLabel.TextTruncate = Enum.TextTruncate.AtEnd
            DescLabel.TextXAlignment = Enum.TextXAlignment.Left
            DescLabel.Parent = SliderCard
            BindTheme(DescLabel, "TextColor3", "TextSecondary")

            -- Value Badge with Click-to-Edit Inline Box
            local ValueBadge = Instance.new("Frame")
            ValueBadge.Size = UDim2.new(0, 36, 0, 24)
            ValueBadge.Position = UDim2.new(1, -10, 0, 9)
            ValueBadge.AnchorPoint = Vector2.new(1, 0)
            ValueBadge.BackgroundColor3 = SairyColors.InnerCardBg
            ValueBadge.BorderSizePixel = 0
            ValueBadge.Parent = SliderCard
            Instance.new("UICorner", ValueBadge).CornerRadius = UDim.new(0, 6)
            BindTheme(ValueBadge, "BackgroundColor3", "InnerCardBg")

            local BadgeStroke = Instance.new("UIStroke")
            BadgeStroke.Color = SairyColors.StrokeBorder
            BadgeStroke.Thickness = 1
            BadgeStroke.Parent = ValueBadge
            BindTheme(BadgeStroke, "Color", "StrokeBorder")

            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Size = UDim2.new(1, 0, 1, 0)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Font = Enum.Font.BuilderSansMedium
            ValueLabel.Text = tostring(CurrentValue) .. Suffix
            ValueLabel.TextColor3 = SairyColors.Accent
            ValueLabel.TextSize = 13
            ValueLabel.Parent = ValueBadge
            BindTheme(ValueLabel, "TextColor3", "Accent")

            local ValueBox = Instance.new("TextBox")
            ValueBox.Size = UDim2.new(1, -10, 1, 0)
            ValueBox.Position = UDim2.new(0, 5, 0, 0)
            ValueBox.BackgroundTransparency = 1
            ValueBox.Font = Enum.Font.BuilderSansMedium
            ValueBox.Text = ""
            ValueBox.TextColor3 = SairyColors.TextPrimary
            ValueBox.TextSize = 13
            ValueBox.Visible = false
            ValueBox.Parent = ValueBadge
            BindTheme(ValueBox, "TextColor3", "TextPrimary")

            local BadgeBtn = Instance.new("TextButton")
            BadgeBtn.Size = UDim2.new(1, 0, 1, 0)
            BadgeBtn.BackgroundTransparency = 1
            BadgeBtn.Text = ""
            BadgeBtn.Parent = ValueBadge

            -- Track Bar
            local Track = Instance.new("Frame")
            Track.Size = UDim2.new(1, -28, 0, 5)
            Track.Position = UDim2.new(0, 14, 0, 70)
            Track.BackgroundColor3 = SairyColors.MutedDark
            Track.BorderSizePixel = 0
            Track.Parent = SliderCard
            Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)
            BindTheme(Track, "BackgroundColor3", "MutedDark")

            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new(0, 0, 1, 0)
            Fill.BackgroundColor3 = SairyColors.Accent
            Fill.BorderSizePixel = 0
            Fill.Parent = Track
            Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
            BindTheme(Fill, "BackgroundColor3", "Accent")

            local SliderGlow = Instance.new("ImageLabel")
            SliderGlow.Size = UDim2.new(0, 28, 0, 28)
            SliderGlow.Position = UDim2.new(0, 0, 0.5, 0)
            SliderGlow.AnchorPoint = Vector2.new(0.5, 0.5)
            SliderGlow.BackgroundTransparency = 1
            SliderGlow.Image = SairyAssets.ToggleGlow
            SliderGlow.ImageColor3 = SairyColors.Accent
            SliderGlow.ImageTransparency = 0.85
            SliderGlow.Parent = Track
            BindTheme(SliderGlow, "ImageColor3", "Accent")

            local Knob = Instance.new("Frame")
            Knob.Size = UDim2.new(0, 12, 0, 12)
            Knob.Position = UDim2.new(0, 0, 0.5, 0)
            Knob.AnchorPoint = Vector2.new(0.5, 0.5)
            Knob.BackgroundColor3 = SairyColors.Accent
            Knob.BorderSizePixel = 0
            Knob.Parent = Track
            Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)
            BindTheme(Knob, "BackgroundColor3", "Accent")

            local HitArea = Instance.new("TextButton")
            HitArea.Size = UDim2.new(1, -16, 0, 40)
            HitArea.Position = UDim2.new(0, 8, 0, 51)
            HitArea.BackgroundTransparency = 1
            HitArea.Text = ""
            HitArea.AutoButtonColor = false
            HitArea.Parent = SliderCard

            ApplyCardHover(HitArea, CardStroke)

            local function RoundStep(Val)
                local Snapped = math.round((Val - Min) / Step) * Step + Min
                local Clamped = math.clamp(Snapped, Min, Max)
                if Step < 1 then
                    return math.round(Clamped * 1000) / 1000
                end
                return math.round(Clamped)
            end

            local function ApplyValue(NewVal, FireCallback)
                CurrentValue = RoundStep(NewVal)
                local Ratio = (Max > Min) and ((CurrentValue - Min) / (Max - Min)) or 0
                Tween(Fill, { Size = UDim2.new(Ratio, 0, 1, 0) }, 0.08)
                Tween(Knob, { Position = UDim2.new(Ratio, 0, 0.5, 0) }, 0.08)
                Tween(SliderGlow, { Position = UDim2.new(Ratio, 0, 0.5, 0) }, 0.08)

                local TextOut = tostring(CurrentValue) .. Suffix
                ValueLabel.Text = TextOut
                local BadgeW = math.max(36, #TextOut * 7 + 16)
                Tween(ValueBadge, { Size = UDim2.new(0, BadgeW, 0, 24) }, 0.1)

                if FireCallback then
                    SafeCallback(Callback, CurrentValue)
                end
            end

            ApplyValue(CurrentValue, false)

            local Dragging = false
            local function UpdateFromScreenX(ScreenX)
                local AbsWidth = math.max(Track.AbsoluteSize.X, 1)
                local Ratio = math.clamp((ScreenX - Track.AbsolutePosition.X) / AbsWidth, 0, 1)
                ApplyValue(Min + (Max - Min) * Ratio, true)
            end

            HitArea.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = true
                    Tween(SliderGlow, { ImageTransparency = 0.55 }, 0.12)
                    Tween(Knob, { Size = UDim2.new(0, 14, 0, 14) }, 0.12)
                    UpdateFromScreenX(Input.Position.X)
                    Input.Changed:Connect(function()
                        if Input.UserInputState == Enum.UserInputState.End then
                            Dragging = false
                            Tween(SliderGlow, { ImageTransparency = 0.85 }, 0.16)
                            Tween(Knob, { Size = UDim2.new(0, 12, 0, 12) }, 0.16)
                        end
                    end)
                end
            end)

            TrackConnection(UserInputService.InputChanged:Connect(function(Input)
                if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
                    UpdateFromScreenX(Input.Position.X)
                end
            end))

            BadgeBtn.MouseButton1Click:Connect(function()
                ValueLabel.Visible = false
                BadgeBtn.Visible = false
                ValueBox.Visible = true
                ValueBox.Text = tostring(CurrentValue)
                Tween(BadgeStroke, { Color = SairyColors.Accent }, 0.14)
                Tween(ValueBadge, { Size = UDim2.new(0, math.max(54, ValueBadge.Size.X.Offset), 0, 24) }, 0.14)
                ValueBox:CaptureFocus()
            end)

            ValueBox.FocusLost:Connect(function()
                ValueBox.Visible = false
                ValueLabel.Visible = true
                BadgeBtn.Visible = true
                Tween(BadgeStroke, { Color = SairyColors.StrokeBorder }, 0.14)
                local Parsed = tonumber(ValueBox.Text)
                if Parsed then
                    ApplyValue(Parsed, true)
                else
                    ApplyValue(CurrentValue, false)
                end
                ValueBox.Text = tostring(CurrentValue)
            end)

            return {
                Set = function(_, V) ApplyValue(V, true) end,
                Get = function() return CurrentValue end,
                Instance = SliderCard
            }
        end

        -- SairyLib Dropdown (Authentic Searchable Card)
        function TabHandler:Dropdown(DropdownConfig)
            DropdownConfig = DropdownConfig or {}
            local Title = DropdownConfig.Title or "Dropdown"
            local Desc = DropdownConfig.Desc or ""
            local Values = DropdownConfig.Values or {}
            local Multi = DropdownConfig.Multi == true
            local RawDefault = DropdownConfig.Default
            if RawDefault == nil then
                RawDefault = DropdownConfig.Value
            end
            local Selected
            if Multi then
                if type(RawDefault) == "table" then
                    Selected = table.clone(RawDefault)
                elseif RawDefault ~= nil then
                    Selected = { RawDefault }
                else
                    Selected = {}
                end
            else
                Selected = RawDefault ~= nil and RawDefault or Values[1]
            end
            local Callback = DropdownConfig.Callback or function() end
            local IsOpen = false

            local DropdownCard = Instance.new("Frame")
            DropdownCard.Name = Title
            DropdownCard.Size = UDim2.new(1, 0, 0, 70)
            DropdownCard.BackgroundColor3 = SairyColors.CardBg
            DropdownCard.BorderSizePixel = 0
            DropdownCard.ClipsDescendants = true
            DropdownCard.Parent = PageScroll
            BindTheme(DropdownCard, "BackgroundColor3", "CardBg")

            Instance.new("UICorner", DropdownCard).CornerRadius = UDim.new(0, 8)
            local CardStroke = Instance.new("UIStroke")
            CardStroke.Color = SairyColors.StrokeBorder
            CardStroke.Thickness = 1
            CardStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            CardStroke.Parent = DropdownCard
            BindTheme(CardStroke, "Color", "StrokeBorder")

            local HeaderBtn = Instance.new("TextButton")
            HeaderBtn.Name = "Header"
            HeaderBtn.Size = UDim2.new(1, 0, 0, 70)
            HeaderBtn.BackgroundTransparency = 1
            HeaderBtn.Text = ""
            HeaderBtn.AutoButtonColor = false
            HeaderBtn.Parent = DropdownCard

            ApplyCardHover(HeaderBtn, CardStroke)

            local CardTitle = Instance.new("TextLabel")
            CardTitle.Name = "Title"
            CardTitle.Size = UDim2.new(1, -152, 0, 18)
            CardTitle.Position = UDim2.new(0, 14, 0, 16)
            CardTitle.BackgroundTransparency = 1
            CardTitle.Font = Enum.Font.BuilderSansMedium
            CardTitle.Text = Title
            CardTitle.TextColor3 = SairyColors.TextPrimary
            CardTitle.TextSize = 14
            CardTitle.TextTruncate = Enum.TextTruncate.AtEnd
            CardTitle.TextXAlignment = Enum.TextXAlignment.Left
            CardTitle.Parent = HeaderBtn
            BindTheme(CardTitle, "TextColor3", "TextPrimary")

            local CardDesc = Instance.new("TextLabel")
            CardDesc.Name = "Desc"
            CardDesc.Size = UDim2.new(1, -152, 0, 17)
            CardDesc.Position = UDim2.new(0, 14, 0, 36)
            CardDesc.BackgroundTransparency = 1
            CardDesc.Font = Enum.Font.BuilderSans
            CardDesc.Text = Desc
            CardDesc.TextColor3 = SairyColors.TextSecondary
            CardDesc.TextSize = 13
            CardDesc.TextTruncate = Enum.TextTruncate.AtEnd
            CardDesc.TextXAlignment = Enum.TextXAlignment.Left
            CardDesc.Parent = HeaderBtn
            BindTheme(CardDesc, "TextColor3", "TextSecondary")

            -- Value Pill on Right
            local ValuePill = Instance.new("Frame")
            ValuePill.Name = "ValuePill"
            ValuePill.Size = UDim2.new(0, 120, 0, 34)
            ValuePill.Position = UDim2.new(1, -10, 0.5, 0)
            ValuePill.AnchorPoint = Vector2.new(1, 0.5)
            ValuePill.BackgroundColor3 = SairyColors.InnerCardBg
            ValuePill.BorderSizePixel = 0
            ValuePill.ClipsDescendants = true
            ValuePill.Parent = HeaderBtn
            Instance.new("UICorner", ValuePill).CornerRadius = UDim.new(0, 6)
            BindTheme(ValuePill, "BackgroundColor3", "InnerCardBg")

            local PillStroke = Instance.new("UIStroke")
            PillStroke.Color = SairyColors.StrokeBorder
            PillStroke.Thickness = 1
            PillStroke.Parent = ValuePill

            local ValueText = Instance.new("TextLabel")
            ValueText.Size = UDim2.new(1, -40, 1, 0)
            ValueText.Position = UDim2.new(0, 10, 0, 0)
            ValueText.BackgroundTransparency = 1
            ValueText.Font = Enum.Font.BuilderSansMedium
            ValueText.TextColor3 = SairyColors.TextSecondary
            ValueText.TextSize = 13
            ValueText.TextXAlignment = Enum.TextXAlignment.Left
            ValueText.TextTruncate = Enum.TextTruncate.AtEnd
            ValueText.Parent = ValuePill
            BindTheme(ValueText, "TextColor3", "TextSecondary")

            local Chevron = Instance.new("ImageLabel")
            Chevron.Size = UDim2.new(0, 16, 0, 16)
            Chevron.Position = UDim2.new(1, -10, 0.5, 0)
            Chevron.AnchorPoint = Vector2.new(1, 0.5)
            Chevron.BackgroundTransparency = 1
            Chevron.Image = SairyAssets.DropdownChevron
            Chevron.ImageColor3 = SairyColors.TextSecondary
            Chevron.Parent = ValuePill

            -- Search Box Inside Expanded Dropdown
            local DropSearchFrame = Instance.new("Frame")
            DropSearchFrame.Name = "SearchFrame"
            DropSearchFrame.Size = UDim2.new(1, -20, 0, 40)
            DropSearchFrame.Position = UDim2.new(0, 10, 0, 72)
            DropSearchFrame.BackgroundColor3 = SairyColors.InnerCardBg
            DropSearchFrame.BorderSizePixel = 0
            DropSearchFrame.Parent = DropdownCard
            Instance.new("UICorner", DropSearchFrame).CornerRadius = UDim.new(0, 6)
            BindTheme(DropSearchFrame, "BackgroundColor3", "InnerCardBg")

            local DropSearchIcon = Instance.new("ImageLabel")
            DropSearchIcon.Size = UDim2.new(0, 14, 0, 14)
            DropSearchIcon.Position = UDim2.new(0, 12, 0.5, 0)
            DropSearchIcon.AnchorPoint = Vector2.new(0, 0.5)
            DropSearchIcon.BackgroundTransparency = 1
            DropSearchIcon.Image = SairyAssets.SearchIcon
            DropSearchIcon.ImageColor3 = SairyColors.TextSecondary
            DropSearchIcon.Parent = DropSearchFrame
            BindTheme(DropSearchIcon, "ImageColor3", "TextSecondary")

            local DropSearchBox = Instance.new("TextBox")
            DropSearchBox.Size = UDim2.new(1, -44, 1, 0)
            DropSearchBox.Position = UDim2.new(0, 34, 0, 0)
            DropSearchBox.BackgroundTransparency = 1
            DropSearchBox.Font = Enum.Font.BuilderSans
            DropSearchBox.PlaceholderText = "Search"
            DropSearchBox.PlaceholderColor3 = SairyColors.TextSecondary
            DropSearchBox.Text = ""
            DropSearchBox.TextColor3 = SairyColors.TextPrimary
            DropSearchBox.TextSize = 13
            DropSearchBox.TextXAlignment = Enum.TextXAlignment.Left
            DropSearchBox.ClearTextOnFocus = false
            DropSearchBox.Parent = DropSearchFrame
            BindTheme(DropSearchBox, "PlaceholderColor3", "TextSecondary")
            BindTheme(DropSearchBox, "TextColor3", "TextPrimary")

            -- Dropdown Options List
            local ListScroll = Instance.new("ScrollingFrame")
            ListScroll.Name = "List"
            ListScroll.Size = UDim2.new(1, -20, 0, 140)
            ListScroll.Position = UDim2.new(0, 10, 0, 118)
            ListScroll.BackgroundTransparency = 1
            ListScroll.BorderSizePixel = 0
            ListScroll.ScrollBarThickness = 2
            ListScroll.ScrollBarImageColor3 = SairyColors.Accent
            ListScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
            ListScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
            ListScroll.Parent = DropdownCard
            BindTheme(ListScroll, "ScrollBarImageColor3", "Accent")

            local ListLayout = Instance.new("UIListLayout")
            ListLayout.Padding = UDim.new(0, 4)
            ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ListLayout.Parent = ListScroll

            local function FormatSelected()
                if Multi then
                    if type(Selected) == "table" and #Selected > 0 then
                        return table.concat(Selected, ", ")
                    end
                    return "None"
                end
                return tostring(Selected or "Select...")
            end
            ValueText.Text = FormatSelected()

            local VisibleItemCount = #Values
            local function GetExpandedHeight()
                local ListH = math.clamp(VisibleItemCount * 44, 44, 150)
                ListScroll.Size = UDim2.new(1, -20, 0, ListH)
                return 126 + ListH
            end

            local function ToggleDropdown()
                IsOpen = not IsOpen
                if IsOpen then
                    Tween(DropdownCard, { Size = UDim2.new(1, 0, 0, GetExpandedHeight()) }, 0.22)
                    Tween(Chevron, { Rotation = 180, ImageColor3 = SairyColors.Accent }, 0.2)
                    Tween(PillStroke, { Color = SairyColors.Accent }, 0.2)
                else
                    Tween(DropdownCard, { Size = UDim2.new(1, 0, 0, 70) }, 0.2)
                    Tween(Chevron, { Rotation = 0, ImageColor3 = SairyColors.TextSecondary }, 0.2)
                    Tween(PillStroke, { Color = SairyColors.StrokeBorder }, 0.2)
                end
            end

            HeaderBtn.MouseButton1Click:Connect(ToggleDropdown)

            local function IsItemSelected(TargetItem)
                if Multi then
                    return type(Selected) == "table" and table.find(Selected, TargetItem) ~= nil
                end
                return Selected == TargetItem
            end

            local ActiveOptionRecords = {}
            AddThemeUpdater(function(Instant)
                local BorderTarget = IsOpen and SairyColors.Accent or SairyColors.StrokeBorder
                local ChevronTarget = IsOpen and SairyColors.Accent or SairyColors.TextSecondary
                if Instant then
                    PillStroke.Color = BorderTarget
                    Chevron.ImageColor3 = ChevronTarget
                else
                    Tween(PillStroke, { Color = BorderTarget }, 0.16)
                    Tween(Chevron, { ImageColor3 = ChevronTarget }, 0.16)
                end
                for _, Record in ipairs(ActiveOptionRecords) do
                    local Sel = IsItemSelected(Record.Item)
                    local LblColor = Sel and SairyColors.TextPrimary or SairyColors.TextSecondary
                    if Instant then
                        Record.Btn.BackgroundColor3 = SairyColors.InnerCardBg
                        Record.Lbl.TextColor3 = LblColor
                        Record.Chk.ImageColor3 = SairyColors.Accent
                    else
                        Tween(Record.Btn, { BackgroundColor3 = SairyColors.InnerCardBg }, 0.16)
                        Tween(Record.Lbl, { TextColor3 = LblColor }, 0.16)
                        Tween(Record.Chk, { ImageColor3 = SairyColors.Accent }, 0.16)
                    end
                end
            end)

            local function RenderList(FilterText)
                FilterText = (FilterText or ""):lower()
                table.clear(ActiveOptionRecords)
                for _, Ch in ipairs(ListScroll:GetChildren()) do
                    if Ch:IsA("TextButton") then Ch:Destroy() end
                end

                VisibleItemCount = 0
                for _, Item in ipairs(Values) do
                    local ItemStr = tostring(Item)
                    if FilterText == "" or ItemStr:lower():find(FilterText, 1, true) then
                        VisibleItemCount += 1
                        local IsSelected = IsItemSelected(Item)

                        local ItemBtn = Instance.new("TextButton")
                        ItemBtn.Name = ItemStr
                        ItemBtn.Size = UDim2.new(1, 0, 0, 40)
                        ItemBtn.BackgroundColor3 = SairyColors.InnerCardBg
                        ItemBtn.BackgroundTransparency = IsSelected and 0 or 1
                        ItemBtn.BorderSizePixel = 0
                        ItemBtn.Text = ""
                        ItemBtn.AutoButtonColor = false
                        ItemBtn.Parent = ListScroll
                        Instance.new("UICorner", ItemBtn).CornerRadius = UDim.new(0, 6)

                        local ItemLabel = Instance.new("TextLabel")
                        ItemLabel.Name = "ItemLabel"
                        ItemLabel.Size = UDim2.new(1, -40, 1, 0)
                        ItemLabel.Position = UDim2.new(0, 12, 0, 0)
                        ItemLabel.BackgroundTransparency = 1
                        ItemLabel.Font = Enum.Font.BuilderSansMedium
                        ItemLabel.Text = ItemStr
                        ItemLabel.TextColor3 = IsSelected and SairyColors.TextPrimary or SairyColors.TextSecondary
                        ItemLabel.TextSize = 13
                        ItemLabel.TextTruncate = Enum.TextTruncate.AtEnd
                        ItemLabel.TextXAlignment = Enum.TextXAlignment.Left
                        ItemLabel.Parent = ItemBtn

                        local Check = Instance.new("ImageLabel")
                        Check.Name = "Check"
                        Check.Size = UDim2.new(0, 14, 0, 14)
                        Check.Position = UDim2.new(1, -12, 0.5, 0)
                        Check.AnchorPoint = Vector2.new(1, 0.5)
                        Check.BackgroundTransparency = 1
                        Check.Image = SairyAssets.Checkmark
                        Check.ImageColor3 = SairyColors.Accent
                        Check.ImageTransparency = IsSelected and 0 or 1
                        Check.Parent = ItemBtn

                        table.insert(ActiveOptionRecords, {
                            Item = Item,
                            Btn = ItemBtn,
                            Lbl = ItemLabel,
                            Chk = Check
                        })

                        ItemBtn.MouseEnter:Connect(function()
                            Tween(ItemBtn, { BackgroundTransparency = 0 }, 0.12)
                            Tween(ItemLabel, { TextColor3 = SairyColors.TextPrimary }, 0.12)
                        end)
                        ItemBtn.MouseLeave:Connect(function()
                            local NowSelected = IsItemSelected(Item)
                            Tween(ItemBtn, { BackgroundTransparency = NowSelected and 0 or 1 }, 0.12)
                            Tween(ItemLabel, { TextColor3 = NowSelected and SairyColors.TextPrimary or SairyColors.TextSecondary }, 0.12)
                        end)

                        ItemBtn.MouseButton1Click:Connect(function()
                            if Multi then
                                local FoundIdx = table.find(Selected, Item)
                                local NowSelected
                                if FoundIdx then
                                    table.remove(Selected, FoundIdx)
                                    NowSelected = false
                                else
                                    table.insert(Selected, Item)
                                    NowSelected = true
                                end
                                Tween(Check, { ImageTransparency = NowSelected and 0 or 1 }, 0.12)
                                Tween(ItemBtn, { BackgroundTransparency = NowSelected and 0 or 1 }, 0.12)
                                Tween(ItemLabel, { TextColor3 = NowSelected and SairyColors.TextPrimary or SairyColors.TextSecondary }, 0.12)
                                ValueText.Text = FormatSelected()
                                SafeCallback(Callback, table.clone(Selected))
                            else
                                Selected = Item
                                ToggleDropdown()
                                RenderList(DropSearchBox.Text)
                                ValueText.Text = FormatSelected()
                                SafeCallback(Callback, Selected)
                            end
                        end)
                    end
                end

                if IsOpen then
                    Tween(DropdownCard, { Size = UDim2.new(1, 0, 0, GetExpandedHeight()) }, 0.15)
                end
            end

            RenderList()
            DropSearchBox:GetPropertyChangedSignal("Text"):Connect(function()
                RenderList(DropSearchBox.Text)
            end)

            return {
                Set = function(_, NewVal)
                    if Multi then
                        if type(NewVal) == "table" then
                            Selected = table.clone(NewVal)
                        elseif NewVal ~= nil then
                            Selected = { NewVal }
                        else
                            Selected = {}
                        end
                    else
                        Selected = NewVal
                    end
                    ValueText.Text = FormatSelected()
                    RenderList(DropSearchBox.Text)
                    SafeCallback(Callback, Multi and table.clone(Selected) or Selected)
                end,
                Refresh = function(_, NewVals)
                    Values = NewVals or {}
                    RenderList(DropSearchBox.Text)
                end,
                Get = function()
                    return Multi and table.clone(Selected) or Selected
                end,
                Instance = DropdownCard
            }
        end

        -- SairyLib Input Card (Card with Input Box)
        function TabHandler:Input(InputConfig)
            InputConfig = InputConfig or {}
            local Title = InputConfig.Title or "Input"
            local Desc = InputConfig.Desc or ""
            local Default = tostring(InputConfig.Default or "")
            local Placeholder = InputConfig.Placeholder or "Enter value..."
            local Callback = InputConfig.Callback or function() end

            local InputCard = Instance.new("Frame")
            InputCard.Name = Title
            InputCard.Size = UDim2.new(1, 0, 0, 70)
            InputCard.BackgroundColor3 = SairyColors.CardBg
            InputCard.BorderSizePixel = 0
            InputCard.Parent = PageScroll
            BindTheme(InputCard, "BackgroundColor3", "CardBg")

            Instance.new("UICorner", InputCard).CornerRadius = UDim.new(0, 8)
            local Stroke = Instance.new("UIStroke")
            Stroke.Color = SairyColors.StrokeBorder
            Stroke.Thickness = 1
            Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            Stroke.Parent = InputCard
            BindTheme(Stroke, "Color", "StrokeBorder")

            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Name = "Title"
            TitleLabel.Size = UDim2.new(1, -132, 0, 18)
            TitleLabel.Position = UDim2.new(0, 14, 0, 16)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Font = Enum.Font.BuilderSansMedium
            TitleLabel.Text = Title
            TitleLabel.TextColor3 = SairyColors.TextPrimary
            TitleLabel.TextSize = 14
            TitleLabel.TextTruncate = Enum.TextTruncate.AtEnd
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.Parent = InputCard
            BindTheme(TitleLabel, "TextColor3", "TextPrimary")

            local DescLabel = Instance.new("TextLabel")
            DescLabel.Name = "Desc"
            DescLabel.Size = UDim2.new(1, -132, 0, 17)
            DescLabel.Position = UDim2.new(0, 14, 0, 36)
            DescLabel.BackgroundTransparency = 1
            DescLabel.Font = Enum.Font.BuilderSans
            DescLabel.Text = Desc
            DescLabel.TextColor3 = SairyColors.TextSecondary
            DescLabel.TextSize = 13
            DescLabel.TextTruncate = Enum.TextTruncate.AtEnd
            DescLabel.TextXAlignment = Enum.TextXAlignment.Left
            DescLabel.Parent = InputCard
            BindTheme(DescLabel, "TextColor3", "TextSecondary")

            local BoxHolder = Instance.new("Frame")
            BoxHolder.Name = "BoxHolder"
            BoxHolder.Size = UDim2.new(0, 100, 0, 32)
            BoxHolder.Position = UDim2.new(1, -10, 0.5, 0)
            BoxHolder.AnchorPoint = Vector2.new(1, 0.5)
            BoxHolder.BackgroundColor3 = SairyColors.InnerCardBg
            BoxHolder.BorderSizePixel = 0
            BoxHolder.Parent = InputCard
            Instance.new("UICorner", BoxHolder).CornerRadius = UDim.new(0, 6)
            BindTheme(BoxHolder, "BackgroundColor3", "InnerCardBg")

            local BoxStroke = Instance.new("UIStroke")
            BoxStroke.Color = SairyColors.StrokeBorder
            BoxStroke.Thickness = 1
            BoxStroke.Parent = BoxHolder
            BindTheme(BoxStroke, "Color", "StrokeBorder")

            local TextBox = Instance.new("TextBox")
            TextBox.Size = UDim2.new(1, -16, 1, 0)
            TextBox.Position = UDim2.new(0, 8, 0, 0)
            TextBox.BackgroundTransparency = 1
            TextBox.Font = Enum.Font.BuilderSans
            TextBox.PlaceholderText = Placeholder
            TextBox.PlaceholderColor3 = SairyColors.TextSecondary
            TextBox.Text = Default
            TextBox.TextColor3 = SairyColors.TextPrimary
            TextBox.TextSize = 13
            TextBox.ClearTextOnFocus = false
            TextBox.Parent = BoxHolder
            BindTheme(TextBox, "PlaceholderColor3", "TextSecondary")
            BindTheme(TextBox, "TextColor3", "TextPrimary")

            TextBox.Focused:Connect(function()
                Tween(BoxStroke, { Color = SairyColors.Accent }, 0.14)
            end)
            TextBox.FocusLost:Connect(function(EnterPressed)
                Tween(BoxStroke, { Color = SairyColors.StrokeBorder }, 0.14)
                SafeCallback(Callback, TextBox.Text, EnterPressed)
            end)

            return {
                Set = function(_, Txt)
                    TextBox.Text = tostring(Txt)
                    SafeCallback(Callback, TextBox.Text, true)
                end,
                Get = function() return TextBox.Text end
            }
        end

        -- SairyLib Keybind Card
        function TabHandler:Keybind(KeybindConfig)
            KeybindConfig = KeybindConfig or {}
            local Title = KeybindConfig.Title or "Keybind"
            local Desc = KeybindConfig.Desc or ""
            local CurrentKey = KeybindConfig.Default or Enum.KeyCode.RightControl
            local Callback = KeybindConfig.Callback or function() end

            local KeyCard = Instance.new("Frame")
            KeyCard.Name = Title
            KeyCard.Size = UDim2.new(1, 0, 0, 70)
            KeyCard.BackgroundColor3 = SairyColors.CardBg
            KeyCard.BorderSizePixel = 0
            KeyCard.Parent = PageScroll
            BindTheme(KeyCard, "BackgroundColor3", "CardBg")

            Instance.new("UICorner", KeyCard).CornerRadius = UDim.new(0, 8)
            local Stroke = Instance.new("UIStroke")
            Stroke.Color = SairyColors.StrokeBorder
            Stroke.Thickness = 1
            Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            Stroke.Parent = KeyCard
            BindTheme(Stroke, "Color", "StrokeBorder")

            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Name = "Title"
            TitleLabel.Size = UDim2.new(1, -120, 0, 18)
            TitleLabel.Position = UDim2.new(0, 14, 0, 16)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Font = Enum.Font.BuilderSansMedium
            TitleLabel.Text = Title
            TitleLabel.TextColor3 = SairyColors.TextPrimary
            TitleLabel.TextSize = 14
            TitleLabel.TextTruncate = Enum.TextTruncate.AtEnd
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.Parent = KeyCard
            BindTheme(TitleLabel, "TextColor3", "TextPrimary")

            local DescLabel = Instance.new("TextLabel")
            DescLabel.Name = "Desc"
            DescLabel.Size = UDim2.new(1, -120, 0, 17)
            DescLabel.Position = UDim2.new(0, 14, 0, 36)
            DescLabel.BackgroundTransparency = 1
            DescLabel.Font = Enum.Font.BuilderSans
            DescLabel.Text = Desc
            DescLabel.TextColor3 = SairyColors.TextSecondary
            DescLabel.TextSize = 13
            DescLabel.TextTruncate = Enum.TextTruncate.AtEnd
            DescLabel.TextXAlignment = Enum.TextXAlignment.Left
            DescLabel.Parent = KeyCard
            BindTheme(DescLabel, "TextColor3", "TextSecondary")

            local KeyPill = Instance.new("TextButton")
            KeyPill.Name = "KeyPill"
            KeyPill.Size = UDim2.new(0, 72, 0, 30)
            KeyPill.Position = UDim2.new(1, -10, 0.5, 0)
            KeyPill.AnchorPoint = Vector2.new(1, 0.5)
            KeyPill.BackgroundColor3 = SairyColors.InnerCardBg
            KeyPill.BorderSizePixel = 0
            KeyPill.Font = Enum.Font.BuilderSansMedium
            KeyPill.Text = FormatKeyName(CurrentKey)
            KeyPill.TextColor3 = SairyColors.Accent
            KeyPill.TextSize = 12
            KeyPill.AutoButtonColor = false
            KeyPill.Parent = KeyCard
            Instance.new("UICorner", KeyPill).CornerRadius = UDim.new(0, 6)
            BindTheme(KeyPill, "BackgroundColor3", "InnerCardBg")
            BindTheme(KeyPill, "TextColor3", "Accent")

            local KeyStroke = Instance.new("UIStroke")
            KeyStroke.Color = SairyColors.StrokeBorder
            KeyStroke.Thickness = 1
            KeyStroke.Parent = KeyPill
            BindTheme(KeyStroke, "Color", "StrokeBorder")

            local Listening = false
            KeyPill.MouseButton1Click:Connect(function()
                if Listening then return end
                Listening = true
                KeyPill.Text = "..."
                Tween(KeyStroke, { Color = SairyColors.Accent }, 0.12)
            end)

            TrackConnection(UserInputService.InputBegan:Connect(function(Input)
                if Listening and Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode ~= Enum.KeyCode.Unknown then
                    Listening = false
                    CurrentKey = Input.KeyCode
                    KeyPill.Text = FormatKeyName(CurrentKey)
                    Tween(KeyStroke, { Color = SairyColors.StrokeBorder }, 0.14)
                    SafeCallback(Callback, CurrentKey)
                end
            end))

            return {
                Set = function(_, NewKey)
                    CurrentKey = NewKey
                    KeyPill.Text = FormatKeyName(NewKey)
                    SafeCallback(Callback, CurrentKey)
                end,
                Get = function() return CurrentKey end
            }
        end

        -- SairyLib Button (Exact Authentic Card + Clean 16x16 Right Icon + Click Flash)
        function TabHandler:Button(ButtonConfig)
            ButtonConfig = ButtonConfig or {}
            local Title = ButtonConfig.Title or "Button"
            local Desc = ButtonConfig.Desc or ""
            local IconId = ButtonConfig.Icon or SairyAssets.ActionArrow
            local Callback = ButtonConfig.Callback or function() end

            local ButtonCard = Instance.new("TextButton")
            ButtonCard.Name = Title
            ButtonCard.Size = UDim2.new(1, 0, 0, 70)
            ButtonCard.BackgroundColor3 = SairyColors.CardBg
            ButtonCard.BorderSizePixel = 0
            ButtonCard.Text = ""
            ButtonCard.AutoButtonColor = false
            ButtonCard.Parent = PageScroll
            BindTheme(ButtonCard, "BackgroundColor3", "CardBg")

            Instance.new("UICorner", ButtonCard).CornerRadius = UDim.new(0, 8)
            local Stroke = Instance.new("UIStroke")
            Stroke.Color = SairyColors.StrokeBorder
            Stroke.Thickness = 1
            Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            Stroke.Parent = ButtonCard
            BindTheme(Stroke, "Color", "StrokeBorder")

            local CardScale = Instance.new("UIScale", ButtonCard)
            ApplyCardHover(ButtonCard, Stroke)

            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Name = "Title"
            TitleLabel.Size = UDim2.new(1, -52, 0, 18)
            TitleLabel.Position = UDim2.new(0, 14, 0, 16)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Font = Enum.Font.BuilderSansMedium
            TitleLabel.Text = Title
            TitleLabel.TextColor3 = SairyColors.TextPrimary
            TitleLabel.TextSize = 14
            TitleLabel.TextTruncate = Enum.TextTruncate.AtEnd
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.Parent = ButtonCard
            BindTheme(TitleLabel, "TextColor3", "TextPrimary")

            local DescLabel = Instance.new("TextLabel")
            DescLabel.Name = "Desc"
            DescLabel.Size = UDim2.new(1, -52, 0, 17)
            DescLabel.Position = UDim2.new(0, 14, 0, 36)
            DescLabel.BackgroundTransparency = 1
            DescLabel.Font = Enum.Font.BuilderSans
            DescLabel.Text = Desc
            DescLabel.TextColor3 = SairyColors.TextSecondary
            DescLabel.TextSize = 13
            DescLabel.TextTruncate = Enum.TextTruncate.AtEnd
            DescLabel.TextXAlignment = Enum.TextXAlignment.Left
            DescLabel.Parent = ButtonCard
            BindTheme(DescLabel, "TextColor3", "TextSecondary")

            local IconHolder = Instance.new("Frame")
            IconHolder.Name = "IconHolder"
            IconHolder.Size = UDim2.new(0, 16, 0, 16)
            IconHolder.Position = UDim2.new(1, -30, 0.5, 0)
            IconHolder.AnchorPoint = Vector2.new(0, 0.5)
            IconHolder.BackgroundTransparency = 1
            IconHolder.Parent = ButtonCard

            local ActionIcon = Instance.new("ImageLabel")
            ActionIcon.Size = UDim2.new(1, 0, 1, 0)
            ActionIcon.BackgroundTransparency = 1
            ActionIcon.Image = IconId
            ActionIcon.ImageColor3 = SairyColors.TextSecondary
            ActionIcon.ScaleType = Enum.ScaleType.Fit
            ActionIcon.Parent = IconHolder
            BindTheme(ActionIcon, "ImageColor3", "TextSecondary")

            ButtonCard.MouseEnter:Connect(function()
                Tween(ActionIcon, { ImageColor3 = SairyColors.Accent }, 0.14)
            end)
            ButtonCard.MouseLeave:Connect(function()
                Tween(ActionIcon, { ImageColor3 = SairyColors.TextSecondary }, 0.14)
            end)

            ButtonCard.MouseButton1Click:Connect(function()
                Tween(CardScale, { Scale = 0.985 }, 0.07)
                Tween(ActionIcon, { ImageColor3 = Color3.fromRGB(255, 255, 255) }, 0.07)
                task.delay(0.08, function()
                    if not Destroyed then
                        Tween(CardScale, { Scale = 1 }, 0.14, Enum.EasingStyle.Back)
                        Tween(ActionIcon, { ImageColor3 = SairyColors.Accent }, 0.14)
                    end
                end)
                SafeCallback(Callback)
            end)

            return ButtonCard
        end

        return TabHandler
    end

    SairyLib.LatestWindow = WindowHandler
    return WindowHandler
end

function SairyLib:Notify(NotifyConfig)
    if SairyLib.LatestWindow and SairyLib.LatestWindow.Notify then
        return SairyLib.LatestWindow:Notify(NotifyConfig)
    end
    return nil
end

if getgenv then
    local Old = getgenv().SairyLib
    if Old and Old.LatestWindow then
        pcall(function() Old.LatestWindow:Destroy() end)
    end
    getgenv().SairyLib = SairyLib
end

return SairyLib
