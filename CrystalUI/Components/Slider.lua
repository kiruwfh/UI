--[[
    CrystalUI - Slider Component
    Компонент слайдера для выбора числовых значений
]]

local Slider = {}
Slider.__index = Slider

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

function Slider.new(options, uiLibrary, window)
    local self = setmetatable({}, Slider)
    
    -- Параметры по умолчанию
    options = options or {}
    self.Name = options.Name or "Slider"
    self.Description = options.Description or ""
    self.Min = options.Min or 0
    self.Max = options.Max or 100
    self.Default = options.Default or self.Min
    self.Increment = options.Increment or 1
    self.Suffix = options.Suffix or ""
    self.Callback = options.Callback or function() end
    self.UILibrary = uiLibrary
    self.Window = window
    self.Value = self.Default
    self.Dragging = false
    
    -- Создание UI элементов
    self:_CreateUI()
    
    -- Установка начального значения
    self:SetValue(self.Default, true) -- true = без вызова callback
    
    return self
end

function Slider:_CreateUI()
    local theme = self.UILibrary.Themes[self.Window.Theme]
    
    -- Основной контейнер
    self.Container = Instance.new("Frame")
    self.Container.Name = self.Name:gsub("%s+", "") .. "Slider"
    self.Container.Size = UDim2.new(1, -20, 0, 60)
    self.Container.BackgroundColor3 = theme.Secondary
    self.Container.BorderSizePixel = 0
    
    -- Закругление углов
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = self.Container
    
    -- Название слайдера
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
    
    -- Значение слайдера
    self.ValueLabel = Instance.new("TextLabel")
    self.ValueLabel.Name = "ValueLabel"
    self.ValueLabel.Size = UDim2.new(0, 50, 0, 20)
    self.ValueLabel.Position = UDim2.new(1, -60, 0, 5)
    self.ValueLabel.BackgroundTransparency = 1
    self.ValueLabel.Text = tostring(self.Default) .. self.Suffix
    self.ValueLabel.TextColor3 = theme.Text
    self.ValueLabel.TextSize = 14
    self.ValueLabel.Font = Enum.Font.GothamBold
    self.ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    self.ValueLabel.Parent = self.Container
    
    -- Описание (если есть)
    if self.Description and self.Description ~= "" then
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
    
    -- Контейнер слайдера (фон)
    self.SliderBackground = Instance.new("Frame")
    self.SliderBackground.Name = "SliderBackground"
    self.SliderBackground.Size = UDim2.new(1, -20, 0, 10)
    self.SliderBackground.Position = UDim2.new(0, 10, 0, 40)
    self.SliderBackground.BackgroundColor3 = theme.Border
    self.SliderBackground.BorderSizePixel = 0
    self.SliderBackground.Parent = self.Container
    
    -- Закругление фона слайдера
    local sliderBgCorner = Instance.new("UICorner")
    sliderBgCorner.CornerRadius = UDim.new(0, 5)
    sliderBgCorner.Parent = self.SliderBackground
    
    -- Индикатор заполнения слайдера
    self.SliderFill = Instance.new("Frame")
    self.SliderFill.Name = "SliderFill"
    self.SliderFill.Size = UDim2.new(0, 0, 1, 0)
    self.SliderFill.BackgroundColor3 = theme.Primary
    self.SliderFill.BorderSizePixel = 0
    self.SliderFill.Parent = self.SliderBackground
    
    -- Закругление индикатора заполнения
    local sliderFillCorner = Instance.new("UICorner")
    sliderFillCorner.CornerRadius = UDim.new(0, 5)
    sliderFillCorner.Parent = self.SliderFill
    
    -- Кружок слайдера
    self.SliderCircle = Instance.new("Frame")
    self.SliderCircle.Name = "SliderCircle"
    self.SliderCircle.Size = UDim2.new(0, 16, 0, 16)
    self.SliderCircle.Position = UDim2.new(0, -8, 0.5, -8)
    self.SliderCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.SliderCircle.BorderSizePixel = 0
    self.SliderCircle.ZIndex = 2
    self.SliderCircle.Parent = self.SliderFill
    
    -- Закругление кружка слайдера
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = self.SliderCircle
    
    -- Тень для кружка
    local circleShadow = Instance.new("ImageLabel")
    circleShadow.Name = "Shadow"
    circleShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    circleShadow.BackgroundTransparency = 1
    circleShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    circleShadow.Size = UDim2.new(1, 6, 1, 6)
    circleShadow.ZIndex = 1
    circleShadow.Image = "rbxassetid://6014261993"
    circleShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    circleShadow.ImageTransparency = 0.6
    circleShadow.ScaleType = Enum.ScaleType.Slice
    circleShadow.SliceCenter = Rect.new(49, 49, 450, 450)
    circleShadow.Parent = self.SliderCircle
    
    -- Кнопка для взаимодействия (невидимая)
    self.SliderButton = Instance.new("TextButton")
    self.SliderButton.Name = "SliderButton"
    self.SliderButton.Size = UDim2.new(1, 0, 1, 0)
    self.SliderButton.BackgroundTransparency = 1
    self.SliderButton.Text = ""
    self.SliderButton.Parent = self.SliderBackground
    
    -- Обработка взаимодействий
    self:_SetupEvents()
end

function Slider:_SetupEvents()
    -- Обработка клика и перетаскивания
    self.SliderButton.MouseButton1Down:Connect(function(x)
        self.Dragging = true
        self:UpdateSlider(x)
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and self.Dragging then
            self.Dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and self.Dragging then
            self:UpdateSlider(input.Position.X)
        end
    end)
    
    -- Эффект при наведении
    self.SliderButton.MouseEnter:Connect(function()
        local hoverTween = TweenService:Create(
            self.Container, 
            TweenInfo.new(0.2), 
            {BackgroundColor3 = self.UILibrary.Themes[self.Window.Theme].Secondary:Lerp(self.UILibrary.Themes[self.Window.Theme].Primary, 0.1)}
        )
        hoverTween:Play()
    end)
    
    self.SliderButton.MouseLeave:Connect(function()
        local leaveTween = TweenService:Create(
            self.Container, 
            TweenInfo.new(0.2), 
            {BackgroundColor3 = self.UILibrary.Themes[self.Window.Theme].Secondary}
        )
        leaveTween:Play()
    end)
end

-- Обновление слайдера на основе позиции мыши
function Slider:UpdateSlider(mouseX)
    -- Получаем позицию мыши относительно слайдера
    local sliderPosition = self.SliderBackground.AbsolutePosition.X
    local sliderSize = self.SliderBackground.AbsoluteSize.X
    
    -- Вычисляем процент заполнения
    local percent = math.clamp((mouseX - sliderPosition) / sliderSize, 0, 1)
    
    -- Вычисляем значение с учетом шага
    local value = self.Min + (self.Max - self.Min) * percent
    value = math.floor(value / self.Increment + 0.5) * self.Increment
    value = math.clamp(value, self.Min, self.Max)
    
    -- Устанавливаем новое значение
    self:SetValue(value)
end

-- Установка значения слайдера
function Slider:SetValue(value, ignoreCallback)
    -- Проверяем и нормализуем значение
    value = math.clamp(value, self.Min, self.Max)
    value = math.floor(value / self.Increment + 0.5) * self.Increment
    
    -- Если значение не изменилось, возвращаемся
    if value == self.Value then return end
    
    self.Value = value
    
    -- Вычисляем процент заполнения
    local percent = (self.Value - self.Min) / (self.Max - self.Min)
    
    -- Обновляем UI
    self.ValueLabel.Text = tostring(self.Value) .. self.Suffix
    
    -- Анимируем заполнение
    local fillTween = TweenService:Create(
        self.SliderFill, 
        TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
        {Size = UDim2.new(percent, 0, 1, 0)}
    )
    fillTween:Play()
    
    -- Вызываем callback, если нужно
    if not ignoreCallback and self.Callback then
        self.Callback(self.Value)
    end
end

-- Обновление темы
function Slider:UpdateTheme(themeName)
    local theme = self.UILibrary.Themes[themeName]
    
    -- Обновляем цвета
    self.Container.BackgroundColor3 = theme.Secondary
    self.NameLabel.TextColor3 = theme.Text
    self.ValueLabel.TextColor3 = theme.Text
    self.SliderBackground.BackgroundColor3 = theme.Border
    self.SliderFill.BackgroundColor3 = theme.Primary
    
    if self.DescriptionLabel then
        self.DescriptionLabel.TextColor3 = theme.SubText
    end
end

return Slider 