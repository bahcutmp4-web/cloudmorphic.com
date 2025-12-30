--[[
    ☁️ CLOUD LIBRARY V3 - UNIVERSAL EDITION
    Compatible: Delta, Codex, Arceus X, Wave, Solara, Electron, Studio
    Features: Glassmorphism, Mobile Toggle, Spring Animations
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Library = {}
local UI = nil
local MainFrame = nil
local ToggleButton = nil

--// 1. UNIVERSAL PARENTING FUNCTION
-- This ensures it works on EVERY executor by checking available security levels
local function GetSafeGuiRoot()
	local success, result = pcall(function()
		return gethui() -- Standard for modern executors (Wave, Solara, Synapse V3)
	end)
	if success and result then return result end

	success, result = pcall(function()
		return game:GetService("CoreGui") -- Old standard (Delta, some android execs)
	end)
	if success and result then return result end

	return LocalPlayer:WaitForChild("PlayerGui") -- Fallback for Studio / weak executors
end

--// THEME CONSTANTS
local THEME = {
	GlassColor = Color3.fromRGB(200, 225, 255),
	GlassTransparency = 0.45,
	SidebarColor = Color3.fromRGB(255, 255, 255),
	SidebarTransparency = 0.9,
	TextColor = Color3.fromRGB(255, 255, 255),
	TextSubColor = Color3.fromRGB(210, 240, 255),
	AccentColor = Color3.fromRGB(130, 190, 255), 
	ElementColor = Color3.fromRGB(255, 255, 255),
	ElementTransparency = 0.85,
	Font = Enum.Font.GothamMedium,
	FontBold = Enum.Font.GothamBold
}

--// ANIMATION UTILS
local function AddRipple(Button)
	spawn(function()
		local Ripple = Instance.new("ImageLabel")
		Ripple.Name = "Ripple"
		Ripple.Parent = Button
		Ripple.BackgroundTransparency = 1
		Ripple.BorderSizePixel = 0
		Ripple.Image = "rbxassetid://2708891598"
		Ripple.ImageColor3 = Color3.new(1,1,1)
		Ripple.ImageTransparency = 0.8
		Ripple.ScaleType = Enum.ScaleType.Fit
		
		local Mouse = LocalPlayer:GetMouse()
		local AbsPos = Button.AbsolutePosition
		local AbsSize = Button.AbsoluteSize
		
		local X = Mouse.X - AbsPos.X
		local Y = Mouse.Y - AbsPos.Y
		
		Ripple.Position = UDim2.new(0, X, 0, Y)
		Ripple.Size = UDim2.new(0, 0, 0, 0)
		
		local Size = math.max(AbsSize.X, AbsSize.Y) * 1.5
		
		TweenService:Create(Ripple, TweenInfo.new(0.5), {Size = UDim2.new(0, Size, 0, Size), Position = UDim2.new(0, X - Size/2, 0, Y - Size/2), ImageTransparency = 1}):Play()
		wait(0.5)
		Ripple:Destroy()
	end)
end

local function MakeDraggable(topbarobject, object)
	local Dragging, DragInput, DragStart, StartPosition

	topbarobject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			Dragging = true
			DragStart = input.Position
			StartPosition = object.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then Dragging = false end
			end)
		end
	end)

	topbarobject.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then DragInput = input end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == DragInput and Dragging then
			local Delta = input.Position - DragStart
			local TargetPos = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
			-- Smooth Drag
			TweenService:Create(object, TweenInfo.new(0.05), {Position = TargetPos}):Play()
		end
	end)
end

function Library:CreateWindow(Settings)
	-- Cleanup Old UI
	if UI then UI:Destroy() end
	for _, v in pairs(GetSafeGuiRoot():GetChildren()) do
		if v.Name == "CloudLibrary" then v:Destroy() end
	end

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "CloudLibrary"
	ScreenGui.IgnoreGuiInset = true
	ScreenGui.ResetOnSpawn = false
	ScreenGui.Parent = GetSafeGuiRoot()
	UI = ScreenGui

	--// MOBILE OPEN/CLOSE BUTTON (Rayfield Style)
	local OpenBtn = Instance.new("TextButton")
	OpenBtn.Name = "OpenButton"
	OpenBtn.Size = UDim2.new(0, 50, 0, 50)
	OpenBtn.Position = UDim2.new(0.1, 0, 0.1, 0) -- Top Left area
	OpenBtn.BackgroundColor3 = THEME.GlassColor
	OpenBtn.BackgroundTransparency = 0.5
	OpenBtn.Text = ""
	OpenBtn.Parent = ScreenGui
	
	local OpenCorner = Instance.new("UICorner")
	OpenCorner.CornerRadius = UDim.new(1, 0)
	OpenCorner.Parent = OpenBtn
	
	local OpenStroke = Instance.new("UIStroke")
	OpenStroke.Thickness = 2
	OpenStroke.Color = THEME.AccentColor
	OpenStroke.Parent = OpenBtn
	
	local OpenIcon = Instance.new("ImageLabel")
	OpenIcon.Image = "rbxassetid://3926305904" -- Cloud Icon
	OpenIcon.Size = UDim2.new(0, 30, 0, 30)
	OpenIcon.Position = UDim2.new(0.5, -15, 0.5, -15)
	OpenIcon.BackgroundTransparency = 1
	OpenIcon.ImageColor3 = Color3.new(1,1,1)
	OpenIcon.Parent = OpenBtn
	
	MakeDraggable(OpenBtn, OpenBtn) -- Make the toggle button draggable too!

	--// MAIN CONTAINER
	MainFrame = Instance.new("Frame")
	MainFrame.Name = "MainFrame"
	MainFrame.Size = UDim2.new(0, 0, 0, 0) -- Start small for animation
	MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	MainFrame.AnchorPoint = Vector2.new(0.5, 0.5) -- Center pivot for scaling
	MainFrame.BackgroundColor3 = THEME.GlassColor
	MainFrame.BackgroundTransparency = THEME.GlassTransparency
	MainFrame.ClipsDescendants = true
	MainFrame.Parent = ScreenGui

	local MainCorner = Instance.new("UICorner")
	MainCorner.CornerRadius = UDim.new(0, 20)
	MainCorner.Parent = MainFrame
	
	local MainStroke = Instance.new("UIStroke")
	MainStroke.Thickness = 2
	MainStroke.Color = Color3.new(1,1,1)
	MainStroke.Transparency = 0.4
	MainStroke.Parent = MainFrame

	-- Scale Animation on Open
	TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 600, 0, 400)}):Play()
	MakeDraggable(MainFrame, MainFrame)

	-- Header
	local Title = Instance.new("TextLabel")
	Title.Text = Settings.Name or "Cloud UI"
	Title.Font = THEME.FontBold
	Title.TextSize = 24
	Title.TextColor3 = THEME.TextColor
	Title.Size = UDim2.new(1, -50, 0, 50)
	Title.Position = UDim2.new(0, 25, 0, 5)
	Title.BackgroundTransparency = 1
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.Parent = MainFrame
	
	-- Close Button (X)
	local CloseBtn = Instance.new("TextButton")
	CloseBtn.Text = "×"
	CloseBtn.Font = Enum.Font.Gotham
	CloseBtn.TextSize = 28
	CloseBtn.TextColor3 = THEME.TextColor
	CloseBtn.BackgroundTransparency = 1
	CloseBtn.Size = UDim2.new(0, 40, 0, 40)
	CloseBtn.Position = UDim2.new(1, -45, 0, 10)
	CloseBtn.Parent = MainFrame
	
	-- Toggle Logic
	local UI_Visible = true
	
	local function ToggleUI()
		UI_Visible = not UI_Visible
		if UI_Visible then
			MainFrame.Visible = true
			TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 600, 0, 400)}):Play()
			TweenService:Create(OpenBtn, TweenInfo.new(0.4), {BackgroundTransparency = 0.5, Size = UDim2.new(0, 50, 0, 50)}):Play()
		else
			TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
			task.delay(0.4, function() MainFrame.Visible = false end)
			-- Pulse the open button to show it's active
			TweenService:Create(OpenBtn, TweenInfo.new(0.4), {BackgroundTransparency = 0.2, Size = UDim2.new(0, 60, 0, 60)}):Play()
		end
	end
	
	CloseBtn.MouseButton1Click:Connect(ToggleUI)
	OpenBtn.MouseButton1Click:Connect(ToggleUI)
	
	-- Sidebar
	local Sidebar = Instance.new("Frame")
	Sidebar.Size = UDim2.new(0, 150, 1, -70)
	Sidebar.Position = UDim2.new(0, 15, 0, 60)
	Sidebar.BackgroundColor3 = THEME.SidebarColor
	Sidebar.BackgroundTransparency = THEME.SidebarTransparency
	Sidebar.Parent = MainFrame
	local SideCorner = Instance.new("UICorner"); SideCorner.CornerRadius = UDim.new(0,15); SideCorner.Parent = Sidebar
	local SideList = Instance.new("UIListLayout"); SideList.Parent = Sidebar; SideList.Padding = UDim.new(0,8); SideList.HorizontalAlignment = Enum.HorizontalAlignment.Center
	local SidePad = Instance.new("UIPadding"); SidePad.Parent = Sidebar; SidePad.PaddingTop = UDim.new(0,10)
	
	-- Content
	local ContentFrame = Instance.new("Frame")
	ContentFrame.Size = UDim2.new(1, -180, 1, -70)
	ContentFrame.Position = UDim2.new(0, 175, 0, 60)
	ContentFrame.BackgroundColor3 = THEME.SidebarColor
	ContentFrame.BackgroundTransparency = THEME.SidebarTransparency
	ContentFrame.Parent = MainFrame
	local ContentCorner = Instance.new("UICorner"); ContentCorner.CornerRadius = UDim.new(0,15); ContentCorner.Parent = ContentFrame

	local Window = {}
	local Tabs = {}
	local FirstTab = true
	
	function Window:CreateTab(TabSettings)
		local TabName = TabSettings.Name or "Tab"
		
		local TabBtn = Instance.new("TextButton")
		TabBtn.Size = UDim2.new(0, 130, 0, 35)
		TabBtn.BackgroundColor3 = THEME.AccentColor
		TabBtn.BackgroundTransparency = 1
		TabBtn.Text = TabName
		TabBtn.TextColor3 = THEME.TextColor
		TabBtn.Font = THEME.Font
		TabBtn.TextSize = 14
		TabBtn.Parent = Sidebar
		
		local TabCorner = Instance.new("UICorner"); TabCorner.CornerRadius = UDim.new(0,10); TabCorner.Parent = TabBtn
		
		local Container = Instance.new("ScrollingFrame")
		Container.Size = UDim2.new(1, -10, 1, -10)
		Container.Position = UDim2.new(0, 5, 0, 5)
		Container.BackgroundTransparency = 1
		Container.ScrollBarThickness = 2
		Container.Visible = false
		Container.Parent = ContentFrame
		
		local Layout = Instance.new("UIListLayout"); Layout.Parent = Container; Layout.Padding = UDim.new(0,8); Layout.SortOrder = Enum.SortOrder.LayoutOrder
		local Pad = Instance.new("UIPadding"); Pad.Parent = Container; Pad.PaddingTop = UDim.new(0,5); Pad.PaddingLeft = UDim.new(0,5)
		
		TabBtn.MouseButton1Click:Connect(function()
			for _, t in pairs(Tabs) do
				TweenService:Create(t.Btn, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
				t.Container.Visible = false
			end
			TweenService:Create(TabBtn, TweenInfo.new(0.3), {BackgroundTransparency = 0.5}):Play()
			Container.Visible = true
			AddRipple(TabBtn)
		end)
		
		if FirstTab then
			FirstTab = false
			TabBtn.BackgroundTransparency = 0.5
			Container.Visible = true
		end
		table.insert(Tabs, {Btn = TabBtn, Container = Container})

		local Elements = {}

		function Elements:CreateButton(Settings)
			local Btn = Instance.new("TextButton")
			Btn.Size = UDim2.new(1, -10, 0, 40)
			Btn.BackgroundColor3 = THEME.ElementColor
			Btn.BackgroundTransparency = THEME.ElementTransparency
			Btn.Text = Settings.Name
			Btn.TextColor3 = THEME.TextColor
			Btn.Font = THEME.Font
			Btn.TextSize = 14
			Btn.Parent = Container
			
			local Corner = Instance.new("UICorner"); Corner.CornerRadius = UDim.new(0,8); Corner.Parent = Btn
			local Stroke = Instance.new("UIStroke"); Stroke.Color = THEME.AccentColor; Stroke.Thickness = 1; Stroke.Transparency = 1; Stroke.Parent = Btn
			
			Btn.MouseButton1Click:Connect(function()
				AddRipple(Btn)
				pcall(Settings.Callback)
			end)
			
			Btn.MouseEnter:Connect(function() TweenService:Create(Stroke, TweenInfo.new(0.2), {Transparency = 0}):Play() end)
			Btn.MouseLeave:Connect(function() TweenService:Create(Stroke, TweenInfo.new(0.2), {Transparency = 1}):Play() end)
		end
		
		function Elements:CreateToggle(Settings)
			local ToggleFrame = Instance.new("TextButton") -- Used button for click whole area
			ToggleFrame.Size = UDim2.new(1, -10, 0, 40)
			ToggleFrame.BackgroundTransparency = 1
			ToggleFrame.Text = ""
			ToggleFrame.Parent = Container
			
			local Label = Instance.new("TextLabel")
			Label.Text = Settings.Name
			Label.Font = THEME.Font
			Label.TextColor3 = THEME.TextColor
			Label.TextSize = 14
			Label.Size = UDim2.new(0.7, 0, 1, 0)
			Label.BackgroundTransparency = 1
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.Position = UDim2.new(0,5,0,0)
			Label.Parent = ToggleFrame
			
			local Switch = Instance.new("Frame")
			Switch.Size = UDim2.new(0, 45, 0, 24)
			Switch.Position = UDim2.new(1, -50, 0.5, -12)
			Switch.BackgroundColor3 = Color3.new(1,1,1)
			Switch.BackgroundTransparency = 0.8
			Switch.Parent = ToggleFrame
			local SC = Instance.new("UICorner"); SC.CornerRadius = UDim.new(1,0); SC.Parent = Switch
			
			local Knob = Instance.new("Frame")
			Knob.Size = UDim2.new(0, 20, 0, 20)
			Knob.Position = UDim2.new(0, 2, 0.5, -10)
			Knob.BackgroundColor3 = Color3.new(1,1,1)
			Knob.Parent = Switch
			local KC = Instance.new("UICorner"); KC.CornerRadius = UDim.new(1,0); KC.Parent = Knob
			
			local Toggled = Settings.CurrentValue or false
			
			local function Update()
				if Toggled then
					TweenService:Create(Knob, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = UDim2.new(1, -22, 0.5, -10)}):Play()
					TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = THEME.AccentColor, BackgroundTransparency = 0.4}):Play()
				else
					TweenService:Create(Knob, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = UDim2.new(0, 2, 0.5, -10)}):Play()
					TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = Color3.new(1,1,1), BackgroundTransparency = 0.8}):Play()
				end
				pcall(Settings.Callback, Toggled)
			end
			Update()
			
			ToggleFrame.MouseButton1Click:Connect(function()
				Toggled = not Toggled
				Update()
			end)
		end
		
		function Elements:CreateSlider(Settings)
			local SliderFrame = Instance.new("Frame")
			SliderFrame.Size = UDim2.new(1, -10, 0, 50)
			SliderFrame.BackgroundTransparency = 1
			SliderFrame.Parent = Container
			
			local Label = Instance.new("TextLabel")
			Label.Text = Settings.Name
			Label.Font = THEME.Font
			Label.TextColor3 = THEME.TextColor
			Label.Size = UDim2.new(1,0,0,20)
			Label.BackgroundTransparency = 1
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.Position = UDim2.new(0,5,0,0)
			Label.Parent = SliderFrame
			
			local ValLabel = Instance.new("TextLabel")
			ValLabel.Text = Settings.CurrentValue or Settings.Range[1]
			ValLabel.Font = THEME.Font
			ValLabel.TextColor3 = THEME.TextColor
			ValLabel.Size = UDim2.new(0,50,0,20)
			ValLabel.Position = UDim2.new(1,-55,0,0)
			ValLabel.BackgroundTransparency = 1
			ValLabel.TextXAlignment = Enum.TextXAlignment.Right
			ValLabel.Parent = SliderFrame
			
			local Bar = Instance.new("Frame")
			Bar.Size = UDim2.new(1, -10, 0, 4)
			Bar.Position = UDim2.new(0, 5, 0, 35)
			Bar.BackgroundColor3 = Color3.new(1,1,1)
			Bar.BackgroundTransparency = 0.8
			Bar.Parent = SliderFrame
			local BC = Instance.new("UICorner"); BC.CornerRadius = UDim.new(1,0); BC.Parent = Bar
			
			local Fill = Instance.new("Frame")
			Fill.Size = UDim2.new(0,0,1,0)
			Fill.BackgroundColor3 = THEME.AccentColor
			Fill.BackgroundTransparency = 0.2
			Fill.Parent = Bar
			local FC = Instance.new("UICorner"); FC.CornerRadius = UDim.new(1,0); FC.Parent = Fill
			
			local Knob = Instance.new("Frame")
			Knob.Size = UDim2.new(0,14,0,14)
			Knob.AnchorPoint = Vector2.new(0.5,0.5)
			Knob.Position = UDim2.new(1,0,0.5,0)
			Knob.BackgroundColor3 = Color3.new(1,1,1)
			Knob.Parent = Fill
			local KNC = Instance.new("UICorner"); KNC.CornerRadius = UDim.new(1,0); KNC.Parent = Knob
			
			local Dragging = false
			local Min, Max = Settings.Range[1], Settings.Range[2]
			
			local function Update(Input)
				local SizeX = math.clamp((Input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
				local Value = math.floor(Min + ((Max - Min) * SizeX))
				ValLabel.Text = Value
				TweenService:Create(Fill, TweenInfo.new(0.1), {Size = UDim2.new(SizeX, 0, 1, 0)}):Play()
				pcall(Settings.Callback, Value)
			end
			
			Bar.InputBegan:Connect(function(Input) 
				if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then 
					Dragging = true; Update(Input) 
				end 
			end)
			UserInputService.InputEnded:Connect(function(Input) 
				if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then 
					Dragging = false 
				end 
			end)
			UserInputService.InputChanged:Connect(function(Input) 
				if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then 
					Update(Input) 
				end 
			end)
		end
		
		return Elements
	end
	
	return Window
end

return Library