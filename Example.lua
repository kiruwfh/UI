--[[
    CrystalUI - Пример использования библиотеки
]]

-- Подключаем библиотеку (путь может отличаться в зависимости от структуры проекта)
local CrystalUI = require(game.ReplicatedStorage:WaitForChild("CrystalUI"))

-- Создаем настройки игрока (для примера)
local playerSettings = {
    Volume = 50,
    SFX = true,
    Music = true,
    Quality = "High",
    Sensitivity = 0.5,
    ThemeColor = Color3.fromRGB(90, 120, 255),
    Username = "",
    Notifications = true,
    AutoSave = true,
    SelectedItems = {}
}

-- Создаем главное окно настроек
local window = CrystalUI:CreateWindow({
    Title = "Настройки",
    Size = UDim2.new(0, 500, 0, 400),
    Position = UDim2.new(0.5, -250, 0.5, -200),
    Theme = "Dark" -- Можно выбрать: "Dark", "Light", "Purple"
})

-- Добавляем страницы
local generalPage = window:AddPage("Общие")
local audioPage = window:AddPage("Аудио")
local visualPage = window:AddPage("Визуал")
local controlsPage = window:AddPage("Управление")

-- СТРАНИЦА "ОБЩИЕ"
-- Добавляем различные элементы управления на страницу "Общие"

-- Переключатель автосохранения
local autoSaveToggle = window:AddToggle({
    Name = "Автосохранение",
    Description = "Автоматически сохранять настройки",
    Default = playerSettings.AutoSave,
    Callback = function(value)
        playerSettings.AutoSave = value
        print("Автосохранение:", value)
    end
})

-- Переключатель уведомлений
local notificationsToggle = window:AddToggle({
    Name = "Уведомления",
    Description = "Включить внутриигровые уведомления",
    Default = playerSettings.Notifications,
    Callback = function(value)
        playerSettings.Notifications = value
        print("Уведомления:", value)
    end
})

-- Текстовое поле для имени пользователя
local usernameInput = window:AddTextBox({
    Name = "Имя пользователя",
    Description = "Отображаемое имя в игре",
    Default = playerSettings.Username,
    Placeholder = "Введите имя...",
    Callback = function(value)
        playerSettings.Username = value
        print("Имя пользователя:", value)
    end
})

-- Выбор качества графики
local qualityDropdown = window:AddDropdown({
    Name = "Качество графики",
    Description = "Выберите качество графики",
    Options = {"Low", "Medium", "High", "Ultra"},
    Default = playerSettings.Quality,
    Callback = function(value)
        playerSettings.Quality = value
        print("Качество графики:", value)
    end
})

-- Кнопка сохранения
local saveButton = window:AddButton({
    Name = "Сохранить настройки",
    Description = "Сохранить все настройки",
    Callback = function()
        print("Настройки сохранены!")
        
        -- Пример уведомления об успешном сохранении
        if playerSettings.Notifications then
            -- Здесь можно добавить свою систему уведомлений
            print("[Уведомление] Настройки успешно сохранены!")
        end
    end
})

-- СТРАНИЦА "АУДИО"
-- Слайдер громкости
local volumeSlider = window:AddSlider({
    Name = "Громкость",
    Description = "Общая громкость игры",
    Min = 0,
    Max = 100,
    Default = playerSettings.Volume,
    Suffix = "%",
    Callback = function(value)
        playerSettings.Volume = value
        print("Громкость:", value)
    end
})

-- Переключатель звуковых эффектов
local sfxToggle = window:AddToggle({
    Name = "Звуковые эффекты",
    Description = "Включить звуковые эффекты",
    Default = playerSettings.SFX,
    Callback = function(value)
        playerSettings.SFX = value
        print("Звуковые эффекты:", value)
    end
})

-- Переключатель музыки
local musicToggle = window:AddToggle({
    Name = "Музыка",
    Description = "Включить фоновую музыку",
    Default = playerSettings.Music,
    Callback = function(value)
        playerSettings.Music = value
        print("Музыка:", value)
    end
})

-- СТРАНИЦА "ВИЗУАЛ"
-- Выбор цвета интерфейса
local themeColorPicker = window:AddColorPicker({
    Name = "Цвет темы",
    Description = "Выберите цвет интерфейса",
    Default = playerSettings.ThemeColor,
    Callback = function(color)
        playerSettings.ThemeColor = color
        print("Цвет темы:", color)
    end
})

-- Выбор темы
local themeDropdown = window:AddDropdown({
    Name = "Тема интерфейса",
    Description = "Выберите стиль интерфейса",
    Options = {"Dark", "Light", "Purple"},
    Default = "Dark",
    Callback = function(theme)
        -- Изменяем тему всего интерфейса
        CrystalUI:SetTheme(theme)
        print("Тема интерфейса:", theme)
    end
})

-- Мульти-выбор предметов (демонстрация множественного выбора)
local itemsDropdown = window:AddDropdown({
    Name = "Избранные предметы",
    Description = "Выберите предметы для быстрого доступа",
    Options = {"Меч", "Щит", "Лук", "Зелье здоровья", "Зелье маны", "Броня"},
    Default = playerSettings.SelectedItems,
    MultiSelect = true,
    Callback = function(items)
        playerSettings.SelectedItems = items
        print("Выбранные предметы:", table.concat(items, ", "))
    end
})

-- СТРАНИЦА "УПРАВЛЕНИЕ"
-- Слайдер чувствительности
local sensitivitySlider = window:AddSlider({
    Name = "Чувствительность",
    Description = "Скорость движения камеры",
    Min = 0.1,
    Max = 2,
    Default = playerSettings.Sensitivity,
    Increment = 0.1,
    Callback = function(value)
        playerSettings.Sensitivity = value
        print("Чувствительность:", value)
    end
})

-- Кнопка сброса настроек управления
local resetControlsButton = window:AddButton({
    Name = "Сбросить настройки",
    Description = "Вернуть настройки управления по умолчанию",
    Callback = function()
        -- Сбрасываем чувствительность на значение по умолчанию
        sensitivitySlider:SetValue(0.5)
        print("Настройки управления сброшены!")
    end
})

-- Поле для ввода сочетания клавиш (для примера)
local keybindInput = window:AddTextBox({
    Name = "Сочетание клавиш",
    Description = "Нажмите и введите сочетание клавиш",
    Placeholder = "Например: Shift+F",
    Callback = function(value)
        print("Новое сочетание клавиш:", value)
    end
})

-- Кнопка для тестирования управления
local testControlsButton = window:AddButton({
    Name = "Тестировать управление",
    Callback = function()
        print("Запуск теста управления с чувствительностью:", playerSettings.Sensitivity)
    end
})

-- Дополнительная информация на странице
local infoTextBox = window:AddTextBox({
    Name = "Дополнительно",
    Description = "Опишите проблемы с управлением, если они возникают",
    MultiLine = true,
    Placeholder = "Введите текст...",
    Callback = function(value)
        print("Дополнительная информация:", value)
    end
})

-- Выводим сообщение в консоль для отладки
print("CrystalUI инициализирован! Открыто окно настроек.") 