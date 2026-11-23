-- ============================================
-- ReaperEngine Roblox V1
-- ESP: Box + Skeleton + Tracer
-- ============================================

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera     = workspace.CurrentCamera
local localPlayer = Players.LocalPlayer

-- ======= AYARLAR =======
local CFG = {
    ESP = {
        Enabled         = true,
        MaxDistance     = 300,
        BoxColor        = Color3.fromRGB(0, 212, 255),
        SkeletonColor   = Color3.fromRGB(0, 212, 255),
        TracerColor     = Color3.fromRGB(0, 255, 100),
        TracerThickness = 2,
        BoxThickness    = 1.5,
        SkelThickness   = 1,
        FriendColor     = Color3.fromRGB(0, 255, 80),
    }
}

-- ======= STATE =======
local menuOpen   = false
local espObjects = {}

-- ======= DRAWING HELPERS =======
local function newLine(color, thickness)
    local l = Drawing.new("Line")
    l.Color     = color
    l.Thickness = thickness
    l.Visible   = false
    l.ZIndex    = 5
    return l
end

local function newBox(color, thickness)
    local b = Drawing.new("Square")
    b.Color     = color
    b.Thickness = thickness
    b.Filled    = false
    b.Visible   = false
    b.ZIndex    = 5
    return b
end

local function newText(color, size)
    local t = Drawing.new("Text")
    t.Color        = color
    t.Size         = size or 13
    t.Visible      = false
    t.Center       = true
    t.Outline      = true
    t.OutlineColor = Color3.fromRGB(0, 0, 0)
    t.ZIndex       = 6
    return t
end

-- ======= SKELETON JOINTS =======
local JOINTS = {
    {"Head","UpperTorso"},
    {"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},
    {"LeftUpperArm","LeftLowerArm"},
    {"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"},
    {"RightUpperArm","RightLowerArm"},
    {"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"},
    {"LeftUpperLeg","LeftLowerLeg"},
    {"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"},
    {"RightUpperLeg","RightLowerLeg"},
    {"RightLowerLeg","RightFoot"},
}

-- ======= CREATE ESP =======
local function createESP(player)
    if espObjects[player] then return end
    local obj = {
        Box     = newBox(CFG.ESP.BoxColor, CFG.ESP.BoxThickness),
        Tracer  = newLine(CFG.ESP.TracerColor, CFG.ESP.TracerThickness),
        Name    = newText(Color3.fromRGB(255,255,255), 13),
        Dist    = newText(CFG.ESP.BoxColor, 11),
        Skel    = {},
    }
    for _ = 1, #JOINTS do
        table.insert(obj.Skel, newLine(CFG.ESP.SkeletonColor, CFG.ESP.SkelThickness))
    end
    espObjects[player] = obj
end

-- ======= REMOVE ESP =======
local function removeESP(player)
    local obj = espObjects[player]
    if not obj then return end
    obj.Box:Remove(); obj.Tracer:Remove()
    obj.Name:Remove(); obj.Dist:Remove()
    for _, l in ipairs(obj.Skel) do l:Remove() end
    espObjects[player] = nil
end

-- ======= HIDE ALL =======
local function hideAll(obj)
    obj.Box.Visible    = false
    obj.Tracer.Visible = false
    obj.Name.Visible   = false
    obj.Dist.Visible   = false
    for _, l in ipairs(obj.Skel) do l.Visible = false end
end

-- ======= SCREEN BOX =======
local function getBox(character)
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local _, size = character:GetBoundingBox()
    local cf = root.CFrame
    local pts = {
        cf * CFrame.new(-size.X/2, -size.Y/2, 0),
        cf * CFrame.new( size.X/2, -size.Y/2, 0),
        cf * CFrame.new( size.X/2,  size.Y/2, 0),
        cf * CFrame.new(-size.X/2,  size.Y/2, 0),
    }
    local minX,minY = math.huge, math.huge
    local maxX,maxY = -math.huge,-math.huge
    for _, c in ipairs(pts) do
        local sp, vis = Camera:WorldToViewportPoint(c.Position)
        if not vis then return nil end
        minX = math.min(minX, sp.X); minY = math.min(minY, sp.Y)
        maxX = math.max(maxX, sp.X); maxY = math.max(maxY, sp.Y)
    end
    return {X=minX, Y=minY, W=maxX-minX, H=maxY-minY}
end

-- ======= SKELETON =======
local function updateSkeleton(char, lines)
    for i, pair in ipairs(JOINTS) do
        local a = char:FindFirstChild(pair[1])
        local b = char:FindFirstChild(pair[2])
        if a and b then
            local sA, vA = Camera:WorldToViewportPoint(a.Position)
            local sB, vB = Camera:WorldToViewportPoint(b.Position)
            if vA and vB then
                lines[i].From    = Vector2.new(sA.X, sA.Y)
                lines[i].To      = Vector2.new(sB.X, sB.Y)
                lines[i].Visible = true
            else
                lines[i].Visible = false
            end
        else
            lines[i].Visible = false
        end
    end
end

-- ======= MAIN UPDATE LOOP =======
local function updateAll()
    if not CFG.ESP.Enabled then
        for _, obj in pairs(espObjects) do hideAll(obj) end
        return
    end

    local myChar = localPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    local vp = Camera.ViewportSize
    local tracerOrigin = Vector2.new(vp.X / 2, 50) -- üst orta yeşil tracer

    for player, obj in pairs(espObjects) do
        if not (player and player.Parent) then
            removeESP(player)
        else
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum  = char and char:FindFirstChildOfClass("Humanoid")

            if not (root and hum and hum.Health > 0) then
                hideAll(obj)
            else
                local dist = (root.Position - myRoot.Position).Magnitude
                if dist > CFG.ESP.MaxDistance then
                    hideAll(obj)
                else
                    local box = getBox(char)
                    if not box then
                        hideAll(obj)
                    else
                        local isFriend = pcall(function()
                            return localPlayer:IsFriendsWith(player.UserId)
                        end)
                        local color = isFriend
                            and CFG.ESP.FriendColor
                            or  CFG.ESP.BoxColor

                        -- Box
                        obj.Box.Position = Vector2.new(box.X, box.Y)
                        obj.Box.Size     = Vector2.new(box.W, box.H)
                        obj.Box.Color    = color
                        obj.Box.Visible  = true

                        -- Tracer (ekran üst ortasından hedefe)
                        local foot, fVis = Camera:WorldToViewportPoint(
                            root.Position - Vector3.new(0, 3, 0))
                        if fVis then
                            obj.Tracer.From    = tracerOrigin
                            obj.Tracer.To      = Vector2.new(foot.X, foot.Y)
                            obj.Tracer.Color   = CFG.ESP.TracerColor
                            obj.Tracer.Visible = true
                        else
                            obj.Tracer.Visible = false
                        end

                        -- İsim
                        obj.Name.Text     = player.Name
                        obj.Name.Position = Vector2.new(box.X + box.W/2, box.Y - 16)
                        obj.Name.Visible  = true

                        -- Mesafe
                        obj.Dist.Text     = string.format("[%dm]", math.floor(dist))
                        obj.Dist.Position = Vector2.new(box.X + box.W/2, box.Y + box.H + 2)
                        obj.Dist.Color    = color
                        obj.Dist.Visible  = true

                        -- Skeleton
                        updateSkeleton(char, obj.Skel)
                    end
                end
            end
        end
    end
end

-- ======= PLAYER EVENTS =======
local function onAdded(player)
    if player == localPlayer then return end
    createESP(player)
end

for _, p in ipairs(Players:GetPlayers()) do onAdded(p) end
Players.PlayerAdded:Connect(onAdded)
Players.PlayerRemoving:Connect(removeESP)

-- ======= GUI =======
local sg = Instance.new("ScreenGui")
sg.Name           = "ReaperEngineGUI"
sg.ResetOnSpawn   = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.Parent         = game.CoreGui

-- Ana frame
local mf = Instance.new("Frame")
mf.Name            = "Main"
mf.Size            = UDim2.new(0, 340, 0, 420)
mf.Position        = UDim2.new(0.5,-170, 0.5,-210)
mf.BackgroundColor3= Color3.fromRGB(5,10,20)
mf.BorderSizePixel = 0
mf.Visible         = false
mf.Parent          = sg
Instance.new("UICorner", mf).CornerRadius = UDim.new(0,8)
local mfStroke = Instance.new("UIStroke", mf)
mfStroke.Color = Color3.fromRGB(0,212,255); mfStroke.Thickness = 1.5

-- Başlık
local tb = Instance.new("Frame", mf)
tb.Size            = UDim2.new(1,0,0,36)
tb.BackgroundColor3= Color3.fromRGB(0,20,40)
tb.BorderSizePixel = 0
Instance.new("UICorner", tb).CornerRadius = UDim.new(0,8)

local titleLbl = Instance.new("TextLabel", tb)
titleLbl.Size            = UDim2.new(1,-40,1,0)
titleLbl.Position        = UDim2.new(0,12,0,0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text            = "ReaperEngine Roblox V1"
titleLbl.TextColor3      = Color3.fromRGB(0,212,255)
titleLbl.TextSize        = 14
titleLbl.Font            = Enum.Font.GothamBold
titleLbl.TextXAlignment  = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", tb)
closeBtn.Size            = UDim2.new(0,28,0,28)
closeBtn.Position        = UDim2.new(1,-32,0,4)
closeBtn.BackgroundColor3= Color3.fromRGB(180,0,60)
closeBtn.Text            = "✕"
closeBtn.TextColor3      = Color3.fromRGB(255,255,255)
closeBtn.TextSize        = 12
closeBtn.Font            = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,4)
closeBtn.MouseButton1Click:Connect(function()
    mf.Visible = false; menuOpen = false
end)

-- Sidebar
local sb = Instance.new("Frame", mf)
sb.Size            = UDim2.new(0,90,1,-36)
sb.Position        = UDim2.new(0,0,0,36)
sb.BackgroundColor3= Color3.fromRGB(8,15,28)
sb.BorderSizePixel = 0
local sbList = Instance.new("UIListLayout", sb)
sbList.SortOrder = Enum.SortOrder.LayoutOrder

-- İçerik alanı
local ca = Instance.new("Frame", mf)
ca.Size               = UDim2.new(1,-90,1,-36)
ca.Position           = UDim2.new(0,90,0,36)
ca.BackgroundTransparency = 1

local cats   = {"AimBot","ESP","Memory"}
local catBtns  = {}
local catFrames= {}
local activeCat = "ESP"

local function makeCatFrame(name)
    local f = Instance.new("Frame", ca)
    f.Size               = UDim2.new(1,0,1,0)
    f.BackgroundTransparency = 1
    f.Visible            = (name == "ESP")
    catFrames[name]      = f
    return f
end

local function makeCatBtn(name, order)
    local btn = Instance.new("TextButton", sb)
    btn.Size            = UDim2.new(1,0,0,44)
    btn.BackgroundTransparency = 1
    btn.Text            = name
    btn.TextColor3      = name == activeCat
        and Color3.fromRGB(0,212,255)
        or  Color3.fromRGB(80,130,160)
    btn.TextSize        = 11
    btn.Font            = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.LayoutOrder     = order

    local line = Instance.new("Frame", btn)
    line.Size            = UDim2.new(0,2,1,0)
    line.BackgroundColor3= Color3.fromRGB(0,212,255)
    line.Visible         = (name == activeCat)

    catBtns[name] = {btn=btn, line=line}

    btn.MouseButton1Click:Connect(function()
        for n, d in pairs(catBtns) do
            d.btn.TextColor3         = Color3.fromRGB(80,130,160)
            d.btn.BackgroundTransparency = 1
            d.line.Visible           = false
            if catFrames[n] then catFrames[n].Visible = false end
        end
        btn.TextColor3         = Color3.fromRGB(0,212,255)
        btn.BackgroundTransparency = 0.6
        line.Visible           = true
        if catFrames[name] then catFrames[name].Visible = true end
        activeCat = name
    end)
end

for i, c in ipairs(cats) do makeCatBtn(c, i) end

-- Devre dışı kategoriler
for _, c in ipairs({"AimBot","Memory"}) do
    local f = makeCatFrame(c)
    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(1,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = c.."\nYakında"
    lbl.TextColor3 = Color3.fromRGB(50,80,100)
    lbl.TextSize = 13
    lbl.Font = Enum.Font.Gotham
end

-- ESP frame
local ef = makeCatFrame("ESP")
local efList = Instance.new("UIListLayout", ef)
efList.Padding = UDim.new(0,8)
local efPad = Instance.new("UIPadding", ef)
efPad.PaddingTop   = UDim.new(0,10)
efPad.PaddingLeft  = UDim.new(0,8)
efPad.PaddingRight = UDim.new(0,8)

-- Toggle helper
local function makeToggle(parent, label, initState, onChange)
    local row = Instance.new("Frame", parent)
    row.Size            = UDim2.new(1,0,0,36)
    row.BackgroundColor3= Color3.fromRGB(10,20,35)
    row.BorderSizePixel = 0
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,6)
    local rs = Instance.new("UIStroke", row)
    rs.Color = Color3.fromRGB(0,80,120); rs.Thickness = 1

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1,-50,1,0)
    lbl.Position = UDim2.new(0,10,0,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(180,220,255)
    lbl.TextSize = 12
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local bg = Instance.new("Frame", row)
    bg.Size = UDim2.new(0,36,0,20)
    bg.Position = UDim2.new(1,-44,0.5,-10)
    bg.BackgroundColor3 = initState
        and Color3.fromRGB(0,212,255)
        or  Color3.fromRGB(30,50,70)
    bg.BorderSizePixel = 0
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1,0)

    local dot = Instance.new("Frame", bg)
    dot.Size = UDim2.new(0,16,0,16)
    dot.Position = initState
        and UDim2.new(1,-18,0.5,-8)
        or  UDim2.new(0,2,0.5,-8)
    dot.BackgroundColor3 = Color3.fromRGB(255,255,255)
    dot.BorderSizePixel = 0
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)

    local state = initState
    local click = Instance.new("TextButton", row)
    click.Size = UDim2.new(1,0,1,0)
    click.BackgroundTransparency = 1
    click.Text = ""
    click.MouseButton1Click:Connect(function()
        state = not state
        bg.BackgroundColor3 = state
            and Color3.fromRGB(0,212,255)
            or  Color3.fromRGB(30,50,70)
        dot.Position = state
            and UDim2.new(1,-18,0.5,-8)
            or  UDim2.new(0,2,0.5,-8)
        rs.Color = state
            and Color3.fromRGB(0,212,255)
            or  Color3.fromRGB(0,80,120)
        onChange(state)
    end)
end

makeToggle(ef, "Player ESP", CFG.ESP.Enabled, function(v)
    CFG.ESP.Enabled = v
    if not v then
        for _, obj in pairs(espObjects) do hideAll(obj) end
    end
end)

-- Drag
local dragging, dragStart, startPos
tb.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.Touch or
       inp.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = inp.Position; startPos = mf.Position
    end
end)
tb.InputChanged:Connect(function(inp)
    if dragging and (inp.UserInputType == Enum.UserInputType.TouchMove or
                     inp.UserInputType == Enum.UserInputType.MouseMovement) then
        local d = inp.Position - dragStart
        mf.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + d.X,
            startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)
tb.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.Touch or
       inp.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Menü butonu (sağ üst)
local toggleBtn = Instance.new("TextButton", sg)
toggleBtn.Size            = UDim2.new(0,44,0,44)
toggleBtn.Position        = UDim2.new(1,-50,0,6)
toggleBtn.BackgroundColor3= Color3.fromRGB(0,20,40)
toggleBtn.Text            = "☰"
toggleBtn.TextColor3      = Color3.fromRGB(0,212,255)
toggleBtn.TextSize        = 20
toggleBtn.Font            = Enum.Font.GothamBold
toggleBtn.BorderSizePixel = 0
toggleBtn.ZIndex          = 10
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0,8)
local tbs = Instance.new("UIStroke", toggleBtn)
tbs.Color = Color3.fromRGB(0,212,255); tbs.Thickness = 1.2

toggleBtn.MouseButton1Click:Connect(function()
    menuOpen  = not menuOpen
    mf.Visible = menuOpen
end)

-- ======= RENDER LOOP =======
RunService.RenderStepped:Connect(updateAll)

print("[ReaperEngine V1] Yüklendi. Sağ üst ☰ → Menü")
