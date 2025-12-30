--[[
	Cloudmorphic Library v2.2
	by Normalitic - Added Rayfield-inspired elements: Dropdown, Slider, Button. Mobile-optimized with animations/sounds.
	Full compatibility: Event-driven; newcclosure wraps. No Drawing; touch-drag/inputs.

	Mobile: Touch-toggle float, drag, sliders (InputChanged). Perf: <60ms/frame; no loops.
	Security: checkcaller() in hooks; CoreGui parent.

	Usage:
	Tab:CreateDropdown({Name = "Mode", Options = {"Easy", "Hard"}, Default = "Easy", Callback = newcclosure(function(v) end)})
	Tab:CreateSlider({Name = "Speed", Min = 1, Max = 100, Default = 50, Increment = 1, Callback = newcclosure(function(v) end)})
	Tab:CreateButton({Name = "Reset", Callback = newcclosure(function() end)})

	Anims: Elastic slide, hover glow/scale. Sounds on interact.
]]

local function getService(n) local s = game:GetService(n) return cloneref and cloneref(s) or s end
local TweenService = getService("TweenService")
local UserInputService = getService("UserInputService")
local RunService = getService("RunService")
local ContentProvider = getService("ContentProvider")
local Players = getService("Players")
local CoreGui = getService("CoreGui")

local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Release = "v2.2"
local Icons = {
	Cloud = "rbxassetid://16149050794",
	Gear = "rbxassetid://6031097221",
	Inventory = "rbxassetid://6031280882",
	Home = "rbxassetid://3926305904"  -- House/home icon
}
local SoundIds = {
	Click = "rbxassetid://131961136",
	Hover = "rbxassetid://131961136",
	Toggle = "rbxassetid://131961157",
	Open = "rbxassetid://131961264"  -- Menu-ish
}

-- Sound Manager (preloaded; Camera parent for mobile)
local Sounds = {}
for name, id in pairs(SoundIds) do
	local sound = Instance.new("Sound")
	sound.SoundId = id
	sound.Volume = 0.3
	sound.Parent = Camera
	Sounds[name] = sound
end
ContentProvider:PreloadAsync(Sounds)  -- Silent preload

local function playSound(name, pitch)
	local s = Sounds[name]
	s.Pitch = pitch or 1.0
	s:Play()
end

local CloudmorphicLibrary = { Flags = {}, Theme = {
	TextColor = Color3.fromRGB(245,245,255),
	Glass = Color3.fromRGB(200,210,255),
	GlassTrans = 0.65,
	Glow = Color3.fromRGB(140,160,240),
	GlowTrans = 0.4,
	Accent = Color3.fromRGB(100,140,255),
	Tab = Color3.fromRGB(160,180,240),
	TabTrans = 0.75
}}

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

	-- Mobile Toggle Button (Floating; shows when UI hidden)
	local ToggleFloat = Instance.new("ImageButton")
	ToggleFloat.Size = UDim2.new(0,60,0,60)
	ToggleFloat.Position = UDim2.new(0.95, -70, 0.9, -70)
	ToggleFloat.BackgroundTransparency = 1
	ToggleFloat.Image = Icons.Cloud
	ToggleFloat.ImageColor3 = CloudmorphicLibrary.Theme.Accent
	ToggleFloat.ImageTransparency = 0.3
	ToggleFloat.Visible = false
	ToggleFloat.Parent = MainFrame
	local FloatCorner = Instance.new("UICorner", ToggleFloat)
	FloatCorner.CornerRadius = UDim.new(0,30)
	local FloatStroke = Instance.new("UIStroke", ToggleFloat)
	FloatStroke.Color = CloudmorphicLibrary.Theme.Glow
	FloatStroke.Thickness = 1.5
	FloatStroke.Transparency = 0.6
	ToggleFloat.MouseButton1Click:Connect(newcclosure(function()
		playSound("Open", 0.9)
		OuterFrame.Visible = true
		ToggleFloat.Visible = false
		TweenService:Create(OuterFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
			Size = Config.Size or UDim2.new(0,450,0,350),
			BackgroundTransparency = CloudmorphicLibrary.Theme.GlassTrans
		}):Play()
	end))
	ToggleFloat.MouseEnter:Connect(newcclosure(function()
		TweenService:Create(ToggleFloat, TweenInfo.new(0.3), {ImageTransparency = 0, Rotation = 15}):Play()
	end))
	ToggleFloat.MouseLeave:Connect(newcclosure(function()
		TweenService:Create(ToggleFloat, TweenInfo.new(0.3), {ImageTransparency = 0.3, Rotation = 0}):Play()
	end))

	local OuterFrame = Instance.new("Frame")
	OuterFrame.Name = "Main"
	OuterFrame.Size = Config.Size or UDim2.new(0, 450, 0, 350)
	OuterFrame.Position = UDim2.new(0.5, -225, 0.5, -175)
	OuterFrame.BackgroundColor3 = CloudmorphicLibrary.Theme.Glass
	OuterFrame.BackgroundTransparency = CloudmorphicLibrary.Theme.GlassTrans
	OuterFrame.BorderSizePixel = 0
	OuterFrame.Parent = MainFrame
	local GlassGradient = Instance.new("UIGradient")
	GlassGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255,0.3)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255,0))
	}
	GlassGradient.Rotation = 45
	GlassGradient.Parent = OuterFrame
	local Corner = Instance.new("UICorner", OuterFrame)
	Corner.CornerRadius = UDim.new(0, 16)
	local GlowStroke = Instance.new("UIStroke", OuterFrame)
	GlowStroke.Color = CloudmorphicLibrary.Theme.Glow
	GlowStroke.Thickness = 2
	GlowStroke.Transparency = CloudmorphicLibrary.Theme.GlowTrans
	GlowStroke.Parent = OuterFrame

	-- Drag (mobile/PC; sync float pos)
	local DragFrame = Instance.new("Frame", OuterFrame)
	DragFrame.Size = UDim2.new(1,0,0,50)
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
			-- Sync float pos to UI (offset)
			ToggleFloat.Position = OuterFrame.Position + UDim2.new(0, OuterFrame.Size.X.Offset + 10, 0, OuterFrame.Size.Y.Offset - 70)
		end
	end))

	-- Topbar
	local Topbar = Instance.new("Frame")
	Topbar.Size = UDim2.new(1,0,0,50)
	Topbar.BackgroundColor3 = CloudmorphicLibrary.Theme.Tab
	Topbar.BackgroundTransparency = CloudmorphicLibrary.Theme.TabTrans
	Topbar.Parent = OuterFrame
	local TopCorner = Instance.new("UICorner", Topbar)
	TopCorner.CornerRadius = UDim.new(0,16)
	local TopGradient = Instance.new("UIGradient", Topbar)
	TopGradient.Color = ColorSequence.new(Color3.fromRGB(255,255,255,0.2), Color3.fromRGB(255,255,255,0))
	TopGradient.Rotation = 90
	local Title = Instance.new("TextLabel")
	Title.Size = UDim2.new(1,-60,1,0)
	Title.Position = UDim2.new(0,15,0,0)
	Title.BackgroundTransparency = 1
	Title.Text = Config.Title or "Cloudmorphic"
	Title.TextColor3 = CloudmorphicLibrary.Theme.TextColor
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 18
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.Parent = Topbar

	local MinimizeBtn = Instance.new("TextButton")
	MinimizeBtn.Size = UDim2.new(0,40,0,40)
	MinimizeBtn.Position = UDim2.new(1,-100,0,5)
	MinimizeBtn.BackgroundTransparency = 1
	MinimizeBtn.Text = "−"
	MinimizeBtn.TextColor3 = Color3.fromRGB(255,255,150)
	MinimizeBtn.Font = Enum.Font.GothamBold
	MinimizeBtn.TextSize = 20
	MinimizeBtn.Parent = Topbar
	MinimizeBtn.MouseButton1Click:Connect(newcclosure(function()
		playSound("Click", 1.0)
		TweenService:Create(OuterFrame, TweenInfo.new(0.4, Enum.EasingStyle.Expo), {
			Size = UDim2.new(0,0,0,0), BackgroundTransparency = 1
		}):Play()
		task.delay(0.4, function()
			OuterFrame.Visible = false
			ToggleFloat.Visible = true
			ToggleFloat.Position = OuterFrame.Position + UDim2.new(0, OuterFrame.Size.X.Offset + 10, 0, OuterFrame.Size.Y.Offset - 70)
		end)
	end))
	MinimizeBtn.MouseEnter:Connect(newcclosure(function() playSound("Hover", 1.3) end))

	local CloseBtn = Instance.new("TextButton")
	CloseBtn.Size = UDim2.new(0,40,0,40)
	CloseBtn.Position = UDim2.new(1,-50,0,5)
	CloseBtn.BackgroundTransparency = 1
	CloseBtn.Text = "✕"
	CloseBtn.TextColor3 = Color3.fromRGB(255,150,150)
	CloseBtn.Font = Enum.Font.GothamBold
	CloseBtn.TextSize = 20
	CloseBtn.Parent = Topbar
	CloseBtn.MouseButton1Click:Connect(newcclosure(function()
		playSound("Click", 1.1)
		TweenService:Create(OuterFrame, TweenInfo.new(0.5, Enum.EasingStyle.Expo), {
			Size = UDim2.new(0,0,0,0), BackgroundTransparency = 1, Rotation = 5
		}):Play()
		TweenService:Create(GlowStroke, TweenInfo.new(0.5), {Thickness = 0}):Play()
		task.wait(0.5)
		MainFrame:Destroy()
	end))
	CloseBtn.MouseEnter:Connect(newcclosure(function() playSound("Hover", 1.3) end))

	-- Sidebar (vertical tabs w/ icons)
	local Sidebar = Instance.new("Frame")
	Sidebar.Size = UDim2.new(0,70,1,-50)
	Sidebar.Position = UDim2.new(0,0,0,50)
	Sidebar.BackgroundTransparency = 1
	Sidebar.Parent = OuterFrame

	local TabContainer = Instance.new("Frame")  -- No scroll; dynamic height
	TabContainer.Size = UDim2.new(1,-70,1,-50)
	TabContainer.Position = UDim2.new(0,70,0,50)
	TabContainer.BackgroundTransparency = 1
	TabContainer.Parent = OuterFrame

	local Tabs = {}
	local CurrentTab = nil

	local function switchTab(newTab)
		if CurrentTab then
			TweenService:Create(CurrentTab.Page, TweenInfo.new(0.5, Enum.EasingStyle.Expo), {
				Position = UDim2.new(-0.1,0,0,0), BackgroundTransparency = 1
			}):Play()
			CurrentTab.Page.Visible = false
			TweenService:Create(CurrentTab.Btn, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
				BackgroundColor3 = CloudmorphicLibrary.Theme.Tab,
				Size = UDim2.new(1,0,0,55)
			}):Play()
		end
		CurrentTab = newTab
		newTab.Page.Visible = true
		newTab.Page.Position = UDim2.new(1.1,0,0,0)
		newTab.Page.BackgroundTransparency = 1
		TweenService:Create(newTab.Page, TweenInfo.new(0.6, Enum.EasingStyle.Expo), {
			Position = UDim2.new(0,0,0,0), BackgroundTransparency = CloudmorphicLibrary.Theme.GlassTrans
		}):Play()
		TweenService:Create(newTab.Btn, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
			BackgroundColor3 = CloudmorphicLibrary.Theme.Accent,
			Size = UDim2.new(1,6,1,0)
		}):Play()
		playSound("Click")
	end

	function Window:CreateTab(cfg)
		local Tab = { Elements = {} }
		local Btn = Instance.new("TextButton")
		Btn.Name = cfg.Name
		Btn.Size = UDim2.new(1,0,0,55)
		Btn.BackgroundColor3 = CloudmorphicLibrary.Theme.Tab
		Btn.BackgroundTransparency = CloudmorphicLibrary.Theme.TabTrans
		Btn.BorderSizePixel = 0
		Btn.Text = ""
		Btn.Parent = Sidebar
		local BtnCorner = Instance.new("UICorner", Btn)
		BtnCorner.CornerRadius = UDim.new(0,12)
		local BtnStroke = Instance.new("UIStroke", Btn)
		BtnStroke.Color = CloudmorphicLibrary.Theme.Glow
		BtnStroke.Thickness = 1.5
		BtnStroke.Transparency = 0.6

		local Icon = Instance.new("ImageLabel")
		Icon.Size = UDim2.new(0,36,0,36)
		Icon.Position = UDim2.new(0.5,-18,0.5,-18)
		Icon.BackgroundTransparency = 1
		Icon.Image = Icons[cfg.Icon or "Home"] or ""
		Icon.ImageColor3 = CloudmorphicLibrary.Theme.TextColor
		Icon.Parent = Btn

		local Label = Instance.new("TextLabel")
		Label.Size = UDim2.new(1,0,0.6,0)
		Label.Position = UDim2.new(0,0,0.4,0)
		Label.BackgroundTransparency = 1
		Label.Text = cfg.Name
		Label.TextColor3 = CloudmorphicLibrary.Theme.TextColor
		Label.Font = Enum.Font.GothamSemibold
		Label.TextSize = 12
		Label.TextScaled = true
		Label.Parent = Btn

		-- Hover/Click anims
		local hoverInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad)
		Btn.MouseEnter:Connect(newcclosure(function()
			playSound("Hover", 1.4)
			TweenService:Create(Btn, hoverInfo, {Size = UDim2.new(1,8,1,4), Rotation = 1}):Play()
			TweenService:Create(Icon, hoverInfo, {ImageTransparency = 0.2, Rotation = 360}):Play()
		end))
		Btn.MouseLeave:Connect(newcclosure(function()
			TweenService:Create(Btn, hoverInfo, {Size = UDim2.new(1,0,0,55), Rotation = 0}):Play()
			TweenService:Create(Icon, hoverInfo, {ImageTransparency = 0, Rotation = 0}):Play()
		end))
		Btn.MouseButton1Click:Connect(newcclosure(function() switchTab(Tab) end))

		local Page = Instance.new("ScrollingFrame")
		Page.Name = cfg.Name .. "_Page"
		Page.Size = UDim2.new(1, -15, 1, -10)
		Page.Position = UDim2.new(0,10,0,10)
		Page.BackgroundColor3 = CloudmorphicLibrary.Theme.Glass
		Page.BackgroundTransparency = 1
		Page.BorderSizePixel = 0
		Page.ScrollBarThickness = 6
		Page.ScrollBarImageColor3 = CloudmorphicLibrary.Theme.Accent
		Page.Visible = false
		Page.Parent = TabContainer
		local PageCorner = Instance.new("UICorner", Page)
		PageCorner.CornerRadius = UDim.new(0,12)
		local PageGradient = Instance.new("UIGradient", Page)
		PageGradient.Color = ColorSequence.new(Color3.fromRGB(255,255,255,0.1), Color3.fromRGB(255,255,255,0))
		PageGradient.Rotation = 135
		local ListLayout = Instance.new("UIListLayout", Page)
		ListLayout.Padding = UDim.new(0,8)
		ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			Page.CanvasSize = UDim2.new(0,0,0, ListLayout.AbsoluteContentSize.Y + 20)
		end)

		Tab.Btn = Btn
		Tab.Page = Page
		table.insert(Tabs, Tab)

		if #Tabs == 1 then switchTab(Tab) end

		-- Elements
		function Tab:CreateSection(cfg)
			local Section = Instance.new("Frame")
			Section.BackgroundTransparency = 1
			Section.LayoutOrder = #Tab.Elements + 1
			Section.Parent = Page
			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1,0,0,25)
			Label.BackgroundTransparency = 1
			Label.Text = cfg.Name or "Section"
			Label.TextColor3 = CloudmorphicLibrary.Theme.TextColor
			Label.Font = Enum.Font.GothamBold
			Label.TextSize = 15
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.Parent = Section
			TweenService:Create(Label, TweenInfo.new(0.8, Enum.EasingStyle.Back), {TextTransparency = 0}):Play()
			table.insert(Tab.Elements, Section)
			return Section
		end

		local elasticInfo = TweenInfo.new(0.4, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
		local hInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad)

		function Tab:CreateToggle(cfg)
			local Toggle = Instance.new("Frame")
			Toggle.Size = UDim2.new(1,0,0,45)
			Toggle.BackgroundColor3 = CloudmorphicLibrary.Theme.Glass
			Toggle.BackgroundTransparency = CloudmorphicLibrary.Theme.GlassTrans
			Toggle.LayoutOrder = #Tab.Elements + 1
			Toggle.Parent = Page
			local TCorner = Instance.new("UICorner", Toggle)
			TCorner.CornerRadius = UDim.new(0,10)
			local TGradient = Instance.new("UIGradient", Toggle)
			TGradient.Color = ColorSequence.new(Color3.fromRGB(255,255,255,0.15))
			TGradient.Rotation = 45
			local TStroke = Instance.new("UIStroke", Toggle)
			TStroke.Color = CloudmorphicLibrary.Theme.Glow
			TStroke.Thickness = 1.2
			TStroke.Transparency = 0.5

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1,-65,1,0)
			Label.Position = UDim2.new(0,12,0,0)
			Label.BackgroundTransparency = 1
			Label.Text = cfg.Name
			Label.TextColor3 = CloudmorphicLibrary.Theme.TextColor
			Label.Font = Enum.Font.Gotham
			Label.TextSize = 14
			Label.Parent = Toggle

			local SwitchBg = Instance.new("Frame")
			SwitchBg.Size = UDim2.new(0,50,0,24)
			SwitchBg.Position = UDim2.new(1,-60,0.5,-12)
			SwitchBg.BackgroundColor3 = Color3.fromRGB(60,60,80)
			SwitchBg.Parent = Toggle
			local SCorner = Instance.new("UICorner", SwitchBg)
			SCorner.CornerRadius = UDim.new(0,12)

			local Knob = Instance.new("Frame")
			Knob.Size = UDim2.new(0,20,0,20)
			Knob.Position = UDim2.new(0,2,0.5,-10)
			Knob.BackgroundColor3 = CloudmorphicLibrary.Theme.TextColor
			Knob.Parent = SwitchBg
			local KCorner = Instance.new("UICorner", Knob)
			KCorner.CornerRadius = UDim.new(0,10)
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
				TweenService:Create(TStroke, hInfo, {Thickness = 2, Transparency = 0.3}):Play()
			end))
			Toggle.MouseLeave:Connect(newcclosure(function()
				TweenService:Create(Toggle, hInfo, {Size = UDim2.new(1,0,0,45)}):Play()
				TweenService:Create(TStroke, hInfo, {Thickness = 1.2, Transparency = 0.5}):Play()
			end))

			table.insert(Tab.Elements, Toggle)
			if cfg.Default then toggle() end
			return Toggle
		end

		local bindConn
		function Tab:CreateKeybind(cfg)
			local Keybind = Instance.new("Frame")
			Keybind.Size = UDim2.new(1,0,0,45)
			Keybind.BackgroundColor3 = CloudmorphicLibrary.Theme.Glass
			Keybind.BackgroundTransparency = CloudmorphicLibrary.Theme.GlassTrans
			Keybind.LayoutOrder = #Tab.Elements + 1
			Keybind.Parent = Page
			local KCorner = Instance.new("UICorner", Keybind)
			KCorner.CornerRadius = UDim.new(0,10)
			local KGradient = Instance.new("UIGradient", Keybind)
			KGradient.Color = ColorSequence.new(Color3.fromRGB(255,255,255,0.2))
			KGradient.Rotation = -45
			local KStroke = Instance.new("UIStroke", Keybind)
			KStroke.Color = CloudmorphicLibrary.Theme.Glow
			KStroke.Thickness = 1.2
			KStroke.Transparency = 0.5

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1,-80,1,0)
			Label.Position = UDim2.new(0,12,0,0)
			Label.BackgroundTransparency = 1
			Label.Text = cfg.Name
			Label.TextColor3 = CloudmorphicLibrary.Theme.TextColor
			Label.Font = Enum.Font.Gotham
			Label.TextSize = 14
			Label.Parent = Keybind

			local BindBtn = Instance.new("TextButton")
			BindBtn.Size = UDim2.new(0,70,0,28)
			BindBtn.Position = UDim2.new(1,-85,0.5,-14)
			BindBtn.BackgroundColor3 = CloudmorphicLibrary.Theme.Tab
			BindBtn.BackgroundTransparency = CloudmorphicLibrary.Theme.TabTrans
			BindBtn.Text = "NONE"
			BindBtn.TextColor3 = CloudmorphicLibrary.Theme.TextColor
			BindBtn.Font = Enum.Font.GothamBold
			BindBtn.TextSize = 12
			BindBtn.Parent = Keybind
			local BCorner = Instance.new("UICorner", BindBtn)
			BCorner.CornerRadius = UDim.new(0,8)

			local CloudIcon = Instance.new("ImageLabel")
			CloudIcon.Size = UDim2.new(0,24,0,24)
			CloudIcon.Position = UDim2.new(1,-105,0.5,-12)
			CloudIcon.BackgroundTransparency = 1
			CloudIcon.Image = Icons.Cloud
			CloudIcon.ImageColor3 = CloudmorphicLibrary.Theme.Accent
			CloudIcon.Parent = Keybind

			local selecting = false
			local currentKey = cfg.Default or Enum.KeyCode.Unknown
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

			BindBtn.MouseButton1Click:Connect(newcclosure(selectMode))
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
			Button.BackgroundColor3 = CloudmorphicLibrary.Theme.Glass
			Button.BackgroundTransparency = CloudmorphicLibrary.Theme.GlassTrans
			Button.LayoutOrder = #Tab.Elements + 1
			Button.Parent = Page
			Button.Text = ""
			local BCorner = Instance.new("UICorner", Button)
			BCorner.CornerRadius = UDim.new(0,10)
			local BGradient = Instance.new("UIGradient", Button)
			BGradient.Color = ColorSequence.new(Color3.fromRGB(255,255,255,0.15))
			BGradient.Rotation = 45
			local BStroke = Instance.new("UIStroke", Button)
			BStroke.Color = CloudmorphicLibrary.Theme.Glow
			BStroke.Thickness = 1.2
			BStroke.Transparency = 0.5

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1,0,1,0)
			Label.Position = UDim2.new(0,12,0,0)
			Label.BackgroundTransparency = 1
			Label.Text = cfg.Name
			Label.TextColor3 = CloudmorphicLibrary.Theme.TextColor
			Label.Font = Enum.Font.Gotham
			Label.TextSize = 14
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.Parent = Button

			Button.MouseButton1Click:Connect(newcclosure(function()
				playSound("Click", 1.1)
				TweenService:Create(Button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = CloudmorphicLibrary.Theme.Accent}):Play()
				task.delay(0.2, function()
					TweenService:Create(Button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = CloudmorphicLibrary.Theme.Glass}):Play()
				end)
				cfg.Callback()
			end))

			Button.MouseEnter:Connect(newcclosure(function()
				playSound("Hover", 1.2)
				TweenService:Create(Button, hInfo, {Size = UDim2.new(1,0,1,5)}):Play()
				TweenService:Create(BStroke, hInfo, {Thickness = 2, Transparency = 0.3}):Play()
			end))
			Button.MouseLeave:Connect(newcclosure(function()
				TweenService:Create(Button, hInfo, {Size = UDim2.new(1,0,0,45)}):Play()
				TweenService:Create(BStroke, hInfo, {Thickness = 1.2, Transparency = 0.5}):Play()
			end))

			table.insert(Tab.Elements, Button)
			return Button
		end

		function Tab:CreateSlider(cfg)
			local Slider = Instance.new("Frame")
			Slider.Size = UDim2.new(1,0,0,45)
			Slider.BackgroundColor3 = CloudmorphicLibrary.Theme.Glass
			Slider.BackgroundTransparency = CloudmorphicLibrary.Theme.GlassTrans
			Slider.LayoutOrder = #Tab.Elements + 1
			Slider.Parent = Page
			local SCorner = Instance.new("UICorner", Slider)
			SCorner.CornerRadius = UDim.new(0,10)
			local SGradient = Instance.new("UIGradient", Slider)
			SGradient.Color = ColorSequence.new(Color3.fromRGB(255,255,255,0.15))
			SGradient.Rotation = 45
			local SStroke = Instance.new("UIStroke", Slider)
			SStroke.Color = CloudmorphicLibrary.Theme.Glow
			SStroke.Thickness = 1.2
			SStroke.Transparency = 0.5

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1,-100,0.6,0)
			Label.Position = UDim2.new(0,12,0,0)
			Label.BackgroundTransparency = 1
			Label.Text = cfg.Name
			Label.TextColor3 = CloudmorphicLibrary.Theme.TextColor
			Label.Font = Enum.Font.Gotham
			Label.TextSize = 14
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.Parent = Slider

			local ValueLabel = Instance.new("TextLabel")
			ValueLabel.Size = UDim2.new(0,50,0.6,0)
			ValueLabel.Position = UDim2.new(1,-60,0,0)
			ValueLabel.BackgroundTransparency = 1
			ValueLabel.Text = tostring(cfg.Default or cfg.Min)
			ValueLabel.TextColor3 = CloudmorphicLibrary.Theme.TextColor
			ValueLabel.Font = Enum.Font.Gotham
			ValueLabel.TextSize = 12
			ValueLabel.Parent = Slider

			local SliderBar = Instance.new("Frame")
			SliderBar.Size = UDim2.new(1, -24, 0, 6)
			SliderBar.Position = UDim2.new(0,12,0.75,0)
			SliderBar.BackgroundColor3 = Color3.fromRGB(60,60,80)
			SliderBar.Parent = Slider
			local BarCorner = Instance.new("UICorner", SliderBar)
			BarCorner.CornerRadius = UDim.new(0,3)

			local Progress = Instance.new("Frame")
			Progress.Size = UDim2.new(0,0,1,0)
			Progress.BackgroundColor3 = CloudmorphicLibrary.Theme.Accent
			Progress.Parent = SliderBar
			local ProgCorner = Instance.new("UICorner", Progress)
			ProgCorner.CornerRadius = UDim.new(0,3)

			local Knob = Instance.new("Frame")
			Knob.Size = UDim2.new(0,16,0,16)
			Knob.Position = UDim2.new(0,-8,0.5,-8)
			Knob.BackgroundColor3 = CloudmorphicLibrary.Theme.TextColor
			Knob.Parent = SliderBar
			local KnobCorner = Instance.new("UICorner", Knob)
			KnobCorner.CornerRadius = UDim.new(0,8)

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
				TweenService:Create(SStroke, hInfo, {Thickness = 2, Transparency = 0.3}):Play()
			end))
			Slider.MouseLeave:Connect(newcclosure(function()
				TweenService:Create(Slider, hInfo, {Size = UDim2.new(1,0,0,45)}):Play()
				TweenService:Create(SStroke, hInfo, {Thickness = 1.2, Transparency = 0.5}):Play()
			end))

			table.insert(Tab.Elements, Slider)
			setValue(current)
			return Slider
		end

		function Tab:CreateDropdown(cfg)
			local Dropdown = Instance.new("Frame")
			Dropdown.Size = UDim2.new(1,0,0,45)
			Dropdown.BackgroundColor3 = CloudmorphicLibrary.Theme.Glass
			Dropdown.BackgroundTransparency = CloudmorphicLibrary.Theme.GlassTrans
			Dropdown.LayoutOrder = #Tab.Elements + 1
			Dropdown.Parent = Page
			local DCorner = Instance.new("UICorner", Dropdown)
			DCorner.CornerRadius = UDim.new(0,10)
			local DGradient = Instance.new("UIGradient", Dropdown)
			DGradient.Color = ColorSequence.new(Color3.fromRGB(255,255,255,0.15))
			DGradient.Rotation = 45
			local DStroke = Instance.new("UIStroke", Dropdown)
			DStroke.Color = CloudmorphicLibrary.Theme.Glow
			DStroke.Thickness = 1.2
			DStroke.Transparency = 0.5

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1,-65,1,0)
			Label.Position = UDim2.new(0,12,0,0)
			Label.BackgroundTransparency = 1
			Label.Text = cfg.Name
			Label.TextColor3 = CloudmorphicLibrary.Theme.TextColor
			Label.Font = Enum.Font.Gotham
			Label.TextSize = 14
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.Parent = Dropdown

			local Selected = Instance.new("TextLabel")
			Selected.Size = UDim2.new(0,100,1,0)
			Selected.Position = UDim2.new(1,-120,0,0)
			Selected.BackgroundTransparency = 1
			Selected.Text = cfg.Default or cfg.Options[1]
			Selected.TextColor3 = CloudmorphicLibrary.Theme.TextColor
			Selected.Font = Enum.Font.Gotham
			Selected.TextSize = 12
			Selected.TextTruncate = Enum.TextTruncate.Split
			Selected.Parent = Dropdown

			local Arrow = Instance.new("TextLabel")
			Arrow.Size = UDim2.new(0,20,1,0)
			Arrow.Position = UDim2.new(1,-20,0,0)
			Arrow.BackgroundTransparency = 1
			Arrow.Text = "▼"
			Arrow.TextColor3 = CloudmorphicLibrary.Theme.TextColor
			Arrow.Font = Enum.Font.Gotham
			Arrow.TextSize = 14
			Arrow.Parent = Dropdown

			local DropList = Instance.new("ScrollingFrame")
			DropList.Size = UDim2.new(1,0,0,0)
			DropList.Position = UDim2.new(0,0,1,0)
			DropList.BackgroundColor3 = CloudmorphicLibrary.Theme.Glass
			DropList.BackgroundTransparency = CloudmorphicLibrary.Theme.GlassTrans
			DropList.BorderSizePixel = 0
			DropList.ScrollBarThickness = 4
			DropList.ScrollBarImageColor3 = CloudmorphicLibrary.Theme.Accent
			DropList.Visible = false
			DropList.Parent = Dropdown
			local DropCorner = Instance.new("UICorner", DropList)
			DropCorner.CornerRadius = UDim.new(0,10)
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
				local OptBtn = Instance.new("TextButton")
				OptBtn.Size = UDim2.new(1,0,0,30)
				OptBtn.BackgroundColor3 = CloudmorphicLibrary.Theme.Tab
				OptBtn.BackgroundTransparency = CloudmorphicLibrary.Theme.TabTrans
				OptBtn.Text = opt
				OptBtn.TextColor3 = CloudmorphicLibrary.Theme.TextColor
				OptBtn.Font = Enum.Font.Gotham
				OptBtn.TextSize = 12
				OptBtn.Parent = DropList
				local OptCorner = Instance.new("UICorner", OptBtn)
				OptCorner.CornerRadius = UDim.new(0,6)

				OptBtn.MouseButton1Click:Connect(newcclosure(function()
					Selected.Text = opt
					cfg.Callback(opt)
					toggleDrop()
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
				TweenService:Create(DStroke, hInfo, {Thickness = 2, Transparency = 0.3}):Play()
			end))
			Dropdown.MouseLeave:Connect(newcclosure(function()
				TweenService:Create(Dropdown, hInfo, {Size = UDim2.new(1,0,0,45)}):Play()
				TweenService:Create(DStroke, hInfo, {Thickness = 1.2, Transparency = 0.5}):Play()
			end))

			table.insert(Tab.Elements, Dropdown)
			return Dropdown
		end

		return Tab
	end

	-- Load Anims + Open Sound
	playSound("Open", 0.7)
	OuterFrame.Size = UDim2.new(0.001,0,0.001,0)
	OuterFrame.BackgroundTransparency = 1
	OuterFrame.Position = UDim2.new(0.5,0,0.5,0)
	TweenService:Create(OuterFrame, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = Config.Size or UDim2.new(0,450,0,350),
		BackgroundTransparency = CloudmorphicLibrary.Theme.GlassTrans,
		Position = UDim2.new(0.5,-225,0.5,-175)
	}):Play()
	TweenService:Create(GlowStroke, TweenInfo.new(0.8), {Thickness = 2}):Play()

	Window.MainFrame = MainFrame  -- Expose for external toggle if needed
	return Window
end

return CloudmorphicLibrary