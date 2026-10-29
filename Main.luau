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
		if not Delta.Settings.CurrentSettings.CodeHighlight then return end

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
		loadstring(Delta.CurrentScript.Source)()
	end)
	Buttons.Clear.MouseButton1Click:Connect(function()
		CodeInput.Text = ""
	end)
	Buttons.Save.MouseButton1Click:Connect(function()
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
			Delta:AddConsoleMessage("Delta",table.concat({...}," "),Enum.MessageType.MessageOutput)
		end
		getgenv().warn = function(...)
			Delta:AddConsoleMessage("Delta",table.concat({...}," "),Enum.MessageType.MessageWarning)
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

Delta:Init()
