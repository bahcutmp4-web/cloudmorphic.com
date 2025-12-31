--[[
    ☁️ CLOUD LIBRARY V4 - REFLECTIVE GLASS EDITION
    Style: Floating Islands (Deconstructed UI)
    Texture: Faux-Reflective Frosted Glass
    Animations: Spring-based
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Library = {}
local UI = nil

--// 1. UNIVERSAL PARENTING
local function GetSafeGuiRoot()
	local success, result = pcall(function() return gethui() end)
	if success and result then return result end
	success, result = pcall(function() return game:GetService("CoreGui") end)
	if success and result then return result end
	return LocalPlayer:WaitForChild("PlayerGui")
end

--// 2. THEME & GLASS SHADERS
local THEME = {
	GlassColor = Color3.fromRGB(220, 240, 255), -- Icy White/Blue
	GlassTransparency = 0.6, -- See-through
	ReflectionTransparency = 0.5, -- The "Shiny" part
	StrokeColor = Color3.fromRGB(255, 255, 255),
	StrokeTransparency = 0.2,
	AccentColor = Color3.fromRGB(164, 218, 255), 
	TextColor = Color3.fromRGB(255, 255, 255),
	Font = Enum.Font.GothamMedium,
	FontBold = Enum.Font.GothamBold
}

--// 3. UTILITIES
local function AddGlassEffect(Frame)
	-- 1. The Glass Shape
	Frame.BackgroundColor3 = THEME.GlassColor
	Frame.BackgroundTransparency = THEME.GlassTransparency
	Frame.BorderSizePixel = 0
	
	-- 2. The Rounded Corners (Squircle)
	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 16)
	Corner.Parent = Frame
	
	-- 3. The "Edge Light" (Stroke)
	local Stroke = Instance.new("UIStroke")
	Stroke.Color = THEME.StrokeColor
	Stroke.Thickness = 1.5
	Stroke.Transparency = THEME.StrokeTransparency
	Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	Stroke.Parent = Frame
	
	-- 4. The "Reflection" (Gradient)
	local Gradient = Instance.new("UIGradient")
	Gradient.Rotation = 45
	Gradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
		ColorSequenceKeypoint.new(1, Color3.new(1,1,1))
	}
	-- This creates a "shine" across the glass
	Gradient.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.4),   -- Shiny top left
		NumberSequenceKeypoint.new(0.4, 0.8), -- Clear middle
		NumberSequenceKeypoint.new(1, 0.6)    -- Hazy bottom right
	}
	Gradient.Parent = Frame
end

local function MakeDraggable(Trigger, Object)
	local Dragging, DragInput, DragStart, StartPosition
	Trigger.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			Dragging = true
			DragStart = input.Position
			StartPosition = Object.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then Dragging = false end
			end)
		end
	end)
	Trigger.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then DragInput = input end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == DragInput and Dragging then
			local Delta = input.Position - DragStart
			-- Using Tween for smooth dragging
			TweenService:Create(Object, TweenInfo.new(0.05), {
				Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
			}):Play()
		end
	end)
end

function Library:CreateWindow(Settings)
	-- Cleanup
	if UI then UI:Destroy() end
	for _,v in pairs(GetSafeGuiRoot():GetChildren()) do if v.Name == "ReflectiveCloud" then v:Destroy() end end

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "ReflectiveCloud"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.IgnoreGuiInset = true
	ScreenGui.Parent = GetSafeGuiRoot()
	UI = ScreenGui

	--// INVISIBLE CONTAINER (Holds the floating islands together)
	local Container = Instance.new("Frame")
	Container.Name = "Container"
	Container.Size = UDim2.new(0, 650, 0, 400)
	Container.Position = UDim2.new(0.5, 0, 0.5, 0)
	Container.AnchorPoint = Vector2.new(0.5, 0.5)
	Container.BackgroundTransparency = 1
	Container.Parent = ScreenGui

	--// 1. FLOATING TITLE BAR (Top "Island")
	local TitleBar = Instance.new("Frame")
	TitleBar.Name = "TitleBar"
	TitleBar.Size = UDim2.new(1, 0, 0, 40) -- Full width of container
	TitleBar.Position = UDim2.new(0, 0, 0, -50) -- Floats ABOVE the content
	AddGlassEffect(TitleBar)
	TitleBar.Parent = Container

	local TitleText = Instance.new("TextLabel")
	TitleText.Text = Settings.Name or "Cloud Library"
	TitleText.Font = THEME.FontBold
	TitleText.TextSize = 22
	TitleText.TextColor3 = THEME.TextColor
	TitleText.Size = UDim2.new(1, -20, 1, 0)
	TitleText.Position = UDim2.new(0, 20, 0, 0)
	TitleText.BackgroundTransparency = 1
	TitleText.TextXAlignment = Enum.TextXAlignment.Left
	TitleText.Parent = TitleBar

	--// 2. FLOATING SIDEBAR (Left "Island")
	local Sidebar = Instance.new("Frame")
	Sidebar.Name = "Sidebar"
	Sidebar.Size = UDim2.new(0, 160, 1, 0)
	Sidebar.Position = UDim2.new(0, 0, 0, 0) -- Left side
	AddGlassEffect(Sidebar)
	Sidebar.Parent = Container
	
	local SideList = Instance.new("UIListLayout")
	SideList.Parent = Sidebar
	SideList.Padding = UDim.new(0, 10)
	SideList.HorizontalAlignment = Enum.HorizontalAlignment.Center
	
	local SidePad = Instance.new("UIPadding")
	SidePad.Parent = Sidebar
	SidePad.PaddingTop = UDim.new(0, 15)

	--// 3. FLOATING CONTENT AREA (Right "Island")
	local Content = Instance.new("Frame")
	Content.Name = "Content"
	Content.Size = UDim2.new(1, -175, 1, 0) -- Fill rest of width
	Content.Position = UDim2.new(1, 0, 0, 0)
	Content.AnchorPoint = Vector2.new(1, 0) -- Align to right
	AddGlassEffect(Content)
	Content.Parent = Container

	-- Make the TitleBar the "Handle" for dragging the whole container
	MakeDraggable(TitleBar, Container)

	--// MOBILE TOGGLE (Floating Cloud)
	local ToggleBtn = Instance.new("TextButton")
	ToggleBtn.Name = "Toggle"
	ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
	ToggleBtn.Position = UDim2.new(0.1, 0, 0.1, 0)
	AddGlassEffect(ToggleBtn)
	ToggleBtn.Text = "☁️"
	ToggleBtn.TextSize = 25
	ToggleBtn.Parent = ScreenGui
	MakeDraggable(ToggleBtn, ToggleBtn)

	local Open = true
	ToggleBtn.MouseButton1Click:Connect(function()
		Open = not Open
		if Open then
			Container.Visible = true
			TweenService:Create(Container, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Size = UDim2.new(0, 650, 0, 400)}):Play()
			TweenService:Create(TitleBar, TweenInfo.new(0.6, Enum.EasingStyle.Back), {Position = UDim2.new(0,0,0,-50)}):Play()
		else
			TweenService:Create(Container, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
			TweenService:Create(TitleBar, TweenInfo.new(0.4), {Position = UDim2.new(0,0,0,0)}):Play() -- Collapse title into body
			task.delay(0.5, function() Container.Visible = false end)
		end
	end)
	
	--// TABS & ELEMENTS SYSTEM
	local Tabs = {}
	local Window = {}
	local First = true

	function Window:CreateTab(Name)
		-- Sidebar Button
		local TabBtn = Instance.new("TextButton")
		TabBtn.Size = UDim2.new(0, 130, 0, 35)
		TabBtn.Text = Name
		TabBtn.TextColor3 = THEME.TextColor
		TabBtn.Font = THEME.Font
		TabBtn.TextSize = 14
		TabBtn.BackgroundTransparency = 1 -- Transparent default
		TabBtn.Parent = Sidebar
		
		local TabCorner = Instance.new("UICorner"); TabCorner.CornerRadius = UDim.new(0, 8); TabCorner.Parent = TabBtn
		
		-- Indicator (Glow when selected)
		local Glow = Instance.new("UIStroke")
		Glow.Color = THEME.AccentColor
		Glow.Thickness = 2
		Glow.Transparency = 1
		Glow.Parent = TabBtn

		-- Page Container
		local Page = Instance.new("ScrollingFrame")
		Page.Name = Name.."Page"
		Page.Size = UDim2.new(1, -20, 1, -20)
		Page.Position = UDim2.new(0, 10, 0, 10)
		Page.BackgroundTransparency = 1
		Page.ScrollBarThickness = 2
		Page.ScrollBarImageColor3 = THEME.AccentColor
		Page.Visible = false
		Page.Parent = Content
		
		local PageLayout = Instance.new("UIListLayout"); PageLayout.Parent = Page; PageLayout.Padding = UDim.new(0, 8)

		TabBtn.MouseButton1Click:Connect(function()
			for _, v in pairs(Tabs) do
				TweenService:Create(v.Glow, TweenInfo.new(0.3), {Transparency = 1}):Play()
				v.Page.Visible = false
				v.Btn.BackgroundTransparency = 1
			end
			TweenService:Create(Glow, TweenInfo.new(0.3), {Transparency = 0}):Play()
			TweenService:Create(TabBtn, TweenInfo.new(0.3), {BackgroundTransparency = 0.8}):Play() -- Slight highlight
			Page.Visible = true
		end)

		if First then
			First = false
			TabBtn.BackgroundTransparency = 0.8
			Glow.Transparency = 0
			Page.Visible = true
		end
		
		table.insert(Tabs, {Btn = TabBtn, Glow = Glow, Page = Page})

		local Elements = {}
		
		function Elements:CreateButton(Name, Callback)
			local Btn = Instance.new("TextButton")
			Btn.Size = UDim2.new(1, -10, 0, 40)
			Btn.Text = Name
			Btn.TextColor3 = THEME.TextColor
			Btn.Font = THEME.Font
			Btn.TextSize = 14
			Btn.Parent = Page
			
			AddGlassEffect(Btn) -- Glass buttons inside glass container!
			Btn.BackgroundTransparency = 0.8 -- More transparent than main window
			
			Btn.MouseButton1Click:Connect(function()
				-- Click Animation
				TweenService:Create(Btn, TweenInfo.new(0.1), {Size = UDim2.new(1, -15, 0, 38)}):Play()
				task.wait(0.1)
				TweenService:Create(Btn, TweenInfo.new(0.1), {Size = UDim2.new(1, -10, 0, 40)}):Play()
				pcall(Callback)
			end)
		end
		
		function Elements:CreateToggle(Name, Callback)
			local TogFrame = Instance.new("Frame")
			TogFrame.Size = UDim2.new(1, -10, 0, 40)
			TogFrame.Parent = Page
			AddGlassEffect(TogFrame)
			TogFrame.BackgroundTransparency = 0.8
			
			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(0.7, 0, 1, 0)
			Label.Position = UDim2.new(0, 10, 0, 0)
			Label.BackgroundTransparency = 1
			Label.Text = Name
			Label.TextColor3 = THEME.TextColor
			Label.Font = THEME.Font
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.Parent = TogFrame
			
			local Switch = Instance.new("TextButton")
			Switch.Size = UDim2.new(0, 44, 0, 22)
			Switch.Position = UDim2.new(1, -54, 0.5, -11)
			Switch.Text = ""
			Switch.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
			Switch.BackgroundTransparency = 0.5
			Switch.Parent = TogFrame
			Instance.new("UICorner", Switch).CornerRadius = UDim.new(1,0)
			
			local Knob = Instance.new("Frame")
			Knob.Size = UDim2.new(0, 18, 0, 18)
			Knob.Position = UDim2.new(0, 2, 0.5, -9)
			Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Knob.Parent = Switch
			Instance.new("UICorner", Knob).CornerRadius = UDim.new(1,0)
			
			local On = false
			Switch.MouseButton1Click:Connect(function()
				On = not On
				if On then
					TweenService:Create(Knob, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Position = UDim2.new(1, -20, 0.5, -9)}):Play()
					TweenService:Create(Switch, TweenInfo.new(0.3), {BackgroundColor3 = THEME.AccentColor}):Play()
				else
					TweenService:Create(Knob, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Position = UDim2.new(0, 2, 0.5, -9)}):Play()
					TweenService:Create(Switch, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
				end
				pcall(Callback, On)
			end)
		end
		
		function Elements:CreateSlider(Name, Range, Callback)
			local SliderFrame = Instance.new("Frame")
			SliderFrame.Size = UDim2.new(1, -10, 0, 50)
			SliderFrame.Parent = Page
			AddGlassEffect(SliderFrame)
			SliderFrame.BackgroundTransparency = 0.8

			local Label = Instance.new("TextLabel")
			Label.Text = Name
			Label.TextColor3 = THEME.TextColor
			Label.Font = THEME.Font
			Label.Size = UDim2.new(1, -20, 0, 20)
			Label.Position = UDim2.new(0, 10, 0, 5)
			Label.BackgroundTransparency = 1
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.Parent = SliderFrame
			
			local Bar = Instance.new("Frame")
			Bar.Size = UDim2.new(1, -20, 0, 4)
			Bar.Position = UDim2.new(0, 10, 0, 35)
			Bar.BackgroundColor3 = Color3.new(1,1,1)
			Bar.BackgroundTransparency = 0.7
			Bar.Parent = SliderFrame
			Instance.new("UICorner", Bar).CornerRadius = UDim.new(1,0)
			
			local Fill = Instance.new("Frame")
			Fill.Size = UDim2.new(0, 0, 1, 0)
			Fill.BackgroundColor3 = THEME.AccentColor
			Fill.Parent = Bar
			Instance.new("UICorner", Fill).CornerRadius = UDim.new(1,0)
			
			local Knob = Instance.new("Frame")
			Knob.Size = UDim2.new(0, 14, 0, 14)
			Knob.Position = UDim2.new(1, 0, 0.5, 0)
			Knob.AnchorPoint = Vector2.new(0.5, 0.5)
			Knob.BackgroundColor3 = Color3.new(1,1,1)
			Knob.Parent = Fill
			Instance.new("UICorner", Knob).CornerRadius = UDim.new(1,0)
			
			-- Glow Effect on Knob
			local KnobGlow = Instance.new("ImageLabel")
			KnobGlow.Image = "rbxassetid://13460408666" -- Soft glow asset
			KnobGlow.Size = UDim2.new(0, 30, 0, 30)
			KnobGlow.Position = UDim2.new(0.5, -15, 0.5, -15)
			KnobGlow.BackgroundTransparency = 1
			KnobGlow.Parent = Knob
			
			local Min, Max = Range[1], Range[2]
			local Dragging = false
			
			local function Update(Input)
				local SizeX = math.clamp((Input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
				TweenService:Create(Fill, TweenInfo.new(0.1), {Size = UDim2.new(SizeX, 0, 1, 0)}):Play()
				local Val = math.floor(Min + ((Max - Min) * SizeX))
				pcall(Callback, Val)
			end
			
			Bar.InputBegan:Connect(function(i) 
				if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then 
					Dragging = true; Update(i) 
				end 
			end)
			UserInputService.InputEnded:Connect(function(i) 
				if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then 
					Dragging = false 
				end 
			end)
			UserInputService.InputChanged:Connect(function(i) 
				if Dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then 
					Update(i) 
				end 
			end)
		end

		return Elements
	end
	
	return Window
end

return Library