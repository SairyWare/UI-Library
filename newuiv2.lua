-- ============================================================ --
--  GAG2 UI LIBRARY  (ModuleScript: GAG2_UILib)                 --
-- ============================================================ --
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players          = game:GetService("Players")
local LP               = Players.LocalPlayer

local UILib = {}
UILib.__index = UILib

local C = {
	ACCENT  = Color3.fromRGB(126, 217, 87),
	ACCENT2 = Color3.fromRGB(88,  180, 120),
	BG      = Color3.fromRGB(20,  22,  27),
	BG2     = Color3.fromRGB(28,  31,  38),
	CARD    = Color3.fromRGB(34,  38,  46),
	STROKE  = Color3.fromRGB(52,  58,  68),
	TXT     = Color3.fromRGB(235, 238, 242),
	SUB     = Color3.fromRGB(150, 158, 168),
	RED     = Color3.fromRGB(220, 80,  80),
	KNOB    = Color3.fromRGB(235, 238, 242),
}

-- ================================================================== HELPERS

local function Corner( _Parent, _Radius )
	local _C = Instance.new("UICorner")
	_C.CornerRadius = UDim.new(0, _Radius or 8)
	_C.Parent = _Parent
	return _C
end

local function Stroke( _Parent, _Color, _Thickness )
	local _S = Instance.new("UIStroke")
	_S.Color = _Color or C.STROKE
	_S.Thickness = _Thickness or 1
	_S.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	_S.Parent = _Parent
	return _S
end

local function Pad( _Parent, _Size )
	local _U = Instance.new("UIPadding")
	_U.PaddingLeft   = UDim.new(0, _Size)
	_U.PaddingRight  = UDim.new(0, _Size)
	_U.PaddingTop    = UDim.new(0, _Size)
	_U.PaddingBottom = UDim.new(0, _Size)
	_U.Parent = _Parent
	return _U
end

local function ListLayout( _Parent, _Padding )
	local _L = Instance.new("UIListLayout")
	_L.SortOrder = Enum.SortOrder.LayoutOrder
	_L.Padding   = UDim.new(0, _Padding or 8)
	_L.Parent    = _Parent
	return _L
end

local function AutoCanvas( _Scroll, _Layout )
	_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		_Scroll.CanvasSize = UDim2.new(0, 0, 0, _Layout.AbsoluteContentSize.Y + 12)
	end)
end

local function ScrollFrame( _Parent )
	local _S = Instance.new("ScrollingFrame")
	_S.BackgroundTransparency = 1
	_S.BorderSizePixel        = 0
	_S.ScrollBarThickness     = 4
	_S.ScrollBarImageColor3   = C.STROKE
	_S.CanvasSize             = UDim2.new()
	_S.Parent                 = _Parent
	return _S
end

-- ================================================================== CONFIG

local CFG_KEY = "__GAG2HUB_CFG"
_G[CFG_KEY] = _G[CFG_KEY] or {}
local Cfg = _G[CFG_KEY]

local DefaultSave = {
	enabled = true,
	Folder  = "GAG2Hub",
	File    = "Config",
}

local function GetFilePath( _SS )
	return _SS.Folder .. "/" .. _SS.File .. ".json"
end

local function EnsureFolder( _SS )
	if not isfolder(_SS.Folder) then
		makefolder(_SS.Folder)
	end
end

local function EncodeJSON( _Table )
	local _Parts = {}
	for _K, _V in pairs(_Table) do
		local _Val
		if type(_V) == "boolean" then
			_Val = _V and "true" or "false"
		elseif type(_V) == "number" then
			_Val = tostring(_V)
		else
			_Val = '"' .. tostring(_V):gsub('"', '\\"') .. '"'
		end
		_Parts[#_Parts + 1] = '"' .. tostring(_K):gsub('"', '\\"') .. '":' .. _Val
	end
	return "{" .. table.concat(_Parts, ",") .. "}"
end

local function DecodeJSON( _Str )
	local _T = {}
	for _K, _V in _Str:gmatch('"([^"]+)"%s*:%s*([^,}]+)') do
		_V = _V:match("^%s*(.-)%s*$")
		if _V == "true" then
			_T[_K] = true
		elseif _V == "false" then
			_T[_K] = false
		elseif tonumber(_V) then
			_T[_K] = tonumber(_V)
		else
			_T[_K] = _V:match('^"(.*)"$') or _V
		end
	end
	return _T
end

local function LoadFromFile( _SS )
	if not _SS.enabled then return end
	local _Path = GetFilePath(_SS)
	local _Ok, _Data = pcall(function()
		if isfile(_Path) then
			return DecodeJSON(readfile(_Path))
		end
	end)
	if not (_Ok and _Data) then return end
	for _K, _V in pairs(_Data) do
		Cfg[_K] = _V
	end
end

local function SaveToFile( _SS )
	if not _SS.enabled then return end
	pcall(function()
		EnsureFolder(_SS)
		writefile(GetFilePath(_SS), EncodeJSON(Cfg))
	end)
end

local function CfgGet( _Key, _Default )
	if Cfg[_Key] == nil then Cfg[_Key] = _Default end
	return Cfg[_Key]
end

local function CfgSet( _Key, _Val, _SS )
	Cfg[_Key] = _Val
	if _SS then SaveToFile(_SS) end
end

-- ================================================================== GUI ROOT

local function GetParentGui( )
	local _G2
	local _Ok = pcall(function() _G2 = gethui and gethui() end)
	if _Ok and _G2 then return _G2 end
	_Ok = pcall(function() _G2 = game:GetService("CoreGui") end)
	if _Ok and _G2 then return _G2 end
	return LP:WaitForChild("PlayerGui")
end

-- ================================================================== WINDOW

function UILib.newWindow( _Title, _Subtitle, _SaveSetting )
	local self   = setmetatable({}, UILib)
	self._tabs   = {}
	self._pages  = {}
	self._lo     = 0

	local _SS = {}
	for _K, _V in pairs(DefaultSave) do _SS[_K] = _V end
	if _SaveSetting then
		for _K, _V in pairs(_SaveSetting) do _SS[_K] = _V end
	end
	self._ss = _SS

	LoadFromFile(_SS)

	local _Old = GetParentGui():FindFirstChild("GAG2Hub")
	if _Old then _Old:Destroy() end

	local _Gui = Instance.new("ScreenGui")
	_Gui.Name           = "GAG2Hub"
	_Gui.ResetOnSpawn   = false
	_Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	_Gui.IgnoreGuiInset = true
	_Gui.Parent         = GetParentGui()
	self._gui = _Gui

	local function CalcSize( )
		local _VP = workspace.CurrentCamera.ViewportSize
		local _W  = math.min(500, _VP.X - 16)
		local _H  = math.min(420, _VP.Y - 16)
		return UDim2.fromOffset(_W, _H), UDim2.new(0.5, -_W/2, 0.5, -_H/2)
	end

	local _Main = Instance.new("Frame")
	_Main.Name             = "Main"
	_Main.BackgroundColor3 = C.BG
	_Main.BorderSizePixel  = 0
	_Main.Parent           = _Gui
	Corner(_Main, 12)
	Stroke(_Main, C.STROKE, 1)
	self._main = _Main

	local function ApplySize( )
		local _Sz, _Pos = CalcSize()
		_Main.Size     = _Sz
		_Main.Position = _Pos
	end
	ApplySize()
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(ApplySize)

	-- ── title bar ──────────────────────────────────────────────
	local _Bar = Instance.new("Frame")
	_Bar.Size             = UDim2.new(1, 0, 0, 46)
	_Bar.BackgroundColor3 = C.BG2
	_Bar.BorderSizePixel  = 0
	_Bar.Parent           = _Main
	Corner(_Bar, 12)

	local _BarFix = Instance.new("Frame")
	_BarFix.Size             = UDim2.new(1, 0, 0, 14)
	_BarFix.Position         = UDim2.new(0, 0, 1, -14)
	_BarFix.BackgroundColor3 = C.BG2
	_BarFix.BorderSizePixel  = 0
	_BarFix.Parent           = _Bar

	local _Dot = Instance.new("Frame")
	_Dot.Size             = UDim2.fromOffset(12, 12)
	_Dot.Position         = UDim2.fromOffset(16, 17)
	_Dot.BackgroundColor3 = C.ACCENT
	_Dot.BorderSizePixel  = 0
	_Dot.Parent           = _Bar
	Corner(_Dot, 6)

	local _TitleLbl = Instance.new("TextLabel")
	_TitleLbl.BackgroundTransparency = 1
	_TitleLbl.Position               = UDim2.fromOffset(38, 7)
	_TitleLbl.Size                   = UDim2.new(1, -120, 0, 20)
	_TitleLbl.Font                   = Enum.Font.GothamBold
	_TitleLbl.Text                   = _Title or "Hub"
	_TitleLbl.TextSize               = 15
	_TitleLbl.TextColor3             = C.TXT
	_TitleLbl.TextXAlignment         = Enum.TextXAlignment.Left
	_TitleLbl.Parent                 = _Bar

	local _SubLbl = Instance.new("TextLabel")
	_SubLbl.BackgroundTransparency = 1
	_SubLbl.Position               = UDim2.fromOffset(38, 25)
	_SubLbl.Size                   = UDim2.new(1, -120, 0, 14)
	_SubLbl.Font                   = Enum.Font.Gotham
	_SubLbl.Text                   = _Subtitle or "INSERT to hide"
	_SubLbl.TextSize               = 11
	_SubLbl.TextColor3             = C.SUB
	_SubLbl.TextXAlignment         = Enum.TextXAlignment.Left
	_SubLbl.Parent                 = _Bar

	-- ── close button ───────────────────────────────────────────
	local _CloseBtn = Instance.new("TextButton")
	_CloseBtn.AnchorPoint      = Vector2.new(1, 0.5)
	_CloseBtn.Position         = UDim2.new(1, -12, 0.5, 0)
	_CloseBtn.Size             = UDim2.fromOffset(26, 26)
	_CloseBtn.BackgroundColor3 = C.RED
	_CloseBtn.Text             = "×"
	_CloseBtn.Font             = Enum.Font.GothamBold
	_CloseBtn.TextSize         = 16
	_CloseBtn.TextColor3       = C.TXT
	_CloseBtn.AutoButtonColor  = true
	_CloseBtn.Parent           = _Bar
	Corner(_CloseBtn, 6)
	_CloseBtn.MouseButton1Click:Connect(function() self:hide() end)

	-- ── drag ───────────────────────────────────────────────────
	do
		local _Dragging, _DragStart, _StartPos
		_Bar.InputBegan:Connect(function(_Input)
			local _T = _Input.UserInputType
			if _T ~= Enum.UserInputType.MouseButton1
			and _T ~= Enum.UserInputType.Touch then return end
			_Dragging  = true
			_DragStart = _Input.Position
			_StartPos  = _Main.Position
			_Input.Changed:Connect(function()
				if _Input.UserInputState == Enum.UserInputState.End then
					_Dragging = false
				end
			end)
		end)
		UserInputService.InputChanged:Connect(function(_Input)
			if not _Dragging then return end
			local _T = _Input.UserInputType
			if _T ~= Enum.UserInputType.MouseMovement
			and _T ~= Enum.UserInputType.Touch then return end
			local _Delta = _Input.Position - _DragStart
			_Main.Position = UDim2.new(
				_StartPos.X.Scale, _StartPos.X.Offset + _Delta.X,
				_StartPos.Y.Scale, _StartPos.Y.Offset + _Delta.Y
			)
		end)
	end

	-- ── tab sidebar ────────────────────────────────────────────
	local _TabBar = Instance.new("Frame")
	_TabBar.Position         = UDim2.fromOffset(12, 54)
	_TabBar.Size             = UDim2.new(0, 110, 1, -66)
	_TabBar.BackgroundColor3 = C.BG2
	_TabBar.BorderSizePixel  = 0
	_TabBar.Parent           = _Main
	Corner(_TabBar, 10)
	ListLayout(_TabBar, 6)
	Pad(_TabBar, 8)
	self._tabBar = _TabBar

	local _Content = Instance.new("Frame")
	_Content.Position          = UDim2.fromOffset(132, 54)
	_Content.Size              = UDim2.new(1, -144, 1, -66)
	_Content.BackgroundTransparency = 1
	_Content.Parent            = _Main
	self._content = _Content

	-- ── INSERT hotkey ──────────────────────────────────────────
	UserInputService.InputBegan:Connect(function(_Input, _GameProcessed)
		if _GameProcessed then return end
		if _Input.KeyCode == Enum.KeyCode.Insert then self:toggle() end
	end)

	-- intro tween
	_Main.Size = UDim2.fromOffset(0, 0)
	task.defer(function()
		local _Sz = CalcSize()
		TweenService:Create(_Main,
			TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{Size = _Sz}):Play()
	end)

	return self
end

function UILib:_ord( )
	self._lo = self._lo + 1
	return self._lo
end

function UILib:selectTab( _Name )
	for _N, _Pg in pairs(self._pages) do _Pg.Visible = (_N == _Name) end
	for _N, _Btn in pairs(self._tabs) do
		local _On = (_N == _Name)
		TweenService:Create(_Btn, TweenInfo.new(0.15),
			{BackgroundColor3 = _On and C.ACCENT or C.CARD}):Play()
		_Btn.TextColor3 = _On and Color3.fromRGB(18, 22, 18) or C.TXT
		_Btn.Font = _On and Enum.Font.GothamBold or Enum.Font.GothamMedium
	end
	CfgSet("__activeTab", _Name, self._ss)
end

function UILib:addTab( _Name )
	local _Btn = Instance.new("TextButton")
	_Btn.Size             = UDim2.new(1, 0, 0, 34)
	_Btn.BackgroundColor3 = C.CARD
	_Btn.AutoButtonColor  = false
	_Btn.Text             = _Name
	_Btn.Font             = Enum.Font.GothamMedium
	_Btn.TextSize         = 13
	_Btn.TextColor3       = C.TXT
	_Btn.BorderSizePixel  = 0
	_Btn.Parent           = self._tabBar
	Corner(_Btn, 8)
	self._tabs[_Name] = _Btn

	local _Page = ScrollFrame(self._content)
	_Page.Size    = UDim2.fromScale(1, 1)
	_Page.Visible = false
	local _Layout = ListLayout(_Page, 8)
	AutoCanvas(_Page, _Layout)
	Pad(_Page, 4)
	self._pages[_Name] = _Page

	_Btn.MouseButton1Click:Connect(function() self:selectTab(_Name) end)
	return _Page
end

function UILib:restoreTab( _Fallback )
	local _Saved = Cfg["__activeTab"]
	if _Saved and self._pages[_Saved] then
		self:selectTab(_Saved)
		return
	end
	if _Fallback then self:selectTab(_Fallback) end
end

function UILib:show( )   self._main.Visible = true  end
function UILib:hide( )   self._main.Visible = false end
function UILib:toggle( ) self._main.Visible = not self._main.Visible end
function UILib:destroy( ) if self._gui then self._gui:Destroy() end end

-- ================================================================== WIDGETS

function UILib:sectionLabel( _Parent, _Text )
	local _Lbl = Instance.new("TextLabel")
	_Lbl.Size                = UDim2.new(1, 0, 0, 18)
	_Lbl.LayoutOrder         = self:_ord()
	_Lbl.BackgroundTransparency = 1
	_Lbl.Text                = string.upper(_Text)
	_Lbl.Font                = Enum.Font.GothamBold
	_Lbl.TextSize            = 11
	_Lbl.TextColor3          = C.SUB
	_Lbl.TextXAlignment      = Enum.TextXAlignment.Left
	_Lbl.Parent              = _Parent
	return _Lbl
end

-- ── toggleRow ─────────────────────────────────────────────────────────────
function UILib:toggleRow( _Parent, _Label, _Source, _Key, _CfgKey, _OnChange )
	if _CfgKey then
		local _Saved = Cfg[_CfgKey]
		if _Saved ~= nil then _Source[_Key] = _Saved end
	end

	local _Row = Instance.new("Frame")
	_Row.Size             = UDim2.new(1, 0, 0, 40)
	_Row.LayoutOrder      = self:_ord()
	_Row.BackgroundColor3 = C.CARD
	_Row.BorderSizePixel  = 0
	_Row.Parent           = _Parent
	Corner(_Row, 8)

	local _TextLbl = Instance.new("TextLabel")
	_TextLbl.BackgroundTransparency = 1
	_TextLbl.Position               = UDim2.fromOffset(12, 0)
	_TextLbl.Size                   = UDim2.new(1, -70, 1, 0)
	_TextLbl.Text                   = _Label
	_TextLbl.Font                   = Enum.Font.GothamMedium
	_TextLbl.TextSize               = 13
	_TextLbl.TextColor3             = C.TXT
	_TextLbl.TextXAlignment         = Enum.TextXAlignment.Left
	_TextLbl.Parent                 = _Row

	local _Pill = Instance.new("TextButton")
	_Pill.AnchorPoint      = Vector2.new(1, 0.5)
	_Pill.Position         = UDim2.new(1, -12, 0.5, 0)
	_Pill.Size             = UDim2.fromOffset(44, 22)
	_Pill.BackgroundColor3 = C.STROKE
	_Pill.Text             = ""
	_Pill.AutoButtonColor  = false
	_Pill.Parent           = _Row
	Corner(_Pill, 11)

	local _Knob = Instance.new("Frame")
	_Knob.Size             = UDim2.fromOffset(18, 18)
	_Knob.Position         = UDim2.fromOffset(2, 2)
	_Knob.BackgroundColor3 = C.KNOB
	_Knob.BorderSizePixel  = 0
	_Knob.Parent           = _Pill
	Corner(_Knob, 9)

	local function Render( )
		local _On = _Source[_Key]
		TweenService:Create(_Pill, TweenInfo.new(0.15),
			{BackgroundColor3 = _On and C.ACCENT or C.STROKE}):Play()
		TweenService:Create(_Knob, TweenInfo.new(0.15),
			{Position = _On and UDim2.fromOffset(24, 2) or UDim2.fromOffset(2, 2)}):Play()
	end

	_Pill.MouseButton1Click:Connect(function()
		_Source[_Key] = not _Source[_Key]
		if _CfgKey then CfgSet(_CfgKey, _Source[_Key], self._ss) end
		Render()
		if _OnChange then _OnChange(_Source[_Key]) end
	end)
	Render()
	return _Row
end

-- ── buttonRow ─────────────────────────────────────────────────────────────
function UILib:buttonRow( _Parent, _Label, _BtnText, _Callback, _CfgKey )
	local _Row = Instance.new("Frame")
	_Row.Size             = UDim2.new(1, 0, 0, 40)
	_Row.LayoutOrder      = self:_ord()
	_Row.BackgroundColor3 = C.CARD
	_Row.BorderSizePixel  = 0
	_Row.Parent           = _Parent
	Corner(_Row, 8)

	local _TextLbl = Instance.new("TextLabel")
	_TextLbl.BackgroundTransparency = 1
	_TextLbl.Position               = UDim2.fromOffset(12, 0)
	_TextLbl.Size                   = UDim2.new(1, -110, 1, 0)
	_TextLbl.Text                   = _Label
	_TextLbl.Font                   = Enum.Font.GothamMedium
	_TextLbl.TextSize               = 13
	_TextLbl.TextColor3             = C.TXT
	_TextLbl.TextXAlignment         = Enum.TextXAlignment.Left
	_TextLbl.Parent                 = _Row

	local _Btn = Instance.new("TextButton")
	_Btn.AnchorPoint      = Vector2.new(1, 0.5)
	_Btn.Position         = UDim2.new(1, -12, 0.5, 0)
	_Btn.Size             = UDim2.fromOffset(86, 26)
	_Btn.BackgroundColor3 = C.ACCENT
	_Btn.Text             = _BtnText
	_Btn.Font             = Enum.Font.GothamBold
	_Btn.TextSize         = 12
	_Btn.TextColor3       = Color3.fromRGB(18, 22, 18)
	_Btn.AutoButtonColor  = true
	_Btn.Parent           = _Row
	Corner(_Btn, 6)

	_Btn.MouseButton1Click:Connect(function()
		if _CfgKey then CfgSet(_CfgKey .. "_last", os.time(), self._ss) end
		_Callback(_Btn)
	end)
	return _Row, _Btn
end

-- ── statusCard ────────────────────────────────────────────────────────────
function UILib:statusCard( _Parent, _Height )
	local _Card = Instance.new("Frame")
	_Card.Size             = UDim2.new(1, 0, 0, _Height or 110)
	_Card.LayoutOrder      = self:_ord()
	_Card.BackgroundColor3 = C.CARD
	_Card.BorderSizePixel  = 0
	_Card.Parent           = _Parent
	Corner(_Card, 8)

	local _Lbl = Instance.new("TextLabel")
	_Lbl.BackgroundTransparency = 1
	_Lbl.Size                   = UDim2.fromScale(1, 1)
	_Lbl.Font                   = Enum.Font.Gotham
	_Lbl.TextSize               = 12
	_Lbl.TextColor3             = C.SUB
	_Lbl.TextXAlignment         = Enum.TextXAlignment.Left
	_Lbl.TextYAlignment         = Enum.TextYAlignment.Top
	_Lbl.Text                   = ""
	_Lbl.TextWrapped            = true
	_Lbl.Parent                 = _Card
	Pad(_Card, 12)
	return _Lbl
end

-- ================================================================== CHECKLIST

function UILib:checklist( _Parent, _Names, _Store, _CfgKey, _Opts )
	_Opts = _Opts or {}
	local _Multi  = _Opts.multiSelect ~= false
	local _Height = _Opts.height or 180

	if _CfgKey then
		for _, _N in ipairs(_Names) do
			local _Saved = Cfg[_CfgKey .. ":" .. _N]
			if _Saved ~= nil then _Store[_N] = _Saved end
		end
	end

	local _Box = Instance.new("Frame")
	_Box.Size             = UDim2.new(1, 0, 0, _Height)
	_Box.LayoutOrder      = self:_ord()
	_Box.BackgroundColor3 = C.CARD
	_Box.BorderSizePixel  = 0
	_Box.Parent           = _Parent
	Corner(_Box, 8)

	-- ── search bar ─────────────────────────────────────────────
	local _SearchBox = Instance.new("TextBox")
	_SearchBox.Size              = UDim2.new(1, -16, 0, 26)
	_SearchBox.Position          = UDim2.fromOffset(8, 8)
	_SearchBox.BackgroundColor3  = C.BG
	_SearchBox.PlaceholderText   = "Search..."
	_SearchBox.PlaceholderColor3 = C.SUB
	_SearchBox.Text              = ""
	_SearchBox.Font              = Enum.Font.Gotham
	_SearchBox.TextSize          = 12
	_SearchBox.TextColor3        = C.TXT
	_SearchBox.ClearTextOnFocus  = false
	_SearchBox.Parent            = _Box
	Corner(_SearchBox, 6)
	Stroke(_SearchBox, C.STROKE, 1)
	do
		local _P = Instance.new("UIPadding")
		_P.PaddingLeft  = UDim.new(0, 8)
		_P.PaddingRight = UDim.new(0, 8)
		_P.Parent = _SearchBox
	end

	-- ── header (all/none + mode label) ────────────────────────
	local _Hdr = Instance.new("Frame")
	_Hdr.Size                 = UDim2.new(1, -16, 0, 22)
	_Hdr.Position             = UDim2.fromOffset(8, 38)
	_Hdr.BackgroundTransparency = 1
	_Hdr.Parent               = _Box

	local function MiniBtn( _Text, _XOffset )
		local _Btn = Instance.new("TextButton")
		_Btn.AnchorPoint      = Vector2.new(1, 0.5)
		_Btn.Position         = UDim2.new(1, _XOffset, 0.5, 0)
		_Btn.Size             = UDim2.fromOffset(46, 20)
		_Btn.BackgroundColor3 = C.BG
		_Btn.Text             = _Text
		_Btn.Font             = Enum.Font.GothamMedium
		_Btn.TextSize         = 11
		_Btn.TextColor3       = C.TXT
		_Btn.AutoButtonColor  = true
		_Btn.Parent           = _Hdr
		Corner(_Btn, 6)
		Stroke(_Btn, C.STROKE, 1)
		return _Btn
	end

	local _ModeLbl = Instance.new("TextLabel")
	_ModeLbl.BackgroundTransparency = 1
	_ModeLbl.Position               = UDim2.fromOffset(0, 0)
	_ModeLbl.Size                   = UDim2.new(1, -100, 1, 0)
	_ModeLbl.Font                   = Enum.Font.Gotham
	_ModeLbl.TextSize               = 10
	_ModeLbl.TextColor3             = C.SUB
	_ModeLbl.TextXAlignment         = Enum.TextXAlignment.Left
	_ModeLbl.Text                   = _Multi and "multi-select" or "single select"
	_ModeLbl.Parent                 = _Hdr

	-- ── scroll list ────────────────────────────────────────────
	local _Sc = ScrollFrame(_Box)
	_Sc.Position = UDim2.fromOffset(0, 64)
	_Sc.Size     = UDim2.new(1, 0, 1, -64)
	local _Layout = ListLayout(_Sc, 3)
	AutoCanvas(_Sc, _Layout)
	Pad(_Sc, 6)

	local _RowMap = {}

	local function PaintRow( _Name )
		local _R = _RowMap[_Name]
		if not _R then return end
		_R.cb.BackgroundColor3 = _Store[_Name] and C.ACCENT or C.STROKE
	end

	local function SelectItem( _Name )
		if not _Multi then
			for _, _N in ipairs(_Names) do
				_Store[_N] = false
				if _CfgKey then CfgSet(_CfgKey .. ":" .. _N, false, self._ss) end
				PaintRow(_N)
			end
		end
		_Store[_Name] = not _Store[_Name]
		if _CfgKey then CfgSet(_CfgKey .. ":" .. _Name, _Store[_Name], self._ss) end
		PaintRow(_Name)
	end

	local function ApplyFilter( _Query )
		_Query = _Query:lower()
		for _, _Name in ipairs(_Names) do
			local _R = _RowMap[_Name]
			if not _R then continue end
			_R.frame.Visible = (_Query == "" or _Name:lower():find(_Query, 1, true) ~= nil)
		end
	end

	for _, _Name in ipairs(_Names) do
		local _Row = Instance.new("TextButton")
		_Row.Size             = UDim2.new(1, -6, 0, 26)
		_Row.BackgroundColor3 = C.BG
		_Row.AutoButtonColor  = false
		_Row.Text             = ""
		_Row.Parent           = _Sc
		Corner(_Row, 6)

		local _Cb = Instance.new("Frame")
		_Cb.Position         = UDim2.fromOffset(6, 6)
		_Cb.Size             = UDim2.fromOffset(14, 14)
		_Cb.BackgroundColor3 = _Store[_Name] and C.ACCENT or C.STROKE
		_Cb.BorderSizePixel  = 0
		_Cb.Parent           = _Row
		Corner(_Cb, _Multi and 4 or 7)

		local _NameLbl = Instance.new("TextLabel")
		_NameLbl.BackgroundTransparency = 1
		_NameLbl.Position               = UDim2.fromOffset(28, 0)
		_NameLbl.Size                   = UDim2.new(1, -32, 1, 0)
		_NameLbl.Text                   = _Name
		_NameLbl.Font                   = Enum.Font.Gotham
		_NameLbl.TextSize               = 12
		_NameLbl.TextColor3             = C.TXT
		_NameLbl.TextXAlignment         = Enum.TextXAlignment.Left
		_NameLbl.TextTruncate           = Enum.TextTruncate.AtEnd
		_NameLbl.Parent                 = _Row

		_RowMap[_Name] = { frame = _Row, cb = _Cb, label = _NameLbl }
		_Row.MouseButton1Click:Connect(function() SelectItem(_Name) end)
	end

	if _Multi then
		MiniBtn("None", -6).MouseButton1Click:Connect(function()
			for _, _N in ipairs(_Names) do
				_Store[_N] = false
				if _CfgKey then CfgSet(_CfgKey .. ":" .. _N, false, self._ss) end
				PaintRow(_N)
			end
		end)
		MiniBtn("All", -56).MouseButton1Click:Connect(function()
			for _, _N in ipairs(_Names) do
				_Store[_N] = true
				if _CfgKey then CfgSet(_CfgKey .. ":" .. _N, true, self._ss) end
				PaintRow(_N)
			end
		end)
	end

	_SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
		ApplyFilter(_SearchBox.Text)
	end)

	return _Box
end

return UILib
