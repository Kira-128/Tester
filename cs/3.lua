local Theme = {
    Colors = {
        -- 🌿 Aksen Utama (Mint/Neon Green - Pengganti Orange Lynx)
        primary   = Color3.fromRGB(110, 231, 183), -- Warna utama (Mint Green)
        secondary = Color3.fromRGB(150, 255, 200), -- Sedikit lebih terang
        accent    = Color3.fromRGB(110, 231, 183), -- Samakan dengan primary untuk konsistensi
        
        -- 🌑 Latar Belakang (Hierarki Dark Green ala Lynx)
        -- Lynx pakai (15,10,5) untuk cokelat. Kita pakai (10,15,10) untuk hijau.
        bg        = Color3.fromRGB(10, 12, 10),    -- Paling gelap (Overlay / Layar belakang)
        panel     = Color3.fromRGB(15, 18, 15),    -- MainFrame
        bg2       = Color3.fromRGB(25, 30, 25),    -- Header / Sidebar
        bg3       = Color3.fromRGB(35, 45, 35),    -- Section / Kotak (Lebih terang)
        bg4       = Color3.fromRGB(48, 60, 48),    -- Tombol / Input (Paling terang)

        -- 📝 Teks (Warm White - Putih dengan tint hijau tipis)
        text      = Color3.fromRGB(240, 250, 240),
        textDim   = Color3.fromRGB(190, 210, 190),
        textDim2  = Color3.fromRGB(130, 150, 130),

        -- 🚦 Status (Untuk fitur Danger/Warning)
        red       = Color3.fromRGB(230, 70, 70),
        yellow    = Color3.fromRGB(255, 200, 80),
        blue      = Color3.fromRGB(80, 160, 240),
        green     = Color3.fromRGB(110, 231, 183),

        -- 🔲 Garis Tepi (Border/Stroke)
        stroke    = Color3.fromRGB(55, 75, 55),
        stroke2   = Color3.fromRGB(70, 95, 70),
        
        -- Transparan
        transparent = Color3.fromRGB(0, 0, 0),
    },

    Icons = {
        combat     = "rbxassetid://99199363807265",
        visual     = "rbxassetid://127234874352422",
        settings   = "rbxassetid://106205298246017",
        config     = "rbxassetid://112330254035751",
        teleport   = "rbxassetid://137091405832737",
        search     = "rbxassetid://72296609649861",
        automation = "rbxassetid://137660494219613",
        afk        = "rbxassetid://73746161985",

        logo     = "rbxassetid://101516376369531",
        icon     = "rbxassetid://80944443292236",
    },

    Font = {
        bold   = Enum.Font.GothamBold,
        norm   = Enum.Font.Gotham,
        medium = Enum.Font.GothamMedium,
    },

    Radius = {
        small  = UDim.new(0, 4),
        medium = UDim.new(0, 6),
        large  = UDim.new(0, 10),
        round  = UDim.new(1, 0),
    },
}

_G.STHAIN.Theme = Theme
