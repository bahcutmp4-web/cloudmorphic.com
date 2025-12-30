-- [[ CLOUD LIBRARY V2 - WITH AUTO-SAVE SYSTEM ]] --
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local CloudLib = {
    Configs = {},
    FolderName = "CloudConfigs"
}

-- Ensure folder exists (Codex/Mobile compatible)
if not isfolder(CloudLib.FolderName) then
    makefolder(CloudLib.FolderName)
end

function CloudLib:Save(fileName)
    local path = CloudLib.FolderName .. "/" .. fileName .. ".json"
    writefile(path, HttpService:JSONEncode(CloudLib.Configs))
end

function CloudLib:Load(fileName)
    local path = CloudLib.FolderName .. "/" .. fileName .. ".json"
    if isfile(path) then
        CloudLib.Configs = HttpService:JSONDecode(readfile(path))
        return true
    end
    return false
end

function CloudLib:CreateWindow(libName, configName)
    local fileName = configName or libName
    CloudLib:Load(fileName) -- Try to load existing settings

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CloudLib_" .. libName
    ScreenGui.Parent = CoreGui
    ScreenGui.ResetOnSpawn = false

    -- Floating Toggle Cloud
    local OpenBtn = Instance.new("TextButton")
    OpenBtn.Size = UDim2.new(0, 50, 0, 50)
    OpenBtn.Position = UDim2.new(0, 10, 0.4, 0)
    OpenBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    OpenBtn.Text = "☁️"
    OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    OpenBtn.TextSize = 25
    OpenBtn.Parent = ScreenGui
    Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", OpenBtn).Color = Color3.fromRGB(255, 255, 255)

    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Parent = ScreenGui
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    Main.Position = UDim2.new(0.5, -200, 0.5, -125)
    Main.Size = UDim2.new(0, 400, 0, 250)
    Main.Visible = true
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
    
    OpenBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

    local Sidebar = Instance.new("ScrollingFrame")
    Sidebar.Size = UDim2.new(0, 100, 1, -50)
    Sidebar.Position = UDim2.new(0, 5, 0, 45)
    Sidebar.BackgroundTransparency = 1
    Sidebar.ScrollBarThickness = 0
    Sidebar.Parent = Main
    Instance.new("UIListLayout", Sidebar).Padding = UDim.new(0, 5)

    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -115, 1, -50)
    Container.Position = UDim2.new(0, 110, 0, 45)
    Container.BackgroundTransparency = 1
    Container.Parent = Main

    local TabLib = {}

    function TabLib:CreateTab(name)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 35)
        TabBtn.Text = name
        TabBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TabBtn.BackgroundTransparency = 1
        TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        TabBtn.Font = Enum.Font.Gotham
        TabBtn.Parent = Sidebar
        Instance.new("UICorner", TabBtn)

        local Content = Instance.new("ScrollingFrame")
        Content.Size = UDim2.new(1, 0, 1, 0)
        Content.BackgroundTransparency = 1
        Content.Visible = false
        Content.ScrollBarThickness = 0
        Content.Parent = Container
        Instance.new("UIListLayout", Content).Padding = UDim.new(0, 8)

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Container:GetChildren()) do v.Visible = false end
            for _, v in pairs(Sidebar:GetChildren()) do if v:IsA("TextButton") then v.BackgroundTransparency = 1 end end
            Content.Visible = true
            TabBtn.BackgroundTransparency = 0.9
        end)

        local Elements = {}

        -- [[ SAVING TOGGLE ]] --
        function Elements:CreateToggle(text, configID, callback)
            local state = CloudLib.Configs[configID] or false
            
            local T = Instance.new("TextButton")
            T.Size = UDim2.new(1, -10, 0, 40)
            T.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            T.Text = "  " .. text
            T.TextColor3 = Color3.fromRGB(255, 255, 255)
            T.TextXAlignment = Enum.TextXAlignment.Left
            T.Parent = Content
            Instance.new("UICorner", T)

            local Ind = Instance.new("Frame")
            Ind.Size = UDim2.new(0, 20, 0, 20)
            Ind.Position = UDim2.new(1, -30, 0.5, -10)
            Ind.BackgroundColor3 = state and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(200, 50, 50)
            Ind.Parent = T
            Instance.new("UICorner", Ind).CornerRadius = UDim.new(1, 0)

            -- Run initial state
            task.spawn(function() callback(state) end)

            T.MouseButton1Click:Connect(function()
                state = not state
                CloudLib.Configs[configID] = state
                CloudLib:Save(fileName)
                TweenService:Create(Ind, TweenInfo.new(0.3), {BackgroundColor3 = state and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(200, 50, 50)}):Play()
                callback(state)
            end)
        end

        -- [[ SAVING SLIDER ]] --
        function Elements:CreateSlider(text, configID, min, max, callback)
            local savedVal = CloudLib.Configs[configID] or min
            
            local S = Instance.new("Frame")
            S.Size = UDim2.new(1, -10, 0, 50)
            S.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            S.Parent = Content
            Instance.new("UICorner", S)

            local ST = Instance.new("TextLabel")
            ST.Text = "  " .. text .. ": " .. savedVal
            ST.Size = UDim2.new(1, 0, 0, 25)
            ST.TextColor3 = Color3.fromRGB(255, 255, 255)
            ST.BackgroundTransparency = 1
            ST.TextXAlignment = Enum.TextXAlignment.Left
            ST.Parent = S

            local Bar = Instance.new("Frame")
            Bar.Size = UDim2.new(1, -20, 0, 6)
            Bar.Position = UDim2.new(0, 10, 0, 35)
            Bar.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
            Bar.Parent = S
            
            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new((savedVal - min) / (max - min), 0, 1, 0)
            Fill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
            Fill.Parent = Bar
            Instance.new("UICorner", Fill)

            task.spawn(function() callback(savedVal) end)

            local function Update(input)
                local move = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                local val = math.floor(min + (max - min) * move)
                Fill.Size = UDim2.new(move, 0, 1, 0)
                ST.Text = "  " .. text .. ": " .. val
                CloudLib.Configs[configID] = val
                CloudLib:Save(fileName)
                callback(val)
            end

            Bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Update(input)
                    local con; con = UserInputService.InputChanged:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseMovement then Update(input)
                        else con:Disconnect() end
                    end)
                end
            end)
        end

        return Elements
    end
    return TabLib
end