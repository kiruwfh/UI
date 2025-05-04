--[[
    CrystalUI для Roblox
    Современная, настраиваемая библиотека GUI
]]

local CrystalUI = {}
local Components = {}

-- Подключение компонентов
Components.Window = require(script.Components.Window)
Components.Toggle = require(script.Components.Toggle)
Components.Button = require(script.Components.Button)
Components.Slider = require(script.Components.Slider)
Components.Dropdown = require(script.Components.Dropdown)
Components.ColorPicker = require(script.Components.ColorPicker)
Components.TextBox = require(script.Components.TextBox)

-- Темы
CrystalUI.Themes = {
    Dark = {
        Background = Color3.fromRGB(30, 30, 30),
        Container = Color3.fromRGB(40, 40, 40),
        Primary = Color3.fromRGB(90, 120, 255),
        Secondary = Color3.fromRGB(60, 60, 60),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(180, 180, 180),
        Border = Color3.fromRGB(60, 60, 60),
    },
    Light = {
        Background = Color3.fromRGB(240, 240, 240),
        Container = Color3.fromRGB(255, 255, 255),
        Primary = Color3.fromRGB(90, 120, 255),
        Secondary = Color3.fromRGB(220, 220, 220),
        Text = Color3.fromRGB(30, 30, 30),
        SubText = Color3.fromRGB(80, 80, 80),
        Border = Color3.fromRGB(200, 200, 200),
    },
    Purple = {
        Background = Color3.fromRGB(30, 25, 40),
        Container = Color3.fromRGB(40, 35, 50),
        Primary = Color3.fromRGB(150, 100, 255),
        Secondary = Color3.fromRGB(60, 50, 70),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(180, 170, 190),
        Border = Color3.fromRGB(70, 60, 80),
    }
}

-- Текущая тема (по умолчанию)
CrystalUI.CurrentTheme = "Dark"

-- Создание нового окна
function CrystalUI:CreateWindow(options)
    options = options or {}
    options.Theme = options.Theme or self.CurrentTheme
    
    -- Применение выбранной темы
    if self.Themes[options.Theme] then
        self.CurrentTheme = options.Theme
    end
    
    -- Создание окна с текущей темой
    return Components.Window.new(options, self)
end

-- Изменение темы для всех окон
function CrystalUI:SetTheme(themeName)
    if self.Themes[themeName] then
        self.CurrentTheme = themeName
        -- Оповещение всех окон об изменении темы
        for _, window in pairs(Components.Window.Instances) do
            window:UpdateTheme(themeName)
        end
        return true
    end
    return false
end

-- Создание новой темы
function CrystalUI:CreateTheme(name, themeColors)
    if type(name) == "string" and type(themeColors) == "table" then
        self.Themes[name] = themeColors
        return true
    end
    return false
end

return CrystalUI 