--[[
============================================================
  [7] PAGES — Command An Army (v3.6) — FIXED
============================================================
]]

local S = _G.STHAIN
repeat task.wait() until S.Config and S.Config.Combat

local C = S.Theme.Colors
local I = S.Theme.Icons
local F = S.Theme.Font

local UIS = S.Services.UIS or game:GetService("UserInputService")
local Run = S.Services.Run or game:GetService("RunService")
local TS  = S.Services.TS  or game:GetService("TweenService")

local pages = {}
local tabs = {}

-- ============================================================
-- SAVE HELPER
-- ============================================================
local function save()
    if _G.STHAIN.MarkDirty then
        _G.STHAIN.MarkDirty()
    elseif S.Utils and S.Utils.SaveConfig then
        task.spawn(S.Utils.SaveConfig)
    end
end

-- ============================================================
-- CREATE PAGE (Frame + AutomaticSize.Y, bukan ScrollingFrame)
-- ============================================================
local function createPage(name)
    local page = Instance.new("Frame")
    page.Name = "Page_" .. name
    page.Size = UDim2.new(1, 0, 0, 0)
    page.AutomaticSize = Enum.AutomaticSize.Y
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.Visible = false
    page.Parent = S.GUI.ContentScroll

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 4)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.VerticalAlignment = Enum.VerticalAlignment.Top
    layout.Parent = page

    local pad = Instance.new("UIPadding")
    pad.PaddingRight = UDim.new(0, 6)
    pad.PaddingBottom = UDim.new(0, 6)
    pad.Parent = page

    pages[name] = page
    return page
end

-- ============================================================
-- SWITCH PAGE
-- ============================================================
local function switchPage(name)
    for n, p in pairs(pages) do
        p.Visible = (n == name)
    end
    if S.GUI.ContentTitle then
        S.GUI.ContentTitle.Text = name
    end
    if S.GUI.ContentScroll then
        S.GUI.ContentScroll.CanvasPosition = Vector2.new(0, 0)
    end
end

-- ============================================================
-- MAKE TAB
-- ============================================================
local function makeTab(iconId, name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.Text = ""
    btn.BackgroundColor3 = C.bg2
    btn.BackgroundTransparency = 1
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = S.GUI.Sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    local acc = Instance.new("Frame")
    acc.Name = "AccentLine"
    acc.Size = UDim2.new(0, 3, 0, 0)
    acc.Position = UDim2.new(0, 6, 0.5, 0)
    acc.AnchorPoint = Vector2.new(0, 0.5)
    acc.BackgroundColor3 = C.accent
    acc.BorderSizePixel = 0
    acc.Visible = false
    acc.Parent = btn
    Instance.new("UICorner", acc).CornerRadius = UDim.new(1, 0)

    local ic = Instance.new("ImageLabel")
    ic.Size = UDim2.new(0, 14, 0, 14)
    ic.Position = UDim2.new(0, 16, 0.5, -7)
    ic.BackgroundTransparency = 1
    ic.Image = iconId
    ic.ImageColor3 = C.textDim
    ic.Parent = btn

    local tx = Instance.new("TextLabel")
    tx.Size = UDim2.new(1, -40, 1, 0)
    tx.Position = UDim2.new(0, 38, 0, 0)
    tx.Text = name
    tx.TextColor3 = C.textDim
    tx.TextSize = 10
    tx.Font = F.norm
    tx.TextXAlignment = Enum.TextXAlignment.Left
    tx.BackgroundTransparency = 1
    tx.Parent = btn

    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do
            t.btn.BackgroundColor3 = C.bg2
            t.btn.BackgroundTransparency = 1
            t.icon.ImageColor3 = C.textDim
            t.text.TextColor3 = C.textDim
            t.bar.Visible = false
        end
        btn.BackgroundColor3 = C.bg3
        btn.BackgroundTransparency = 0.3
        ic.ImageColor3 = C.accent
        tx.TextColor3 = C.text
        acc.Visible = true
        acc.Size = UDim2.new(0, 3, 0, 0)
        TS:Create(acc, TweenInfo.new(0.15), {
            Size = UDim2.new(0, 3, 0, 18)
        }):Play()
        switchPage(name)
    end)

    table.insert(tabs, { btn = btn, icon = ic, text = tx, bar = acc })
end

-- ============================================================
-- BUAT PAGES + TABS
-- ============================================================
createPage("Combat")
createPage("Esp")
createPage("Teleport")
createPage("Automation")
createPage("Settings")
createPage("Config")

makeTab(I.combat, "Combat")
makeTab(I.visual, "Esp")
makeTab(I.teleport, "Teleport")
makeTab(I.automation, "Automation")
makeTab(I.settings, "Settings")
makeTab(I.config, "Config")

-- ============================================================
-- TAB COMBAT
-- ============================================================
local CC = S.Config.Combat
local SS = S.Config.Spawn

local autoCombat, recalcAutoCombat = S.Comp.makeSection(pages["Combat"], "Auto Combat", false)
S.Comp.makeToggle(autoCombat, "Auto Attack (V)", CC.AutoAttack == true, function(v) CC.AutoAttack = v save() end, {"Combat", "AutoAttack"})
S.Comp.makeToggle(autoCombat, "Auto Rush (B)", CC.AutoRush == true, function(v) CC.AutoRush = v save() end, {"Combat", "AutoRush"})
S.Comp.makeToggle(autoCombat, "Auto Follow (C)", CC.AutoFollow == true, function(v) CC.AutoFollow = v save() end, {"Combat", "AutoFollow"})
task.defer(function() task.wait(0.05) recalcAutoCombat() end)

local spawnSection, recalcSpawn = S.Comp.makeSection(pages["Combat"], "Spawn Unit", false)
S.Comp.makeDropdown(spawnSection, "Unit Slot", {"1", "2", "3", "4"}, function(v)
    SS.UnitSlot = tonumber(v) or 1
    save()
end)
S.Comp.makeButton(spawnSection, "Spawn Unit", function()
    if _G.STHAIN.SpawnUnit then _G.STHAIN.SpawnUnit(SS.UnitSlot) end
end)
S.Comp.makeToggle(spawnSection, "Auto Respawn [BETA]", SS.AutoSpawn == true, function(v)
    SS.AutoSpawn = v
    save()
end, {"Spawn", "AutoSpawn"})
task.defer(function() task.wait(0.05) recalcSpawn() end)

local pvpSection, recalcPvp = S.Comp.makeSection(pages["Combat"], "PvP", false)
S.Comp.makeToggle(pvpSection, "Kill Aura", CC.KillAura == true, function(v) CC.KillAura = v save() end, {"Combat", "KillAura"})
S.Comp.makeToggle(pvpSection, "Target Lock", CC.TargetLock == true, function(v) CC.TargetLock = v save() end, {"Combat", "TargetLock"})
S.Comp.makeToggle(pvpSection, "Auto Heal", CC.AutoHeal == true, function(v) CC.AutoHeal = v save() end, {"Combat", "AutoHeal"})
S.Comp.makeToggle(pvpSection, "Anti-Stun", CC.AntiStun == true, function(v) CC.AntiStun = v save() end, {"Combat", "AntiStun"})
task.defer(function() task.wait(0.05) recalcPvp() end)

local combatDelay, recalcCombatDelay = S.Comp.makeSection(pages["Combat"], "Delay Settings", false)
S.Comp.makeInput(combatDelay, "Attack Delay", CC.AttackDelay, function(v) CC.AttackDelay = v save() end)
S.Comp.makeInput(combatDelay, "Rush Delay", CC.RushDelay, function(v) CC.RushDelay = v save() end)
S.Comp.makeInput(combatDelay, "Follow Delay", CC.FollowDelay, function(v) CC.FollowDelay = v save() end)
task.defer(function() task.wait(0.05) recalcCombatDelay() end)

-- ============================================================
-- TAB ESP
-- ============================================================
local VV = S.Config.Visual

local enableEsp, recalcEnableEsp = S.Comp.makeSection(pages["Esp"], "Enable Esp", false)
S.Comp.makeToggle(enableEsp, "Enable Esp", VV.Chams == true, function(v) VV.Chams = v save() end, {"Visual", "Chams"})
task.defer(function() task.wait(0.05) recalcEnableEsp() end)

local espSetting, recalcEspSetting = S.Comp.makeSection(pages["Esp"], "Esp Setting", false)
S.Comp.makeToggle(espSetting, "Show Distance", VV.ESPShowDistance == true, function(v) VV.ESPShowDistance = v save() end, {"Visual", "ESPShowDistance"})
S.Comp.makeToggle(espSetting, "Show Health", VV.ESPHealth == true, function(v) VV.ESPHealth = v save() end, {"Visual", "ESPHealth"})
S.Comp.makeToggle(espSetting, "Show Name", VV.ESPName == true, function(v) VV.ESPName = v save() end, {"Visual", "ESPName"})
task.defer(function() task.wait(0.05) recalcEspSetting() end)

local espObject, recalcEspObject = S.Comp.makeSection(pages["Esp"], "Esp Object", false)
S.Comp.makeToggle(espObject, "Esp Supply", VV.ESPSupply == true, function(v) VV.ESPSupply = v save() end, {"Visual", "ESPSupply"})
S.Comp.makeToggle(espObject, "Esp Capture", VV.ESPCapture == true, function(v) VV.ESPCapture = v save() end, {"Visual", "ESPCapture"})
task.defer(function() task.wait(0.05) recalcEspObject() end)

-- ============================================================
-- TAB TELEPORT
-- ============================================================
local TT = S.Config.Teleport

local tpCapture, recalcTpCapture = S.Comp.makeSection(pages["Teleport"], "Capture Point", false)
S.Comp.makeButton(tpCapture, "TP to Nearest Capture", function()
    if _G.STHAIN.TeleportToNearestCapture then _G.STHAIN.TeleportToNearestCapture() end
end)
S.Comp.makeButton(tpCapture, "TP to Base", function()
    if _G.STHAIN.TeleportToBase then _G.STHAIN.TeleportToBase() end
end)
S.Comp.makeButton(tpCapture, "TP to Point A", function()
    if _G.STHAIN.TeleportToPointA then _G.STHAIN.TeleportToPointA() end
end)
S.Comp.makeButton(tpCapture, "TP to Point B", function()
    if _G.STHAIN.TeleportToPointB then _G.STHAIN.TeleportToPointB() end
end)
task.defer(function() task.wait(0.05) recalcTpCapture() end)

local tpPlayer, recalcTpPlayer = S.Comp.makeSection(pages["Teleport"], "Player", false)
S.Comp.makeButton(tpPlayer, "TP to Nearest Enemy", function()
    if _G.STHAIN.TeleportToNearestEnemy then _G.STHAIN.TeleportToNearestEnemy() end
end)
S.Comp.makeButton(tpPlayer, "TP to Teammate", function()
    if _G.STHAIN.TeleportToTeammate then _G.STHAIN.TeleportToTeammate() end
end)
task.defer(function() task.wait(0.05) recalcTpPlayer() end)

local supplyEnemySection, recalcSupplyEnemy = S.Comp.makeSection(pages["Teleport"], "Supply Enemy", false)
local enemyDropdown = S.Comp.makeDropdown(supplyEnemySection, "Supply Target", {TT.EnemySupplyTarget or "None"}, function(v)
    TT.EnemySupplyTarget = v
    save()
end)
S.Comp.makeButton(supplyEnemySection, "TP Supply Enemy", function()
    if _G.STHAIN.TeleportToSupplyEnemy then _G.STHAIN.TeleportToSupplyEnemy(TT.EnemySupplyTarget or "") end
end)
task.defer(function() task.wait(0.05) recalcSupplyEnemy() end)

local supplyOwnerSection, recalcSupplyOwner = S.Comp.makeSection(pages["Teleport"], "Supply Owner", false)
local ownerDropdown = S.Comp.makeDropdown(supplyOwnerSection, "Supply Target", {TT.OwnerSupplyTarget or "None"}, function(v)
    TT.OwnerSupplyTarget = v
    save()
end)
S.Comp.makeButton(supplyOwnerSection, "TP Supply Owner", function()
    if _G.STHAIN.TeleportToSupplyOwner then _G.STHAIN.TeleportToSupplyOwner(TT.OwnerSupplyTarget or "") end
end)
task.defer(function() task.wait(0.05) recalcSupplyOwner() end)

-- ============================================================
-- DYNAMIC DROPDOWN UPDATE LOOP (supply)
-- ============================================================
task.spawn(function()
    while task.wait(2) do
        -- guard: stop kalau GUI sudah destroy
        if not S.GUI or not S.GUI.MainFrame or not S.GUI.MainFrame.Parent then break end
        if not _G.STHAIN.GetSupplyList then continue end

        local ok, data = pcall(_G.STHAIN.GetSupplyList)
        if not ok or type(data) ~= "table" then
            enemyDropdown.UpdateOptions({"None"})
            ownerDropdown.UpdateOptions({"None"})
            continue
        end

        local enemies = data.enemySupplies or {}
        local owners = data.ownerSupplies or {}

        enemyDropdown.UpdateOptions(#enemies > 0 and enemies or {"None"})
        ownerDropdown.UpdateOptions(#owners > 0 and owners or {"None"})
    end
end)

-- ============================================================
-- TAB AUTOMATION
-- ============================================================
local AA = S.Config.Automation or {}

-- 1. SUMMON
local summonSection, recalcSummon = S.Comp.makeSection(pages["Automation"], "Summon", false)
S.Comp.makeToggle(summonSection, "Auto Summon", AA.AutoSummon == true, function(v)
    AA.AutoSummon = v
    save()
end, {"Automation", "AutoSummon"})
S.Comp.makeDropdown(summonSection, "Summon Amount", {"1x", "10x"}, function(val)
    AA.SummonAmount = val
    save()
end)
S.Comp.makeInput(summonSection, "Keep Gems", AA.KeepGems or 0, function(v)
    AA.KeepGems = v
    save()
end)
task.defer(function() task.wait(0.05) recalcSummon() end)

-- 2. ASCEND
local ascendSection, recalcAscend = S.Comp.makeSection(pages["Automation"], "Ascend", false)
S.Comp.makeToggle(ascendSection, "Auto Ascend", AA.AutoAscend == true, function(v)
    AA.AutoAscend = v
    save()
end, {"Automation", "AutoAscend"})
task.defer(function() task.wait(0.05) recalcAscend() end)

-- 3. EVOLVE
local evolveSection, recalcEvolve = S.Comp.makeSection(pages["Automation"], "Evolve", false)
S.Comp.makeToggle(evolveSection, "Auto Evolve", AA.AutoEvolve == true, function(v)
    AA.AutoEvolve = v
    save()
end, {"Automation", "AutoEvolve"})
task.defer(function() task.wait(0.05) recalcEvolve() end)

-- 4. REWARDS
local rewardSection, recalcReward = S.Comp.makeSection(pages["Automation"], "Rewards", false)
S.Comp.makeToggle(rewardSection, "Auto Daily/Weekly Reward", AA.AutoReward == true, function(v)
    AA.AutoReward = v
    save()
end, {"Automation", "AutoReward"})
task.defer(function() task.wait(0.05) recalcReward() end)

-- 5. CLAIM CODE
local codeSection, recalcCode = S.Comp.makeSection(pages["Automation"], "Claim Code", false)

local codeBox = S.Comp.makeTextInput(codeSection, "Enter Code", "", "Enter A Code...", function(v)
    -- callback opsional
end)

local codeDropdown = S.Comp.makeDropdown(codeSection, "Available Codes", {"Fetching..."}, function(val)
    if val ~= "Fetching..." and val ~= "None" and val ~= "No Codes" then
        codeBox.Text = val
    end
end)

-- fetch codes dengan retry
task.spawn(function()
    for attempt = 1, 3 do
        task.wait(attempt == 1 and 2 or 5)
        if not S.GUI or not S.GUI.MainFrame or not S.GUI.MainFrame.Parent then return end
        if not _G.STHAIN.FetchCodesSmart then break end
        local ok, codes = pcall(_G.STHAIN.FetchCodesSmart)
        if ok and codes and #codes > 0 then
            codeDropdown.UpdateOptions(codes)
            return
        end
    end
    if S.GUI and S.GUI.MainFrame and S.GUI.MainFrame.Parent then
        codeDropdown.UpdateOptions({"No Codes"})
    end
end)

S.Comp.makeButton(codeSection, "Claim Code", function()
    local code = codeBox.Text
    if code ~= "" then
        local Remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Shared")
            and game:GetService("ReplicatedStorage").Shared:FindFirstChild("Remotes")
        local RedeemCode = Remotes and Remotes:FindFirstChild("RedeemCode")
        if RedeemCode then
            pcall(function() RedeemCode:InvokeServer(code) end)
        end
        codeBox.Text = ""
    end
end)
task.defer(function() task.wait(0.05) recalcCode() end)

-- ============================================================
-- TAB SETTINGS
-- ============================================================
local MM = S.Config.Movement
local XX = S.Config.Misc

local utilityContent, recalcUtility = S.Comp.makeSection(pages["Settings"], "Player Utility", false)
S.Comp.makeInput(utilityContent, "Speed Value", MM.WalkSpeed, function(v) MM.WalkSpeed = v save() end)
S.Comp.makeToggle(utilityContent, "Enable Run Speed", MM.EnableRunSpeed == true, function(v)
    MM.EnableRunSpeed = v
    save()
end, {"Movement", "EnableRunSpeed"})
S.Comp.makeToggle(utilityContent, "No Clip", MM.Noclip == true, function(v) MM.Noclip = v save() end, {"Movement", "Noclip"})
S.Comp.makeToggle(utilityContent, "Fly", MM.Fly == true, function(v) MM.Fly = v save() end, {"Movement", "Fly"})
S.Comp.makeToggle(utilityContent, "Infinite Jump", MM.InfJump == true, function(v) MM.InfJump = v save() end, {"Movement", "InfJump"})
S.Comp.makeInput(utilityContent, "Fly Speed", MM.FlySpeed, function(v) MM.FlySpeed = v save() end)
S.Comp.makeInput(utilityContent, "Jump Power", MM.JumpPower, function(v) MM.JumpPower = v save() end)
S.Comp.makeToggle(utilityContent, "Anti-AFK", XX.AntiAFK == true, function(v) XX.AntiAFK = v save() end, {"Misc", "AntiAFK"})
task.defer(function() task.wait(0.05) recalcUtility() end)

local visualContent, recalcVisual = S.Comp.makeSection(pages["Settings"], "Visuals", false)
S.Comp.makeToggle(visualContent, "Full Bright", VV.Fullbright == true, function(v) VV.Fullbright = v save() end, {"Visual", "Fullbright"})
S.Comp.makeToggle(visualContent, "No Fog", VV.NoFog == true, function(v) VV.NoFog = v save() end, {"Visual", "NoFog"})
task.defer(function() task.wait(0.05) recalcVisual() end)

local autoJoinContent, recalcAutoJoin = S.Comp.makeSection(pages["Settings"], "Auto Join Team", false)
local setJoinDefender, setJoinAttacker

local initialTeam = XX.AutoJoinTeam or "none"
local initDef = (initialTeam == "defender")
local initAtt = (initialTeam == "attacker")

setJoinDefender = S.Comp.makeToggle(autoJoinContent, "Auto Join Defenders", initDef, function(v)
    if v then
        XX.AutoJoinTeam = "defender"
        if setJoinAttacker then setJoinAttacker(false, true) end
        save()
    elseif XX.AutoJoinTeam == "defender" then
        XX.AutoJoinTeam = "none"
        save()
    end
end)

setJoinAttacker = S.Comp.makeToggle(autoJoinContent, "Auto Join Attackers", initAtt, function(v)
    if v then
        XX.AutoJoinTeam = "attacker"
        if setJoinDefender then setJoinDefender(false, true) end
        save()
    elseif XX.AutoJoinTeam == "attacker" then
        XX.AutoJoinTeam = "none"
        save()
    end
end)
task.defer(function() task.wait(0.05) recalcAutoJoin() end)

local serverContent, recalcServer = S.Comp.makeSection(pages["Settings"], "Server", false)
S.Comp.makeButton(serverContent, "Rejoin Server", function()
    pcall(function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, S.LP)
    end)
end)
S.Comp.makeButton(serverContent, "Server Hop (Find Small Server)", function()
    pcall(function()
        local Http = game:GetService("HttpService")
        local TeleportService = game:GetService("TeleportService")
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100"
        local data = Http:JSONDecode(game:HttpGet(url))
        local best = nil
        for _, server in pairs(data.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                if not best or server.playing < best.playing then
                    best = server
                end
            end
        end
        if best then TeleportService:TeleportToPlaceInstance(game.PlaceId, best.id, S.LP) end
    end)
end)
task.defer(function() task.wait(0.05) recalcServer() end)

-- ============================================================
-- TAB CONFIG
-- ============================================================
local cfg = S.Config.Config

local autoSaveSection, recalcAutoSave = S.Comp.makeSection(pages["Config"], "Auto Save", false)
S.Comp.makeToggle(autoSaveSection, "Auto Save Config", cfg.AutoSave == true, function(v)
    cfg.AutoSave = v
    save()
end, {"Config", "AutoSave"})
task.defer(function() task.wait(0.05) recalcAutoSave() end)

local configMgmt, recalcConfigMgmt = S.Comp.makeSection(pages["Config"], "Config Management", false)

-- ============================================================
-- TOMBOL RESET (CONFIRMED! 3 DETIK)
-- ============================================================
local resetBtn = S.Comp.makeButton(configMgmt, "Reset to Default", function() end, true)
local resetTimer = nil

resetBtn.MouseButton1Click:Connect(function()
    if resetBtn.Text == "Reset to Default" then
        resetBtn.Text = "Click Again to Confirm"
        if resetTimer then pcall(task.cancel, resetTimer) end
        resetTimer = task.delay(3, function()
            resetBtn.Text = "Reset to Default"
            resetTimer = nil
        end)
    elseif resetBtn.Text == "Click Again to Confirm" then
        if _G.STHAIN.ResetConfig then
            pcall(_G.STHAIN.ResetConfig)
        end
        if S.Comp and S.Comp.RefreshAll then
            S.Comp.RefreshAll()
        end
        if S.Comp and S.Comp.RefreshAllDropdowns then
            S.Comp.RefreshAllDropdowns()
        end
        resetBtn.Text = "Confirmed!"
        if resetTimer then pcall(task.cancel, resetTimer) end
        resetTimer = task.delay(3, function()
            resetBtn.Text = "Reset to Default"
            resetTimer = nil
        end)
    end
end)

-- ============================================================
-- TOMBOL DELETE (CONFIRMED! 3 DETIK)
-- ============================================================
local deleteBtn = S.Comp.makeButton(configMgmt, "Delete Config File", function() end, true)
local deleteTimer = nil

deleteBtn.MouseButton1Click:Connect(function()
    if deleteBtn.Text == "Delete Config File" then
        deleteBtn.Text = "Click Again to Confirm"
        if deleteTimer then pcall(task.cancel, deleteTimer) end
        deleteTimer = task.delay(3, function()
            deleteBtn.Text = "Delete Config File"
            deleteTimer = nil
        end)
    elseif deleteBtn.Text == "Click Again to Confirm" then
        if _G.STHAIN.Utils and _G.STHAIN.Utils.DeleteConfig then
            pcall(_G.STHAIN.Utils.DeleteConfig)
        end
        deleteBtn.Text = "Confirmed!"
        if deleteTimer then pcall(task.cancel, deleteTimer) end
        deleteTimer = task.delay(3, function()
            deleteBtn.Text = "Delete Config File"
            deleteTimer = nil
        end)
    end
end)

task.defer(function() task.wait(0.05) recalcConfigMgmt() end)

-- ============================================================
-- DRAG MAIN FRAME (dengan clamp ke layar)
-- ============================================================
local mainDrag, mainStart, mainPos
S.GUI.Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        mainDrag = true
        mainStart = input.Position
        mainPos = S.GUI.MainFrame.Position
    end
end)
S.GUI.Header.InputChanged:Connect(function(input)
    if mainDrag and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - mainStart
        local screen = S.GUI.MainFrame.Parent.AbsoluteSize
        local size = S.GUI.MainFrame.AbsoluteSize
        local newX = mainPos.X.Offset + delta.X
        local newY = mainPos.Y.Offset + delta.Y
        newX = math.clamp(newX, 0, math.max(0, screen.X - size.X))
        newY = math.clamp(newY, 0, math.max(0, screen.Y - size.Y))
        S.GUI.MainFrame.Position = UDim2.new(0, newX, 0, newY)
    end
end)
S.GUI.Header.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        mainDrag = false
    end
end)

-- ============================================================
-- MINIMIZE / OPEN
-- ============================================================
switchPage("Combat")

for _, t in pairs(tabs) do
    if t.text.Text == "Combat" then
        t.btn.BackgroundColor3 = C.bg3
        t.btn.BackgroundTransparency = 0.3
        t.icon.ImageColor3 = C.accent
        t.text.TextColor3 = C.text
        t.bar.Visible = true
        t.bar.Size = UDim2.new(0, 3, 0, 18)
        break
    end
end

S.GUI.MinBtn.MouseButton1Click:Connect(function()
    S.GUI.MainFrame.Visible = false
    S.GUI.FloatBtn.Visible = true
end)

S.GUI.MainFrame.Visible = true
S.GUI.FloatBtn.Visible = false

-- ============================================================
-- SEARCH FEATURE
-- ============================================================
if S.GUI.SearchBox then
    S.GUI.SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = string.lower(S.GUI.SearchBox.Text)
        if query == "" then
            -- reset ke Combat
            switchPage("Combat")
            for _, t in pairs(tabs) do
                local isCombat = t.text.Text == "Combat"
                t.btn.BackgroundColor3 = isCombat and C.bg3 or C.bg2
                t.btn.BackgroundTransparency = isCombat and 0.3 or 1
                t.icon.ImageColor3 = isCombat and C.accent or C.textDim
                t.text.TextColor3 = isCombat and C.text or C.textDim
                t.bar.Visible = isCombat
            end
            return
        end

        for pageName, page in pairs(pages) do
            for _, section in pairs(page:GetChildren()) do
                if section.Name:find("Section_") then
                    local sectionName = string.lower(section.Name:gsub("Section_", ""))
                    local matchFound = false

                    if string.find(sectionName, query) then
                        matchFound = true
                    end

                    local content = section:FindFirstChild("Content")
                    if content then
                        for _, item in pairs(content:GetChildren()) do
                            local itemName = ""
                            if item:IsA("Frame") then
                                local lbl = item:FindFirstChildWhichIsA("TextLabel")
                                if lbl then itemName = string.lower(lbl.Text) end
                            end
                            if string.find(itemName, query) then
                                matchFound = true
                                break
                            end
                        end
                    end

                    if matchFound then
                        switchPage(pageName)
                        if S.GUI.ContentTitle then
                            S.GUI.ContentTitle.Text = pageName
                        end

                        for _, t in pairs(tabs) do
                            if t.text.Text == pageName then
                                t.btn.BackgroundColor3 = C.bg3
                                t.btn.BackgroundTransparency = 0.3
                                t.icon.ImageColor3 = C.accent
                                t.text.TextColor3 = C.text
                                t.bar.Visible = true
                            else
                                t.btn.BackgroundColor3 = C.bg2
                                t.btn.BackgroundTransparency = 1
                                t.icon.ImageColor3 = C.textDim
                                t.text.TextColor3 = C.textDim
                                t.bar.Visible = false
                            end
                        end

                        task.defer(function()
                            if page and page.Visible and S.GUI.ContentScroll then
                                S.GUI.ContentScroll.CanvasPosition = Vector2.new(0, section.Position.Y.Offset)
                            end
                        end)
                        return
                    end
                end
            end
        end
    end)
end

-- ============================================================
-- RESIZE UI
-- ============================================================
if S.Comp and S.Comp.attachResizeHandle then
    S.Comp.attachResizeHandle(S.GUI.MainFrame)
end
