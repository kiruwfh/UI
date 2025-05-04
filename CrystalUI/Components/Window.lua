--[[
    CrystalUI - Window Component
    Основной контейнер для интерфейса
]]

local Window = {}
Window.__index = Window
Window.Instances = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Создание нового окна
function Window.new(options, uiLibrary)
    local self = setmetatable({}, Window)
    
    -- Параметры по умолчанию
    options = options or {}
    self.Title = options.Title or "CrystalUI Window"
    self.Size = options.Size or UDim2.new(0, 400, 0, 300)
    self.Position = options.Position or UDim2.new(0.5, -200, 0.5, -150)
    self.Theme = options.Theme or "Dark"
    self.UILibrary = uiLibrary
    self.Components = {}
    self.Pages = {}
    self.CurrentPage = nil
    
    -- Создание UI структуры
    self:_CreateUI()
    
    -- Добавление окна в глобальный список окон
    table.insert(Window.Instances, self)
    
    return self
end

-- Создание UI элементов окна
function Window:_CreateUI()
    local theme = self.UILibrary.Themes[self.Theme]
    
    -- Основной ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "CrystalUI_" .. self.Title:gsub("%s+", "_")
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Главный фрейм
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Size = self.Size
    self.MainFrame.Position = self.Position
    self.MainFrame.BackgroundColor3 = theme.Background
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    self.MainFrame.Parent = self.ScreenGui
    
    -- Закругление углов
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = self.MainFrame
    
    -- Тень
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.ZIndex = -1
    shadow.Image = "rbxassetid://6014261993"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.Parent = self.MainFrame
    
    -- Верхняя панель (заголовок)
    self.TopBar = Instance.new("Frame")
    self.TopBar.Name = "TopBar"
    self.TopBar.Size = UDim2.new(1, 0, 0, 30)
    self.TopBar.BackgroundColor3 = theme.Primary
    self.TopBar.BorderSizePixel = 0
    self.TopBar.Parent = self.MainFrame
    
    -- Закругление верхней панели
    local topBarCorner = Instance.new("UICorner")
    topBarCorner.CornerRadius = UDim.new(0, 6)
    topBarCorner.Parent = self.TopBar
    
    -- Убираем закругление снизу у верхней панели
    local topBarFix = Instance.new("Frame")
    topBarFix.Name = "TopBarFix"
    topBarFix.Size = UDim2.new(1, 0, 0.5, 0)
    topBarFix.Position = UDim2.new(0, 0, 0.5, 0)
    topBarFix.BackgroundColor3 = theme.Primary
    topBarFix.BorderSizePixel = 0
    topBarFix.ZIndex = 0
    topBarFix.Parent = self.TopBar
    
    -- Заголовок
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Name = "Title"
    self.TitleLabel.Size = UDim2.new(1, -60, 1, 0)
    self.TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = self.Title
    self.TitleLabel.TextColor3 = theme.Text
    self.TitleLabel.TextSize = 16
    self.TitleLabel.Font = Enum.Font.GothamSemibold
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.Parent = self.TopBar
    
    -- Кнопка закрытия
    self.CloseButton = Instance.new("TextButton")
    self.CloseButton.Name = "CloseButton"
    self.CloseButton.Size = UDim2.new(0, 24, 0, 24)
    self.CloseButton.Position = UDim2.new(1, -27, 0, 3)
    self.CloseButton.BackgroundTransparency = 1
    self.CloseButton.Text = "✕"
    self.CloseButton.TextColor3 = theme.Text
    self.CloseButton.TextSize = 14
    self.CloseButton.Font = Enum.Font.GothamBold
    self.CloseButton.Parent = self.TopBar
    
    -- Кнопка сворачивания
    self.MinimizeButton = Instance.new("TextButton")
    self.MinimizeButton.Name = "MinimizeButton"
    self.MinimizeButton.Size = UDim2.new(0, 24, 0, 24)
    self.MinimizeButton.Position = UDim2.new(1, -52, 0, 3)
    self.MinimizeButton.BackgroundTransparency = 1
    self.MinimizeButton.Text = "−"
    self.MinimizeButton.TextColor3 = theme.Text
    self.MinimizeButton.TextSize = 14
    self.MinimizeButton.Font = Enum.Font.GothamBold
    self.MinimizeButton.Parent = self.TopBar
    
    -- Контейнер для контента
    self.ContentContainer = Instance.new("Frame")
    self.ContentContainer.Name = "ContentContainer"
    self.ContentContainer.Size = UDim2.new(1, 0, 1, -30)
    self.ContentContainer.Position = UDim2.new(0, 0, 0, 30)
    self.ContentContainer.BackgroundColor3 = theme.Container
    self.ContentContainer.BorderSizePixel = 0
    self.ContentContainer.Parent = self.MainFrame
    
    -- Контейнер для боковой панели
    self.SideBar = Instance.new("Frame")
    self.SideBar.Name = "SideBar"
    self.SideBar.Size = UDim2.new(0, 120, 1, 0)
    self.SideBar.BackgroundColor3 = theme.Secondary
    self.SideBar.BorderSizePixel = 0
    self.SideBar.Parent = self.ContentContainer
    
    -- Контейнер для кнопок боковой панели
    self.SideBarContainer = Instance.new("ScrollingFrame")
    self.SideBarContainer.Name = "SideBarContainer"
    self.SideBarContainer.Size = UDim2.new(1, 0, 1, 0)
    self.SideBarContainer.BackgroundTransparency = 1
    self.SideBarContainer.BorderSizePixel = 0
    self.SideBarContainer.ScrollBarThickness = 2
    self.SideBarContainer.ScrollBarImageColor3 = theme.Primary
    self.SideBarContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.SideBarContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    self.SideBarContainer.Parent = self.SideBar
    
    -- Основной контейнер для компонентов (страниц)
    self.PageContainer = Instance.new("Frame")
    self.PageContainer.Name = "PageContainer"
    self.PageContainer.Size = UDim2.new(1, -120, 1, 0)
    self.PageContainer.Position = UDim2.new(0, 120, 0, 0)
    self.PageContainer.BackgroundTransparency = 1
    self.PageContainer.BorderSizePixel = 0
    self.PageContainer.Parent = self.ContentContainer
    
    -- Реализация перетаскивания окна
    self:_MakeDraggable()
    
    -- Функционал кнопок
    self:_SetupButtons()
end

-- Реализация перемещения окна
function Window:_MakeDraggable()
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    
    self.TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.MainFrame.Position
        end
    end)
    
    self.TopBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            self.MainFrame.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X, 
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    self.TopBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
end

-- Настройка функциональности кнопок
function Window:_SetupButtons()
    -- Закрытие окна
    self.CloseButton.MouseButton1Click:Connect(function()
        self:Close()
    end)
    
    -- Сворачивание окна
    local minimized = false
    local originalSize = self.MainFrame.Size
    
    self.MinimizeButton.MouseButton1Click:Connect(function()
        minimized = not minimized
        
        local targetSize = minimized 
            and UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, 30) 
            or originalSize
            
        local tween = TweenService:Create(
            self.MainFrame, 
            TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), 
            {Size = targetSize}
        )
        
        tween:Play()
        
        -- Скрываем или показываем контент
        self.ContentContainer.Visible = not minimized
    end)
end

-- Создание новой страницы
function Window:AddPage(name)
    -- Создаем кнопку страницы в боковой панели
    local pageButton = Instance.new("TextButton")
    pageButton.Name = name .. "Button"
    pageButton.Size = UDim2.new(1, -10, 0, 30)
    pageButton.Position = UDim2.new(0, 5, 0, #self.Pages * 35 + 5)
    pageButton.BackgroundColor3 = self.UILibrary.Themes[self.Theme].Secondary
    pageButton.BorderSizePixel = 0
    pageButton.Text = name
    pageButton.TextColor3 = self.UILibrary.Themes[self.Theme].Text
    pageButton.TextSize = 14
    pageButton.Font = Enum.Font.Gotham
    pageButton.Parent = self.SideBarContainer
    
    -- Добавляем закругление кнопки
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 4)
    buttonCorner.Parent = pageButton
    
    -- Создаем контейнер страницы
    local pageContainer = Instance.new("ScrollingFrame")
    pageContainer.Name = name .. "Page"
    pageContainer.Size = UDim2.new(1, -20, 1, -20)
    pageContainer.Position = UDim2.new(0, 10, 0, 10)
    pageContainer.BackgroundTransparency = 1
    pageContainer.BorderSizePixel = 0
    pageContainer.ScrollBarThickness = 4
    pageContainer.ScrollBarImageColor3 = self.UILibrary.Themes[self.Theme].Primary
    pageContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    pageContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    pageContainer.Visible = false
    pageContainer.Parent = self.PageContainer
    
    -- Создаем контейнер для компонентов
    local componentsContainer = Instance.new("Frame")
    componentsContainer.Name = "ComponentsContainer"
    componentsContainer.Size = UDim2.new(1, 0, 0, 0)
    componentsContainer.BackgroundTransparency = 1
    componentsContainer.AutomaticSize = Enum.AutomaticSize.Y
    componentsContainer.Parent = pageContainer
    
    -- Создаем UIListLayout для автоматического размещения компонентов
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 10)
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = componentsContainer
    
    -- Добавляем отступ сверху
    local paddingTop = Instance.new("UIPadding")
    paddingTop.PaddingTop = UDim.new(0, 5)
    paddingTop.Parent = componentsContainer
    
    -- Создаем объект страницы
    local page = {
        Name = name,
        Button = pageButton,
        Container = pageContainer,
        ComponentsContainer = componentsContainer,
        Components = {}
    }
    
    -- Добавляем страницу в список страниц
    table.insert(self.Pages, page)
    
    -- При клике на кнопку страницы - показываем её
    pageButton.MouseButton1Click:Connect(function()
        self:SelectPage(name)
    end)
    
    -- Если это первая страница - делаем её активной
    if #self.Pages == 1 then
        self:SelectPage(name)
    end
    
    -- Возвращаем объект страницы
    return page
end

-- Выбор страницы
function Window:SelectPage(pageName)
    for _, page in pairs(self.Pages) do
        local isSelected = page.Name == pageName
        page.Container.Visible = isSelected
        
        -- Изменяем цвет кнопки в зависимости от состояния выбранности
        if isSelected then
            page.Button.BackgroundColor3 = self.UILibrary.Themes[self.Theme].Primary
            self.CurrentPage = page
        else
            page.Button.BackgroundColor3 = self.UILibrary.Themes[self.Theme].Secondary
        end
    end
end

-- Обновление темы окна
function Window:UpdateTheme(themeName)
    -- Проверяем, существует ли тема
    if not self.UILibrary.Themes[themeName] then return end
    
    -- Обновляем текущую тему
    self.Theme = themeName
    local theme = self.UILibrary.Themes[themeName]
    
    -- Обновляем цвета основных элементов
    self.MainFrame.BackgroundColor3 = theme.Background
    self.TopBar.BackgroundColor3 = theme.Primary
    self.TopBarFix.BackgroundColor3 = theme.Primary
    self.TitleLabel.TextColor3 = theme.Text
    self.CloseButton.TextColor3 = theme.Text
    self.MinimizeButton.TextColor3 = theme.Text
    self.ContentContainer.BackgroundColor3 = theme.Container
    self.SideBar.BackgroundColor3 = theme.Secondary
    self.SideBarContainer.ScrollBarImageColor3 = theme.Primary
    
    -- Обновляем цвета страниц
    for _, page in pairs(self.Pages) do
        page.Container.ScrollBarImageColor3 = theme.Primary
        
        -- Если это текущая страница, применяем цвет выбранной страницы
        if self.CurrentPage and page.Name == self.CurrentPage.Name then
            page.Button.BackgroundColor3 = theme.Primary
        else
            page.Button.BackgroundColor3 = theme.Secondary
        end
        
        page.Button.TextColor3 = theme.Text
        
        -- Обновляем цвета всех компонентов на странице
        for _, component in pairs(page.Components) do
            if component.UpdateTheme then
                component:UpdateTheme(themeName)
            end
        end
    end
end

-- Добавление переключателя (Toggle)
function Window:AddToggle(options)
    if not self.CurrentPage then
        warn("CrystalUI: Нельзя добавить компонент, так как нет активной страницы")
        return nil
    end
    
    -- Добавляем компонент через выбранную страницу
    local toggle = self.UILibrary.Components.Toggle.new(options, self.UILibrary, self)
    table.insert(self.CurrentPage.Components, toggle)
    toggle.Container.Parent = self.CurrentPage.ComponentsContainer
    return toggle
end

-- Добавление кнопки (Button)
function Window:AddButton(options)
    if not self.CurrentPage then
        warn("CrystalUI: Нельзя добавить компонент, так как нет активной страницы")
        return nil
    end
    
    local button = self.UILibrary.Components.Button.new(options, self.UILibrary, self)
    table.insert(self.CurrentPage.Components, button)
    button.Container.Parent = self.CurrentPage.ComponentsContainer
    return button
end

-- Добавление слайдера (Slider)
function Window:AddSlider(options)
    if not self.CurrentPage then
        warn("CrystalUI: Нельзя добавить компонент, так как нет активной страницы")
        return nil
    end
    
    local slider = self.UILibrary.Components.Slider.new(options, self.UILibrary, self)
    table.insert(self.CurrentPage.Components, slider)
    slider.Container.Parent = self.CurrentPage.ComponentsContainer
    return slider
end

-- Добавление выпадающего списка (Dropdown)
function Window:AddDropdown(options)
    if not self.CurrentPage then
        warn("CrystalUI: Нельзя добавить компонент, так как нет активной страницы")
        return nil
    end
    
    local dropdown = self.UILibrary.Components.Dropdown.new(options, self.UILibrary, self)
    table.insert(self.CurrentPage.Components, dropdown)
    dropdown.Container.Parent = self.CurrentPage.ComponentsContainer
    return dropdown
end

-- Добавление текстового поля (TextBox)
function Window:AddTextBox(options)
    if not self.CurrentPage then
        warn("CrystalUI: Нельзя добавить компонент, так как нет активной страницы")
        return nil
    end
    
    local textbox = self.UILibrary.Components.TextBox.new(options, self.UILibrary, self)
    table.insert(self.CurrentPage.Components, textbox)
    textbox.Container.Parent = self.CurrentPage.ComponentsContainer
    return textbox
end

-- Добавление выбора цвета (ColorPicker)
function Window:AddColorPicker(options)
    if not self.CurrentPage then
        warn("CrystalUI: Нельзя добавить компонент, так как нет активной страницы")
        return nil
    end
    
    local colorPicker = self.UILibrary.Components.ColorPicker.new(options, self.UILibrary, self)
    table.insert(self.CurrentPage.Components, colorPicker)
    colorPicker.Container.Parent = self.CurrentPage.ComponentsContainer
    return colorPicker
end

-- Закрытие окна
function Window:Close()
    -- Анимация закрытия
    local tween = TweenService:Create(
        self.MainFrame, 
        TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), 
        {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}
    )
    
    tween.Completed:Connect(function()
        -- Удаляем окно из списка окон
        for i, window in pairs(Window.Instances) do
            if window == self then
                table.remove(Window.Instances, i)
                break
            end
        end
        
        -- Удаляем GUI
        self.ScreenGui:Destroy()
    end)
    
    tween:Play()
end

return Window 