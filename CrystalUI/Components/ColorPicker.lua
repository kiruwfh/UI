--[[
    CrystalUI - ColorPicker Component
    Компонент для выбора цвета
]]

local ColorPicker = {}
ColorPicker.__index = ColorPicker

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

function ColorPicker.new(options, uiLibrary, window)
    local self = setmetatable({}, ColorPicker)
    
    -- Параметры по умолчанию
    options = options or {}
    self.Name = options.Name or "Color Picker"
    self.Description = options.Description or ""
    self.Default = options.Default or Color3.fromRGB(255, 0, 0)
    self.Callback = options.Callback or function() end
    self.UILibrary = uiLibrary
    self.Window = window
    self.Value = self.Default
    self.Open = false
    
    -- HSV значения
    self.H, self.S, self.V = self.Default:ToHSV()
    
    -- Создание UI элементов
    self:_CreateUI()
    
    -- Установка начального значения
    self:SetValue(self.Default, true) -- true = без вызова callback
    
    return self
end

function ColorPicker:_CreateUI()
    local theme = self.UILibrary.Themes[self.Window.Theme]
    
    -- Основной контейнер
    self.Container = Instance.new("Frame")
    self.Container.Name = self.Name:gsub("%s+", "") .. "ColorPicker"
    self.Container.Size = UDim2.new(1, -20, 0, 40)
    self.Container.BackgroundColor3 = theme.Secondary
    self.Container.BorderSizePixel = 0
    self.Container.ClipsDescendants = true -- Чтобы скрыть расширяющуюся часть
    
    -- Закругление углов
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = self.Container
    
    -- Название компонента
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
    
    -- Образец текущего цвета
    self.ColorDisplay = Instance.new("Frame")
    self.ColorDisplay.Name = "ColorDisplay"
    self.ColorDisplay.Size = UDim2.new(0, 30, 0, 30)
    self.ColorDisplay.Position = UDim2.new(1, -40, 0, 5)
    self.ColorDisplay.BackgroundColor3 = self.Default
    self.ColorDisplay.BorderSizePixel = 0
    self.ColorDisplay.Parent = self.Container
    
    -- Закругление образца цвета
    local displayCorner = Instance.new("UICorner")
    displayCorner.CornerRadius = UDim.new(0, 4)
    displayCorner.Parent = self.ColorDisplay
    
    -- Контейнер для пикера (расширяется при клике)
    self.PickerContainer = Instance.new("Frame")
    self.PickerContainer.Name = "PickerContainer"
    self.PickerContainer.Size = UDim2.new(1, -20, 0, 160)
    self.PickerContainer.Position = UDim2.new(0, 10, 0, 45)
    self.PickerContainer.BackgroundColor3 = theme.Secondary:Lerp(theme.Border, 0.3)
    self.PickerContainer.BorderSizePixel = 0
    self.PickerContainer.Visible = false
    self.PickerContainer.Parent = self.Container
    
    -- Закругление контейнера пикера
    local pickerCorner = Instance.new("UICorner")
    pickerCorner.CornerRadius = UDim.new(0, 4)
    pickerCorner.Parent = self.PickerContainer
    
    -- Основная цветовая панель (SV компоненты)
    self.ColorPanel = Instance.new("ImageLabel")
    self.ColorPanel.Name = "ColorPanel"
    self.ColorPanel.Size = UDim2.new(1, -20, 0, 100)
    self.ColorPanel.Position = UDim2.new(0, 10, 0, 10)
    self.ColorPanel.BackgroundColor3 = Color3.fromHSV(self.H, 1, 1)
    self.ColorPanel.BorderSizePixel = 0
    self.ColorPanel.Image = "rbxassetid://4155801252" -- Градиент SV
    self.ColorPanel.Parent = self.PickerContainer
    
    -- Закругление цветовой панели
    local panelCorner = Instance.new("UICorner")
    panelCorner.CornerRadius = UDim.new(0, 4)
    panelCorner.Parent = self.ColorPanel
    
    -- Указатель на цветовой панели
    self.ColorCursor = Instance.new("Frame")
    self.ColorCursor.Name = "ColorCursor"
    self.ColorCursor.Size = UDim2.new(0, 10, 0, 10)
    self.ColorCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.ColorCursor.BorderSizePixel = 0
    self.ColorCursor.AnchorPoint = Vector2.new(0.5, 0.5)
    self.ColorCursor.Parent = self.ColorPanel
    
    -- Закругление указателя
    local cursorCorner = Instance.new("UICorner")
    cursorCorner.CornerRadius = UDim.new(1, 0)
    cursorCorner.Parent = self.ColorCursor
    
    -- Полоска оттенка (H компонент)
    self.HueSlider = Instance.new("ImageLabel")
    self.HueSlider.Name = "HueSlider"
    self.HueSlider.Size = UDim2.new(1, -20, 0, 15)
    self.HueSlider.Position = UDim2.new(0, 10, 0, 120)
    self.HueSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.HueSlider.BorderSizePixel = 0
    self.HueSlider.Image = "rbxassetid://3283534159" -- Rainbow gradient
    self.HueSlider.Parent = self.PickerContainer
    
    -- Закругление полоски оттенка
    local hueCorner = Instance.new("UICorner")
    hueCorner.CornerRadius = UDim.new(0, 4)
    hueCorner.Parent = self.HueSlider
    
    -- Указатель на полоске оттенка
    self.HueCursor = Instance.new("Frame")
    self.HueCursor.Name = "HueCursor"
    self.HueCursor.Size = UDim2.new(0, 5, 1, 0)
    self.HueCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.HueCursor.BorderSizePixel = 0
    self.HueCursor.Parent = self.HueSlider
    
    -- Закругление указателя оттенка
    local hueCursorCorner = Instance.new("UICorner")
    hueCursorCorner.CornerRadius = UDim.new(0, 2)
    hueCursorCorner.Parent = self.HueCursor
    
    -- RGB значения
    self.RLabel = Instance.new("TextLabel")
    self.RLabel.Name = "RLabel"
    self.RLabel.Size = UDim2.new(0, 15, 0, 15)
    self.RLabel.Position = UDim2.new(0, 10, 0, 140)
    self.RLabel.BackgroundTransparency = 1
    self.RLabel.Text = "R:"
    self.RLabel.TextColor3 = theme.Text
    self.RLabel.TextSize = 12
    self.RLabel.Font = Enum.Font.Gotham
    self.RLabel.Parent = self.PickerContainer
    
    self.RValue = Instance.new("TextBox")
    self.RValue.Name = "RValue"
    self.RValue.Size = UDim2.new(0, 30, 0, 15)
    self.RValue.Position = UDim2.new(0, 25, 0, 140)
    self.RValue.BackgroundColor3 = theme.Border
    self.RValue.BorderSizePixel = 0
    self.RValue.Text = tostring(math.floor(self.Default.R * 255 + 0.5))
    self.RValue.TextColor3 = theme.Text
    self.RValue.TextSize = 12
    self.RValue.Font = Enum.Font.Gotham
    self.RValue.Parent = self.PickerContainer
    
    -- Закругление поля R
    local rCorner = Instance.new("UICorner")
    rCorner.CornerRadius = UDim.new(0, 2)
    rCorner.Parent = self.RValue
    
    self.GLabel = Instance.new("TextLabel")
    self.GLabel.Name = "GLabel"
    self.GLabel.Size = UDim2.new(0, 15, 0, 15)
    self.GLabel.Position = UDim2.new(0, 65, 0, 140)
    self.GLabel.BackgroundTransparency = 1
    self.GLabel.Text = "G:"
    self.GLabel.TextColor3 = theme.Text
    self.GLabel.TextSize = 12
    self.GLabel.Font = Enum.Font.Gotham
    self.GLabel.Parent = self.PickerContainer
    
    self.GValue = Instance.new("TextBox")
    self.GValue.Name = "GValue"
    self.GValue.Size = UDim2.new(0, 30, 0, 15)
    self.GValue.Position = UDim2.new(0, 80, 0, 140)
    self.GValue.BackgroundColor3 = theme.Border
    self.GValue.BorderSizePixel = 0
    self.GValue.Text = tostring(math.floor(self.Default.G * 255 + 0.5))
    self.GValue.TextColor3 = theme.Text
    self.GValue.TextSize = 12
    self.GValue.Font = Enum.Font.Gotham
    self.GValue.Parent = self.PickerContainer
    
    -- Закругление поля G
    local gCorner = Instance.new("UICorner")
    gCorner.CornerRadius = UDim.new(0, 2)
    gCorner.Parent = self.GValue
    
    self.BLabel = Instance.new("TextLabel")
    self.BLabel.Name = "BLabel"
    self.BLabel.Size = UDim2.new(0, 15, 0, 15)
    self.BLabel.Position = UDim2.new(0, 120, 0, 140)
    self.BLabel.BackgroundTransparency = 1
    self.BLabel.Text = "B:"
    self.BLabel.TextColor3 = theme.Text
    self.BLabel.TextSize = 12
    self.BLabel.Font = Enum.Font.Gotham
    self.BLabel.Parent = self.PickerContainer
    
    self.BValue = Instance.new("TextBox")
    self.BValue.Name = "BValue"
    self.BValue.Size = UDim2.new(0, 30, 0, 15)
    self.BValue.Position = UDim2.new(0, 135, 0, 140)
    self.BValue.BackgroundColor3 = theme.Border
    self.BValue.BorderSizePixel = 0
    self.BValue.Text = tostring(math.floor(self.Default.B * 255 + 0.5))
    self.BValue.TextColor3 = theme.Text
    self.BValue.TextSize = 12
    self.BValue.Font = Enum.Font.Gotham
    self.BValue.Parent = self.PickerContainer
    
    -- Закругление поля B
    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 2)
    bCorner.Parent = self.BValue
    
    -- Кнопка для взаимодействия
    self.ColorButton = Instance.new("TextButton")
    self.ColorButton.Name = "ColorButton"
    self.ColorButton.Size = UDim2.new(1, 0, 0, 40)
    self.ColorButton.BackgroundTransparency = 1
    self.ColorButton.Text = ""
    self.ColorButton.Parent = self.Container
    
    -- Настройка взаимодействий
    self:_SetupEvents()
    
    -- Обновляем позиции указателей
    self:UpdateColorCursor()
    self:UpdateHueCursor()
end

function ColorPicker:_SetupEvents()
    -- Переключение состояния пикера (открыт/закрыт)
    self.ColorButton.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    
    -- Эффект при наведении на кнопку
    self.ColorButton.MouseEnter:Connect(function()
        local hoverTween = TweenService:Create(
            self.Container, 
            TweenInfo.new(0.2), 
            {BackgroundColor3 = self.UILibrary.Themes[self.Window.Theme].Secondary:Lerp(self.UILibrary.Themes[self.Window.Theme].Primary, 0.1)}
        )
        hoverTween:Play()
    end)
    
    self.ColorButton.MouseLeave:Connect(function()
        local leaveTween = TweenService:Create(
            self.Container, 
            TweenInfo.new(0.2), 
            {BackgroundColor3 = self.UILibrary.Themes[self.Window.Theme].Secondary}
        )
        leaveTween:Play()
    end)
    
    -- Обработка взаимодействия с цветовой панелью
    local colorPanelDragging = false
    
    self.ColorPanel.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            colorPanelDragging = true
            self:UpdateColorFromPanel(input.Position)
        end
    end)
    
    self.ColorPanel.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            colorPanelDragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and colorPanelDragging then
            self:UpdateColorFromPanel(input.Position)
        end
    end)
    
    -- Обработка взаимодействия с полоской оттенка
    local hueDragging = false
    
    self.HueSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            hueDragging = true
            self:UpdateHueFromSlider(input.Position)
        end
    end)
    
    self.HueSlider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            hueDragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and hueDragging then
            self:UpdateHueFromSlider(input.Position)
        end
    end)
    
    -- Обработка ввода RGB значений
    self.RValue.FocusLost:Connect(function()
        self:UpdateFromRGB()
    end)
    
    self.GValue.FocusLost:Connect(function()
        self:UpdateFromRGB()
    end)
    
    self.BValue.FocusLost:Connect(function()
        self:UpdateFromRGB()
    end)
    
    -- Закрытие при клике вне компонента
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and self.Open then
            local mousePosition = UserInputService:GetMouseLocation()
            local containerPosition = self.Container.AbsolutePosition
            local containerSize = self.Container.AbsoluteSize
            
            -- Если клик вне контейнера, закрываем
            if mousePosition.X < containerPosition.X or
               mousePosition.X > containerPosition.X + containerSize.X or
               mousePosition.Y < containerPosition.Y or
               mousePosition.Y > containerPosition.Y + containerSize.Y then
                self:Toggle(false)
            end
        end
    end)
end

-- Обновление цвета на основе положения на цветовой панели
function ColorPicker:UpdateColorFromPanel(mousePosition)
    local panelPosition = self.ColorPanel.AbsolutePosition
    local panelSize = self.ColorPanel.AbsoluteSize
    
    -- Вычисляем S и V компоненты
    local s = math.clamp((mousePosition.X - panelPosition.X) / panelSize.X, 0, 1)
    local v = 1 - math.clamp((mousePosition.Y - panelPosition.Y) / panelSize.Y, 0, 1)
    
    -- Обновляем S и V, сохраняя H
    self.S = s
    self.V = v
    
    -- Обновляем положение указателя
    self:UpdateColorCursor()
    
    -- Обновляем отображаемый цвет
    self:UpdateColor()
end

-- Обновление оттенка на основе положения на полоске оттенка
function ColorPicker:UpdateHueFromSlider(mousePosition)
    local sliderPosition = self.HueSlider.AbsolutePosition
    local sliderSize = self.HueSlider.AbsoluteSize
    
    -- Вычисляем H компонент
    local h = math.clamp((mousePosition.X - sliderPosition.X) / sliderSize.X, 0, 1)
    
    -- Обновляем H, сохраняя S и V
    self.H = h
    
    -- Обновляем цвет панели
    self.ColorPanel.BackgroundColor3 = Color3.fromHSV(self.H, 1, 1)
    
    -- Обновляем положение указателя
    self:UpdateHueCursor()
    
    -- Обновляем отображаемый цвет
    self:UpdateColor()
end

-- Обновление из RGB значений
function ColorPicker:UpdateFromRGB()
    -- Считываем и проверяем значения
    local r = tonumber(self.RValue.Text) or 0
    local g = tonumber(self.GValue.Text) or 0
    local b = tonumber(self.BValue.Text) or 0
    
    -- Ограничиваем значения в пределах 0-255
    r = math.clamp(r, 0, 255)
    g = math.clamp(g, 0, 255)
    b = math.clamp(b, 0, 255)
    
    -- Обновляем текстовые поля
    self.RValue.Text = tostring(math.floor(r))
    self.GValue.Text = tostring(math.floor(g))
    self.BValue.Text = tostring(math.floor(b))
    
    -- Создаем Color3 и конвертируем в HSV
    local color = Color3.fromRGB(r, g, b)
    self.H, self.S, self.V = color:ToHSV()
    
    -- Обновляем цвет панели
    self.ColorPanel.BackgroundColor3 = Color3.fromHSV(self.H, 1, 1)
    
    -- Обновляем положение указателей
    self:UpdateColorCursor()
    self:UpdateHueCursor()
    
    -- Обновляем значение
    self:SetValue(color)
end

-- Обновление положения указателя на цветовой панели
function ColorPicker:UpdateColorCursor()
    self.ColorCursor.Position = UDim2.new(self.S, 0, 1 - self.V, 0)
end

-- Обновление положения указателя на полоске оттенка
function ColorPicker:UpdateHueCursor()
    self.HueCursor.Position = UDim2.new(self.H, 0, 0, 0)
end

-- Обновление отображаемого цвета
function ColorPicker:UpdateColor()
    local color = Color3.fromHSV(self.H, self.S, self.V)
    
    -- Обновляем образец цвета
    self.ColorDisplay.BackgroundColor3 = color
    
    -- Обновляем RGB значения
    local r, g, b = math.floor(color.R * 255 + 0.5), math.floor(color.G * 255 + 0.5), math.floor(color.B * 255 + 0.5)
    self.RValue.Text = tostring(r)
    self.GValue.Text = tostring(g)
    self.BValue.Text = tostring(b)
    
    -- Сохраняем новое значение
    self:SetValue(color)
end

-- Открытие/закрытие пикера
function ColorPicker:Toggle(state)
    -- Если состояние не указано, переключаем текущее
    if state == nil then
        state = not self.Open
    end
    
    self.Open = state
    
    -- Показываем/скрываем контейнер пикера
    self.PickerContainer.Visible = state
    
    -- Анимируем контейнер
    local heightTween = TweenService:Create(
        self.Container,
        TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        {Size = UDim2.new(1, -20, 0, state and 215 or 40)}
    )
    heightTween:Play()
end

-- Установка значения
function ColorPicker:SetValue(color, ignoreCallback)
    self.Value = color
    
    -- Обновляем HSV значения
    self.H, self.S, self.V = color:ToHSV()
    
    -- Обновляем отображение
    self.ColorDisplay.BackgroundColor3 = color
    self.ColorPanel.BackgroundColor3 = Color3.fromHSV(self.H, 1, 1)
    
    -- Обновляем RGB значения
    local r, g, b = math.floor(color.R * 255 + 0.5), math.floor(color.G * 255 + 0.5), math.floor(color.B * 255 + 0.5)
    self.RValue.Text = tostring(r)
    self.GValue.Text = tostring(g)
    self.BValue.Text = tostring(b)
    
    -- Обновляем положение указателей
    self:UpdateColorCursor()
    self:UpdateHueCursor()
    
    -- Вызываем callback если нужно
    if not ignoreCallback and self.Callback then
        self.Callback(color)
    end
end

-- Получение текущего значения цвета
function ColorPicker:GetValue()
    return self.Value
end

-- Обновление темы
function ColorPicker:UpdateTheme(themeName)
    local theme = self.UILibrary.Themes[themeName]
    
    -- Обновляем цвета основных элементов
    self.Container.BackgroundColor3 = theme.Secondary
    self.NameLabel.TextColor3 = theme.Text
    self.PickerContainer.BackgroundColor3 = theme.Secondary:Lerp(theme.Border, 0.3)
    self.RValue.BackgroundColor3 = theme.Border
    self.RValue.TextColor3 = theme.Text
    self.GValue.BackgroundColor3 = theme.Border
    self.GValue.TextColor3 = theme.Text
    self.BValue.BackgroundColor3 = theme.Border
    self.BValue.TextColor3 = theme.Text
    self.RLabel.TextColor3 = theme.Text
    self.GLabel.TextColor3 = theme.Text
    self.BLabel.TextColor3 = theme.Text
    
    if self.DescriptionLabel then
        self.DescriptionLabel.TextColor3 = theme.SubText
    end
end

return ColorPicker 