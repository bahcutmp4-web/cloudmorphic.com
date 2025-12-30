-- [[ CLOUD-MORPHIC LIBRARY V2.3 - DROPDOWNS ADDED ]] --
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local CloudLib = { Configs = {}, FolderName = "CloudConfigs" }
local ParentObj = (game:GetService("RunService"):IsStudio() and Players.LocalPlayer:WaitForChild("PlayerGui")) or CoreGui

if not isfolder(CloudLib.FolderName) then makefolder(CloudLib.FolderName) end

function CloudLib:Save(name)
    writefile(CloudLib.FolderName.."/"..name..".json", HttpService:JSONEncode(CloudLib.Configs))
end

function CloudLib:CreateWindow(libName, configName)
    local fileName = configName or libName
    pcall(function()
        if isfile(CloudLib.FolderName.."/"..fileName..".json") then
            CloudLib.Configs = HttpService:JSONDecode(readfile(CloudLib.FolderName.."/"..fileName..".json"))
        end
    end)

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CloudmorphicUI"
    ScreenGui.Parent = ParentObj
    ScreenGui.ResetOnSpawn = false

    local OpenBtn = Instance.new("TextButton")
    OpenBtn.Size = UDim2.new(0, 50, 0, 50)
    OpenBtn.Position = UDim2.new(0, 20, 0.5, -25)
    OpenBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    OpenBtn.Text = "☁️"
    OpenBtn.TextColor3 = Color3.new(1,1,1)
    OpenBtn.TextSize = 25
    OpenBtn.Parent = ScreenGui
    Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", OpenBtn).Color = Color3.new(1,1,1)

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 400, 0, 260)
    Main.Position = UDim2.new(0.5, -200, 0.5, -130)
    Main.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
    Main.ClipsDescendants = true
    Main.Visible = false
    Main.Parent = ScreenGui
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 15)
    
    OpenBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

    local Sidebar = Instance.new("ScrollingFrame")
    Sidebar.Size = UDim2.new(0, 110, 1, -50)
    Sidebar.Position = UDim2.new(0, 5, 0, 45)
    Sidebar.BackgroundTransparency = 1
    Sidebar.CanvasSize = UDim2.new(0,0,0,0)
    Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Sidebar.ScrollBarThickness = 0
    Sidebar.Parent = Main
    Instance.new("UIListLayout", Sidebar).Padding = UDim.new(0, 5)

    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -125, 1, -55)
    Container.Position = UDim2.new(0, 120, 0, 45)
    Container.BackgroundTransparency = 1
    Container.Parent = Main

    local TabLib = {}

    function TabLib:CreateTab(name)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, -5, 0, 35)
        TabBtn.Text = name
        TabBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TabBtn.BackgroundTransparency = 0.95
        TabBtn.TextColor3 = Color3.new(0.8, 0.8, 0.8)
        TabBtn.Font = Enum.Font.GothamMedium
        TabBtn.Parent = Sidebar
        Instance.new("UICorner", TabBtn)

        local Content = Instance.new("ScrollingFrame")
        Content.Size = UDim2.new(1, 0, 1, 0)
        Content.BackgroundTransparency = 1
        Content.Visible = false
        Content.ScrollBarThickness = 0
        Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Content.Parent = Container
        Instance.new("UIListLayout", Content).Padding = UDim.new(0, 8)

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Container:GetChildren()) do v.Visible = false end
            for _, v in pairs(Sidebar:GetChildren()) do if v:IsA("TextButton") then v.BackgroundTransparency = 0.95 end end
            Content.Visible = true
            TabBtn.BackgroundTransparency = 0.8
        end)

        local Elements = {}

        function Elements:CreateToggle(text, configID, callback)
            local state = CloudLib.Configs[configID] or false
            local T = Instance.new("TextButton")
            T.Size = UDim2.new(1, -5, 0, 40)
            T.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
            T.Text = "  "..text
            T.TextColor3 = Color3.new(1,1,1)
            T.TextXAlignment = Enum.TextXAlignment.Left
            T.Parent = Content
            Instance.new("UICorner", T)
            
            local Ind = Instance.new("Frame")
            Ind.Size = UDim2.new(0, 18, 0, 18)
            Ind.Position = UDim2.new(1, -28, 0.5, -9)
            Ind.BackgroundColor3 = state and Color3.fromRGB(0, 210, 255) or Color3.fromRGB(60, 60, 65)
            Ind.Parent = T
            Instance.new("UICorner", Ind).CornerRadius = UDim.new(1, 0)

            T.MouseButton1Click:Connect(function()
                state = not state
                CloudLib.Configs[configID] = state
                CloudLib:Save(fileName)
                TweenService:Create(Ind, TweenInfo.new(0.2), {BackgroundColor3 = state and Color3.fromRGB(0, 210, 255) or Color3.fromRGB(60, 60, 65)}):Play()
                callback(state)
            end)
            task.spawn(function() callback(state) end)
        end

        function Elements:CreateSlider(text, configID, min, max, callback)
            local savedVal = CloudLib.Configs[configID] or min
            local S = Instance.new("Frame")
            S.Size = UDim2.new(1, -5, 0, 50)
            S.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
            S.Parent = Content
            Instance.new("UICorner", S)

            local ST = Instance.new("TextLabel")
            ST.Text = "  "..text..": "..savedVal
            ST.Size = UDim2.new(1, 0, 0, 25)
            ST.BackgroundTransparency = 1
            ST.TextColor3 = Color3.new(1,1,1)
            ST.TextXAlignment = Enum.TextXAlignment.Left
            ST.Parent = S

            local Bar = Instance.new("Frame")
            Bar.Size = UDim2.new(1, -20, 0, 4)
            Bar.Position = UDim2.new(0, 10, 0, 35)
            Bar.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
            Bar.Parent = S
            
            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new((savedVal - min) / (max - min), 0, 1, 0)
            Fill.BackgroundColor3 = Color3.fromRGB(0, 210, 255)
            Fill.Parent = Bar
            Instance.new("UICorner", Fill)

            local function Update(input)
                local move = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                local val = math.floor(min + (max - min) * move)
                Fill.Size = UDim2.new(move, 0, 1, 0)
                ST.Text = "  "..text..": "..val
                CloudLib.Configs[configID] = val
                CloudLib:Save(fileName)
                callback(val)
            end

            Bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local con; con = UserInputService.InputChanged:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.MouseMovement then Update(inp) end
                    end)
                    UserInputService.InputEnded:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.MouseButton1 then con:Disconnect() end
                    end)
                end
            end)
            task.spawn(function() callback(savedVal) end)
        end

        function Elements:CreateDropdown(text, options, callback)
            local D = Instance.new("Frame")
            D.Size = UDim2.new(1, -5, 0, 40)
            D.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
            D.ClipsDescendants = true
            D.Parent = Content
            Instance.new("UICorner", D)

            local DT = Instance.new("TextButton")
            DT.Size = UDim2.new(1, 0, 0, 40)
            DT.BackgroundTransparency = 1
            DT.Text = "  "..text.." ▼"
            DT.TextColor3 = Color3.new(1,1,1)
            DT.TextXAlignment = Enum.TextXAlignment.Left
            DT.Parent = D

            local OptContainer = Instance.new("Frame")
            OptContainer.Size = UDim2.new(1, 0, 0, #options * 30)
            OptContainer.Position = UDim2.new(0, 0, 0, 40)
            OptContainer.BackgroundTransparency = 1
            OptContainer.Parent = D
            
            local open = false
            DT.MouseButton1Click:Connect(function()
                open = not open
                TweenService:Create(D, TweenInfo.new(0.3), {Size = open and UDim2.new(1, -5, 0, 40 + (#options * 30)) or UDim2.new(1, -5, 0, 40)}):Play()
            end)

            for _, opt in pairs(options) do
                local O = Instance.new("TextButton")
                O.Size = UDim2.new(1, 0, 0, 30)
                O.BackgroundTransparency = 1
                O.Text = "    "..opt
                O.TextColor3 = Color3.fromRGB(180, 180, 180)
                O.TextXAlignment = Enum.TextXAlignment.Left
                O.Parent = OptContainer
                
                O.MouseButton1Click:Connect(function()
                    DT.Text = "  "..text..": "..opt.." ▼"
                    open = false
                    TweenService:Create(D, TweenInfo.new(0.3), {Size = UDim2.new(1, -5, 0, 40)}):Play()
                    callback(opt)
                end)
            end
        end

        return Elements
    end
    return TabLib
end

return CloudLib