--[[
    CrystalUI - TextBox Component
    Компонент текстового поля для ввода текста
]]

local TextBox = {}
TextBox.__index = TextBox

local TweenService = game:GetService("TweenService")

function TextBox.new(options, uiLibrary, window)
    local self = setmetatable({}, TextBox)
    
    -- Параметры по умолчанию
    options = options or {}
    self.Name = options.Name or "TextBox"
    self.Description = options.Description or ""
    self.Placeholder = options.Placeholder or "Введите текст..."
    self.Default = options.Default or ""
    self.ClearOnFocus = options.ClearOnFocus or false
    self.MultiLine = options.MultiLine or false
    self.Callback = options.Callback or function() end
    self.UILibrary = uiLibrary
    self.Window = window
    self.Value = self.Default
    
    -- Создание UI элементов
    self:_CreateUI()
    
    -- Установка начального значения
    self:SetValue(self.Default, true) -- true = без вызова callback
    
    return self
end

function TextBox:_CreateUI()
    local theme = self.UILibrary.Themes[self.Window.Theme]
    
    -- Вычисляем высоту в зависимости от наличия описания и многострочного режима
    local containerHeight = 40
    if self.Description ~= "" then containerHeight = containerHeight + 20 end
    if self.MultiLine then containerHeight = containerHeight + 40 end
    
    -- Основной контейнер
    self.Container = Instance.new("Frame")
    self.Container.Name = self.Name:gsub("%s+", "") .. "TextBox"
    self.Container.Size = UDim2.new(1, -20, 0, containerHeight)
    self.Container.BackgroundColor3 = theme.Secondary
    self.Container.BorderSizePixel = 0
    
    -- Закругление углов
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = self.Container
    
    -- Название текстового поля
    self.NameLabel = Instance.new("TextLabel")
    self.NameLabel.Name = "NameLabel"
    self.NameLabel.Size = UDim2.new(1, -20, 0, 20)
    self.NameLabel.Position = UDim2.new(0, 10, 0, 5)
    self.NameLabel.BackgroundTransparency = 1
    self.NameLabel.Text = self.Name
    self.NameLabel.TextColor3 = theme.Text
    self.NameLabel.TextSize = 14
    self.NameLabel.Font = Enum.Font.Gotham
    self.NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.NameLabel.Parent = self.Container
    
    -- Описание (если есть)
    local descriptionOffset = 0
    if self.Description and self.Description ~= "" then
        descriptionOffset = 20
        self.DescriptionLabel = Instance.new("TextLabel")
        self.DescriptionLabel.Name = "DescriptionLabel"
        self.DescriptionLabel.Size = UDim2.new(1, -20, 0, 14)
        self.DescriptionLabel.Position = UDim2.new(0, 10, 0, 23)
        self.DescriptionLabel.BackgroundTransparency = 1
        self.DescriptionLabel.Text = self.Description
        self.DescriptionLabel.TextColor3 = theme.SubText
        self.DescriptionLabel.TextSize = 12
        self.DescriptionLabel.Font = Enum.Font.Gotham
        self.DescriptionLabel.TextXAlignment = Enum.TextXAlignment.Left
        self.DescriptionLabel.Parent = self.Container
    end
    
    -- Фон для текстового поля
    self.TextBoxBackground = Instance.new("Frame")
    self.TextBoxBackground.Name = "TextBoxBackground"
    self.TextBoxBackground.Size = UDim2.new(1, -20, 0, self.MultiLine and 60 or 30)
    self.TextBoxBackground.Position = UDim2.new(0, 10, 0, 25 + descriptionOffset)
    self.TextBoxBackground.BackgroundColor3 = theme.Border
    self.TextBoxBackground.BorderSizePixel = 0
    self.TextBoxBackground.Parent = self.Container
    
    -- Закругление фона текстового поля
    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(0, 4)
    bgCorner.Parent = self.TextBoxBackground
    
    -- Текстовое поле
    self.InputBox = Instance.new("TextBox")
    self.InputBox.Name = "InputBox"
    self.InputBox.Size = UDim2.new(1, -20, 1, -10)
    self.InputBox.Position = UDim2.new(0, 10, 0, 5)
    self.InputBox.BackgroundTransparency = 1
    self.InputBox.Text = self.Default
    self.InputBox.PlaceholderText = self.Placeholder
    self.InputBox.PlaceholderColor3 = theme.SubText:Lerp(theme.Border, 0.5)
    self.InputBox.TextColor3 = theme.Text
    self.InputBox.TextSize = 14
    self.InputBox.Font = Enum.Font.Gotham
    self.InputBox.ClearTextOnFocus = self.ClearOnFocus
    self.InputBox.MultiLine = self.MultiLine
    self.InputBox.TextXAlignment = Enum.TextXAlignment.Left
    self.InputBox.TextYAlignment = Enum.TextYAlignment.Top
    self.InputBox.Parent = self.TextBoxBackground
    
    -- Настройка взаимодействий
    self:_SetupEvents()
end

function TextBox:_SetupEvents()
    -- Изменение фокуса
    self.InputBox.Focused:Connect(function()
        -- Подсветка фона при фокусе
        local focusTween = TweenService:Create(
            self.TextBoxBackground, 
            TweenInfo.new(0.2), 
            {BackgroundColor3 = self.UILibrary.Themes[self.Window.Theme].Primary:Lerp(self.UILibrary.Themes[self.Window.Theme].Border, 0.5)}
        )
        focusTween:Play()
    end)
    
    self.InputBox.FocusLost:Connect(function(enterPressed)
        -- Возврат к обычному цвету при потере фокуса
        local unfocusTween = TweenService:Create(
            self.TextBoxBackground, 
            TweenInfo.new(0.2), 
            {BackgroundColor3 = self.UILibrary.Themes[self.Window.Theme].Border}
        )
        unfocusTween:Play()
        
        -- Сохраняем новое значение
        self:SetValue(self.InputBox.Text)
    end)
    
    -- Эффект при наведении
    self.TextBoxBackground.MouseEnter:Connect(function()
        if self.InputBox:IsFocused() then return end
        
        local hoverTween = TweenService:Create(
            self.TextBoxBackground, 
            TweenInfo.new(0.2), 
            {BackgroundColor3 = self.UILibrary.Themes[self.Window.Theme].Border:Lerp(self.UILibrary.Themes[self.Window.Theme].Primary, 0.1)}
        )
        hoverTween:Play()
    end)
    
    self.TextBoxBackground.MouseLeave:Connect(function()
        if self.InputBox:IsFocused() then return end
        
        local leaveTween = TweenService:Create(
            self.TextBoxBackground, 
            TweenInfo.new(0.2), 
            {BackgroundColor3 = self.UILibrary.Themes[self.Window.Theme].Border}
        )
        leaveTween:Play()
    end)
end

-- Установка значения текстового поля
function TextBox:SetValue(value, ignoreCallback)
    self.Value = value
    self.InputBox.Text = value
    
    -- Вызываем callback если нужно
    if not ignoreCallback and self.Callback then
        self.Callback(value)
    end
end

-- Получение текущего значения текстового поля
function TextBox:GetValue()
    return self.Value
end

-- Очистка текстового поля
function TextBox:Clear()
    self:SetValue("")
end

-- Обновление темы
function TextBox:UpdateTheme(themeName)
    local theme = self.UILibrary.Themes[themeName]
    
    -- Обновляем цвета основных элементов
    self.Container.BackgroundColor3 = theme.Secondary
    self.NameLabel.TextColor3 = theme.Text
    self.TextBoxBackground.BackgroundColor3 = theme.Border
    self.InputBox.TextColor3 = theme.Text
    self.InputBox.PlaceholderColor3 = theme.SubText:Lerp(theme.Border, 0.5)
    
    if self.DescriptionLabel then
        self.DescriptionLabel.TextColor3 = theme.SubText
    end
end

return TextBox 