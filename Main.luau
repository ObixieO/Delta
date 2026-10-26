local DefaultScript = [[

--忍者UI美化
--By Obi_xieO

]]

local Delta = {
	UIDownloadUrl = "https://raw.githubusercontent.com/ObixieO/Delta/refs/heads/main/DeltaUi.rbxm",
	UiTransparency = {},
	Closed = true,
	Connections = {},
	UiOpenButtonPosition = UDim2.new(.5,0,0,58),
	Scripts = {},
	CurrentScript = nil,
	Highlighter = {},
	DeltaUi = nil,
	NavIslandPositions = {
		Top = {
			Position = UDim2.new(0.5,0,0,58),
		},
		Bottom = {
			Position = UDim2.new(0.5,0,1,-40),
		},
	},
	CurrentNavIslandPosition = "Top",
}

local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LogService = game:GetService("LogService")
local ScriptContext = game:GetService("ScriptContext")
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



if RunService:IsStudio() then
	Delta.Ui = Player.PlayerGui:WaitForChild("Delta")
else
	local IsFile = isfile("DeltaUiCached")
	if not isfolder("SavedScripts") then
		makefolder("SavedScripts")
	end
	
	for i,v in gethui():GetChildren() do
		if v:FindFirstChild("UILibrary") and v:FindFirstChild("MainScript") then
			Delta.DeltaUi = v
		end
	end
	
	local Loadedevent = Instance.new("BindableEvent")
	
	task.spawn(function()
		writefile("DeltaUiCached",game:HttpGet(Delta.UIDownloadUrl))
		writefile("CompletionModule",game:HttpGet("https://raw.githubusercontent.com/ObixieO/Delta/refs/heads/main/CompletionModule.luau"))
		if not IsFile then
			Delta.Ui = game:GetObjects(getcustomasset("DeltaUiCached"))[1]
		end
		Loadedevent:Fire()
	end)
	
	if IsFile then
		Delta.Ui = game:GetObjects(getcustomasset("DeltaUiCached"))[1]
	else
		Loadedevent.Event:Wait()
	end
	
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

	Tween(Delta.Ui.NavIsland,{.1},{
		Size = UDim2.fromOffset(320,44),
		Position = UDim2.new(.5,0,0,58)
	})

	
	if Delta.Connections.Drag then
		Delta.Connections.Drag:Disconnect()
	end
end

function Delta:CloseUi()
	local Id = tick()
	Delta.CloseId = Id
	
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
			BackgroundColor3 = Color3.fromRGB(91, 116, 110)
		})
		Tween(Delta.CurrentScript.Button.UIStroke,{.25},{
			Color = Color3.fromRGB(91, 116, 110)
		})
	end
	
	Tween(Script.Button,{.25},{
		BackgroundColor3 = Color3.fromRGB(131, 216, 255)
	})
	Tween(Script.Button.UIStroke,{.25},{
		Color = Color3.fromRGB(131, 216, 255)
	})
	
	CodeFrame.Text.Code.ScrollingFrame.TextBox.Text = Script.Source
	
	Delta.CurrentScript = Script

end

function Delta:AddScript(Name,scr)
	scr = scr or ""
	local FinalName = Name
	if Delta.Scripts[Name] then
		local c = 1
		while Delta.Scripts[FinalName] do
			FinalName = Name.." "..tostring(c)
			c += 1
		end
	end
	local Scripts = Delta.Ui.ContentIsland.Main.code.Buttons.Scripts
	local NewScriptButton = Scripts.UIListLayout.TextButton:Clone()
	NewScriptButton.Name = FinalName
	NewScriptButton.Text = FinalName
	NewScriptButton.Parent = Scripts
	
	NewScriptButton.MouseButton1Click:Connect(function()
		Delta:OpenScript(FinalName)
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
	local t = os.date("*t")
	local str = string.format("%02d:%02d:%02d", t.hour, t.min, t.sec)

	local Text = Message
	local NewText: TextLabel = ConsoleUi:FindFirstChild(Side).UIListLayout.TextLabel:Clone()

	NewText.RichText = true
	NewText.Text = string.format('<font color="#FFFFFF">[%s]</font> %s', str, Message)
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
	
	local Completion = RunService:IsStudio() and require(script.CompletionModule) or loadstring(readfile("CompletionModule"))()

	Completion.bind(CodeInput,{})
	
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
			if v:IsA("Frame") and not v.TextLabel.Text:find(Text) then
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
	
	if not RunService:IsStudio() then
		Delta:RefreshSavedScript()
	end
	
	local oldprint = print
	local oldwarn = warn
	local olderror = error
	
	if RunService:IsStudio() then
		getfenv().print = function(...)
			Delta:AddConsoleMessage("Delta",table.concat({...}," "),Enum.MessageType.MessageOutput)
			return oldprint(...)
		end
		getfenv().warn = function(...)
			Delta:AddConsoleMessage("Delta",table.concat({...}," "),Enum.MessageType.MessageWarning)
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
			if Tscript == script or (Tscript.Parent == nil and Tscript.Name == "LocalScript") then
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
			return oldprint(...)
		end
		getgenv().warn = function(...)
			Delta:AddConsoleMessage("Delta",table.concat({...}," "),Enum.MessageType.MessageWarning)
			return oldwarn(...)
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
			return olderror(Message,level)
		end
	end
	
	Delta:CloseUi()
	
	Delta:AddScript("Script",DefaultScript)
	Delta:OpenScript("Script")
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
