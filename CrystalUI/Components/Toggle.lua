--[[
    CrystalUI - Toggle Component
    Компонент переключатель (вкл/выкл)
]]

local Toggle = {}
Toggle.__index = Toggle

local TweenService = game:GetService("TweenService")

function Toggle.new(options, uiLibrary, window)
    local self = setmetatable({}, Toggle)
    
    -- Параметры по умолчанию
    options = options or {}
    self.Name = options.Name or "Toggle"
    self.Description = options.Description or ""
    self.Default = options.Default or false
    self.Callback = options.Callback or function() end
    self.UILibrary = uiLibrary
    self.Window = window
    self.Value = self.Default
    
    -- Создание UI элементов
    self:_CreateUI()
    
    -- Установка начального состояния
    self:SetValue(self.Default, true) -- true = без вызова callback
    
    return self
end

function Toggle:_CreateUI()
    local theme = self.UILibrary.Themes[self.Window.Theme]
    
    -- Основной контейнер
    self.Container = Instance.new("Frame")
    self.Container.Name = self.Name:gsub("%s+", "") .. "Toggle"
    self.Container.Size = UDim2.new(1, -20, 0, 40)
    self.Container.BackgroundColor3 = theme.Secondary
    self.Container.BorderSizePixel = 0
    
    -- Закругление углов
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = self.Container
    
    -- Название переключателя
    self.NameLabel = Instance.new("TextLabel")
    self.NameLabel.Name = "NameLabel"
    self.NameLabel.Size = UDim2.new(1, -60, 0, 20)
    self.NameLabel.Position = UDim2.new(0, 10, 0, 5)
    self.NameLabel.BackgroundTransparency = 1
    self.NameLabel.Text = self.Name
    self.NameLabel.TextColor3 = theme.Text
    self.NameLabel.TextSize = 14
    self.NameLabel.Font = Enum.Font.Gotham
    self.NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.NameLabel.Parent = self.Container
    
    -- Описание (если есть)
    if self.Description and self.Description ~= "" then
        self.DescriptionLabel = Instance.new("TextLabel")
        self.DescriptionLabel.Name = "DescriptionLabel"
        self.DescriptionLabel.Size = UDim2.new(1, -60, 0, 14)
        self.DescriptionLabel.Position = UDim2.new(0, 10, 0, 23)
        self.DescriptionLabel.BackgroundTransparency = 1
        self.DescriptionLabel.Text = self.Description
        self.DescriptionLabel.TextColor3 = theme.SubText
        self.DescriptionLabel.TextSize = 12
        self.DescriptionLabel.Font = Enum.Font.Gotham
        self.DescriptionLabel.TextXAlignment = Enum.TextXAlignment.Left
        self.DescriptionLabel.Parent = self.Container
    end
    
    -- Контейнер переключателя
    self.ToggleFrame = Instance.new("Frame")
    self.ToggleFrame.Name = "ToggleFrame"
    self.ToggleFrame.Size = UDim2.new(0, 40, 0, 20)
    self.ToggleFrame.Position = UDim2.new(1, -50, 0.5, -10)
    self.ToggleFrame.BackgroundColor3 = theme.Border
    self.ToggleFrame.BorderSizePixel = 0
    self.ToggleFrame.Parent = self.Container
    
    -- Закругление углов переключателя
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0) -- Полностью округлый
    toggleCorner.Parent = self.ToggleFrame
    
    -- Кружок переключателя
    self.ToggleCircle = Instance.new("Frame")
    self.ToggleCircle.Name = "ToggleCircle"
    self.ToggleCircle.Size = UDim2.new(0, 16, 0, 16)
    self.ToggleCircle.Position = UDim2.new(0, 2, 0.5, -8)
    self.ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.ToggleCircle.BorderSizePixel = 0
    self.ToggleCircle.Parent = self.ToggleFrame
    
    -- Закругление кружка
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = self.ToggleCircle
    
    -- Кнопка для взаимодействия (невидимая)
    self.ToggleButton = Instance.new("TextButton")
    self.ToggleButton.Name = "ToggleButton"
    self.ToggleButton.Size = UDim2.new(1, 0, 1, 0)
    self.ToggleButton.BackgroundTransparency = 1
    self.ToggleButton.Text = ""
    self.ToggleButton.Parent = self.Container
    
    -- Обработка нажатия
    self.ToggleButton.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    
    -- Эффект при наведении
    self.ToggleButton.MouseEnter:Connect(function()
        local hoverTween = TweenService:Create(
            self.Container, 
            TweenInfo.new(0.2), 
            {BackgroundColor3 = theme.Secondary:Lerp(theme.Primary, 0.1)}
        )
        hoverTween:Play()
    end)
    
    self.ToggleButton.MouseLeave:Connect(function()
        local leaveTween = TweenService:Create(
            self.Container, 
            TweenInfo.new(0.2), 
            {BackgroundColor3 = theme.Secondary}
        )
        leaveTween:Play()
    end)
end

-- Переключить состояние
function Toggle:Toggle()
    self:SetValue(not self.Value)
end

-- Установить значение
function Toggle:SetValue(value, ignoreCallback)
    self.Value = value
    
    local theme = self.UILibrary.Themes[self.Window.Theme]
    local targetPosition = self.Value 
        and UDim2.new(1, -18, 0.5, -8) 
        or UDim2.new(0, 2, 0.5, -8)
    
    local targetColor = self.Value 
        and theme.Primary 
        or theme.Border
    
    -- Анимация переключения
    local circleTween = TweenService:Create(
        self.ToggleCircle, 
        TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
        {Position = targetPosition}
    )
    
    local colorTween = TweenService:Create(
        self.ToggleFrame, 
        TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
        {BackgroundColor3 = targetColor}
    )
    
    circleTween:Play()
    colorTween:Play()
    
    -- Вызываем callback, если нужно
    if not ignoreCallback and self.Callback then
        self.Callback(self.Value)
    end
end

-- Обновление темы
function Toggle:UpdateTheme(themeName)
    local theme = self.UILibrary.Themes[themeName]
    
    -- Обновляем цвета
    self.Container.BackgroundColor3 = theme.Secondary
    self.NameLabel.TextColor3 = theme.Text
    
    if self.DescriptionLabel then
        self.DescriptionLabel.TextColor3 = theme.SubText
    end
    
    -- Обновляем цвет переключателя в зависимости от состояния
    self.ToggleFrame.BackgroundColor3 = self.Value 
        and theme.Primary 
        or theme.Border
end

return Toggle 