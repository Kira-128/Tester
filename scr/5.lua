--[[
============================================================
  [5] GUI (Flow Hub v2.4) — OOP (SELF) 470x280
============================================================
]]

local S = _G.STHAIN
local C = S.Theme.Colors
local I = S.Theme.Icons
local F = S.Theme.Font
local UIS = game:GetService("UserInputService")

local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

local parentGui
local ok, hui = pcall(function() return gethui and gethui() end)
if ok and hui then parentGui = hui else parentGui = game:GetService("CoreGui") end

-- ============================================================
-- LIBRARY CLASS (OOP)
-- ============================================================
local Library = {}
Library.__index = Library

function Library.new()
    local self = setmetatable({}, Library)
    self.IsMobile = isMobile
    self._connections = {}
    return self
end

function Library:AddConnection(name, conn)
    if self._connections[name] then
        pcall(function() self._connections[name]:Disconnect() end)
    end
    self._connections[name] = conn
end

-- ============================================================
-- BUILD GUI (Fungsi Utama)
-- ============================================================
function Library:BuildGUI()
    -- Hapus GUI lama
    local oldGui = parentGui:FindFirstChild("FlowHub")
    if oldGui then oldGui:Destroy() end

    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "FlowHub"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.IgnoreGuiInset = true
    self.ScreenGui.Parent = parentGui

    -- ========================================================
    -- FLOAT BUTTON
    -- ========================================================
    self.FloatBtn = Instance.new("TextButton")
    self.FloatBtn.Name = "FloatBtn"
    self.FloatBtn.Size = UDim2.new(0, 48, 0, 48)
    self.FloatBtn.Position = UDim2.new(0, 30, 0.5, -24)
    self.FloatBtn.Text = ""
    self.FloatBtn.BackgroundTransparency = 1
    self.FloatBtn.BorderSizePixel = 0
    self.FloatBtn.AutoButtonColor = false
    self.FloatBtn.Active = true
    self.FloatBtn.ZIndex = 100
    self.FloatBtn.Parent = self.ScreenGui
    self.FloatBtn.Visible = false

    local fBg = Instance.new("Frame")
    fBg.Size = UDim2.new(1, 0, 1, 0)
    fBg.BackgroundColor3 = C.bg2
    fBg.BackgroundTransparency = 0.1
    fBg.BorderSizePixel = 0
    fBg.Parent = self.FloatBtn
    Instance.new("UICorner", fBg).CornerRadius = UDim.new(0, 12)

    local fIcon = Instance.new("ImageLabel")
    fIcon.Size = UDim2.new(1, 0, 1, 0)
    fIcon.BackgroundTransparency = 1
    fIcon.Image = I.logo
    fIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
    fIcon.ScaleType = Enum.ScaleType.Fit
    fIcon.Parent = fBg

    -- Logika Drag Float Button
    local iconDragging, iconDragStart, iconStartPos, iconDragMoved = false, nil, nil, false
    self:AddConnection("floatDragStart", self.FloatBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            iconDragging = true; iconDragMoved = false
            iconDragStart = input.Position; iconStartPos = self.FloatBtn.Position
        end
    end))
    self:AddConnection("floatDragChanged", UIS.InputChanged:Connect(function(input)
        if not iconDragging or not iconStartPos or not iconDragStart then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - iconDragStart
            if delta.Magnitude > 6 then iconDragMoved = true end
            self.FloatBtn.Position = UDim2.new(iconStartPos.X.Scale, iconStartPos.X.Offset + delta.X, iconStartPos.Y.Scale, iconStartPos.Y.Offset + delta.Y)
        end
    end))
    self:AddConnection("floatDragEnd", UIS.InputEnded:Connect(function(input)
        if not iconDragging then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            iconDragging = false
            if not iconDragMoved then
                self.FloatBtn.Visible = false
                self.MainFrame.Visible = true
            end
        end
    end))

    -- ========================================================
    -- MAIN FRAME
    -- ========================================================
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Size = self.IsMobile and UDim2.new(0, 470, 0, 280) or UDim2.new(0, 560, 0, 360)
    self.MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    self.MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    self.MainFrame.BackgroundColor3 = C.panel
    self.MainFrame.BackgroundTransparency = 0.1
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Active = true
    self.MainFrame.Visible = false
    self.MainFrame.ClipsDescendants = true
    self.MainFrame.Parent = self.ScreenGui
    Instance.new("UICorner", self.MainFrame).CornerRadius = UDim.new(0, 8)

    local mStroke = Instance.new("UIStroke")
    mStroke.Color = C.stroke
    mStroke.Thickness = 1
    mStroke.Transparency = 0.3
    mStroke.Parent = self.MainFrame

    -- ========================================================
    -- HEADER
    -- ========================================================
    local HEADER_H = 34
    self.Header = Instance.new("TextButton")
    self.Header.Name = "Header"
    self.Header.Size = UDim2.new(1, 0, 0, HEADER_H)
    self.Header.BackgroundTransparency = 1
    self.Header.Text = ""
    self.Header.AutoButtonColor = false
    self.Header.Active = true
    self.Header.ZIndex = 5
    self.Header.Parent = self.MainFrame

    local lText = Instance.new("TextLabel")
    lText.Size = UDim2.new(0, 60, 1, 0)
    lText.Position = UDim2.new(0, 12, 0, 0)
    lText.Text = "Flow"
    lText.TextColor3 = C.accent
    lText.TextSize = 14
    lText.Font = F.bold
    lText.TextXAlignment = Enum.TextXAlignment.Left
    lText.BackgroundTransparency = 1
    lText.ZIndex = 6
    lText.Parent = self.Header

    local lIcon = Instance.new("ImageLabel")
    lIcon.Size = UDim2.new(0, 16, 0, 16)
    lIcon.Position = UDim2.new(0, 48, 0.5, -8)
    lIcon.BackgroundTransparency = 1
    lIcon.Image = I.icon
    lIcon.ImageColor3 = C.accent
    lIcon.ScaleType = Enum.ScaleType.Fit
    lIcon.ZIndex = 6
    lIcon.Parent = self.Header

    local sep = Instance.new("Frame")
    sep.Size = UDim2.new(0, 1, 0, 16)
    sep.Position = UDim2.new(0, 74, 0.5, -8)
    sep.BackgroundColor3 = C.stroke
    sep.BorderSizePixel = 0
    sep.ZIndex = 6
    sep.Parent = self.Header

    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(0, 200, 1, 0)
    sub.Position = UDim2.new(0, 84, 0, 0)
    sub.Text = "Command An Army"
    sub.TextColor3 = C.textDim
    sub.TextSize = 10
    sub.Font = F.norm
    sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.BackgroundTransparency = 1
    sub.ZIndex = 6
    sub.Parent = self.Header

    self.MinBtn = Instance.new("TextButton")
    self.MinBtn.Size = UDim2.new(0, 22, 0, 22)
    self.MinBtn.Position = UDim2.new(1, -30, 0.5, -11)
    self.MinBtn.Text = "−"
    self.MinBtn.TextColor3 = C.accent
    self.MinBtn.TextSize = 14
    self.MinBtn.Font = F.bold
    self.MinBtn.BackgroundColor3 = C.bg3
    self.MinBtn.BackgroundTransparency = 0.5
    self.MinBtn.BorderSizePixel = 0
    self.MinBtn.ZIndex = 7
    self.MinBtn.Parent = self.Header
    Instance.new("UICorner", self.MinBtn).CornerRadius = UDim.new(0, 4)

    -- Garis Header
    self.HeaderLine = Instance.new("Frame")
    self.HeaderLine.Size = UDim2.new(1, -20, 0, 1)
    self.HeaderLine.Position = UDim2.new(0, 10, 0, HEADER_H - 1)
    self.HeaderLine.BackgroundColor3 = C.stroke
    self.HeaderLine.BackgroundTransparency = 0.62
    self.HeaderLine.BorderSizePixel = 0
    self.HeaderLine.ZIndex = 4
    self.HeaderLine.Parent = self.MainFrame

    -- ========================================================
    -- SEARCH & TITLE
    -- ========================================================
    local ROW_Y = HEADER_H + 8

    self.SearchFrame = Instance.new("Frame")
    self.SearchFrame.Size = UDim2.new(0.35, 0, 0, 26)
    self.SearchFrame.Position = UDim2.new(0, 10, 0, ROW_Y)
    self.SearchFrame.BackgroundColor3 = C.bg2
    self.SearchFrame.BackgroundTransparency = 0.1
    self.SearchFrame.BorderSizePixel = 0
    self.SearchFrame.ZIndex = 5
    self.SearchFrame.Parent = self.MainFrame
    Instance.new("UICorner", self.SearchFrame).CornerRadius = UDim.new(0, 5)

    local sIcon = Instance.new("ImageLabel")
    sIcon.Size = UDim2.new(0, 10, 0, 10)
    sIcon.Position = UDim2.new(0, 9, 0.5, -5)
    sIcon.BackgroundTransparency = 1
    sIcon.Image = I.search
    sIcon.ImageColor3 = C.textDim
    sIcon.ZIndex = 6
    sIcon.Parent = self.SearchFrame

    self.SearchBox = Instance.new("TextBox")
    self.SearchBox.Size = UDim2.new(1, -30, 1, 0)
    self.SearchBox.Position = UDim2.new(0, 26, 0, 0)
    self.SearchBox.Text = ""
    self.SearchBox.PlaceholderText = "Search feature.."
    self.SearchBox.PlaceholderColor3 = C.textDim2
    self.SearchBox.TextColor3 = C.text
    self.SearchBox.TextSize = 10
    self.SearchBox.Font = F.norm
    self.SearchBox.BackgroundTransparency = 1
    self.SearchBox.TextXAlignment = Enum.TextXAlignment.Left
    self.SearchBox.ClearTextOnFocus = false
    self.SearchBox.ZIndex = 6
    self.SearchBox.Parent = self.SearchFrame

    self.TitleDivider = Instance.new("Frame")
    self.TitleDivider.Size = UDim2.new(0, 2, 0, 18)
    self.TitleDivider.Position = UDim2.new(0.35, 10, 0, ROW_Y + 4)
    self.TitleDivider.BackgroundColor3 = C.accent
    self.TitleDivider.BorderSizePixel = 0
    self.TitleDivider.ZIndex = 5
    self.TitleDivider.Parent = self.MainFrame
    Instance.new("UICorner", self.TitleDivider).CornerRadius = UDim.new(1, 0)

    self.ContentTitle = Instance.new("TextLabel")
    self.ContentTitle.Size = UDim2.new(1, -200, 0, 26)
    self.ContentTitle.Position = UDim2.new(0.35, 20, 0, ROW_Y)
    self.ContentTitle.Text = "Combat"
    self.ContentTitle.TextColor3 = C.text
    self.ContentTitle.TextSize = 12
    self.ContentTitle.Font = F.bold
    self.ContentTitle.TextXAlignment = Enum.TextXAlignment.Left
    self.ContentTitle.BackgroundTransparency = 1
    self.ContentTitle.ZIndex = 5
    self.ContentTitle.Parent = self.MainFrame

    self.TitleLine = Instance.new("Frame")
    self.TitleLine.Size = UDim2.new(1, -200, 0, 1)
    self.TitleLine.Position = UDim2.new(0.35, 20, 0, ROW_Y + 28)
    self.TitleLine.BackgroundColor3 = C.stroke
    self.TitleLine.BackgroundTransparency = 0.3
    self.TitleLine.BorderSizePixel = 0
    self.TitleLine.ZIndex = 5
    self.TitleLine.Parent = self.MainFrame

    -- ========================================================
    -- SIDEBAR & CONTENT
    -- ========================================================
    local SIDEBAR_Y = ROW_Y + 38

    self.Sidebar = Instance.new("ScrollingFrame")
    self.Sidebar.Name = "Sidebar"
    self.Sidebar.Size = UDim2.new(0, 120, 1, -(SIDEBAR_Y + 10))
    self.Sidebar.Position = UDim2.new(0, 10, 0, SIDEBAR_Y)
    self.Sidebar.BackgroundTransparency = 1
    self.Sidebar.BorderSizePixel = 0
    self.Sidebar.ScrollBarThickness = 0
    self.Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
    self.Sidebar.ScrollingDirection = Enum.ScrollingDirection.Y
    self.Sidebar.ClipsDescendants = true
    self.Sidebar.ZIndex = 5
    self.Sidebar.Parent = self.MainFrame

    local sLayout = Instance.new("UIListLayout")
    sLayout.Padding = UDim.new(0, 4)
    sLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    sLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    sLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sLayout.Parent = self.Sidebar

    self.ContentPanel = Instance.new("Frame")
    self.ContentPanel.Name = "ContentPanel"
    self.ContentPanel.Size = UDim2.new(1, -140, 1, -(SIDEBAR_Y + 10))
    self.ContentPanel.Position = UDim2.new(0, 130, 0, SIDEBAR_Y)
    self.ContentPanel.BackgroundTransparency = 1
    self.ContentPanel.BorderSizePixel = 0
    self.ContentPanel.ClipsDescendants = true
    self.ContentPanel.ZIndex = 5
    self.ContentPanel.Parent = self.MainFrame

    self.ContentScroll = Instance.new("ScrollingFrame")
    self.ContentScroll.Name = "ContentScroll"
    self.ContentScroll.Size = UDim2.new(1, 0, 1, 0)
    self.ContentScroll.BackgroundTransparency = 1
    self.ContentScroll.BorderSizePixel = 0
    self.ContentScroll.ClipsDescendants = true
    self.ContentScroll.ScrollBarThickness = 3
    self.ContentScroll.ScrollBarImageColor3 = C.accent
    self.ContentScroll.ScrollBarImageTransparency = 0.4
    self.ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.ContentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    self.ContentScroll.ScrollingDirection = Enum.ScrollingDirection.Y
    self.ContentScroll.ZIndex = 5
    self.ContentScroll.Parent = self.ContentPanel

    -- ========================================================
    -- EXPORT KE S.GUI
    -- ========================================================
    S.GUI = {
        Screen = self.ScreenGui,
        FloatBtn = self.FloatBtn,
        MainFrame = self.MainFrame,
        Header = self.Header,
        Sidebar = self.Sidebar,
        Content = self.ContentPanel,
        ContentScroll = self.ContentScroll,
        ContentTitle = self.ContentTitle,
        TitleLine = self.TitleLine,
        HeaderLine = self.HeaderLine,
        TitleDivider = self.TitleDivider,
        SearchBox = self.SearchBox,
        MinBtn = self.MinBtn,
        CloseBtn = nil,
        IsMobile = self.IsMobile,
    }

    return self
end
