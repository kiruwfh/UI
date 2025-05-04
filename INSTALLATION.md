# Установка и использование CrystalUI для Roblox

## Установка

### Метод 1: Roblox Studio

1. Скачайте все файлы библиотеки
2. В Roblox Studio откройте ваш проект
3. Создайте новую папку ModuleScript в ReplicatedStorage с именем "CrystalUI"
4. Внутри папки CrystalUI создайте еще одну папку ModuleScript с именем "Components"
5. Загрузите следующие файлы:
   - `init.lua` -> CrystalUI
   - `Components/Window.lua` -> CrystalUI/Components
   - `Components/Toggle.lua` -> CrystalUI/Components
   - `Components/Button.lua` -> CrystalUI/Components
   - `Components/Slider.lua` -> CrystalUI/Components
   - `Components/Dropdown.lua` -> CrystalUI/Components
   - `Components/TextBox.lua` -> CrystalUI/Components
   - `Components/ColorPicker.lua` -> CrystalUI/Components

### Метод 2: Импорт через Roblox Asset

1. Опубликуйте библиотеку как модель в Roblox Asset Library
2. В вашей игре используйте модель библиотеки и поместите её в ReplicatedStorage

## Базовое использование

```lua
-- Подключение библиотеки
local CrystalUI = require(game.ReplicatedStorage:WaitForChild("CrystalUI"))

-- Создание главного окна
local window = CrystalUI:CreateWindow({
    Title = "Мое окно",
    Size = UDim2.new(0, 400, 0, 300),
    Position = UDim2.new(0.5, -200, 0.5, -150),
    Theme = "Dark" -- Доступные темы: "Dark", "Light", "Purple"
})

-- Добавление страницы
local page = window:AddPage("Главная")

-- Добавление переключателя (Toggle)
local toggle = window:AddToggle({
    Name = "Мой переключатель",
    Description = "Описание переключателя",
    Default = false,
    Callback = function(value)
        print("Переключатель:", value)
    end
})

-- Добавление слайдера (Slider)
local slider = window:AddSlider({
    Name = "Мой слайдер",
    Description = "Описание слайдера",
    Min = 0,
    Max = 100,
    Default = 50,
    Callback = function(value)
        print("Слайдер:", value)
    end
})

-- Добавление выпадающего списка (Dropdown)
local dropdown = window:AddDropdown({
    Name = "Мой выпадающий список",
    Description = "Описание списка",
    Options = {"Опция 1", "Опция 2", "Опция 3"},
    Default = "Опция 1",
    Callback = function(value)
        print("Выбрано:", value)
    end
})

-- Добавление кнопки (Button)
local button = window:AddButton({
    Name = "Моя кнопка",
    Description = "Описание кнопки",
    Callback = function()
        print("Кнопка нажата!")
    end
})

-- Добавление текстового поля (TextBox)
local textbox = window:AddTextBox({
    Name = "Моё текстовое поле",
    Description = "Описание поля",
    Default = "",
    Placeholder = "Введите текст...",
    Callback = function(value)
        print("Текст:", value)
    end
})

-- Добавление выбора цвета (ColorPicker)
local colorpicker = window:AddColorPicker({
    Name = "Выбор цвета",
    Description = "Описание",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(color)
        print("Цвет:", color)
    end
})

-- Изменение темы
CrystalUI:SetTheme("Light") -- Изменение темы для всех окон
```

## Создание собственных тем

```lua
-- Создание и применение собственной темы
CrystalUI:CreateTheme("MyTheme", {
    Background = Color3.fromRGB(20, 20, 30),
    Container = Color3.fromRGB(30, 30, 40),
    Primary = Color3.fromRGB(100, 150, 255),
    Secondary = Color3.fromRGB(40, 40, 50),
    Text = Color3.fromRGB(255, 255, 255),
    SubText = Color3.fromRGB(170, 170, 180),
    Border = Color3.fromRGB(50, 50, 60),
})

-- Применение созданной темы
CrystalUI:SetTheme("MyTheme")
```

## Дополнительная информация

- Все компоненты поддерживают изменение значений программно через метод `SetValue()`
- Для получения текущего значения компонента используйте метод `GetValue()`
- Для обновления опций выпадающего списка используйте метод `UpdateOptions()`
- Полную документацию и примеры использования смотрите в Example.lua 