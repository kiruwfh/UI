# CrystalUI для Roblox

Современная, настраиваемая библиотека GUI для Roblox с разнообразными компонентами и функциями.

## Возможности
- Переключатели (вкл/выкл)
- Мульти-выбор
- Одиночный выбор
- Текстовые поля
- Слайдеры
- Настройка темы
- Полностью настраиваемые стили

## Использование
```lua
local CrystalUI = require(game.ReplicatedStorage.CrystalUI)

-- Создание главного окна
local window = CrystalUI:CreateWindow({
    Title = "Настройки",
    Size = UDim2.new(0, 400, 0, 300),
    Position = UDim2.new(0.5, -200, 0.5, -150),
    Theme = "Dark"
})

-- Добавление компонентов
local toggle = window:AddToggle({
    Name = "Включить звуки",
    Default = true,
    Callback = function(value)
        print("Звуки: " .. (value and "включены" or "выключены"))
    end
})

local slider = window:AddSlider({
    Name = "Громкость",
    Min = 0,
    Max = 100,
    Default = 50,
    Callback = function(value)
        print("Громкость установлена: " .. value)
    end
})
```

## Установка
1. Скачайте файлы библиотеки
2. Поместите папку CrystalUI в ReplicatedStorage вашей игры
3. Используйте `require` для подключения библиотеки 