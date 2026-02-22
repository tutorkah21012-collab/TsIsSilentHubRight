local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local isTouch = UserInputService.TouchEnabled

local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

local function refreshChar()
 character = player.Character or player.CharacterAdded:Wait()
 rootPart = character:WaitForChild("HumanoidRootPart")
 humanoid = character:WaitForChild("Humanoid")
end
player.CharacterAdded:Connect(function()
 task.wait(0.5)
 refreshChar()
end)

pcall(function()
 CoreGui:FindFirstChild("SilentHubGrabV2"):Destroy()
end)

local gui = Instance.new("ScreenGui")
gui.Name = "SilentHubGrabV2"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = CoreGui

local scale = (UserInputService.TouchEnabled and 0.9 or 1) * 0.65

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(360*scale,220*scale)
main.Position = UDim2.fromScale(0.5,0.32)
main.AnchorPoint = Vector2.new(0.5,0)
main.BackgroundColor3 = Color3.fromRGB(14,18,24)
main.BorderSizePixel = 0
main.Active = true
main.Parent = gui
Instance.new("UICorner",main).CornerRadius = UDim.new(0,22*scale)

local stroke = Instance.new("UIStroke",main)
stroke.Color = Color3.fromRGB(0,200,255)
stroke.Thickness = 2
stroke.Transparency = 0.15

local gradient = Instance.new("UIGradient",main)
gradient.Color = ColorSequence.new{
 ColorSequenceKeypoint.new(0, Color3.fromRGB(20,30,45)),
 ColorSequenceKeypoint.new(1, Color3.fromRGB(8,12,18))
}

local snowHolder = Instance.new("Frame",main)
snowHolder.Size = UDim2.new(1,0,1,0)
snowHolder.BackgroundTransparency = 1
snowHolder.ClipsDescendants = true
snowHolder.ZIndex = 0

local titleBar = Instance.new("Frame",main)
titleBar.Size = UDim2.new(1,0,0,50*scale)
titleBar.BackgroundTransparency = 1
titleBar.ZIndex = 2

local title = Instance.new("TextLabel",titleBar)
title.Size = UDim2.new(1,-110*scale,1,0)
title.Position = UDim2.new(0,15*scale,0,0)
title.BackgroundTransparency = 1
title.Text = "SilentHub Fast Grab V2"
title.Font = Enum.Font.GothamBold
title.TextSize = 16*scale
title.TextColor3 = Color3.fromRGB(170,230,255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 3

local discordBtn = Instance.new("TextButton",titleBar)
discordBtn.Size = UDim2.fromOffset(75*scale,30*scale)
discordBtn.Position = UDim2.new(1,-130*scale,0.5,-15*scale)
discordBtn.BackgroundColor3 = Color3.fromRGB(25,45,65)
discordBtn.Text = "Discord"
discordBtn.Font = Enum.Font.GothamBold
discordBtn.TextSize = 12*scale
discordBtn.TextColor3 = Color3.fromRGB(170,230,255)
discordBtn.AutoButtonColor = false
discordBtn.ZIndex = 3
Instance.new("UICorner",discordBtn).CornerRadius = UDim.new(1,0)

local minBtn = Instance.new("TextButton",titleBar)
minBtn.Size = UDim2.fromOffset(30*scale,30*scale)
minBtn.Position = UDim2.new(1,-40*scale,0.5,-15*scale)
minBtn.BackgroundColor3 = Color3.fromRGB(25,45,65)
minBtn.Text = "-"
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 18*scale
minBtn.TextColor3 = Color3.fromRGB(170,230,255)
minBtn.AutoButtonColor = false
minBtn.ZIndex = 3
Instance.new("UICorner",minBtn).CornerRadius = UDim.new(1,0)

local content = Instance.new("Frame",main)
content.Size = UDim2.new(1,-30*scale,1,-70*scale)
content.Position = UDim2.new(0,15*scale,0,55*scale)
content.BackgroundTransparency = 1
content.ZIndex = 2

local toggle = Instance.new("TextButton",content)
toggle.Size = UDim2.fromOffset(200*scale,50*scale)
toggle.Position = UDim2.new(0.5,-100*scale,0.25,-25*scale)
toggle.BackgroundColor3 = Color3.fromRGB(20,35,50)
toggle.Text = "Disabled"
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 20*scale
toggle.TextColor3 = Color3.fromRGB(180,220,255)
toggle.AutoButtonColor = false
toggle.ZIndex = 3
Instance.new("UICorner",toggle).CornerRadius = UDim.new(0,16*scale)

local tStroke = Instance.new("UIStroke",toggle)
tStroke.Color = Color3.fromRGB(0,200,255)
tStroke.Transparency = 0.4

local progContainer = Instance.new("Frame",content)
progContainer.Size = UDim2.new(0.9,0,0,14*scale)
progContainer.Position = UDim2.new(0.05,0,0.65,0)
progContainer.BackgroundColor3 = Color3.fromRGB(20,30,40)
progContainer.BorderSizePixel = 0
progContainer.Visible = false
progContainer.ZIndex = 3
Instance.new("UICorner",progContainer).CornerRadius = UDim.new(1,0)

local progFill = Instance.new("Frame",progContainer)
progFill.Size = UDim2.new(0,0,1,0)
progFill.BackgroundColor3 = Color3.fromRGB(0,200,255)
progFill.BorderSizePixel = 0
Instance.new("UICorner",progFill).CornerRadius = UDim.new(1,0)

local progText = Instance.new("TextLabel",progContainer)
progText.Size = UDim2.new(1,0,0,20*scale)
progText.Position = UDim2.new(0,0,0,16*scale)
progText.BackgroundTransparency = 1
progText.Text = ""
progText.Font = Enum.Font.GothamBold
progText.TextSize = 14*scale
progText.TextColor3 = Color3.fromRGB(0,200,255)
progText.TextXAlignment = Enum.TextXAlignment.Center

local enabled = false
local loopActive = false

local function getPos(prompt)
 local p = prompt.Parent
 if p:IsA("BasePart") then return p.Position end
 if p:IsA("Model") then
  local prim = p.PrimaryPart or p:FindFirstChildWhichIsA("BasePart")
  return prim and prim.Position
 end
 if p:IsA("Attachment") then return p.WorldPosition end
 local part = p:FindFirstChildWhichIsA("BasePart", true)
 return part and part.Position
end

local function findNearestStealPrompt()
 if not rootPart then return nil end
 local plots = Workspace:FindFirstChild("Plots")
 if not plots then return nil end
 local myPos = rootPart.Position
 local nearest = nil
 local nearestDist = math.huge
 for _, plot in ipairs(plots:GetChildren()) do
  for _, obj in ipairs(plot:GetDescendants()) do
  if obj:IsA("ProximityPrompt") and obj.Enabled and obj.ActionText == "Steal" then
   local pos = getPos(obj)
   if pos then
    local dist = (myPos - pos).Magnitude
    if dist <= obj.MaxActivationDistance and dist < nearestDist then
    nearest = obj
    nearestDist = dist
    end
   end
  end
  end
 end
 return nearest
end

local function firePrompt(prompt)
 if not prompt then return end
 task.spawn(function()
  pcall(function()
  fireproximityprompt(prompt, 10000)
  prompt:InputHoldBegin()
  task.wait(0.05)
  prompt:InputHoldEnd()
  end)
 end)
end

local function indicateGrab()
 progContainer.Visible = true
 toggle.Visible = false
 progFill:TweenSize(UDim2.new(1,0,1,0), "Out", "Quad", 0.15, true)
 progText.Text = "GRAB"
 task.wait(0.15)
 progFill.Size = UDim2.new(0,0,1,0)
 progText.Text = ""
 progContainer.Visible = false
 toggle.Visible = true
end

local function grabLoop()
 while enabled do
  if humanoid and humanoid.WalkSpeed > 29 then
  local nearest = findNearestStealPrompt()
  if nearest then
   task.wait(0.1)  -- Changed from 0.07 to 0.1
   firePrompt(nearest)
   indicateGrab()
  end
  end
  task.wait(0.3)
 end
 loopActive = false
end

toggle.MouseButton1Click:Connect(function()
 enabled = not enabled
 if enabled then
  toggle.Text = "Enabled"
  TweenService:Create(toggle,TweenInfo.new(0.25),{
  BackgroundColor3 = Color3.fromRGB(0,120,190)
  }):Play()
  tStroke.Transparency = 0
  if not loopActive then
  loopActive = true
  task.spawn(grabLoop)
  end
 else
  toggle.Text = "Disabled"
  TweenService:Create(toggle,TweenInfo.new(0.25),{
  BackgroundColor3 = Color3.fromRGB(20,35,50)
  }):Play()
  tStroke.Transparency = 0.4
 end
end)

discordBtn.MouseButton1Click:Connect(function()
 pcall(function() setclipboard("https://discord.gg/NGEMSasjjG") end)
 discordBtn.Text = "Copied!"
 TweenService:Create(discordBtn,TweenInfo.new(0.2),{
  BackgroundColor3 = Color3.fromRGB(0,180,140)
 }):Play()
 task.wait(1)
 discordBtn.Text = "Discord"
 TweenService:Create(discordBtn,TweenInfo.new(0.2),{
  BackgroundColor3 = Color3.fromRGB(25,45,65)
 }):Play()
end)

local minimized = false
minBtn.MouseButton1Click:Connect(function()
 minimized = not minimized
 if minimized then
  content.Visible = false
  minBtn.Text = "+"
  main:TweenSize(UDim2.fromOffset(360*scale,50*scale),"Out","Quad",0.3,true)
 else
  content.Visible = true
  minBtn.Text = "-"
  main:TweenSize(UDim2.fromOffset(360*scale,220*scale),"Out","Quad",0.3,true)
 end
end)

local dragging = false
local dragStart
local startPos

titleBar.InputBegan:Connect(function(input)
 if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
  dragging = true
  dragStart = input.Position
  startPos = main.Position
 end
end)

UserInputService.InputEnded:Connect(function(input)
 if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
  dragging = false
 end
end)

UserInputService.InputChanged:Connect(function(input)
 if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
  local delta = input.Position - dragStart
  local goal = UDim2.new(
  startPos.X.Scale,
  startPos.X.Offset + delta.X,
  startPos.Y.Scale,
  startPos.Y.Offset + delta.Y
  )
  TweenService:Create(main,TweenInfo.new(0.07,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{
  Position = goal
  }):Play()
 end
end)

local topText = Instance.new("TextLabel",gui)
topText.Size = UDim2.new(1,0,0,35)
topText.Position = UDim2.new(0,0,0,10)
topText.BackgroundTransparency = 1
topText.Text = "https://discord.gg/NGEMSasjjG"
topText.Font = Enum.Font.GothamBold
topText.TextSize = 22
topText.TextStrokeTransparency = 0.5
topText.ZIndex = 100

task.spawn(function()
 local c1 = Color3.fromRGB(170,230,255)
 local c2 = Color3.fromRGB(0,200,255)
 local c3 = Color3.fromRGB(0,150,220)
 local t = 0
 while true do
  t += task.wait()*1.5
  local blend = (math.sin(t)+1)/2
  topText.TextColor3 = c1:Lerp(c2,blend):Lerp(c3,math.abs(math.sin(t*0.6)))
 end
end)

task.spawn(function()
 while true do
  local snow = Instance.new("Frame")
  snow.Size = UDim2.fromOffset(math.random(2,4),math.random(2,4))
  snow.Position = UDim2.new(math.random(),0,-0.1,0)
  snow.BackgroundColor3 = Color3.fromRGB(200,240,255)
  snow.BackgroundTransparency = 0.2
  snow.BorderSizePixel = 0
  snow.ZIndex = 1
  Instance.new("UICorner",snow).CornerRadius = UDim.new(1,0)
  snow.Parent = snowHolder

  local fall = TweenService:Create(snow,TweenInfo.new(math.random(4,7),Enum.EasingStyle.Linear),{
  Position = UDim2.new(snow.Position.X.Scale,0,1.1,0)
  })
  fall:Play()
  fall.Completed:Connect(function()
  snow:Destroy()
  end)

  task.wait(0.12)
 end
end)

local function toggleLoop()
    while isToggled do
        if humanoid and humanoid.WalkSpeed > 29 then
            local nearest = findNearestStealPrompt()
            if nearest then
                task.wait(0.1)  -- Changed from 0.07 to 0.1
                firePrompt(nearest)
                indicateGrab()
            end
        end
        task.wait(0.3)
    end
    toggleLoopActive = false
end# TsIsSilentHubRight
