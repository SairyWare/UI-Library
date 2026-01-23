-- ImGui.lua
-- GUI Framework for Roblox inspired by ImGui

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local ImGui = {}
ImGui.__index = ImGui

-- สีธีม (Dark Theme แบบ ImGui)
ImGui.Colors = {
    WindowBg = Color3.fromRGB(40, 40, 50),
    TitleBg = Color3.fromRGB(50, 50, 60),
    TitleBgActive = Color3.fromRGB(60, 60, 75),
    Button = Color3.fromRGB(70, 70, 90),
    ButtonHovered = Color3.fromRGB(85, 85, 110),
    ButtonActive = Color3.fromRGB(95, 95, 125),
    FrameBg = Color3.fromRGB(60, 60, 70),
    FrameBgHovered = Color3.fromRGB(70, 70, 85),
    FrameBgActive = Color3.fromRGB(75, 75, 95),
    Text = Color3.fromRGB(220, 220, 220),
    TextDisabled = Color3.fromRGB(150, 150, 150),
    CheckMark = Color3.fromRGB(100, 180, 255),
    SliderGrab = Color3.fromRGB(100, 180, 255),
    SliderGrabActive = Color3.fromRGB(120, 200, 255),
    Border = Color3.fromRGB(80, 80, 90),
    BorderShadow = Color3.fromRGB(0, 0, 0, 0.5),
    ScrollbarBg = Color3.fromRGB(40, 40, 50),
    ScrollbarGrab = Color3.fromRGB(80, 80, 100),
    ScrollbarGrabHovered = Color3.fromRGB(90, 90, 115),
    ScrollbarGrabActive = Color3.fromRGB(100, 100, 130),
}

-- Syntax Highlighting Colors สำหรับ Luau
ImGui.SyntaxColors = {
    numbers = Color3.fromHex("#79c0ff"),
    boolean = Color3.fromHex("#79c0ff"),
    operator = Color3.fromHex("#ff7b72"),
    lua = Color3.fromHex("#ff7b72"),
    rbx = Color3.fromHex("#7fcfef"),
    str = Color3.fromHex("#a5d6ff"),
    comment = Color3.fromHex("#8b949e"),
    null = Color3.fromHex("#79c0ff"),
    call = Color3.fromHex("#d2a8ff"),
    self_call = Color3.fromHex("#d2a8ff"),
    local_property = Color3.fromHex("#ff7b72"),
}

-- สร้างหน้าต่างหลัก
function ImGui:CreateWindow(config)
    local window = {}
    setmetatable(window, ImGui)
    
    window.Title = config.Title or "ImGui Window"
    window.Size = config.Size or Vector2.new(400, 500)
    window.Position = config.Position or Vector2.new(100, 100)
    window.Open = true
    window.Elements = {}
    window.ContentHeight = 0
    window.OnClose = config.OnClose
    
    -- สร้าง ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ImGui_" .. window.Title
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 999
    window.ScreenGui = screenGui
    
    -- สร้างหน้าต่างหลัก
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "Window"
    mainFrame.Size = UDim2.fromOffset(window.Size.X, window.Size.Y)
    mainFrame.Position = UDim2.fromOffset(window.Position.X, window.Position.Y)
    mainFrame.BackgroundColor3 = ImGui.Colors.WindowBg
    mainFrame.BorderSizePixel = 1
    mainFrame.BorderColor3 = ImGui.Colors.Border
    mainFrame.ClipsDescendants = true
    window.MainFrame = mainFrame
    
    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = ImGui.Colors.TitleBg
    titleBar.BorderSizePixel = 0
    titleBar.ZIndex = 2
    
    local titleText = Instance.new("TextLabel")
    titleText.Name = "Title"
    titleText.Size = UDim2.new(1, -60, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = window.Title
    titleText.TextColor3 = ImGui.Colors.Text
    titleText.TextSize = 14
    titleText.Font = Enum.Font.Code
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -30, 0, 0)
    closeButton.BackgroundColor3 = ImGui.Colors.Button
    closeButton.BorderSizePixel = 0
    closeButton.Text = "✕"
    closeButton.TextColor3 = ImGui.Colors.Text
    closeButton.TextSize = 16
    closeButton.Font = Enum.Font.Code
    
    closeButton.MouseButton1Click:Connect(function()
        window:Close()
    end)
    
    -- Content area
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(1, 0, 1, -30)
    contentFrame.Position = UDim2.new(0, 0, 0, 30)
    contentFrame.BackgroundTransparency = 1
    contentFrame.ClipsDescendants = true
    window.ContentFrame = contentFrame
    
    -- Scroll container
    local scrollContainer = Instance.new("ScrollingFrame")
    scrollContainer.Name = "ScrollContainer"
    scrollContainer.Size = UDim2.new(1, 0, 1, 0)
    scrollContainer.Position = UDim2.new(0, 0, 0, 0)
    scrollContainer.BackgroundTransparency = 1
    scrollContainer.BorderSizePixel = 0
    scrollContainer.ScrollBarThickness = 8
    scrollContainer.ScrollBarImageColor3 = ImGui.Colors.ScrollbarGrab
    scrollContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollContainer.ScrollingDirection = Enum.ScrollingDirection.Y
    scrollContainer.VerticalScrollBarInset = Enum.ScrollBarInset.Always
    window.ScrollContainer = scrollContainer
    
    -- Layout frame สำหรับ elements
    local layoutFrame = Instance.new("Frame")
    layoutFrame.Name = "Layout"
    layoutFrame.Size = UDim2.new(1, -20, 0, 0)
    layoutFrame.Position = UDim2.new(0, 10, 0, 10)
    layoutFrame.BackgroundTransparency = 1
    layoutFrame.AutomaticSize = Enum.AutomaticSize.Y
    window.LayoutFrame = layoutFrame
    
    -- UIListLayout สำหรับจัดเรียง elements
    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Padding = UDim.new(0, 8)
    uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    uiListLayout.Parent = layoutFrame
    
    -- Assembly
    titleText.Parent = titleBar
    closeButton.Parent = titleBar
    titleBar.Parent = mainFrame
    layoutFrame.Parent = scrollContainer
    scrollContainer.Parent = contentFrame
    contentFrame.Parent = mainFrame
    mainFrame.Parent = screenGui
    
    -- Make window draggable (รองรับทั้ง Desktop และ Mobile)
    local dragging = false
    local dragStart = Vector2.new(0, 0)
    local frameStart = Vector2.new(0, 0)
    
    local function startDrag(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = Vector2.new(input.Position.X, input.Position.Y)
            frameStart = Vector2.new(mainFrame.Position.X.Offset, mainFrame.Position.Y.Offset)
            
            -- Highlight title bar
            titleBar.BackgroundColor3 = ImGui.Colors.TitleBgActive
        end
    end
    
    local function endDrag(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            titleBar.BackgroundColor3 = ImGui.Colors.TitleBg
        end
    end
    
    local function updateDrag(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
                         input.UserInputType == Enum.UserInputType.Touch) then
            local dragDelta = Vector2.new(input.Position.X, input.Position.Y) - dragStart
            local newX = math.clamp(frameStart.X + dragDelta.X, 0, workspace.CurrentCamera.ViewportSize.X - window.Size.X)
            local newY = math.clamp(frameStart.Y + dragDelta.Y, 0, workspace.CurrentCamera.ViewportSize.Y - window.Size.Y)
            
            mainFrame.Position = UDim2.fromOffset(newX, newY)
        end
    end
    
    -- Connect input events
    titleBar.InputBegan:Connect(startDrag)
    titleBar.InputChanged:Connect(updateDrag)
    titleBar.InputEnded:Connect(endDrag)
    
    -- Handle touch inputs for mobile
    UserInputService.TouchStarted:Connect(function(input, processed)
        if not processed and titleBar:IsDescendantOf(game) then
            local touchPos = input.Position
            local framePos = mainFrame.AbsolutePosition
            local frameSize = mainFrame.AbsoluteSize
            
            if touchPos.X >= framePos.X and touchPos.X <= framePos.X + frameSize.X and
               touchPos.Y >= framePos.Y and touchPos.Y <= framePos.Y + 30 then
                startDrag(input)
            end
        end
    end)
    
    UserInputService.TouchMoved:Connect(updateDrag)
    UserInputService.TouchEnded:Connect(endDrag)
    
    -- สร้าง parent ให้ ScreenGui
    local player = Players.LocalPlayer
    if player then
        local playerGui = player:WaitForChild("PlayerGui")
        screenGui.Parent = playerGui
    end
    
    return window
end

-- ปิดหน้าต่าง
function ImGui:Close()
    self.Open = false
    if self.OnClose then
        self.OnClose()
    end
    self.ScreenGui:Destroy()
end

-- สร้างปุ่ม (ใช้ callback)
function ImGui:Button(config)
    local label = config.Label or "Button"
    local size = config.Size or UDim2.new(1, 0, 0, 36)
    local onClick = config.OnClick
    
    local button = Instance.new("TextButton")
    button.Name = "Button_" .. label
    button.Size = size
    button.BackgroundColor3 = ImGui.Colors.Button
    button.BorderSizePixel = 0
    button.Text = label
    button.TextColor3 = ImGui.Colors.Text
    button.TextSize = 14
    button.Font = Enum.Font.Code
    button.LayoutOrder = #self.Elements + 1
    button.AutoButtonColor = false
    
    -- Hover effect
    local originalColor = ImGui.Colors.Button
    local hoverColor = ImGui.Colors.ButtonHovered
    local activeColor = ImGui.Colors.ButtonActive
    
    local function setColor(color)
        TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = color}):Play()
    end
    
    button.MouseEnter:Connect(function()
        setColor(hoverColor)
    end)
    
    button.MouseLeave:Connect(function()
        setColor(originalColor)
    end)
    
    button.MouseButton1Down:Connect(function()
        setColor(activeColor)
    end)
    
    button.MouseButton1Up:Connect(function()
        setColor(hoverColor)
        if onClick then
            onClick()
        end
    end)
    
    -- สำหรับ Mobile Touch
    button.TouchLongPress:Connect(function()
        setColor(activeColor)
    end)
    
    button.TouchTap:Connect(function()
        setColor(hoverColor)
        if onClick then
            onClick()
        end
    end)
    
    button.Parent = self.LayoutFrame
    table.insert(self.Elements, button)
    
    return {
        SetText = function(text)
            button.Text = text
        end,
        SetVisible = function(visible)
            button.Visible = visible
        end
    }
end

-- สร้าง Toggle (ใช้ callback)
function ImGui:Toggle(config)
    local label = config.Label or "Toggle"
    local initialState = config.InitialState or false
    local onChange = config.OnChange
    
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = "Toggle_" .. label
    toggleFrame.Size = UDim2.new(1, 0, 0, 36)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.LayoutOrder = #self.Elements + 1
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = UDim2.fromOffset(20, 20)
    toggleButton.Position = UDim2.new(0, 0, 0.5, -10)
    toggleButton.BackgroundColor3 = ImGui.Colors.FrameBg
    toggleButton.BorderSizePixel = 0
    toggleButton.Text = ""
    toggleButton.AutoButtonColor = false
    
    local checkLabel = Instance.new("TextLabel")
    checkLabel.Name = "Label"
    checkLabel.Size = UDim2.new(1, -30, 1, 0)
    checkLabel.Position = UDim2.new(0, 30, 0, 0)
    checkLabel.BackgroundTransparency = 1
    checkLabel.Text = label
    checkLabel.TextColor3 = ImGui.Colors.Text
    checkLabel.TextSize = 14
    checkLabel.Font = Enum.Font.Code
    checkLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Checkmark
    local checkmark = Instance.new("Frame")
    checkmark.Name = "Checkmark"
    checkmark.Size = UDim2.new(0, 10, 0, 10)
    checkmark.Position = UDim2.new(0.5, -5, 0.5, -5)
    checkmark.BackgroundColor3 = ImGui.Colors.CheckMark
    checkmark.BorderSizePixel = 0
    
    local state = initialState
    
    -- Function to update toggle state
    local function updateToggle(newState)
        state = newState
        
        if state then
            TweenService:Create(toggleButton, TweenInfo.new(0.2), {BackgroundColor3 = ImGui.Colors.FrameBgActive}):Play()
            TweenService:Create(checkmark, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
        else
            TweenService:Create(toggleButton, TweenInfo.new(0.2), {BackgroundColor3 = ImGui.Colors.FrameBg}):Play()
            TweenService:Create(checkmark, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
        end
        
        if onChange then
            onChange(state)
        end
    end
    
    -- Toggle on click
    toggleButton.MouseButton1Click:Connect(function()
        updateToggle(not state)
    end)
    
    -- Hover effect
    toggleButton.MouseEnter:Connect(function()
        if not state then
            TweenService:Create(toggleButton, TweenInfo.new(0.1), {BackgroundColor3 = ImGui.Colors.FrameBgHovered}):Play()
        end
    end)
    
    toggleButton.MouseLeave:Connect(function()
        if not state then
            TweenService:Create(toggleButton, TweenInfo.new(0.1), {BackgroundColor3 = ImGui.Colors.FrameBg}):Play()
        end
    end)
    
    -- สำหรับ Mobile Touch
    toggleButton.TouchTap:Connect(function()
        updateToggle(not state)
    end)
    
    -- Initialize
    checkmark.BackgroundTransparency = state and 0 or 1
    toggleButton.BackgroundColor3 = state and ImGui.Colors.FrameBgActive or ImGui.Colors.FrameBg
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = toggleButton
    
    local checkCorner = Instance.new("UICorner")
    checkCorner.CornerRadius = UDim.new(0, 2)
    checkCorner.Parent = checkmark
    
    -- Assembly
    checkmark.Parent = toggleButton
    toggleButton.Parent = toggleFrame
    checkLabel.Parent = toggleFrame
    toggleFrame.Parent = self.LayoutFrame
    
    table.insert(self.Elements, toggleFrame)
    
    return {
        GetState = function() return state end,
        SetState = updateToggle,
        SetLabel = function(text)
            checkLabel.Text = text
        end
    }
end

-- สร้าง Text Label
function ImGui:TextLabel(config)
    local text = config.Text or ""
    local size = config.Size or UDim2.new(1, 0, 0, 0)
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = size
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = ImGui.Colors.Text
    label.TextSize = 14
    label.Font = Enum.Font.Code
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.LayoutOrder = #self.Elements + 1
    label.TextWrapped = true
    label.AutomaticSize = size == UDim2.new(1, 0, 0, 0) and Enum.AutomaticSize.Y or Enum.AutomaticSize.None
    
    label.Parent = self.LayoutFrame
    table.insert(self.Elements, label)
    
    return {
        SetText = function(newText)
            label.Text = newText
        end,
        SetColor = function(color)
            label.TextColor3 = color
        end
    }
end

-- สร้าง Text Input (ใช้ callback)
function ImGui:TextInput(config)
    local label = config.Label
    local placeholder = config.Placeholder or ""
    local initialText = config.Text or ""
    local onChange = config.OnChange
    local onFocusLost = config.OnFocusLost
    
    local inputFrame = Instance.new("Frame")
    inputFrame.Name = "Input"
    inputFrame.Size = UDim2.new(1, 0, 0, label and 56 or 36)
    inputFrame.BackgroundTransparency = 1
    inputFrame.LayoutOrder = #self.Elements + 1
    
    local labelText
    if label then
        labelText = Instance.new("TextLabel")
        labelText.Name = "Label"
        labelText.Size = UDim2.new(1, 0, 0, 20)
        labelText.Position = UDim2.new(0, 0, 0, 0)
        labelText.BackgroundTransparency = 1
        labelText.Text = label
        labelText.TextColor3 = ImGui.Colors.Text
        labelText.TextSize = 12
        labelText.Font = Enum.Font.Code
        labelText.TextXAlignment = Enum.TextXAlignment.Left
        labelText.Parent = inputFrame
    end
    
    local textBox = Instance.new("TextBox")
    textBox.Name = "TextBox"
    textBox.Size = UDim2.new(1, 0, 0, 36)
    textBox.Position = label and UDim2.new(0, 0, 0, 20) or UDim2.new(0, 0, 0, 0)
    textBox.BackgroundColor3 = ImGui.Colors.FrameBg
    textBox.BorderSizePixel = 0
    textBox.Text = initialText
    textBox.PlaceholderText = placeholder
    textBox.TextColor3 = ImGui.Colors.Text
    textBox.PlaceholderColor3 = ImGui.Colors.TextDisabled
    textBox.TextSize = 14
    textBox.Font = Enum.Font.Code
    textBox.ClearTextOnFocus = false
    textBox.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Add padding
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 12)
    padding.Parent = textBox
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = textBox
    
    -- Focus effects
    textBox.Focused:Connect(function()
        TweenService:Create(textBox, TweenInfo.new(0.2), {BackgroundColor3 = ImGui.Colors.FrameBgActive}):Play()
    end)
    
    textBox.FocusLost:Connect(function(enterPressed)
        TweenService:Create(textBox, TweenInfo.new(0.2), {BackgroundColor3 = ImGui.Colors.FrameBg}):Play()
        if onFocusLost then
            onFocusLost(textBox.Text, enterPressed)
        end
    end)
    
    -- Text change
    if onChange then
        textBox:GetPropertyChangedSignal("Text"):Connect(function()
            onChange(textBox.Text)
        end)
    end
    
    textBox.Parent = inputFrame
    inputFrame.Parent = self.LayoutFrame
    
    table.insert(self.Elements, inputFrame)
    
    return {
        GetText = function() return textBox.Text end,
        SetText = function(newText) 
            textBox.Text = newText
        end,
        SetPlaceholder = function(ph)
            textBox.PlaceholderText = ph
        end
    }
end

-- Syntax Highlighter สำหรับ Luau
local function createKeywordSet(keywords)
    local keywordSet = {}
    for _, keyword in ipairs(keywords) do
        keywordSet[keyword] = true
    end
    return keywordSet
end

local keywords = {
    lua = {
        "and", "break", "or", "else", "elseif", "if", "then", "until", "repeat", 
        "while", "do", "for", "in", "end", "local", "return", "function", "export"
    },
    rbx = {
        "game", "workspace", "script", "math", "string", "table", "task", "wait", 
        "select", "next", "Enum", "error", "warn", "tick", "assert", "shared", 
        "loadstring", "tonumber", "tostring", "type", "typeof", "unpack", "print", 
        "Instance", "CFrame", "Vector3", "Vector2", "Color3", "UDim", "UDim2", 
        "Ray", "BrickColor", "OverlapParams", "RaycastParams", "Axes", "Random", 
        "Region3", "Rect", "TweenInfo", "collectgarbage", "not", "utf8", "pcall", 
        "xpcall", "_G", "setmetatable", "getmetatable", "os", "pairs", "ipairs"
    },
    operators = {
        "#", "+", "-", "*", "%", "/", "^", "=", "~", "=", "<", ">",
    }
}

local luaSet = createKeywordSet(keywords.lua)
local rbxSet = createKeywordSet(keywords.rbx)
local operatorsSet = createKeywordSet(keywords.operators)

local function highlightLuauCode(source)
    local tokens = {}
    local multiStrings = {}
    local currentToken = ""
    
    local index = 1
    source = source:gsub("%[%[.-%]%]", function(str)
        local placeholder = "__MULTISTR_" .. index .. "__"
        multiStrings[placeholder] = str
        index = index + 1
        return placeholder
    end)
    
    local inString = false
    local inComment = false
    local commentPersist = false
    
    for i = 1, #source do
        local character = source:sub(i, i)
        
        if inComment then
            if character == "\n" and not commentPersist then
                table.insert(tokens, currentToken)
                table.insert(tokens, character)
                currentToken = ""
                inComment = false
            elseif source:sub(i - 1, i) == "]]" and commentPersist then
                currentToken = currentToken .. "]"
                table.insert(tokens, currentToken)
                currentToken = ""
                inComment = false
                commentPersist = false
            else
                currentToken = currentToken .. character
            end
        elseif inString then
            if character == inString and source:sub(i - 1, i - 1) ~= "\\" or character == "\n" then
                currentToken = currentToken .. character
                inString = false
            else
                currentToken = currentToken .. character
            end
        else
            local foundPlaceholder = source:sub(i):match("^__MULTISTR_%d+__")
            if foundPlaceholder then
                table.insert(tokens, currentToken)
                table.insert(tokens, foundPlaceholder)
                i = i + #foundPlaceholder - 1
            elseif source:sub(i, i + 1) == "--" then
                table.insert(tokens, currentToken)
                currentToken = "-"
                inComment = true
                commentPersist = source:sub(i + 2, i + 3) == "[["
            elseif character == "\"" or character == "\'" then
                table.insert(tokens, currentToken)
                currentToken = character
                inString = character
            elseif operatorsSet[character] then
                table.insert(tokens, currentToken)
                table.insert(tokens, character)
                currentToken = ""
            elseif character:match("[%w_]") then
                currentToken = currentToken .. character
            else
                table.insert(tokens, currentToken)
                table.insert(tokens, character)
                currentToken = ""
            end
        end
    end
    
    table.insert(tokens, currentToken)
    
    local function getHighlight(token, prevToken, nextToken)
        if ImGui.SyntaxColors[token .. "_color"] then
            return ImGui.SyntaxColors[token .. "_color"]
        end
        
        if tonumber(token) then
            return ImGui.SyntaxColors.numbers
        elseif token == "nil" then
            return ImGui.SyntaxColors.null
        elseif token:sub(1, 2) == "--" then
            return ImGui.SyntaxColors.comment
        elseif operatorsSet[token] then
            return ImGui.SyntaxColors.operator
        elseif luaSet[token] then
            return ImGui.SyntaxColors.lua
        elseif rbxSet[token] then
            return ImGui.SyntaxColors.rbx
        elseif token:sub(1, 1) == "\"" or token:sub(1, 1) == "\'" then
            return ImGui.SyntaxColors.str
        elseif token == "true" or token == "false" then
            return ImGui.SyntaxColors.boolean
        end
        
        if nextToken == "(" then
            if prevToken == ":" then
                return ImGui.SyntaxColors.self_call
            end
            return ImGui.SyntaxColors.call
        end
        
        if prevToken == "." then
            if tokens[#tokens-2] == "Enum" then
                return ImGui.SyntaxColors.rbx
            end
            return ImGui.SyntaxColors.local_property
        end
    end
    
    local highlighted = {}
    
    for i, token in ipairs(tokens) do
        if multiStrings[token] then
            local syntax = string.format(
                '<font color="#%s">%s</font>',
                ImGui.SyntaxColors.str:ToHex(),
                multiStrings[token]:gsub("<", "&lt;"):gsub(">", "&gt;")
            )
            table.insert(highlighted, syntax)
        elseif token ~= "" then
            local prevToken = tokens[i-1]
            local nextToken = tokens[i+1]
            local highlight = getHighlight(token, prevToken, nextToken)
            
            if highlight then
                local syntax = string.format(
                    '<font color="#%s">%s</font>',
                    highlight:ToHex(),
                    token:gsub("<", "&lt;"):gsub(">", "&gt;")
                )
                table.insert(highlighted, syntax)
            else
                table.insert(highlighted, token:gsub("<", "&lt;"):gsub(">", "&gt;"))
            end
        end
    end
    
    return table.concat(highlighted)
end

-- สร้าง Code Viewer (ใช้ callback)
function ImGui:CodeView(config)
    local title = config.Title or "Code View"
    local code = config.Code or "-- print('Hello World')"
    local readonly = config.ReadOnly or false
    local onCopy = config.OnCopy
    local onChange = config.OnChange
    local size = config.Size or UDim2.new(1, 0, 0, 200)
    
    local container = Instance.new("Frame")
    container.Name = "CodeView"
    container.Size = size
    container.BackgroundTransparency = 1
    container.LayoutOrder = #self.Elements + 1
    container.ClipsDescendants = true
    
    -- Main code frame
    local codeFrame = Instance.new("Frame")
    codeFrame.Name = "CodeFrame"
    codeFrame.Size = UDim2.new(1, 0, 1, 0)
    codeFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    codeFrame.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = codeFrame
    
    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 32)
    titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    titleBar.BorderSizePixel = 0
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -100, 1, 0)
    titleLabel.Position = UDim2.new(0, 12, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = ImGui.Colors.Text
    titleLabel.TextSize = 12
    titleLabel.Font = Enum.Font.Code
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local copyButton = Instance.new("TextButton")
    copyButton.Name = "CopyButton"
    copyButton.Size = UDim2.new(0, 80, 0, 24)
    copyButton.Position = UDim2.new(1, -84, 0.5, -12)
    copyButton.BackgroundColor3 = ImGui.Colors.Button
    copyButton.BorderSizePixel = 0
    copyButton.Text = "Copy"
    copyButton.TextColor3 = ImGui.Colors.Text
    copyButton.TextSize = 12
    copyButton.Font = Enum.Font.Code
    copyButton.AutoButtonColor = false
    
    local copyCorner = Instance.new("UICorner")
    copyCorner.CornerRadius = UDim.new(0, 4)
    copyCorner.Parent = copyButton
    
    -- Code area
    local codeArea = Instance.new("Frame")
    codeArea.Name = "CodeArea"
    codeArea.Size = UDim2.new(1, 0, 1, -32)
    codeArea.Position = UDim2.new(0, 0, 0, 32)
    codeArea.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    codeArea.BorderSizePixel = 0
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ScrollFrame"
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.Position = UDim2.new(0, 0, 0, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.ScrollBarImageColor3 = ImGui.Colors.ScrollbarGrab
    scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.XY
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local codeText
    if readonly then
        codeText = Instance.new("TextLabel")
    else
        codeText = Instance.new("TextBox")
        codeText.ClearTextOnFocus = false
        codeText.MultiLine = true
    end
    
    codeText.Name = "CodeText"
    codeText.Size = UDim2.new(1, -20, 0, 0)
    codeText.Position = UDim2.new(0, 10, 0, 10)
    codeText.BackgroundTransparency = 1
    codeText.Text = code
    codeText.TextColor3 = ImGui.Colors.Text
    codeText.TextSize = 12
    codeText.Font = Enum.Font.Code
    codeText.TextXAlignment = Enum.TextXAlignment.Left
    codeText.TextYAlignment = Enum.TextYAlignment.Top
    codeText.RichText = true
    codeText.AutomaticSize = Enum.AutomaticSize.Y
    
    -- Apply initial highlighting
    local function updateHighlighting()
        if not codeText:IsA("TextBox") or not codeText:IsFocused() then
            codeText.Text = highlightLuauCode(codeText.Text)
        end
    end
    
    updateHighlighting()
    
    -- Update highlighting when text changes (for editable code)
    if not readonly then
        codeText:GetPropertyChangedSignal("Text"):Connect(function()
            if not codeText:IsFocused() then
                updateHighlighting()
            end
        end)
        
        codeText.FocusLost:Connect(function()
            updateHighlighting()
            if onChange then
                onChange(codeText.Text)
            end
        end)
    end
    
    -- Copy button functionality
    local isCopied = false
    copyButton.MouseButton1Click:Connect(function()
        if not isCopied then
            -- Get plain text without HTML tags
            local plainText = codeText.Text:gsub("<[^>]+>", "")
            plainText = plainText:gsub("&lt;", "<")
            plainText = plainText:gsub("&gt;", ">")
            plainText = plainText:gsub("&amp;", "&")
            
            if setclipboard then
                setclipboard(plainText)
            else
                -- Fallback for Roblox Studio
                print("Code copied to clipboard (simulated):")
                print(plainText)
            end
            
            if onCopy then
                onCopy(plainText)
            end
            
            -- Visual feedback
            copyButton.Text = "Copied!"
            TweenService:Create(copyButton, TweenInfo.new(0.2), {BackgroundColor3 = ImGui.Colors.CheckMark}):Play()
            
            isCopied = true
            wait(1.5)
            
            copyButton.Text = "Copy"
            TweenService:Create(copyButton, TweenInfo.new(0.2), {BackgroundColor3 = ImGui.Colors.Button}):Play()
            isCopied = false
        end
    end)
    
    -- Assembly
    titleLabel.Parent = titleBar
    copyButton.Parent = titleBar
    titleBar.Parent = codeFrame
    
    codeText.Parent = scrollFrame
    scrollFrame.Parent = codeArea
    codeArea.Parent = codeFrame
    codeFrame.Parent = container
    container.Parent = self.LayoutFrame
    
    table.insert(self.Elements, container)
    
    return {
        GetCode = function()
            local plainText = codeText.Text:gsub("<[^>]+>", "")
            plainText = plainText:gsub("&lt;", "<")
            plainText = plainText:gsub("&gt;", ">")
            plainText = plainText:gsub("&amp;", "&")
            return plainText
        end,
        SetCode = function(newCode)
            codeText.Text = newCode
            updateHighlighting()
        end,
        SetTitle = function(newTitle)
            titleLabel.Text = newTitle
        end,
        UpdateHighlighting = updateHighlighting
    }
end

-- แยก Line สำหรับ UI
function ImGui:Separator()
    local separator = Instance.new("Frame")
    separator.Name = "Separator"
    separator.Size = UDim2.new(1, 0, 0, 1)
    separator.BackgroundColor3 = ImGui.Colors.Border
    separator.BorderSizePixel = 0
    separator.LayoutOrder = #self.Elements + 1
    
    separator.Parent = self.LayoutFrame
    table.insert(self.Elements, separator)
    
    return {
        SetColor = function(color)
            separator.BackgroundColor3 = color
        end,
        SetVisible = function(visible)
            separator.Visible = visible
        end
    }
end

return ImGui