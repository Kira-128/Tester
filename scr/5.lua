--[[
============================================================
  [5] GUI (Flow Hub) — 100% LYNX UI ARCHITECTURE
============================================================
]]

local S = _G.STHAIN
local C = S.Theme.Colors
local I = S.Theme.Icons
local F = S.Theme.Font
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local parentGui
local ok, hui = pcall(function() return gethui and gethui() end)
if ok and hui then parentGui = hui else parentGui = game:GetService("CoreGui") end

local oldGui = parentGui:FindFirstChild("FlowHub")
if oldGui then oldGui:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "FlowHub"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = parentGui

-- ============================================================
-- KONFIGURASI UKURAN (PERSIS LYNX)
-- ============================================================
local isMobile = UIS.TouchEnabled and not UIS.MouseEnabled
local windowSize, minWindowSize, maxWindowSize

if isMobile then
    windowSize    = UDim2.new(0, 420, 0, 280) -- Ukuran persis Lynx Mobile
    minWindowSize = Vector2.new(380, 250)
    maxWindowSize = Vector2.new(800, 600)
else
    windowSize    = UDim2.new(0, 560, 0, 360)
    minWindowSize = Vector2.new(440, 300)
    maxWindowSize = Vector2.new(1100, 760)
end

local sidebarWidth = 120
local headerHeight = 34
local topBarHeight = 28
local sectionHeaderHeight = 30

-- ============================================================
-- MAIN FRAME
-- ============================================================
local self_win = Instance.new("Frame")
self_win.Name = "MainFrame"
self_win.Size = windowSize
self_win.Position = UDim2.new(0.5, -windowSize.X.Offset/2, 0.5, -windowSize.Y.Offset/2)
self_win.BackgroundColor3 = C.bg1
self_win.BackgroundTransparency = 0.1
self_win.BorderSizePixel = 0
self_win.ClipsDescendants = false
self_win.ZIndex = 3
self_win.Visible = false
self_win.Parent = gui
Instance.new("UICorner", self_win).CornerRadius = UDim.new(0, 7)

local mStroke = Instance.new("UIStroke")
mStroke.Color = C.stroke
mStroke.Thickness = 1
mStroke.Transparency = 0.3
mStroke.Parent = self_win

-- ============================================================
-- HEADER
-- ============================================================
local scriptHeader = Instance.new("TextButton")
scriptHeader.Name = "Header"
scriptHeader.Size = UDim2.new(1, 0, 0, headerHeight)
scriptHeader.Position = UDim2.new(0, 0, 0, 0)
scriptHeader.BackgroundTransparency = 1
scriptHeader.BorderSizePixel = 0
scriptHeader.Text = ""
scriptHeader.AutoButtonColor = false
scriptHeader.ZIndex = 5
scriptHeader.Parent = self_win

-- Garis tipis di bawah header
local headerLine = Instance.new("Frame")
headerLine.Size = UDim2.new(1, -20, 0, 1)
headerLine.Position = UDim2.new(0, 10, 1, -1)
headerLine.BackgroundColor3 = C.stroke
headerLine.BackgroundTransparency = 0.62 -- Transparansi persis Lynx
headerLine.BorderSizePixel = 0
headerLine.ZIndex = 5
headerLine.Parent = scriptHeader

-- Teks Title
local lText = Instance.new("TextLabel")
lText.Size = UDim2.new(0, 80, 1, 0)
lText.Position = UDim2.new(0, 12, 0, 0)
lText.Text = "Flow"
lText.TextColor3 = C.accent
lText.TextSize = 15
lText.Font = F.bold
lText.TextXAlignment = Enum.TextXAlignment.Left
lText.BackgroundTransparency = 1
lText.ZIndex = 6
lText.Parent = scriptHeader

-- Ikon
local lIcon = Instance.new("ImageLabel")
lIcon.Size = UDim2.new(0, 16, 0, 16)
lIcon.Position = UDim2.new(0, 58, 0.5, -8)
lIcon.BackgroundTransparency = 1
lIcon.Image = I.icon
lIcon.ImageColor3 = C.accent
lIcon.ZIndex = 6
lIcon.Parent = scriptHeader

-- Garis pemisah vertikal
local separator = Instance.new("Frame")
separator.Size = UDim2.new(0, 1, 0, 16)
separator.Position = UDim2.new(0, 82, 0.5, -8)
separator.BackgroundColor3 = C.stroke
separator.BackgroundTransparency = 0.2
separator.BorderSizePixel = 0
separator.ZIndex = 6
separator.Parent = scriptHeader

-- Subtitle
local sub = Instance.new("TextLabel")
sub.Size = UDim2.new(0, 200, 1, 0)
sub.Position = UDim2.new(0, 96, 0, 0)
sub.Text = "Command An Army"
sub.TextColor3 = C.textDim
sub.TextSize = 11
sub.Font = F.bold
sub.TextXAlignment = Enum.TextXAlignment.Left
sub.BackgroundTransparency = 1
sub.ZIndex = 6
sub.Parent = scriptHeader

-- Tombol Minimize (Persis Lynx)
local btnMinHeader = Instance.new("TextButton")
btnMinHeader.Size = UDim2.new(0, 22, 0, 22)
btnMinHeader.Position = UDim2.new(1, -28, 0.5, -11)
btnMinHeader.BackgroundColor3 = C.bg2
btnMinHeader.BackgroundTransparency = 0.3
btnMinHeader.BorderSizePixel = 0
btnMinHeader.Text = ""
btnMinHeader.AutoButtonColor = false
btnMinHeader.ZIndex = 7
btnMinHeader.Parent = scriptHeader
Instance.new("UICorner", btnMinHeader).CornerRadius = UDim.new(0, 5)

local btnMinStroke = Instance.new("UIStroke")
btnMinStroke.Color = C.stroke
btnMinStroke.Thickness = 1
btnMinStroke.Transparency = 0.4
btnMinStroke.Parent = btnMinHeader

local minLine = Instance.new("Frame")
minLine.Size = UDim2.new(0, 10, 0, 2)
minLine.Position = UDim2.new(0.5, -5, 0.5, -1)
minLine.BackgroundColor3 = C.accent
minLine.BorderSizePixel = 0
minLine.ZIndex = 8
minLine.Parent = btnMinHeader
Instance.new("UICorner", minLine).CornerRadius = UDim.new(1, 0)

-- ============================================================
-- SIDEBAR
-- ============================================================
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, sidebarWidth, 1, -headerHeight)
sidebar.Position = UDim2.new(0, 0, 0, headerHeight)
sidebar.BackgroundTransparency = 1
sidebar.BorderSizePixel = 0
sidebar.ClipsDescendants = true
sidebar.ZIndex = 4
sidebar.Parent = self_win

local sidebarLine = Instance.new("Frame")
sidebarLine.Size = UDim2.new(0, 1, 1, 0)
sidebarLine.Position = UDim2.new(1, 0, 0, 0)
sidebarLine.BackgroundColor3 = C.stroke
sidebarLine.BackgroundTransparency = 0.42
sidebarLine.BorderSizePixel = 0
sidebarLine.ZIndex = 4
sidebarLine.Parent = sidebar

-- ============================================================
-- SEARCH BAR (Posisi Persis Lynx)
-- ============================================================
local searchW = sidebarWidth - 12
local searchH = 22
local searchContainer = Instance.new("Frame")
searchContainer.Name = "SearchBar"
searchContainer.Size = UDim2.new(0, searchW, 0, searchH)
searchContainer.Position = UDim2.new(0, 6, 0, 6)
searchContainer.BackgroundColor3 = C.bg2
searchContainer.BackgroundTransparency = 0.3
searchContainer.BorderSizePixel = 0
searchContainer.ZIndex = 7
searchContainer.Parent = sidebar
Instance.new("UICorner", searchContainer).CornerRadius = UDim.new(0, 5)

local searchStroke = Instance.new("UIStroke")
searchStroke.Color = C.stroke
searchStroke.Thickness = 1
searchStroke.Transparency = 0.4
searchStroke.Parent = searchContainer

local sIcon = Instance.new("ImageLabel")
sIcon.Size = UDim2.new(0, 14, 0, 14)
sIcon.Position = UDim2.new(0, 6, 0.5, -7)
sIcon.BackgroundTransparency = 1
sIcon.Image = I.search
sIcon.ImageColor3 = C.textDim2
sIcon.ZIndex = 8
sIcon.Parent = searchContainer

local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, -46, 1, 0)
searchBox.Position = UDim2.new(0, 26, 0, 0)
searchBox.BackgroundTransparency = 1
searchBox.Text = ""
searchBox.PlaceholderText = "Search feature..."
searchBox.Font = F.bold
searchBox.TextSize = 10
searchBox.TextColor3 = C.text
searchBox.PlaceholderColor3 = C.textDim2
searchBox.TextXAlignment = Enum.TextXAlignment.Left
searchBox.ClearTextOnFocus = false
searchBox.ZIndex = 9
searchBox.Parent = searchContainer

-- ============================================================
-- NAV CONTAINER (Menu Kiri)
-- ============================================================
local navContainer = Instance.new("ScrollingFrame")
navContainer.Name = "NavContainer"
navContainer.Size = UDim2.new(1, -10, 1, -39)
navContainer.Position = UDim2.new(0, 5, 0, 34)
navContainer.BackgroundTransparency = 1
navContainer.BorderSizePixel = 0
navContainer.ScrollBarThickness = 0
navContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
navContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
navContainer.ScrollingDirection = Enum.ScrollingDirection.Y
navContainer.ZIndex = 5
navContainer.Parent = sidebar

local navLayout = Instance.new("UIListLayout")
navLayout.Padding = UDim.new(0, 4)
navLayout.SortOrder = Enum.SortOrder.LayoutOrder
navLayout.Parent = navContainer

-- ============================================================
-- CONTENT BACKGROUND
-- ============================================================
local contentBg = Instance.new("Frame")
contentBg.Name = "ContentBg"
contentBg.Size = UDim2.new(1, -(sidebarWidth + 6), 1, -(headerHeight + 3))
contentBg.Position = UDim2.new(0, sidebarWidth + 3, 0, headerHeight + 1)
contentBg.BackgroundTransparency = 1
contentBg.BorderSizePixel = 0
contentBg.ClipsDescendants = true
contentBg.ZIndex = 4
contentBg.Parent = self_win

-- Top Bar Content (Judul Halaman)
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, -4, 0, topBarHeight)
topBar.Position = UDim2.new(0, 2, 0, 2)
topBar.BackgroundTransparency = 1
topBar.BorderSizePixel = 0
topBar.ZIndex = 5
topBar.Parent = contentBg

local pageTitleAccent = Instance.new("Frame")
pageTitleAccent.Size = UDim2.new(0, 3, 0, 16)
pageTitleAccent.Position = UDim2.new(0, 0, 0.5, -8)
pageTitleAccent.BackgroundColor3 = C.accent
pageTitleAccent.BorderSizePixel = 0
pageTitleAccent.ZIndex = 6
pageTitleAccent.Parent = topBar
Instance.new("UICorner", pageTitleAccent).CornerRadius = UDim.new(1, 0)

local pageTitle = Instance.new("TextLabel")
pageTitle.Text = "Combat"
pageTitle.Size = UDim2.new(1, -16, 1, 0)
pageTitle.Position = UDim2.new(0, 10, 0, 0)
pageTitle.Font = F.bold
pageTitle.TextSize = 12
pageTitle.BackgroundTransparency = 1
pageTitle.TextColor3 = C.text
pageTitle.TextXAlignment = Enum.TextXAlignment.Left
pageTitle.TextYAlignment = Enum.TextYAlignment.Center
pageTitle.ZIndex = 6
pageTitle.Parent = topBar

local topBarLine = Instance.new("Frame")
topBarLine.Size = UDim2.new(1, -10, 0, 1)
topBarLine.Position = UDim2.new(0, 5, 1, -1)
topBarLine.BackgroundColor3 = C.stroke
topBarLine.BackgroundTransparency = 0.7
topBarLine.BorderSizePixel = 0
topBarLine.ZIndex = 5
topBarLine.Parent = topBar

-- ============================================================
-- FLOAT BUTTON (Tombol Melayang)
-- ============================================================
local floatBtn = Instance.new("TextButton")
floatBtn.Size = UDim2.new(0, 40, 0, 40)
floatBtn.Position = UDim2.new(0, 20, 0, 100)
floatBtn.BackgroundColor3 = C.bg2
floatBtn.BorderSizePixel = 0
floatBtn.Text = ""
floatBtn.AutoButtonColor = false
floatBtn.Visible = false
floatBtn.ZIndex = 50
floatBtn.Parent = gui
Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(0, 6)

local floatIcon = Instance.new("ImageLabel")
floatIcon.Size = UDim2.new(1, 0, 1, 0)
floatIcon.BackgroundTransparency = 1
floatIcon.Image = I.icon
floatIcon.ImageColor3 = C.accent
floatIcon.ZIndex = 51
floatIcon.Parent = floatBtn

-- ============================================================
-- EXPORT (Agar 6.lua bisa mendeteksi)
-- ============================================================
S.GUI = {
    Screen = gui,
    MainFrame = self_win,
    Header = scriptHeader,
    Sidebar = sidebar,
    Content = contentBg,
    SearchBox = searchBox,
    ContentTitle = pageTitle,
    NavContainer = navContainer,
    FloatBtn = floatBtn,
    MinBtn = btnMinHeader
}
