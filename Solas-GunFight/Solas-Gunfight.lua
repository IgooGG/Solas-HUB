local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local AIM_ENABLED = false
local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")

-- Function to find the head of the target player
local function getHead(targetPlayer)
    local character = targetPlayer.Character
    if character then
        return character:FindFirstChild("Head")
    end
    return nil
end

-- Function to check if a target is in the player's line of sight
local function isInLineOfSight(targetPart)
    local origin = camera.CFrame.Position
    local direction = (targetPart.Position - origin).unit * 1000
    local ray = Ray.new(origin, direction)
    local hit, position = workspace:FindPartOnRay(ray, player.Character)

    return hit and hit:IsDescendantOf(targetPart.Parent)
end

-- Function to check if teams exist
local function teamsExist()
    for _, targetPlayer in pairs(game.Players:GetPlayers()) do
        if targetPlayer.Team then
            return true
        end
    end
    return false
end

-- Function to check if a player is an enemy (if teams exist)
local function isEnemy(targetPlayer)
    if teamsExist() then
        return targetPlayer.Team ~= player.Team
    else
        return true  -- If no teams, consider everyone as a target
    end
end

-- Function to check if a player is alive
local function isAlive(targetPlayer)
    local character = targetPlayer.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid and humanoid.Health > 0 then
            return true
        end
    end
    return false
end

-- Function to check if a player has a forcefield
local function hasForceField(targetPlayer)
    local character = targetPlayer.Character
    if character then
        return character:FindFirstChild("ForceField") ~= nil
    end
    return false
end

-- Function to aim at the head of the target player
local function aimAtHead()
    for _, targetPlayer in pairs(game.Players:GetPlayers()) do
        if targetPlayer ~= player and isEnemy(targetPlayer) and isAlive(targetPlayer) and not hasForceField(targetPlayer) then
            local head = getHead(targetPlayer)
            if head and isInLineOfSight(head) then
                -- Aim the camera at the head
                camera.CFrame = CFrame.new(camera.CFrame.Position, head.Position)
                break
            end
        end
    end
end

-- Function to toggle aim assist
local function toggleAim()
    AIM_ENABLED = not AIM_ENABLED
    if AIM_ENABLED then
        Rayfield:Notify({
           Title = "FullAim",
           Content = "FullAim has been enabled",
           Duration = 3,
        })
    else
        Rayfield:Notify({
           Title = "FullAim",
           Content = "FullAim has been disabled",
           Duration = 3,
        })
    end
end

-- Bind the toggle function to the "P" key
UserInputService.InputBegan:Connect(function(input, processed)
    if input.KeyCode == Enum.KeyCode.P and not processed then
        toggleAim()
    end
end)

-- Continuously check for aim assist when enabled
game:GetService("RunService").RenderStepped:Connect(function()
    if AIM_ENABLED then
        aimAtHead()
    end
end)

local Window = Rayfield:CreateWindow({
   Name = "Solas GunFight",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "Solas HUB",
   LoadingSubtitle = "by IgooGG",
   Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "Big Hub"
   },

   Discord = {
      Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },

   KeySystem = true, -- Set this to true to use our key system
   KeySettings = {
      Title = "Solas",
      Subtitle = "Key System",
      Note = "This is Solas utils for GunFight games. The key is VeryPrivate..", -- Use this to tell the user how to get a key
      FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = false, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"SolasIgooGG.VeryPrivate"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})

local Tab = Window:CreateTab("AutoAim")

local Section = Tab:CreateSection("FullAim")

local Toggle = Tab:CreateToggle({
   Name = "FullAim",
   CurrentValue = false,
   Flag = "Toggle1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
      toggleAim()
   end,
})
