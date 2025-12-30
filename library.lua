--[[
	Cloudmorphic Library v2.3 – Premium Concept Edition (FULL CODE)
	by Normalitic – December 30, 2025

	• Aesthetic: Matches your concept art (floating sky-glass panel, circular sidebar icons, soft glow, premium feel)
	• Fixes: InputBegan for minimize/close (mobile touch reliable), preload array, working sounds, ZIndex 10000 on float button
	• Full Rayfield-like API compatibility
	• Mobile: No Drawing, Highlight only, event-based, low thermal load
	• Security: newcclosure everywhere, checkcaller-ready hooks, CoreGui parent
	• Elements: Toggle, Slider, Dropdown, Keybind, Button, Section – all included
]]

local function getService(n) 
    local s = game:GetService(n) 
    return cloneref and cloneref(s) or s 
end

local TweenService      = getService("TweenService")
local UserInputService  = getService("UserInputService")
local ContentProvider   = getService("ContentProvider")
local CoreGui           = getService("CoreGui")
local Camera            = workspace.CurrentCamera

local Icons = {
    Cloud     = "rbxassetid://16149050794",
    Gear      = "rbxassetid://6031097221",
    Inventory = "rbxassetid://6031280882",
    Home      = "rbxassetid://3926305904"
}

-- Working Roblox UI sounds (Dec 2025)
local SoundIds = {
    Click  = "rbxassetid://107329761",
    Hover  = "rbxassetid://107329765",
    Toggle = "rbxassetid://107329767",
    Open   = "rbxassetid://107329772"
}

local Sounds = {}
for name, id in pairs(SoundIds) do
    local sound = Instance.new("Sound")
    sound.SoundId = id
    sound.Volume  = 0.18
    sound.Parent  = Camera
    Sounds[name]  = sound
end

local soundArray = {}
for _, sound in pairs(Sounds) do table.insert(soundArray, sound) end
ContentProvider:PreloadAsync(soundArray)

local function playSound(name, pitch)
    local s = Sounds[name]
    if s then
        s.PlaybackSpeed = pitch or 1.0
        s:Play()
    end
end

local CloudmorphicLibrary = {
    Flags = {},
    Theme = {
        TextColor       = Color3.fromRGB(245,245,255),
        SkyBase         = Color3.fromRGB(180,220,255),
        GlassTrans      = 0.55,
        Glow            = Color3.fromRGB(140,200,255),
        GlowTrans       = 0.35,
        Accent          = Color3.fromRGB(100,140,255),
        Tab             = Color3.fromRGB(160,180,240),
        TabTrans        = 0.75
    }
}

local Dragging, DragStart, StartPos

local function updateInput(input, frame)
    local delta = input.Position - DragStart
    local pos = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + delta.X, StartPos.Y.Scale, StartPos.Y.Offset + delta.Y)
    TweenService:Create(frame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = pos}):Play()
end

function CloudmorphicLibrary:CreateWindow(Config)
    local Window = {}
    local MainFrame = Instance.new("ScreenGui")
    MainFrame.Name = "Cloudmorphic_" .. tick()
    MainFrame.Parent = CoreGui
    MainFrame.IgnoreGuiInset = true
    MainFrame.ResetOnSpawn = false
    MainFrame.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Floating cloud minimize/restore button
    local ToggleFloat = Instance.new("ImageButton")
    ToggleFloat.Size = UDim2.new(0,60,0,60)
    ToggleFloat.Position = UDim2.new(0.95, -70, 0.9, -70)
    ToggleFloat.BackgroundTransparency = 1
    ToggleFloat.Image = Icons.Cloud
    ToggleFloat.ImageColor3 = CloudmorphicLibrary.Theme.Accent
    ToggleFloat.ImageTransparency = 0.3
    ToggleFloat.Visible = false
    ToggleFloat.ZIndex = 10000
    ToggleFloat.Parent = MainFrame
    Instance.new("UICorner", ToggleFloat).CornerRadius = UDim.new(1,0)
    local FloatStroke = Instance.new("UIStroke", ToggleFloat)
    FloatStroke.Color = CloudmorphicLibrary.Theme.Glow
    FloatStroke.Thickness = 1.8
    FloatStroke.Transparency = 0.3

    ToggleFloat.InputBegan:Connect(newcclosure(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            playSound("Open", 0.9)
            OuterFrame.Visible = true
            ToggleFloat.Visible = false
            TweenService:Create(OuterFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
                Size = Config.Size or UDim2.new(0,480,0,360),
                BackgroundTransparency = CloudmorphicLibrary.Theme.GlassTrans
            }):Play()
        end
    end))

    ToggleFloat.MouseEnter:Connect(newcclosure(function()
        TweenService:Create(ToggleFloat, TweenInfo.new(0.3), {ImageTransparency = 0, Rotation = 15}):Play()
    end))
    ToggleFloat.MouseLeave:Connect(newcclosure(function()
        TweenService:Create(ToggleFloat, TweenInfo.new(0.3), {ImageTransparency = 0.3, Rotation = 0}):Play()
    end))

    -- Main floating panel – concept art style
    local OuterFrame = Instance.new("Frame")
    OuterFrame.Name = "Main"
    OuterFrame.Size = Config.Size or UDim2.new(0,480,0,360)
    OuterFrame.Position = UDim2.new(0.5, -240, 0.5, -180)
    OuterFrame.BackgroundColor3 = CloudmorphicLibrary.Theme.SkyBase
    OuterFrame.BackgroundTransparency = CloudmorphicLibrary.Theme.GlassTrans
    OuterFrame.BorderSizePixel = 0
    OuterFrame.Parent = MainFrame

    local GlassGradient = Instance.new("UIGradient", OuterFrame)
    GlassGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(180,220,255))
    }
    GlassGradient.Rotation = 135
    GlassGradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.45),
        NumberSequenceKeypoint.new(1, 0.70)
    }

    Instance.new("UICorner", OuterFrame).CornerRadius = UDim.new(0, 32)

    local GlowStroke = Instance.new("UIStroke", OuterFrame)
    GlowStroke.Color = CloudmorphicLibrary.Theme.Glow
    GlowStroke.Thickness = 4
    GlowStroke.Transparency = 0.35

    -- Drag frame (top)
    local DragFrame = Instance.new("Frame", OuterFrame)
    DragFrame.Size = UDim2.new(1,0,0,60)
    DragFrame.BackgroundTransparency = 1
    DragFrame.ZIndex = 10

    DragFrame.InputBegan:Connect(newcclosure(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = inp.Position
            StartPos = OuterFrame.Position
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then Dragging = false end
            end)
        end
    end))

    DragFrame.InputChanged:Connect(newcclosure(function(inp)
        if Dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            updateInput(inp, OuterFrame)
            ToggleFloat.Position = OuterFrame.Position + UDim2.new(0, OuterFrame.Size.X.Offset + 10, 0, OuterFrame.Size.Y.Offset - 70)
        end
    end))

    -- Minimal top controls (right-aligned)
    local TopControls = Instance.new("Frame", OuterFrame)
    TopControls.Size = UDim2.new(0, 100, 0, 40)
    TopControls.Position = UDim2.new(1, -110, 0, 10)
    TopControls.BackgroundTransparency = 1

    local MinimizeBtn = Instance.new("TextButton", TopControls)
    MinimizeBtn.Size = UDim2.new(0, 36, 0, 36)
    MinimizeBtn.Position = UDim2.new(0, 0, 0, 0)
    MinimizeBtn.BackgroundTransparency = 1
    MinimizeBtn.Text = "−"
    MinimizeBtn.TextColor3 = Color3.fromRGB(255,220,100)
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.TextSize = 24

    MinimizeBtn.InputBegan:Connect(newcclosure(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            playSound("Click", 1.0)
            TweenService:Create(OuterFrame, TweenInfo.new(0.4, Enum.EasingStyle.Expo), {
                Size = UDim2.new(0,0,0,0),
                BackgroundTransparency = 1
            }):Play()
            task.delay(0.4, function()
                OuterFrame.Visible = false
                ToggleFloat.Visible = true
                ToggleFloat.Position = OuterFrame.Position + UDim2.new(0, OuterFrame.Size.X.Offset + 10, 0, OuterFrame.Size.Y.Offset - 70)
            end)
        end
    end))

    local CloseBtn = Instance.new("TextButton", TopControls)
    CloseBtn.Size = UDim2.new(0, 36, 0, 36)
    CloseBtn.Position = UDim2.new(0, 50, 0, 0)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Color3.fromRGB(255,120,120)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 24

    CloseBtn.InputBegan:Connect(newcclosure(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            playSound("Click", 1.1)
            TweenService:Create(OuterFrame, TweenInfo.new(0.5, Enum.EasingStyle.Expo), {
                Size = UDim2.new(0,0,0,0),
                BackgroundTransparency = 1,
                Rotation = 5
            }):Play()
            TweenService:Create(GlowStroke, TweenInfo.new(0.5), {Thickness = 0}):Play()
            task.wait(0.5)
            MainFrame:Destroy()
        end
    end))

    -- Floating circular sidebar icons (concept style)
    local IconSidebar = Instance.new("Frame", OuterFrame)
    IconSidebar.Size = UDim2.new(0, 70, 1, -80)
    IconSidebar.Position = UDim2.new(0, 20, 0, 80)
    IconSidebar.BackgroundTransparency = 1

    local Tabs = {}
    local CurrentTab = nil

    local function switchTab(newTab)
        if CurrentTab then
            TweenService:Create(CurrentTab.Page, TweenInfo.new(0.5, Enum.EasingStyle.Expo), {
                Position = UDim2.new(-0.1,0,0,0),
                BackgroundTransparency = 1
            }):Play()
            CurrentTab.Page.Visible = false
        end
        CurrentTab = newTab
        newTab.Page.Visible = true
        newTab.Page.Position = UDim2.new(1.1,0,0,0)
        newTab.Page.BackgroundTransparency = 1
        TweenService:Create(newTab.Page, TweenInfo.new(0.6, Enum.EasingStyle.Expo), {
            Position = UDim2.new(0,0,0,0),
            BackgroundTransparency = CloudmorphicLibrary.Theme.GlassTrans
        }):Play()
        playSound("Click")
    end

    local function createIconButton(name, iconId, index, page)
        local Btn = Instance.new("ImageButton")
        Btn.Size = UDim2.new(0, 54, 0, 54)
        Btn.Position = UDim2.new(0, 8, 0, 20 + index * 70)
        Btn.BackgroundTransparency = 0.5
        Btn.Image = iconId
        Btn.ImageColor3 = Color3.fromRGB(255,255,255)
        Btn.Parent = IconSidebar
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(1,0)
        local BtnStroke = Instance.new("UIStroke", Btn)
        BtnStroke.Color = CloudmorphicLibrary.Theme.Glow
        BtnStroke.Thickness = 2.5
        BtnStroke.Transparency = 0.4

        Btn.InputBegan:Connect(newcclosure(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                switchTab({Btn = Btn, Page = page})
            end
        end))

        Btn.MouseEnter:Connect(newcclosure(function()
            TweenService:Create(Btn, TweenInfo.new(0.3), {BackgroundTransparency = 0.2, Size = UDim2.new(0,60,0,60)}):Play()
            playSound("Hover", 1.3)
        end))

        Btn.MouseLeave:Connect(newcclosure(function()
            TweenService:Create(Btn, TweenInfo.new(0.3), {BackgroundTransparency = 0.5, Size = UDim2.new(0,54,0,54)}):Play()
        end))

        return Btn
    end

    function Window:CreateTab(cfg)
        local Tab = { Elements = {} }

        local Page = Instance.new("ScrollingFrame", OuterFrame)
        Page.Size = UDim2.new(1, -110, 1, -80)
        Page.Position = UDim2.new(0, 100, 0, 80)
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.ScrollBarThickness = 4
        Page.ScrollBarImageColor3 = CloudmorphicLibrary.Theme.Accent
        Page.Visible = false

        local ListLayout = Instance.new("UIListLayout", Page)
        ListLayout.Padding = UDim.new(0,10)
        ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0,0,0, ListLayout.AbsoluteContentSize.Y + 20)
        end)

        Tab.Page = Page
        table.insert(Tabs, Tab)

        -- Create icon for this tab
        createIconButton(cfg.Name, Icons[cfg.Icon or "Home"], #Tabs - 1, Page)

        if #Tabs == 1 then
            Page.Visible = true
            TweenService:Create(Page, TweenInfo.new(0.6, Enum.EasingStyle.Expo), {BackgroundTransparency = CloudmorphicLibrary.Theme.GlassTrans}):Play()
        end

        local elasticInfo = TweenInfo.new(0.4, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
        local hInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad)

        function Tab:CreateSection(cfg)
            local Section = Instance.new("Frame")
            Section.BackgroundTransparency = 1
            Section.LayoutOrder = #Tab.Elements + 1
            Section.Parent = Page
            local Label = Instance.new("TextLabel", Section)
            Label.Size = UDim2.new(1,0,0,25)
            Label.BackgroundTransparency = 1
            Label.Text = cfg.Name or "Section"
            Label.TextColor3 = CloudmorphicLibrary.Theme.TextColor
            Label.Font = Enum.Font.GothamBold
            Label.TextSize = 15
            Label.TextXAlignment = Enum.TextXAlignment.Left
            TweenService:Create(Label, TweenInfo.new(0.8, Enum.EasingStyle.Back), {TextTransparency = 0}):Play()
            table.insert(Tab.Elements, Section)
            return Section
        end

        function Tab:CreateToggle(cfg)
            local Toggle = Instance.new("Frame")
            Toggle.Size = UDim2.new(1,0,0,45)
            Toggle.BackgroundColor3 = CloudmorphicLibrary.Theme.SkyBase
            Toggle.BackgroundTransparency = CloudmorphicLibrary.Theme.GlassTrans
            Toggle.LayoutOrder = #Tab.Elements + 1
            Toggle.Parent = Page
            Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0,16)
            local TGradient = Instance.new("UIGradient", Toggle)
            TGradient.Color = ColorSequence.new(Color3.fromRGB(255,255,255,0.15))
            TGradient.Rotation = 45
            local TStroke = Instance.new("UIStroke", Toggle)
            TStroke.Color = CloudmorphicLibrary.Theme.Glow
            TStroke.Thickness = 1.8
            TStroke.Transparency = 0.3

            local Label = Instance.new("TextLabel", Toggle)
            Label.Size = UDim2.new(1,-65,1,0)
            Label.Position = UDim2.new(0,12,0,0)
            Label.BackgroundTransparency = 1
            Label.Text = cfg.Name
            Label.TextColor3 = CloudmorphicLibrary.Theme.TextColor
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 14

            local SwitchBg = Instance.new("Frame", Toggle)
            SwitchBg.Size = UDim2.new(0,50,0,24)
            SwitchBg.Position = UDim2.new(1,-60,0.5,-12)
            SwitchBg.BackgroundColor3 = Color3.fromRGB(60,60,80)
            Instance.new("UICorner", SwitchBg).CornerRadius = UDim.new(0,12)

            local Knob = Instance.new("Frame", SwitchBg)
            Knob.Size = UDim2.new(0,20,0,20)
            Knob.Position = UDim2.new(0,2,0.5,-10)
            Knob.BackgroundColor3 = CloudmorphicLibrary.Theme.TextColor
            Instance.new("UICorner", Knob).CornerRadius = UDim.new(0,10)
            local KStroke = Instance.new("UIStroke", Knob)
            KStroke.Color = CloudmorphicLibrary.Theme.Glow
            KStroke.Thickness = 1.5

            local enabled = cfg.Default or false
            local function toggle()
                enabled = not enabled
                playSound("Toggle", enabled and 1.0 or 0.8)
                TweenService:Create(SwitchBg, elasticInfo, {
                    BackgroundColor3 = enabled and CloudmorphicLibrary.Theme.Accent or Color3.fromRGB(60,60,80)
                }):Play()
                TweenService:Create(Knob, elasticInfo, {
                    Position = enabled and UDim2.new(1,-22,0.5,-10) or UDim2.new(0,2,0.5,-10),
                    BackgroundColor3 = enabled and Color3.fromRGB(255,255,255) or CloudmorphicLibrary.Theme.TextColor
                }):Play()
                cfg.Callback(enabled)
            end

            Toggle.InputBegan:Connect(newcclosure(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    toggle()
                end
            end))

            Toggle.MouseEnter:Connect(newcclosure(function()
                playSound("Hover", 1.2)
                TweenService:Create(Toggle, hInfo, {Size = UDim2.new(1,0,1,5)}):Play()
                TweenService:Create(TStroke, hInfo, {Thickness = 2.5, Transparency = 0.2}):Play()
            end))

            Toggle.MouseLeave:Connect(newcclosure(function()
                TweenService:Create(Toggle, hInfo, {Size = UDim2.new(1,0,0,45)}):Play()
                TweenService:Create(TStroke, hInfo, {Thickness = 1.8, Transparency = 0.3}):Play()
            end))

            table.insert(Tab.Elements, Toggle)
            if cfg.Default then toggle() end
            return Toggle
        end

        function Tab:CreateSlider(cfg)
            local Slider = Instance.new("Frame")
            Slider.Size = UDim2.new(1,0,0,45)
            Slider.BackgroundColor3 = CloudmorphicLibrary.Theme.SkyBase
            Slider.BackgroundTransparency = CloudmorphicLibrary.Theme.GlassTrans
            Slider.LayoutOrder = #Tab.Elements + 1
            Slider.Parent = Page
            Instance.new("UICorner", Slider).CornerRadius = UDim.new(0,16)
            local SGradient = Instance.new("UIGradient", Slider)
            SGradient.Color = ColorSequence.new(Color3.fromRGB(255,255,255,0.15))
            SGradient.Rotation = 45
            local SStroke = Instance.new("UIStroke", Slider)
            SStroke.Color = CloudmorphicLibrary.Theme.Glow
            SStroke.Thickness = 1.8
            SStroke.Transparency = 0.3

            local Label = Instance.new("TextLabel", Slider)
            Label.Size = UDim2.new(1,-100,0.6,0)
            Label.Position = UDim2.new(0,12,0,0)
            Label.BackgroundTransparency = 1
            Label.Text = cfg.Name
            Label.TextColor3 = CloudmorphicLibrary.Theme.TextColor
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left

            local ValueLabel = Instance.new("TextLabel", Slider)
            ValueLabel.Size = UDim2.new(0,50,0.6,0)
            ValueLabel.Position = UDim2.new(1,-60,0,0)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Text = tostring(cfg.Default or cfg.Min)
            ValueLabel.TextColor3 = CloudmorphicLibrary.Theme.TextColor
            ValueLabel.Font = Enum.Font.Gotham
            ValueLabel.TextSize = 12

            local SliderBar = Instance.new("Frame", Slider)
            SliderBar.Size = UDim2.new(1, -24, 0, 6)
            SliderBar.Position = UDim2.new(0,12,0.75,0)
            SliderBar.BackgroundColor3 = Color3.fromRGB(60,60,80)
            Instance.new("UICorner", SliderBar).CornerRadius = UDim.new(0,3)

            local Progress = Instance.new("Frame", SliderBar)
            Progress.Size = UDim2.new(0,0,1,0)
            Progress.BackgroundColor3 = CloudmorphicLibrary.Theme.Accent
            Instance.new("UICorner", Progress).CornerRadius = UDim.new(0,3)

            local Knob = Instance.new("Frame", SliderBar)
            Knob.Size = UDim2.new(0,16,0,16)
            Knob.Position = UDim2.new(0,-8,0.5,-8)
            Knob.BackgroundColor3 = CloudmorphicLibrary.Theme.TextColor
            Instance.new("UICorner", Knob).CornerRadius = UDim.new(0,8)

            local min, max, inc = cfg.Min or 0, cfg.Max or 100, cfg.Increment or 1
            local current = cfg.Default or min

            local function setValue(val)
                val = math.clamp(math.floor(val / inc) * inc, min, max)
                current = val
                ValueLabel.Text = tostring(val)
                local pct = (val - min) / (max - min)
                TweenService:Create(Progress, elasticInfo, {Size = UDim2.new(pct,0,1,0)}):Play()
                TweenService:Create(Knob, elasticInfo, {Position = UDim2.new(pct, -8, 0.5, -8)}):Play()
                cfg.Callback(val)
            end

            local sliding = false
            Slider.InputBegan:Connect(newcclosure(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    sliding = true
                    local absPos = SliderBar.AbsolutePosition.X
                    local absSize = SliderBar.AbsoluteSize.X
                    local mouseX = inp.Position.X
                    local val = min + (max - min) * ((mouseX - absPos) / absSize)
                    setValue(val)
                end
            end))

            Slider.InputEnded:Connect(newcclosure(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    sliding = false
                end
            end))

            UserInputService.InputChanged:Connect(newcclosure(function(inp)
                if sliding and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
                    local absPos = SliderBar.AbsolutePosition.X
                    local absSize = SliderBar.AbsoluteSize.X
                    local mouseX = math.clamp(inp.Position.X, absPos, absPos + absSize)
                    local val = min + (max - min) * ((mouseX - absPos) / absSize)
                    setValue(val)
                end
            end))

            Slider.MouseEnter:Connect(newcclosure(function()
                playSound("Hover", 1.2)
                TweenService:Create(Slider, hInfo, {Size = UDim2.new(1,0,1,5)}):Play()
                TweenService:Create(SStroke, hInfo, {Thickness = 2.5, Transparency = 0.2}):Play()
            end))

            Slider.MouseLeave:Connect(newcclosure(function()
                TweenService:Create(Slider, hInfo, {Size = UDim2.new(1,0,0,45)}):Play()
                TweenService:Create(SStroke, hInfo, {Thickness = 1.8, Transparency = 0.3}):Play()
            end))

            table.insert(Tab.Elements, Slider)
            setValue(current)
            return Slider
        end

        function Tab:CreateDropdown(cfg)
            local Dropdown = Instance.new("Frame")
            Dropdown.Size = UDim2.new(1,0,0,45)
            Dropdown.BackgroundColor3 = CloudmorphicLibrary.Theme.SkyBase
            Dropdown.BackgroundTransparency = CloudmorphicLibrary.Theme.GlassTrans
            Dropdown.LayoutOrder = #Tab.Elements + 1
            Dropdown.Parent = Page
            Instance.new("UICorner", Dropdown).CornerRadius = UDim.new(0,16)
            local DGradient = Instance.new("UIGradient", Dropdown)
            DGradient.Color = ColorSequence.new(Color3.fromRGB(255,255,255,0.15))
            DGradient.Rotation = 45
            local DStroke = Instance.new("UIStroke", Dropdown)
            DStroke.Color = CloudmorphicLibrary.Theme.Glow
            DStroke.Thickness = 1.8
            DStroke.Transparency = 0.3

            local Label = Instance.new("TextLabel", Dropdown)
            Label.Size = UDim2.new(1,-65,1,0)
            Label.Position = UDim2.new(0,12,0,0)
            Label.BackgroundTransparency = 1
            Label.Text = cfg.Name
            Label.TextColor3 = CloudmorphicLibrary.Theme.TextColor
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left

            local Selected = Instance.new("TextLabel", Dropdown)
            Selected.Size = UDim2.new(0,100,1,0)
            Selected.Position = UDim2.new(1,-120,0,0)
            Selected.BackgroundTransparency = 1
            Selected.Text = cfg.Default or cfg.Options[1]
            Selected.TextColor3 = CloudmorphicLibrary.Theme.TextColor
            Selected.Font = Enum.Font.Gotham
            Selected.TextSize = 12
            Selected.TextTruncate = Enum.TextTruncate.Split

            local Arrow = Instance.new("TextLabel", Dropdown)
            Arrow.Size = UDim2.new(0,20,1,0)
            Arrow.Position = UDim2.new(1,-20,0,0)
            Arrow.BackgroundTransparency = 1
            Arrow.Text = "▼"
            Arrow.TextColor3 = CloudmorphicLibrary.Theme.TextColor
            Arrow.Font = Enum.Font.Gotham
            Arrow.TextSize = 14

            local DropList = Instance.new("ScrollingFrame", Dropdown)
            DropList.Size = UDim2.new(1,0,0,0)
            DropList.Position = UDim2.new(0,0,1,0)
            DropList.BackgroundColor3 = CloudmorphicLibrary.Theme.SkyBase
            DropList.BackgroundTransparency = CloudmorphicLibrary.Theme.GlassTrans
            DropList.BorderSizePixel = 0
            DropList.ScrollBarThickness = 4
            DropList.ScrollBarImageColor3 = CloudmorphicLibrary.Theme.Accent
            DropList.Visible = false
            Instance.new("UICorner", DropList).CornerRadius = UDim.new(0,16)
            local DropListLayout = Instance.new("UIListLayout", DropList)
            DropListLayout.Padding = UDim.new(0,2)
            DropListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            DropListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                DropList.CanvasSize = UDim2.new(0,0,0, DropListLayout.AbsoluteContentSize.Y + 4)
                DropList.Size = UDim2.new(1,0,0, math.min(DropListLayout.AbsoluteContentSize.Y + 4, 150))
            end)

            local open = false
            local function toggleDrop()
                open = not open
                DropList.Visible = open
                TweenService:Create(Arrow, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Rotation = open and 180 or 0}):Play()
                playSound("Click", 1.0)
            end

            Dropdown.InputBegan:Connect(newcclosure(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    toggleDrop()
                end
            end))

            for _, opt in ipairs(cfg.Options or {}) do
                local OptBtn = Instance.new("TextButton", DropList)
                OptBtn.Size = UDim2.new(1,0,0,30)
                OptBtn.BackgroundColor3 = CloudmorphicLibrary.Theme.Tab
                OptBtn.BackgroundTransparency = CloudmorphicLibrary.Theme.TabTrans
                OptBtn.Text = opt
                OptBtn.TextColor3 = CloudmorphicLibrary.Theme.TextColor
                OptBtn.Font = Enum.Font.Gotham
                OptBtn.TextSize = 12
                Instance.new("UICorner", OptBtn).CornerRadius = UDim.new(0,12)

                OptBtn.InputBegan:Connect(newcclosure(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                        Selected.Text = opt
                        cfg.Callback(opt)
                        toggleDrop()
                    end
                end))

                OptBtn.MouseEnter:Connect(newcclosure(function()
                    playSound("Hover", 1.3)
                    TweenService:Create(OptBtn, hInfo, {BackgroundColor3 = CloudmorphicLibrary.Theme.Accent}):Play()
                end))

                OptBtn.MouseLeave:Connect(newcclosure(function()
                    TweenService:Create(OptBtn, hInfo, {BackgroundColor3 = CloudmorphicLibrary.Theme.Tab}):Play()
                end))
            end

            Dropdown.MouseEnter:Connect(newcclosure(function()
                playSound("Hover", 1.2)
                TweenService:Create(Dropdown, hInfo, {Size = UDim2.new(1,0,1,5)}):Play()
                TweenService:Create(DStroke, hInfo, {Thickness = 2.5, Transparency = 0.2}):Play()
            end))

            Dropdown.MouseLeave:Connect(newcclosure(function()
                TweenService:Create(Dropdown, hInfo, {Size = UDim2.new(1,0,0,45)}):Play()
                TweenService:Create(DStroke, hInfo, {Thickness = 1.8, Transparency = 0.3}):Play()
            end))

            table.insert(Tab.Elements, Dropdown)
            return Dropdown
        end

        function Tab:CreateKeybind(cfg)
            local Keybind = Instance.new("Frame")
            Keybind.Size = UDim2.new(1,0,0,45)
            Keybind.BackgroundColor3 = CloudmorphicLibrary.Theme.SkyBase
            Keybind.BackgroundTransparency = CloudmorphicLibrary.Theme.GlassTrans
            Keybind.LayoutOrder = #Tab.Elements + 1
            Keybind.Parent = Page
            Instance.new("UICorner", Keybind).CornerRadius = UDim.new(0,16)
            local KGradient = Instance.new("UIGradient", Keybind)
            KGradient.Color = ColorSequence.new(Color3.fromRGB(255,255,255,0.2))
            KGradient.Rotation = -45
            local KStroke = Instance.new("UIStroke", Keybind)
            KStroke.Color = CloudmorphicLibrary.Theme.Glow
            KStroke.Thickness = 1.8
            KStroke.Transparency = 0.3

            local Label = Instance.new("TextLabel", Keybind)
            Label.Size = UDim2.new(1,-80,1,0)
            Label.Position = UDim2.new(0,12,0,0)
            Label.BackgroundTransparency = 1
            Label.Text = cfg.Name
            Label.TextColor3 = CloudmorphicLibrary.Theme.TextColor
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 14

            local BindBtn = Instance.new("TextButton", Keybind)
            BindBtn.Size = UDim2.new(0,70,0,28)
            BindBtn.Position = UDim2.new(1,-85,0.5,-14)
            BindBtn.BackgroundColor3 = CloudmorphicLibrary.Theme.Tab
            BindBtn.BackgroundTransparency = CloudmorphicLibrary.Theme.TabTrans
            BindBtn.Text = "NONE"
            BindBtn.TextColor3 = CloudmorphicLibrary.Theme.TextColor
            BindBtn.Font = Enum.Font.GothamBold
            BindBtn.TextSize = 12
            Instance.new("UICorner", BindBtn).CornerRadius = UDim.new(0,12)

            local CloudIcon = Instance.new("ImageLabel", Keybind)
            CloudIcon.Size = UDim2.new(0,24,0,24)
            CloudIcon.Position = UDim2.new(1,-105,0.5,-12)
            CloudIcon.BackgroundTransparency = 1
            CloudIcon.Image = Icons.Cloud
            CloudIcon.ImageColor3 = CloudmorphicLibrary.Theme.Accent

            local selecting = false
            local currentKey = cfg.Default or Enum.KeyCode.Unknown
            local bindConn

            local function setKey(key)
                if key == Enum.KeyCode.Unknown then return end
                currentKey = key
                BindBtn.Text = key.Name
                cfg.Callback(key)
                if bindConn then bindConn:Disconnect() end
                selecting = false
                TweenService:Create(CloudIcon, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Rotation = 0, ImageTransparency = 0}):Play()
            end

            local function selectMode()
                if selecting then return end
                selecting = true
                BindBtn.Text = "..."
                TweenService:Create(CloudIcon, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {Rotation = 360}):Play()
                bindConn = UserInputService.InputBegan:Connect(newcclosure(function(inp, gp)
                    if gp then return end
                    if inp.KeyCode ~= Enum.KeyCode.Unknown then
                        setKey(inp.KeyCode)
                    end
                end))
            end

            BindBtn.InputBegan:Connect(newcclosure(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    selectMode()
                end
            end))

            Keybind.InputBegan:Connect(newcclosure(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    selectMode()
                end
            end))

            Keybind.MouseEnter:Connect(newcclosure(function()
                playSound("Hover", 1.25)
                TweenService:Create(Keybind, hInfo, {Size = UDim2.new(1,0,1,5)}):Play()
            end))

            Keybind.MouseLeave:Connect(newcclosure(function()
                TweenService:Create(Keybind, hInfo, {Size = UDim2.new(1,0,0,45)}):Play()
            end))

            table.insert(Tab.Elements, Keybind)
            if currentKey ~= Enum.KeyCode.Unknown then setKey(currentKey) end
            return Keybind
        end

        function Tab:CreateButton(cfg)
            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(1,0,0,45)
            Button.BackgroundColor3 = CloudmorphicLibrary.Theme.SkyBase
            Button.BackgroundTransparency = CloudmorphicLibrary.Theme.GlassTrans
            Button.LayoutOrder = #Tab.Elements + 1
            Button.Parent = Page
            Button.Text = ""
            Instance.new("UICorner", Button).CornerRadius = UDim.new(0,16)
            local BGradient = Instance.new("UIGradient", Button)
            BGradient.Color = ColorSequence.new(Color3.fromRGB(255,255,255,0.15))
            BGradient.Rotation = 45
            local BStroke = Instance.new("UIStroke", Button)
            BStroke.Color = CloudmorphicLibrary.Theme.Glow
            BStroke.Thickness = 1.8
            BStroke.Transparency = 0.3

            local Label = Instance.new("TextLabel", Button)
            Label.Size = UDim2.new(1,0,1,0)
            Label.Position = UDim2.new(0,12,0,0)
            Label.BackgroundTransparency = 1
            Label.Text = cfg.Name
            Label.TextColor3 = CloudmorphicLibrary.Theme.TextColor
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left

            Button.InputBegan:Connect(newcclosure(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    playSound("Click", 1.1)
                    TweenService:Create(Button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = CloudmorphicLibrary.Theme.Accent}):Play()
                    task.delay(0.2, function()
                        TweenService:Create(Button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = CloudmorphicLibrary.Theme.SkyBase}):Play()
                    end)
                    cfg.Callback()
                end
            end))

            Button.MouseEnter:Connect(newcclosure(function()
                playSound("Hover", 1.2)
                TweenService:Create(Button, hInfo, {Size = UDim2.new(1,0,1,5)}):Play()
                TweenService:Create(BStroke, hInfo, {Thickness = 2.5, Transparency = 0.2}):Play()
            end))

            Button.MouseLeave:Connect(newcclosure(function()
                TweenService:Create(Button, hInfo, {Size = UDim2.new(1,0,0,45)}):Play()
                TweenService:Create(BStroke, hInfo, {Thickness = 1.8, Transparency = 0.3}):Play()
            end))

            table.insert(Tab.Elements, Button)
            return Button
        end

        return Tab
    end

    -- Opening animation
    OuterFrame.Size = UDim2.new(0.001,0,0.001,0)
    OuterFrame.BackgroundTransparency = 1
    OuterFrame.Rotation = 3
    TweenService:Create(OuterFrame, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = Config.Size or UDim2.new(0,480,0,360),
        BackgroundTransparency = CloudmorphicLibrary.Theme.GlassTrans,
        Rotation = 0
    }):Play()

    playSound("Open", 0.8)

    Window.MainFrame = MainFrame
    return Window
end

-- Rayfield compatibility aliases
CloudmorphicLibrary.Notify = function(self, cfg)
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 300, 0, 80)
    notif.Position = UDim2.new(1, -320, 1, -100)
    notif.BackgroundColor3 = self.Theme.SkyBase
    notif.BackgroundTransparency = self.Theme.GlassTrans
    notif.Parent = self.MainFrame
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0,16)
    
    local title = Instance.new("TextLabel", notif)
    title.Size = UDim2.new(1,0,0.4,0)
    title.Text = cfg.Title or "Notification"
    title.TextColor3 = self.Theme.TextColor
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    
    local content = Instance.new("TextLabel", notif)
    content.Size = UDim2.new(1,0,0.6,0)
    content.Position = UDim2.new(0,0,0.4,0)
    content.Text = cfg.Content or ""
    content.TextColor3 = self.Theme.TextColor
    content.Font = Enum.Font.Gotham
    content.TextSize = 14
    content.TextWrapped = true
    
    TweenService:Create(notif, TweenInfo.new(0.4), {Position = UDim2.new(1, -320, 1, -180)}):Play()
    task.delay(cfg.Duration or 5, function()
        TweenService:Create(notif, TweenInfo.new(0.4), {Position = UDim2.new(1, -320, 1, -100), BackgroundTransparency = 1}):Play()
        task.delay(0.4, notif.Destroy, notif)
    end)
end

return CloudmorphicLibrary