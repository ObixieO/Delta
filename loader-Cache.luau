local Path = "DeltaByObi_xieO"

if not isfile(Path) then
	writefile(Path,base64decode(game:GetService("HttpService"):JSONDecode(game:HttpGet("https://api.github.com/repos/ObixieO/Delta/contents/Main.luau?ref=main")).content))
	writefile("DeltaUiCached",game:HttpGet("https://raw.githubusercontent.com/ObixieO/Delta/refs/heads/main/DeltaUi.rbxm"))
	writefile("CompletionModule",game:HttpGet("https://raw.githubusercontent.com/ObixieO/Delta/refs/heads/main/CompletionModule.luau"))
else
	task.spawn(function()
		writefile(Path,base64decode(game:GetService("HttpService"):JSONDecode(game:HttpGet("https://api.github.com/repos/ObixieO/Delta/contents/Main.luau?ref=main")).content))
		writefile("DeltaUiCached",game:HttpGet("https://raw.githubusercontent.com/ObixieO/Delta/refs/heads/main/DeltaUi.rbxm"))
		writefile("CompletionModule",game:HttpGet("https://raw.githubusercontent.com/ObixieO/Delta/refs/heads/main/CompletionModule.luau"))
	end)
end

loadstring(readfile(Path))()
