getgenv().autoRemote = false
getgenv().autoRebirth = false
getgenv().autoLayout = false

function doRemote()
    spawn(function()
        while autoRemote == true do
            game:GetService("ReplicatedStorage").RemoteDrop:FireServer()
            wait()
        end
    end)
end

local findItem = require(game.ReplicatedStorage.FetchItem)
local Player = game.Players.LocalPlayer
repeat 
	wait()
until Player.PlayerGui:FindFirstChild("GUI")

local Cash = Player.PlayerGui.GUI:FindFirstChild("Money")
local MoneyLayout = nil--layout to get money 
local MainLayout = "Layout1"--main layout to load after you get the money for it.
local MoneyLib = require(game.ReplicatedStorage.MoneyLib)
local Withdraw = game.ReplicatedStorage.DestroyAll
local HasItem = game.ReplicatedStorage.HasItem
local autoRebirth = true
local CanRebirth = true
local WaitToSkip = 0
local WaitToRebirth = 0

function Convert(Table)
    print("Convert start")
	local NewTable = {}
	for i,v in pairs(Table) do
		print("Check "..v.ItemId)
		local Add = NewTable[v.ItemId]
		if Add then
			print("Found")
			NewTable[v.ItemId] = NewTable[v.ItemId] +1
		else
			print("Add")
			NewTable[v.ItemId] = 1
		end
	end
	print("Convert end")
	return NewTable
end

function CalculatePrice()
    print("Calc  start")
	local RealLayout = Player.Layouts:FindFirstChild(MainLayout)
	local layoutItems = game.HttpService:JSONDecode(RealLayout.Value)
	local Price = 0
	if layoutItems then 
		local ItemTable = Convert(layoutItems)
		if ItemTable then 
			print("New Table")
			for Item,Count in pairs(ItemTable) do
			    spawn(function()
			    print("Here "..Item,Count)
				--print("Here ".. _,Item)
				
				local PlayerHas = HasItem:InvokeServer(Item)
				local Needed = Count-PlayerHas
				if Needed <= 0 then 
				else 
				local RealItem = findItem:Get(tonumber(Item))
				Price =Price + RealItem.Cost.Value*Needed
				print(Price)
				end 
				print("Item "..PlayerHas)
				end)
		  end
		end
	end
	wait(0.5)
	print("Calc End")
	return Price
end
function doRebirth()--function to load the layouts includes calculating the money needed
    print("Do rebirth func")
    Withdraw:InvokeServer()
    if MoneyLayout ~=nil then 
        print("Need money")
	local LayoutPrice = CalculatePrice()
	print("Price "..LayoutPrice)
	if Cash.Value >= LayoutPrice then 
	    print("You got the cash")
		game.ReplicatedStorage.Layouts:InvokeServer("Load",MainLayout)
		else
		    print("Loading MoneyLayout")
		game.ReplicatedStorage.Layouts:InvokeServer("Load",MoneyLayout)
		repeat 
			wait()
		until Cash.Value >= LayoutPrice
		print("Load main")
		Withdraw:InvokeServer()
        game.ReplicatedStorage.Layouts:InvokeServer("Load",MainLayout)

	end
	else
	 game.ReplicatedStorage.Layouts:InvokeServer("Load",MainLayout)   
    end
end
function WaitForRebirth()
    WaitToRebirth = tonumber(WaitToRebirth)
    local Time = 0
    if WaitToRebirth <= 0 then CanRebirth = true end
    repeat 
        wait(0.1)
        Time = Time +0.1
    until Time == WaitToRebirth
    CanRebirth = true
end

Cash.Changed:Connect(function()-- detects change to money and then if there is enough to rebirth it will the load your chosen layout.
	local RBP = MoneyLib.RebornPrice(Player) --Players rebirth price
	if getgenv().autoRebirth and CanRebirth then
	    print("Rebirth true")
		if WaitToSkip >0 then
			local SkipPrice = RBP *(WaitToSkip*1000)
			if Cash.Value >= SkipPrice then
				game.ReplicatedStorage.Rebirth:InvokeServer()
				doRebirth()
			end
		elseif Cash.Value >= RBP then
		    print("Fire rebirth")
			game.ReplicatedStorage.Rebirth:InvokeServer()
			doRebirth()
		end
		WaitForRebirth()
	end
end)


--Add code to for button to change auto rebirth to true or false and fire Load()when making it true
--Use a text box to set wait to skip number. make sure to convert it from a sting to a number with tonumber()

function getCurrentPlayerPOS()
    local plyr = game.Players.LocalPlayer;
    if plyr.Character then
        return plyr.Character.HumnaoidRootPart.Position
    end
    return false;
end

function teleportTO(placeCFrame)
    local plyr = game.Players.LocalPlayer;
    if plyr.Character then
        plyr.Character.HumanoidRootPart.CFrame = placeCFrame;
    end
end
function teleportWorld(world)
    if game:GetService("Workspace").Map.TeleporterModel:FindFirstChild(world) then
        teleportTO(game:GetService("Workspace").Map.TeleporterModel[world].CFrame)
    end
end

local library = loadstring(game:HttpGet(('https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/wall%20v3')))()

local w = library:CreateWindow("Miners Haven") -- Creates the window

local b = w:CreateFolder("Autofarm")

local c = w:CreateFolder("Teleport")

b:Toggle("Auto Rebirth",function(bool)
    print("Change ARB")
    getgenv().autoRebirth = bool
    print('Auto Rebirth is: ', bool)
    if bool then
        print("ARB true")
        spawn(function()
        doRebirth();
        end)
    end
end)

b:Box("Wait To Rebirth","number",function(value) -- "number" or "string"
   print(value)
   WaitToRebirth = tonumber(value)
end)

b:Toggle("Auto Remote",function(bool)
    getgenv().autoRemote = bool
    print('Auto Remote is: ', bool);
    if bool then
        doRemote();
    end
end)
b:Dropdown("Main Layout",{"Layout1","Layout2","Layout3"},true,function(mob) --true/false, replaces the current title "Dropdown" with the option that t
     print(mob)
     MainLayout = mob
end)
b:Dropdown("Money Layout",{"Layout1","Layout2","Layout3"},true,function(mob) --true/false, replaces the current title "Dropdown" with the option that t
     print(mob)
     MoneyLayout = mob
end)

b:Slider("Wait To Skip",{
    min = 0; -- min value of the slider
    max = 20; -- max value of the slider
    precise = false; -- max 2 decimals
},function(value)
    WaitToSkip = value
     print(value)
end)

local selectedWorld;

c:Dropdown("Places",{"TowerInterior","McDookShop","Temple"},true,function(value)
    selectedWorld = value;
    print(value)
end)

c:Button("Teleport Selection",function()
    if selectedWorld then
        teleportWorld(selectedWorld)
    end
end)



b:DestroyGui(function()
    print("Bye bye")
    getgenv().autoRemote = false
    getgenv().autoRebirth = false
    getgenv().autoLayout = false
end)




-- b:Label("Pretty Useless NGL",{
--     TextSize = 25; -- Self Explaining
--     TextColor = Color3.fromRGB(255,255,255); -- Self Explaining
--     BgColor = Color3.fromRGB(69,69,69); -- Self Explaining
    
-- }) 

-- b:Slider("Slider",{
--     min = 10; -- min value of the slider
--     max = 50; -- max value of the slider
--     precise = true; -- max 2 decimals
-- },function(value)
--     print(value)
-- end)

-- b:Dropdown("Dropdown",{"A","B","C"},true,function(mob) --true/false, replaces the current title "Dropdown" with the option that t
--     print(mob)
-- end)

-- b:Bind("Bind",Enum.KeyCode.C,function() --Default bind
--     print("Yes")
-- end)

-- b:ColorPicker("ColorPicker",Color3.fromRGB(255,0,0),function(color) --Default color
--     print(color)
-- end)

-- b:Box("Box","number",function(value) -- "number" or "string"
--     print(value)
-- end)
