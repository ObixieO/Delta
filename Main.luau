local DefaultScript = [[

--忍者UI美化
--By Obi_xieO

]]

local Delta = {
	UiTransparency = {},
	Closed = true,
	Connections = {},
	UiOpenButtonPosition = UDim2.new(.5,0,0,58),
	Scripts = {},
	CurrentScript = nil,
	Highlighter = {},
	DeltaUi = {},
	NavIslandPositions = {
		Top = {
			Position = UDim2.new(0.5,0,0,58),
		},
		Bottom = {
			Position = UDim2.new(0.5,0,1,-40),
		},
		Right = {
			Size = UDim2.fromOffset(60,230),
			Position = UDim2.new(.95,0,.5,58),
			Vertical = true
		},
	},
	Openned = true,
	Misc = {},
}

local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LogService = game:GetService("LogService")
local ScriptContext = game:GetService("ScriptContext")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local Player = Players.LocalPlayer

local function Tween(Obj,Info,Properties)
	TweenService:Create(Obj,TweenInfo.new(unpack(Info)),Properties):Play()
end
local function Create(ClassName,Properties)
	const I = Instance.new(ClassName)
	for i,v in Properties do
		I[i] = v
	end
	return I
end

local function GetInScreenPosition(Position, Size)
	local C = workspace.Camera
	if not C then return Position end
	local screenSize = C.ViewportSize

	return Vector2.new(
		math.clamp(Position.X, 0, math.max(0, screenSize.X - Size.X)),
		math.clamp(Position.Y, 0, math.max(0, screenSize.Y - Size.Y))
	)
end

local function fmtTime(sec)
	if type(sec) ~= "number" or sec ~= sec then return "0:00" end
	sec = math.max(0, math.floor(sec))

	local d = math.floor(sec / 86400)
	local h = math.floor((sec % 86400) / 3600)
	local m = math.floor((sec % 3600) / 60)
	local s = sec % 60

	if d > 0 then
		return string.format("%d:%02d:%02d:%02d", d, h, m, s)
	elseif h > 0 then
		return string.format("%d:%02d:%02d", h, m, s)
	else
		return string.format("%d:%02d", m, s)
	end
end

local function md5(msg)
	local function band(a,b) local r,p=0,1 for _=1,32 do local x,y=a%2,b%2 if x==1 and y==1 then r=r+p end a=(a-x)/2 b=(b-y)/2 p=p*2 end return r end
	local function bor(a,b) local r,p=0,1 for _=1,32 do local x,y=a%2,b%2 if x==1 or y==1 then r=r+p end a=(a-x)/2 b=(b-y)/2 p=p*2 end return r end
	local function bxor(a,b) local r,p=0,1 for _=1,32 do local x,y=a%2,b%2 if x~=y then r=r+p end a=(a-x)/2 b=(b-y)/2 p=p*2 end return r end
	local function lrot(x,c) return (x*2^c)%2^32 + math.floor(x/2^(32-c)) end
	local function add(a,b) return (a+b)%2^32 end
	local s = {7,12,17,22,7,12,17,22,7,12,17,22,7,12,17,22,
		5,9,14,20,5,9,14,20,5,9,14,20,5,9,14,20,
		4,11,16,23,4,11,16,23,4,11,16,23,4,11,16,23,
		6,10,15,21,6,10,15,21,6,10,15,21,6,10,15,21}
	local K = {}
	for i=1,64 do K[i]=math.floor(math.abs(math.sin(i))*2^32) end
	local len = #msg * 8
	msg = msg .. "\128" .. string.rep("\0", (56 - (#msg+1) % 64) % 64)
	msg = msg .. string.pack("<I8", len)
	local a0,b0,c0,d0 = 0x67452301,0xefcdab89,0x98badcfe,0x10325476
	for chunk=1,#msg,64 do
		local M = {}
		for i=1,16 do M[i] = string.unpack("<I4", msg, chunk+(i-1)*4) end
		local A,B,C,D = a0,b0,c0,d0
		for i=1,64 do
			local F,g
			if i<=16 then F=bor(band(B,C),band(bxor(B,0xffffffff),D)); g=i-1
			elseif i<=32 then F=bor(band(D,B),band(bxor(D,0xffffffff),C)); g=(5*(i-1)+1)%16
			elseif i<=48 then F=bxor(bxor(B,C),D); g=(3*(i-1)+5)%16
			else F=bxor(C,bor(B,bxor(D,0xffffffff))); g=(7*(i-1))%16 end
			local tmp = D
			D = C
			C = B
			B = add(B, lrot(add(add(A,F),add(K[i],M[g+1])), s[i]))
			A = tmp
		end
		a0=add(a0,A); b0=add(b0,B); c0=add(c0,C); d0=add(d0,D)
	end
	return string.pack("<I4I4I4I4", a0,b0,c0,d0)
end

if RunService:IsStudio() then
	Delta.Ui = Player.PlayerGui:WaitForChild("Delta")
else
	if not isfolder("SavedScripts") then
		makefolder("SavedScripts")
	end

	for i,v in gethui():GetChildren() do
		if (v:FindFirstChild("MainScript") and v:FindFirstChild("UILibrary")) then
			Delta.DeltaUi.Main = v
		elseif (#v:GetChildren() == 1 and v:FindFirstChildOfClass("ImageButton") and v:FindFirstChildOfClass("ImageButton").Image:find("logo.png")) then
			Delta.DeltaUi.Logo = v
		end
	end

	local Loadedevent = Instance.new("BindableEvent")

	Delta.Ui = game:GetObjects(getcustomasset("DeltaUiCached"))[1]
	Delta.Ui.Parent = gethui()
end

for i,v in Delta.Ui.NavIsland.Buttons:GetChildren() do
	if v:IsA("TextButton") then
		Delta.UiTransparency[v] = {
			BackgroundTransparency = v.BackgroundTransparency,
			TextTransparency = v.TextTransparency,
		}

		if v:FindFirstChild("UIStroke") then
			Delta.UiTransparency[v.UIStroke] = {
				Transparency = v.UIStroke.Transparency
			}
		end
	end
end

function Delta:OpenUi()
	if Delta.Openned then return end
	Delta.Openned = true
	local Id = tick()
	Delta.OpenId = Id

	Delta.Ui.ContentIsland.Visible = true

	Tween(Delta.Ui.ContentIsland,{.25},{
		GroupTransparency = 0
	})
	Tween(Delta.Ui.ContentIsland.UIShadow,{.25},{
		Transparency = .5
	})
	Tween(Delta.Ui.ContentIsland.UIStroke,{.25},{
		Transparency = .5
	})

	if Delta.Ui.NavIsland:FindFirstChild("Logo") then
		Tween(Delta.Ui.NavIsland.Logo,{.1},{
			ImageTransparency = 1
		})
	end

	for i,v in Delta.Ui.NavIsland.Buttons:GetChildren() do
		if v:IsA("TextButton") then
			v.Visible = true

			Tween(v,{.1},{
				BackgroundTransparency = Delta.UiTransparency[v].BackgroundTransparency,
				TextTransparency = Delta.UiTransparency[v].TextTransparency,
			})
			Tween(v.UIStroke,{.1},{
				Transparency = Delta.UiTransparency[v.UIStroke].Transparency
			})
		end
	end

	task.delay(.1,function()
		if Delta.OpenId ~= Id then
			return
		end

		Delta.Ui.NavIsland.DragButton.Visible = false
	end)

	local CurrentConfig = Delta.NavIslandPositions[Delta.Settings.CurrentSettings.CurrentNavIslandPosition[1]]

	Tween(Delta.Ui.NavIsland,{.1},{
		Size = CurrentConfig.Size or UDim2.fromOffset(320,44),
		Position = CurrentConfig.Position
	})
	Delta.Ui.NavIsland.Buttons.UIListLayout.FillDirection = CurrentConfig.Vertical and Enum.FillDirection.Vertical or Enum.FillDirection.Horizontal

	if Delta.Connections.Drag then
		Delta.Connections.Drag:Disconnect()
	end
end

function Delta:CloseUi()
	if not Delta.Openned then return end
	Delta.Openned = false
	local Id = tick()
	Delta.CloseId = Id

	if Delta.Ui.NavIsland:FindFirstChild("Logo") then
		Tween(Delta.Ui.NavIsland.Logo,{.1},{
			ImageTransparency = 0
		})
	end
	Tween(Delta.Ui.ContentIsland,{.25},{
		GroupTransparency = 1
	})
	Tween(Delta.Ui.ContentIsland.UIShadow,{.25},{
		Transparency = 1
	})
	Tween(Delta.Ui.ContentIsland.UIStroke,{.25},{
		Transparency = 1
	})

	for i,v in Delta.Ui.NavIsland.Buttons:GetChildren() do
		if v:IsA("TextButton") then
			Tween(v,{.1},{
				BackgroundTransparency = 1,
				TextTransparency = 1,
			})
			Tween(v.UIStroke,{.1},{
				Transparency = 1
			})
			task.delay(.1,function()
				if Delta.CloseId ~= Id then
					return
				end

				v.Visible = false
			end)
		end
	end

	task.delay(.1,function()
		if Delta.CloseId ~= Id then
			return
		end
		Delta.Ui.ContentIsland.Visible = false
		Delta.Ui.NavIsland.DragButton.Visible = true
	end)

	Tween(Delta.Ui.NavIsland,{.1},{
		Size = UDim2.fromOffset(44,44),
		Position = Delta.UiOpenButtonPosition
	})

	local NavIsland = Delta.Ui.NavIsland
	local DragButton = NavIsland.DragButton

	Delta.Connections.Drag = DragButton.MouseButton1Down:Connect(function()
		local MousePos = UserInputService:GetMouseLocation()
		local ViewportSize = workspace.CurrentCamera.ViewportSize

		local Offset = Vector2.new(
			MousePos.X / ViewportSize.X - NavIsland.Position.X.Scale,
			MousePos.Y / ViewportSize.Y - NavIsland.Position.Y.Scale
		)

		local R = RunService.RenderStepped:Connect(function()
			local MousePos = UserInputService:GetMouseLocation()
			local ViewportSize = workspace.CurrentCamera.ViewportSize

			local TargetX = MousePos.X / ViewportSize.X - Offset.X
			local TargetY = MousePos.Y / ViewportSize.Y - Offset.Y

			local FinalPosition = UDim2.new(TargetX, 0, TargetY, 58)
			Delta.UiOpenButtonPosition = FinalPosition

			Tween(NavIsland, {0.1}, {
				Position = FinalPosition
			})
		end)

		local Release
		Release = UserInputService.InputEnded:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1
				or Input.UserInputType == Enum.UserInputType.Touch then
				R:Disconnect()
				Release:Disconnect()
			end
		end)
	end)
end

function Delta:TogglePage(Page)
	if Delta.Toggleing then
		return
	end

	task.spawn(function()
		Delta.Toggleing = true

		Tween(Delta.Ui.ContentIsland,{.1},{
			GroupTransparency = 1
		})
		for i,v in Delta.Ui.NavIsland.Buttons:GetChildren() do
			if v:IsA("TextButton") and Delta.Ui.ContentIsland.Main:FindFirstChild(v.Name) then
				Tween(v,{.1},{
					BackgroundColor3 = v.Name == Page and Color3.fromRGB(120, 180, 255) or Color3.fromRGB(28, 32, 46),
					BackgroundTransparency = v.Name == Page and 0.55 or 0.9,
					TextColor3 = v.Name == Page and Color3.fromRGB(240, 244, 255) or Color3.fromRGB(150, 160, 190),
				})
				Tween(v.UIStroke,{.1},{
					Color = v.Name == Page and Color3.fromRGB(120, 180, 255) or Color3.fromRGB(28, 32, 46),
					Transparency = v.Name == Page and 0.2 or 0.95,
				})
			end
		end

		task.wait(.1)
		for i,v in Delta.Ui.ContentIsland.Main:GetChildren() do
			v.Visible = false
		end

		local Target = Delta.Ui.ContentIsland.Main[Page]
		Target.Visible = true

		Tween(Delta.Ui.ContentIsland,{.1},{
			GroupTransparency = 0
		})
		task.wait(.1)

		Delta.Toggleing = nil
	end)
end

function Delta:OpenScript(Name)
	local Script = Delta.Scripts[Name]

	if not Script then
		return
	end

	local CodeFrame = Delta.Ui.ContentIsland.Main.code

	if Delta.CurrentScript then
		Tween(Delta.CurrentScript.Button,{.25},{
			BackgroundColor3 = Color3.fromRGB(28, 32, 46)
		})
		Tween(Delta.CurrentScript.Button.UIStroke,{.25},{
			Color = Color3.fromRGB(120, 180, 255),
			Transparency = 0.8,
		})
	end

	Tween(Script.Button,{.25},{
		BackgroundColor3 = Color3.fromRGB(131, 216, 255)
	})
	Tween(Script.Button.UIStroke,{.25},{
		Color = Color3.fromRGB(131, 216, 255),
		Transparency = 0.2,
	})

	CodeFrame.Text.Code.ScrollingFrame.TextBox.Text = Script.Source

	Delta.CurrentScript = Script

end

local function GetScriptName(Name)
	local FinalName = Name
	if Delta.Scripts[Name] then
		local c = 1
		while Delta.Scripts[FinalName] do
			FinalName = Name.." "..tostring(c)
			c += 1
		end
	end
	return FinalName
end

function Delta:AddScript(Name,scr)
	scr = scr or ""
	local FinalName = GetScriptName(Name)
	local Scripts = Delta.Ui.ContentIsland.Main.code.Buttons.Scripts
	local NewScriptButton = Scripts.UIListLayout.TextButton:Clone()
	NewScriptButton.Name = FinalName
	NewScriptButton.Text = FinalName
	NewScriptButton.Parent = Scripts

	NewScriptButton.MouseButton1Down:Connect(function()
		local Preessed = false
		local c
		local b;b = NewScriptButton.MouseButton1Up:Connect(function()
			Delta:OpenScript(FinalName)
			Preessed = true
			c:Disconnect()
			b:Disconnect()
		end)
		c = UserInputService.InputEnded:Connect(function(input)
			if input == Enum.UserInputType.MouseButton1 or input == Enum.UserInputType.Touch then
				b:Disconnect()
				c:Disconnect()
			end
		end)

		task.delay(1,function()
			if not Preessed then
				b:Disconnect()
				c:Disconnect()
				NewScriptButton.TextTransparency = 1

				local TextBox = NewScriptButton.TextBox
				TextBox.Visible = true
				TextBox:CaptureFocus()
			end
		end)
	end)

	NewScriptButton.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
		NewScriptButton.Text = NewScriptButton.TextBox.Text
	end)

	NewScriptButton.TextBox.FocusLost:Connect(function()
		NewScriptButton.TextBox.Visible = false

		local OldScript = Delta.Scripts[FinalName]

		Delta.Scripts[FinalName] = nil
		FinalName = GetScriptName(NewScriptButton.TextBox.Text)
		Delta.Scripts[FinalName] = OldScript
		NewScriptButton.Name = FinalName
		NewScriptButton.Text = FinalName
		NewScriptButton.TextTransparency = 0
	end)

	Delta.Scripts[FinalName] = {
		Source = scr,
		Button = NewScriptButton
	}
	return FinalName
end

function Delta:RemoveScript(Name)
	if Delta.Scripts[Name] then
		Delta.Scripts[Name] = nil
	end

	local ScriptButton = Delta.Ui.ContentIsland.Main.code.Buttons.Scripts:FindFirstChild(Name)
	if ScriptButton then
		ScriptButton:Destroy()
	end
end

local ConsoleUi = Delta.Ui.ContentIsland.Main.console

local function AutoScroll(scrollingframe)
	local stickToBottom = true
	local internalScroll = false

	local function getMaxScrollY(sf: ScrollingFrame): number
		return math.max(0, sf.AbsoluteCanvasSize.Y - sf.AbsoluteWindowSize.Y)
	end

	local function scrollToBottom()
		local maxY = getMaxScrollY(scrollingframe)
		internalScroll = true
		scrollingframe.CanvasPosition = Vector2.new(scrollingframe.CanvasPosition.X, maxY)
		task.defer(function()
			internalScroll = false
		end)
	end

	scrollingframe:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		if internalScroll then return end
		stickToBottom = scrollingframe.CanvasPosition.Y >= getMaxScrollY(scrollingframe) - 2
	end)
	scrollingframe:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(function()
		if not stickToBottom then return end
		scrollToBottom()
	end)
	scrollingframe:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(function()
		if not stickToBottom then return end
		scrollToBottom()
	end)

end


function Delta:AddConsoleMessage(Side, Message, MessageType)
	Delta.SmallConsole:AddConsoleMessage(Side,Message,MessageType)

	local t = os.date("*t")
	local str = string.format("%02d:%02d:%02d", t.hour, t.min, t.sec)

	local Text = tostring(Message)
	local NewText = ConsoleUi:FindFirstChild(Side).UIListLayout.TextLabel:Clone()

	NewText.RichText = true
	NewText.Text = string.format('<font color="#FFFFFF">[%s]</font> %s', str, Text)
	NewText.TextSize = 14

	NewText.TextColor3 =
		(MessageType == Enum.MessageType.MessageError   and Color3.fromRGB(231, 87, 80))  or
		(MessageType == Enum.MessageType.MessageWarning and Color3.fromRGB(245, 118, 48)) or
		(MessageType == Enum.MessageType.MessageInfo    and Color3.fromRGB(107, 180, 255)) or
		Color3.fromRGB(255, 255, 255)

	if (MessageType == Enum.MessageType.MessageError) or (MessageType == Enum.MessageType.MessageWarning) then
		local n = NewText.FontFace
		n.Weight = Enum.FontWeight.ExtraBold
		NewText.FontFace = n
	end

	NewText.Parent = ConsoleUi:FindFirstChild(Side)
end

function Delta:RefreshSavedScript()
	local files = listfiles("SavedScripts")

	local ScriptsUi = Delta.Ui.ContentIsland.Main.saved

	for i,v in ScriptsUi.ScrollingFrame:GetChildren() do
		if v:IsA("Frame") then
			v:Destroy()
		end
	end

	for i,v in files do
		local scriptname = string.sub(v,#("SavedScripts/")+1)
		local NewSavedScriptButton = ScriptsUi.ScrollingFrame.UIListLayout.Frame:Clone()

		NewSavedScriptButton.Parent = ScriptsUi.ScrollingFrame
		NewSavedScriptButton.TextLabel.Text = scriptname
		NewSavedScriptButton.Buttons.Run.MouseButton1Click:Connect(function()
			loadstring(readfile(v))()
		end)
		NewSavedScriptButton.Buttons.Delete.MouseButton1Click:Connect(function()
			delfile(v)
			Delta:RefreshSavedScript()
		end)
		NewSavedScriptButton.Buttons.Open.MouseButton1Click:Connect(function()
			Delta:OpenScript(Delta:AddScript(scriptname,readfile(v)))
			Delta:TogglePage("code")
		end)
	end
end

function Delta:Init()
	const DragButton = Create("TextButton",{
		Size = UDim2.fromScale(1,1),
		Text = "",
		BackgroundTransparency = 1,
		Parent = Delta.Ui.NavIsland,
		Name = "DragButton"
	})

	DragButton.MouseButton1Down:Connect(function()
		local T = tick()

		local Ended
		Ended = UserInputService.InputEnded:Connect(function(Input)
			if (Input.UserInputType == Enum.UserInputType.MouseButton1
				or Input.UserInputType == Enum.UserInputType.Touch)
				and tick()-T <= .25 then

				Delta:OpenUi()
				Ended:Disconnect()
			end
		end)

	end)

	Delta.Ui.NavIsland.Buttons.Close.MouseButton1Click:Connect(function()
		Delta:CloseUi()
	end)

	local Highlighter = Delta.Highlighter.new()

	local CodeFrame = Delta.Ui.ContentIsland.Main.code.Text.Code
	local CodeInput = CodeFrame.ScrollingFrame.TextBox
	local OldText = ""

	CodeInput:GetPropertyChangedSignal("Text"):Connect(function()
		if not Delta.Settings.CurrentSettings.CodeHighlight or not Delta.CurrentScript then return end

		local Text = CodeInput.Text

		if Text == OldText then return end
		OldText = Text

		local LinesCount = #string.split(Text,"\n")
		local str = ""
		for i=1,LinesCount do
			str = str..tostring(i).."\n"
		end
		CodeFrame.Line.LineNumber.Text = str

		Highlighter:SetText(Text)

		local str = ""

		for i,v in Highlighter:GetRichLines() do
			str = str..v.."\n"
		end

		CodeFrame.ScrollingFrame.TextLabel.Text = str
		Delta.CurrentScript.Source = Text
	end)

	CodeFrame.ScrollingFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		CodeFrame.Line.CanvasPosition = CodeFrame.ScrollingFrame.CanvasPosition
	end)
	CodeFrame.ScrollingFrame:GetPropertyChangedSignal("CanvasSize"):Connect(function()
		CodeFrame.Line.CanvasSize = CodeFrame.ScrollingFrame.CanvasSize
	end)

	local Buttons = Delta.Ui.ContentIsland.Main.code.Buttons.Another
	Buttons.Add.MouseButton1Click:Connect(function()
		Delta:OpenScript(Delta:AddScript("Script",""))
	end)
	Buttons.Run.MouseButton1Click:Connect(function()
		if not Delta.CurrentScript then return end
		loadstring(Delta.CurrentScript.Source)()
	end)
	Buttons.Clear.MouseButton1Click:Connect(function()
		CodeInput.Text = ""
	end)
	Buttons.Save.MouseButton1Click:Connect(function()
		if not Delta.CurrentScript then return end
		local Name = Delta.CurrentScript.Button.Name
		writefile(`SavedScripts/{Name}`,Delta.CurrentScript.Source)
		Delta:RefreshSavedScript()
	end)
	Buttons.Console.MouseButton1Click:Connect(function()
		Delta.Ui.SmallConsole.Visible = not Delta.Ui.SmallConsole.Visible
	end)

	local SavedUi = Delta.Ui.ContentIsland.Main.saved
	SavedUi.Frame.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
		local Text = SavedUi.Frame.TextBox.Text
		if string.gsub(Text," ","") == "" then
			for i,v in SavedUi.ScrollingFrame:GetChildren() do
				if v:IsA("Frame") then
					v.Visible = true
				end
			end
			return
		end

		for i,v in SavedUi.ScrollingFrame:GetChildren() do
			if v:IsA("Frame") and not v.TextLabel.Text:lower():find(Text:lower()) then
				v.Visible = false
			end
		end
	end)

	for i,v in Delta.Ui.NavIsland.Buttons:GetChildren() do
		if v:IsA("TextButton") then
			v.MouseButton1Click:Connect(function()
				if Delta.Ui.ContentIsland.Main:FindFirstChild(v.Name) then
					Delta:TogglePage(v.Name)
					
					if Delta[v.Name] and Delta[v.Name].Init then
						Delta[v.Name]:Init()
					end
				end
			end)
		end
	end

	LogService.MessageOut:Connect(function(Message,MessageType)
		if not RunService:IsStudio() and MessageType == Enum.MessageType.MessageError then return end
		Delta:AddConsoleMessage("Roblox",Message,MessageType)
	end)

	AutoScroll(ConsoleUi.Roblox)
	AutoScroll(ConsoleUi.Delta)

	ConsoleUi.DeltaTitle.TextButton.MouseButton1Click:Connect(function()
		for i,v in ConsoleUi.Delta:GetChildren() do
			if v:IsA("TextLabel") then
				v:Destroy()
			end
		end
	end)

	ConsoleUi.RobloxTitle.TextButton.MouseButton1Click:Connect(function()
		for i,v in ConsoleUi.Roblox:GetChildren() do
			if v:IsA("TextLabel") then
				v:Destroy()
			end
		end
	end)

	if not RunService:IsStudio() then
		Delta:RefreshSavedScript()
	end

	local oldprint = print
	local oldwarn = warn
	local olderror = error

	if RunService:IsStudio() then
		getfenv().print = function(...)
			local args = {...}
			for i,v in args do
				args[i] = tostring(v)
			end
			Delta:AddConsoleMessage("Delta",table.concat(args," "),Enum.MessageType.MessageOutput)
			return oldprint(...)
		end
		getfenv().warn = function(...)
			local args = {...}
			for i,v in args do
				args[i] = tostring(v)
			end
			Delta:AddConsoleMessage("Delta",table.concat(args," "),Enum.MessageType.MessageWarning)
			return oldwarn(...)
		end
		getfenv().error = function(Message,level)
			Delta:AddConsoleMessage("Delta",Message or "Error occurred, no output from Luau.",Enum.MessageType.MessageError)
			Delta:AddConsoleMessage("Delta","Stack Begin",Enum.MessageType.MessageInfo)
			local startLevel = math.max(2, (level or 1) + 1)
			local Frame = debug.traceback(nil, startLevel)
			for i,v in string.split(Frame,"\n") do
				if v == "" then continue end
				Delta:AddConsoleMessage("Delta",v,Enum.MessageType.MessageInfo)
			end
			Delta:AddConsoleMessage("Delta","Stack End",Enum.MessageType.MessageInfo)
			return olderror(Message,level)
		end
	else
		ScriptContext.Error:Connect(function(message, stackTrace, Tscript)
			local scriptName = Tscript and Tscript:GetFullName() or "Unknown"
			if not Tscript then
				Delta:AddConsoleMessage("Delta", message, Enum.MessageType.MessageError)

				if stackTrace and stackTrace ~= "" then
					Delta:AddConsoleMessage("Delta", "Stack Begin", Enum.MessageType.MessageInfo)
					for line in stackTrace:gmatch("([^\n]*)\n?") do
						if line ~= "" then
							Delta:AddConsoleMessage("Delta", line, Enum.MessageType.MessageInfo)
						end
					end
					Delta:AddConsoleMessage("Delta", "Stack End", Enum.MessageType.MessageInfo)
				end
				return
			end

			Delta:AddConsoleMessage("Roblox", message, Enum.MessageType.MessageError)

			if stackTrace and stackTrace ~= "" then
				Delta:AddConsoleMessage("Roblox", "Stack Begin", Enum.MessageType.MessageInfo)
				for line in stackTrace:gmatch("([^\n]*)\n?") do
					if line ~= "" then
						Delta:AddConsoleMessage("Roblox", line, Enum.MessageType.MessageInfo)
					end
				end
				Delta:AddConsoleMessage("Roblox", "Stack End", Enum.MessageType.MessageInfo)
			end
		end)

		getgenv().print = function(...)
			local str = ""
			for i,v in {...} do
				str = str..tostring(v).." "
			end
			Delta:AddConsoleMessage("Delta",str,Enum.MessageType.MessageOutput)
		end
		getgenv().warn = function(...)
			local str = ""
			for i,v in {...} do
				str = str..tostring(v).." "
			end
			Delta:AddConsoleMessage("Delta",str,Enum.MessageType.MessageWarning)
		end
		getgenv().error = function(Message,level)
			Delta:AddConsoleMessage("Delta",Message or "Error occurred, no output from Luau.",Enum.MessageType.MessageError)
			Delta:AddConsoleMessage("Delta","Stack Begin",Enum.MessageType.MessageInfo)
			local startLevel = math.max(2, (level or 1) + 1)
			local Frame = debug.traceback(nil, startLevel)
			for i,v in string.split(Frame,"\n") do
				if v == "" then continue end
				Delta:AddConsoleMessage("Delta",v,Enum.MessageType.MessageInfo)
			end
			Delta:AddConsoleMessage("Delta","Stack End",Enum.MessageType.MessageInfo)
		end
	end

	local Completion = RunService:IsStudio() and require(script.CompletionModule) or loadstring(readfile("CompletionModule"))()

	Delta:CloseUi()
	Delta:TogglePage("code")

	local CurrentCompletion

	local SettingsFolder = "Delta(Obi_xieO)/Settings/"


	if not RunService:IsStudio() then
		setfflag("TaskSchedulerLimitTargetFpsTo2402","False")
		setfflag("GameBasicSettingsFramerateCap5","False")

		if not isfolder("Delta(Obi_xieO)/Settings") then
			makefolder("Delta(Obi_xieO)/Settings")
		end
	end

	local OldSettings = table.clone(Delta.Settings.CurrentSettings)

	local function UpdateSettings()
		local NeedToUpdate = {}

		for i,v in Delta.Settings.CurrentSettings do
			if OldSettings[i] == v then
				continue
			end
			NeedToUpdate[i] = v
		end

		OldSettings = table.clone(Delta.Settings.CurrentSettings)

		if not next(NeedToUpdate) then return end

		for i,v in NeedToUpdate do
			local Path = SettingsFolder..i

			if RunService:IsStudio() then
				warn("设置更改: ",Path,HttpService:JSONEncode(v))
				continue
			end
			writefile(Path,HttpService:JSONEncode(v))
		end
	end

	local function GetSettings()
		if RunService:IsStudio() then return end
		local Settings = listfiles("Delta(Obi_xieO)/Settings")
		for i,v in Settings do
			local Data = readfile(v)
			if Data == "" then continue end
			local SettingName = string.sub(v,#SettingsFolder+1)

			Delta.Settings.CurrentSettings[SettingName] = HttpService:JSONDecode(Data)
		end
	end

	Delta.Settings.CurrentSettings = {
		CodeCompletion = true,
		CodeHighlight = true,
		Fpscap = 60,
		CurrentNavIslandPosition = {"Top"},
	}

	GetSettings()

	Delta.Settings:AddToggle({
		Name = "代码补全",
		Text = "仅限pc端，长代码性能不佳",
		Value = Delta.Settings.CurrentSettings.CodeCompletion,
	},function(Value)
		Delta.Settings.CurrentSettings.CodeCompletion = Value
		if Value then
			CurrentCompletion = Completion.bind(CodeInput,{})
		elseif CurrentCompletion then
			CurrentCompletion:unbind()
		end

		UpdateSettings()
	end)
	Delta.Settings:AddToggle({
		Name = "语法高亮",
		Text = "推荐开启，性能影响不大",
		Value = Delta.Settings.CurrentSettings.CodeHighlight,
	},function(Value)
		Delta.Settings.CurrentSettings.CodeHighlight = Value
		if Value then
			CodeFrame.ScrollingFrame.TextLabel.Visible = true
		else
			CodeFrame.ScrollingFrame.TextLabel.Visible = false
		end

		UpdateSettings()
	end)

	Delta.Settings:AddDropdown({
		Name = "菜单位置",
		Options = {
			"Top",
			"Bottom",
			"Right",
		},
		CurrentOptions = Delta.Settings.CurrentSettings.CurrentNavIslandPosition
	},function(Options)
		Delta.Settings.CurrentSettings.CurrentNavIslandPosition = Options

		if Delta.Openned then
			local CurrentConfig = Delta.NavIslandPositions[Delta.Settings.CurrentSettings.CurrentNavIslandPosition[1]]

			Tween(Delta.Ui.NavIsland,{.1},{
				Size = CurrentConfig.Size or UDim2.fromOffset(320,44),
				Position = CurrentConfig.Position
			})
			Delta.Ui.NavIsland.Buttons.UIListLayout.FillDirection = CurrentConfig.Vertical and Enum.FillDirection.Vertical or Enum.FillDirection.Horizontal
		end

		UpdateSettings()
	end)

	Delta.Settings:AddNumber({
		Name = "帧率上限",
		Text = "设置Roblox帧率上限",
		Value = Delta.Settings.CurrentSettings.Fpscap,
		Min = 0,
		Max = math.huge,
		Step = 10,
	},function(Number)
		Delta.Settings.CurrentSettings.Fpscap = Number

		if not RunService:IsStudio() then
			setfflag("TaskSchedulerLimitTargetFpsTo2402","False")
			setfflag("GameBasicSettingsFramerateCap5","False")
			setfflag("TaskSchedulerTargetFps",Number)
		end

		UpdateSettings()
	end)

	local FOV = 0

	Delta.Settings:AddNumber({
		Name = "Fov锁定（部分游戏可能有检测，0为禁用，默认0且不保存）",
		Text = "设置fov",
		Value = FOV,
		Min = 0,
		Max = 1000,
		Step = 1,
	},function(Number)
		FOV = Number
	end)

	Delta.Settings:AddToggle({
		Name = "启用忍者ui",
	},function(Value)
		for i,v in Delta.DeltaUi do
			v.Enabled = Value
		end
	end)

	Delta.Settings:AddButton({
		Name = "快速换服",
	},function()
		local placeId = game.PlaceId
		local jobId = game.JobId

		local function fetchServers()
			local all = {}
			local cursor = ""
			for _ = 1, 10 do
				local url = "https://games.roblox.com/v1/games/"
					.. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
				if cursor ~= "" and cursor ~= "null" then
					url = url .. "&cursor=" .. cursor
				end
				local ok, body = pcall(function()
					return HttpService:JSONDecode(game:HttpGet(url))
				end)
				if not ok or not body or not body.data then break end
				for _, srv in ipairs(body.data) do
					if srv.playing < srv.maxPlayers then
						table.insert(all, srv)
					end
				end
				cursor = body.nextPageCursor
				if not cursor or cursor == "null" then break end
				task.wait()
			end
			table.sort(all, function(a, b)
				return (a.ping or 9999) < (b.ping or 9999)
			end)
			return all
		end

		while true do
			local ok, servers = pcall(fetchServers)
			if ok then
				for _, srv in ipairs(servers) do
					local id = tostring(srv.id)
					if id ~= tostring(jobId) then
						local hopOk = pcall(function()
							TeleportService:TeleportToPlaceInstance(
								placeId, id, Players.LocalPlayer
							)
						end)
						if hopOk then return end
					end
				end
			end
			task.wait(3)
		end
	end)

	local MessageFrame = Delta.Ui.ContentIsland.Main.settings.SomeMessage

	MessageFrame.PlaceId.Text = `PlaceId : {game.PlaceId}`

	local ti = tick()
	RunService.RenderStepped:Connect(function(dt)
		if tick() - ti > 0.5 then
			ti = tick()

			MessageFrame.FPS.Text = `FPS : {math.floor(1/dt)}`
			MessageFrame.PING.Text = `Ping : {math.floor(Player:GetNetworkPing()*100000)/100}ms`
		end

		if FOV and FOV ~= 0 then
			workspace.CurrentCamera.FieldOfView = FOV
		end
	end)

	Delta:AddScript("Script",DefaultScript)
	Delta:OpenScript("Script")

	if not RunService:IsStudio() then
		Create("ImageLabel",{
			Name = "Logo",
			Parent = Delta.Ui.NavIsland,
			Image = Delta.DeltaUi.Logo:FindFirstChildOfClass("ImageButton").Image,
			Size = UDim2.fromScale(1,1),
			BackgroundTransparency = 1,
			ScaleType = Enum.ScaleType.Fit
		})
	end

	for i,v in Delta.DeltaUi do
		v.Enabled = false
	end
	
	if not RunService:IsStudio() then
		for i,v in Delta.Misc do
			if v.Init then
				task.spawn(function()
					xpcall(v.Init,function(m)
						warn("Error: ",debug.traceback(m))
					end)
				end)
			end
		end
	end
	
	local MiscUi = Delta.Ui.ContentIsland.Main.something
	
	for i,v in MiscUi.Tabs:GetChildren() do
		if v:IsA("TextButton") and MiscUi.Frame:FindFirstChild(v.Name) then
			v.MouseButton1Click:Connect(function()
				local Page = v.Name
				for i,v in MiscUi.Tabs:GetChildren() do
					if v:IsA("TextButton") then
						Tween(v,{.1},{
							BackgroundColor3 = v.Name == Page and Color3.fromRGB(120, 180, 255) or Color3.fromRGB(28, 32, 46),
							BackgroundTransparency = v.Name == Page and 0.55 or 0.75,
							TextColor3 = v.Name == Page and Color3.fromRGB(240, 244, 255) or Color3.fromRGB(150, 160, 190),
						})
						Tween(v.UIStroke,{.1},{
							Transparency = v.Name == Page and 0.2 or 0.8,
						})
					end
				end
				MiscUi.Frame.UIPageLayout:JumpTo(MiscUi.Frame:FindFirstChild(v.Name))
			end)
		end
	end
end

local SmallConsole = {
	Ui = Delta.Ui.SmallConsole
}
Delta.SmallConsole = SmallConsole

function SmallConsole:AddConsoleMessage(Side,Message,MessageType)
	local t = os.date("*t")
	local str = string.format("%02d:%02d:%02d", t.hour, t.min, t.sec)

	local Text = tostring(Message)
	local NewText = SmallConsole.Ui.ConsoleText:Clone()

	NewText.RichText = true
	NewText.Text = string.format('<font color="#FFFFFF">[%s]</font> %s', str, Text)
	NewText.TextSize = 12

	NewText.TextColor3 =
		(MessageType == Enum.MessageType.MessageError   and Color3.fromRGB(231, 87, 80))  or
		(MessageType == Enum.MessageType.MessageWarning and Color3.fromRGB(245, 118, 48)) or
		(MessageType == Enum.MessageType.MessageInfo    and Color3.fromRGB(107, 180, 255)) or
		Color3.fromRGB(255, 255, 255)

	if (MessageType == Enum.MessageType.MessageError) or (MessageType == Enum.MessageType.MessageWarning) then
		local n = NewText.FontFace
		n.Weight = Enum.FontWeight.ExtraBold
		NewText.FontFace = n
	end

	NewText.Parent = SmallConsole.Ui:FindFirstChild(Side)
end

for i,v in SmallConsole.Ui.Frame.Buttons:GetChildren() do
	if v:IsA("TextButton") then
		local Page = SmallConsole.Ui:FindFirstChild(v.Name)

		v.MouseButton1Click:Connect(function()
			for i,n in SmallConsole.Ui.Frame.Buttons:GetChildren() do
				if n:IsA("TextButton") then
					Tween(n,{.1},{
						BackgroundColor3 = n == v and Color3.fromRGB(120, 180, 255) or Color3.fromRGB(28, 32, 46)
					})

					Tween(n.UIStroke,{.1},{
						Transparency = n == v and 0.2 or 0.7
					})

					SmallConsole.Ui:FindFirstChild(n.Name).Visible = n == v
				end
			end
		end)

		SmallConsole.Ui.Frame.Clear.MouseButton1Click:Connect(function()
			for i,v in Page:GetChildren() do
				if v:IsA("TextLabel") then
					v:Destroy()
				end
			end
		end)
	end
end

Delta.Connections.ConsoleDrag = SmallConsole.Ui.Frame.InputBegan:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
	local MousePos = UserInputService:GetMouseLocation()
	local ViewportSize = workspace.CurrentCamera.ViewportSize

	local Offset = Vector2.new(
		MousePos.X / ViewportSize.X - SmallConsole.Ui.Position.X.Scale,
		MousePos.Y / ViewportSize.Y - SmallConsole.Ui.Position.Y.Scale
	)

	local R = RunService.RenderStepped:Connect(function()
		local MousePos = UserInputService:GetMouseLocation()
		local ViewportSize = workspace.CurrentCamera.ViewportSize

		local TargetX = MousePos.X / ViewportSize.X - Offset.X
		local TargetY = MousePos.Y / ViewportSize.Y - Offset.Y

		local FinalPosition = UDim2.new(TargetX, 0, TargetY, 0)

		Tween(SmallConsole.Ui, {0.1}, {
			Position = FinalPosition
		})
	end)

	local Release
	Release = UserInputService.InputEnded:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1
			or Input.UserInputType == Enum.UserInputType.Touch then
			R:Disconnect()
			Release:Disconnect()
		end
	end)
end)

local Settings = {
	Ui = Delta.Ui.ContentIsland.Main.settings,
	CurrentSettings = {

	},
}
Delta.Settings = Settings
Delta.DropdownConnections = {}

function Settings:AddButton(Info,CallBack)
	Info = {
		Name = Info.Name or "Button",
		Text = Info.Text,
	}

	local NewButton = Settings.Ui.UIListLayout.Button:Clone()

	function Info:Set()
		NewButton.TextLabel.Text = self.Name
		if self.Text then
			NewButton.SubText.Text = self.Text
			NewButton.SubText.Visible = true
		end
	end

	Info.Set(Info)

	NewButton.Parent = Settings.Ui

	NewButton.TextButton.MouseButton1Click:Connect(function()
		CallBack()
	end)

	return Info
end

local Dropdown = Delta.Ui.Dropdown

function Settings:AddDropdown(Info, Callback)
	if Info.CurrentOptions then
		task.spawn(function()
			Callback(Info.CurrentOptions,Info.CurrentOptions[1])
		end)
	end

	Info = {
		Name           = Info.Name or "Dropdown",
		Text           = Info.Text,
		Options        = Info.Options or {},
		CurrentOptions = table.clone(Info.CurrentOptions or {}),
		MultSelect     = Info.MultSelect or false,
		CanNone        = Info.CanNone or false,
	}

	local T = {
		bg      = Color3.fromRGB(30, 34, 48),
		bgDark  = Color3.fromRGB(20, 22, 32),
		text    = Color3.fromRGB(240, 244, 255),
		subtext = Color3.fromRGB(150, 160, 190),
		accent  = Color3.fromRGB(120, 180, 255),
	}

	local NewDropdown = Settings.Ui.UIListLayout.Dropdown:Clone()

	local TriggerBtn = NewDropdown.TextButton
	local Panel      = Dropdown.Dropdown.Panel
	local Scroll     = Panel.Scroll
	local Template   = Scroll.UIListLayout.Item

	local Buttons      = {}
	local IsOpen       = false

	TriggerBtn.AutoButtonColor = true

	local function contains(t, v)
		for _, x in ipairs(t) do if x == v then return true end end
		return false
	end

	local function UpdateTriggerText()
		local cur = Info.CurrentOptions
		if #cur == 0 then
			TriggerBtn.Value.Text = "请选择..."
			TriggerBtn.Value.TextColor3 = T.subtext
		else
			TriggerBtn.Value.Text = table.concat(cur, ", ")
			TriggerBtn.Value.TextColor3 = T.text
		end
	end

	local function SetSelectedVisual(btn, on)
		Tween(btn, {.1}, {
			BackgroundTransparency = on and .7 or 1,
			BackgroundColor3       = on and T.accent or T.bg,
		})

		local frame = btn:FindFirstChild("Frame")
		if frame then
			if on then
				frame.Visible = true
				Tween(frame, {.1}, { BackgroundTransparency = 0 })
			else
				Tween(frame, {.1}, { BackgroundTransparency = 1 })
				task.delay(.1, function()
					if not contains(Info.CurrentOptions, btn:GetAttribute("Value")) then
						frame.Visible = false
					end
				end)
			end
		end
	end

	local function ApplySelection(v)
		if Info.MultSelect then
			if contains(Info.CurrentOptions, v) then
				if #Info.CurrentOptions == 1 and not Info.CanNone then
					return
				end
				for i, x in ipairs(Info.CurrentOptions) do
					if x == v then
						table.remove(Info.CurrentOptions, i)
						break
					end
				end
			else
				table.insert(Info.CurrentOptions, v)
			end
		else
			if #Info.CurrentOptions == 1 and Info.CurrentOptions[1] == v then
				if Info.CanNone then
					Info.CurrentOptions = {}
				else
					return
				end
			else
				Info.CurrentOptions = { v }
			end
		end

		local Ordered = {}
		for _, opt in ipairs(Info.Options) do
			if contains(Info.CurrentOptions, opt) then
				table.insert(Ordered, opt)
			end
		end
		Info.CurrentOptions = Ordered

		for val, btn in pairs(Buttons) do
			SetSelectedVisual(btn, contains(Info.CurrentOptions, val))
		end
		UpdateTriggerText()

		if Callback then
			task.spawn(function()
				Callback(Info.CurrentOptions, Info.CurrentOptions[1])
			end)
		end
	end

	local function NewButton(v)
		local item = Template:Clone()
		item.Label.Text = tostring(v)
		item:SetAttribute("Value", v)
		item.Visible = true

		local isSel = contains(Info.CurrentOptions, v)
		item.BackgroundTransparency = isSel and .7 or 1
		item.BackgroundColor3       = isSel and T.accent or T.bg
		local frame = item:FindFirstChild("Frame")
		if frame then frame.Visible = isSel; frame.BackgroundTransparency = isSel and 0 or 1 end

		item.MouseEnter:Connect(function()
			if not contains(Info.CurrentOptions, v) then
				Tween(item, {.1}, { BackgroundTransparency = .5 })
			end
		end)
		item.MouseLeave:Connect(function()
			if contains(Info.CurrentOptions, v) then
				Tween(item, {.1}, { BackgroundTransparency = .7 })
			else
				Tween(item, {.1}, { BackgroundTransparency = 1 })
			end
		end)

		item.TextButton.MouseButton1Click:Connect(function()
			ApplySelection(v)
		end)

		item.Parent = Scroll
		Buttons[v] = item
		return item
	end

	local function Refresh()
		UpdateTriggerText()
		if not IsOpen then return end

		for _, btn in pairs(Buttons) do btn:Destroy() end
		Buttons = {}
		for _, v in ipairs(Info.Options) do
			NewButton(v)
		end
	end

	local SetOpen
	SetOpen = function(open)
		if Settings.DropdownRunning then return end
		Settings.DropdownRunning = true

		IsOpen = open

		Refresh()

		local GuiInsert = GuiService:GetGuiInset()
		local FinalPos = GetInScreenPosition(TriggerBtn.AbsolutePosition+GuiInsert,Dropdown.Dropdown.AbsoluteSize + Vector2.new(0,Dropdown.Dropdown.Panel.AbsoluteSize.Y + 10))

		Dropdown.Dropdown.Position = UDim2.fromOffset(FinalPos.X,FinalPos.Y)
		Dropdown.Visible = true
		if open then
			Panel.Size = UDim2.new(1, 0, 0, 0)
		end

		local targetH = open and 130 or 0

		Tween(Panel, {.18}, { Size = UDim2.new(1, 0, 0, targetH) })

		task.delay(.2, function()
			if not open then
				Dropdown.Visible = false

				for i,v in Dropdown.Dropdown.Panel.Scroll:GetChildren() do
					if v:IsA("Frame") then
						v:Destroy()
					end
				end
			end

			Settings.DropdownRunning = false
		end)

		local arrow = TriggerBtn:FindFirstChild("Arrow")
		if arrow then
			Tween(arrow, {.18}, { Rotation = open and 0 or -90 })
		end

		local a;a = Dropdown.MouseButton1Click:Connect(function()
			if Settings.DropdownRunning then return end
			SetOpen(false)
			a:Disconnect()
		end)
	end

	function Info:Set()
		NewDropdown.TextLabel.Text = self.Name

		if self.Text then
			NewDropdown.SubText.Text = self.Text
			NewDropdown.SubText.Visible = true
		end

		Info = self

		Refresh()
	end

	TriggerBtn.MouseButton1Click:Connect(function()
		SetOpen(not IsOpen)
	end)

	NewDropdown.Parent = Settings.Ui

	Info.Refresh = Refresh
	Info:Set()

	return Info
end

function Settings:AddToggle(Info,Callback)
	Info = {
		Name = Info.Name or "Toggle",
		Text = Info.Text,
		Value = Info.Value or false,
	}

	local NewToggle = Settings.Ui.UIListLayout.Toggle:Clone()


	function Info:Set()
		NewToggle.TextLabel.Text = self.Name
		if self.Text then
			NewToggle.SubText.Text = self.Text
			NewToggle.SubText.Visible = true
		end

		Tween(NewToggle.Frame,{.1},{
			BackgroundColor3 = self.Value and Color3.fromRGB(130, 255, 180) or Color3.fromRGB(255, 130, 180),
		})
		Tween(NewToggle.Frame.Frame,{.1},{
			Position = self.Value and UDim2.new(1,-3,0.5,0) or UDim2.new(0,3,0.5,0),
			AnchorPoint = self.Value and Vector2.new(1,0.5) or Vector2.new(0,0.5)
		})

		if not Callback then return end
		Callback(self.Value)
	end

	Info:Set()

	NewToggle.Parent = Settings.Ui
	NewToggle.Frame.TextButton.MouseButton1Click:Connect(function()
		Info.Value = not Info.Value
		Info:Set()
	end)

	return Info
end

function Settings:AddNumber(Info,Callback)
	Info = {
		Name = Info.Name or "Number",
		Text = Info.Text,
		Value = Info.Value or 0,
		Min = Info.Min or 0,
		Max = Info.Max or math.huge,
		Step = Info.Step or 1,
	}

	local NewNumber = Settings.Ui.UIListLayout.Number:Clone()

	function Info:Set()
		NewNumber.TextLabel.Text = Info.Name
		if Info.Text then
			NewNumber.SubText.Text = Info.Text
			NewNumber.SubText.Visible = true
		end

		NewNumber.TextBox.Text = tostring(Info.Value)

		if Callback then
			Callback(Info.Value)
		end
	end

	Info:Set()

	NewNumber.Add.MouseButton1Click:Connect(function()
		if math.min(Info.Value + Info.Step,Info.Max) == Info.Value then return end
		Info.Value = math.min(Info.Value + Info.Step,Info.Max)
		Info:Set()
	end)
	NewNumber:FindFirstChild("Remove").MouseButton1Click:Connect(function()
		if math.max(Info.Value - Info.Step,Info.Min) == Info.Value then return end
		Info.Value = math.max(Info.Value - Info.Step,Info.Min)
		Info:Set()
	end)
	NewNumber.TextBox.FocusLost:Connect(function()
		if Info.Value == tonumber(NewNumber.TextBox.Text) or not tonumber(NewNumber.TextBox.Text) then
			NewNumber.TextBox.Text = tostring(Info.Value)
			return
		end

		Info.Value = math.clamp(tonumber(NewNumber.TextBox.Text),Info.Min,Info.Max)
		Info:Set()
	end)

	NewNumber.Parent = Settings.Ui

	return Info
end

--[[
    API:
      local hl = Highlighter.new({ Colors = {...} })   -- 可选，覆盖默认配色
      hl:SetText(source)                       -- 设置源码（自动分行）
      hl:GetText()                             -- 取回源码
      hl:HighlightLine(lineIndex)              -- 返回该行的 { [列号] = 类型编号 }
      hl:GetRichLine(lineIndex)                -- 返回该行的 RichText 字符串（整行，无滚动裁剪）
      hl:GetRichLines()                        -- 返回所有行的 RichText 数组
      hl:ApplyTheme(colors)                    -- 更新配色
]]
local Highlighter = {}
Delta.Highlighter = Highlighter

local typeMap = {
	[1]  = "String",
	[2]  = "String",
	[3]  = "String",
	[4]  = "Comment",
	[5]  = "Operator",
	[6]  = "Number",
	[7]  = "Keyword",
	[8]  = "BuiltIn",
	[9]  = "LocalMethod",
	[10] = "LocalProperty",
	[11] = "Nil",
	[12] = "Bool",
	[13] = "Function",
	[14] = "Local",
	[15] = "Self",
	[16] = "FunctionName",
	[17] = "Bracket",
	[18] = "Executor",
}

local specialKeywordsTypes = {
	["nil"]      = 11,
	["true"]     = 12,
	["false"]    = 12,
	["function"] = 13,
	["local"]    = 14,
	["self"]     = 15,
}

local keywords = {
	["and"] = true, ["break"] = true, ["do"] = true, ["else"] = true,
	["elseif"] = true, ["end"] = true, ["const"] = true, ["false"] = true,
	["for"] = true, ["function"] = true, ["if"] = true, ["in"] = true,
	["local"] = true, ["nil"] = true, ["not"] = true, ["or"] = true,
	["repeat"] = true, ["return"] = true, ["then"] = true, ["true"] = true,
	["until"] = true, ["while"] = true, ["plugin"] = true,
}

local builtIns = {
	-- 基础函数
	["delay"] = true, ["elapsedTime"] = true, ["require"] = true, ["spawn"] = true,
	["tick"] = true, ["time"] = true, ["typeof"] = true, ["UserSettings"] = true,
	["wait"] = true, ["warn"] = true, ["game"] = true, ["shared"] = true,
	["script"] = true, ["workspace"] = true, ["assert"] = true, ["collectgarbage"] = true,
	["error"] = true, ["getfenv"] = true, ["getmetatable"] = true, ["ipairs"] = true,
	["loadstring"] = true, ["newproxy"] = true, ["next"] = true, ["pairs"] = true,
	["pcall"] = true, ["print"] = true, ["rawequal"] = true, ["rawget"] = true,
	["rawset"] = true, ["select"] = true, ["setfenv"] = true, ["setmetatable"] = true,
	["tonumber"] = true, ["tostring"] = true, ["type"] = true, ["unpack"] = true,
	["xpcall"] = true, ["_G"] = true, ["_VERSION"] = true,["task"] = true,
	-- 库
	["coroutine"] = true, ["debug"] = true, ["math"] = true, ["os"] = true,
	["string"] = true, ["table"] = true, ["bit32"] = true, ["utf8"] = true,
	-- Roblox 数据类型
	["Axes"] = true, ["BrickColor"] = true, ["CFrame"] = true, ["Color3"] = true,
	["ColorSequence"] = true, ["ColorSequenceKeypoint"] = true, ["DockWidgetPluginGuiInfo"] = true,
	["Enum"] = true, ["Faces"] = true, ["Instance"] = true, ["NumberRange"] = true,
	["NumberSequence"] = true, ["NumberSequenceKeypoint"] = true, ["PathWaypoint"] = true,
	["PhysicalProperties"] = true, ["Random"] = true, ["Ray"] = true, ["Rect"] = true,
	["Region3"] = true, ["Region3int16"] = true, ["TweenInfo"] = true, ["UDim"] = true,
	["UDim2"] = true, ["Vector2"] = true, ["Vector2int16"] = true, ["Vector3"] = true,
	["Vector3int16"] = true,
}

local executorFuncs = {}
local executorSubTables = {}

local Executor

if RunService:IsStudio() then
	Executor = {
		checkcaller = true,
		clonefunction = true,
		getfunctionhash = true,
		hookfunction = true,
		hookmetamethod = true,
		iscclosure = true,
		isexecutorclosure = true,
		islclosure = true,
		loadstring = true,
		newcclosure = true,
		restorefunction = true,
		debug = {
			getconstant = true,
			getconstants = true,
			getproto = true,
			getprotos = true,
			getstack = true,
			getupvalue = true,
			getupvalues = true,
			setconstant = true,
			setstack = true,
			setupvalue = true,
		},
		Drawing = {
			cleardrawcache = true,
			getrenderproperty = true,
			isrenderobj = true,
			setrenderproperty = true,
			new = true,
		},
		base64decode = true,
		base64encode = true,
		lz4compress = true,
		lz4decompress = true,
		getgc = true,
		getgenv = true,
		getreg = true,
		getrenv = true,
		filtergc = true,
		appendfile = true,
		delfile = true,
		delfolder = true,
		getcustomasset = true,
		isfile = true,
		isfolder = true,
		listfiles = true,
		loadfile = true,
		makefolder = true,
		readfile = true,
		writefile = true,
		cloneref = true,
		compareinstances = true,
		fireclickdetector = true,
		fireproximityprompt = true,
		firetouchinterest = true,
		getcallbackvalue = true,
		gethui = true,
		getinstances = true,
		getnilinstances = true,
		getnamecallmethod = true,
		getrawmetatable = true,
		isreadonly = true,
		setrawmetatable = true,
		setreadonly = true,
		identifyexecutor = true,
		request = true,
		gethiddenproperty = true,
		gettheadidentity = true,
		isscriptable = true,
		sethiddenproperty = true,
		setscriptable = true,
		setthreadidentity = true,
		getcallingscript = true,
		getloadedmodules = true,
		getrunningscripts = true,
		getscriptbytecode = true,
		getscriptclosure = true,
		getscriptfromthread = true,
		getscripthash = true,
		getsenv = true,
		getmenv = true,
		firesignal = true,
		getconnections = true,
		replicatesignal = true
	}
else
	Executor = getgenv()
end

local builtInInited = false

local richReplace = {
	["'"] = "&apos;",
	['"'] = "&quot;",
	["<"] = "&lt;",
	[">"] = "&gt;",
	["&"] = "&amp;",
}

local tabSub = "\205"
local tabReplacement = (" %s%s "):format(tabSub, tabSub)

local tabJumps = {
	[("[^%s] %s"):format(tabSub, tabSub)] = 0,
	[(" %s%s"):format(tabSub, tabSub)] = -1,
	[("%s%s "):format(tabSub, tabSub)] = 2,
	[("%s [^%s]"):format(tabSub, tabSub)] = 1,
}

local DEFAULT_COLORS = {
	Text           = Color3.fromRGB(204, 204, 204),
	Background     = Color3.fromRGB(36, 36, 36),
	Selection      = Color3.fromRGB(255, 255, 255),
	SelectionBack  = Color3.fromRGB(11, 90, 175),
	Operator       = Color3.fromRGB(204, 204, 204),
	Number         = Color3.fromRGB(255, 198, 0),
	String         = Color3.fromRGB(173, 241, 149),
	Comment        = Color3.fromRGB(102, 102, 102),
	Keyword        = Color3.fromRGB(248, 109, 124),
	Error          = Color3.fromRGB(255, 0, 0),
	FindBackground = Color3.fromRGB(141, 118, 0),
	MatchingWord   = Color3.fromRGB(85, 85, 85),
	BuiltIn        = Color3.fromRGB(132, 214, 247),
	CurrentLine    = Color3.fromRGB(45, 50, 65),
	LocalMethod    = Color3.fromRGB(253, 251, 172),
	LocalProperty  = Color3.fromRGB(97, 161, 241),
	Nil            = Color3.fromRGB(255, 198, 0),
	Bool           = Color3.fromRGB(255, 198, 0),
	Function       = Color3.fromRGB(248, 109, 124),
	Local          = Color3.fromRGB(248, 109, 124),
	Self           = Color3.fromRGB(248, 109, 124),
	FunctionName   = Color3.fromRGB(253, 251, 172),
	Bracket        = Color3.fromRGB(204, 204, 204),
	Executor       = Color3.fromRGB(200, 0, 255),
}

local function collectExecutor(exec)
	if type(exec) ~= "table" then return end
	for name, value in next, exec do
		if type(name) ~= "string" then continue end
		if type(value) == "table" then
			local sub = executorSubTables[name]
			if not sub then
				sub = {}
				executorSubTables[name] = sub
			end
			for subName in next, value do
				if type(subName) == "string" then
					sub[subName] = true
				end
			end
			executorFuncs[name] = true
		else
			executorFuncs[name] = true
		end
	end
end

local function initBuiltIn()
	local env = getfenv and getfenv() or _G
	for name in next, builtIns do
		local envVal = env[name]
		if type(envVal) == "table" then
			local items = {}
			for i, v in next, envVal do
				items[i] = true
			end
			builtIns[name] = items
		end
	end

	local ok, enums = pcall(function() return Enum:GetEnums() end)
	if ok and enums then
		local enumEntries = {}
		for i = 1, #enums do
			enumEntries[tostring(enums[i])] = true
		end
		builtIns["Enum"] = enumEntries
	end

	collectExecutor(Executor)

	builtInInited = true
end

local funcs = {}
local mt = { __index = funcs }

function funcs._splitLines(self, text)
	local lines = {}
	local count = 1
	text = text:gsub("\r\n", "\n")
	for line in text:gmatch("([^\n]*)\n?") do
		lines[count] = line
		count = count + 1
	end
	if #lines > 1 and lines[#lines] == "" and text:sub(-1) == "\n" then
		lines[#lines] = nil
	end
	return lines
end

function funcs.MakeRichTemplates(self)
	local floor = math.floor
	local templates = {}
	for name, color in pairs(self.Colors) do
		templates[name] = ('<font color="rgb(%s,%s,%s)">'):format(
			floor(color.r * 255), floor(color.g * 255), floor(color.b * 255))
	end
	self.RichTemplates = templates
end

function funcs.TabAdjust(self, x, y)
	local line = self.Lines[y + 1]
	x = x + 1
	if line then
		local left   = line:sub(x - 1, x - 1)
		local middle = line:sub(x, x)
		local right  = line:sub(x + 1, x + 1)
		local selRange = (#left > 0 and left or " ")
			.. (#middle > 0 and middle or " ")
			.. (#right > 0 and right or " ")
		for i, v in pairs(tabJumps) do
			if selRange:find(i) then
				return v
			end
		end
	end
	return 0
end

function funcs._mapNewLines(self)
	local newLines = {}
	local count = 1
	local text = self.Text
	local find = string.find
	local init = 1
	local pos = find(text, "\n", init, true)
	while pos do
		newLines[count] = pos
		count = count + 1
		init = pos + 1
		pos = find(text, "\n", init, true)
	end
	self.NewLines = newLines
end

function funcs.PreHighlight(self)
	local text = self.Text:gsub("\\\\", "  ")
	local textLen = #text
	local found, foundMap, extras = {}, {}, {}
	local find = string.find
	local sub = string.sub
	self.ColoredLines = {}

	local function findAll(str, pattern, typ, raw)
		local count = #found + 1
		local init = 1
		local x, y, extra = find(str, pattern, init, raw)
		while x do
			found[count] = x
			foundMap[x] = typ
			if extra then extras[x] = extra end
			count = count + 1
			init = y + 1
			x, y, extra = find(str, pattern, init, raw)
		end
	end

	findAll(text, '"', 1, true)
	findAll(text, "'", 2, true)
	findAll(text, "%[(=*)%[", 3)
	findAll(text, "--", 4, true)
	table.sort(found)

	local newLines = self.NewLines
	local curLine = 0
	local lineEnd = 0
	local lastEnding = 0
	local foundHighlights = {}

	for i = 1, #found do
		local pos = found[i]
		if pos <= lastEnding then continue end

		local ending = pos
		local typ = foundMap[pos]

		if typ == 1 then
			ending = find(text, '"', pos + 1, true)
			while ending and sub(text, ending - 1, ending - 1) == "\\" do
				ending = find(text, '"', ending + 1, true)
			end
			if not ending then ending = textLen end
		elseif typ == 2 then
			ending = find(text, "'", pos + 1, true)
			while ending and sub(text, ending - 1, ending - 1) == "\\" do
				ending = find(text, "'", ending + 1, true)
			end
			if not ending then ending = textLen end
		elseif typ == 3 then
			_, ending = find(text, "]" .. extras[pos] .. "]", pos + 1, true)
			if not ending then ending = textLen end
		elseif typ == 4 then
			local ahead = foundMap[pos + 2]
			if ahead == 3 then
				_, ending = find(text, "]" .. extras[pos + 2] .. "]", pos + 1, true)
				if not ending then ending = textLen end
			else
				ending = find(text, "\n", pos + 1, true) or textLen
			end
		end

		while pos > lineEnd do
			curLine = curLine + 1
			lineEnd = newLines[curLine] or textLen + 1
		end

		while true do
			local lineTable = foundHighlights[curLine]
			if not lineTable then lineTable = {} foundHighlights[curLine] = lineTable end
			lineTable[pos] = {typ, ending}

			if ending > lineEnd then
				curLine = curLine + 1
				lineEnd = newLines[curLine] or textLen + 1
			else
				break
			end
		end

		lastEnding = ending
	end

	self.PreHighlights = foundHighlights
end

function funcs.HighlightLine(self, line)
	local cached = self.ColoredLines[line]
	if cached then return cached end

	local sub   = string.sub
	local find  = string.find
	local match = string.match
	local highlights = {}
	local preHighlights = self.PreHighlights[line] or {}
	local lineText = self.Lines[line] or ""
	local lastEnding = 0
	local currentType = 0
	local lastWord = nil
	local wordBeginsDotted = false
	local funcStatus = 0
	local lineStart = self.NewLines[line - 1] or 0

	local preHighlightMap = {}
	for pos, data in next, preHighlights do
		local relativePos = pos - lineStart
		if relativePos < 1 then
			currentType = data[1]
			lastEnding = data[2] - lineStart
		else
			preHighlightMap[relativePos] = {data[1], data[2] - lineStart}
		end
	end

	for col = 1, #lineText do
		if col <= lastEnding then
			highlights[col] = currentType
			continue
		end

		local pre = preHighlightMap[col]
		if pre then
			currentType = pre[1]
			lastEnding = pre[2]
			highlights[col] = currentType
			wordBeginsDotted = false
			lastWord = nil
			funcStatus = 0
		else
			local char = sub(lineText, col, col)
			if find(char, "[%a_]") then
				local word = match(lineText, "[%a%d_]+", col)
				local isExecutor = executorFuncs[word] and true or false
				local wordType = (keywords[word] and 7)
					or (isExecutor and 18)
					or (builtIns[word] and 8)

				lastEnding = col + #word - 1

				if wordType ~= 7 then
					if wordBeginsDotted then
						local prevWord = lastWord
						local prevBuiltIn = prevWord and builtIns[prevWord]
						local prevSub = prevWord and executorSubTables[prevWord]

						if isExecutor and (prevWord == "Executor" or executorFuncs[prevWord]) then
							wordType = 18
						elseif prevSub and prevSub[word] then
							wordType = 18
						else
							wordType = (prevBuiltIn and type(prevBuiltIn) == "table"
								and prevBuiltIn[word] and 8) or 10
						end
					end

					if wordType ~= 8 and wordType ~= 18 then
						local x, y, br = find(lineText, "^%s*([%({\"'])", lastEnding + 1)
						if x then
							wordType = (funcStatus > 0 and br == "(" and 16) or 9
							funcStatus = 0
						end
					end
				else
					wordType = specialKeywordsTypes[word] or wordType
					funcStatus = (word == "function" and 1 or 0)
				end

				lastWord = word
				wordBeginsDotted = false
				if funcStatus > 0 then funcStatus = 1 end

				if wordType then
					currentType = wordType
					highlights[col] = currentType
				else
					currentType = nil
				end
			elseif find(char, "%p") then
				local isDot = (char == ".")
				local isNum = isDot and find(sub(lineText, col + 1, col + 1), "%d")
				highlights[col] = (isNum and 6 or 5)

				if not isNum then
					local dotStr = isDot and match(lineText, "%.%.?%.?", col)
					if dotStr and #dotStr > 1 then
						currentType = 5
						lastEnding = col + #dotStr - 1
						wordBeginsDotted = false
						lastWord = nil
						funcStatus = 0
					else
						if isDot then
							if wordBeginsDotted then
								lastWord = nil
							else
								wordBeginsDotted = true
							end
						else
							wordBeginsDotted = false
							lastWord = nil
						end
						funcStatus = ((isDot or char == ":") and funcStatus == 1 and 2) or 0
					end
				end
			elseif find(char, "%d") then
				local _, endPos = find(lineText, "%x+", col)
				local endPart = sub(lineText, endPos, endPos + 1)
				if (endPart == "e+" or endPart == "e-")
					and find(sub(lineText, endPos + 2, endPos + 2), "%d") then
					endPos = endPos + 1
				end
				currentType = 6
				lastEnding = endPos
				highlights[col] = 6
				wordBeginsDotted = false
				lastWord = nil
				funcStatus = 0
			else
				highlights[col] = currentType
				local _, endPos = find(lineText, "%s+", col)
				if endPos then lastEnding = endPos end
			end
		end
	end

	self.ColoredLines[line] = highlights
	return highlights
end

function funcs.GetRichLine(self, lineIndex)
	local lineText = self.Lines[lineIndex] or ""
	if #lineText == 0 then return "" end

	local highlights = self:HighlightLine(lineIndex)
	local gsub = string.gsub
	local sub  = string.sub
	local richTemplates = self.RichTemplates
	local textTemplate = richTemplates.Text

	local resText = ""
	local colStart = 1
	local curType = highlights[1]
	local curTemplate = richTemplates[typeMap[curType]] or textTemplate

	for col = 2, #lineText do
		local posType = highlights[col]
		if posType ~= curType then
			local template = richTemplates[typeMap[posType]] or textTemplate
			if template ~= curTemplate then
				local nextText = gsub(sub(lineText, colStart, col - 1), "['\"<>&]", richReplace)
				resText = resText .. (curTemplate ~= textTemplate and (curTemplate .. nextText .. "</font>") or nextText)
				colStart = col
				curTemplate = template
			end
			curType = posType
		end
	end

	local lastText = gsub(sub(lineText, colStart, #lineText), "['\"<>&]", richReplace)
	if #lastText > 0 then
		resText = resText
			.. (curTemplate ~= textTemplate and (curTemplate .. lastText .. "</font>") or lastText)
	end

	return resText
end

function funcs.GetRichLines(self)
	local out = {}
	for i = 1, #self.Lines do
		out[i] = self:GetRichLine(i)
	end
	return out
end

function funcs.SetText(self, txt)
	txt = txt:gsub("\r\n", "\n")
	self.Text = txt
	self.Lines = self:_splitLines(txt)
	if #self.Lines == 0 then self.Lines = {""} end
	self:_mapNewLines()
	self:PreHighlight()
end

function funcs.GetText(self)
	return table.concat(self.Lines, "\n")
end

function funcs.ApplyTheme(self, colors)
	if colors then
		for k, v in pairs(colors) do
			self.Colors[k] = v
		end
	end
	self:MakeRichTemplates()
end

function funcs.Refresh(self)
	self.ColoredLines = {}
	self:_mapNewLines()
	self:PreHighlight()
end

function Highlighter.new(opts)
	opts = opts or {}
	if not builtInInited then initBuiltIn() end

	local self = setmetatable({}, mt)
	self.Colors = {}
	for k, v in pairs(DEFAULT_COLORS) do
		self.Colors[k] = v
	end
	if opts.Colors then
		for k, v in pairs(opts.Colors) do
			self.Colors[k] = v
		end
	end

	self.Lines = {""}
	self.Text = ""
	self.NewLines = {}
	self.ColoredLines = {}
	self.PreHighlights = {}
	self.RichTemplates = {}

	self:MakeRichTemplates()
	return self
end

Highlighter.typeMap = typeMap
Highlighter.keywords = keywords
Highlighter.builtIns = builtIns
Highlighter.executorFuncs = executorFuncs
Highlighter.executorSubTables = executorSubTables
Highlighter.DEFAULT_COLORS = DEFAULT_COLORS




-----------------------------------------------------------
--  杂项
-----------------------------------------------------------

do
	local bit32 = bit32

	local SHA256 = {}

	local function rrotate(x: number, n: number): number
		return bit32.bor(bit32.rshift(x, n), bit32.lshift(x, 32 - n))
	end

	local function rshift(x: number, n: number): number
		return bit32.rshift(x, n)
	end

	local K = {
		0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5,
		0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
		0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
		0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
		0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc,
		0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
		0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7,
		0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
		0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
		0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
		0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3,
		0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
		0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5,
		0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
		0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
		0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
	}

	local H0 = {
		0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
		0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19,
	}

	local function packUInt32BE(n: number): string
		n = n % 0x100000000
		local b1 = math.floor(n / 0x1000000) % 0x100
		local b2 = math.floor(n / 0x10000) % 0x100
		local b3 = math.floor(n / 0x100) % 0x100
		local b4 = n % 0x100
		return string.char(b1, b2, b3, b4)
	end

	local function preprocess(message: string): string
		local len = #message
		local bitLen = len * 8

		message = message .. "\x80"

		while #message % 64 ~= 56 do
			message = message .. "\x00"
		end

		local high = math.floor(bitLen / 0x100000000)
		local low = bitLen % 0x100000000
		message = message .. packUInt32BE(high) .. packUInt32BE(low)

		return message
	end

	local function processBlock(H: { number }, block: string)
		local w: { number } = table.create(64)

		for i = 0, 15 do
			local offset = i * 4 + 1
			local b1, b2, b3, b4 = string.byte(block, offset, offset + 3)
			w[i + 1] = bit32.bor(
				bit32.lshift(b1, 24),
				bit32.lshift(b2, 16),
				bit32.lshift(b3, 8),
				b4
			)
		end

		for i = 17, 64 do
			local s0 = bit32.bxor(
				rrotate(w[i - 15], 7),
				rrotate(w[i - 15], 18),
				rshift(w[i - 15], 3)
			)
			local s1 = bit32.bxor(
				rrotate(w[i - 2], 17),
				rrotate(w[i - 2], 19),
				rshift(w[i - 2], 10)
			)
			w[i] = (w[i - 16] + s0 + w[i - 7] + s1) % 0x100000000
		end

		local a, b, c, d, e, f, g, h =
			H[1], H[2], H[3], H[4], H[5], H[6], H[7], H[8]

		for i = 1, 64 do
			local S1 = bit32.bxor(
				rrotate(e, 6),
				rrotate(e, 11),
				rrotate(e, 25)
			)
			local ch = bit32.bxor(bit32.band(e, f), bit32.band(bit32.bnot(e), g))
			local temp1 = (h + S1 + ch + K[i] + w[i]) % 0x100000000
			local S0 = bit32.bxor(
				rrotate(a, 2),
				rrotate(a, 13),
				rrotate(a, 22)
			)
			local maj = bit32.bxor(
				bit32.band(a, b),
				bit32.band(a, c),
				bit32.band(b, c)
			)
			local temp2 = (S0 + maj) % 0x100000000

			h = g
			g = f
			f = e
			e = (d + temp1) % 0x100000000
			d = c
			c = b
			b = a
			a = (temp1 + temp2) % 0x100000000
		end

		H[1] = (H[1] + a) % 0x100000000
		H[2] = (H[2] + b) % 0x100000000
		H[3] = (H[3] + c) % 0x100000000
		H[4] = (H[4] + d) % 0x100000000
		H[5] = (H[5] + e) % 0x100000000
		H[6] = (H[6] + f) % 0x100000000
		H[7] = (H[7] + g) % 0x100000000
		H[8] = (H[8] + h) % 0x100000000
	end

	function SHA256.sha256(message: string): string
		local H = table.clone(H0)
		local padded = preprocess(message)

		for i = 1, #padded, 64 do
			local block = string.sub(padded, i, i + 63)
			processBlock(H, block)
		end

		local out = {}
		for i = 1, 8 do
			local word = H[i]
			out[i] = string.format("%08x", word)
		end
		return table.concat(out)
	end

	Delta.SHA256 = SHA256.sha256
end

local MiscUi = Delta.Ui.ContentIsland.Main.something

MiscUi.Frame.Folder.UIPageLayout.Parent = MiscUi.Frame
MiscUi.Frame.Folder:Destroy()

for i,v in MiscUi.Frame:GetChildren() do
	if v:IsA("Frame") then
		v.Visible = true
	end
end

MiscUi.Frame.UIPageLayout:JumpTo(MiscUi.Frame.Key)

do
	local cloneref  = cloneref or function(...) return ... end
	local TextService = cloneref(game:GetService("TextService"))
	local RunService = cloneref(game:GetService("RunService"))

	local Highlight = {}

	local parentFrame
	local scrollingFrame
	local textFrame
	local lineNumbersFrame
	local lines = {}

	local tableContents = {}

	local line = 0
	local largestX = 0

	local lineSpace = 15
	local font = Enum.Font.Ubuntu
	local textSize = 14

	local backgroundColor = Color3.fromRGB(40, 44, 52)
	local operatorColor = Color3.fromRGB(187, 85, 255)
	local functionColor = Color3.fromRGB(97, 175, 239)
	local stringColor = Color3.fromRGB(152, 195, 121)
	local numberColor = Color3.fromRGB(209, 154, 102)
	local booleanColor = numberColor
	local objectColor = Color3.fromRGB(229, 192, 123)
	local defaultColor = Color3.fromRGB(224, 108, 117)
	local commentColor = Color3.fromRGB(148, 148, 148)
	local lineNumberColor = commentColor
	local genericColor = Color3.fromRGB(240, 240, 240)

	local operators = {"^(function)[^%w_]", "^(local)[^%w_]", "^(if)[^%w_]", "^(for)[^%w_]", "^(while)[^%w_]", "^(then)[^%w_]", "^(do)[^%w_]", "^(else)[^%w_]", "^(elseif)[^%w_]", "^(return)[^%w_]", "^(end)[^%w_]", "^(continue)[^%w_]", "^(and)[^%w_]", "^(not)[^%w_]", "^(or)[^%w_]", "[^%w_](or)[^%w_]", "[^%w_](and)[^%w_]", "[^%w_](not)[^%w_]", "[^%w_](continue)[^%w_]", "[^%w_](function)[^%w_]", "[^%w_](local)[^%w_]", "[^%w_](if)[^%w_]", "[^%w_](for)[^%w_]", "[^%w_](while)[^%w_]", "[^%w_](then)[^%w_]", "[^%w_](do)[^%w_]", "[^%w_](else)[^%w_]", "[^%w_](elseif)[^%w_]", "[^%w_](return)[^%w_]", "[^%w_](end)[^%w_]"}
	local strings = {{"\"", "\""}, {"'", "'"}, {"%[%[", "%]%]", true}}
	local comments = {"%-%-%[%[[^%]%]]+%]?%]?", "(%-%-[^\n]+)"}
	local functions = {"[^%w_]([%a_][%a%d_]*)%s*%(", "^([%a_][%a%d_]*)%s*%(", "[:%.%(%[%p]([%a_][%a%d_]*)%s*%("}
	local numbers = {"[^%w_](%d+[eE]?%d*)", "[^%w_](%.%d+[eE]?%d*)", "[^%w_](%d+%.%d+[eE]?%d*)", "^(%d+[eE]?%d*)", "^(%.%d+[eE]?%d*)", "^(%d+%.%d+[eE]?%d*)"}
	local booleans = {"[^%w_](true)", "^(true)", "[^%w_](false)", "^(false)", "[^%w_](nil)", "^(nil)"}
	local objects = {"[^%w_:]([%a_][%a%d_]*):", "^([%a_][%a%d_]*):"}
	local other = {"[^_%s%w=>~<%-%+%*]", ">", "~", "<", "%-", "%+", "=", "%*"}
	local offLimits = {}

	local function isOffLimits(index)
		for _, v in next, offLimits do
			if index >= v[1] and index <= v[2] then
				return true
			end
		end
		return false
	end

	local function gfind(str, pattern)
		return coroutine.wrap(function()
			local start = 0
			while true do
				local findStart, findEnd = str:find(pattern, start)
				if findStart and findEnd ~= #str then
					start = findEnd + 1
					coroutine.yield(findStart, findEnd)
				else
					return
				end
			end
		end)
	end

	local function renderComments()
		local str = Highlight:getRaw()
		local step = 1
		for _, pattern in next, comments do
			for commentStart, commentEnd in gfind(str, pattern) do
				if step % 1000 == 0 then
					RunService.Heartbeat:Wait()
				end
				step += 1
				if not isOffLimits(commentStart) then
					for i = commentStart, commentEnd do
						table.insert(offLimits, {commentStart, commentEnd})
						if tableContents[i] then
							tableContents[i].Color = commentColor
						end
					end
				end
			end
		end
	end

	local function renderStrings()
		local stringType
		local stringEndType
		local ignoreBackslashes
		local stringStart
		local stringEnd
		local offLimitsIndex
		local skip = false

		for i, char in next, tableContents do
			if stringType then
				char.Color = stringColor
				local possibleString = ""
				for k = stringStart, i do
					possibleString = possibleString .. tableContents[k].Char
				end
				if char.Char:match(stringEndType) and not not ignoreBackslashes or (possibleString:match("(\\*)" .. stringEndType .. "$") and #possibleString:match("(\\*)" .. stringEndType .. "$") % 2 == 0) then
					skip = true
					stringType = nil
					stringEndType = nil
					ignoreBackslashes = nil
					stringEnd = i
					offLimits[offLimitsIndex][2] = stringEnd
				end
			end
			if not skip then
				for _, v in next, strings do
					if char.Char:match(v[1]) and not isOffLimits(i) then
						stringType = v[1]
						stringEndType = v[2]
						ignoreBackslashes = v[3]
						char.Color = stringColor
						stringStart = i
						offLimitsIndex = #offLimits + 1
						offLimits[offLimitsIndex] = {stringStart, math.huge}
					end
				end
			end
			skip = false
		end
	end

	local function highlightPattern(patternArray, color)
		local str = Highlight:getRaw()
		local step = 1
		for _, pattern in next, patternArray do
			for findStart, findEnd in gfind(str, pattern) do
				if step % 1000 == 0 then
					RunService.Heartbeat:Wait()
				end
				step += 1
				if not isOffLimits(findStart) and not isOffLimits(findEnd) then
					for i = findStart, findEnd do
						if tableContents[i] then
							tableContents[i].Color = color
						end
					end
				end
			end
		end
	end

	local function autoEscape(s)
		for i = 0, #s do
			local char = string.sub(s, i, i)
			if char == "<" then
				s = string.format("%s%s%s", string.sub(s, 0, i - 1), "&lt;", string.sub(s, i + 1, -1))
				i += 3
			elseif char == ">" then
				s = string.format("%s%s%s", string.sub(s, 0, i - 1), "&gt;", string.sub(s, i + 1, -1))
				i += 3
			elseif char == '"' then
				s = string.format("%s%s%s", string.sub(s, 0, i - 1), "&quot;", string.sub(s, i + 1, -1))
				i += 5
			elseif char == "'" then
				s = string.format("%s%s%s", string.sub(s, 0, i - 1), "&apos;", string.sub(s, i + 1, -1))
				i += 5
			elseif char == "&" then
				s = string.format("%s%s%s", string.sub(s, 0, i - 1), "&amp;", string.sub(s, i + 1, -1))
				i += 4
			end
		end
		return s
	end

	local function render()
		offLimits = {}
		lines = {}
		textFrame:ClearAllChildren()
		lineNumbersFrame:ClearAllChildren()

		highlightPattern(functions, functionColor)
		highlightPattern(numbers, numberColor)
		highlightPattern(operators, operatorColor)
		highlightPattern(objects, objectColor)
		highlightPattern(booleans, booleanColor)
		highlightPattern(other, genericColor)
		renderComments()
		renderStrings()

		local lastColor
		local lineStr = ""
		local rawStr = ""
		largestX = 0
		line = 1

		for i = 1, #tableContents + 1 do
			local char = tableContents[i]
			if i == #tableContents + 1 or char.Char == "\n" then
				lineStr = lineStr .. (lastColor and "</font>" or "")

				local lineText = Instance.new("TextLabel")
				local x = TextService:GetTextSize(rawStr, textSize, font, Vector2.new(math.huge, math.huge)).X + 60

				if x > largestX then
					largestX = x
				end

				lineText.TextXAlignment = Enum.TextXAlignment.Left
				lineText.TextYAlignment = Enum.TextYAlignment.Top
				lineText.Position = UDim2.new(0, 0, 0, line * lineSpace - lineSpace / 2)
				lineText.Size = UDim2.new(0, x, 0, textSize)
				lineText.RichText = true
				lineText.Font = font
				lineText.TextSize = textSize
				lineText.BackgroundTransparency = 1
				lineText.Text = lineStr
				lineText.Parent = textFrame

				if i ~= #tableContents + 1 then
					local lineNumber = Instance.new("TextLabel")
					lineNumber.Text = line
					lineNumber.Font = font
					lineNumber.TextSize = textSize
					lineNumber.Size = UDim2.new(1, 0, 0, lineSpace)
					lineNumber.TextXAlignment = Enum.TextXAlignment.Right
					lineNumber.TextColor3 = lineNumberColor
					lineNumber.Position = UDim2.new(0, 0, 0, line * lineSpace - lineSpace / 2)
					lineNumber.BackgroundTransparency = 1
					lineNumber.Parent = lineNumbersFrame
				end

				lineStr = ""
				rawStr = ""
				lastColor = nil
				line += 1
				updateZIndex()
				updateCanvasSize()
				if line % 5 == 0 then
					RunService.Heartbeat:Wait()
				end
			elseif char.Char == " " then
				lineStr = lineStr .. char.Char
				rawStr = rawStr .. char.Char
			elseif char.Char == "\t" then
				lineStr = lineStr .. string.rep(" ", 4)
				rawStr = rawStr .. char.Char
			else
				if char.Color == lastColor then
					lineStr = lineStr .. autoEscape(char.Char)
				else
					lineStr = lineStr .. string.format('%s<font color="rgb(%d,%d,%d)">', lastColor and "</font>" or "", char.Color.R * 255, char.Color.G * 255, char.Color.B * 255)
					lineStr = lineStr .. autoEscape(char.Char)
					lastColor = char.Color
				end
				rawStr = rawStr .. char.Char
			end
		end
		updateZIndex()
		updateCanvasSize()
	end

	function onFrameSizeChange()
		local newSize = parentFrame.AbsoluteSize
		scrollingFrame.Size = UDim2.new(0, newSize.X, 0, newSize.Y)
	end

	function updateCanvasSize()
		scrollingFrame.CanvasSize = UDim2.new(0, largestX, 0, line * lineSpace)
	end

	function updateZIndex()
		for _, v in next, parentFrame:GetDescendants() do
			if v:IsA("GuiObject") then
				v.ZIndex = parentFrame.ZIndex
			end
		end
	end
	function Highlight:init(frame)
		if typeof(frame) == "Instance" and frame:IsA("Frame") then
			frame:ClearAllChildren()

			parentFrame = frame
			scrollingFrame = Instance.new("ScrollingFrame")
			textFrame = Instance.new("Frame")
			lineNumbersFrame = Instance.new("Frame")

			local parentSize = frame.AbsoluteSize
			scrollingFrame.Size = UDim2.new(0, parentSize.X, 0, parentSize.Y)
			scrollingFrame.BackgroundColor3 = backgroundColor
			scrollingFrame.BorderSizePixel = 0
			scrollingFrame.ScrollBarThickness = 4

			textFrame.Size = UDim2.new(1, -40, 1, 0)
			textFrame.Position = UDim2.new(0, 40, 0, 0)
			textFrame.BackgroundTransparency = 1

			lineNumbersFrame.Size = UDim2.new(0, 25, 1, 0)
			lineNumbersFrame.BackgroundTransparency = 1

			textFrame.Parent = scrollingFrame
			lineNumbersFrame.Parent = scrollingFrame
			scrollingFrame.Parent = parentFrame

			render()
			parentFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(onFrameSizeChange)
			parentFrame:GetPropertyChangedSignal("ZIndex"):Connect(updateZIndex)
		else
			error("Initialization error: argument " .. typeof(frame) .. " is not a Frame Instance")
		end
	end

	function Highlight:setRaw(raw)
		raw = raw .. "\n"
		tableContents = {}
		local line = 1
		for i = 1, #raw do
			table.insert(tableContents, {
				Char = raw:sub(i, i),
				Color = defaultColor,
				-- Line = line
			})
			if i % 1000 == 0 then
				RunService.Heartbeat:Wait()
			end
		end
		render()
	end

	function Highlight:getRaw()
		local result = ""
		for _, char in next, tableContents do
			result = result .. char.Char
		end
		return result
	end

	function Highlight:getString()
		local result = ""
		for _, char in next, tableContents do
			result = result .. char.Char:sub(1, 1)
		end
		return result
	end

	function Highlight:getTable()
		return tableContents
	end

	function Highlight:getSize()
		return #tableContents
	end

	function Highlight:getLine(line)
		local currentline = 0
		local rightLine = false
		local result = ""
		for _, v in next, tableContents do
			currentline = currentline + 1
			if v.Char == "\n" and not rightLine then
				rightLine = true
			end
			if rightLine and v.Char ~= "\n" then
				result = result .. v.Char
			elseif rightLine then
				break
			end
		end
		return result
	end

	function Highlight:setLine(line, text)
		if #tableContents and line >= tableContents[#tableContents].Line then
			for i = tableContents[#tableContents].Line, line do
				table.insert(tableContents, {
					Char = "\n",
					Line = i,
					Color = defaultColor
				})
				local str = Highlight:getRaw()
				str = str:sub(0, #str) .. text
				Highlight:setRaw(str)
				return
			end
		elseif not #tableContents then
			return
		end
		local str = Highlight:getRaw()
		local lastStart = 0
		local currentLine = 0
		for i in gfind(str, "\n") do
			currentLine = currentLine + 1
			if line == currentLine then
				str = str:sub(0, lastStart) .. text .. str:sub(i, #str)
				Highlight:setRaw(str)
				return
			end
		end
		error("Unable to set line")
	end

	function Highlight:insertLine(line, text)
		if #tableContents and line >= tableContents[#tableContents].Line then
			Highlight:setLine(line, text)
		elseif not #tableContents then
			return
		end
		local str = Highlight:getRaw()
		local lastStart = 0
		local currentLine = 0
		for i in gfind(str, "\n") do
			currentLine = currentLine + 1
			if line == currentLine then
				str = str:sub(0, lastStart) .. "\n" .. text .. "\n" .. str:sub(i, #str)
				Highlight:setRaw(str)
				return
			end
		end
		error("Unable to insert line")
	end

	local constructor = {}

	function constructor.new(...)
		local class = Highlight
		local new = {}
		class.__index = class
		setmetatable(new, class)
		new:init(...)
		return new
	end

	Delta.constructor = constructor
end

--卡密
do
	local KeyManager = {
		XClientVersion = "8.2.3"
	}
	
	local KeyUi = MiscUi.Frame.Key
	
	Delta.Misc["密钥管理"] = KeyManager
	
	local function extractTicket(url)
		if type(url) ~= "string" then return nil end
		local ticket = url:match("[?&]d=([^&]+)") or url:match("[?&]ticket=([^&]+)")
		return ticket
	end
	
	function KeyManager.CreateLink(HWID,Platform)
		local FinalHwid = Delta.SHA256(HWID)
		local result = request({
			Url = "https://api.platoboost.net/public/start",
			Method = "POST",
			Headers = {
				["Content-Type"] = "application/json",
			},
			Body = HttpService:JSONEncode(
				{
					service = Platform == "Android" and 6 or 8,
					identifier = FinalHwid,
				}
			)
		})
		if result and result.Success and result.StatusCode == 200 then
			local data = HttpService:JSONDecode(result.Body)
			local url = data and data.data and data.data.url
			
			return url
		end
	end
	
	function KeyManager.GetStatus(Link)
		local api = `https://auth.platorelay.com/api/session/status?ticket={extractTicket(Link)}`
		local Status = request({
			Url = api,
			Method = "GET",
			Headers = {
				["Accept"] = "application/json",
				["X-Client-Name"] = "platoboost webclient",
				["X-Client-Version"] = KeyManager.XClientVersion,
			},
		})
		
		local body
		if type(Status) == "table" then
			body = Status.Body or Status.body
		elseif type(Status) == "string" then
			body = Status
		end

		local ok, data = pcall(HttpService.JSONDecode, HttpService, body)
		if ok and data and data.data then
			return data.data --data.data.key, data.data.minutesLeft
		end
	end
	
	local function formatMinutes(mins)
		if type(mins) ~= "number" then return "未知" end
		if mins <= 0 then return "已过期" end

		local totalSec = math.floor(mins * 60)
		local days = math.floor(totalSec / 86400)
		local hours = math.floor((totalSec % 86400) / 3600)
		local minutes = math.floor((totalSec % 3600) / 60)
		local seconds = totalSec % 60

		if days > 0 then
			return string.format("%d 天 %d 小时 %d 分", days, hours, minutes)
		elseif hours > 0 then
			return string.format("%d 小时 %d 分", hours, minutes)
		elseif minutes > 0 then
			return string.format("%d 分 %d 秒", minutes, seconds)
		else
			return string.format("%d 秒", seconds)
		end
	end
	
	function KeyManager.Init()
		KeyUi.Background.MainScroll.HWID.Input.Text = gethwid()
		local hwid = KeyUi.Background.MainScroll.HWID.Input.Text
		local CurrentPlatform = getgenv().Delta.is_android() and "Android" or "IOS"
		local CurrentLink = KeyManager.CreateLink(hwid, CurrentPlatform)
		local Status = KeyManager.GetStatus(CurrentLink)

		local expiresAt = nil
		if Status and type(Status.minutesLeft) == "number" and Status.minutesLeft > 0 then
			expiresAt = os.time() + Status.minutesLeft * 60
		end

		local timeLabel = KeyUi.Background.MainScroll.LeftTime.Frame.Frame.Time

		local function formatRemaining(sec)
			if sec <= 0 then return "已过期" end
			local totalMin = math.floor(sec / 60)
			local h = math.floor(totalMin / 60)
			local m = totalMin % 60
			if h > 0 then
				return string.format("%d 小时 %d 分", h, m)
			elseif totalMin > 0 then
				return string.format("%d 分 %d 秒", m, sec % 60)
			else
				return string.format("%d 秒", sec)
			end
		end

		local function update()
			if not expiresAt then
				timeLabel.Text = "已过期"
				timeLabel.TextColor3 = Color3.fromRGB(248, 113, 113)
				return
			end
			local remaining = expiresAt - os.time()
			if remaining <= 0 then
				timeLabel.Text = "已过期"
				timeLabel.TextColor3 = Color3.fromRGB(248, 113, 113)
			elseif remaining < 3600 then
				timeLabel.Text = formatRemaining(remaining)
				timeLabel.TextColor3 = Color3.fromRGB(250, 204, 21)
			else
				timeLabel.Text = formatRemaining(remaining)
				timeLabel.TextColor3 = Color3.fromRGB(74, 222, 128)
			end
			
			KeyUi.Background.MainScroll.LeftTime.Frame.Frame.Key.Text = Status.key or "无"
		end

		update()
		
		KeyUi.Background.MainScroll.LeftTime.Frame.Refresh.MouseButton1Click:Connect(function()
			hwid = KeyUi.Background.MainScroll.HWID.Input.Text
			CurrentLink = KeyManager.CreateLink(hwid, CurrentPlatform)
			Status = KeyManager.GetStatus(CurrentLink)
		end)
		
		local function TogglePlatform(Target)
			for i,v in KeyUi.Background.MainScroll.Main.Platform.Frame:GetChildren() do
				if v:IsA("TextButton") then
					Tween(v,{.1},{
						BackgroundColor3 = v.Name == Target and Color3.fromRGB(99, 102, 241) or Color3.fromRGB(2, 6, 23),
						BackgroundTransparency = v.Name == Target and 0 or .4,
						TextColor3 = v.Name == Target and Color3.fromRGB(199, 210, 254) or Color3.fromRGB(148, 163, 184),
					})
					CurrentPlatform = Target
				end
			end
		end
		
		TogglePlatform(CurrentPlatform)
		
		for i,v in KeyUi.Background.MainScroll.Main.Platform.Frame:GetChildren() do
			if v:IsA("TextButton") then
				v.MouseButton1Click:Connect(function()
					TogglePlatform(v.Name)
				end)
			end
		end

		task.spawn(function()
			while task.wait(1) do
				update()
			end
		end)
	end
end

--Rspy
do
	local RspyUI = MiscUi.Frame.Rspy
	local Rspy = {
		CodeBox = Delta.constructor.new(RspyUI.Main.Code),
		Colors = {
			fireserver = Color3.fromRGB(255, 200, 0),
			invokeserver = Color3.fromRGB(0, 150, 255),
			onclientevent = Color3.fromRGB(50, 255, 0),
			onclientinvoke = Color3.fromRGB(255, 100, 255),
			httpget = Color3.fromRGB(255, 0, 0),
			request = Color3.fromRGB(0, 0, 255),
		},
		CurrentInfo = nil,
		Methods = {
			fireserver = "%s:FireServer(unpack(args))",
			invokeserver = "%s:InvokeServer(unpack(args))",
			onclientevent = [[firesignal(%s.OnClientEvent,unpack(args))]],
			onclientinvoke = [[getcallbackvalue(%s,"OnClientInvoke")(unpack(args))]],
			httpget = "game:HttpGet(unpack(args))",
			request = "request(unpack(args))",
		},
	}
	
	Delta.Misc["Rspy"] = Rspy
	
	if not RunService:IsStudio() then
		if not isfile("LazyFix") then
			writefile("LazyFix",game:HttpGet("https://raw.githubusercontent.com/qian-cheng-awa/Tools/refs/heads/main/TableToLua.lua"))
		end
		LazyFix = getgenv().LazyFix or loadstring(readfile("LazyFix"))()
		getgenv().LazyFix = LazyFix
	end

	
	function Rspy.TableToString(table)
		return LazyFix.Convert(table, true)
	end

	function Rspy.GetPath(Obj)
		if typeof(Obj) ~= "Instance" then
			return tostring(Obj)
		end

		local function Same(a, b)
			if rawequal(a, b) then return true end
			if typeof(a) ~= "Instance" or typeof(b) ~= "Instance" then return false end
			if compareinstances then
				local ok, r = pcall(compareinstances, a, b)
				return ok and r
			end
			return false
		end

		local function Segment(Name)
			if type(Name) == "string" and Name:match("^[%a_][%w_]*$") then
				return "." .. Name
			end
			local Escaped = tostring(Name):gsub("\\", "\\\\"):gsub('"', '\\"'):gsub("\n", "\\n")
			return '["' .. Escaped .. '"]'
		end

		local function AsService(Child)
			if Child.Parent and Same(Child.Parent, game) then
				local ok, svc = pcall(game.FindService, game, Child.ClassName)
				if ok and svc and Same(svc, Child) then
					return ':GetService("' .. Child.ClassName .. '")'
				end
			end
			return nil
		end

		if Same(Obj, game) then
			return "game"
		end

		if Same(Obj, workspace) then
			return "workspace"
		end
		if Player and Same(Obj, Player) then
			return 'game:GetService("Players").LocalPlayer'
		end
		if Player and Player.Character and Same(Obj, Player.Character) then
			return 'game:GetService("Players").LocalPlayer.Character'
		end
		if Same(Obj, game:GetService("Players")) then
			return 'game:GetService("Players")'
		end
		if Same(Obj,gethui()) then
			return 'gethui()'
		end

		local Segments = {}
		local Cur = Obj
		local HitNilParent = false

		while Cur do
			if Same(Cur, game) then
				table.insert(Segments, 1, "game")
				break
			end
			if Same(Cur, workspace) then
				table.insert(Segments, 1, "workspace")
				break
			end
			if Same(Cur, gethui()) then
				table.insert(Segments, 1, "gethui()")
				break
			end
			if Player and Same(Cur, Player) then
				table.insert(Segments, 1, ".LocalPlayer")
				table.insert(Segments, 1, 'game:GetService("Players")')
				break
			end

			local Parent = Cur.Parent
			if not Parent then
				HitNilParent = true
				table.insert(Segments, 1, Segment(Cur.Name))
				break
			end

			local ServicePath = AsService(Cur)
			if ServicePath then
				table.insert(Segments, 1, ServicePath)
				table.insert(Segments, 1, "game")
				break
			end

			local Siblings = Parent.GetChildren(Parent)
			local SameNameCount = 0
			local MyIndex
			for i, child in ipairs(Siblings) do
				if child.Name == Cur.Name then
					SameNameCount += 1
					if Same(child, Cur) then
						MyIndex = i
					end
				end
			end

			if SameNameCount > 1 and MyIndex then
				table.insert(Segments, 1, ":GetChildren()[" .. MyIndex .. "]")
			else
				table.insert(Segments, 1, Segment(Cur.Name))
			end

			Cur = Parent
		end

		local Path = table.concat(Segments)
		if HitNilParent then
			Path = Path .. " --[[ Nil Parent ]]"
		end
		return Path
	end
	
	function Rspy.GenCode()
		RspyUI.Main.Stack.Visible = false
		RspyUI.Main.Code.Visible = true
		
		local CurrentInfo = Rspy.CurrentInfo
		
		local str = `local args = {Rspy.TableToString(CurrentInfo.Args)}`
		str = str .. "\n\n"
		str = str .. string.format(Rspy.Methods[CurrentInfo.Method], Rspy.GetPath(CurrentInfo.Remote) or "")
		
		Rspy.CodeBox:setRaw(str)
	end
	
	function Rspy.ReturnValue()
		RspyUI.Main.Stack.Visible = false
		RspyUI.Main.Code.Visible = true
		
		local CurrentInfo = Rspy.CurrentInfo

		local str = `local ReturnValue = {Rspy.TableToString(CurrentInfo.ReturnValue)}`

		Rspy.CodeBox:setRaw(str)
	end
	
	function Rspy.CallStack()
		RspyUI.Main.Stack.Visible = true
		RspyUI.Main.Code.Visible = false
		
		local CurrentInfo = Rspy.CurrentInfo
		
		for i,v in RspyUI.Main.Stack:GetChildren() do
			if v:IsA("TextButton") then
				v:Destroy()
			end
		end
		
		for i,v in CurrentInfo.CallStack do
			local NewButton = RspyUI.Main.Stack.UIListLayout.TextButton:Clone()
			NewButton.FunctionName = v.n
			NewButton.CallingScript = v.s
			
			NewButton.Parent = RspyUI.Main.Stack
			
			NewButton.MouseButton1Click:Connect(function()
				Rspy.CodeBox:setRaw(Rspy.TableToString(v.f))
			end)
		end
	end
	
	local MethodNormal = {
		fireserver = "FireServer",
		invokeserver = "InvokeServer",
		onclientinvoke = "OnClientInvoke",
		onclientevent = "OnClientEvent",
		httpget = "HttpGet",
	}
	
	local CallbackOwners = setmetatable({}, { __mode = "k" })
	local ConnectCache = setmetatable({}, { __mode = "k" })
	local LogCache = setmetatable({}, { __mode = "k" })
	
	local LogCounter = 0
	
	local Clone = game.Clone
	
	function Rspy.Log(Remote,Method,args,returnvalue)
		local targetcache
		
		if Method == "httpget" then
			LogCache[Method] = LogCache[Method] or {}
			if args[1] then
				targetcache = LogCache[Method][args[1]] or {}
				LogCache[Method][args[1]] = targetcache
			end
		elseif Method == "request" then
			LogCache[Method] = LogCache[Method] or {}
			if args[1] and args[1].Url then
				targetcache = LogCache[Method][args[1].Url] or {}
				LogCache[Method][args[1].Url] = targetcache
			end
		else
			LogCache[Remote] = LogCache[Remote] or {}
			targetcache = LogCache[Remote][Method] or {}
			LogCache[Remote][Method] = targetcache
		end
		
		if not targetcache then
			return
		end
		
		local NewButton = targetcache.Ui or Clone(RspyUI.List.ScrollingFrame.UIListLayout.Frame)
		if not targetcache.Ui then
			targetcache.Ui = NewButton
			NewButton.Parent = RspyUI.List.ScrollingFrame
			NewButton.TextButton.MouseButton1Click:Connect(function()
				NewButton.Child.Visible = not NewButton.Child.Visible
			end)
		end
		
		local Now = tick()
		local TextNow = os.date("%X")
		targetcache.Tick = Now
		
		LogCounter += 1
		NewButton.LayoutOrder = -LogCounter
		NewButton.RemoteName.Text = 
			(Method == "httpget" and args[1]) or 
			(Method == "request" and args[1].Url) or 
			(Remote.Name)
		
		NewButton.Tick.Text = TextNow
		NewButton.Frame.BackgroundColor3 = Rspy.Colors[Method] or Color3.fromRGB(255, 255, 255)
		
		local NewChildButton = Clone(NewButton.Child.UIListLayout.Frame)
		
		local CallStack = {}

		for level = 2, 30 do
			local s, n, f = debug.info(level, "snf")
			if not s then break end
			table.insert(CallStack, { s = s, n = n, f = f })
		end

		NewChildButton.Tick.Text = TextNow
		NewChildButton.Parent = NewButton.Child
		NewChildButton.TextButton.MouseButton1Click:Connect(function()
			Rspy.CurrentInfo = {
				Remote = Remote,
				Method = Method,
				Args = args,
				ReturnValue = returnvalue,
				CallStack = CallStack
			}
			
			RspyUI.Main.Method.Text = `{MethodNormal[Method] or Method}  ·  {Remote.Name}`
			RspyUI.Main.Path.Text = Rspy.GetPath(Remote)
			
			Rspy.GenCode()
		end)
	end
	
	
	local function ResolveCallable(Value)
		if typeof(Value) == "function" then
			return Value
		end

		local ok, mt = pcall(getrawmetatable, Value)
		if not ok or not mt then return nil end

		local hasCall, call = pcall(rawget, mt, "__call")
		return (hasCall and typeof(call) == "function") and call or nil
	end
	
	local function CreateDetour(Instance, Method, Callback)
		local Original = assert(ResolveCallable(Callback), "callback not callable")
		local IsDirect = rawequal(Callback, Original)

		local Detour = function(...)
			local Origin
			if getscriptfromthread then
				Origin = getscriptfromthread(coroutine.running())
			end
			if not Origin then
				local S = rawget(getfenv(Original), "script")
				if typeof(S) == "Instance" then Origin = S end
			end

			local args = table.pack(...)

			local InitEnv, InitIdentity = getfenv(0), getthreadidentity()

			setthreadidentity(2)
			setfenv(0, getfenv(Original))
			
			local success, results = pcall(function()
				if IsDirect then
					return table.pack(Original(table.unpack(args)))
				else
					return table.pack(Original(Callback, table.unpack(args)))
				end
			end)

			if not success then
				setfenv(0, InitEnv)
				setthreadidentity(InitIdentity)
				pcall(Rspy.Log, Instance, "onclientinvoke", args, nil)
				error(results, 0)
			end
			
			setfenv(0, InitEnv)
			setthreadidentity(InitIdentity)
			
			pcall(Rspy.Log, Instance, "onclientinvoke", args, results)
			return table.unpack(results, 1, results.n)
		end

		if setstackhidden then
			pcall(setstackhidden, Detour, true)
		end

		CallbackOwners[Detour] = {
			Original = Callback,
			Instance = Instance,
			Method   = Method,
		}

		return Detour
	end

	local function WrapAssignment(Instance, Method, Value)
		if typeof(Value) ~= "function" and ResolveCallable(Value) == nil then
			return Value
		end

		if CallbackOwners[Value] then
			return Value
		end

		return CreateDetour(Instance, Method, Value)
	end
	
	function Rspy.Init()
		local othhook = oth.hook
		
		local InstanceRaw = getrawmetatable(game)
		local tr = Instance.new("RemoteEvent")
		local SignalRaw = getrawmetatable(tr.OnClientEvent)
		
		RspyUI.Main.Buttons.Code.MouseButton1Click:Connect(function()
			Rspy.GenCode()
		end)
		RspyUI.Main.Buttons.Stack.MouseButton1Click:Connect(function()
			Rspy.CallStack()
		end)
		RspyUI.Main.Buttons.ReturnValue.MouseButton1Click:Connect(function()
			Rspy.ReturnValue()
		end)
		RspyUI.Main.Buttons.Copy.MouseButton1Click:Connect(function()
			setclipboard(Rspy.CodeBox:getRaw())
		end)
		
		local IsA = game.IsA
		
		local NameCall;NameCall = othhook(rawget(InstanceRaw,"__namecall"), function(...)
			local method = string.lower(getnamecallmethod() or "")
			
			local args = {select(2,...)}
			local self = (...)
			
			if method and self and typeof(self) == "Instance" then
				if (
					method == "fireserver" and 
						(
							IsA(self,"RemoteEvent") or 
							IsA(self,"UnreliableRemoteEvent")
						)
					) or 
						(
							method == "invokeserver" and 
							IsA(self,"RemoteFunction")
						) then
					
					local returnvalue = NameCall(...)
					
					pcall(Rspy.Log,self,method,args,returnvalue)

					return returnvalue
				elseif method == "httpget" and self.ClassName == "DataModel" then
					local returnvalue = NameCall(...)
					
					pcall(Rspy.Log,self,"httpget",args,returnvalue)
					
					return returnvalue
				end
			end
			
			return NameCall(...)
		end)
		
		local NewIndex;NewIndex = othhook(rawget(InstanceRaw,"__newindex"), function(...)
			local self, key, value = ...

			if typeof(self) == "Instance" and self.ClassName == "RemoteFunction" then
				local Method = "onclientinvoke"
				if string.lower(key or "") == Method then
					return NewIndex(self, key, WrapAssignment(self, Method, value))
				end
			end

			return NewIndex(...)
		end)
		
		local HttpGetH;HttpGetH = othhook(game.HttpGet, function(self, ...)
			local args = {...}
			
			local ReturnValue = HttpGetH(self, ...)
			
			pcall(Rspy.Log, self, "httpget", args, ReturnValue)
			
			return ReturnValue
		end)
		
		local requestH;requestH = othhook(request, function(...)
			local args = {...}
			
			local ReturnValue = requestH(...)
			
			pcall(Rspy.Log, nil, "request", args, ReturnValue)
			
			return ReturnValue
		end)
		
		local function RegisterSignal(Instance)
			local Signal = Instance["OnClientEvent"]
			if Signal and not ConnectCache[Signal] then
				ConnectCache[Signal] = Signal:Connect(function(...)
					pcall(Rspy.Log, Instance, "onclientevent", table.pack(...))
				end)
			end
		end

		local function HookRF(obj)
			local Method = "onclientinvoke"
			local ok, cb = pcall(getcallbackvalue, obj, "OnClientInvoke")
			if not ok or cb == nil or CallbackOwners[cb] then return end
			if ResolveCallable(cb) == nil then return end

			local InitEnv = getfenv(cb)
			local InitScript = rawget(InitEnv, "script")

			local assign = function()
				obj.OnClientInvoke = CreateDetour(obj, Method, cb)
			end

			if trampoline_call then
				trampoline_call(assign, {}, {
					env      = InitEnv,
					script   = InitScript,
					identity = 2,
				})
			else
				task.spawn(function()
					setthreadidentity(2)
					setfenv(0, InitEnv)
					assign()
				end)
			end
		end
		
		for _, obj in ipairs(game:GetDescendants()) do
			if obj:IsA("RemoteFunction") then
				HookRF(obj)
			elseif obj:IsA("RemoteEvent") or obj:IsA("UnreliableRemoteEvent") then
				pcall(RegisterSignal, obj)
			end
		end
		
		game.DescendantAdded:Connect(function(obj)
			if obj:IsA("RemoteFunction") then
				task.defer(HookRF, obj)
			elseif obj:IsA("RemoteEvent") or obj:IsA("UnreliableRemoteEvent") then
				pcall(RegisterSignal, obj)
			end
		end)
	end
end

--网易云
do
	type Song = {
		Id: number,
		Name: string,
		Author: string,
		Length: number,
		Loved: boolean,
		SoundId: string,
		ImageId: string,
	}

	local WYY = {
		PlayingSong = nil :: Song?,
		CachedSong = {} :: { [number]: Song }, 
		Loved = {} :: { [number]: Song },
		SongList = {} :: { string },
	}

	Delta.Misc["网易云"] = WYY
	
	local WYYUI = MiscUi.Frame.WYY

	local function GetLoved()
		if not isfolder("music163/Loved") then
			makefolder("music163/Loved")
		end
		local loved = listfiles("music163/Loved")
		
		for i, v in ipairs(loved) do
			loved[i] = string.sub(v,#("music163/Loved/")+1)
		end
		
		return loved
	end
	
	local function IsLoved(Id)
		local Id = tostring(Id)
		local Cached = GetLoved()
		if table.find(Cached, Id) then
			return true
		end
	end

	local function urlEncode(s)
		return tostring(s or ""):gsub("([^%w%-_%.~])", function(c)
			return string.format("%%%02X", string.byte(c))
		end)
	end


	local function GetThumb(ImageId)
		if isfile(`music163/Cached/{ImageId}_thumb.jpg`) then
			return getcustomasset(`music163/Cached/{ImageId}_thumb.jpg`)
		end

		if typeof(ImageId) == "string" then
			local id = tonumber(ImageId:match("id=(%d+)"))
			writefile(`music163/Cached/{id}_thumb.jpg`,game:HttpGet(ImageId))

			return getcustomasset(`music163/Cached/{id}_thumb.jpg`)
		end

		local MAGIC = "3go8&$8*3*3h0k(2)2"

		local id = tostring(ImageId)
		local key = {}
		for i = 1, #id do
			local m = MAGIC:byte((i-1) % #MAGIC + 1)
			key[i] = string.char(bit32.bxor(m, id:byte(i)))
		end
		local raw = md5(table.concat(key))
		local B64C = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
		local out = {}
		for i = 1, #raw, 3 do
			local a,b,c = raw:byte(i, i+2)
			local n = (a or 0)*65536 + (b or 0)*256 + (c or 0)
			out[#out+1] = B64C:sub(math.floor(n/262144)%64 + 1, math.floor(n/262144)%64 + 1)
			out[#out+1] = B64C:sub(math.floor(n/4096)%64 + 1, math.floor(n/4096)%64 + 1)
			out[#out+1] = b and B64C:sub(math.floor(n/64)%64 + 1, math.floor(n/64)%64 + 1) or "="
			out[#out+1] = c and B64C:sub(n%64 + 1, n%64 + 1) or "="
		end
		local b64 = table.concat(out):gsub("/","_"):gsub("+","-")

		writefile(`music163/Cached/{ImageId}_thumb.jpg`,game:HttpGet(`https://p1.music.126.net/{b64}/{id}.jpg?param=130y130`))

		return getcustomasset(`music163/Cached/{ImageId}_thumb.jpg`)
	end

	function WYY.Search(keywords, limit, offset)
		local api = `https://api.qijieya.cn/meting/?type=search&id={urlEncode(keywords)}&page={offset or 1}&limit={limit or 10}`
		--local api = `https://music.163.com/api/search/get/web?csrf_token=&type=1&offset={tostring(offset or 0)}&total=true&s={urlEncode(keywords)}&limit={tostring(limit or 10)}`
		local Result = game:HttpGet(api)

		if Result then
			local Info = HttpService:JSONDecode(Result)
			if Info then
				local Songs = {}

				for _, v in Info do
					table.insert(Songs,{
						Id = tonumber(v.url:match("id=(%d+)")),
						Name = v.name,
						Author = v.artist,
						ImageId = GetThumb(v.pic),
					})
				end

				return Songs
			end
		end
	end


	function WYY.GetSongInfo(ID)
		ID = tonumber(ID)
		if WYY.CachedSong[ID] then
			return WYY.CachedSong[ID]
		elseif isfile(`music163/Cached/{ID}`) then
			local Result = HttpService:JSONDecode(readfile(`music163/Cached/{ID}`))
			Result.SoundId = getcustomasset(`music163/Cached/{ID}.mp3`)
			Result.ImageId = getcustomasset(`music163/Cached/{ID}.jpg`)

			Result.Loved = isfile(`music163/Loved/{ID}`)

			WYY.CachedSong[ID] = Result
			return Result
		end

		local Api = `http://music.163.com/api/song/detail/?id={ID}&ids=[{ID}]`

		local Result = game:HttpGet(Api)

		if Result then
			local Info = HttpService:JSONDecode(Result)
			if Info then
				Info = Info.songs[1]

				if not isfile(`music163/Cached/{ID}.jpg`) then
					writefile(`music163/Cached/{ID}.jpg`,game:HttpGet(Info.album.picUrl))
				end


				local NewSong : Song = {
					SoundId = WYY.GetSongId(ID),
					ImageId = getcustomasset(`music163/Cached/{ID}.jpg`),
					Id = Info.id,
					Name = Info.name,
					Author = Info.artists[1].name,
					Length = Info.duration/1000,
					Loved = isfile(`music163/Loved/{ID}`)
				}

				WYY.CachedSong[ID] = NewSong

				writefile(`music163/Cached/{ID}`,HttpService:JSONEncode(NewSong))

				return NewSong
			end
		end
	end

	function WYY.GetSongId(Id,VIP)
		if WYY.CachedSong[Id] then
			return WYY.CachedSong[Id].SoundId
		end
		if isfile(`music163/Cached/{Id}.mp3`) then
			return getcustomasset(`music163/Cached/{Id}.mp3`)
		end

		local Api = `https://api.qijieya.cn/meting/?server=netease&type=url&id={Id}`

		local Success, Result = pcall(game.HttpGet,game,Api)
		if Success and Result then
			writefile(`music163/Cached/{Id}.mp3`,Result)
		end

		return getcustomasset(`music163/Cached/{Id}.mp3`)
	end

	function WYY.TogglePage(Page)
		if Page ~= "列表" then
			WYY.CurrentPage = Page
		end
	
		for i,v in WYYUI.List.Buttons:GetChildren() do
			if v:IsA("TextButton") then
				Tween(v,{.1},{
					BackgroundColor3 = v.Name == Page and Color3.fromRGB(194, 12, 12) or Color3.fromRGB(246, 246, 248),
					TextColor3 = v.Name == Page and Color3.fromRGB(255,255,255) or Color3.fromRGB(51, 51, 51)
				})
			end
		end
		
		for i,v in WYYUI.Pages:GetChildren() do
			v.Visible = v.Name == Page
		end
	end
	
	function WYY.Play(ID)
		ID = tostring(ID)
		local SongInfo = WYY.GetSongInfo(ID)
		if SongInfo then
			if not table.find(WYY.SongList,ID) then
				table.insert(WYY.SongList,ID)
			end
			
			WYY.PlayingSong = SongInfo
			
			WYYUI.Frame.SongName.Text = SongInfo.Name
			WYYUI.Frame.Author.Text = SongInfo.Author
			WYYUI.Frame.Image.Frame.ImageLabel.Image = SongInfo.ImageId
			WYYUI.Frame.Image.Frame.ImageLabel.Rotation = 0
			WYYUI.Frame.Love.Text = IsLoved(ID) and "❤" or "♡"
			
			WYYUI.Sound.SoundId = SongInfo.SoundId
			WYYUI.Sound.TimePosition = 0
			
			WYYUI.Sound:Play()
		end
	end
	
	function WYY.NewSongButton(Info)
		local NewSongButton = WYYUI.Song:Clone()
		NewSongButton.SongName.Text = Info.Name
		NewSongButton.TextButton.Text = Info.Author
		NewSongButton.Length.Text = Info.Length and fmtTime(Info.Length) or "Unknow"
		NewSongButton.ImageLabel.Image = Info.ImageId
		NewSongButton.Visible = true
		NewSongButton.MouseButton1Click:Connect(function()
			WYY.Play(Info.Id)
		end)
		
		return NewSongButton
	end
	
	function WYY.ShowList(List)
		for i,v in WYYUI.Pages["列表"].ScrollingFrame:GetChildren() do
			if v:IsA("TextButton") then
				v:Destroy()
			end
		end
		
		for _,id in List do
			local Info = WYY.GetSongInfo(id)
			WYY.NewSongButton(Info).Parent = WYYUI.Pages["列表"].ScrollingFrame
		end
		
		WYY.TogglePage("列表")
	end

	function WYY.Init()
		local SearchOffset = 0
		local SearchText = WYYUI.Top.Search.TextBox.Text
		
		
		WYYUI.Pages["列表"].TextButton.MouseButton1Click:Connect(function()
			if WYY.CurrentPage then
				WYY.TogglePage(WYY.CurrentPage)
			end
		end)
		WYYUI.Sound:GetPropertyChangedSignal("Playing"):Connect(function()
			WYYUI.Frame.Player.Frame.TextButton.Text = WYYUI.Sound.Playing and "II" or "▶"
		end)
		WYYUI.Sound:GetPropertyChangedSignal("PlaybackSpeed"):Connect(function()
			local v = WYYUI.Sound.PlaybackSpeed/3
			
			local Display = math.floor(WYYUI.Sound.PlaybackSpeed * 100) / 100
			
			WYYUI.Rate.CurrentRate.Text = `{Display}x`
			WYYUI.Frame.Rate.Text = `{Display}x`
			
			WYYUI.Rate.Scroll.Frame.Size = UDim2.fromScale(v,1)
			WYYUI.Rate.Scroll.Point.Position = UDim2.fromScale(v,.5)
		end)
		
		RunService.RenderStepped:Connect(function(dt)
			if WYYUI.Sound.Playing then
				WYYUI.Frame.Image.Frame.ImageLabel.Rotation += dt * 10
			end
			
			WYYUI.Frame.Player.TextLabel.Text = `{fmtTime(WYYUI.Sound.TimePosition)}/{fmtTime(WYYUI.Sound.TimeLength)}`

			local tl = WYYUI.Sound.TimeLength
			local v = (tl > 0) and math.clamp(WYYUI.Sound.TimePosition / tl, 0, 1) or 0

			WYYUI.Frame.Player.TextButton.Frame.Size = UDim2.fromScale(v,1)
			WYYUI.Frame.Player.TextButton.Point.Position = UDim2.fromScale(v,.5)
		end)
		
		local btn = WYYUI.Frame.Player.TextButton
		btn.MouseButton1Down:Connect(function()
			local ratioX
			local function update()
				local mouse = UserInputService:GetMouseLocation()
				local mx = mouse.X

				ratioX = math.clamp(
					(mx - btn.AbsolutePosition.X) / math.max(1, btn.AbsoluteSize.X),
					0, 1
				)
				
				WYYUI.Frame.Player.TextButton.Frame.Size = UDim2.fromScale(ratioX,1)
				WYYUI.Frame.Player.TextButton.Point.Position = UDim2.fromScale(ratioX,.5)
			end

			update()

			local a = RunService.RenderStepped:Connect(update)

			local b;b = UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch then
					if WYYUI.Sound.TimeLength > 0 and ratioX then
						WYYUI.Sound.TimePosition = WYYUI.Sound.TimeLength * ratioX
					end
					
					a:Disconnect()
					b:Disconnect()
				end
			end)
		end)
		
		local function AddSearchSongs(Offset)
			local List = WYY.Search(SearchText,10,Offset)
			
			for i,v in List do
				WYY.NewSongButton(v).Parent = WYYUI.Pages["搜索"].ScrollingFrame
			end
		end
		
		WYYUI.Frame.Player.Frame.TextButton.MouseButton1Click:Connect(function()
			if not WYY.PlayingSong then return end
			
			if WYYUI.Sound.Playing then
				WYYUI.Sound:Pause()
			else
				WYYUI.Sound:Resume()
			end
		end)
		
		WYYUI.Frame.Player.Last.MouseButton1Click:Connect(function()
			if not WYY.PlayingSong then return end
			local CurrentId = WYY.PlayingSong.Id
			local index = table.find(WYY.SongList,tostring(CurrentId))
			if index then
				if index <= 1 then
					index = #WYY.SongList
				else
					index -= 1
				end
				
				WYY.Play(WYY.SongList[index])
			end
		end)
		WYYUI.Frame.Player.New.MouseButton1Click:Connect(function()
			if not WYY.PlayingSong then return end
			local CurrentId = WYY.PlayingSong.Id
			local index = table.find(WYY.SongList,tostring(CurrentId))
			if index then
				if index >= #WYY.SongList then
					index = 1
				else
					index += 1
				end
				
				WYY.Play(WYY.SongList[index])
			end
		end)
		WYYUI.Frame.Love.MouseButton1Click:Connect(function()
			if not WYY.PlayingSong then return end
			local id = WYY.PlayingSong.Id
			
			if IsLoved(id) then
				delfile(`music163/Loved/{id}`)
				WYYUI.Frame.Love.Text = "♡"
			else
				writefile(`music163/Loved/{id}`,"Obi_xieO")
				WYYUI.Frame.Love.Text = "❤"
			end
			
			if WYY.RefreshLoved then
				WYY.RefreshLoved()
			end
		end)
		
		WYYUI.Frame.Rate.MouseButton1Click:Connect(function()
			WYYUI.Rate.Visible = not WYYUI.Rate.Visible
		end)
		WYYUI.Frame.Volume.MouseButton1Click:Connect(function()
			WYYUI.Volume.Visible = not WYYUI.Volume.Visible
		end)
		
		local ratebtn = WYYUI.Rate.TextButton
		ratebtn.MouseButton1Down:Connect(function()
			local ratioX
			local function update()
				local mouse = UserInputService:GetMouseLocation()
				local mx = mouse.X

				ratioX = math.clamp(
					(mx - ratebtn.AbsolutePosition.X) / math.max(1, ratebtn.AbsoluteSize.X),
					0, 1
				)
				
				WYYUI.Rate.Scroll.Frame.Size = UDim2.fromScale(ratioX,1)
				WYYUI.Rate.Scroll.Point.Position = UDim2.fromScale(ratioX,.5)
				WYYUI.Rate.CurrentRate.Text = `{math.floor(300 * ratioX)/100}x`
			end

			update()

			local a = RunService.RenderStepped:Connect(update)

			local b;b = UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch then
					
					WYYUI.Sound.PlaybackSpeed = math.floor(300 * ratioX)/100

					a:Disconnect()
					b:Disconnect()
				end
			end)
		end)
		
		local volumebtn = WYYUI.Volume.TextButton
		volumebtn.MouseButton1Down:Connect(function()
			local ratioX
			local function update()
				local mouse = UserInputService:GetMouseLocation()
				local mx = mouse.X

				ratioX = math.clamp(
					(mx - volumebtn.AbsolutePosition.X) / math.max(1, volumebtn.AbsoluteSize.X),
					0, 1
				)

				WYYUI.Volume.Scroll.Frame.Size = UDim2.fromScale(ratioX,1)
				WYYUI.Volume.Scroll.Point.Position = UDim2.fromScale(ratioX,.5)
				WYYUI.Sound.Volume = math.floor(ratioX*100)/100
				WYYUI.Volume.CurrentVolume.Text = math.floor(ratioX * 100) .. "%"
			end

			update()

			local a = RunService.RenderStepped:Connect(update)

			local b;b = UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch then
					a:Disconnect()
					b:Disconnect()
				end
			end)
		end)
		
		WYYUI.Top.Search.TextBox.FocusLost:Connect(function(enter)
			if enter then
				for i,v in WYYUI.Pages["搜索"].ScrollingFrame:GetChildren() do
					if v:IsA("TextButton") and v.Name ~= "LoadMore" then
						v:Destroy()
					end
				end
				
				WYY.TogglePage("搜索")
				
				SearchOffset = 1
				SearchText = WYYUI.Top.Search.TextBox.Text
				
				AddSearchSongs(SearchOffset)
			end
		end)
		WYYUI.Pages["搜索"].ScrollingFrame.LoadMore.MouseButton1Click:Connect(function()
			SearchOffset += 1
			
			AddSearchSongs(SearchOffset)
		end)
		WYYUI.List.Buttons["搜索"].MouseButton1Click:Connect(function()
			WYY.TogglePage("搜索")
			WYY.RefreshLoved = nil
		end)
		WYYUI.List.Buttons["推荐"].MouseButton1Click:Connect(function()
			WYY.TogglePage("推荐")
			WYY.RefreshLoved = nil
		end)
		WYYUI.List.Buttons["喜欢"].MouseButton1Click:Connect(function()
			WYY.ShowList(GetLoved())
			WYY.RefreshLoved = function()
				WYY.ShowList(GetLoved())
			end
		end)
		WYYUI.List.Buttons["队列"].MouseButton1Click:Connect(function()
			WYY.ShowList(WYY.SongList)
			WYY.RefreshLoved = nil
		end)
		
		WYYUI.Sound.Ended:Connect(function()
			WYY.Play(WYY.PlayingSong.Id)
		end)
		
		for i,v in WYY.Search("热歌",20,1) do
			WYY.NewSongButton(v).Parent = WYYUI.Pages["推荐"].ScrollingFrame
		end
	end
end

Delta:Init()
