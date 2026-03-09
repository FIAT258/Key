-- Load WindUI
local WindUI = loadstring(game:HttpGet(
"https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
))()

local Window = WindUI:CreateWindow({
    Title = "XFIREX HUB (Key System)",
    Icon = "door-open",
    Author = "XFIREX HUB",
    Folder = "XFIREXHub",

    Size = UDim2.fromOffset(580, 460),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(900, 560),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 200,
})








-------------------------------------------------
-- TAB KEY SYSTEM
-------------------------------------------------

local KeyTab = Window:Tab({
    Title = "Key System",
    Icon = "key",
})

local enteredKey = ""

KeyTab:Input({
    Title = "Enter Key",
    Desc = "Paste your key here",
    Placeholder = "Enter key...",
    Callback = function(text)
        enteredKey = text
    end
})

-------------------------------------------------
-- CHECK KEY
-------------------------------------------------

KeyTab:Button({
    Title = "Check Key",
    Callback = function()

        if enteredKey ~= "#fire#hubx130key18722--KEYwalfy" then

            WindUI:Notify({
                Title = "Key System",
                Content = "Invalid or expired key.",
                Duration = 4
            })

            return
        end

        WindUI:Notify({
            Title = "Key System",
            Content = "Key accepted!",
            Duration = 3
        })

        -------------------------------------------------
        -- EXECUTE SCRIPTS BY GAME ID
        -------------------------------------------------

        local id = game.PlaceId

        if id == 4924922222 then

            loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/FIAT258/fiathub2/main/XFireXhubbeta.lua"
            ))()

        elseif id == 2753915549
        or id == 4442272183
        or id == 7449423635 then

            loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/FIAT258/fiathub/main/xfirexbloxfruit(BETATEST).lua"
            ))()

        end

        -- Destroy UI after execution
        WindUI:Destroy()

    end
})

-------------------------------------------------
-- GET KEY
-------------------------------------------------

KeyTab:Button({
    Title = "Get Key",
    Callback = function()

        setclipboard("Kj")

        WindUI:Notify({
            Title = "Key copied",
            Content = "Key content copied to clipboard.",
            Duration = 3
        })

    end
})

-------------------------------------------------
-- TAB DISCORD / CREDITS
-------------------------------------------------

local CreditsTab = Window:Tab({
    Title = "Discord / Credits",
    Icon = "users",
})

CreditsTab:Button({
    Title = "Get Discord",
    Callback = function()

        setclipboard("https://discord.gg/rUVF64QWEN")

        WindUI:Notify({
            Title = "Discord",
            Content = "Discord link copied.",
            Duration = 3
        })

    end
})

CreditsTab:Paragraph({
    Title = "Credits",
    Desc =
[[Interface: ChatGPT 👤
Creator: JX1 👑
Gays: lorenzo 🏳️‍🌈 kkk]]
})

-------------------------------------------------
-- TAB EXTRA
-------------------------------------------------

local ExtraTab = Window:Tab({
    Title = "Extra",
    Icon = "star",
})

-------------------------------------------------
-- BIG HEAD LOL
-------------------------------------------------

ExtraTab:Button({
    Title = "CABEÇA GIGANTE LOL",
    Callback = function()

        local player = game.Players.LocalPlayer

        local function apply()

            local char = player.Character
            if not char then return end

            local head = char:FindFirstChild("Head")

            if head then
                head.Size = Vector3.new(5,5,5)
            end

        end

        apply()

        player.CharacterAdded:Connect(function()

            task.wait(12)
            apply()

        end)

    end
})
