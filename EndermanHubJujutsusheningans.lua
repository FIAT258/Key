-- Carregar a biblioteca redz hub
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/tlredz/Library/refs/heads/main/redz-V5-remake/main.luau"))()

-- Criar a janela principal
local Window = Library:MakeWindow({
    Title = "ENDERMAN HUB (JUJUTSU SHENINGANS)",
    SubTitle = "By JX1 and loloma",
    ScriptFolder = "redz-library-V5"
})

Library:SetUIScale(1.1)

local Minimizer = Window:NewMinimizer({
    KeyCode = Enum.KeyCode.LeftControl
})

local MobileButton = Minimizer:CreateMobileMinimizer({
    Image = "rbxassetid://121207764172268",
    BackgroundColor3 = Color3.fromRGB(128, 0, 128)
})

-- =====================================================
-- MAIN TAB
-- =====================================================
local MainTab = Window:MakeTab({
    Title = "Main",
    Icon = "Home"
})

-- Dropdown body part
local bodyPartOptions = {"Torso", "Head", "Back"}
local selectedBodyPart = "Torso"

MainTab:AddDropdown({
    Name = "Aimbot Body Part",
    Options = bodyPartOptions,
    Default = "Torso",
    Callback = function(Value)
        selectedBodyPart = Value
    end
})

-- Slider smoothness
local smoothness = 0.1
MainTab:AddSlider({
    Name = "Aimbot Smoothness",
    Min = 0.01,
    Max = 0.5,
    Increment = 0.01,
    Default = 0.1,
    Callback = function(Value)
        smoothness = Value
    end
})

-- Variáveis do aimbot
local aimbotEnabled = false
local aimbotTarget = nil
local currentTargetType = nil
local killNotifications = true

-- Função aprimorada para obter parte do corpo (com fallback)
local function getTargetPart(character)
    if not character then return nil end
    local part
    if selectedBodyPart == "Head" then
        part = character:FindFirstChild("Head")
    elseif selectedBodyPart == "Torso" then
        part = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
    elseif selectedBodyPart == "Back" then
        part = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
    end
    -- Fallback para HumanoidRootPart se a parte desejada não existir
    return part or character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")
end

-- Função para encontrar o alvo mais próximo (melhorada)
local function getClosestTarget()
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character then return nil, nil end
    local root = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")
    if not root then return nil, nil end

    local closestDistance = math.huge
    local closestTarget = nil
    local targetType = nil
    local cameraPos = workspace.CurrentCamera.CFrame.Position

    -- Players
    for _, otherPlayer in ipairs(game.Players:GetPlayers()) do
        if otherPlayer ~= player then
            local otherChar = otherPlayer.Character
            if otherChar and otherChar:FindFirstChild("Humanoid") and otherChar.Humanoid.Health > 0 then
                local otherRoot = otherChar:FindFirstChild("HumanoidRootPart") or otherChar:FindFirstChild("Torso")
                if otherRoot then
                    local dist = (cameraPos - otherRoot.Position).Magnitude
                    if dist < closestDistance then
                        closestDistance = dist
                        closestTarget = otherChar
                        targetType = "Player"
                    end
                end
            end
        end
    end

    -- Dummies
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "Dummy" and obj:IsA("Model") then
            local humanoid = obj:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local dummyRoot = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")
                if dummyRoot then
                    local dist = (cameraPos - dummyRoot.Position).Magnitude
                    if dist < closestDistance then
                        closestDistance = dist
                        closestTarget = obj
                        targetType = "Dummy"
                    end
                end
            end
        end
    end

    return closestTarget, targetType
end

-- Loop do aimbot (agora com fallback e verificação extra)
local runService = game:GetService("RunService")
local camera = workspace.CurrentCamera

runService.RenderStepped:Connect(function()
    if aimbotEnabled and aimbotTarget then
        -- Verificar se o alvo ainda existe
        local humanoid = aimbotTarget:FindFirstChild("Humanoid")
        if not humanoid or humanoid.Health <= 0 then
            if killNotifications then
                if currentTargetType == "Player" then
                    Library:Notify(aimbotTarget.Name .. " died 👤", 3)
                elseif currentTargetType == "Dummy" then
                    Library:Notify("Dummy died ⚠️", 3)
                end
            end
            aimbotEnabled = false
            aimbotToggle:Set(false)
            aimbotTarget = nil
            return
        end

        local targetPart = getTargetPart(aimbotTarget)
        if targetPart then
            local targetPos = targetPart.Position
            local currentCF = camera.CFrame
            local lookAt = CFrame.lookAt(currentCF.Position, targetPos)
            camera.CFrame = currentCF:Lerp(lookAt, smoothness)
        end
    elseif aimbotEnabled then
        -- Tenta encontrar novo alvo
        local target, targetType = getClosestTarget()
        if target then
            aimbotTarget = target
            currentTargetType = targetType
        else
            aimbotEnabled = false
            aimbotToggle:Set(false)
        end
    end
end)

-- Toggle do aimbot
local aimbotToggle = MainTab:AddToggle({
    Name = "Aimbot (Player/Dummy)",
    Default = false,
    Callback = function(Value)
        aimbotEnabled = Value
        if aimbotEnabled then
            local target, targetType = getClosestTarget()
            if target then
                aimbotTarget = target
                currentTargetType = targetType
            else
                aimbotEnabled = false
                return false
            end
        else
            aimbotTarget = nil
        end
    end
})

-- Toggle notificações
MainTab:AddToggle({
    Name = "Kill Notifications",
    Default = true,
    Callback = function(Value)
        killNotifications = Value
    end
})

-- =====================================================
-- AUTO BLACK FLASH (botão flutuante)
-- =====================================================
local autoBlackFlashActive = false
local blackFlashButton = nil
local blackFlashConnection = nil

local function createBlackFlashButton()
    -- Criar ScreenGui
    local gui = Instance.new("ScreenGui")
    gui.Name = "AutoBlackFlash"
    gui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    gui.ResetOnSpawn = false

    -- Botão redondo
    local button = Instance.new("TextButton")
    button.Name = "BlackFlashButton"
    button.Size = UDim2.new(0, 80, 0, 80)
    button.Position = UDim2.new(0.5, -40, 0.5, -40) -- Centralizado
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    button.BorderColor3 = Color3.fromRGB(100, 100, 100) -- Cinza
    button.BorderSizePixel = 2
    button.Text = "Auto\nBlack\nFlash"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.Font = Enum.Font.SourceSansBold -- Fonte padrão, mas você pode usar a ID da fonte personalizada
    -- Se quiser usar a fonte personalizada, substitua a linha acima por:
    -- button.Font = Enum.Font.fromValue(0) e defina button.TextFont = "rbxasset://fonts/font.ttf" (depende do executor)
    button.TextWrapped = true
    button.Parent = gui

    -- Arredondar (usando clipe ou imagem, mas vamos usar um retângulo com cantos arredondados via UI Corner)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0) -- 100% arredondado
    corner.Parent = button

    -- Tornar arrastável
    local dragging = false
    local dragStart, buttonStart

    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            buttonStart = button.Position
        end
    end)

    button.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            button.Position = UDim2.new(
                buttonStart.X.Scale,
                buttonStart.X.Offset + delta.X,
                buttonStart.Y.Scale,
                buttonStart.Y.Offset + delta.Y
            )
        end
    end)

    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- Ação ao clicar
    button.MouseButton1Click:Connect(function()
        if autoBlackFlashActive then
            -- Desativar
            autoBlackFlashActive = false
            if blackFlashConnection then
                blackFlashConnection:Disconnect()
                blackFlashConnection = nil
            end
            button.BackgroundColor3 = Color3.fromRGB(30, 30, 30) -- Cor original
        else
            -- Ativar
            autoBlackFlashActive = true
            button.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- Verde ao ativar
            -- Criar loop a cada 0.2 segundos
            blackFlashConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if not autoBlackFlashActive then
                    if blackFlashConnection then
                        blackFlashConnection:Disconnect()
                        blackFlashConnection = nil
                    end
                    return
                end
                -- Executar o código do Black Flash
                local playerChar = game.Players.LocalPlayer.Character
                if playerChar then
                    local moveset = playerChar:FindFirstChild("Moveset")
                    if moveset then
                        local divergentFist = moveset:FindFirstChild("Divergent Fist")
                        if divergentFist then
                            local args = { divergentFist }
                            game:GetService("ReplicatedStorage"):WaitForChild("Knit"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("DivergentFistService"):WaitForChild("RE"):WaitForChild("Activated"):FireServer(unpack(args))
                        end
                    end
                end
                wait(0.2) -- Aguarda 0.2 segundos
            end)
        end
    end)

    return button
end

-- Toggle para ativar/desativar o botão flutuante
MainTab:AddToggle({
    Name = "Auto Black Flash",
    Default = false,
    Callback = function(Value)
        if Value then
            if not blackFlashButton then
                blackFlashButton = createBlackFlashButton()
            else
                blackFlashButton.Visible = true
            end
        else
            if blackFlashButton then
                blackFlashButton.Visible = false
                if autoBlackFlashActive then
                    autoBlackFlashActive = false
                    if blackFlashConnection then
                        blackFlashConnection:Disconnect()
                        blackFlashConnection = nil
                    end
                end
            end
        end
    end
})

-- =====================================================
-- STORE TAB
-- =====================================================
local StoreTab = Window:MakeTab({
    Title = "Store",
    Icon = "ShoppingCart"
})

-- Botão para comprar emote manualmente
StoreTab:AddButton({
    Name = "Buy Emote",
    Callback = function()
        local args = { false, 1 }
        game:GetService("ReplicatedStorage"):WaitForChild("Knit"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("ShopService"):WaitForChild("RE"):WaitForChild("PurchaseEmote"):FireServer(unpack(args))
        Library:Notify("Emote purchase triggered!", 2)
    end
})

-- Toggle auto comprar emote após morte
local autoBuyEmote = false
StoreTab:AddToggle({
    Name = "Auto Buy Emote on Player Death",
    Default = false,
    Callback = function(Value)
        autoBuyEmote = Value
    end
})

-- Função de compra automática
local function buyEmote()
    local args = { false, 1 }
    game:GetService("ReplicatedStorage"):WaitForChild("Knit"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("ShopService"):WaitForChild("RE"):WaitForChild("PurchaseEmote"):FireServer(unpack(args))
end

-- Detectar mortes de players
local function onPlayerAdded(player)
    player.CharacterAdded:Connect(function(character)
        local humanoid = character:WaitForChild("Humanoid")
        humanoid.Died:Connect(function()
            if autoBuyEmote then
                buyEmote()
            end
            if killNotifications then
                Library:Notify(player.Name .. " died 👤", 3)
            end
        end)
    end)
end

for _, player in ipairs(game.Players:GetPlayers()) do
    onPlayerAdded(player)
end
game.Players.PlayerAdded:Connect(onPlayerAdded)

-- =====================================================
-- ESP DUMMY TAB
-- =====================================================
local ESPTab = Window:MakeTab({
    Title = "ESP Dummy",
    Icon = "Eye"
})

local espEnabled = false
local espHighlights = {}

ESPTab:AddToggle({
    Name = "Highlight Dummies (Yellow Outline)",
    Default = false,
    Callback = function(Value)
        espEnabled = Value
        if espEnabled then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj.Name == "Dummy" and obj:IsA("Model") then
                    local highlight = Instance.new("Highlight")
                    highlight.FillTransparency = 1
                    highlight.OutlineColor = Color3.new(1, 1, 0)
                    highlight.OutlineTransparency = 0
                    highlight.Parent = obj
                    table.insert(espHighlights, highlight)
                end
            end
            workspace.DescendantAdded:Connect(function(descendant)
                if not espEnabled then return end
                if descendant.Name == "Dummy" and descendant:IsA("Model") then
                    local highlight = Instance.new("Highlight")
                    highlight.FillTransparency = 1
                    highlight.OutlineColor = Color3.new(1, 1, 0)
                    highlight.OutlineTransparency = 0
                    highlight.Parent = descendant
                    table.insert(espHighlights, highlight)
                end
            end)
        else
            for _, highlight in ipairs(espHighlights) do
                if highlight then
                    highlight:Destroy()
                end
            end
            espHighlights = {}
        end
    end
})

-- =====================================================
-- PARAGRAPHS
-- =====================================================
MainTab:AddParagraph("Info", "Aimbot locks onto nearest Player or Dummy. Smoothness adjustable.\nAuto Black Flash creates a draggable round button.")
StoreTab:AddParagraph("Store Info", "Manual buy button and auto buy after player death.")
ESPTab:AddParagraph("ESP Info", "Highlights all Dummies with a yellow outline, updates automatically.")
