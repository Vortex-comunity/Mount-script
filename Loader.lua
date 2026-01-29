-- =========================

--  Script Made by ReyXcode 

--  Version 7.0.2

--  Mohon untuk tidak menjual script

-- =========================



-- Services (utama)

local Players = game:GetService("Players")

local StarterGui = game:GetService("StarterGui")

local HttpService = game:GetService("HttpService")

local TeleportService = game:GetService("TeleportService")

local UserInputService = game:GetService("UserInputService")

local RunService = game:GetService("RunService")

local VirtualUser = game:GetService("VirtualUser")

local plr = Players.LocalPlayer



--  Helper: Checkpoint utilities

local function resolveInstanceFromPath(path)

    if typeof(path) == "Vector3" then

        return path

    end

    if typeof(path) == "Instance" then

        return path

    end



    if type(path) ~= "string" then return nil end

    local cur = workspace

    for part in string.gmatch(path, "[^%.]+") do

        if part:lower() == "workspace" then

            cur = workspace

        else

            cur = cur:FindFirstChild(part)

        end

        if not cur then return nil end

    end

    return cur

end



local function getBasePartFromInstance(inst)

    if not inst then return nil end

    if typeof(inst) == "Vector3" then

        return nil

    end

    if inst:IsA("BasePart") then

        return inst

    elseif inst:IsA("Model") then

        if inst.PrimaryPart and inst.PrimaryPart:IsA("BasePart") then

            return inst.PrimaryPart

        end

        for _, v in ipairs(inst:GetDescendants()) do

            if v:IsA("BasePart") then

                return v

            end

        end

    end

    return nil

end



local function getCheckpointPosition(cp)

    if not cp then return nil end

    if typeof(cp) == "Vector3" then return cp end

    if cp.Pos and typeof(cp.Pos) == "Vector3" then return cp.Pos end

    if cp.Path and type(cp.Path) == "string" then

        local resolved = resolveInstanceFromPath(cp.Path)

        if resolved then

            local bp = getBasePartFromInstance(resolved)

            if bp then return bp.Position end

        end

    end

    if type(cp) == "string" then

        local resolved = resolveInstanceFromPath(cp)

        if resolved then

            local bp = getBasePartFromInstance(resolved)

            if bp then return bp.Position end

        end

    end

    return nil

end



-- Random float helper

local function randFloat(min, max)

    return min + math.random() * (max - min)

end



--  UI (Rayfield) dan Tabs

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()



local Window = Rayfield:CreateWindow({

    Name = "[EXCLUSIVE] ⛰️Mount Project - ReyXcode",

    Icon = 0,

    LoadingTitle = "Loading script...🚀",

    LoadingSubtitle = "Powered by ReyXcode",

    ShowText = "ReyXcode",

    Theme = "DarkBlue",

    ConfigurationSaving = {

        Enabled = true, 

        FolderName = "ReyXTeam",

        FileName = "ReyXCode"

    },

    DisableRayfieldPrompts = true,

})



--  Checkpoint System

getgenv().Checkpoints = {

{Name = "Checkpoint 1", Pos = Vector3.new(387.90, 59.71, -59.39)},

{Name = "Checkpoint 2", Pos = Vector3.new(43.99, 187.71, -140.09)},

{Name = "Checkpoint 3", Pos = Vector3.new(-0.44, 231.71, -650.31)},

{Name = "Checkpoint 4", Pos = Vector3.new(-406.31, 287.70, -661.87)},

{Name = "Checkpoint 5", Pos = Vector3.new(-737.19, 351.70, -610.19)},

{Name = "Checkpoint 6", Pos = Vector3.new(-1109.44, 351.70, -610.64)},

{Name = "Checkpoint 7", Pos = Vector3.new(-1701.72, 415.70, -796.81)},

{Name = "Checkpoint 8", Pos = Vector3.new(-2237.02, 455.70, -725.93)},

{Name = "Checkpoint 9", Pos = Vector3.new(-2675.18, 531.70, -601.35)},

{Name = "Checkpoint 10", Pos = Vector3.new(-2870.96, 587.70, -572.46)},

{Name = "Checkpoint 11", Pos = Vector3.new(-3151.57, 711.70, -692.09)},

{Name = "Summit", Pos = Vector3.new(-3439.52, 963.80, -31.08)},

{Name = "Spawn", Pos = Vector3.new(673.39, 64.96, 57.80)},

}

getgenv().CurrentCheckpoint = 1

getgenv().AutoSummitLoop = false

getgenv().AutoSummitOnce = false

getgenv().AutoSummitRunning = false

getgenv().AutoSummitDelay = 0.1

getgenv().WalkSpeedValue = 16

getgenv().InfiniteJump = false

getgenv().GodMode = false

getgenv().NoClip = false

getgenv().AntiAFK = true

getgenv().AntiFling = false

getgenv().GotoTarget = nil

getgenv().GotoPlayer = false

getgenv().BringPlayer = false

getgenv().NonstopServerHop = false

getgenv().VisitedServers = {}

getgenv().AutoSummitRespawn = false

getgenv().TeleportYOffset = 5



local ESPEnabled = false

local ESPBoxes, ESPConnections, lastNotify = {}, {}, {}

local AntiFlingConnection = nil

local AntiAFKConnection = nil



--  Helper: Notifications

local function SafeNotify(data)

    local now = tick()

    if data == nil or type(data.Title) ~= "string" then return end

    if lastNotify[data.Title] and now - lastNotify[data.Title] < 1.5 then return end

    lastNotify[data.Title] = now

    pcall(function() Rayfield:Notify(data) end)

end



--  Movement / Player Helpers

local function applyWalkSpeed(v)

    if type(v) == "number" then getgenv().WalkSpeedValue = v end

    if not plr then return end

    local char = plr.Character

    local hum = char and char:FindFirstChildOfClass("Humanoid")

    if hum then

        pcall(function() hum.WalkSpeed = getgenv().WalkSpeedValue end)

    end

end



local InfiniteJumpConnection

local function setInfiniteJump(state)

    getgenv().InfiniteJump = state

    if InfiniteJumpConnection then InfiniteJumpConnection:Disconnect() InfiniteJumpConnection = nil end

    if state then

        InfiniteJumpConnection = UserInputService.JumpRequest:Connect(function()

            if not plr then return end

            local char = plr.Character

            local hum = char and char:FindFirstChildOfClass("Humanoid")

            if hum and hum:GetState() ~= Enum.HumanoidStateType.Dead then

                pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)

            end

        end)

    end

end



-- God Mode

local GodModeConnection

local DiedConnection

local function setGodMode(state)

    getgenv().GodMode = state



    if GodModeConnection then

        GodModeConnection:Disconnect()

        GodModeConnection = nil

    end

    if DiedConnection then

        DiedConnection:Disconnect()

        DiedConnection = nil

    end



    if state then

        GodModeConnection = RunService.Heartbeat:Connect(function()

            if not plr then return end

            local char = plr.Character

            local hum = char and char:FindFirstChildOfClass("Humanoid")

            if hum and hum.Health > 0 and hum.Health < hum.MaxHealth then

                pcall(function() hum.Health = hum.MaxHealth end)

            end

        end)



        local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")

        if hum then

            DiedConnection = hum.Died:Connect(function()

                pcall(function() hum.Health = hum.MaxHealth end)

            end)

        end

    end

end



-- NoClip

local NoclipConnection

local OldCollisions = {}

local function setNoClip(state)

    getgenv().NoClip = state

    if NoclipConnection then NoclipConnection:Disconnect() NoclipConnection = nil end

    if state then

        NoclipConnection = RunService.Stepped:Connect(function()

            if not plr then return end

            local char = plr.Character

            if not char then return end

            for _, part in ipairs(char:GetDescendants()) do

                if part:IsA("BasePart") and not part.Anchored then

                    if OldCollisions[part] == nil then

                        OldCollisions[part] = part.CanCollide

                    end

                    pcall(function() part.CanCollide = false end)

                end

            end

        end)

    else

        local char = plr and plr.Character

        if char then

            for _, part in ipairs(char:GetDescendants()) do

                if part:IsA("BasePart") and OldCollisions[part] ~= nil then

                    pcall(function() part.CanCollide = OldCollisions[part] end)

                    OldCollisions[part] = nil

                end

            end

        end

    end

end



-- AntiFling

local AntiFlingConnection

local function setAntiFling(state)

    getgenv().AntiFling = state

    if AntiFlingConnection then AntiFlingConnection:Disconnect() AntiFlingConnection = nil end

    if state then

        AntiFlingConnection = RunService.Heartbeat:Connect(function()

            if not plr then return end

            local char = plr.Character

            local hrp = char and char:FindFirstChild("HumanoidRootPart")

            if hrp then

                pcall(function()

                    if hrp.Velocity.Magnitude > 100 then

                        hrp.Velocity = Vector3.new(0,0,0)

                    end

                    if hrp.RotVelocity.Magnitude > 100 then

                        hrp.RotVelocity = Vector3.new(0,0,0)

                    end

                end)

            end

        end)

    end

end



-- Anti AFK

local AntiAFKConnection

local function setAntiAFK(state)

    getgenv().AntiAFK = state

    if AntiAFKConnection then

        AntiAFKConnection:Disconnect()

        AntiAFKConnection = nil

    end



    if state then

        AntiAFKConnection = plr.Idled:Connect(function()

            if not UserInputService then return end



            if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then

                -- Mobile: tap + rotate camera

                pcall(function()

                    UserInputService.TouchStarted:Fire(Vector2.new(200,200))

                end)

                local cam = workspace.CurrentCamera

                if cam then

                    local pos = cam.CFrame

                    cam.CFrame = pos * CFrame.Angles(0, math.rad(3), 0)

                    task.wait(0.2)

                    cam.CFrame = pos

                end

            else

                -- PC: gunakan VirtualUser

                pcall(function()

                    VirtualUser:CaptureController()

                    VirtualUser:ClickButton2(Vector2.new())

                end)

            end

        end)

    end

end



-- Re-apply on Respawn

plr.CharacterAdded:Connect(function(char)

    task.spawn(function()

        if not char then return end

        pcall(function() char:WaitForChild("Humanoid", 10) end)

        pcall(function() char:WaitForChild("HumanoidRootPart", 10) end)

        task.wait(0.15)



        applyWalkSpeed()

        setGodMode(getgenv().GodMode)

        setNoClip(getgenv().NoClip)



        if getgenv().InfiniteJump then

            setInfiniteJump(true)

        end



        if getgenv().AntiFling then

            setAntiFling(true)

        end



        if getgenv().AntiAFK then

            setAntiAFK(true)

        end

    end)

end)



--  ESP

local function createESP(p)

    if ESPBoxes[p] then return end

    local char = p.Character

    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    if not hrp then return end



    local billboard = Instance.new("BillboardGui")

    billboard.Name = "ESP_"..p.Name

    billboard.Adornee = hrp

    billboard.Size = UDim2.new(0,100,0,25)

    billboard.AlwaysOnTop = true

    billboard.StudsOffset = Vector3.new(0,3,0)



    local txt = Instance.new("TextLabel")

    txt.Size = UDim2.new(1,0,1,0)

    txt.BackgroundTransparency = 1

    txt.TextStrokeTransparency = 0

    txt.TextScaled = true

    txt.Parent = billboard

    billboard.Parent = game.CoreGui



    local conn

    conn = RunService.Heartbeat:Connect(function()

        if not ESPEnabled or not hrp or not hrp.Parent then

            if conn then conn:Disconnect() end

            if billboard and billboard.Parent then pcall(function() billboard:Destroy() end) end

            ESPBoxes[p], ESPConnections[p] = nil, nil

            return

        end

        local selfHrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")

        local dist = selfHrp and math.floor((hrp.Position - selfHrp.Position).Magnitude) or 0

        txt.Text = p.Name.." - "..dist.."m"



        if dist < 15 then

            txt.TextColor3 = Color3.fromRGB(0,255,0)

        elseif dist < 50 then

            txt.TextColor3 = Color3.fromRGB(255,0,0)

        else

            txt.TextColor3 = Color3.fromRGB(255,255,255)

        end

    end)



    ESPBoxes[p], ESPConnections[p] = billboard, conn

end



local function removeESP(p)

    if ESPBoxes[p] then

        pcall(function() ESPBoxes[p]:Destroy() end)

        ESPBoxes[p] = nil

    end

    if ESPConnections[p] then

        pcall(function() ESPConnections[p]:Disconnect() end)

        ESPConnections[p] = nil

    end

end



Players.PlayerAdded:Connect(function(p) if ESPEnabled and p~=plr then createESP(p) end end)

Players.PlayerRemoving:Connect(removeESP)



--  Auto Summit (Ultra Fast)

local function AutoSummitHandler()

    if getgenv().AutoSummitRunning then return end

    getgenv().AutoSummitRunning = true



    local mode = getgenv().AutoSummitLoop and "Loop" or "Sekali"

    SafeNotify({Title="🚀 Auto Summit "..mode, Content="Dimulai!", Duration=2})



    task.spawn(function()

        local function gotoCheckpoint(i)

            local char = plr.Character or plr.CharacterAdded:Wait()

            local hrp = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart",5)

            if not hrp then return end



            local cp = getgenv().Checkpoints[i]

            local pos = cp and (cp.Pos or getCheckpointPosition(cp))

            if pos then

                pcall(function()

                    hrp.CFrame = CFrame.new(pos + Vector3.new(

                        math.random(-0.3,0.3),

                        getgenv().TeleportYOffset,

                        math.random(-0.3,0.3)

                    ))

                end)

                getgenv().CurrentCheckpoint = i

                task.wait(getgenv().AutoSummitDelay + math.random()*0.2)

            end

        end



        -- Once Mode

        if getgenv().AutoSummitOnce then

            getgenv().CurrentCheckpoint = 1

            for i = getgenv().CurrentCheckpoint, #getgenv().Checkpoints do

                gotoCheckpoint(i)

            end

            getgenv().AutoSummitOnce = false

            getgenv().AutoSummitRunning = false



            SafeNotify({Title="🚀 Auto Summit Sekali", Content="Selesai!", Duration=2})

            return

        end



        -- Loop Mode

        if getgenv().AutoSummitLoop then

            getgenv().CurrentCheckpoint = 1

        end



        while getgenv().AutoSummitLoop do

            gotoCheckpoint(getgenv().CurrentCheckpoint)



            if getgenv().CurrentCheckpoint >= #getgenv().Checkpoints then



                if getgenv().AutoSummitRespawn then

                    pcall(function()

                        if plr and plr.Character then

                            plr.Character:BreakJoints()

                        end

                    end)

                    local newChar = plr.CharacterAdded:Wait()

                    newChar:WaitForChild("HumanoidRootPart",10)

                    task.wait(0.1)

                end



                getgenv().CurrentCheckpoint = 1

            else

                getgenv().CurrentCheckpoint += 1

            end



            task.wait(0.1)

        end



        getgenv().AutoSummitRunning = false

        SafeNotify({Title="🚀 Auto Summit Stopped", Content="Berhenti", Duration=2})

    end)

end



--  Server Hop

local function ServerHopLoop()

    task.spawn(function()

        while getgenv().NonstopServerHop do

            local servers, success, data = {}, pcall(function()

                return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))

            end)

            if success and data and data.data then

                for _, s in pairs(data.data) do

                    local sid = tostring(s.id)

                    if sid ~= tostring(game.JobId) and not table.find(getgenv().VisitedServers, sid) and s.playing < s.maxPlayers then

                        table.insert(servers, s)

                    end

                end

                if #servers > 0 then

                    table.sort(servers, function(a,b) return a.playing < b.playing end)

                    local target = servers[1]

                    table.insert(getgenv().VisitedServers, tostring(target.id))

                    SafeNotify({Title="🌍 Server Hop", Content="Server: "..tostring(target.playing).." player, ID: "..tostring(target.id), Duration=4})

                    pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, target.id, plr) end)

                else

                    SafeNotify({Title="🌍 Server Hop", Content="Tidak ada server baru!", Duration=3})

                end

            end

            task.wait(math.random(5,10))

        end

    end)

end



-- Rejoin Server

local function RejoinServer()

    task.spawn(function()

        local jobId = game.JobId

        SafeNotify({Title="🔄 Rejoin", Content="Rejoining server...", Duration=2})

        task.wait(1)

        pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, jobId, plr) end)

    end)

end



-- Tabs

local MainTab = Window:CreateTab("🗻 Main")

local CopyTab = Window:CreateTab("📋 CopyPos")

local CheckpointTab = Window:CreateTab("📍 Checkpoints")

local CheatTab = Window:CreateTab("💀 Cheat")

local PlayerTab = Window:CreateTab("👥 Player")

local AboutTab = Window:CreateTab("📝 About")



-- Main Tab

MainTab:CreateParagraph({Title = "Note :", Content = "Jika kurang puas sama delay\nSilahkan atur delay dibawah\nJika terjadi bug mohon segera hubungi Fayint"})

MainTab:CreateToggle({

    Name="🚀 Auto Summit Loop (BEST)",

    CurrentValue=false,

    Callback=function(v)

        getgenv().AutoSummitLoop = v

        if v then

            getgenv().AutoSummitOnce = false

            getgenv().CurrentCheckpoint = 1

            AutoSummitHandler()

        end

    end

})

MainTab:CreateButton({

    Name="🎯 Auto Summit Sekali",

    Callback=function()

        getgenv().AutoSummitOnce = true

        getgenv().CurrentCheckpoint = 1

        AutoSummitHandler()

    end

})

MainTab:CreateSlider({Name="⏳ Summit Delay", Range={0.1,20}, Increment=0.1, Suffix="Detik", CurrentValue=getgenv().AutoSummitDelay, Callback=function(v) getgenv().AutoSummitDelay=v end})

MainTab:CreateParagraph({Title = "Note :", Content = "Off in respawn jika ingin Summit sekali/Otomatis Loop\nJika diaktifkan akan membuat setiap summit Respawn"})

MainTab:CreateToggle({Name="🛌 Respawn setelah Summit", CurrentValue=getgenv().AutoSummitRespawn, Callback=function(v)

    getgenv().AutoSummitRespawn = v and true or false

    SafeNotify({Title="🛌 Respawn", Content=getgenv().AutoSummitRespawn and "Aktif" or "Nonaktif", Duration=2})

end})



-- Checkpoint Tab (buat tombol untuk tiap checkpoint)

for _, cp in ipairs(getgenv().Checkpoints) do

    CheckpointTab:CreateButton({

        Name = "➡️ "..cp.Name,

        Callback = function()

            local char = (plr.Character or plr.CharacterAdded:Wait())

            local hrp = char:FindFirstChild("HumanoidRootPart")

            if hrp and cp then

                local pos = getCheckpointPosition(cp)

                if pos then

                    pcall(function()

                        hrp.CFrame = CFrame.new(pos) * CFrame.new(

                            randFloat(-0.3, 0.3),

                            getgenv().TeleportYOffset,

                            randFloat(-0.3, 0.3)

                        )

                    end)

                    SafeNotify({Title="📍 Manual", Content="Pindah ke "..cp.Name, Duration=2})

                else

                    SafeNotify({Title="⚠️ Error", Content="Pos checkpoint tidak ditemukan!", Duration=2})

                end

            end

        end

    })

end



--  CopyPosition

local CopyPositionBuffer = {}



local function copyToClipboard(text)

    if setclipboard then

        setclipboard(text)

    elseif toclipboard then

        toclipboard(text)

    else

        warn("Clipboard tidak didukung di exploit kamu.")

    end

end



-- Ambil posisi HumanoidRootPart pemain

local function getCurrentPosition()

    local localPlayer = plr or Players.LocalPlayer

    if not localPlayer then return nil end

    local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()

    if not character then return nil end

    local hrp = character:FindFirstChild("HumanoidRootPart")

    if hrp then return hrp.Position end

    return nil

end



local function formatCheckpointString(name, pos)

    return string.format('{Name = "%s", Pos = Vector3.new(%.2f, %.2f, %.2f)},', name, pos.X, pos.Y, pos.Z)

end



CopyTab:CreateParagraph({Title = "CopyPosition", Content = "Gunakan tombol di bawah untuk menambahkan checkpoint dari posisi kamu dan menyalinnya ke clipboard."})

CopyTab:CreateButton({

    Name = "📍 CopyPos (Tambah Checkpoint)",

    Callback = function()

        local pos = getCurrentPosition()

        if not pos then

            pcall(function() Rayfield:Notify({Title = "⚠️ CopyPos", Content = "Tidak dapat menentukan posisi saat ini!", Duration = 3}) end)

            return

        end



        -- Perubahan: nomor dimulai dari 1 setiap kali script dijalankan

        local nextIndex = (#CopyPositionBuffer or 0) + 1

        local name = "Checkpoint " .. tostring(nextIndex)

        local formatted = formatCheckpointString(name, pos)



        table.insert(CopyPositionBuffer, formatted)

        copyToClipboard(formatted)



        pcall(function() Rayfield:Notify({Title = "📍 CopyPos", Content = name .. " berhasil disalin ke clipboard!", Duration = 3}) end)

    end

})



CopyTab:CreateButton({

    Name = "📋 Copy All Checkpoints",

    Callback = function()

        if #CopyPositionBuffer == 0 then

            pcall(function() Rayfield:Notify({Title = "📋 Copy All", Content = "Belum ada checkpoint yang disalin!", Duration = 3}) end)

            return

        end



        local all = table.concat(CopyPositionBuffer, "\n")

        copyToClipboard(all)

        pcall(function() Rayfield:Notify({Title = "📋 Copy All", Content = "Semua checkpoint disalin ke clipboard!", Duration = 3}) end)

    end

})



pcall(function() Rayfield:Notify({Title = "📋 CopyPosition Aktif", Content = "Fitur CopyPosition telah ditambahkan tanpa mengubah kode asli.", Duration = 4}) end)



-- Cheat Tab

CheatTab:CreateSlider({Name="🏃 WalkSpeed", Range={16,200}, Increment=1, CurrentValue=getgenv().WalkSpeedValue, Callback=applyWalkSpeed})

CheatTab:CreateToggle({Name="🦘 Infinite Jump", CurrentValue=false, Callback=setInfiniteJump})

CheatTab:CreateToggle({Name="🛡️ God Mode", CurrentValue=false, Callback=setGodMode})

CheatTab:CreateToggle({Name="🚫 NoClip", CurrentValue=false, Callback=setNoClip})

CheatTab:CreateToggle({Name="🖐️ AntiFling", CurrentValue=false, Callback=setAntiFling})

CheatTab:CreateToggle({

    Name = "👁️ ESP Players",

    CurrentValue = false,

    Callback = function(v)

        ESPEnabled = v

        if v then

            for _, p in ipairs(Players:GetPlayers()) do

                if p ~= plr then createESP(p) end

            end

        else

            for p, _ in pairs(ESPBoxes) do removeESP(p) end

        end

    end

})



-- Jump button controls (cheat tab)

do

    local jumpEnabled = false

    local dragEnabled = false

    local jumpSize = 100

    local dragConn, inputConn

    local defaultSize = UDim2.new(0, 120, 0, 120)

    local defaultPos = UDim2.new(1, -140, 1, -180)



    local function getJumpButton()

        local gui = plr:WaitForChild("PlayerGui")

        local touchGui

        repeat

            touchGui = gui:FindFirstChild("TouchGui")

            task.wait(0.1)

        until touchGui

        local frame = touchGui:WaitForChild("TouchControlFrame")

        return frame:WaitForChild("JumpButton")

    end



    local function clampPosition(btn, newPos)

        local screenSize = plr.PlayerGui.AbsoluteSize

        local btnSize = btn.AbsoluteSize

        return UDim2.new(

            newPos.X.Scale,

            math.clamp(newPos.X.Offset, 0, screenSize.X - btnSize.X),

            newPos.Y.Scale,

            math.clamp(newPos.Y.Offset, 0, screenSize.Y - btnSize.Y)

        )

    end



    local function setupDrag(btn)

        if dragConn then dragConn:Disconnect() dragConn = nil end

        if inputConn then inputConn:Disconnect() inputConn = nil end

        if not dragEnabled then return end

        local startPos, startUDim

        dragConn = btn.InputBegan:Connect(function(input)

            if input.UserInputType ~= Enum.UserInputType.Touch and input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end

            startPos = input.Position

            startUDim = btn.Position

            inputConn = UserInputService.InputChanged:Connect(function(moveInput)

                if moveInput.UserInputType ~= Enum.UserInputType.Touch and moveInput.UserInputType ~= Enum.UserInputType.MouseMovement then return end

                local delta = moveInput.Position - startPos

                btn.Position = clampPosition(btn, UDim2.new(

                    startUDim.X.Scale,

                    startUDim.X.Offset + delta.X,

                    startUDim.Y.Scale,

                    startUDim.Y.Offset + delta.Y

                ))

            end)

        end)

        btn.InputEnded:Connect(function(input)

            if inputConn then inputConn:Disconnect() inputConn = nil end

        end)

    end



    local function updateJumpButton()

        local btn = getJumpButton()

        if not btn then return end

        if jumpEnabled then

            btn.Size = UDim2.new(0, jumpSize, 0, jumpSize)

            setupDrag(btn)

        else

            btn.Size = defaultSize

            btn.Position = defaultPos

            if dragConn then dragConn:Disconnect() dragConn = nil end

            if inputConn then inputConn:Disconnect() inputConn = nil end

        end

    end



    CheatTab:CreateToggle({

        Name = "🔘 Jump Button",

        CurrentValue = false,

        Callback = function(v)

            jumpEnabled = v

            updateJumpButton()

        end

    })

    CheatTab:CreateSlider({

        Name = "📏 Jump Size",

        Range = {50, 250},

        Increment = 10,

        CurrentValue = jumpSize,

        Callback = function(v)

            jumpSize = v

            if jumpEnabled then updateJumpButton() end

        end

    })

end



--  Player Tab

PlayerTab:CreateInput({

    Name = "🎯 Username Player",

    PlaceholderText = "Nama player",

    RemoveTextAfterFocusLost = false,

    Callback = function(name)

        local t = Players:FindFirstChild(name)

        if t then

            getgenv().GotoTarget = t

            SafeNotify({

                Title = "🎯 Target",

                Content = "Target: " .. name,

                Duration = 2

            })

        else

            getgenv().GotoTarget = nil

            SafeNotify({

                Title = "⚠️ Error",

                Content = "Player tidak ditemukan!",

                Duration = 2

            })

        end

    end

})



local function getAnyPart(char)

    if not char then return nil end

    return char:FindFirstChild("HumanoidRootPart")

        or char:FindFirstChild("UpperTorso")

        or char:FindFirstChild("Torso")

        or char:FindFirstChild("Head")

end



PlayerTab:CreateButton({

    Name = "🚀 Teleport to Player",

    Callback = function()

        local target = getgenv().GotoTarget

        if target and target.Character and plr.Character then

            local myRoot = getAnyPart(plr.Character)

            local targetRoot = getAnyPart(target.Character)



            if myRoot and targetRoot then

                local ok, err = pcall(function()

                    myRoot.CFrame = targetRoot.CFrame + Vector3.new(0, 3, 0)

                end)

                if ok then

                    SafeNotify({

                        Title = "🎯 Teleport",

                        Content = "Berhasil teleport ke " .. target.Name,

                        Duration = 2

                    })

                else

                    SafeNotify({Title="⚠️ Gagal", Content="Gagal teleport: "..tostring(err), Duration=2})

                end

            else

                SafeNotify({

                    Title = "⚠️ Gagal",

                    Content = "Tidak bisa menemukan part untuk teleport!",

                    Duration = 2

                })

            end

        else

            SafeNotify({

                Title = "⚠️ Error",

                Content = "Target belum dipilih atau tidak valid!",

                Duration = 2

            })

        end

    end

})



PlayerTab:CreateToggle({

    Name="⏰ Anti AFK",

    CurrentValue=false,

    Callback=function(v)

        setAntiAFK(v)

        SafeNotify({

            Title="⏰ Anti AFK",

            Content=v and "Aktif" or "Nonaktif",

            Duration=2

        })

    end

})



PlayerTab:CreateButton({

    Name="🔄 Reset Character",

    Callback=function()

        if plr and plr.Character then

            pcall(function() plr.Character:BreakJoints() end)

            SafeNotify({Title="🔄 Reset", Content="Karakter reset", Duration=2})

        end

    end

})



PlayerTab:CreateButton({

    Name="🔄 Rejoin Server",

    Callback=RejoinServer

})



PlayerTab:CreateToggle({

    Name="🌍 Server Hop Nonstop",

    CurrentValue=false,

    Callback=function(v)

        getgenv().NonstopServerHop=v

        if v then ServerHopLoop() end

    end

})



--  About Tab

AboutTab:CreateParagraph({Title = "👋 Hallo Everyone", Content = "Selamat datang di ReyXCode!\nTerimakasih telah menggunakan script ini\nSelalu support Rey kedepannya yaa..."})

AboutTab:CreateParagraph({Title = "🧑‍💻 Developer Script", Content = "by ReyXCode\nSince: 12 September 2025\nVersion: 7.1.2"})

AboutTab:CreateButton({

    Name = "📞 Contact g",

    Callback = function()

        pcall(function() setclipboard("https://wa.me/62") end)

        SafeNotify({Title="Free Request Mount", Content="Nomor telah dicopy", Duration=3})

        sendSimpleEmbed("📞 Contact rey", "User menyalin nomor kontak", {})

    end

})

AboutTab:CreateButton({

    Name = "🔎 Search Script? Join Discord!!",

    Callback = function()

        pcall(function() setclipboard("https://discord.gg/nAStqCh6p") end)

        SafeNotify({Title="Server Discord", Content="Link Discord dicopy!", Duration=3})

        sendSimpleEmbed("🔎 Discord Link", "User menyalin link Discord", {})

    end

})

AboutTab:CreateButton({

    Name = "🔗 Alternative Saluran",

    Callback = function()

        pcall(function() setclipboard("https://whatsapp.com/channel/0029VbBk5jlK0IBj5AQO4M2N") end)

        SafeNotify({Title="Link Saluran", Content="Link Saluran dicopy!", Duration=3})

        sendSimpleEmbed("🔗 Alternative Channel", "User menyalin link saluran alternatif", {})

    end

})

AboutTab:CreateButton({

    Name = "💬 Join Community",

    Callback = function()

        pcall(function() setclipboard("https://chat.whatsapp.com/EMwfGNHgZ2S3iQh7ZreeHC?mode=gi_t") end)

        SafeNotify({Title="Group WhatsApp", Content="Link Group dicopy!", Duration=3})

        sendSimpleEmbed("💬 Join Community", "User menyalin link group WhatsApp", {})

    end

})



-- Notify

pcall(function()

    local success, userId = pcall(function() return Players:GetUserIdFromNameAsync("FAYINTX") end)

    if success and userId then

        local thumbType = Enum.ThumbnailType.HeadShot

        local thumbSize = Enum.ThumbnailSize.Size420x420

        local content, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)



        StarterGui:SetCore("SendNotification", {

            Title = "🔓 Script Terbuka",

            Text = "Exclusive Script!!",

            Icon = content,

            Duration = 8

        })



        StarterGui:SetCore("SendNotification", {

            Title = "👨‍💻 Developer by",

            Text = "ReyXCode!!",

            Icon = content,

            Duration = 8

        })

    end

end)



--  End of Script
