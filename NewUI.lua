-- ============================================================ --
--  GAG2 UI LIBRARY  (ModuleScript: GAG2_UILib)                 --
--  Drop in ReplicatedStorage or inject inline.                  --
-- ============================================================ --
local TweenService       = game:GetService("TweenService")
local UserInputService   = game:GetService("UserInputService")
local Players            = game:GetService("Players")
local LP                 = Players.LocalPlayer

local UILib = {}
UILib.__index = UILib

-- ------------------------------------------------------------------ palette
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

-- ------------------------------------------------------------------ helpers
local function corner(p, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 8)
	c.Parent = p
	return c
end
local function stroke(p, col, th)
	local s = Instance.new("UIStroke")
	s.Color = col or C.STROKE
	s.Thickness = th or 1
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = p
	return s
end
local function pad(p, n)
	local u = Instance.new("UIPadding")
	u.PaddingLeft   = UDim.new(0, n)
	u.PaddingRight  = UDim.new(0, n)
	u.PaddingTop    = UDim.new(0, n)
	u.PaddingBottom = UDim.new(0, n)
	u.Parent = p
	return u
end
local function listLayout(parent, padding)
	local l = Instance.new("UIListLayout")
	l.SortOrder  = Enum.SortOrder.LayoutOrder
	l.Padding    = UDim.new(0, padding or 8)
	l.Parent     = parent
	return l
end
local function autoCanvas(scroll, layout)
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 12)
	end)
end
local function scrollFrame(parent)
	local s = Instance.new("ScrollingFrame")
	s.BackgroundTransparency  = 1
	s.BorderSizePixel         = 0
	s.ScrollBarThickness      = 4
	s.ScrollBarImageColor3    = C.STROKE
	s.CanvasSize              = UDim2.new()
	s.Parent                  = parent
	return s
end

-- ------------------------------------------------------------------ config
-- Saved into _G.__GAG2HUB_CFG  (plain table, survives re-inject)
local CFG_KEY = "__GAG2HUB_CFG"
_G[CFG_KEY] = _G[CFG_KEY] or {}
local cfg = _G[CFG_KEY]

local function cfgGet(key, default)
	if cfg[key] == nil then cfg[key] = default end
	return cfg[key]
end
local function cfgSet(key, val)
	cfg[key] = val
end

-- ------------------------------------------------------------------ gui root
local function getParentGui()
	local g
	local ok = pcall(function() g = gethui and gethui() end)
	if ok and g then return g end
	ok = pcall(function() g = game:GetService("CoreGui") end)
	if ok and g then return g end
	return LP:WaitForChild("PlayerGui")
end

-- ================================================================== Window
-- UILib.newWindow(title, subtitle)  →  windowObj
--   windowObj:addTab(name)          →  page (ScrollingFrame)
--   windowObj:show() / :hide() / :toggle()
--   windowObj:destroy()
-- ================================================================== --

function UILib.newWindow(title, subtitle)
	local self = setmetatable({}, UILib)
	self._tabs  = {}
	self._pages = {}
	self._lo    = 0

	local old = getParentGui():FindFirstChild("GAG2Hub")
	if old then old:Destroy() end

	local gui = Instance.new("ScreenGui")
	gui.Name             = "GAG2Hub"
	gui.ResetOnSpawn     = false
	gui.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
	gui.IgnoreGuiInset   = true
	gui.Parent           = getParentGui()
	self._gui = gui

	-- RESPONSIVE sizing: scale on small screens (mobile)
	-- Width: min(500, viewport.X - 16)   Height: min(420, viewport.Y - 16)
	local function calcSize()
		local vp = workspace.CurrentCamera.ViewportSize
		local w  = math.min(500, vp.X - 16)
		local h  = math.min(420, vp.Y - 16)
		return UDim2.fromOffset(w, h), UDim2.new(0.5, -w/2, 0.5, -h/2)
	end

	local main = Instance.new("Frame")
	main.Name             = "Main"
	main.BackgroundColor3 = C.BG
	main.BorderSizePixel  = 0
	main.Parent           = gui
	corner(main, 12)
	stroke(main, C.STROKE, 1)
	self._main = main

	local function applySize()
		local sz, pos = calcSize()
		main.Size     = sz
		main.Position = pos
	end
	applySize()
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(applySize)

	-- ── title bar ──────────────────────────────────────────────
	local bar = Instance.new("Frame")
	bar.Size             = UDim2.new(1, 0, 0, 46)
	bar.BackgroundColor3 = C.BG2
	bar.BorderSizePixel  = 0
	bar.Parent           = main
	corner(bar, 12)
	local barFix = Instance.new("Frame")
	barFix.Size             = UDim2.new(1, 0, 0, 14)
	barFix.Position         = UDim2.new(0, 0, 1, -14)
	barFix.BackgroundColor3 = C.BG2
	barFix.BorderSizePixel  = 0
	barFix.Parent           = bar

	local dot = Instance.new("Frame")
	dot.Size             = UDim2.fromOffset(12, 12)
	dot.Position         = UDim2.fromOffset(16, 17)
	dot.BackgroundColor3 = C.ACCENT
	dot.BorderSizePixel  = 0
	dot.Parent           = bar
	corner(dot, 6)

	local titleLbl = Instance.new("TextLabel")
	titleLbl.BackgroundTransparency = 1
	titleLbl.Position               = UDim2.fromOffset(38, 7)
	titleLbl.Size                   = UDim2.new(1, -120, 0, 20)
	titleLbl.Font                   = Enum.Font.GothamBold
	titleLbl.Text                   = title or "Hub"
	titleLbl.TextSize               = 15
	titleLbl.TextColor3             = C.TXT
	titleLbl.TextXAlignment         = Enum.TextXAlignment.Left
	titleLbl.TextScaled             = false
	titleLbl.Parent                 = bar

	local subLbl = Instance.new("TextLabel")
	subLbl.BackgroundTransparency = 1
	subLbl.Position               = UDim2.fromOffset(38, 25)
	subLbl.Size                   = UDim2.new(1, -120, 0, 14)
	subLbl.Font                   = Enum.Font.Gotham
	subLbl.Text                   = subtitle or "INSERT to hide"
	subLbl.TextSize               = 11
	subLbl.TextColor3             = C.SUB
	subLbl.TextXAlignment         = Enum.TextXAlignment.Left
	subLbl.Parent                 = bar

	-- ── close button ───────────────────────────────────────────
	local closeBtn = Instance.new("TextButton")
	closeBtn.AnchorPoint       = Vector2.new(1, 0.5)
	closeBtn.Position          = UDim2.new(1, -12, 0.5, 0)
	closeBtn.Size              = UDim2.fromOffset(26, 26)
	closeBtn.BackgroundColor3  = C.RED
	closeBtn.Text              = "×"
	closeBtn.Font              = Enum.Font.GothamBold
	closeBtn.TextSize          = 16
	closeBtn.TextColor3        = C.TXT
	closeBtn.AutoButtonColor   = true
	closeBtn.Parent            = bar
	corner(closeBtn, 6)
	closeBtn.MouseButton1Click:Connect(function() self:hide() end)

	-- ── drag (mouse + touch) ───────────────────────────────────
	do
		local dragging, ds, sp
		bar.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1
			or i.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				ds = i.Position
				sp = main.Position
				i.Changed:Connect(function()
					if i.UserInputState == Enum.UserInputState.End then dragging = false end
				end)
			end
		end)
		UserInputService.InputChanged:Connect(function(i)
			if not dragging then return end
			if i.UserInputType == Enum.UserInputType.MouseMovement
			or i.UserInputType == Enum.UserInputType.Touch then
				local d = i.Position - ds
				main.Position = UDim2.new(
					sp.X.Scale, sp.X.Offset + d.X,
					sp.Y.Scale, sp.Y.Offset + d.Y
				)
			end
		end)
	end

	-- ── tab sidebar ────────────────────────────────────────────
	local tabBar = Instance.new("Frame")
	tabBar.Position         = UDim2.fromOffset(12, 54)
	tabBar.Size             = UDim2.new(0, 110, 1, -66)
	tabBar.BackgroundColor3 = C.BG2
	tabBar.BorderSizePixel  = 0
	tabBar.Parent           = main
	corner(tabBar, 10)
	listLayout(tabBar, 6)
	pad(tabBar, 8)
	self._tabBar = tabBar

	local content = Instance.new("Frame")
	content.Position          = UDim2.fromOffset(132, 54)
	content.Size              = UDim2.new(1, -144, 1, -66)
	content.BackgroundTransparency = 1
	content.Parent            = main
	self._content = content

	-- ── INSERT hotkey ──────────────────────────────────────────
	UserInputService.InputBegan:Connect(function(i, gpe)
		if gpe then return end
		if i.KeyCode == Enum.KeyCode.Insert then self:toggle() end
	end)

	-- intro tween
	main.Size = UDim2.fromOffset(0, 0)
	task.defer(function()
		local sz = calcSize()
		TweenService:Create(main,
			TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{Size = sz}):Play()
	end)

	return self
end

function UILib:_ord() self._lo = self._lo + 1; return self._lo end

function UILib:selectTab(name)
	for n, pg in pairs(self._pages) do pg.Visible = (n == name) end
	for n, b  in pairs(self._tabs)  do
		local on = (n == name)
		TweenService:Create(b, TweenInfo.new(0.15),
			{BackgroundColor3 = on and C.ACCENT or C.CARD}):Play()
		b.TextColor3 = on and Color3.fromRGB(18, 22, 18) or C.TXT
		b.Font = on and Enum.Font.GothamBold or Enum.Font.GothamMedium
	end
	cfgSet("__activeTab", name)
end

function UILib:addTab(name)
	local b = Instance.new("TextButton")
	b.Size             = UDim2.new(1, 0, 0, 34)
	b.BackgroundColor3 = C.CARD
	b.AutoButtonColor  = false
	b.Text             = name
	b.Font             = Enum.Font.GothamMedium
	b.TextSize         = 13
	b.TextColor3       = C.TXT
	b.BorderSizePixel  = 0
	b.Parent           = self._tabBar
	corner(b, 8)
	self._tabs[name] = b

	local page = scrollFrame(self._content)
	page.Size    = UDim2.fromScale(1, 1)
	page.Visible = false
	local l = listLayout(page, 8)
	autoCanvas(page, l)
	pad(page, 4)
	self._pages[name] = page

	b.MouseButton1Click:Connect(function() self:selectTab(name) end)
	return page
end

function UILib:show()    self._main.Visible = true  end
function UILib:hide()    self._main.Visible = false end
function UILib:toggle()  self._main.Visible = not self._main.Visible end
function UILib:destroy() if self._gui then self._gui:Destroy() end end

-- ================================================================== WIDGETS
-- All widget constructors are methods on the window object so they share
-- the internal layout-order counter and config namespace.
-- ================================================================== --

-- ── section label ──────────────────────────────────────────────────────────
function UILib:sectionLabel(parent, txt)
	local l = Instance.new("TextLabel")
	l.Size               = UDim2.new(1, 0, 0, 18)
	l.LayoutOrder        = self:_ord()
	l.BackgroundTransparency = 1
	l.Text               = string.upper(txt)
	l.Font               = Enum.Font.GothamBold
	l.TextSize           = 11
	l.TextColor3         = C.SUB
	l.TextXAlignment     = Enum.TextXAlignment.Left
	l.Parent             = parent
	return l
end

-- ── toggle row (pill switch) ────────────────────────────────────────────────
-- cfgKey  → _G.__GAG2HUB_CFG key (nil = don't persist)
-- source  → table holding the live flag   (e.g. F)
-- key     → field in source
function UILib:toggleRow(parent, label, source, key, cfgKey, onChange)
	-- restore from config if available
	if cfgKey then
		local saved = cfg[cfgKey]
		if saved ~= nil then source[key] = saved end
	end

	local row = Instance.new("Frame")
	row.Size             = UDim2.new(1, 0, 0, 40)
	row.LayoutOrder      = self:_ord()
	row.BackgroundColor3 = C.CARD
	row.BorderSizePixel  = 0
	row.Parent           = parent
	corner(row, 8)

	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Position           = UDim2.fromOffset(12, 0)
	t.Size               = UDim2.new(1, -70, 1, 0)
	t.Text               = label
	t.Font               = Enum.Font.GothamMedium
	t.TextSize           = 13
	t.TextColor3         = C.TXT
	t.TextXAlignment     = Enum.TextXAlignment.Left
	t.Parent             = row

	local pill = Instance.new("TextButton")
	pill.AnchorPoint      = Vector2.new(1, 0.5)
	pill.Position         = UDim2.new(1, -12, 0.5, 0)
	pill.Size             = UDim2.fromOffset(44, 22)
	pill.BackgroundColor3 = C.STROKE
	pill.Text             = ""
	pill.AutoButtonColor  = false
	pill.Parent           = row
	corner(pill, 11)

	local knob = Instance.new("Frame")
	knob.Size             = UDim2.fromOffset(18, 18)
	knob.Position         = UDim2.fromOffset(2, 2)
	knob.BackgroundColor3 = C.KNOB
	knob.BorderSizePixel  = 0
	knob.Parent           = pill
	corner(knob, 9)

	local function render()
		local on = source[key]
		TweenService:Create(pill, TweenInfo.new(0.15),
			{BackgroundColor3 = on and C.ACCENT or C.STROKE}):Play()
		TweenService:Create(knob, TweenInfo.new(0.15),
			{Position = on and UDim2.fromOffset(24, 2) or UDim2.fromOffset(2, 2)}):Play()
	end
	pill.MouseButton1Click:Connect(function()
		source[key] = not source[key]
		if cfgKey then cfgSet(cfgKey, source[key]) end
		render()
		if onChange then onChange(source[key]) end
	end)
	render()
	return row
end

-- ── button row ─────────────────────────────────────────────────────────────
function UILib:buttonRow(parent, label, btnText, cb)
	local row = Instance.new("Frame")
	row.Size             = UDim2.new(1, 0, 0, 40)
	row.LayoutOrder      = self:_ord()
	row.BackgroundColor3 = C.CARD
	row.BorderSizePixel  = 0
	row.Parent           = parent
	corner(row, 8)

	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Position           = UDim2.fromOffset(12, 0)
	t.Size               = UDim2.new(1, -110, 1, 0)
	t.Text               = label
	t.Font               = Enum.Font.GothamMedium
	t.TextSize           = 13
	t.TextColor3         = C.TXT
	t.TextXAlignment     = Enum.TextXAlignment.Left
	t.Parent             = row

	local b = Instance.new("TextButton")
	b.AnchorPoint      = Vector2.new(1, 0.5)
	b.Position         = UDim2.new(1, -12, 0.5, 0)
	b.Size             = UDim2.fromOffset(86, 26)
	b.BackgroundColor3 = C.ACCENT
	b.Text             = btnText
	b.Font             = Enum.Font.GothamBold
	b.TextSize         = 12
	b.TextColor3       = Color3.fromRGB(18, 22, 18)
	b.AutoButtonColor  = true
	b.Parent           = row
	corner(b, 6)
	b.MouseButton1Click:Connect(function() cb(b) end)
	return row, b
end

-- ── status card ────────────────────────────────────────────────────────────
function UILib:statusCard(parent, height)
	local card = Instance.new("Frame")
	card.Size             = UDim2.new(1, 0, 0, height or 110)
	card.LayoutOrder      = self:_ord()
	card.BackgroundColor3 = C.CARD
	card.BorderSizePixel  = 0
	card.Parent           = parent
	corner(card, 8)

	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Size               = UDim2.fromScale(1, 1)
	lbl.Font               = Enum.Font.Gotham
	lbl.TextSize           = 12
	lbl.TextColor3         = C.SUB
	lbl.TextXAlignment     = Enum.TextXAlignment.Left
	lbl.TextYAlignment     = Enum.TextYAlignment.Top
	lbl.Text               = ""
	lbl.TextWrapped        = true
	lbl.Parent             = card
	pad(card, 12)
	return lbl
end

-- ================================================================== CHECKLIST
-- UILib:checklist(parent, names, store, cfgKey, opts)
--   names   → { "Seed1", "Seed2", ... }
--   store   → table   store[name] = bool
--   cfgKey  → string  prefix used in cfg for each item  (nil = no persist)
--   opts    → { multiSelect = true|false,  height = px }
--
-- multiSelect = true  → check/uncheck freely  (default)
-- multiSelect = false → radio — selecting one deselects the rest
--
-- Has live search box at the top.
-- ================================================================== --

function UILib:checklist(parent, names, store, cfgKey, opts)
	opts = opts or {}
	local multi  = opts.multiSelect ~= false  -- default true
	local height = opts.height or 180

	-- restore per-item config
	if cfgKey then
		for _, n in ipairs(names) do
			local saved = cfg[cfgKey .. ":" .. n]
			if saved ~= nil then store[n] = saved end
		end
	end

	local box = Instance.new("Frame")
	box.Size             = UDim2.new(1, 0, 0, height)
	box.LayoutOrder      = self:_ord()
	box.BackgroundColor3 = C.CARD
	box.BorderSizePixel  = 0
	box.Parent           = parent
	corner(box, 8)

	-- ── search bar ─────────────────────────────────────────────
	local searchBox = Instance.new("TextBox")
	searchBox.Size             = UDim2.new(1, -16, 0, 26)
	searchBox.Position         = UDim2.fromOffset(8, 8)
	searchBox.BackgroundColor3 = C.BG
	searchBox.PlaceholderText  = "Search..."
	searchBox.PlaceholderColor3 = C.SUB
	searchBox.Text             = ""
	searchBox.Font             = Enum.Font.Gotham
	searchBox.TextSize         = 12
	searchBox.TextColor3       = C.TXT
	searchBox.ClearTextOnFocus = false
	searchBox.Parent           = box
	corner(searchBox, 6)
	stroke(searchBox, C.STROKE, 1)
	do local p = Instance.new("UIPadding")
		p.PaddingLeft = UDim.new(0, 8); p.PaddingRight = UDim.new(0, 8)
		p.Parent = searchBox
	end

	-- ── all / none header ──────────────────────────────────────
	local hdr = Instance.new("Frame")
	hdr.Size                 = UDim2.new(1, -16, 0, 22)
	hdr.Position             = UDim2.fromOffset(8, 38)
	hdr.BackgroundTransparency = 1
	hdr.Parent               = box

	local function miniBtn(txt, xoff)
		local b = Instance.new("TextButton")
		b.AnchorPoint      = Vector2.new(1, 0.5)
		b.Position         = UDim2.new(1, xoff, 0.5, 0)
		b.Size             = UDim2.fromOffset(46, 20)
		b.BackgroundColor3 = C.BG
		b.Text             = txt
		b.Font             = Enum.Font.GothamMedium
		b.TextSize         = 11
		b.TextColor3       = C.TXT
		b.AutoButtonColor  = true
		b.Parent           = hdr
		corner(b, 6)
		stroke(b, C.STROKE, 1)
		return b
	end

	local modeLabel = Instance.new("TextLabel")
	modeLabel.BackgroundTransparency = 1
	modeLabel.Position = UDim2.fromOffset(0, 0)
	modeLabel.Size     = UDim2.new(1, -100, 1, 0)
	modeLabel.Font     = Enum.Font.Gotham
	modeLabel.TextSize = 10
	modeLabel.TextColor3 = C.SUB
	modeLabel.TextXAlignment = Enum.TextXAlignment.Left
	modeLabel.Text     = multi and "multi-select" or "single select"
	modeLabel.Parent   = hdr

	-- ── scroll list ────────────────────────────────────────────
	local sc = scrollFrame(box)
	sc.Position = UDim2.fromOffset(0, 64)
	sc.Size     = UDim2.new(1, 0, 1, -64)
	local ll = listLayout(sc, 3)
	autoCanvas(sc, ll)
	pad(sc, 6)

	local rowMap   = {}   -- name → { frame, cb, label }
	local function paint(name)
		if rowMap[name] then
			rowMap[name].cb.BackgroundColor3 = store[name] and C.ACCENT or C.STROKE
		end
	end

	local function select(name)
		if not multi then
			for _, n in ipairs(names) do
				store[n] = false
				if cfgKey then cfgSet(cfgKey .. ":" .. n, false) end
				paint(n)
			end
		end
		store[name] = not store[name]
		if cfgKey then cfgSet(cfgKey .. ":" .. name, store[name]) end
		paint(name)
	end

	local function applyFilter(query)
		query = query:lower()
		for _, name in ipairs(names) do
			local r = rowMap[name]
			if r then
				r.frame.Visible = (query == "" or name:lower():find(query, 1, true) ~= nil)
			end
		end
	end

	for _, name in ipairs(names) do
		local r = Instance.new("TextButton")
		r.Size             = UDim2.new(1, -6, 0, 26)
		r.BackgroundColor3 = C.BG
		r.AutoButtonColor  = false
		r.Text             = ""
		r.Parent           = sc
		corner(r, 6)

		local cb = Instance.new("Frame")
		cb.Position        = UDim2.fromOffset(6, 6)
		cb.Size            = UDim2.fromOffset(14, 14)
		cb.BackgroundColor3 = store[name] and C.ACCENT or C.STROKE
		cb.BorderSizePixel = 0
		cb.Parent          = r
		corner(cb, multi and 4 or 7)   -- square for multi, round for single

		local nm = Instance.new("TextLabel")
		nm.BackgroundTransparency = 1
		nm.Position        = UDim2.fromOffset(28, 0)
		nm.Size            = UDim2.new(1, -32, 1, 0)
		nm.Text            = name
		nm.Font            = Enum.Font.Gotham
		nm.TextSize        = 12
		nm.TextColor3      = C.TXT
		nm.TextXAlignment  = Enum.TextXAlignment.Left
		nm.TextTruncate    = Enum.TextTruncate.AtEnd
		nm.Parent          = r

		rowMap[name] = { frame = r, cb = cb, label = nm }
		r.MouseButton1Click:Connect(function() select(name) end)
	end

	-- all / none only meaningful in multi mode
	if multi then
		miniBtn("None", -6).MouseButton1Click:Connect(function()
			for _, n in ipairs(names) do
				store[n] = false
				if cfgKey then cfgSet(cfgKey .. ":" .. n, false) end
				paint(n)
			end
		end)
		miniBtn("All", -56).MouseButton1Click:Connect(function()
			for _, n in ipairs(names) do
				store[n] = true
				if cfgKey then cfgSet(cfgKey .. ":" .. n, true) end
				paint(n)
			end
		end)
	end

	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		applyFilter(searchBox.Text)
	end)

	return box
end

return UILib
