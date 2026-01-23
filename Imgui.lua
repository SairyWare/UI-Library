-- ImGuiStyle.lua
-- GUI Framework for Roblox inspired by ImGui

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

-- สร้างฟอนต์
function ImGui.CreateFont(name, size)
    return Enum.Font.Code
end

-- สร้างหน้าต่างหลัก
function ImGui:CreateWindow(title, size, position)
    local window = {}
    setmetatable(window, ImGui)
    
    window.Title = title
    window.Size = size or Vector2.new(400, 500)
    window.Position = position or Vector2.new(100, 100)
    window.Open = true
    window.Elements = {}
    window.Cursor = Vector2.new(10, 30)
    window.Padding = 10
    window.ItemSpacing = 5
    window.ScrollOffset = 0
    window.ContentHeight = 0
    
    -- สร้าง ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ImGui_" .. title
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
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
    titleBar.Size = UDim2.new(1, 0, 0, 25)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = ImGui.Colors.TitleBg
    titleBar.BorderSizePixel = 0
    titleBar.ZIndex = 2
    
    local titleText = Instance.new("TextLabel")
    titleText.Name = "Title"
    titleText.Size = UDim2.new(1, -60, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = title
    titleText.TextColor3 = ImGui.Colors.Text
    titleText.TextSize = 14
    titleText.Font = Enum.Font.Code
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 25, 0, 25)
    closeButton.Position = UDim2.new(1, -30, 0, 0)
    closeButton.BackgroundColor3 = ImGui.Colors.Button
    closeButton.BorderSizePixel = 0
    closeButton.Text = "X"
    closeButton.TextColor3 = ImGui.Colors.Text
    closeButton.TextSize = 14
    closeButton.Font = Enum.Font.Code
    
    closeButton.MouseButton1Click:Connect(function()
        window:Close()
    end)
    
    -- Content area
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(1, 0, 1, -25)
    contentFrame.Position = UDim2.new(0, 0, 0, 25)
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
    window.ScrollContainer = scrollContainer
    
    -- Layout frame สำหรับ elements
    local layoutFrame = Instance.new("Frame")
    layoutFrame.Name = "Layout"
    layoutFrame.Size = UDim2.new(1, -window.Padding * 2, 0, 0)
    layoutFrame.Position = UDim2.new(0, window.Padding, 0, window.Padding)
    layoutFrame.BackgroundTransparency = 1
    layoutFrame.AutomaticSize = Enum.AutomaticSize.Y
    window.LayoutFrame = layoutFrame
    
    -- UIListLayout สำหรับจัดเรียง elements
    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Padding = UDim.new(0, window.ItemSpacing)
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
    
    -- Make window draggable
    local dragging = false
    local dragStart = Vector2.new(0, 0)
    local frameStart = Vector2.new(0, 0)
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = Vector2.new(input.Position.X, input.Position.Y)
            frameStart = Vector2.new(mainFrame.Position.X.Offset, mainFrame.Position.Y.Offset)
        end
    end)
    
    titleBar.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local dragDelta = Vector2.new(input.Position.X, input.Position.Y) - dragStart
            mainFrame.Position = UDim2.fromOffset(frameStart.X + dragDelta.X, frameStart.Y + dragDelta.Y)
        end
    end)
    
    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- สร้าง parent ให้ ScreenGui
    if game:GetService("Players").LocalPlayer then
        screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end
    
    return window
end

-- ปิดหน้าต่าง
function ImGui:Close()
    self.Open = false
    self.ScreenGui:Destroy()
end

-- สร้างปุ่ม
function ImGui:Button(label, size)
    size = size or Vector2.new(100, 30)
    
    local button = Instance.new("TextButton")
    button.Name = "Button_" .. label
    button.Size = UDim2.fromOffset(size.X, size.Y)
    button.BackgroundColor3 = ImGui.Colors.Button
    button.BorderSizePixel = 0
    button.Text = label
    button.TextColor3 = ImGui.Colors.Text
    button.TextSize = 14
    button.Font = Enum.Font.Code
    button.LayoutOrder = #self.Elements + 1
    
    -- Hover effect
    local originalColor = ImGui.Colors.Button
    local hoverColor = ImGui.Colors.ButtonHovered
    local activeColor = ImGui.Colors.ButtonActive
    
    button.MouseEnter:Connect(function()
        if not button:GetAttribute("Active") then
            button.BackgroundColor3 = hoverColor
        end
    end)
    
    button.MouseLeave:Connect(function()
        if not button:GetAttribute("Active") then
            button.BackgroundColor3 = originalColor
        end
    end)
    
    button.MouseButton1Down:Connect(function()
        button.BackgroundColor3 = activeColor
        button:SetAttribute("Active", true)
    end)
    
    button.MouseButton1Up:Connect(function()
        button.BackgroundColor3 = hoverColor
        button:SetAttribute("Active", false)
    end)
    
    button.Parent = self.LayoutFrame
    table.insert(self.Elements, button)
    
    return button
end

-- สร้าง Toggle (checkbox)
function ImGui:Toggle(label, state)
    state = state or false
    
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = "Toggle_" .. label
    toggleFrame.Size = UDim2.new(1, 0, 0, 30)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.LayoutOrder = #self.Elements + 1
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = UDim2.fromOffset(20, 20)
    toggleButton.Position = UDim2.new(0, 0, 0.5, -10)
    toggleButton.BackgroundColor3 = ImGui.Colors.FrameBg
    toggleButton.BorderSizePixel = 0
    toggleButton.Text = ""
    
    local checkLabel = Instance.new("TextLabel")
    checkLabel.Name = "Label"
    checkLabel.Size = UDim2.new(1, -30, 1, 0)
    checkLabel.Position = UDim2.new(0, 25, 0, 0)
    checkLabel.BackgroundTransparency = 1
    checkLabel.Text = label
    checkLabel.TextColor3 = ImGui.Colors.Text
    checkLabel.TextSize = 14
    checkLabel.Font = Enum.Font.Code
    checkLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Checkmark (แสดงเมื่อ state = true)
    local checkmark = Instance.new("TextLabel")
    checkmark.Name = "Checkmark"
    checkmark.Size = UDim2.new(1, 0, 1, 0)
    checkmark.Position = UDim2.new(0, 0, 0, 0)
    checkmark.BackgroundTransparency = 1
    checkmark.Text = "✓"
    checkmark.TextColor3 = ImGui.Colors.CheckMark
    checkmark.TextSize = 16
    checkmark.Font = Enum.Font.Code
    checkmark.Visible = state
    
    -- Function to update toggle state
    local function updateToggle(newState)
        state = newState
        checkmark.Visible = state
        
        if state then
            toggleButton.BackgroundColor3 = ImGui.Colors.FrameBgActive
        else
            toggleButton.BackgroundColor3 = ImGui.Colors.FrameBg
        end
    end
    
    -- Toggle on click
    toggleButton.MouseButton1Click:Connect(function()
        updateToggle(not state)
    end)
    
    -- Hover effect
    toggleButton.MouseEnter:Connect(function()
        if not state then
            toggleButton.BackgroundColor3 = ImGui.Colors.FrameBgHovered
        end
    end)
    
    toggleButton.MouseLeave:Connect(function()
        if not state then
            toggleButton.BackgroundColor3 = ImGui.Colors.FrameBg
        end
    end)
    
    -- Initialize
    updateToggle(state)
    
    -- Assembly
    checkmark.Parent = toggleButton
    toggleButton.Parent = toggleFrame
    checkLabel.Parent = toggleFrame
    toggleFrame.Parent = self.LayoutFrame
    
    table.insert(self.Elements, {
        Frame = toggleFrame,
        Button = toggleButton,
        Label = checkLabel,
        GetState = function() return state end,
        SetState = updateToggle
    })
    
    return {
        GetState = function() return state end,
        SetState = updateToggle,
        Button = toggleButton
    }
end

-- สร้าง Text Label
function ImGui:TextLabel(text)
    local label = Instance.new("TextLabel")
    label.Name = "Label_" .. string.sub(text, 1, 10)
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = ImGui.Colors.Text
    label.TextSize = 14
    label.Font = Enum.Font.Code
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.LayoutOrder = #self.Elements + 1
    label.TextWrapped = true
    label.AutomaticSize = Enum.AutomaticSize.Y
    
    label.Parent = self.LayoutFrame
    table.insert(self.Elements, label)
    
    return label
end

-- สร้าง Text Input
function ImGui:TextInput(label, placeholder, text)
    text = text or ""
    placeholder = placeholder or ""
    
    local inputFrame = Instance.new("Frame")
    inputFrame.Name = "Input_" .. label
    inputFrame.Size = UDim2.new(1, 0, 0, 50)
    inputFrame.BackgroundTransparency = 1
    inputFrame.LayoutOrder = #self.Elements + 1
    
    local labelText
    if label and label ~= "" then
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
    textBox.Size = UDim2.new(1, 0, 0, 30)
    textBox.Position = labelText and UDim2.new(0, 0, 0, 20) or UDim2.new(0, 0, 0, 0)
    textBox.BackgroundColor3 = ImGui.Colors.FrameBg
    textBox.BorderSizePixel = 0
    textBox.Text = text
    textBox.PlaceholderText = placeholder
    textBox.TextColor3 = ImGui.Colors.Text
    textBox.PlaceholderColor3 = ImGui.Colors.TextDisabled
    textBox.TextSize = 14
    textBox.Font = Enum.Font.Code
    textBox.ClearTextOnFocus = false
    textBox.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Add padding
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 8)
    padding.PaddingRight = UDim.new(0, 8)
    padding.Parent = textBox
    
    -- Focus effects
    textBox.Focused:Connect(function()
        textBox.BackgroundColor3 = ImGui.Colors.FrameBgActive
    end)
    
    textBox.FocusLost:Connect(function()
        textBox.BackgroundColor3 = ImGui.Colors.FrameBg
    end)
    
    textBox.Parent = inputFrame
    inputFrame.Parent = self.LayoutFrame
    
    table.insert(self.Elements, {
        Frame = inputFrame,
        TextBox = textBox,
        GetText = function() return textBox.Text end,
        SetText = function(newText) textBox.Text = newText end
    })
    
    return {
        GetText = function() return textBox.Text end,
        SetText = function(newText) textBox.Text = newText end,
        TextBox = textBox
    }
end

-- สร้าง Code Viewer พร้อม Syntax Highlighting สำหรับ Luau
function ImGui:CodeView(title, code, readonly)
    code = code or ""
    readonly = readonly or false
    
    local codeFrame = Instance.new("Frame")
    codeFrame.Name = "CodeView_" .. title
    codeFrame.Size = UDim2.new(1, 0, 0, 200)
    codeFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    codeFrame.BorderSizePixel = 0
    codeFrame.LayoutOrder = #self.Elements + 1
    codeFrame.ClipsDescendants = true
    
    local titleLabel
    if title and title ~= "" then
        titleLabel = Instance.new("TextLabel")
        titleLabel.Name = "Title"
        titleLabel.Size = UDim2.new(1, 0, 0, 25)
        titleLabel.Position = UDim2.new(0, 0, 0, 0)
        titleLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        titleLabel.BorderSizePixel = 0
        titleLabel.Text = title
        titleLabel.TextColor3 = ImGui.Colors.Text
        titleLabel.TextSize = 12
        titleLabel.Font = Enum.Font.Code
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local padding = Instance.new("UIPadding")
        padding.PaddingLeft = UDim.new(0, 8)
        padding.Parent = titleLabel
        
        titleLabel.Parent = codeFrame
    end
    
    -- Scroll container สำหรับโค้ด
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "CodeScroll"
    scrollFrame.Size = UDim2.new(1, 0, 1, titleLabel and -25 or 0)
    scrollFrame.Position = UDim2.new(0, 0, 0, titleLabel and 25 or 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 8
    scrollFrame.ScrollBarImageColor3 = ImGui.Colors.ScrollbarGrab
    scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    -- Text box สำหรับโค้ด
    local codeTextBox
    if readonly then
        codeTextBox = Instance.new("TextLabel")
        codeTextBox.Name = "CodeLabel"
    else
        codeTextBox = Instance.new("TextBox")
        codeTextBox.Name = "CodeTextBox"
        codeTextBox.ClearTextOnFocus = false
        codeTextBox.MultiLine = true
    end
    
    codeTextBox.Size = UDim2.new(1, -10, 0, 0)
    codeTextBox.Position = UDim2.new(0, 5, 0, 5)
    codeTextBox.BackgroundTransparency = 1
    codeTextBox.Text = code
    codeTextBox.TextColor3 = ImGui.Colors.Text
    codeTextBox.TextSize = 12
    codeTextBox.Font = Enum.Font.Code
    codeTextBox.TextXAlignment = Enum.TextXAlignment.Left
    codeTextBox.TextYAlignment = Enum.TextYAlignment.Top
    codeTextBox.TextWrapped = false
    codeTextBox.RichText = true
    codeTextBox.AutomaticSize = Enum.AutomaticSize.Y
    
    -- Apply syntax highlighting
    local function applySyntaxHighlighting(text)
        -- Luau syntax highlighting rules
        local keywords = {
            "and", "break", "do", "else", "elseif", "end", "false", "for", 
            "function", "if", "in", "local", "nil", "not", "or", "repeat", 
            "return", "then", "true", "until", "while"
        }
        
        local builtin = {
            "print", "warn", "error", "assert", "type", "typeof", "tostring",
            "tonumber", "rawget", "rawset", "rawequal", "getmetatable", 
            "setmetatable", "pcall", "xpcall", "select", "require", "spawn",
            "delay", "task", "wait", "Vector3", "CFrame", "Instance", "UDim2"
        }
        
        -- Escape HTML characters
        text = text:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
        
        -- Highlight comments
        text = text:gsub("%-%-[^\n]*", "<font color='#6A9955'>%0</font>")
        
        -- Highlight multiline comments
        text = text:gsub("%-%-%[%[.-%]%]", function(match)
            return "<font color='#6A9955'>" .. match .. "</font>"
        end)
        
        -- Highlight strings
        text = text:gsub("(['\"])[^'\"]*%1", function(match)
            return "<font color='#CE9178'>" .. match .. "</font>"
        end)
        
        -- Highlight numbers
        text = text:gsub("[-+]?%d+%.?%d*", function(match)
            return "<font color='#B5CEA8'>" .. match .. "</font>"
        end)
        
        -- Highlight keywords
        for _, keyword in ipairs(keywords) do
            text = text:gsub("%f[%a_]" .. keyword .. "%f[^%a_]", function(match)
                return "<font color='#569CD6'>" .. match .. "</font>"
            end)
        end
        
        -- Highlight built-in functions
        for _, func in ipairs(builtin) do
            text = text:gsub("%f[%a_]" .. func .. "%f[^%a_]", function(match)
                return "<font color='#DCDCAA'>" .. match .. "</font>"
            end)
        end
        
        return text
    end
    
    if readonly then
        codeTextBox.Text = applySyntaxHighlighting(code)
    else
        -- Update highlighting when text changes
        codeTextBox:GetPropertyChangedSignal("Text"):Connect(function()
            codeTextBox.Text = applySyntaxHighlighting(codeTextBox.Text)
        end)
        codeTextBox.Text = applySyntaxHighlighting(code)
    end
    
    codeTextBox.Parent = scrollFrame
    scrollFrame.Parent = codeFrame
    codeFrame.Parent = self.LayoutFrame
    
    table.insert(self.Elements, {
        Frame = codeFrame,
        TextBox = codeTextBox,
        GetText = function() 
            if readonly then
                return codeTextBox.Text
            else
                -- Remove HTML tags to get plain text
                local text = codeTextBox.Text
                text = text:gsub("<[^>]+>", "")
                text = text:gsub("&lt;", "<")
                text = text:gsub("&gt;", ">")
                text = text:gsub("&amp;", "&")
                return text
            end
        end,
        SetText = function(newText) 
            if readonly then
                codeTextBox.Text = applySyntaxHighlighting(newText)
            else
                codeTextBox.Text = applySyntaxHighlighting(newText)
            end
        end
    })
    
    return {
        GetText = function() 
            if readonly then
                return codeTextBox.Text
            else
                local text = codeTextBox.Text
                text = text:gsub("<[^>]+>", "")
                text = text:gsub("&lt;", "<")
                text = text:gsub("&gt;", ">")
                text = text:gsub("&amp;", "&")
                return text
            end
        end,
        SetText = function(newText) 
            if readonly then
                codeTextBox.Text = applySyntaxHighlighting(newText)
            else
                codeTextBox.Text = applySyntaxHighlighting(newText)
            end
        end,
        Frame = codeFrame,
        TextBox = codeTextBox
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
    
    return separator
end

return ImGui