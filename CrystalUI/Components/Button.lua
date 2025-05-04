--[[
    CrystalUI - Button Component
    Компонент кнопки для выполнения действий
]]

local Button = {}
Button.__index = Button

local TweenService = game:GetService("TweenService")

function Button.new(options, uiLibrary, window)
    local self = setmetatable({}, Button)
    
    -- Параметры по умолчанию
    options = options or {}
    self.Name = options.Name or "Button"
    self.Description = options.Description or ""
    self.Callback = options.Callback or function() end
    self.Icon = options.Icon or nil
    self.UILibrary = uiLibrary
    self.Window = window
    
    -- Создание UI элементов
    self:_CreateUI()
    
    return self
end

function Button:_CreateUI()
    local theme = self.UILibrary.Themes[self.Window.Theme]
    
    -- Основной контейнер
    self.Container = Instance.new("Frame")
    self.Container.Name = self.Name:gsub("%s+", "") .. "Button"
    self.Container.Size = UDim2.new(1, -20, 0, self.Description ~= "" and 60 or 40)
    self.Container.BackgroundColor3 = theme.Secondary
    self.Container.BorderSizePixel = 0
    
    -- Закругление углов
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = self.Container
    
    -- Название кнопки и описание
    local textOffset = self.Icon and 25 or 0
    
    -- Название кнопки
    self.NameLabel = Instance.new("TextLabel")
    self.NameLabel.Name = "NameLabel"
    self.NameLabel.Size = UDim2.new(1, -40 - textOffset, 0, 20)
    self.NameLabel.Position = UDim2.new(0, 10 + textOffset, 0, self.Description ~= "" and 10 or 10)
    self.NameLabel.BackgroundTransparency = 1
    self.NameLabel.Text = self.Name
    self.NameLabel.TextColor3 = theme.Text
    self.NameLabel.TextSize = 14
    self.NameLabel.Font = Enum.Font.GothamSemibold
    self.NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.NameLabel.Parent = self.Container
    
    -- Описание (если есть)
    if self.Description and self.Description ~= "" then
        self.DescriptionLabel = Instance.new("TextLabel")
        self.DescriptionLabel.Name = "DescriptionLabel"
        self.DescriptionLabel.Size = UDim2.new(1, -40 - textOffset, 0, 14)
        self.DescriptionLabel.Position = UDim2.new(0, 10 + textOffset, 0, 30)
        self.DescriptionLabel.BackgroundTransparency = 1
        self.DescriptionLabel.Text = self.Description
        self.DescriptionLabel.TextColor3 = theme.SubText
        self.DescriptionLabel.TextSize = 12
        self.DescriptionLabel.Font = Enum.Font.Gotham
        self.DescriptionLabel.TextXAlignment = Enum.TextXAlignment.Left
        self.DescriptionLabel.Parent = self.Container
    end
    
    -- Иконка (если указана)
    if self.Icon then
        self.IconImage = Instance.new("ImageLabel")
        self.IconImage.Name = "IconImage"
        self.IconImage.Size = UDim2.new(0, 20, 0, 20)
        self.IconImage.Position = UDim2.new(0, 10, 0.5, -10)
        self.IconImage.BackgroundTransparency = 1
        self.IconImage.Image = self.Icon
        self.IconImage.ImageColor3 = theme.Text
        self.IconImage.Parent = self.Container
    end
    
    -- Визуальный эффект нажатия
    self.PressEffect = Instance.new("Frame")
    self.PressEffect.Name = "PressEffect"
    self.PressEffect.Size = UDim2.new(1, 0, 1, 0)
    self.PressEffect.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.PressEffect.BackgroundTransparency = 1
    self.PressEffect.BorderSizePixel = 0
    self.PressEffect.ZIndex = 2
    self.PressEffect.Parent = self.Container
    
    -- Закругление эффекта нажатия
    local pressCorner = Instance.new("UICorner")
    pressCorner.CornerRadius = UDim.new(0, 4)
    pressCorner.Parent = self.PressEffect
    
    -- Кнопка для взаимодействия
    self.ButtonElement = Instance.new("TextButton")
    self.ButtonElement.Name = "ButtonElement"
    self.ButtonElement.Size = UDim2.new(1, 0, 1, 0)
    self.ButtonElement.BackgroundTransparency = 1
    self.ButtonElement.Text = ""
    self.ButtonElement.ZIndex = 3
    self.ButtonElement.Parent = self.Container
    
    -- Настройка взаимодействий
    self:_SetupInteractions()
end

function Button:_SetupInteractions()
    -- Эффект при наведении
    self.ButtonElement.MouseEnter:Connect(function()
        local hoverTween = TweenService:Create(
            self.Container, 
            TweenInfo.new(0.2), 
            {BackgroundColor3 = self.UILibrary.Themes[self.Window.Theme].Secondary:Lerp(self.UILibrary.Themes[self.Window.Theme].Primary, 0.2)}
        )
        hoverTween:Play()
    end)
    
    self.ButtonElement.MouseLeave:Connect(function()
        local leaveTween = TweenService:Create(
            self.Container, 
            TweenInfo.new(0.2), 
            {BackgroundColor3 = self.UILibrary.Themes[self.Window.Theme].Secondary}
        )
        leaveTween:Play()
    end)
    
    -- Эффект при клике
    self.ButtonElement.MouseButton1Down:Connect(function()
        local pressTween = TweenService:Create(
            self.PressEffect, 
            TweenInfo.new(0.1), 
            {BackgroundTransparency = 0.9}
        )
        pressTween:Play()
    end)
    
    self.ButtonElement.MouseButton1Up:Connect(function()
        local releaseTween = TweenService:Create(
            self.PressEffect, 
            TweenInfo.new(0.1), 
            {BackgroundTransparency = 1}
        )
        releaseTween:Play()
    end)
    
    -- Обработка клика (вызов callback)
    self.ButtonElement.MouseButton1Click:Connect(function()
        self:_OnClick()
    end)
end

function Button:_OnClick()
    -- Анимация нажатия
    local clickTween = TweenService:Create(
        self.Container, 
        TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
        {BackgroundColor3 = self.UILibrary.Themes[self.Window.Theme].Primary}
    )
    clickTween:Play()
    
    -- Возвращаем исходный цвет после анимации
    delay(0.2, function()
        local resetTween = TweenService:Create(
            self.Container, 
            TweenInfo.new(0.2), 
            {BackgroundColor3 = self.UILibrary.Themes[self.Window.Theme].Secondary}
        )
        resetTween:Play()
    end)
    
    -- Вызываем callback
    if self.Callback then
        self.Callback()
    end
end

-- Обновление темы
function Button:UpdateTheme(themeName)
    local theme = self.UILibrary.Themes[themeName]
    
    -- Обновляем цвета
    self.Container.BackgroundColor3 = theme.Secondary
    self.NameLabel.TextColor3 = theme.Text
    
    if self.DescriptionLabel then
        self.DescriptionLabel.TextColor3 = theme.SubText
    end
    
    if self.IconImage then
        self.IconImage.ImageColor3 = theme.Text
    end
end

-- Изменение текста кнопки
function Button:SetText(text)
    self.Name = text
    self.NameLabel.Text = text
end

-- Изменение описания
function Button:SetDescription(description)
    self.Description = description
    
    if self.DescriptionLabel then
        self.DescriptionLabel.Text = description
    else
        -- Если описания не было, создаем его
        if description and description ~= "" then
            local textOffset = self.Icon and 25 or 0
            local theme = self.UILibrary.Themes[self.Window.Theme]
            
            -- Увеличиваем высоту контейнера
            self.Container.Size = UDim2.new(1, -20, 0, 60)
            
            -- Изменяем позицию названия
            self.NameLabel.Position = UDim2.new(0, 10 + textOffset, 0, 10)
            
            -- Создаем лейбл описания
            self.DescriptionLabel = Instance.new("TextLabel")
            self.DescriptionLabel.Name = "DescriptionLabel"
            self.DescriptionLabel.Size = UDim2.new(1, -40 - textOffset, 0, 14)
            self.DescriptionLabel.Position = UDim2.new(0, 10 + textOffset, 0, 30)
            self.DescriptionLabel.BackgroundTransparency = 1
            self.DescriptionLabel.Text = description
            self.DescriptionLabel.TextColor3 = theme.SubText
            self.DescriptionLabel.TextSize = 12
            self.DescriptionLabel.Font = Enum.Font.Gotham
            self.DescriptionLabel.TextXAlignment = Enum.TextXAlignment.Left
            self.DescriptionLabel.Parent = self.Container
        end
    end
end

return Button 