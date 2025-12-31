--[[
    ☁️ CLOUD LIBRARY V4.3 - FLOATING TITLEBAR (CONCEPT ACCURATE)
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Library = {}
local UI = nil

--// SAFE PARENTING
local function GetSafeGuiRoot()
	local success, result = pcall(function() return gethui() end)
	if success and result then return result end
	success, result = pcall(function() return game:GetService("CoreGui") end)
	if success and result then return result end
	return LocalPlayer:WaitForChild("PlayerGui")
end

--// THEME
local THEME = {
	GlassColor = Color3.fromRGB(200, 230, 255),
	GlassTransparency = 0.4,
	StrokeColor = Color3.fromRGB(255, 255, 255),
	StrokeTransparency = 0.3,
	AccentColor = Color3.fromRGB(120, 200, 255), 
	TextColor = Color3.fromRGB(255, 255, 255),
	SidebarTint = Color3.fromRGB(180, 220, 255),
	Font = Enum.Font.GothamMedium,
	FontBold = Enum.Font.GothamBold
}

--// GLASS EFFECT WITH SHADOW
local function AddGlassEffect(Frame, CornerRadius, IsSidebar)
	Frame.BackgroundColor3 = IsSidebar and THEME.SidebarTint or THEME.GlassColor
	Frame.BackgroundTransparency = THEME.GlassTransparency
	Frame.BorderSizePixel = 0
	
	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, CornerRadius or 16)
	Corner.Parent = Frame
	
	local Stroke = Instance.new("UIStroke")
	Stroke.Color = THEME.StrokeColor
	Stroke.Thickness = 2
	Stroke.Transparency = THEME.StrokeTransparency
	Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	Stroke.Parent = Frame
	
	-- Drop Shadow
	local Shadow = Instance.new("ImageLabel")
	Shadow.Name = "Shadow"
	Shadow.BackgroundTransparency = 1
	Shadow.Image = "rbxassetid://5554236805"
	Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
	Shadow.ImageTransparency = 0.7
	Shadow.ScaleType = Enum.ScaleType.Slice
	Shadow.SliceCenter = Rect.new(23, 23, 277, 277)
	Shadow.Size = UDim2.new(1, 30, 1, 30)
	Shadow.Position = UDim2.new(0, -15, 0, -15)
	Shadow.ZIndex = Frame.ZIndex - 1
	Shadow.Parent = Frame
	
	-- Gradient Shine
	local Gradient = Instance.new("UIGradient")
	Gradient.Rotation = 45
	Gradient.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(0.5, 0.7),
		NumberSequenceKeypoint.new(1, 0.5)
	}
	Gradient.Parent = Frame
end

local function MakeDraggable(Trigger, MainFrame, TitleBar)
	local Dragging, DragInput, DragStart, StartPosMain, StartPosTitle
	Trigger.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			Dragging = true
			DragStart = input.Position
			StartPosMain = MainFrame.Position
			StartPosTitle = TitleBar.Position
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
			-- Move both MainFrame and TitleBar together
			TweenService:Create(MainFrame, TweenInfo.new(0.05), {
				Position = UDim2.new(StartPosMain.X.Scale, StartPosMain.X.Offset + Delta.X, StartPosMain.Y.Scale, StartPosMain.Y.Offset + Delta.Y)
			}):Play()
			TweenService:Create(TitleBar, TweenInfo.new(0.05), {
				Position = UDim2.new(StartPosTitle.X.Scale, StartPosTitle.X.Offset + Delta.X, StartPosTitle.Y.Scale, StartPosTitle.Y.Offset + Delta.Y)
			}):Play()
		end
	end)
end

function Library:CreateWindow(Settings)
	if UI then UI:Destroy() end
	for _,v in pairs(GetSafeGuiRoot():GetChildren()) do if v.Name == "ReflectiveCloud" then v:Destroy() end end

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "ReflectiveCloud"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.Parent = GetSafeGuiRoot()
	UI = ScreenGui

	task.wait(0.1)

	--// TOGGLE BUTTON
	local ToggleCapsule = Instance.new("TextButton")
	ToggleCapsule.Name = "ToggleCapsule"
	ToggleCapsule.Size = UDim2.new(0, 180, 0, 40)
	ToggleCapsule.Position = UDim2.new(0, (ScreenGui.AbsoluteSize.X / 2) - 90, 0, -100)
	ToggleCapsule.Text = "  Open Library"
	ToggleCapsule.TextColor3 = THEME.TextColor
	ToggleCapsule.Font = THEME.FontBold
	ToggleCapsule.TextSize = 15
	ToggleCapsule.TextXAlignment = Enum.TextXAlignment.Left
	ToggleCapsule.Visible = false
	AddGlassEffect(ToggleCapsule, 20)
	ToggleCapsule.Parent = ScreenGui
	
	local CloudIcon = Instance.new("ImageLabel")
	CloudIcon.Image = "rbxassetid://3926305904"
	CloudIcon.Size = UDim2.new(0, 24, 0, 24)
	CloudIcon.Position = UDim2.new(0, 12, 0.5, -12)
	CloudIcon.BackgroundTransparency = 1
	CloudIcon.ImageColor3 = THEME.TextColor
	CloudIcon.Parent = ToggleCapsule

	--// FLOATING TITLE BAR (Above MainFrame)
	local TitleBar = Instance.new("Frame")
	TitleBar.Name = "TitleBar"
	TitleBar.Size = UDim2.new(0, 700, 0, 55)
	TitleBar.Position = UDim2.new(0, (ScreenGui.AbsoluteSize.X / 2) - 350, 0, (ScreenGui.AbsoluteSize.Y / 2) - 285) -- 60px above MainFrame
	AddGlassEffect(TitleBar, 16)
	TitleBar.Parent = ScreenGui

	local TitleText = Instance.new("TextLabel")
	TitleText.Text = Settings.Name or "Cloud Library"
	TitleText.Font = THEME.FontBold
	TitleText.TextSize = 24
	TitleText.TextColor3 = THEME.TextColor
	TitleText.Size = UDim2.new(1, -60, 1, 0)
	TitleText.Position = UDim2.new(0, 20, 0, 0)
	TitleText.BackgroundTransparency = 1
	TitleText.TextXAlignment = Enum.TextXAlignment.Left
	TitleText.Parent = TitleBar
	
	-- Close Button
	local CloseBtn = Instance.new("TextButton")
	CloseBtn.Text = "×"
	CloseBtn.Font = Enum.Font.GothamBold
	CloseBtn.TextSize = 32
	CloseBtn.TextColor3 = THEME.TextColor
	CloseBtn.BackgroundTransparency = 1
	CloseBtn.Size = UDim2.new(0, 45, 0, 45)
	CloseBtn.Position = UDim2.new(1, -50, 0, 5)
	CloseBtn.Parent = TitleBar

	--// MAIN CONTENT FRAME (Below TitleBar)
	local MainFrame = Instance.new("Frame")
	MainFrame.Name = "MainFrame"
	MainFrame.Size = UDim2.new(0, 700, 0, 450)
	MainFrame.Position = UDim2.new(0, (ScreenGui.AbsoluteSize.X / 2) - 350, 0, (ScreenGui.AbsoluteSize.Y / 2) - 225)
	AddGlassEffect(MainFrame, 20)
	MainFrame.Parent = ScreenGui

	--// SIDEBAR
	local Sidebar = Instance.new("Frame")
	Sidebar.Name = "Sidebar"
	Sidebar.Size = UDim2.new(0, 200, 1, -20)
	Sidebar.Position = UDim2.new(0, 10, 0, 10)
	AddGlassEffect(Sidebar, 16, true)
	Sidebar.Parent = MainFrame
	
	local SideList = Instance.new("UIListLayout")
	SideList.Parent = Sidebar
	SideList.Padding = UDim.new(0, 8)
	SideList.HorizontalAlignment = Enum.HorizontalAlignment.Center
	
	local SidePad = Instance.new("UIPadding")
	SidePad.Parent = Sidebar
	SidePad.PaddingTop = UDim.new(0, 15)

	--// CONTENT AREA
	local Content = Instance.new("Frame")
	Content.Name = "Content"
	Content.Size = UDim2.new(0, 465, 1, -20)
	Content.Position = UDim2.new(0, 225, 0, 10)
	Content.BackgroundTransparency = 1
	Content.Parent = MainFrame

	-- Make draggable (drag titlebar, moves both frames)
	MakeDraggable(TitleBar, MainFrame, TitleBar)

	--// OPEN/CLOSE LOGIC
	local function OpenUI()
		local TweenOut = TweenService:Create(ToggleCapsule, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
			Position = UDim2.new(0, (ScreenGui.AbsoluteSize.X / 2) - 90, 0, -100)
		})
		TweenOut:Play()
		TweenOut.Completed:Connect(function() ToggleCapsule.Visible = false end)
		
		-- Show both frames
		MainFrame.Visible = true
		TitleBar.Visible = true
		MainFrame.Size = UDim2.new(0, 0, 0, 0)
		TitleBar.Size = UDim2.new(0, 0, 0, 0)
		
		TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 700, 0, 450)
		}):Play()
		TweenService:Create(TitleBar, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 700, 0, 55)
		}):Play()
	end

	local function CloseUI()
		TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
			Size = UDim2.new(0, 0, 0, 0)
		}):Play()
		TweenService:Create(TitleBar, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
			Size = UDim2.new(0, 0, 0, 0)
		}):Play()
		
		task.delay(0.5, function()
			MainFrame.Visible = false
			TitleBar.Visible = false
		end)
		
		ToggleCapsule.Visible = true
		ToggleCapsule.Position = UDim2.new(0, (ScreenGui.AbsoluteSize.X / 2) - 90, 0, -100)
		TweenService:Create(ToggleCapsule, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Position = UDim2.new(0, (ScreenGui.AbsoluteSize.X / 2) - 90, 0, 15)
		}):Play()
	end

	CloseBtn.MouseButton1Click:Connect(CloseUI)
	ToggleCapsule.MouseButton1Click:Connect(OpenUI)

	--// TAB SYSTEM
	local Tabs = {}
	local Window = {}
	local First = true

	local TabIcons = {
		Home = "rbxassetid://3926305904",
		Settings = "rbxassetid://3926307971",
		Inventory = "rbxassetid://4335480586"
	}

	function Window:CreateTab(Name)
		local TabBtn = Instance.new("TextButton")
		TabBtn.Size = UDim2.new(0, 170, 0, 50)
		TabBtn.Text = ""
		TabBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TabBtn.BackgroundTransparency = 0.9
		TabBtn.Parent = Sidebar
		
		local TabCorner = Instance.new("UICorner")
		TabCorner.CornerRadius = UDim.new(0, 12)
		TabCorner.Parent = TabBtn
		
		local Glow = Instance.new("UIStroke")
		Glow.Color = THEME.AccentColor
		Glow.Thickness = 2.5
		Glow.Transparency = 1
		Glow.Parent = TabBtn

		-- Tab Icon
		local Icon = Instance.new("ImageLabel")
		Icon.Image = TabIcons[Name] or "rbxassetid://3926305904"
		Icon.Size = UDim2.new(0, 30, 0, 30)
		Icon.Position = UDim2.new(0, 15, 0.5, -15)
		Icon.BackgroundTransparency = 1
		Icon.ImageColor3 = THEME.TextColor
		Icon.Parent = TabBtn

		-- Tab Label
		local Label = Instance.new("TextLabel")
		Label.Text = Name
		Label.Font = THEME.Font
		Label.TextSize = 16
		Label.TextColor3 = THEME.TextColor
		Label.Size = UDim2.new(1, -60, 1, 0)
		Label.Position = UDim2.new(0, 55, 0, 0)
		Label.BackgroundTransparency = 1
		Label.TextXAlignment = Enum.TextXAlignment.Left
		Label.Parent = TabBtn

		-- Page
		local Page = Instance.new("ScrollingFrame")
		Page.Name = Name.."Page"
		Page.Size = UDim2.new(1, -20, 1, -20)
		Page.Position = UDim2.new(0, 10, 0, 10)
		Page.BackgroundTransparency = 1
		Page.ScrollBarThickness = 3
		Page.ScrollBarImageColor3 = THEME.AccentColor
		Page.BorderSizePixel = 0
		Page.Visible = false
		Page.Parent = Content
		
		local PageLayout = Instance.new("UIListLayout")
		PageLayout.Parent = Page
		PageLayout.Padding = UDim.new(0, 10)

		TabBtn.MouseButton1Click:Connect(function()
			for _, v in pairs(Tabs) do
				TweenService:Create(v.Glow, TweenInfo.new(0.3), {Transparency = 1}):Play()
				v.Page.Visible = false
				v.Btn.BackgroundTransparency = 0.9
			end
			TweenService:Create(Glow, TweenInfo.new(0.3), {Transparency = 0.3}):Play()
			TweenService:Create(TabBtn, TweenInfo.new(0.3), {BackgroundTransparency = 0.6}):Play()
			Page.Visible = true
		end)

		if First then
			First = false
			TabBtn.BackgroundTransparency = 0.6
			Glow.Transparency = 0.3
			Page.Visible = true
		end
		
		table.insert(Tabs, {Btn = TabBtn, Glow = Glow, Page = Page})

		local Elements = {}
		
		function Elements:CreateButton(Name, Callback)
			local Btn = Instance.new("TextButton")
			Btn.Size = UDim2.new(1, -10, 0, 45)
			Btn.Text = Name
			Btn.TextColor3 = THEME.TextColor
			Btn.Font = THEME.Font
			Btn.TextSize = 15
			Btn.Parent = Page
			AddGlassEffect(Btn)
			Btn.BackgroundTransparency = 0.7
			
			Btn.MouseButton1Click:Connect(function()
				TweenService:Create(Btn, TweenInfo.new(0.1), {Size = UDim2.new(1, -15, 0, 42)}):Play()
				task.wait(0.1)
				TweenService:Create(Btn, TweenInfo.new(0.1), {Size = UDim2.new(1, -10, 0, 45)}):Play()
				pcall(Callback)
			end)
		end
		
		function Elements:CreateToggle(Name, Callback)
			local TogFrame = Instance.new("Frame")
			TogFrame.Size = UDim2.new(1, -10, 0, 45)
			TogFrame.Parent = Page
			AddGlassEffect(TogFrame)
			TogFrame.BackgroundTransparency = 0.7
			
			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(0.65, 0, 1, 0)
			Label.Position = UDim2.new(0, 15, 0, 0)
			Label.BackgroundTransparency = 1
			Label.Text = Name
			Label.TextColor3 = THEME.TextColor
			Label.Font = THEME.Font
			Label.TextSize = 15
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.Parent = TogFrame
			
			local Switch = Instance.new("TextButton")
			Switch.Size = UDim2.new(0, 50, 0, 26)
			Switch.Position = UDim2.new(1, -60, 0.5, -13)
			Switch.Text = ""
			Switch.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			Switch.BackgroundTransparency = 0.3
			Switch.Parent = TogFrame
			Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)
			
			local Knob = Instance.new("Frame")
			Knob.Size = UDim2.new(0, 20, 0, 20)
			Knob.Position = UDim2.new(0, 3, 0.5, -10)
			Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Knob.Parent = Switch
			Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)
			
			local On = false
			Switch.MouseButton1Click:Connect(function()
				On = not On
				TweenService:Create(Knob, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
					Position = On and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
				}):Play()
				TweenService:Create(Switch, TweenInfo.new(0.3), {
					BackgroundColor3 = On and THEME.AccentColor or Color3.fromRGB(60, 60, 60)
				}):Play()
				pcall(Callback, On)
			end)
		end
		
		function Elements:CreateSlider(Name, Range, Callback)
			local SliderFrame = Instance.new("Frame")
			SliderFrame.Size = UDim2.new(1, -10, 0, 60)
			SliderFrame.Parent = Page
			AddGlassEffect(SliderFrame)
			SliderFrame.BackgroundTransparency = 0.7
			
			local Label = Instance.new("TextLabel")
			Label.Text = Name
			Label.TextColor3 = THEME.TextColor
			Label.Font = THEME.Font
			Label.TextSize = 15
			Label.Size = UDim2.new(1, -30, 0, 25)
			Label.Position = UDim2.new(0, 15, 0, 8)
			Label.BackgroundTransparency = 1
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.Parent = SliderFrame
			
			local Bar = Instance.new("Frame")
			Bar.Size = UDim2.new(1, -30, 0, 5)
			Bar.Position = UDim2.new(0, 15, 0, 42)
			Bar.BackgroundColor3 = Color3.new(1, 1, 1)
			Bar.BackgroundTransparency = 0.6
			Bar.Parent = SliderFrame
			Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)
			
			local Fill = Instance.new("Frame")
			Fill.Size = UDim2.new(0, 0, 1, 0)
			Fill.BackgroundColor3 = THEME.AccentColor
			Fill.Parent = Bar
			Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
			
			local Knob = Instance.new("Frame")
			Knob.Size = UDim2.new(0, 16, 0, 16)
			Knob.Position = UDim2.new(1, 0, 0.5, 0)
			Knob.AnchorPoint = Vector2.new(0.5, 0.5)
			Knob.BackgroundColor3 = Color3.new(1, 1, 1)
			Knob.Parent = Fill
			Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)
			
			local Min, Max = Range[1], Range[2]
			local Dragging = false
			
			local function Update(Input)
				local SizeX = math.clamp((Input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
				TweenService:Create(Fill, TweenInfo.new(0.1), {Size = UDim2.new(SizeX, 0, 1, 0)}):Play()
				pcall(Callback, math.floor(Min + ((Max - Min) * SizeX)))
			end
			
			Bar.InputBegan:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
					Dragging = true
					Update(i)
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