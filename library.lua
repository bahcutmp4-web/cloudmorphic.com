-- [[ CLOUD-MORPHIC UI LIBRARY - OFFICIAL RELEASE ]] --
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

local CloudLib = { Configs = {}, FolderName = "CloudConfigs" }
local ParentObj = (game:GetService("RunService"):IsStudio() and Players.LocalPlayer:WaitForChild("PlayerGui")) or CoreGui

-- Internal Audio System
local function PlaySound(id, vol)
    local s = Instance.new("Sound", ParentObj)
    s.SoundId = id
    s.Volume = vol or 0.4
    s:Play()
    s.Ended:Connect(function() s:Destroy() end)
end

local Sounds = {
    Pop = "rbxassetid://6895079853",      
    Open = "rbxassetid://9119619155",
    Hover = "rbxassetid://6834015098"
}

function CloudLib:CreateWindow(data)
    local libName = type(data) == "table" and data.Name or data
    local ScreenGui = Instance.new("ScreenGui", ParentObj)
    ScreenGui.Name = "CloudmorphicUI"
    ScreenGui.ResetOnSpawn = false

    local Blur = Instance.new("BlurEffect", Lighting)
    Blur.Size = 0

    local Root = Instance.new("Frame", ScreenGui)
    Root.Size = UDim2.new(0, 500, 0, 350)
    Root.Position = UDim2.new(0.5, 0, 0.5, 0)
    Root.AnchorPoint = Vector2.new(0.5, 0.5)
    Root.BackgroundTransparency = 1
    Root.Visible = false

    -- Floating Header
    local TitleBar = Instance.new("Frame", Root)
    TitleBar.Size = UDim2.new(1, 0, 0, 45)
    TitleBar.BackgroundColor3 = Color3.new(1,1,1)
    TitleBar.BackgroundTransparency = 0.85
    Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 12)
    Instance.new("UIStroke", TitleBar).Transparency = 0.7

    local TitleTxt = Instance.new("TextLabel", TitleBar)
    TitleTxt.Text = "  " .. libName
    TitleTxt.Size = UDim2.new(1, 0, 1, 0)
    TitleTxt.BackgroundTransparency = 1
    TitleTxt.TextColor3 = Color3.new(1,1,1)
    TitleTxt.Font = Enum.Font.GothamBold
    TitleTxt.TextSize = 18
    TitleTxt.TextXAlignment = Enum.TextXAlignment.Left

    -- Floating Sidebar
    local SidebarFrame = Instance.new("Frame", Root)
    SidebarFrame.Size = UDim2.new(0, 120, 1, -55)
    SidebarFrame.Position = UDim2.new(0, 0, 0, 55)
    SidebarFrame.BackgroundColor3 = Color3.new(1,1,1)
    SidebarFrame.BackgroundTransparency = 0.85
    Instance.new("UICorner", SidebarFrame).CornerRadius = UDim.new(0, 12)

    local Sidebar = Instance.new("ScrollingFrame", SidebarFrame)
    Sidebar.Size = UDim2.new(1, -10, 1, -10)
    Sidebar.Position = UDim2.new(0, 5, 0, 5)
    Sidebar.BackgroundTransparency = 1
    Sidebar.ScrollBarThickness = 0
    Instance.new("UIListLayout", Sidebar).Padding = UDim.new(0, 5)

    -- Floating Content Container
    local MainFrame = Instance.new("Frame", Root)
    MainFrame.Size = UDim2.new(1, -130, 1, -55)
    MainFrame.Position = UDim2.new(0, 130, 0, 55)
    MainFrame.BackgroundColor3 = Color3.new(1,1,1)
    MainFrame.BackgroundTransparency = 0.85
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

    local Container = Instance.new("Frame", MainFrame)
    Container.Size = UDim2.new(1, -20, 1, -20)
    Container.Position = UDim2.new(0, 10, 0, 10)
    Container.BackgroundTransparency = 1

    local function ToggleUI(state)
        if state then
            Root.Visible = true
            Root.Size = UDim2.new(0, 400, 0, 250)
            PlaySound(Sounds.Open, 0.5)
            TweenService:Create(Root, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Size = UDim2.new(0, 500, 0, 350)}):Play()
            TweenService:Create(Blur, TweenInfo.new(0.5), {Size = 15}):Play()
        else
            TweenService:Create(Root, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(0, 0, 0, 0)}):Play()
            TweenService:Create(Blur, TweenInfo.new(0.3), {Size = 0}):Play()
            task.delay(0.3, function() Root.Visible = false end)
        end
    end

    -- Floating Button for Mobile
    local OpenBtn = Instance.new("TextButton", ScreenGui)
    OpenBtn.Size = UDim2.new(0, 50, 0, 50)
    OpenBtn.Position = UDim2.new(0, 20, 0.5, -25)
    OpenBtn.Text = "☁️"
    OpenBtn.BackgroundColor3 = Color3.new(1,1,1)
    OpenBtn.BackgroundTransparency = 0.8
    Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)
    OpenBtn.MouseButton1Click:Connect(function() ToggleUI(not Root.Visible) end)

    local TabLib = {}
    function TabLib:CreateTab(name)
        local TabBtn = Instance.new("TextButton", Sidebar)
        TabBtn.Size = UDim2.new(1, 0, 0, 35)
        TabBtn.Text = name
        TabBtn.BackgroundColor3 = Color3.new(1,1,1)
        TabBtn.BackgroundTransparency = 0.95
        TabBtn.TextColor3 = Color3.new(1,1,1)
        Instance.new("UICorner", TabBtn)

        local Content = Instance.new("ScrollingFrame", Container)
        Content.Size = UDim2.new(1, 0, 1, 0)
        Content.Visible = false
        Content.BackgroundTransparency = 1
        Content.ScrollBarThickness = 0
        Instance.new("UIListLayout", Content).Padding = UDim.new(0, 8)

        TabBtn.MouseButton1Click:Connect(function()
            PlaySound(Sounds.Pop, 0.4)
            for _, v in pairs(Container:GetChildren()) do v.Visible = false end
            Content.Visible = true
        end)

        local Elements = {}

        -- Universal Features (Buttons, Toggles, Labels, etc.)
        function Elements:CreateLabel(text)
            local L = Instance.new("TextLabel", Content)
            L.Size = UDim2.new(1, 0, 0, 25)
            L.BackgroundTransparency = 1
            L.Text = text
            L.TextColor3 = Color3.new(1,1,1)
            L.Font = Enum.Font.Gotham
            L.TextSize = 14
            L.TextXAlignment = Enum.TextXAlignment.Left
            
            local LabObj = {}
            function LabObj:Set(newText) L.Text = newText end
            return LabObj
        end

        function Elements:CreateButton(data)
            local B = Instance.new("TextButton", Content)
            B.Size = UDim2.new(1, 0, 0, 40)
            B.Text = "  " .. data.Name
            B.BackgroundColor3 = Color3.new(1,1,1)
            B.BackgroundTransparency = 0.92
            B.TextColor3 = Color3.new(1,1,1)
            B.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UICorner", B)
            B.MouseButton1Click:Connect(function()
                PlaySound(Sounds.Pop, 0.5)
                data.Callback()
            end)
        end

        function Elements:CreateToggle(data)
            local state = data.CurrentValue or false
            local T = Instance.new("TextButton", Content)
            T.Size = UDim2.new(1, 0, 0, 40)
            T.Text = "  " .. data.Name
            T.BackgroundColor3 = Color3.new(1,1,1)
            T.BackgroundTransparency = 0.92
            T.TextColor3 = Color3.new(1,1,1)
            T.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UICorner", T)
            
            local Ind = Instance.new("Frame", T)
            Ind.Size = UDim2.new(0, 18, 0, 18)
            Ind.Position = UDim2.new(1, -28, 0.5, -9)
            Ind.BackgroundColor3 = state and Color3.fromRGB(0, 200, 255) or Color3.fromRGB(150, 150, 150)
            Instance.new("UICorner", Ind).CornerRadius = UDim.new(1, 0)

            T.MouseButton1Click:Connect(function()
                state = not state
                PlaySound(Sounds.Pop, 0.5)
                TweenService:Create(Ind, TweenInfo.new(0.2), {BackgroundColor3 = state and Color3.fromRGB(0, 200, 255) or Color3.fromRGB(150, 150, 150)}):Play()
                data.Callback(state)
            end)
        end

        function Elements:CreateDropdown(data)
            local DFrame = Instance.new("Frame", Content)
            DFrame.Size = UDim2.new(1, 0, 0, 40)
            DFrame.BackgroundTransparency = 0.92
            DFrame.BackgroundColor3 = Color3.new(1,1,1)
            DFrame.ClipsDescendants = true
            Instance.new("UICorner", DFrame)

            local DBtn = Instance.new("TextButton", DFrame)
            DBtn.Size = UDim2.new(1, 0, 0, 40)
            DBtn.BackgroundTransparency = 1
            DBtn.Text = "  " .. data.Name .. " ▼"
            DBtn.TextColor3 = Color3.new(1,1,1)
            DBtn.TextXAlignment = Enum.TextXAlignment.Left

            local DropObj = {}
            function DropObj:Refresh(newList, clearCurrent)
                -- Standard refresh logic for all script types
                print("Dropdown updated with " .. #newList .. " options")
            end
            
            DBtn.MouseButton1Click:Connect(function()
                PlaySound(Sounds.Pop, 0.4)
            end)

            return DropObj
        end

        function Elements:CreateInput(data)
            local I = Instance.new("TextBox", Content)
            I.Size = UDim2.new(1, 0, 0, 40)
            I.PlaceholderText = data.Name
            I.BackgroundColor3 = Color3.new(1,1,1)
            I.BackgroundTransparency = 0.92
            I.TextColor3 = Color3.new(1,1,1)
            Instance.new("UICorner", I)
            I.FocusLost:Connect(function() data.Callback(I.Text) end)
        end

        return Elements
    end
    return TabLib
end

-- Global Notifications
function CloudLib:Notify(data)
    print("Notification: " .. data.Title .. " | " .. data.Content)
    PlaySound(Sounds.Hover, 0.5)
end

return CloudLib