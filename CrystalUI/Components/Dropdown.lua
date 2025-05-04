--[[
    CrystalUI - Dropdown Component
    Компонент выпадающего списка с одиночным или множественным выбором
]]

local Dropdown = {}
Dropdown.__index = Dropdown

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

function Dropdown.new(options, uiLibrary, window)
    local self = setmetatable({}, Dropdown)
    
    -- Параметры по умолчанию
    options = options or {}
    self.Name = options.Name or "Dropdown"
    self.Description = options.Description or ""
    self.Options = options.Options or {}
    self.Default = options.Default or nil
    self.MaxVisibleItems = options.MaxVisibleItems or 5
    self.MultiSelect = options.MultiSelect or false
    self.Callback = options.Callback or function() end
    self.UILibrary = uiLibrary
    self.Window = window
    
    -- Задаем начальное значение
    self.Selected = {}
    
    if self.Default then
        if self.MultiSelect and type(self.Default) == "table" then
            for _, value in pairs(self.Default) do
                self.Selected[value] = true
            end
        elseif not self.MultiSelect and type(self.Default) == "string" then
            self.Selected[self.Default] = true
        end
    end
    
    -- Состояние выпадающего списка
    self.Open = false
    
    -- Создание UI элементов
    self:_CreateUI()
    
    -- Обновляем текст
    self:_UpdateText()
    
    return self
end

function Dropdown:_CreateUI()
    local theme = self.UILibrary.Themes[self.Window.Theme]
    
    -- Основной контейнер
    self.Container = Instance.new("Frame")
    self.Container.Name = self.Name:gsub("%s+", "") .. "Dropdown"
    self.Container.Size = UDim2.new(1, -20, 0, 40)
    self.Container.BackgroundColor3 = theme.Secondary
    self.Container.BorderSizePixel = 0
    self.Container.ClipsDescendants = true
    self.Container.ZIndex = 1
    
    -- Закругление углов
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = self.Container
    
    -- Заголовок и описание
    self.HeaderContainer = Instance.new("Frame")
    self.HeaderContainer.Name = "HeaderContainer"
    self.HeaderContainer.Size = UDim2.new(1, 0, 0, 40)
    self.HeaderContainer.BackgroundTransparency = 1
    self.HeaderContainer.Parent = self.Container
    
    -- Название дропдауна
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
    self.NameLabel.Parent = self.HeaderContainer
    
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
        self.DescriptionLabel.Parent = self.HeaderContainer
    end
    
    -- Отображение выбранного значения
    self.SelectedLabel = Instance.new("TextLabel")
    self.SelectedLabel.Name = "SelectedLabel"
    self.SelectedLabel.Size = UDim2.new(0, 0, 0, 20)
    self.SelectedLabel.Position = UDim2.new(1, -30, 0, 10)
    self.SelectedLabel.BackgroundTransparency = 1
    self.SelectedLabel.Text = "Select..."
    self.SelectedLabel.TextColor3 = theme.SubText
    self.SelectedLabel.TextSize = 14
    self.SelectedLabel.Font = Enum.Font.Gotham
    self.SelectedLabel.TextXAlignment = Enum.TextXAlignment.Right
    self.SelectedLabel.AutomaticSize = Enum.AutomaticSize.X
    self.SelectedLabel.Parent = self.HeaderContainer
    
    -- Иконка стрелки
    self.ArrowIcon = Instance.new("ImageLabel")
    self.ArrowIcon.Name = "ArrowIcon"
    self.ArrowIcon.Size = UDim2.new(0, 16, 0, 16)
    self.ArrowIcon.Position = UDim2.new(1, -20, 0.5, -8)
    self.ArrowIcon.BackgroundTransparency = 1
    self.ArrowIcon.Image = "rbxassetid://6031094670"
    self.ArrowIcon.ImageColor3 = theme.Text
    self.ArrowIcon.Rotation = 90
    self.ArrowIcon.Parent = self.HeaderContainer
    
    -- Контейнер для опций
    self.OptionsContainer = Instance.new("ScrollingFrame")
    self.OptionsContainer.Name = "OptionsContainer"
    self.OptionsContainer.Size = UDim2.new(1, -10, 0, 0) -- Изначально скрыт (высота 0)
    self.OptionsContainer.Position = UDim2.new(0, 5, 0, 40)
    self.OptionsContainer.BackgroundTransparency = 1
    self.OptionsContainer.BorderSizePixel = 0
    self.OptionsContainer.ScrollBarThickness = 4
    self.OptionsContainer.ScrollBarImageColor3 = theme.Primary
    self.OptionsContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.OptionsContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    self.OptionsContainer.Parent = self.Container
    
    -- Разделитель
    self.Separator = Instance.new("Frame")
    self.Separator.Name = "Separator"
    self.Separator.Size = UDim2.new(1, -10, 0, 1)
    self.Separator.Position = UDim2.new(0, 5, 0, 40)
    self.Separator.BackgroundColor3 = theme.Border
    self.Separator.BorderSizePixel = 0
    self.Separator.Visible = false
    self.Separator.Parent = self.Container
    
    -- Контейнер для элементов списка
    self.ItemsHolder = Instance.new("Frame")
    self.ItemsHolder.Name = "ItemsHolder"
    self.ItemsHolder.Size = UDim2.new(1, 0, 0, 0)
    self.ItemsHolder.BackgroundTransparency = 1
    self.ItemsHolder.AutomaticSize = Enum.AutomaticSize.Y
    self.ItemsHolder.Parent = self.OptionsContainer
    
    -- Авторазмещение элементов списка
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 2)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = self.ItemsHolder
    
    -- Создаем элементы списка
    self:_CreateOptions()
    
    -- Кнопка для взаимодействия с заголовком (открытие/закрытие)
    self.HeaderButton = Instance.new("TextButton")
    self.HeaderButton.Name = "HeaderButton"
    self.HeaderButton.Size = UDim2.new(1, 0, 1, 0)
    self.HeaderButton.BackgroundTransparency = 1
    self.HeaderButton.Text = ""
    self.HeaderButton.Parent = self.HeaderContainer
    
    -- Настройка взаимодействий
    self:_SetupEvents()
end

-- Создание опций выпадающего списка
function Dropdown:_CreateOptions()
    local theme = self.UILibrary.Themes[self.Window.Theme]
    
    -- Создаем каждый элемент списка
    for i, option in ipairs(self.Options) do
        local itemButton = Instance.new("TextButton")
        itemButton.Name = "Option_" .. option
        itemButton.Size = UDim2.new(1, 0, 0, 30)
        itemButton.BackgroundColor3 = theme.Secondary
        itemButton.BorderSizePixel = 0
        itemButton.Text = option
        itemButton.TextColor3 = theme.Text
        itemButton.TextSize = 14
        itemButton.Font = Enum.Font.Gotham
        itemButton.Parent = self.ItemsHolder
        itemButton.ZIndex = 2
        
        -- Индикатор выбора для мульти-выбора
        if self.MultiSelect then
            local checkbox = Instance.new("Frame")
            checkbox.Name = "Checkbox"
            checkbox.Size = UDim2.new(0, 16, 0, 16)
            checkbox.Position = UDim2.new(0, 5, 0.5, -8)
            checkbox.BackgroundColor3 = theme.Border
            checkbox.BorderSizePixel = 0
            checkbox.ZIndex = 3
            checkbox.Parent = itemButton
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 4)
            corner.Parent = checkbox
            
            local checkmark = Instance.new("ImageLabel")
            checkmark.Name = "Checkmark"
            checkmark.Size = UDim2.new(0.8, 0, 0.8, 0)
            checkmark.Position = UDim2.new(0.1, 0, 0.1, 0)
            checkmark.BackgroundTransparency = 1
            checkmark.Image = "rbxassetid://6031094667"
            checkmark.ImageColor3 = Color3.fromRGB(255, 255, 255)
            checkmark.ZIndex = 4
            checkmark.Visible = self.Selected[option] or false
            checkmark.Parent = checkbox
            
            -- Сдвигаем текст, чтобы освободить место для чекбокса
            itemButton.TextXAlignment = Enum.TextXAlignment.Left
            itemButton.Text = "      " .. option
        end
        
        -- Подсветка при наведении
        itemButton.MouseEnter:Connect(function()
            local hoverTween = TweenService:Create(
                itemButton, 
                TweenInfo.new(0.1), 
                {BackgroundColor3 = theme.Secondary:Lerp(theme.Primary, 0.1)}
            )
            hoverTween:Play()
        end)
        
        itemButton.MouseLeave:Connect(function()
            -- Цвет зависит от выбранности элемента (для одиночного выбора)
            local targetColor = (not self.MultiSelect and self.Selected[option]) 
                and theme.Primary:Lerp(theme.Secondary, 0.7)
                or theme.Secondary
                
            local leaveTween = TweenService:Create(
                itemButton, 
                TweenInfo.new(0.1), 
                {BackgroundColor3 = targetColor}
            )
            leaveTween:Play()
        end)
        
        -- Если элемент уже выбран, устанавливаем цвет
        if not self.MultiSelect and self.Selected[option] then
            itemButton.BackgroundColor3 = theme.Primary:Lerp(theme.Secondary, 0.7)
        end
        
        -- Обработка клика по элементу
        itemButton.MouseButton1Click:Connect(function()
            if self.MultiSelect then
                -- Для множественного выбора - переключаем состояние
                self.Selected[option] = not self.Selected[option]
                local checkmark = itemButton.Checkbox.Checkmark
                checkmark.Visible = self.Selected[option]
                
                local checkboxTween = TweenService:Create(
                    itemButton.Checkbox, 
                    TweenInfo.new(0.2), 
                    {BackgroundColor3 = self.Selected[option] and theme.Primary or theme.Border}
                )
                checkboxTween:Play()
            else
                -- Для одиночного выбора - выбираем только текущий элемент
                
                -- Сначала сбрасываем все выделения
                for _, child in pairs(self.ItemsHolder:GetChildren()) do
                    if child:IsA("TextButton") then
                        local resetTween = TweenService:Create(
                            child, 
                            TweenInfo.new(0.2), 
                            {BackgroundColor3 = theme.Secondary}
                        )
                        resetTween:Play()
                    end
                end
                
                -- Выделяем текущий
                self.Selected = {}
                self.Selected[option] = true
                
                local selectTween = TweenService:Create(
                    itemButton, 
                    TweenInfo.new(0.2), 
                    {BackgroundColor3 = theme.Primary:Lerp(theme.Secondary, 0.7)}
                )
                selectTween:Play()
                
                -- Закрываем выпадающий список
                self:Toggle(false)
            end
            
            -- Обновляем текст выбранного
            self:_UpdateText()
            
            -- Вызываем callback с текущим выбором
            if self.Callback then
                if self.MultiSelect then
                    -- Для множественного выбора возвращаем таблицу выбранных
                    local selectedItems = {}
                    for option, selected in pairs(self.Selected) do
                        if selected then
                            table.insert(selectedItems, option)
                        end
                    end
                    self.Callback(selectedItems)
                else
                    -- Для одиночного выбора возвращаем строку
                    for option, selected in pairs(self.Selected) do
                        if selected then
                            self.Callback(option)
                            break
                        end
                    end
                end
            end
        end)
    end
    
    -- Устанавливаем максимальную высоту контейнера опций
    local maxVisibleItems = math.min(self.MaxVisibleItems, #self.Options)
    self.MaxHeight = maxVisibleItems * 32 -- 30 + 2 (высота элемента + отступ)
end

-- Настройка взаимодействий
function Dropdown:_SetupEvents()
    -- Открытие/закрытие выпадающего списка при клике на заголовок
    self.HeaderButton.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    
    -- Эффект при наведении на заголовок
    self.HeaderButton.MouseEnter:Connect(function()
        local hoverTween = TweenService:Create(
            self.Container, 
            TweenInfo.new(0.2), 
            {BackgroundColor3 = self.UILibrary.Themes[self.Window.Theme].Secondary:Lerp(self.UILibrary.Themes[self.Window.Theme].Primary, 0.1)}
        )
        hoverTween:Play()
    end)
    
    self.HeaderButton.MouseLeave:Connect(function()
        local leaveTween = TweenService:Create(
            self.Container, 
            TweenInfo.new(0.2), 
            {BackgroundColor3 = self.UILibrary.Themes[self.Window.Theme].Secondary}
        )
        leaveTween:Play()
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

-- Обновление текста выбранного
function Dropdown:_UpdateText()
    local theme = self.UILibrary.Themes[self.Window.Theme]
    
    if self.MultiSelect then
        -- Для мульти-выбора считаем количество выбранных
        local count = 0
        for _, selected in pairs(self.Selected) do
            if selected then
                count = count + 1
            end
        end
        
        if count == 0 then
            self.SelectedLabel.Text = "Select..."
            self.SelectedLabel.TextColor3 = theme.SubText
        else
            self.SelectedLabel.Text = count .. " selected"
            self.SelectedLabel.TextColor3 = theme.Text
        end
    else
        -- Для одиночного выбора показываем выбранный элемент
        local selected = false
        for option, isSelected in pairs(self.Selected) do
            if isSelected then
                self.SelectedLabel.Text = option
                self.SelectedLabel.TextColor3 = theme.Text
                selected = true
                break
            end
        end
        
        if not selected then
            self.SelectedLabel.Text = "Select..."
            self.SelectedLabel.TextColor3 = theme.SubText
        end
    end
end

-- Открытие/закрытие выпадающего списка
function Dropdown:Toggle(state)
    -- Если состояние не указано, переключаем текущее
    if state == nil then
        state = not self.Open
    end
    
    self.Open = state
    
    -- Обновляем состояние компонентов
    self.Separator.Visible = state
    
    -- Анимация стрелки
    local arrowTween = TweenService:Create(
        self.ArrowIcon, 
        TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), 
        {Rotation = state and -90 or 90}
    )
    arrowTween:Play()
    
    -- Анимация контейнера опций
    local optionsHeightTween = TweenService:Create(
        self.OptionsContainer, 
        TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), 
        {Size = UDim2.new(1, -10, 0, state and self.MaxHeight or 0)}
    )
    optionsHeightTween:Play()
    
    -- Анимация высоты всего контейнера
    local containerHeightTween = TweenService:Create(
        self.Container, 
        TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), 
        {Size = UDim2.new(1, -20, 0, state and (40 + self.MaxHeight + 5) or 40)}
    )
    containerHeightTween:Play()
end

-- Установка значения
function Dropdown:SetValue(value, ignoreCallback)
    if self.MultiSelect and type(value) == "table" then
        -- Для множественного выбора принимаем таблицу
        self.Selected = {}
        for _, option in pairs(value) do
            self.Selected[option] = true
        end
    elseif not self.MultiSelect and type(value) == "string" then
        -- Для одиночного выбора принимаем строку
        self.Selected = {}
        self.Selected[value] = true
    end
    
    -- Обновляем отображение
    self:_UpdateText()
    
    -- Обновляем отображение checkmark для мульти-выбора
    if self.MultiSelect then
        for _, child in pairs(self.ItemsHolder:GetChildren()) do
            if child:IsA("TextButton") and child:FindFirstChild("Checkbox") then
                local option = child.Name:gsub("Option_", "")
                child.Checkbox.Checkmark.Visible = self.Selected[option] or false
                child.Checkbox.BackgroundColor3 = self.Selected[option] 
                    and self.UILibrary.Themes[self.Window.Theme].Primary 
                    or self.UILibrary.Themes[self.Window.Theme].Border
            end
        end
    else
        -- Обновляем цвета для одиночного выбора
        for _, child in pairs(self.ItemsHolder:GetChildren()) do
            if child:IsA("TextButton") then
                local option = child.Name:gsub("Option_", "")
                child.BackgroundColor3 = self.Selected[option] 
                    and self.UILibrary.Themes[self.Window.Theme].Primary:Lerp(self.UILibrary.Themes[self.Window.Theme].Secondary, 0.7)
                    or self.UILibrary.Themes[self.Window.Theme].Secondary
            end
        end
    end
    
    -- Вызываем callback если нужно
    if not ignoreCallback and self.Callback then
        if self.MultiSelect then
            local selectedItems = {}
            for option, selected in pairs(self.Selected) do
                if selected then
                    table.insert(selectedItems, option)
                end
            end
            self.Callback(selectedItems)
        else
            for option, selected in pairs(self.Selected) do
                if selected then
                    self.Callback(option)
                    break
                end
            end
        end
    end
end

-- Обновление доступных опций
function Dropdown:UpdateOptions(options)
    self.Options = options
    
    -- Очищаем текущие опции
    for _, child in pairs(self.ItemsHolder:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    -- Создаем новые
    self:_CreateOptions()
    
    -- Обновляем выбранные значения (удаляем несуществующие)
    local newSelected = {}
    for option, selected in pairs(self.Selected) do
        local found = false
        for _, newOption in ipairs(self.Options) do
            if option == newOption then
                found = true
                break
            end
        end
        
        if found and selected then
            newSelected[option] = true
        end
    end
    
    self.Selected = newSelected
    self:_UpdateText()
end

-- Обновление темы
function Dropdown:UpdateTheme(themeName)
    local theme = self.UILibrary.Themes[themeName]
    
    -- Обновляем цвета основных элементов
    self.Container.BackgroundColor3 = theme.Secondary
    self.NameLabel.TextColor3 = theme.Text
    self.ArrowIcon.ImageColor3 = theme.Text
    self.Separator.BackgroundColor3 = theme.Border
    
    if self.DescriptionLabel then
        self.DescriptionLabel.TextColor3 = theme.SubText
    end
    
    -- Обновляем цвет текста выбранного
    local hasSelection = false
    for _, selected in pairs(self.Selected) do
        if selected then
            hasSelection = true
            break
        end
    end
    
    self.SelectedLabel.TextColor3 = hasSelection and theme.Text or theme.SubText
    
    -- Обновляем цвета элементов списка
    for _, child in pairs(self.ItemsHolder:GetChildren()) do
        if child:IsA("TextButton") then
            child.TextColor3 = theme.Text
            
            local option = child.Name:gsub("Option_", "")
            
            if self.MultiSelect and child:FindFirstChild("Checkbox") then
                -- Для мульти-выбора обновляем чекбоксы
                child.Checkbox.BackgroundColor3 = self.Selected[option] 
                    and theme.Primary 
                    or theme.Border
            else
                -- Для одиночного выбора обновляем фон кнопки
                child.BackgroundColor3 = self.Selected[option] 
                    and theme.Primary:Lerp(theme.Secondary, 0.7)
                    or theme.Secondary
            end
        end
    end
end

return Dropdown 