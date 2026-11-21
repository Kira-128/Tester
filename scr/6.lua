--[[
============================================================
  [6] LIBRARY (Flow Hub v2.4) — FIXED & STABLE
============================================================
]]

local S = _G.STHAIN
local C = S.Theme.Colors
local F = S.Theme.Font

local Lib = {}
local ITEM_H = 34
local HEADER_H = 30
local CARD_BG = C.bg3
local CARD_TRANS = 0.15

-- Services Fallback
local TS  = (S.Services and S.Services.TS)  or game:GetService("TweenService")
local UIS = (S.Services and S.Services.UIS) or game:GetService("UserInputService")
local Run = (S.Services and S.Services.Run) or game:GetService("RunService")

-- ============================================================
-- REGISTRY (Untuk Refresh Config)
-- ============================================================
local ToggleRegistry = {}
local DropdownRegistry = {}

function Lib.RefreshAll()
    for _, entry in pairs(ToggleRegistry) do
        local path = entry.path
        if path and path[1] and path[2] and S.Config then
            local cat = S.Config[path[1]]
            local currentVal = cat and cat[path[2]]
            if currentVal ~= nil and entry.setState then
                pcall(entry.setState, currentVal, true)
            end
        end
    end
end

function Lib.RefreshAllDropdowns()
    for _, entry in ipairs(DropdownRegistry) do
        if entry.setValue then
            pcall(entry.setValue, "None")
        end
    end
end

-- ============================================================
-- HELPER: Recalculate section height (Anti-Loop)
-- ============================================================
local recalcGuard = {}

local function recalcSection(card, content)
    if not card or not card.Parent then return end
    if recalcGuard[card] then return end
    recalcGuard[card] = true

    if not content.Visible then
        card.Size = UDim2.new(1, 0, 0, HEADER_H)
        recalcGuard[card] = nil
        return
    end

    local layout = content:FindFirstChildOfClass("UIListLayout")
    local totalH = layout and layout.AbsoluteContentSize.Y or 0
    card.Size = UDim2.new(1, 0, 0, HEADER_H + totalH + 8)

    task.defer(function()
        recalcGuard[card] = nil
    end)
end

local function hookAutoRecalc(card, content)
    local layout = content:FindFirstChildOfClass("UIListLayout")
    if layout then
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            recalcSection(card, content)
        end)
    end
    content.ChildAdded:Connect(function()
        task.defer(function() recalcSection(card, content) end)
    end)
    content.ChildRemoved:Connect(function()
        task.defer(function() recalcSection(card, content) end)
    end)
end

-- ============================================================
-- SECTION
-- ============================================================
function Lib.makeSection(parent, title, defaultOpen)
    local card = Instance.new("Frame")
    card.Name = "Section_" .. title
    card.Size = UDim2.new(1, 0, 0, HEADER_H)
    card.BackgroundColor3 = CARD_BG
    card.BackgroundTransparency = CARD_TRANS
    card.BorderSizePixel = 0
    card.ClipsDescendants = true
    card.Parent = parent
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)

    local header = Instance.new("TextButton")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, HEADER_H)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.Text = ""
    header.BackgroundTransparency = 1
    header.BorderSizePixel = 0
    header.AutoButtonColor = false
    header.ZIndex = 2
    header.Parent = card

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -50, 1, 0)
    titleLbl.Position = UDim2.new(0, 12, 0, 0)
    titleLbl.Text = title
    titleLbl.TextColor3 = C.text
    titleLbl.TextSize = 11
    titleLbl.Font = F.bold
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.BackgroundTransparency = 1
    titleLbl.ZIndex = 3
    titleLbl.Parent = header

    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 16, 1, 0)
    arrow.Position = UDim2.new(1, -26, 0, 0)
    arrow.AnchorPoint = Vector2.new(1, 0)
    arrow.Text = defaultOpen and "▼" or "▶"
    arrow.TextColor3 = C.accent
    arrow.TextSize = 10
    arrow.Font = F.bold
    arrow.BackgroundTransparency = 1
    arrow.ZIndex = 3
    arrow.Parent = header

    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, 0, 0, 0)
    content.Position = UDim2.new(0, 0, 0, HEADER_H)
    content.BackgroundTransparency = 1
    content.ClipsDescendants = false
    content.Visible = defaultOpen
    content.ZIndex = 2
    content.Parent = card

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 1)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Parent = content

    local cPad = Instance.new("UIPadding")
    cPad.PaddingTop = UDim.new(0, 4)
    cPad.PaddingBottom = UDim.new(0, 4)
    cPad.Parent = content

    local isOpen = defaultOpen
    hookAutoRecalc(card, content)

    header.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        arrow.Text = isOpen and "▼" or "▶"
        content.Visible = isOpen
        task.defer(function() recalcSection(card, content) end)
    end)

    task.defer(function()
        task.wait(0.15)
        if defaultOpen then recalcSection(card, content) end
    end)

    return content, function() recalcSection(card, content) end, card
end

-- ============================================================
-- TOGGLE
-- ============================================================
function Lib.makeToggle(parent, name, default, callback, configPath)
    local f = Instance.new("Frame")
    f.Name = "Toggle_" .. name
    f.Size = UDim2.new(1, 0, 0, ITEM_H)
    f.BackgroundTransparency = 1
    f.BorderSizePixel = 0
    f.Parent = parent

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.7, -12, 1, 0)
    l.Position = UDim2.new(0, 12, 0, 0)
    l.Text = name
    l.TextColor3 = C.text
    l.TextSize = 11
    l.Font = F.norm
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.BackgroundTransparency = 1
    l.Parent = f

    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 30, 0, 18)
    b.AnchorPoint = Vector2.new(1, 0.5)
    b.Position = UDim2.new(1, -12, 0.5, 0)
    b.Text = ""
    b.BackgroundColor3 = default and C.accent or C.bg4
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Parent = f
    Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = default and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
    knob.BackgroundColor3 = C.text
    knob.BorderSizePixel = 0
    knob.Parent = b
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local state = default

    local function setState(newState, skipCallback)
        if state == newState then return end
        state = newState
        TS:Create(b, TweenInfo.new(0.2), {
            BackgroundColor3 = state and C.accent or C.bg4
        }):Play()
        TS:Create(knob, TweenInfo.new(0.2), {
            Position = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
        }):Play()
        if not skipCallback then pcall(callback, state) end
    end

    b.MouseButton1Click:Connect(function() setState(not state, false) end)

    if configPath then
        local entry = { path = configPath, setState = setState }
        table.insert(ToggleRegistry, entry)

        f.Destroying:Connect(function()
            for i = #ToggleRegistry, 1, -1 do
                if ToggleRegistry[i] == entry then
                    table.remove(ToggleRegistry, i)
                end
            end
        end)
    end

    return setState
end

-- ============================================================
-- INPUT (Number)
-- ============================================================
function Lib.makeInput(parent, name, default, callback)
    local f = Instance.new("Frame")
    f.Name = "Input_" .. name
    f.Size = UDim2.new(1, 0, 0, ITEM_H)
    f.BackgroundTransparency = 1
    f.BorderSizePixel = 0
    f.Parent = parent

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.55, -12, 1, 0)
    l.Position = UDim2.new(0, 12, 0, 0)
    l.Text = name
    l.TextColor3 = C.text
    l.TextSize = 11
    l.Font = F.norm
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.BackgroundTransparency = 1
    l.Parent = f

    local b = Instance.new("TextBox")
    b.AnchorPoint = Vector2.new(1, 0.5)
    b.Position = UDim2.new(1, -12, 0.5, 0)
    b.Size = UDim2.new(0.20, 0, 0, 22)
    b.Text = tostring(default)
    b.TextColor3 = C.text
    b.TextSize = 11
    b.Font = F.norm
    b.BackgroundColor3 = C.bg4
    b.BorderSizePixel = 0
    b.ClearTextOnFocus = false
    b.Parent = f
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)

    b.FocusLost:Connect(function()
        local v = tonumber(b.Text)
        if v then
            pcall(callback, v)
        else
            b.Text = tostring(default)
        end
    end)

    return b
end

-- ============================================================
-- TEXT INPUT
-- ============================================================
function Lib.makeTextInput(parent, name, default, placeholder, callback)
    local f = Instance.new("Frame")
    f.Name = "TextInput_" .. name
    f.Size = UDim2.new(1, 0, 0, ITEM_H)
    f.BackgroundTransparency = 1
    f.BorderSizePixel = 0
    f.Parent = parent

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.5, -12, 1, 0)
    l.Position = UDim2.new(0, 12, 0, 0)
    l.Text = name
    l.TextColor3 = C.text
    l.TextSize = 11
    l.Font = F.norm
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.BackgroundTransparency = 1
    l.Parent = f

    local b = Instance.new("TextBox")
    b.Name = "TextBox"
    b.AnchorPoint = Vector2.new(1, 0.5)
    b.Position = UDim2.new(1, -12, 0.5, 0)
    b.Size = UDim2.new(0.48, 0, 0, 22)
    b.Text = tostring(default or "")
    b.PlaceholderText = placeholder or ""
    b.PlaceholderColor3 = C.textDim2
    b.TextColor3 = C.text
    b.TextSize = 11
    b.Font = F.norm
    b.BackgroundColor3 = C.bg4
    b.BorderSizePixel = 0
    b.ClearTextOnFocus = false
    b.Parent = f
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)

    b.FocusLost:Connect(function() pcall(callback, b.Text) end)
    return b
end

-- ============================================================
-- BUTTON
-- ============================================================
function Lib.makeButton(parent, name, callback, noHover)
    local wrapper = Instance.new("Frame")
    wrapper.Name = "BtnWrapper_" .. name
    wrapper.Size = UDim2.new(1, 0, 0, ITEM_H)
    wrapper.BackgroundTransparency = 1
    wrapper.Parent = parent

    local b = Instance.new("TextButton")
    b.Name = "Button_" .. name
    b.Size = UDim2.new(1, -12, 0, ITEM_H - 8)
    b.Position = UDim2.new(0, 6, 0.5, -(ITEM_H - 8) / 2)
    b.Text = name
    b.TextColor3 = C.text
    b.TextSize = 11
    b.Font = F.norm
    b.BackgroundColor3 = C.bg4
    b.BackgroundTransparency = 0.3
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Parent = wrapper
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)

    local flash = Instance.new("Frame")
    flash.Size = UDim2.new(1, 0, 1, 0)
    flash.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    flash.BackgroundTransparency = 1
    flash.BorderSizePixel = 0
    flash.ZIndex = 1
    flash.Parent = b
    Instance.new("UICorner", flash).CornerRadius = UDim.new(0, 5)

    b.MouseButton1Down:Connect(function()
        TS:Create(flash, TweenInfo.new(0.1), { BackgroundTransparency = 0.8 }):Play()
    end)
    b.MouseButton1Up:Connect(function()
        TS:Create(flash, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
    end)
    b.MouseLeave:Connect(function()
        TS:Create(flash, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()
    end)

    b.MouseButton1Click:Connect(function() pcall(callback) end)

    if not noHover then
        b.MouseEnter:Connect(function()
            TS:Create(b, TweenInfo.new(0.15), {
                BackgroundColor3 = C.bg3,
                BackgroundTransparency = 0.1
            }):Play()
        end)
        b.MouseLeave:Connect(function()
            TS:Create(b, TweenInfo.new(0.15), {
                BackgroundColor3 = C.bg4,
                BackgroundTransparency = 0.3
            }):Play()
        end)
    end

    return b
end

-- ============================================================
-- DROPDOWN (PANEL SLIDE-IN 160PX)
-- ============================================================
local PANEL_W = 160
local PANEL_PAD = 8
local TWEEN_IN  = TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local TWEEN_OUT = TweenInfo.new(0.20, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

local SlidePanel = {
    overlay = nil, panel = nil, folder = nil, pageLayout = nil,
    active = nil, count = 0, activeTween = nil, initialized = false,
}

local function slideClosedPos() 
    return UDim2.new(1, PANEL_W + 4, 0, 0)
end
local function slideOpenPos() 
    return UDim2.new(1, -PANEL_PAD, 0, 0)
end

local function initSlidePanel()
    if SlidePanel.initialized or not S.GUI or not S.GUI.MainFrame then return end
    SlidePanel.initialized = true

    local mainFrame = S.GUI.MainFrame

    local overlay = Instance.new("TextButton")
    overlay.Name = "SlideOverlay"
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.new(0, 0, 0)
    overlay.BackgroundTransparency = 1
    overlay.BorderSizePixel = 0
    overlay.Text = ""
    overlay.AutoButtonColor = false
    overlay.Visible = false
    overlay.ZIndex = 140
    overlay.Parent = mainFrame
    overlay.Activated:Connect(function()
        Lib.HideSlidePanel()
    end)
    SlidePanel.overlay = overlay

    local panel = Instance.new("Frame")
    panel.Name = "SlidePanel"
    panel.AnchorPoint = Vector2.new(1, 0)
    panel.Size = UDim2.new(0, PANEL_W, 1, 0) 
    panel.Position = slideClosedPos()
    panel.BackgroundColor3 = C.bg2
    panel.BackgroundTransparency = 0.05
    panel.BorderSizePixel = 0
    panel.ClipsDescendants = true
    panel.ZIndex = 152
    panel.Parent = mainFrame
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 8)
    
    local pStroke = Instance.new("UIStroke")
    pStroke.Color = C.stroke
    pStroke.Thickness = 1
    pStroke.Transparency = 0.5
    pStroke.Parent = panel
    SlidePanel.panel = panel

    local folder = Instance.new("Frame")
    folder.Name = "SlideFolder"
    folder.Size = UDim2.new(1, 0, 1, 0)
    folder.BackgroundTransparency = 1
    folder.ClipsDescendants = true
    folder.ZIndex = 153
    folder.Parent = panel
    SlidePanel.folder = folder

    local pageLayout = Instance.new("UIPageLayout")
    pageLayout.EasingDirection = Enum.EasingDirection.InOut
    pageLayout.EasingStyle = Enum.EasingStyle.Quad
    pageLayout.TweenTime = 0.01
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pageLayout.FillDirection = Enum.FillDirection.Vertical
    pageLayout.Parent = folder
    SlidePanel.pageLayout = pageLayout
end

function Lib.ShowSlidePanel(container, component)
    initSlidePanel()
    if not SlidePanel.initialized then return end

    if SlidePanel.activeTween then
        pcall(function() SlidePanel.activeTween:Cancel() end)
        SlidePanel.activeTween = nil
    end

    if SlidePanel.active and SlidePanel.active ~= component then
        if SlidePanel.active._arrow then
            TS:Create(SlidePanel.active._arrow, TweenInfo.new(0.15), {Rotation = 0}):Play()
        end
    end
    SlidePanel.active = component

    SlidePanel.pageLayout:JumpTo(container)
    SlidePanel.panel.Position = slideClosedPos()
    SlidePanel.overlay.Visible = true

    local tw = TS:Create(SlidePanel.panel, TWEEN_IN, {
        Position = slideOpenPos()
    })
    SlidePanel.activeTween = tw
    tw:Play()
end

function Lib.HideSlidePanel()
    if not SlidePanel.overlay or not SlidePanel.overlay.Visible then return end

    if SlidePanel.active and SlidePanel.active._arrow then
        TS:Create(SlidePanel.active._arrow, TweenInfo.new(0.15), {Rotation = 0}):Play()
    end
    SlidePanel.active = nil
    SlidePanel.overlay.Visible = false

    if SlidePanel.activeTween then
        pcall(function() SlidePanel.activeTween:Cancel() end)
        SlidePanel.activeTween = nil
    end

    local tw = TS:Create(SlidePanel.panel, TWEEN_OUT, {
        Position = slideClosedPos()
    })
    SlidePanel.activeTween = tw
    tw:Play()
end

function Lib.makeDropdown(parent, name, initialOptions, callback)
    initSlidePanel()
    if not SlidePanel.initialized then return end

    local layoutOrder = SlidePanel.count
    SlidePanel.count += 1

    local f = Instance.new("Frame")
    f.Name = "Dropdown_" .. name
    f.Size = UDim2.new(1, 0, 0, ITEM_H)
    f.BackgroundTransparency = 1
    f.BorderSizePixel = 0
    f.ClipsDescendants = false
    f.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5, -12, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.Text = name
    lbl.TextColor3 = C.text
    lbl.TextSize = 11
    lbl.Font = F.bold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.BackgroundTransparency = 1
    lbl.Parent = f

    local dropdownBtn = Instance.new("TextButton")
    dropdownBtn.Name = "Button_" .. name
    dropdownBtn.AnchorPoint = Vector2.new(1, 0.5)
    dropdownBtn.Position = UDim2.new(1, -12, 0.5, 0)
    dropdownBtn.Size = UDim2.new(0.48, 0, 0, 22)
    dropdownBtn.Text = ""
    dropdownBtn.BackgroundColor3 = C.bg2
    dropdownBtn.BackgroundTransparency = 0.3
    dropdownBtn.BorderSizePixel = 0
    dropdownBtn.AutoButtonColor = false
    dropdownBtn.ZIndex = 8
    dropdownBtn.Parent = f
    Instance.new("UICorner", dropdownBtn).CornerRadius = UDim.new(0, 4)

    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = C.stroke
    btnStroke.Thickness = 1
    btnStroke.Transparency = 0.5
    btnStroke.Parent = dropdownBtn

    local optionLabel = Instance.new("TextLabel")
    optionLabel.Size = UDim2.new(1, -24, 1, 0)
    optionLabel.Position = UDim2.new(0, 8, 0, 0)
    optionLabel.Text = "Select..."
    optionLabel.TextColor3 = C.textDim
    optionLabel.TextSize = 10
    optionLabel.Font = F.bold
    optionLabel.TextXAlignment = Enum.TextXAlignment.Left
    optionLabel.TextTruncate = Enum.TextTruncate.AtEnd
    optionLabel.BackgroundTransparency = 1
    optionLabel.ZIndex = 9
    optionLabel.Parent = dropdownBtn

    local arrow = Instance.new("ImageLabel")
    arrow.Size = UDim2.new(0, 11, 0, 11)
    arrow.Position = UDim2.new(1, -6, 0.5, 0)
    arrow.AnchorPoint = Vector2.new(1, 0.5)
    arrow.BackgroundTransparency = 1
    arrow.Image = "rbxassetid://6031091004"
    arrow.ImageColor3 = C.accent
    arrow.ZIndex = 9
    arrow.Parent = dropdownBtn

    dropdownBtn.MouseEnter:Connect(function()
        TS:Create(dropdownBtn, TweenInfo.new(0.15), {
            BackgroundColor3 = C.bg3,
            BackgroundTransparency = 0.1
        }):Play()
    end)
    dropdownBtn.MouseLeave:Connect(function()
        TS:Create(dropdownBtn, TweenInfo.new(0.15), {
            BackgroundColor3 = C.bg2,
            BackgroundTransparency = 0.3
        }):Play()
    end)

    local container = Instance.new("Frame")
    container.Name = "Page_" .. name
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.LayoutOrder = layoutOrder
    container.Parent = SlidePanel.folder

    local showSearch = #initialOptions > 6

    local searchBox = Instance.new("TextBox")
    searchBox.Name = "SearchBox"
    searchBox.Size = UDim2.new(1, -8, 0, 24)
    searchBox.Position = UDim2.new(0, 4, 0, 4)
    searchBox.Text = ""
    searchBox.PlaceholderText = "Search..."
    searchBox.PlaceholderColor3 = C.textDim2
    searchBox.TextColor3 = C.text
    searchBox.TextSize = 10
    searchBox.Font = F.norm
    searchBox.BackgroundColor3 = C.bg3
    searchBox.BackgroundTransparency = 0.3
    searchBox.BorderSizePixel = 0
    searchBox.TextXAlignment = Enum.TextXAlignment.Left
    searchBox.ClearTextOnFocus = false
    searchBox.Visible = showSearch
    searchBox.ZIndex = 154
    searchBox.Parent = container
    Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 4)
    local searchPad = Instance.new("UIPadding")
    searchPad.PaddingLeft = UDim.new(0, 8)
    searchPad.Parent = searchBox

    local scrollSelect = Instance.new("ScrollingFrame")
    scrollSelect.Name = "OptionsList"
    scrollSelect.Size = showSearch and UDim2.new(1, -8, 1, -36) or UDim2.new(1, -8, 1, -8)
    scrollSelect.Position = showSearch and UDim2.new(0, 4, 0, 32) or UDim2.new(0, 4, 0, 4)
    scrollSelect.BackgroundTransparency = 1
    scrollSelect.BorderSizePixel = 0
    scrollSelect.ScrollBarThickness = 3
    scrollSelect.ScrollBarImageColor3 = C.accent
    scrollSelect.ScrollBarImageTransparency = 0.4
    scrollSelect.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollSelect.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollSelect.ScrollingDirection = Enum.ScrollingDirection.Y
    scrollSelect.ElasticBehavior = Enum.ElasticBehavior.Never
    scrollSelect.ZIndex = 154
    scrollSelect.Parent = container

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 3)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = scrollSelect

    local allOptions = {}
    local function normalizeOptions(opts)
        allOptions = {}
        for _, opt in ipairs(opts or {}) do
            local label, value
            if type(opt) == "table" and opt.Label ~= nil and opt.Value ~= nil then
                label, value = tostring(opt.Label), opt.Value
            else
                label, value = tostring(opt), opt
            end
            table.insert(allOptions, {
                label = label,
                value = value,
                lower = string.lower(label)
            })
        end
    end
    normalizeOptions(initialOptions)

    local currentValue = initialOptions[1]
    local rows = {}
    local destroyed = false

    local function setLabel()
        if currentValue == nil then
            optionLabel.Text = "Select..."
            optionLabel.TextColor3 = C.textDim
            return
        end
        for _, opt in ipairs(allOptions) do
            if opt.value == currentValue then
                optionLabel.Text = opt.label
                optionLabel.TextColor3 = C.text
                return
            end
        end
        optionLabel.Text = tostring(currentValue)
        optionLabel.TextColor3 = C.text
    end
    setLabel()

    local function rebuild(filter)
        if destroyed then return end
        filter = string.lower(filter or "")

        for _, r in ipairs(rows) do
            if r.button and r.button.Parent then r.button:Destroy() end
        end
        rows = {}

        local order = 0
        for _, opt in ipairs(allOptions) do
            if filter == "" or string.find(opt.lower, filter, 1, true) then
                order += 1
                local isSelected = (opt.value == currentValue)

                local row = Instance.new("TextButton")
                row.Size = UDim2.new(1, -6, 0, 26)
                row.BackgroundColor3 = isSelected and C.bg3 or C.bg2
                row.BackgroundTransparency = isSelected and 0.2 or 0.5
                row.BorderSizePixel = 0
                row.Text = ""
                row.AutoButtonColor = false
                row.LayoutOrder = order
                row.ZIndex = 155
                row.Parent = scrollSelect
                Instance.new("UICorner", row).CornerRadius = UDim.new(0, 4)

                if isSelected then
                    local accentBar = Instance.new("Frame")
                    accentBar.Size = UDim2.new(0, 3, 0, 16)
                    accentBar.Position = UDim2.new(0, 2, 0.5, -8)
                    accentBar.BackgroundColor3 = C.accent
                    accentBar.BorderSizePixel = 0
                    accentBar.ZIndex = 156
                    accentBar.Parent = row
                    Instance.new("UICorner", accentBar).CornerRadius = UDim.new(1, 0)
                end

                local optLbl = Instance.new("TextLabel")
                optLbl.Size = UDim2.new(1, -16, 1, 0)
                optLbl.Position = UDim2.new(0, isSelected and 10 or 8, 0, 0)
                optLbl.Text = opt.label
                optLbl.TextColor3 = isSelected and C.accent or C.textDim
                optLbl.TextSize = 10
                optLbl.Font = isSelected and F.bold or F.norm
                optLbl.TextXAlignment = Enum.TextXAlignment.Left
                optLbl.TextTruncate = Enum.TextTruncate.AtEnd
                optLbl.BackgroundTransparency = 1
                optLbl.ZIndex = 156
                optLbl.Parent = row

                row.MouseEnter:Connect(function()
                    if not isSelected then
                        TS:Create(row, TweenInfo.new(0.12), {
                            BackgroundColor3 = C.bg3,
                            BackgroundTransparency = 0.3
                        }):Play()
                    end
                end)
                row.MouseLeave:Connect(function()
                    if not isSelected then
                        TS:Create(row, TweenInfo.new(0.12), {
                            BackgroundColor3 = C.bg2,
                            BackgroundTransparency = 0.5
                        }):Play()
                    end
                end)

                row.MouseButton1Click:Connect(function()
                    currentValue = opt.value
                    setLabel()
                    rebuild(searchBox.Text)
                    Lib.HideSlidePanel()
                    pcall(callback, opt.value, opt.label)
                end)

                table.insert(rows, { button = row, value = opt.value })
            end
        end
    end

    rebuild("")

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        rebuild(searchBox.Text)
    end)

    local component = {
        _arrow = arrow,
        frame = f,
        UpdateOptions = function(opts)
            normalizeOptions(opts)
            local stillValid = false
            for _, opt in ipairs(allOptions) do
                if opt.value == currentValue then stillValid = true break end
            end
            if not stillValid and #allOptions > 0 then
                currentValue = allOptions[1].value
                setLabel()
                pcall(callback, currentValue)
            end
            if SlidePanel.active == component then
                rebuild(searchBox.Text)
            end
        end,
        SetValue = function(val)
            currentValue = val
            setLabel()
            if SlidePanel.active == component then
                rebuild(searchBox.Text)
            end
        end,
        GetValue = function() return currentValue end,
        ClosePopup = function()
            if SlidePanel.active == component then
                Lib.HideSlidePanel()
            end
        end,
    }

    dropdownBtn.MouseButton1Click:Connect(function()
        if destroyed then return end
        if SlidePanel.active == component then
            Lib.HideSlidePanel()
        else
            searchBox.Text = ""
            rebuild("")
            Lib.ShowSlidePanel(container, component)
            TS:Create(arrow, TweenInfo.new(0.15), { Rotation = 180 }):Play()
        end
    end)

    local regEntry = {
        setValue = component.SetValue,
        getValue = component.GetValue,
    }
    table.insert(DropdownRegistry, regEntry)

    f.Destroying:Connect(function()
        destroyed = true
        if SlidePanel.active == component then
            Lib.HideSlidePanel()
        end
        if container and container.Parent then
            container:Destroy()
        end
        for i = #DropdownRegistry, 1, -1 do
            if DropdownRegistry[i] == regEntry then
                table.remove(DropdownRegistry, i)
            end
        end
    end)

    return component
end

-- ============================================================
-- RESIZE HANDLE
-- ============================================================
function Lib.attachResizeHandle(mainFrame)
    if not mainFrame or not mainFrame.Parent then return end

    local UIS = S.Services.UIS or game:GetService("UserInputService")
    local TS = S.Services.TS or game:GetService("TweenService")
    local RunService = S.Services.Run or game:GetService("RunService")

    local isMobile = UIS.TouchEnabled and not UIS.MouseEnabled
    local minW, minH, maxW, maxH

    if isMobile then
        minW, minH = 380, 250
        maxW, maxH = 800, 600
    else
        minW, minH = 440, 300
        maxW, maxH = 1100, 760
    end

    local oldHandle = mainFrame:FindFirstChild("ResizeHandle")
    if oldHandle then oldHandle:Destroy() end
    local oldLayer = mainFrame.Parent and mainFrame.Parent:FindFirstChild("ResizeHandleLayer")
    if oldLayer then oldLayer:Destroy() end

    local handleLayer = Instance.new("Frame")
    handleLayer.Name = "ResizeHandleLayer"
    handleLayer.Size = UDim2.new(1, 0, 1, 0)
    handleLayer.BackgroundTransparency = 1
    handleLayer.BorderSizePixel = 0
    handleLayer.ClipsDescendants = false
    handleLayer.ZIndex = 9998
    handleLayer.Active = false
    handleLayer.Parent = mainFrame.Parent

    local resizeHandle = Instance.new("TextButton")
    resizeHandle.Name = "ResizeHandle"
    resizeHandle.Size = UDim2.new(0, 44, 0, 44)
    resizeHandle.AnchorPoint = Vector2.new(1, 1)
    resizeHandle.Position = UDim2.new(0, 0, 0, 0)
    resizeHandle.BackgroundTransparency = 1
    resizeHandle.Text = ""
    resizeHandle.AutoButtonColor = false
    resizeHandle.ZIndex = 9999
    resizeHandle.Visible = true
    resizeHandle.Parent = handleLayer

    local arcContainer = Instance.new("Frame")
    arcContainer.Size = UDim2.new(0, 24, 0, 24)
    arcContainer.AnchorPoint = Vector2.new(1, 1)
    arcContainer.Position = UDim2.new(1, 0, 1, 0)
    arcContainer.BackgroundTransparency = 1
    arcContainer.ClipsDescendants = true
    arcContainer.ZIndex = 10000
    arcContainer.Parent = resizeHandle

    local curvedRing = Instance.new("Frame")
    curvedRing.Size = UDim2.new(0, 34, 0, 34)
    curvedRing.AnchorPoint = Vector2.new(0, 0)
    curvedRing.Position = UDim2.new(0, -17, 0, -17)
    curvedRing.BackgroundTransparency = 1
    curvedRing.ZIndex = 10000
    curvedRing.Parent = arcContainer

    local ringStroke = Instance.new("UIStroke")
    ringStroke.Color = Color3.fromRGB(220, 220, 220)
    ringStroke.Thickness = 2.8
    ringStroke.Transparency = 0.45
    ringStroke.Parent = curvedRing

    local ringCorner = Instance.new("UICorner")
    ringCorner.CornerRadius = UDim.new(1, 0)
    ringCorner.Parent = curvedRing

    local GAP = 14
    local function updateHandlePosition()
        local mfPos = mainFrame.AbsolutePosition
        local mfSize = mainFrame.AbsoluteSize
        local layerPos = handleLayer.AbsolutePosition
        local localX = (mfPos.X + mfSize.X) - layerPos.X + GAP
        local localY = (mfPos.Y + mfSize.Y) - layerPos.Y + GAP
        resizeHandle.Position = UDim2.new(0, localX, 0, localY)
    end

    local updateConn = RunService.RenderStepped:Connect(updateHandlePosition)
    updateHandlePosition()

    local isShowing = true
    local hideTimer = nil
    local IDLE_TIME = 5
    local resizing = false
    local destroyed = false

    local function applyVisualState(show)
        isShowing = show
        if show then
            resizeHandle.Visible = true
            TS:Create(ringStroke, TweenInfo.new(0.2), { Transparency = 0.45 }):Play()
        else
            TS:Create(ringStroke, TweenInfo.new(0.3), { Transparency = 0.85 }):Play()
        end
    end

    local function showHandle()
        if not mainFrame.Visible then return end
        if not isShowing then applyVisualState(true) end
        if hideTimer then pcall(task.cancel, hideTimer) end
        hideTimer = task.delay(IDLE_TIME, function()
            if not resizing and isShowing then applyVisualState(false) end
        end)
    end

    local activeInput = nil
    local resizeStart = nil
    local startSize = nil

    resizeHandle.InputBegan:Connect(function(input)
        if destroyed or not mainFrame.Visible then return end
        local it = input.UserInputType
        if it == Enum.UserInputType.MouseButton1 or it == Enum.UserInputType.Touch then
            resizing = true
            activeInput = input
            resizeStart = input.Position
            startSize = mainFrame.AbsoluteSize
            showHandle()
        end
    end)

    local inputChangedConn = UIS.InputChanged:Connect(function(input)
        if not resizing or not activeInput then return end
        local isMouse = activeInput.UserInputType == Enum.UserInputType.MouseButton1
            and input.UserInputType == Enum.UserInputType.MouseMovement
        local isTouch = activeInput.UserInputType == Enum.UserInputType.Touch and input == activeInput
        if not isMouse and not isTouch then return end

        local delta = input.Position - resizeStart
        local newW = math.clamp(startSize.X + delta.X, minW, maxW)
        local newH = math.clamp(startSize.Y + delta.Y, minH, maxH)

        mainFrame.Size = UDim2.new(0, newW, 0, newH)
        updateHandlePosition()
        showHandle()
    end)

    local inputEndedConn = UIS.InputEnded:Connect(function(input)
        if not resizing or not activeInput then return end
        local isMouse = activeInput.UserInputType == Enum.UserInputType.MouseButton1
            and input.UserInputType == Enum.UserInputType.MouseButton1
        local isTouch = activeInput.UserInputType == Enum.UserInputType.Touch and input == activeInput
        if isMouse or isTouch then
            resizing = false
            activeInput = nil
            resizeStart = nil
            startSize = nil
            showHandle()
        end
    end)

    local moveConn = UIS.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            showHandle()
        end
    end)

    local renderConn = RunService.RenderStepped:Connect(function()
        if destroyed then return end
        if not mainFrame.Parent then
            resizeHandle.Visible = false
            return
        end
        if not mainFrame.Visible then
            resizeHandle.Visible = false
            isShowing = false
            if hideTimer then pcall(task.cancel, hideTimer) hideTimer = nil end
        else
            updateHandlePosition()
        end
    end)

    local function cleanup()
        if destroyed then return end
        destroyed = true
        resizing = false
        activeInput = nil
        if hideTimer then pcall(task.cancel, hideTimer) end
        updateConn:Disconnect()
        renderConn:Disconnect()
        inputChangedConn:Disconnect()
        inputEndedConn:Disconnect()
        moveConn:Disconnect()
        if handleLayer.Parent then handleLayer:Destroy() end
    end

    resizeHandle.Destroying:Connect(cleanup)
    mainFrame.Destroying:Connect(cleanup)

    applyVisualState(true)

    return resizeHandle
end

-- ============================================================
-- EXPORT
-- ============================================================
S.Comp = Lib
S.Lib = Lib
