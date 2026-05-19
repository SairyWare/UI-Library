local Library = {Flags = {}, Windows = {}, Open = true}

--Services
local RunService = game:GetService"RunService"
local TweenService = game:GetService"TweenService"
local TextService = game:GetService"TextService"
local UserInputService = game:GetService"UserInputService"
local MouseButton1 = Enum.UserInputType.MouseButton1
--Locals
local Dragging, DragInput, DragStart, StartPos, DragObject

--Functions
local function RoundFunc(_Num, _Bracket)
	_Bracket = _Bracket or 1
	local a = math.floor(_Num/_Bracket + (math.sign(_Num) * 0.5)) * _Bracket
	if a < 0 then
		a = a + _Bracket
	end
	return a
end

local function KeyCheck(x,x1)
	for _,v in next, x1 do
		if v == x then
			return true
		end
	end
end

local function UpdateFunc(_Input)
	local _Delta = _Input.Position - DragStart
	local _YPos = (StartPos.Y.Offset + _Delta.Y) < -36 and -36 or StartPos.Y.Offset + _Delta.Y
	DragObject:TweenPosition(UDim2.new(StartPos.X.Scale, StartPos.X.Offset + _Delta.X, StartPos.Y.Scale, _YPos), "Out", "Quint", 0.1, true)
end
 
--From: https://devforum.roblox.com/t/how-to-create-a-simple-rainbow-effect-using-tweenService/221849/2
local ChromaColor
local RainbowTime = 5
spawn(function()
	while task.wait() do
		ChromaColor = Color3.fromHSV(tick() % RainbowTime / RainbowTime, 1, 1)
	end
end)

function Library:Create(_Class, _Properties)
	_Properties = typeof(_Properties) == "table" and _Properties or {}
	local _Inst = Instance.new(_Class)
	for property, value in next, _Properties do
		_Inst[property] = value
	end
	return _Inst
end

local function CreateOptionHolder(_HolderTitle, _Parent, _ParentTable, _SubHolder)
	local _Size = _SubHolder and 34 or 40
	_ParentTable.main = Library:Create("ImageButton", {
		LayoutOrder = _SubHolder and _ParentTable.position or 0,
		Position = UDim2.new(0, 20 + (250 * (_ParentTable.position or 0)), 0, 20),
		Size = UDim2.new(0, 230, 0, _Size),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = Color3.fromRGB(20, 20, 20),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.04,
		ClipsDescendants = true,
		Parent = _Parent
	})
	
	local _Round
	if not _SubHolder then
		_Round = Library:Create("ImageLabel", {
			Size = UDim2.new(1, 0, 0, _Size),
			BackgroundTransparency = 1,
			Image = "rbxassetid://3570695787",
			ImageColor3 = _ParentTable.open and (_SubHolder and Color3.fromRGB(16, 16, 16) or Color3.fromRGB(10, 10, 10)) or (_SubHolder and Color3.fromRGB(10, 10, 10) or Color3.fromRGB(6, 6, 6)),
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(100, 100, 100, 100),
			SliceScale = 0.04,
			Parent = _ParentTable.main
		})
	end
	
	local _Title = Library:Create("TextLabel", {
		Size = UDim2.new(1, 0, 0, _Size),
		BackgroundTransparency = _SubHolder and 0 or 1,
		BackgroundColor3 = Color3.fromRGB(10, 10, 10),
		BorderSizePixel = 0,
		Text = _HolderTitle,
		TextSize = _SubHolder and 16 or 17,
		Font = Enum.Font.LuckiestGuy,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Parent = _ParentTable.main
	})
	
	local _CloseHolder = Library:Create("Frame", {
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.new(-1, 0, 1, 0),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		BackgroundTransparency = 1,
		Parent = _Title
	})
	
	local _Close = Library:Create("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(1, -_Size - 10, 1, -_Size - 10),
		Rotation = _ParentTable.open and 90 or 180,
		BackgroundTransparency = 1,
		Image = "rbxassetid://4918373417",
		ImageColor3 = _ParentTable.open and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(30, 30, 30),
		ScaleType = Enum.ScaleType.Fit,
		Parent = _CloseHolder
	})
	
	_ParentTable.content = Library:Create("Frame", {
		Position = UDim2.new(0, 0, 0, _Size),
		Size = UDim2.new(1, 0, 1, -_Size),
		BackgroundTransparency = 1,
		Parent = _ParentTable.main
	})
	
	local _Layout = Library:Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = _ParentTable.content
	})
	
	_Layout.Changed:connect(function()
		_ParentTable.content.Size = UDim2.new(1, 0, 0, _Layout.AbsoluteContentSize.Y)
		_ParentTable.main.Size = #_ParentTable.options > 0 and _ParentTable.open and UDim2.new(0, 230, 0, _Layout.AbsoluteContentSize.Y + _Size) or UDim2.new(0, 230, 0, _Size)
	end)
	
	if not _SubHolder then
		Library:Create("UIPadding", {
			Parent = _ParentTable.content
		})
		
		_Title.InputBegan:connect(function(input)
			if input.UserInputType == MouseButton1 then
				DragObject = _ParentTable.main
				Dragging = true
				DragStart = input.Position
				StartPos = DragObject.Position
			elseif input.UserInputType == Enum.UserInputType.Touch then
				DragObject = _ParentTable.main
				Dragging = true
				DragStart = input.Position
				StartPos = DragObject.Position
			end
		end)
		_Title.InputChanged:connect(function(input)
			if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				DragInput = input
			elseif Dragging and input.UserInputType == Enum.UserInputType.Touch then
				DragInput = input
			end
		end)
			_Title.InputEnded:connect(function(input)
			if input.UserInputType == MouseButton1 then
				Dragging = false
			elseif input.UserInputType == Enum.UserInputType.Touch then
				Dragging = false
			end
		end)
	end
	
	_CloseHolder.InputBegan:connect(function(input)
		if input.UserInputType == MouseButton1 then
			_ParentTable.open = not _ParentTable.open
			TweenService:Create(_Close, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = _ParentTable.open and 90 or 180, ImageColor3 = _ParentTable.open and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(30, 30, 30)}):Play()
			if _SubHolder then
				TweenService:Create(_Title, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = _ParentTable.open and Color3.fromRGB(16, 16, 16) or Color3.fromRGB(10, 10, 10)}):Play()
			else
				TweenService:Create(_Round, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = _ParentTable.open and Color3.fromRGB(10, 10, 10) or Color3.fromRGB(6, 6, 6)}):Play()
			end
			_ParentTable.main:TweenSize(#_ParentTable.options > 0 and _ParentTable.open and UDim2.new(0, 230, 0, _Layout.AbsoluteContentSize.Y + _Size) or UDim2.new(0, 230, 0, _Size), "Out", "Quad", 0.2, true)
		elseif input.UserInputType == Enum.UserInputType.Touch then
			_ParentTable.open = not _ParentTable.open
			TweenService:Create(_Close, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = _ParentTable.open and 90 or 180, ImageColor3 = _ParentTable.open and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(30, 30, 30)}):Play()
			if _SubHolder then
				TweenService:Create(_Title, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = _ParentTable.open and Color3.fromRGB(16, 16, 16) or Color3.fromRGB(10, 10, 10)}):Play()
			else
				TweenService:Create(_Round, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = _ParentTable.open and Color3.fromRGB(10, 10, 10) or Color3.fromRGB(6, 6, 6)}):Play()
			end
			_ParentTable.main:TweenSize(#_ParentTable.options > 0 and _ParentTable.open and UDim2.new(0, 230, 0, _Layout.AbsoluteContentSize.Y + _Size) or UDim2.new(0, 230, 0, _Size), "Out", "Quad", 0.2, true)
		end
	end)

	function _ParentTable:SetTitle(newTitle)
		_Title.Text = tostring(newTitle)
	end
	
	return _ParentTable
end
	
local function CreateLabel(_Option, _Parent)
	local _Main = Library:Create("TextLabel", {
		LayoutOrder = _Option.position,
		Size = UDim2.new(1, 0, 0, 26),
		BackgroundTransparency = 1,
		Text = " " .. _Option.text,
		TextSize = 17,
		Font = Enum.Font.GothamBlack,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = _Parent.content
	})
	
	setmetatable(_Option, {__newindex = function(t, i, v)
		if i == "Text" then
			_Main.Text = " " .. tostring(v)
		end
	end})
end

function CreateToggle(_Option, _Parent)
	local _Main = Library:Create("TextLabel", {
		LayoutOrder = _Option.position,
		Size = UDim2.new(1, 0, 0, 31),
		BackgroundTransparency = 1,
		Text = " " .. _Option.text,
		TextSize = 17,
		Font = Enum.Font.GothamBlack,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = _Parent.content
	})
	
	local _TickboxOutline = Library:Create("ImageLabel", {
		Position = UDim2.new(1, -6, 0, 4),
		Size = UDim2.new(-1, 10, 1, -10),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = _Option.state and Color3.fromRGB(255, 65, 65) or Color3.fromRGB(100, 100, 100),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = _Main
	})
	
	local _TickboxInner = Library:Create("ImageLabel", {
		Position = UDim2.new(0, 2, 0, 2),
		Size = UDim2.new(1, -4, 1, -4),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = _Option.state and Color3.fromRGB(255, 65, 65) or Color3.fromRGB(20, 20, 20),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = _TickboxOutline
	})
	
	local _CheckmarkHolder = Library:Create("Frame", {
		Position = UDim2.new(0, 4, 0, 4),
		Size = _Option.state and UDim2.new(1, -8, 1, -8) or UDim2.new(0, 0, 1, -8),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Parent = _TickboxOutline
	})
	
	local _Checkmark = Library:Create("ImageLabel", {
		Size = UDim2.new(1, 0, 1, 0),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		BackgroundTransparency = 1,
		Image = "rbxassetid://4919148038",
		ImageColor3 = Color3.fromRGB(20, 20, 20),
		Parent = _CheckmarkHolder
	})
	
	local _InContact
	_Main.InputBegan:connect(function(input)
		if input.UserInputType == MouseButton1 then
			_Option:SetState(not _Option.state)
		elseif input.UserInputType == Enum.UserInputType.Touch then
			_Option:SetState(not _Option.state)
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			_InContact = true
			if not _Option.state then
				TweenService:Create(_TickboxOutline, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(140, 140, 140)}):Play()
			end
		end
	end)
	
	_Main.InputEnded:connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			_InContact = true
			if not _Option.state then
				TweenService:Create(_TickboxOutline, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(100, 100, 100)}):Play()
			end
		end
	end)
	
	function _Option:SetState(_State)
		Library.Flags[self.flag] = _State
		self.state = _State
		_CheckmarkHolder:TweenSize(_Option.state and UDim2.new(1, -8, 1, -8) or UDim2.new(0, 0, 1, -8), "Out", "Quad", 0.2, true)
		TweenService:Create(_TickboxInner, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = _State and Color3.fromRGB(255, 65, 65) or Color3.fromRGB(20, 20, 20)}):Play()
		if _State then
			TweenService:Create(_TickboxOutline, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(255, 65, 65)}):Play()
		else
			if _InContact then
				TweenService:Create(_TickboxOutline, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(140, 140, 140)}):Play()
			else
				TweenService:Create(_TickboxOutline, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(100, 100, 100)}):Play()
			end
		end
		self.callback(_State)
	end

	if _Option.state then
		delay(1, function() _Option.callback(true) end)
	end
	
	setmetatable(_Option, {__newindex = function(t, i, v)
		if i == "Text" then
			_Main.Text = " " .. tostring(v)
		end
	end})
end

function CreateButton(_Option, _Parent)
	local _Main = Library:Create("TextLabel", {
		ZIndex = 2,
		LayoutOrder = _Option.position,
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundTransparency = 1,
		Text = " " .. _Option.text,
		TextSize = 17,
		Font = Enum.Font.GothamBlack,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Parent = _Parent.content
	})
	
	local _Round = Library:Create("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(1, -12, 1, -10),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = Color3.fromRGB(40, 40, 40),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = _Main
	})
	
	local _InContact
	local _Clicking
	_Main.InputBegan:connect(function(input)
		if input.UserInputType == MouseButton1 then
			Library.Flags[_Option.flag] = true
			_Clicking = true
			TweenService:Create(_Round, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(255, 65, 65)}):Play()
			_Option.callback()
		elseif input.UserInputType == Enum.UserInputType.Touch then
			Library.Flags[_Option.flag] = true
			_Clicking = true
			TweenService:Create(_Round, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(255, 65, 65)}):Play()
			_Option.callback()
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			_InContact = true
			TweenService:Create(_Round, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(60, 60, 60)}):Play()
		end
	end)
	
	_Main.InputEnded:connect(function(input)
		if input.UserInputType == MouseButton1 then
			_Clicking = false
			if _InContact then
				TweenService:Create(_Round, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(60, 60, 60)}):Play()
			else
				TweenService:Create(_Round, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(40, 40, 40)}):Play()
			end
		elseif input.UserInputType == Enum.UserInputType.Touch then
			_Clicking = false
			if _InContact then
				TweenService:Create(_Round, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(60, 60, 60)}):Play()
			else
				TweenService:Create(_Round, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(40, 40, 40)}):Play()
			end
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			_InContact = false
			if not _Clicking then
				TweenService:Create(_Round, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(40, 40, 40)}):Play()
			end
		end
	end)
end

local function CreateBind(_Option, _Parent)
	local _Binding
	local _Holding
	local _Loop
	local _Text = string.match(_Option.key, "Mouse") and string.sub(_Option.key, 1, 5) .. string.sub(_Option.key, 12, 13) or _Option.key

	local _Main = Library:Create("TextLabel", {
		LayoutOrder = _Option.position,
		Size = UDim2.new(1, 0, 0, 33),
		BackgroundTransparency = 1,
		Text = " " .. _Option.text,
		TextSize = 17,
		Font = Enum.Font.GothamBlack,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = _Parent.content
	})
	
	local _Round = Library:Create("ImageLabel", {
		Position = UDim2.new(1, -6, 0, 4),
		Size = UDim2.new(0, -TextService:GetTextSize(_Text, 16, Enum.Font.GothamBlack, Vector2.new(9e9, 9e9)).X - 16, 1, -10),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = Color3.fromRGB(40, 40, 40),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = _Main
	})
	
	local _Bindinput = Library:Create("TextLabel", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = _Text,
		TextSize = 16,
		Font = Enum.Font.GothamBlack,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Parent = _Round
	})
	
	local _InContact
	_Main.InputBegan:connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			_InContact = true
			if not _Binding then
				TweenService:Create(_Round, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(60, 60, 60)}):Play()
			end
		end
	end)
	 
	_Main.InputEnded:connect(function(input)
		if input.UserInputType == MouseButton1 then
			_Binding = true
			_Bindinput.Text = "..."
			TweenService:Create(_Round, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(255, 65, 65)}):Play()
		elseif input.UserInputType == Enum.UserInputType.Touch then
			_Binding = true
			_Bindinput.Text = "..."
			TweenService:Create(_Round, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(255, 65, 65)}):Play()
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			_InContact = false
			if not _Binding then
				TweenService:Create(_Round, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(40, 40, 40)}):Play()
			end
		end
	end)
	
	UserInputService.InputBegan:connect(function(input)
		if UserInputService:GetFocusedTextBox() then return end
		if (input.KeyCode.Name == _Option.key or input.UserInputType.Name == _Option.key) and not _Binding then
			if _Option.hold then
				_Loop = RunService.Heartbeat:connect(function()
					if _Binding then
						_Option.callback(true)
						_Loop:Disconnect()
						_Loop = nil
					else
						_Option.callback()
					end
				end)
			else
				_Option.callback()
			end
		elseif _Binding then
			local _Key
			pcall(function()
				if not KeyCheck(input.KeyCode, blacklistedKeys) then
					_Key = input.KeyCode
				end
			end)
			pcall(function()
				if KeyCheck(input.UserInputType, whitelistedMouseinputs) and not _Key then
					_Key = input.UserInputType
				end
			end)
			_Key = _Key or _Option.key
			_Option:SetKey(_Key)
		end
	end)
	
	UserInputService.InputEnded:connect(function(input)
		if input.KeyCode.Name == _Option.key or input.UserInputType.Name == _Option.key or input.UserInputType.Name == "MouseMovement" then
			if _Loop then
				_Loop:Disconnect()
				_Loop = nil
				_Option.callback(true)
			end
		end
	end)
	
	function _Option:SetKey(_KeyInput)
		_Binding = false
		if _Loop then
			_Loop:Disconnect()
			_Loop = nil
		end
		self.key = _KeyInput or self.key
		self.key = self.key.Name or self.key
		Library.Flags[self.flag] = self.key
		if string.match(self.key, "Mouse") then
			_Bindinput.Text = string.sub(self.key, 1, 5) .. string.sub(self.key, 12, 13)
		else
			_Bindinput.Text = self.key
		end
		TweenService:Create(_Round, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = _InContact and Color3.fromRGB(60, 60, 60) or Color3.fromRGB(40, 40, 40)}):Play()
		_Round.Size = UDim2.new(0, -TextService:GetTextSize(_Bindinput.Text, 15, Enum.Font.GothamBlack, Vector2.new(9e9, 9e9)).X - 16, 1, -10)	
	end
end

local function CreateSlider(_Option, _Parent)
	local _Main = Library:Create("Frame", {
		LayoutOrder = _Option.position,
		Size = UDim2.new(1, 0, 0, 50),
		BackgroundTransparency = 1,
		Parent = _Parent.content
	})
	
	local _Title = Library:Create("TextLabel", {
		Position = UDim2.new(0, 0, 0, 4),
		Size = UDim2.new(1, 0, 0, 20),
		BackgroundTransparency = 1,
		Text = " " .. _Option.text,
		TextSize = 17,
		Font = Enum.Font.GothamBlack,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = _Main
	})
	
	local _Slider = Library:Create("ImageLabel", {
		Position = UDim2.new(0, 10, 0, 34),
		Size = UDim2.new(1, -20, 0, 5),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = Color3.fromRGB(30, 30, 30),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = _Main
	})
	
	local _Fill = Library:Create("ImageLabel", {
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = Color3.fromRGB(60, 60, 60),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = _Slider
	})
	
	local _Circle = Library:Create("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new((_Option.value - _Option.min) / (_Option.max - _Option.min), 0, 0.5, 0),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = Color3.fromRGB(60, 60, 60),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 1,
		Parent = _Slider
	})
	
	local _ValueRound = Library:Create("ImageLabel", {
		Position = UDim2.new(1, -6, 0, 4),
		Size = UDim2.new(0, -60, 0, 18),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = Color3.fromRGB(40, 40, 40),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = _Main
	})
	
	local _Inputvalue = Library:Create("TextBox", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = _Option.value,
		TextColor3 = Color3.fromRGB(235, 235, 235),
		TextSize = 15,
		TextWrapped = true,
		Font = Enum.Font.GothamBlack,
		Parent = _ValueRound
	})
	
	if _Option.min >= 0 then
		_Fill.Size = UDim2.new((_Option.value - _Option.min) / (_Option.max - _Option.min), 0, 1, 0)
	else
		_Fill.Position = UDim2.new((0 - _Option.min) / (_Option.max - _Option.min), 0, 0, 0)
		_Fill.Size = UDim2.new(_Option.value / (_Option.max - _Option.min), 0, 1, 0)
	end
	
	local _Sliding
	local _InContact
	_Main.InputBegan:connect(function(input)
		if input.UserInputType == MouseButton1 then
			TweenService:Create(_Fill, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(255, 65, 65)}):Play()
			TweenService:Create(_Circle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(3.5, 0, 3.5, 0), ImageColor3 = Color3.fromRGB(255, 65, 65)}):Play()
			_Sliding = true
			_Option:SetValue(_Option.min + ((input.Position.X - _Slider.AbsolutePosition.X) / _Slider.AbsoluteSize.X) * (_Option.max - _Option.min))
		elseif input.UserInputType == Enum.UserInputType.Touch then
			TweenService:Create(_Fill, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(255, 65, 65)}):Play()
			TweenService:Create(_Circle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(3.5, 0, 3.5, 0), ImageColor3 = Color3.fromRGB(255, 65, 65)}):Play()
			_Sliding = true
			_Option:SetValue(_Option.min + ((input.Position.X - _Slider.AbsolutePosition.X) / _Slider.AbsoluteSize.X) * (_Option.max - _Option.min))
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			_InContact = true
			if not _Sliding then
				TweenService:Create(_Fill, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(100, 100, 100)}):Play()
				TweenService:Create(_Circle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(2.8, 0, 2.8, 0), ImageColor3 = Color3.fromRGB(100, 100, 100)}):Play()
			end
		end
	end)
	
	UserInputService.InputChanged:connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement and _Sliding then
			_Option:SetValue(_Option.min + ((input.Position.X - _Slider.AbsolutePosition.X) / _Slider.AbsoluteSize.X) * (_Option.max - _Option.min))
		end
	end)

	_Main.InputEnded:connect(function(input)
		if input.UserInputType == MouseButton1 then
			_Sliding = false
			if _InContact then
				TweenService:Create(_Fill, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(100, 100, 100)}):Play()
				TweenService:Create(_Circle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(2.8, 0, 2.8, 0), ImageColor3 = Color3.fromRGB(100, 100, 100)}):Play()
			else
				TweenService:Create(_Fill, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(60, 60, 60)}):Play()
				TweenService:Create(_Circle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 0, 0, 0), ImageColor3 = Color3.fromRGB(60, 60, 60)}):Play()
			end
		elseif input.UserInputType == Enum.UserInputType.Touch then
			_Sliding = false
			if _InContact then
				TweenService:Create(_Fill, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(100, 100, 100)}):Play()
				TweenService:Create(_Circle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(2.8, 0, 2.8, 0), ImageColor3 = Color3.fromRGB(100, 100, 100)}):Play()
			else
				TweenService:Create(_Fill, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(60, 60, 60)}):Play()
				TweenService:Create(_Circle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 0, 0, 0), ImageColor3 = Color3.fromRGB(60, 60, 60)}):Play()
			end
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			_InContact = false
			_Inputvalue:ReleaseFocus()
			if not _Sliding then
				TweenService:Create(_Fill, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(60, 60, 60)}):Play()
				TweenService:Create(_Circle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 0, 0, 0), ImageColor3 = Color3.fromRGB(60, 60, 60)}):Play()
			end
		end
	end)

	_Inputvalue.FocusLost:connect(function()
		TweenService:Create(_Circle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 0, 0, 0), ImageColor3 = Color3.fromRGB(60, 60, 60)}):Play()
		_Option:SetValue(tonumber(_Inputvalue.Text) or _Option.value)
	end)

	function _Option:SetValue(_Value)
		_Value = RoundFunc(_Value, _Option.float)
		_Value = math.clamp(_Value, self.min, self.max)
		_Circle:TweenPosition(UDim2.new((_Value - self.min) / (self.max - self.min), 0, 0.5, 0), "Out", "Quad", 0.1, true)
		if self.min >= 0 then
			_Fill:TweenSize(UDim2.new((_Value - self.min) / (self.max - self.min), 0, 1, 0), "Out", "Quad", 0.1, true)
		else
			_Fill:TweenPosition(UDim2.new((0 - self.min) / (self.max - self.min), 0, 0, 0), "Out", "Quad", 0.1, true)
			_Fill:TweenSize(UDim2.new(_Value / (self.max - self.min), 0, 1, 0), "Out", "Quad", 0.1, true)
		end
		Library.Flags[self.flag] = _Value
		self.value = _Value
		_Inputvalue.Text = _Value
		self.callback(_Value)
	end
end

local function CreateList(_Option, _Parent, _Holder)
	local _ValueCount = 0
	
	local _Main = Library:Create("Frame", {
		LayoutOrder = _Option.position,
		Size = UDim2.new(1, 0, 0, 52),
		BackgroundTransparency = 1,
		Parent = _Parent.content
	})
	
	local _Round = Library:Create("ImageLabel", {
		Position = UDim2.new(0, 6, 0, 4),
		Size = UDim2.new(1, -12, 1, -10),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = Color3.fromRGB(40, 40, 40),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = _Main
	})
	
	local _Title = Library:Create("TextLabel", {
		Position = UDim2.new(0, 12, 0, 8),
		Size = UDim2.new(1, -24, 0, 14),
		BackgroundTransparency = 1,
		Text = _Option.text,
		TextSize = 14,
		Font = Enum.Font.GothamBlack,
		TextColor3 = Color3.fromRGB(140, 140, 140),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = _Main
	})
	
	local _Listvalue = Library:Create("TextLabel", {
		Position = UDim2.new(0, 12, 0, 20),
		Size = UDim2.new(1, -24, 0, 24),
		BackgroundTransparency = 1,
		Text = _Option.value,
		TextSize = 18,
		Font = Enum.Font.GothamBlack,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = _Main
	})
	
	Library:Create("ImageLabel", {
		Position = UDim2.new(1, -16, 0, 16),
		Size = UDim2.new(-1, 32, 1, -32),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		Rotation = 90,
		BackgroundTransparency = 1,
		Image = "rbxassetid://4918373417",
		ImageColor3 = Color3.fromRGB(140, 140, 140),
		ScaleType = Enum.ScaleType.Fit,
		Parent = _Round
	})
	
	_Option.mainHolder = Library:Create("ImageButton", {
		ZIndex = 3,
		Size = UDim2.new(0, 240, 0, 52),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageTransparency = 1,
		ImageColor3 = Color3.fromRGB(30, 30, 30),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Visible = false,
		Parent = Library.base
	})
	
	local _Content = Library:Create("ScrollingFrame", {
		ZIndex = 3,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarImageColor3 = Color3.fromRGB(),
		ScrollBarThickness = 0,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		Parent = _Option.mainHolder
	})
	
	Library:Create("UIPadding", {
		PaddingTop = UDim.new(0, 6),
		Parent = _Content
	})
	
	local _Layout = Library:Create("UIListLayout", {
		Parent = _Content
	})
	
	_Layout.Changed:connect(function()
		_Option.mainHolder.Size = UDim2.new(0, 240, 0, (_ValueCount > 4 and (4 * 40) or _Layout.AbsoluteContentSize.Y) + 12)
		_Content.CanvasSize = UDim2.new(0, 0, 0, _Layout.AbsoluteContentSize.Y + 12)
	end)
	
	local _InContact
	_Round.InputBegan:connect(function(input)
		if input.UserInputType == MouseButton1 then
			if Library.activePopup then
				Library.activePopup:Close()
			end
			local _Position = _Main.AbsolutePosition
			_Option.mainHolder.Position = UDim2.new(0, _Position.X - 5, 0, _Position.Y - 10)
			_Option.open = true
			_Option.mainHolder.Visible = true
			Library.activePopup = _Option
			_Content.ScrollBarThickness = 6
			TweenService:Create(_Option.mainHolder, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = 0, Position = UDim2.new(0, _Position.X - 5, 0, _Position.Y - 4)}):Play()
			TweenService:Create(_Option.mainHolder, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0.1), {Position = UDim2.new(0, _Position.X - 5, 0, _Position.Y + 1)}):Play()
			for _,label in next, _Content:GetChildren() do
				if label:IsA"TextLabel" then
					TweenService:Create(label, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0, TextTransparency = 0}):Play()
				end
			end
		elseif input.UserInputType == Enum.UserInputType.Touch then
			if Library.activePopup then
				Library.activePopup:Close()
			end
			local _Position = _Main.AbsolutePosition
			_Option.mainHolder.Position = UDim2.new(0, _Position.X - 5, 0, _Position.Y - 10)
			_Option.open = true
			_Option.mainHolder.Visible = true
			Library.activePopup = _Option
			_Content.ScrollBarThickness = 6
			TweenService:Create(_Option.mainHolder, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = 0, Position = UDim2.new(0, _Position.X - 5, 0, _Position.Y - 4)}):Play()
			TweenService:Create(_Option.mainHolder, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0.1), {Position = UDim2.new(0, _Position.X - 5, 0, _Position.Y + 1)}):Play()
			for _,label in next, _Content:GetChildren() do
				if label:IsA"TextLabel" then
					TweenService:Create(label, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0, TextTransparency = 0}):Play()
				end
			end
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			_InContact = true
			if not _Option.open then
				TweenService:Create(_Round, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(60, 60, 60)}):Play()
			end
		end
	end)
	
	_Round.InputEnded:connect(function(_Input)
		if _Input.UserInputType == Enum.UserInputType.MouseMovement then
			_InContact = false
			if not _Option.open then
				TweenService:Create(_Round, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(40, 40, 40)}):Play()
			end
		end
	end)
	
	function _Option:AddValue(_Value)
		_ValueCount = _ValueCount + 1
		local label = Library:Create("TextLabel", {
			ZIndex = 3,
			Size = UDim2.new(1, 0, 0, 40),
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			BorderSizePixel = 0,
			Text = "    " .. _Value,
			TextSize = 14,
			TextTransparency = self.open and 0 or 1,
			Font = Enum.Font.GothamBlack,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = _Content
		})
		
		local _InContact
		local _Clicking
		label.InputBegan:connect(function(_Input)
			if _Input.UserInputType == MouseButton1 then
				_Clicking = true
				TweenService:Create(label, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(10, 10, 10)}):Play()
				self:SetValue(_Value)
			elseif _Input.UserInputType == Enum.UserInputType.Touch then
				_Clicking = true
				TweenService:Create(label, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(10, 10, 10)}):Play()
				self:SetValue(_Value)
			end
			if _Input.UserInputType == Enum.UserInputType.MouseMovement then
				_InContact = true
				if not _Clicking then
					TweenService:Create(label, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(20, 20, 20)}):Play()
				end
			end
		end)
		
		label.InputEnded:connect(function(_Input)
			if _Input.UserInputType == MouseButton1 then
				_Clicking = false
				TweenService:Create(label, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = _InContact and Color3.fromRGB(20, 20, 20) or Color3.fromRGB(30, 30, 30)}):Play()
			elseif _Input.UserInputType == Enum.UserInputType.Touch then
				_Clicking = false
				TweenService:Create(label, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = _InContact and Color3.fromRGB(20, 20, 20) or Color3.fromRGB(30, 30, 30)}):Play()
			end
			if _Input.UserInputType == Enum.UserInputType.MouseMovement then
				_InContact = false
				if not _Clicking then
					TweenService:Create(label, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
				end
			end
		end)
	end

	if not table.find(_Option.values, _Option.value) then
		_Option:AddValue(_Option.value)
	end
	
	for _, value in next, _Option.values do
		_Option:AddValue(tostring(value))
	end
	
	function _Option:RemoveValue(_Value)
		for _,label in next, _Content:GetChildren() do
			if label:IsA"TextLabel" and label.Text == "	" .. _Value then
				label:Destroy()
				_ValueCount = _ValueCount - 1
				break
			end
		end
		if self.value == _Value then
			self:SetValue("")
		end
	end
	
	function _Option:SetValue(_Value)
		Library.Flags[self.flag] = tostring(_Value)
		self.value = tostring(_Value)
		_Listvalue.Text = self.value
		self.callback(_Value)
	end
	
	function _Option:Close()
		Library.activePopup = nil
		self.open = false
		_Content.ScrollBarThickness = 0
		local _Position = _Main.AbsolutePosition
		TweenService:Create(_Round, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = _InContact and Color3.fromRGB(60, 60, 60) or Color3.fromRGB(40, 40, 40)}):Play()
		TweenService:Create(self.mainHolder, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = 1, Position = UDim2.new(0, _Position.X - 5, 0, _Position.Y -10)}):Play()
		for _,label in next, _Content:GetChildren() do
			if label:IsA"TextLabel" then
				TweenService:Create(label, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
			end
		end
		task.wait(0.3)
		--delay(0.3, function()
			if not self.open then
				self.mainHolder.Visible = false
			end
		--end)
	end

	return _Option
end

local function CreateBox(_Option, _Parent)
	local _Main = Library:Create("Frame", {
		LayoutOrder = _Option.position,
		Size = UDim2.new(1, 0, 0, 52),
		BackgroundTransparency = 1,
		Parent = _Parent.content
	})
	
	local _Outline = Library:Create("ImageLabel", {
		Position = UDim2.new(0, 6, 0, 4),
		Size = UDim2.new(1, -12, 1, -10),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = Color3.fromRGB(60, 60, 60),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = _Main
	})
	
	local _Round = Library:Create("ImageLabel", {
		Position = UDim2.new(0, 8, 0, 6),
		Size = UDim2.new(1, -16, 1, -14),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = Color3.fromRGB(20, 20, 20),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.01,
		Parent = _Main
	})
	
	local _Title = Library:Create("TextLabel", {
		Position = UDim2.new(0, 12, 0, 8),
		Size = UDim2.new(1, -24, 0, 14),
		BackgroundTransparency = 1,
		Text = _Option.text,
		TextSize = 14,
		Font = Enum.Font.GothamBlack,
		TextColor3 = Color3.fromRGB(100, 100, 100),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = _Main
	})
	
	local _Inputvalue = Library:Create("TextBox", {
		Position = UDim2.new(0, 12, 0, 20),
		Size = UDim2.new(1, -24, 0, 24),
		BackgroundTransparency = 1,
		Text = _Option.value,
		TextSize = 18,
		Font = Enum.Font.GothamBlack,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		Parent = _Main
	})
	
	local _InContact
	local _Focused
	_Main.InputBegan:connect(function(_Input)
		if _Input.UserInputType == MouseButton1 then
			if not _Focused then _Inputvalue:CaptureFocus() end
		elseif _Input.UserInputType == Enum.UserInputType.Touch then
			if not _Focused then _Inputvalue:CaptureFocus() end
		end
		if _Input.UserInputType == Enum.UserInputType.MouseMovement then
			_InContact = true
			if not _Focused then
				TweenService:Create(_Outline, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(100, 100, 100)}):Play()
			end
		end
	end)
	
	_Main.InputEnded:connect(function(_Input)
		if _Input.UserInputType == Enum.UserInputType.MouseMovement then
			_InContact = false
			if not _Focused then
				TweenService:Create(_Outline, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(60, 60, 60)}):Play()
			end
		end
	end)
	
	_Inputvalue.Focused:connect(function()
		_Focused = true
		TweenService:Create(_Outline, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(255, 65, 65)}):Play()
	end)
	
	_Inputvalue.FocusLost:connect(function(enter)
		_Focused = false
		TweenService:Create(_Outline, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(60, 60, 60)}):Play()
		_Option:SetValue(_Inputvalue.Text, enter)
	end)
	
	function _Option:SetValue(_Value, _Enter)
		Library.Flags[self.flag] = tostring(_Value)
		self.value = tostring(_Value)
		_Inputvalue.Text = self.value
		self.callback(_Value, _Enter)
	end
end

local function CreateColorPickerWindow(_Option)
	_Option.mainHolder = Library:Create("ImageButton", {
		ZIndex = 3,
		Size = UDim2.new(0, 240, 0, 180),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageTransparency = 1,
		ImageColor3 = Color3.fromRGB(30, 30, 30),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = Library.base
	})
		
	local _Hue, _Sat, _Val = Color3.toHSV(_Option.color)
	_Hue, _Sat, _Val = _Hue == 0 and 1 or _Hue, _Sat + 0.005, _Val - 0.005
	local _Editinghue
	local _Editingsatval
	local _CurrentColor = _Option.color
	local _PreviousColors = {[1] = _Option.color}
	local _OriginalColor = _Option.color
	local _RainbowEnabled
	local _RainbowLoop
	
	function _Option:updateVisuals(_Color)
		_CurrentColor = _Color
		self.visualize2.ImageColor3 = _Color
		_Hue, _Sat, _Val = Color3.toHSV(_Color)
		_Hue = _Hue == 0 and 1 or _Hue
		self.satval.BackgroundColor3 = Color3.fromHSV(_Hue, 1, 1)
		self.hueSlider.Position = UDim2.new(1 - _Hue, 0, 0, 0)
		self.satvalSlider.Position = UDim2.new(_Sat, 0, 1 - _Val, 0)
	end
	
	_Option.hue = Library:Create("ImageLabel", {
		ZIndex = 3,
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 8, 1, -8),
		Size = UDim2.new(1, -100, 0, 22),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageTransparency = 1,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = _Option.mainHolder
	})
	
	local _Gradient = Library:Create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(0.157, Color3.fromRGB(255, 0, 255)),
			ColorSequenceKeypoint.new(0.323, Color3.fromRGB(0, 0, 255)),
			ColorSequenceKeypoint.new(0.488, Color3.fromRGB(0, 255, 255)),
			ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 255, 0)),
			ColorSequenceKeypoint.new(0.817, Color3.fromRGB(255, 255, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
		}),
		Parent = _Option.hue
	})
	
	_Option.hueSlider = Library:Create("Frame", {
		ZIndex = 3,
		Position = UDim2.new(1 - _Hue, 0, 0, 0),
		Size = UDim2.new(0, 2, 1, 0),
		BackgroundTransparency = 1,
		BackgroundColor3 = Color3.fromRGB(30, 30, 30),
		BorderColor3 = Color3.fromRGB(255, 255, 255),
		Parent = _Option.hue
	})
	
	_Option.hue.InputBegan:connect(function(_Input)
		if _Input.UserInputType == MouseButton1 then
			_Editinghue = true
			X = (_Option.hue.AbsolutePosition.X + _Option.hue.AbsoluteSize.X) - _Option.hue.AbsolutePosition.X
			X = (_Input.Position.X - _Option.hue.AbsolutePosition.X) / X
			X = X < 0 and 0 or X > 0.995 and 0.995 or X
			_Option:updateVisuals(Color3.fromHSV(1 - X, _Sat, _Val))
		elseif input.UserInputType == Enum.UserInputType.Touch then
			_Editinghue = true
			X = (_Option.hue.AbsolutePosition.X + _Option.hue.AbsoluteSize.X) - _Option.hue.AbsolutePosition.X
			X = (_Input.Position.X - _Option.hue.AbsolutePosition.X) / X
			X = X < 0 and 0 or X > 0.995 and 0.995 or X
			_Option:updateVisuals(Color3.fromHSV(1 - X, _Sat, _Val))
		end
	end)
	
	UserInputService.InputChanged:connect(function(_Input)
		if _Input.UserInputType == Enum.UserInputType.MouseMovement and _Editinghue then
			X = (_Option.hue.AbsolutePosition.X + _Option.hue.AbsoluteSize.X) - _Option.hue.AbsolutePosition.X
			X = (_Input.Position.X - _Option.hue.AbsolutePosition.X) / X
			X = X <= 0 and 0 or X >= 0.995 and 0.995 or X
			_Option:updateVisuals(Color3.fromHSV(1 - X, _Sat, _Val))
		end
	end)
	
	_Option.hue.InputEnded:connect(function(_Input)
		if _Input.UserInputType == MouseButton1 then
			_Editinghue = false
		elseif _Input.UserInputType == Enum.UserInputType.Touch then
			_Editinghue = false
		end
	end)
	
	_Option.satval = Library:Create("ImageLabel", {
		ZIndex = 3,
		Position = UDim2.new(0, 8, 0, 8),
		Size = UDim2.new(1, -100, 1, -42),
		BackgroundTransparency = 1,
		BackgroundColor3 = Color3.fromHSV(_Hue, 1, 1),
		BorderSizePixel = 0,
		Image = "rbxassetid://4155801252",
		ImageTransparency = 1,
		ClipsDescendants = true,
		Parent = _Option.mainHolder
	})
	
	_Option.satvalSlider = Library:Create("Frame", {
		ZIndex = 3,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(_Sat, 0, 1 - _Val, 0),
		Size = UDim2.new(0, 4, 0, 4),
		Rotation = 45,
		BackgroundTransparency = 1,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Parent = _Option.satval
	})
	
	_Option.satval.InputBegan:connect(function(_Input)
		if _Input.UserInputType == MouseButton1 then
			_Editingsatval = true
			X = (_Option.satval.AbsolutePosition.X + _Option.satval.AbsoluteSize.X) - _Option.satval.AbsolutePosition.X
			Y = (_Option.satval.AbsolutePosition.Y + _Option.satval.AbsoluteSize.Y) - _Option.satval.AbsolutePosition.Y
			X = (_Input.Position.X - _Option.satval.AbsolutePosition.X) / X
			Y = (_Input.Position.Y - _Option.satval.AbsolutePosition.Y) / Y
			X = X <= 0.005 and 0.005 or X >= 1 and 1 or X
			Y = Y <= 0 and 0 or Y >= 0.995 and 0.995 or Y
			_Option:updateVisuals(Color3.fromHSV(_Hue, X, 1 - Y))
		elseif input.UserInputType == Enum.UserInputType.Touch then
			_Editingsatval = true
			X = (_Option.satval.AbsolutePosition.X + _Option.satval.AbsoluteSize.X) - _Option.satval.AbsolutePosition.X
			Y = (_Option.satval.AbsolutePosition.Y + _Option.satval.AbsoluteSize.Y) - _Option.satval.AbsolutePosition.Y
			X = (_Input.Position.X - _Option.satval.AbsolutePosition.X) / X
			Y = (_Input.Position.Y - _Option.satval.AbsolutePosition.Y) / Y
			X = X <= 0.005 and 0.005 or X >= 1 and 1 or X
			Y = Y <= 0 and 0 or Y >= 0.995 and 0.995 or Y
			_Option:updateVisuals(Color3.fromHSV(_Hue, X, 1 - Y))
		end
	end)
	
	UserInputService.InputChanged:connect(function(_Input)
		if _Input.UserInputType == Enum.UserInputType.MouseMovement and _Editingsatval then
			X = (_Option.satval.AbsolutePosition.X + _Option.satval.AbsoluteSize.X) - _Option.satval.AbsolutePosition.X
			Y = (_Option.satval.AbsolutePosition.Y + _Option.satval.AbsoluteSize.Y) - _Option.satval.AbsolutePosition.Y
			X = (_Input.Position.X - _Option.satval.AbsolutePosition.X) / X
			Y = (_Input.Position.Y - _Option.satval.AbsolutePosition.Y) / Y
			X = X <= 0.005 and 0.005 or X >= 1 and 1 or X
			Y = Y <= 0 and 0 or Y >= 0.995 and 0.995 or Y
			_Option:updateVisuals(Color3.fromHSV(_Hue, X, 1 - Y))
		end
	end)
	
	_Option.satval.InputEnded:connect(function(_Input)
		if _Input.UserInputType == MouseButton1 then
			_Editingsatval = false
		elseif input.UserInputType == Enum.UserInputType.Touch then
			_Editingsatval = false
		end
	end)
	
	_Option.visualize2 = Library:Create("ImageLabel", {
		ZIndex = 3,
		Position = UDim2.new(1, -8, 0, 8),
		Size = UDim2.new(0, -80, 0, 80),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = _CurrentColor,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = _Option.mainHolder
	})
	
	_Option.resetColor = Library:Create("ImageLabel", {
		ZIndex = 3,
		Position = UDim2.new(1, -8, 0, 92),
		Size = UDim2.new(0, -80, 0, 18),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageTransparency = 1,
		ImageColor3 = Color3.fromRGB(20, 20, 20),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = _Option.mainHolder
	})
	
	_Option.resetText = Library:Create("TextLabel", {
		ZIndex = 3,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = "Reset",
		TextTransparency = 1,
		Font = Enum.Font.Code,
		TextSize = 15,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Parent = _Option.resetColor
	})
	
	_Option.resetColor.InputBegan:connect(function(_Input)
		if _Input.UserInputType == MouseButton1 and not _RainbowEnabled then
			_PreviousColors = {_OriginalColor}
			_Option:SetColor(_OriginalColor)
		elseif _Input.UserInputType == Enum.UserInputType.Touch and not _RainbowEnabled then
			_PreviousColors = {_OriginalColor}
			_Option:SetColor(_OriginalColor)
		end
		if _Input.UserInputType == Enum.UserInputType.MouseMovement and not Dragging then
			TweenService:Create(_Option.resetColor, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(10, 10, 10)}):Play()
		end
	end)
	
	_Option.resetColor.InputEnded:connect(function(_Input)
		if _Input.UserInputType == Enum.UserInputType.MouseMovement and not Dragging then
			TweenService:Create(_Option.resetColor, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(20, 20, 20)}):Play()
		end
	end)
	
	_Option.undoColor = Library:Create("ImageLabel", {
		ZIndex = 3,
		Position = UDim2.new(1, -8, 0, 112),
		Size = UDim2.new(0, -80, 0, 18),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageTransparency = 1,
		ImageColor3 = Color3.fromRGB(20, 20, 20),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = _Option.mainHolder
	})
	
	_Option.undoText = Library:Create("TextLabel", {
		ZIndex = 3,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = "Undo",
		TextTransparency = 1,
		Font = Enum.Font.Code,
		TextSize = 15,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Parent = _Option.undoColor
	})
	
	_Option.undoColor.InputBegan:connect(function(_Input)
		if _Input.UserInputType == MouseButton1 and not _RainbowEnabled then
			local _Num = #_PreviousColors == 1 and 0 or 1
			_Option:SetColor(_PreviousColors[#_PreviousColors - _Num])
			if #_PreviousColors ~= 1 then
				table.remove(_PreviousColors, #_PreviousColors)
			end
		elseif _Input.UserInputType == Enum.UserInputType.Touch and not _RainbowEnabled then
			local _Num = #_PreviousColors == 1 and 0 or 1
			_Option:SetColor(_PreviousColors[#_PreviousColors - _Num])
			if #_PreviousColors ~= 1 then
				table.remove(_PreviousColors, #_PreviousColors)
			end
		end
		if _Input.UserInputType == Enum.UserInputType.MouseMovement and not Dragging then
			TweenService:Create(_Option.undoColor, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(10, 10, 10)}):Play()
		end
	end)
	
	_Option.undoColor.InputEnded:connect(function(_Input)
		if _Input.UserInputType == Enum.UserInputType.MouseMovement and not Dragging then
			TweenService:Create(_Option.undoColor, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(20, 20, 20)}):Play()
		end
	end)
	
	_Option.setColor = Library:Create("ImageLabel", {
		ZIndex = 3,
		Position = UDim2.new(1, -8, 0, 132),
		Size = UDim2.new(0, -80, 0, 18),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageTransparency = 1,
		ImageColor3 = Color3.fromRGB(20, 20, 20),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = _Option.mainHolder
	})
	
	_Option.setText = Library:Create("TextLabel", {
		ZIndex = 3,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = "Set",
		TextTransparency = 1,
		Font = Enum.Font.Code,
		TextSize = 15,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Parent = _Option.setColor
	})
	
	_Option.setColor.InputBegan:connect(function(_Input)
		if _Input.UserInputType == MouseButton1 and not _RainbowEnabled then
			table.insert(_PreviousColors, _CurrentColor)
			_Option:SetColor(_CurrentColor)
		elseif _Input.UserInputType == Enum.UserInputType.Touch and not _RainbowEnabled then
			table.insert(_PreviousColors, _CurrentColor)
			_Option:SetColor(_CurrentColor)
		end
		if _Input.UserInputType == Enum.UserInputType.MouseMovement and not Dragging then
			TweenService:Create(_Option.setColor, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(10, 10, 10)}):Play()
		end
	end)
	
	_Option.setColor.InputEnded:connect(function(_Input)
		if _Input.UserInputType == Enum.UserInputType.MouseMovement and not Dragging then
			TweenService:Create(_Option.setColor, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(20, 20, 20)}):Play()
		end
	end)
	
	_Option.rainbow = Library:Create("ImageLabel", {
		ZIndex = 3,
		Position = UDim2.new(1, -8, 0, 152),
		Size = UDim2.new(0, -80, 0, 18),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageTransparency = 1,
		ImageColor3 = Color3.fromRGB(20, 20, 20),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = _Option.mainHolder
	})
	
	_Option.rainbowText = Library:Create("TextLabel", {
		ZIndex = 3,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = "Rainbow",
		TextTransparency = 1,
		Font = Enum.Font.Code,
		TextSize = 15,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Parent = _Option.rainbow
	})
	
	_Option.rainbow.InputBegan:connect(function(Input)
		if Input.UserInputType == MouseButton1 then
			_RainbowEnabled = not _RainbowEnabled
			if _RainbowEnabled then
				_RainbowLoop = RunService.Heartbeat:connect(function()
					_Option:SetColor(ChromaColor)
					_Option.rainbowText.TextColor3 = ChromaColor
				end)
			else
				_RainbowLoop:Disconnect()
				_Option:SetColor(_PreviousColors[#_PreviousColors])
				_Option.rainbowText.TextColor3 = Color3.fromRGB(255, 255, 255)
			end
		elseif input.UserInputType == Enum.UserInputType.Touch then
			_RainbowEnabled = not _RainbowEnabled
			if _RainbowEnabled then
				_RainbowLoop = RunService.Heartbeat:connect(function()
					_Option:SetColor(ChromaColor)
					_Option.rainbowText.TextColor3 = ChromaColor
				end)
			else
				_RainbowLoop:Disconnect()
				_Option:SetColor(_PreviousColors[#_PreviousColors])
				_Option.rainbowText.TextColor3 = Color3.fromRGB(255, 255, 255)
			end
		end
		if Input.UserInputType == Enum.UserInputType.MouseMovement and not Dragging then
			TweenService:Create(_Option.rainbow, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(10, 10, 10)}):Play()
		end
	end)
	
	_Option.rainbow.InputEnded:connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement and not Dragging then
			TweenService:Create(_Option.rainbow, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(20, 20, 20)}):Play()
		end
	end)
	
	return _Option
end

local function CreateColor(_Option, _Parent, _Holder)
	_Option.main = Library:Create("TextLabel", {
		LayoutOrder = _Option.position,
		Size = UDim2.new(1, 0, 0, 31),
		BackgroundTransparency = 1,
		Text = " " .. _Option.text,
		TextSize = 17,
		Font = Enum.Font.GothamBlack,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = _Parent.content
	})
	
	local _ColorBoxOutline = Library:Create("ImageLabel", {
		Position = UDim2.new(1, -6, 0, 4),
		Size = UDim2.new(-1, 10, 1, -10),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = Color3.fromRGB(100, 100, 100),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = _Option.main
	})
	
	_Option.visualize = Library:Create("ImageLabel", {
		Position = UDim2.new(0, 2, 0, 2),
		Size = UDim2.new(1, -4, 1, -4),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = _Option.color,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = _ColorBoxOutline
	})
	
	local _InContact
	_Option.main.InputBegan:connect(function(input)
		if input.UserInputType == MouseButton1 then
			if not _Option.mainHolder then CreateColorPickerWindow(_Option) end
			if Library.activePopup then
				Library.activePopup:Close()
			end
			local _Position = _Option.main.AbsolutePosition
			_Option.mainHolder.Position = UDim2.new(0, _Position.X - 5, 0, _Position.Y - 10)
			_Option.open = true
			_Option.mainHolder.Visible = true
			Library.activePopup = _Option
			TweenService:Create(_Option.mainHolder, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = 0, Position = UDim2.new(0, _Position.X - 5, 0, _Position.Y - 4)}):Play()
			TweenService:Create(_Option.mainHolder, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0.1), {Position = UDim2.new(0, _Position.X - 5, 0, _Position.Y + 1)}):Play()
			TweenService:Create(_Option.satval, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
			for _,object in next, _Option.mainHolder:GetDescendants() do
				if object:IsA"TextLabel" then
					TweenService:Create(object, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
				elseif object:IsA"ImageLabel" then
					TweenService:Create(object, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = 0}):Play()
				elseif object:IsA"Frame" then
					TweenService:Create(object, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
				end
			end
		elseif input.UserInputType == Enum.UserInputType.Touch then
			if not _Option.mainHolder then CreateColorPickerWindow(_Option) end
			if Library.activePopup then
				Library.activePopup:Close()
			end
			local _Position = _Option.main.AbsolutePosition
			_Option.mainHolder.Position = UDim2.new(0, _Position.X - 5, 0, _Position.Y - 10)
			_Option.open = true
			_Option.mainHolder.Visible = true
			Library.activePopup = _Option
			TweenService:Create(_Option.mainHolder, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = 0, Position = UDim2.new(0, _Position.X - 5, 0, _Position.Y - 4)}):Play()
			TweenService:Create(_Option.mainHolder, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0.1), {Position = UDim2.new(0, _Position.X - 5, 0, _Position.Y + 1)}):Play()
			TweenService:Create(_Option.satval, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
			for _,object in next, _Option.mainHolder:GetDescendants() do
				if object:IsA"TextLabel" then
					TweenService:Create(object, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
				elseif object:IsA"ImageLabel" then
					TweenService:Create(object, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = 0}):Play()
				elseif object:IsA"Frame" then
					TweenService:Create(object, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
				end
			end
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			_InContact = true
			if not _Option.open then
				TweenService:Create(_ColorBoxOutline, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(140, 140, 140)}):Play()
			end
		end
	end)
	
	_Option.main.InputEnded:connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			_InContact = true
			if not _Option.open then
				TweenService:Create(_ColorBoxOutline, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(100, 100, 100)}):Play()
			end
		end
	end)
	
	function _Option:SetColor(_NewColor)
		if self.mainHolder then
			self:updateVisuals(_NewColor)
		end
		self.visualize.ImageColor3 = _NewColor
		Library.Flags[self.flag] = _NewColor
		self.color = _NewColor
		self.callback(_NewColor)
	end
	
	function _Option:Close()
		Library.activePopup = nil
		self.open = false
		local _Position = self.main.AbsolutePosition
		TweenService:Create(self.mainHolder, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = 1, Position = UDim2.new(0, _Position.X - 5, 0, _Position.Y - 10)}):Play()
		TweenService:Create(self.satval, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
		for _,object in next, self.mainHolder:GetDescendants() do
			if object:IsA"TextLabel" then
				TweenService:Create(object, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1}):Play()
			elseif object:IsA"ImageLabel" then
				TweenService:Create(object, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = 1}):Play()
			elseif object:IsA"Frame" then
				TweenService:Create(object, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
			end
		end
		delay(0.3, function()
			if not self.open then
				self.mainHolder.Visible = false
			end 
		end)
	end
end

local function LoadOptions(_Option, _Holder)
	for _,newOption in next, _Option.options do
		if newOption.type == "label" then
			CreateLabel(newOption, _Option)
		elseif newOption.type == "toggle" then
			CreateToggle(newOption, _Option)
		elseif newOption.type == "button" then
			CreateButton(newOption, _Option)
		elseif newOption.type == "list" then
			CreateList(newOption, _Option, _Holder)
		elseif newOption.type == "box" then
			CreateBox(newOption, _Option)
		elseif newOption.type == "bind" then
			CreateBind(newOption, _Option)
		elseif newOption.type == "slider" then
			CreateSlider(newOption, _Option)
		elseif newOption.type == "color" then
			CreateColor(newOption, _Option, _Holder)
		elseif newOption.type == "folder" then
			newOption:init()
		end
	end
end

local function GetFnctions(_Parent)
	function _Parent:AddLabel(option)
		option = typeof(option) == "table" and option or {}
		option.text = tostring(option.text)
		option.type = "label"
		option.position = #self.options
		table.insert(self.options, option)
		
		return option
	end
	
	function _Parent:AddToggle(_Option)
		_Option = typeof(_Option) == "table" and _Option or {}
		_Option.text = tostring(_Option.text)
		_Option.state = typeof(_Option.state) == "boolean" and _Option.state or false
		_Option.callback = typeof(_Option.callback) == "function" and _Option.callback or function() end
		_Option.type = "toggle"
		_Option.position = #self.options
		_Option.flag = _Option.flag or _Option.text
		Library.Flags[_Option.flag] = _Option.state
		table.insert(self.options, _Option)
		
		return _Option
	end
	
	function _Parent:AddButton(_Option)
		_Option = typeof(_Option) == "table" and _Option or {}
		_Option.text = tostring(_Option.text)
		_Option.callback = typeof(_Option.callback) == "function" and _Option.callback or function() end
		_Option.type = "button"
		_Option.position = #self.options
		_Option.flag = _Option.flag or _Option.text
		table.insert(self.options, _Option)
		
		return _Option
	end
	
	function _Parent:AddBind(_Option)
		_Option = typeof(_Option) == "table" and _Option or {}
		_Option.text = tostring(_Option.text)
		_Option.key = (_Option.key and _Option.key.Name) or _Option.key or "F"
		_Option.hold = typeof(_Option.hold) == "boolean" and _Option.hold or false
		_Option.callback = typeof(_Option.callback) == "function" and _Option.callback or function() end
		_Option.type = "bind"
		_Option.position = #self.options
		_Option.flag = _Option.flag or _Option.text
		Library.Flags[_Option.flag] = _Option.key
		table.insert(self.options, _Option)
		
		return _Option
	end
	
	function _Parent:AddSlider(_Option)
		_Option = typeof(_Option) == "table" and _Option or {}
		_Option.text = tostring(_Option.text)
		_Option.min = typeof(_Option.min) == "number" and _Option.min or 0
		_Option.max = typeof(_Option.max) == "number" and _Option.max or 0
		_Option.dual = typeof(_Option.dual) == "boolean" and _Option.dual or false
		_Option.value = math.clamp(typeof(_Option.value) == "number" and _Option.value or _Option.min, _Option.min, _Option.max)
		_Option.value2 = typeof(_Option.value2) == "number" and _Option.value2 or _Option.max
		_Option.callback = typeof(_Option.callback) == "function" and _Option.callback or function() end
		_Option.float = typeof(_Option.value) == "number" and _Option.float or 1
		_Option.type = "slider"
		_Option.position = #self.options
		_Option.flag = _Option.flag or _Option.text
		Library.Flags[_Option.flag] = _Option.value
		table.insert(self.options, _Option)
		
		return _Option
	end
	
	function _Parent:AddList(_Option)
		_Option = typeof(_Option) == "table" and _Option or {}
		_Option.text = tostring(_Option.text)
		_Option.values = typeof(_Option.values) == "table" and _Option.values or {}
		_Option.value = tostring(_Option.value or _Option.values[1] or "")
		_Option.callback = typeof(_Option.callback) == "function" and _Option.callback or function() end
		_Option.open = false
		_Option.type = "list"
		_Option.position = #self.options
		_Option.flag = _Option.flag or _Option.text
		Library.Flags[_Option.flag] = _Option.value
		table.insert(self.options, _Option)
		
		return _Option
	end
	
	function _Parent:AddBox(_Option)
		_Option = typeof(_Option) == "table" and _Option or {}
		_Option.text = tostring(_Option.text)
		_Option.value = tostring(_Option.value or "")
		_Option.callback = typeof(_Option.callback) == "function" and _Option.callback or function() end
		_Option.type = "box"
		_Option.position = #self.options
		_Option.flag = _Option.flag or _Option.text
		Library.Flags[_Option.flag] = _Option.value
		table.insert(self.options, _Option)
		
		return _Option
	end
	
	function _Parent:AddColor(_Option)
		_Option = typeof(_Option) == "table" and _Option or {}
		_Option.text = tostring(_Option.text)
		_Option.color = typeof(_Option.color) == "table" and Color3.new(tonumber(_Option.color[1]), tonumber(_Option.color[2]), tonumber(_Option.color[3])) or _Option.color or Color3.new(255, 255, 255)
		_Option.callback = typeof(_Option.callback) == "function" and _Option.callback or function() end
		_Option.open = false
		_Option.type = "color"
		_Option.position = #self.options
		_Option.flag = _Option.flag or _Option.text
		Library.Flags[_Option.flag] = _Option.color
		table.insert(self.options, _Option)
		
		return _Option
	end
	
	function _Parent:AddFolder(_Title)
		local _Option = {}
		_Option.title = tostring(_Title)
		_Option.options = {}
		_Option.open = false
		_Option.type = "folder"
		_Option.position = #self.options
		table.insert(self.options, _Option)
		
		GetFnctions(_Option)
		
		function _Option:init()
			CreateOptionHolder(self.title, _Parent.content, self, true)
			LoadOptions(self, _Parent)
		end
		
		return _Option
	end
end

function Library:CreateWindow(_Title)
	local _Window = {
		title = tostring(_Title),
		options = {},
		open = true,
		canInit = true,
		init = false,
		position = #self.Windows
	}

	GetFnctions(_Window)

	table.insert(self.Windows, _Window)

	return _Window
end

local UIToggle
function Library:Init()
	self.base = self.base or self:Create("ScreenGui")
	if syn and syn.protect_gui then
		syn.protect_gui(self.base)
	elseif get_hidden_gui then
		get_hidden_gui(self.base)
	elseif gethui then
		gethui(self.base)
	else
		game:GetService"Players".LocalPlayer:Kick("Error: protect_gui function not found")
		return
	end
	self.base.Parent = game:GetService"CoreGui"
	self.base.ResetOnSpawn = true
	self.base.Name = "Alert3z"
	
	
	for _, window in next, self.windows do
		if window.canInit and not window.init then
			window.init = true
			CreateOptionHolder(window.title, self.base, window)
			LoadOptions(window)
		end
	end
	return self.base
end

function Library:Close()
	if typeof(self.base) ~= "Instance" then end
	self.open = not self.open
	if self.activePopup then
		self.activePopup:Close()
	end
	for _, window in next, self.windows do
		if window.main then
			window.main.Visible = self.open
		end
	end
end

UserInputService.InputBegan:connect(function(input)
	if input.UserInputType == MouseButton1 then
		if Library.activePopup then
			if input.Position.X < Library.activePopup.mainHolder.AbsolutePosition.X or input.Position.Y < Library.activePopup.mainHolder.AbsolutePosition.Y then
				Library.activePopup:Close()
			end
		end
		if Library.activePopup then
			if input.Position.X > Library.activePopup.mainHolder.AbsolutePosition.X + Library.activePopup.mainHolder.AbsoluteSize.X or input.Position.Y > Library.activePopup.mainHolder.AbsolutePosition.Y + Library.activePopup.mainHolder.AbsoluteSize.Y then
				Library.activePopup:Close()
			end
		end
	elseif input.UserInputType == Enum.UserInputType.Touch then
		if Library.activePopup then
			if input.Position.X < Library.activePopup.mainHolder.AbsolutePosition.X or input.Position.Y < Library.activePopup.mainHolder.AbsolutePosition.Y then
				Library.activePopup:Close()
			end
		end
		if Library.activePopup then
			if input.Position.X > Library.activePopup.mainHolder.AbsolutePosition.X + Library.activePopup.mainHolder.AbsoluteSize.X or input.Position.Y > Library.activePopup.mainHolder.AbsolutePosition.Y + Library.activePopup.mainHolder.AbsoluteSize.Y then
				Library.activePopup:Close()
			end
		end
	end
end)

UserInputService.InputChanged:connect(function(input)
	if input == DragInput and Dragging then
		UpdateFunc(input)
	end
end)

task.wait(1)
local VirtualUser=game:service'VirtualUser'
game:service('Players').LocalPlayer.Idled:connect(function()
VirtualUser:CaptureController()
VirtualUser:ClickButton2(Vector2.new())
end)

return Library
