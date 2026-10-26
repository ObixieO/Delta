--!nocheck
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")
local ReflectionService = game:GetService("ReflectionService")
local GuiService = game:GetService("GuiService")

local Completion = {}
Completion.__index = Completion

-- ============================================================
-- 常量表
local BASE_TYPES = {
	["string"] = true, ["number"] = true, ["boolean"] = true, ["nil"] = true,
	["any"] = true, ["table"] = true, ["thread"] = true, ["userdata"] = true,
	["function"] = true, ["never"] = true, ["unknown"] = true,
}
local KEYWORDS = {
	"and", "break", "continue", "do", "else", "elseif", "end",
	"false", "for", "function", "if", "in", "local", "nil",
	"not", "or", "repeat", "return", "then", "true", "until", "while",
}

local GLOBAL_FUNCTIONS = {
	"assert", "error", "getfenv", "getmetatable", "ipairs", "loadstring",
	"newproxy", "next", "pairs", "pcall", "print", "rawequal", "rawget",
	"rawlen", "rawset", "select", "setfenv", "setmetatable", "tonumber",
	"tostring", "type", "typeof", "unpack", "warn", "xpcall", "require",
	"collectgarbage", "delay", "elapsedTime", "spawn", "tick", "time",
	"wait", "UserSettings", "settings", "DebuggerManager", "PluginManager",
}

local GLOBAL_NAMES = {
	"_G", "_VERSION", "shared",
	"bit32", "buffer", "coroutine", "debug", "math", "os", "string",
	"table", "utf8", "vector",
	"Axes", "BrickColor", "CFrame", "Color3", "ColorSequence",
	"ColorSequenceKeypoint", "DockWidgetPluginGuiInfo", "Enum", "Faces",
	"Instance", "NumberRange", "NumberSequence", "NumberSequenceKeypoint",
	"PathWaypoint", "PhysicalProperties", "Random", "Ray", "Rect",
	"Region3", "Region3int16", "TweenInfo", "UDim", "UDim2",
	"Vector2", "Vector2int16", "Vector3", "Vector3int16",
	"game", "workspace", "script", "task",
}

local TABLE_MEMBERS = {
	task = { "spawn", "defer", "delay", "wait", "cancel", "synchronize", "desynchronize" },
	math = {
		"abs", "acos", "asin", "atan", "atan2", "ceil", "clamp", "cos", "deg",
		"exp", "floor", "fmod", "frexp", "huge", "ldexp", "log", "log10", "max",
		"min", "modf", "pi", "pow", "rad", "random", "randomseed", "sin", "sqrt",
		"tan", "noise", "sign", "round", "isnan", "isinf", "isfinite",
	},
	string = {
		"byte", "char", "find", "format", "gmatch", "gsub", "len", "lower",
		"match", "rep", "reverse", "sub", "upper", "split", "pack", "unpack", "packsize",
	},
	table = {
		"concat", "insert", "move", "pack", "remove", "sort", "unpack",
		"create", "find", "clone", "freeze", "isfrozen", "maxn", "foreach",
		"foreachi", "getn",
	},
	coroutine = { "close", "create", "isyieldable", "resume", "running", "status", "wrap", "yield" },
	os = { "clock", "date", "difftime", "time" },
	utf8 = { "char", "codes", "codepoint", "len", "offset", "nfcnormalize", "nfdnormalize", "graphemes" },
	bit32 = { "arshift", "band", "bnot", "bor", "btest", "bxor", "extract", "lshift", "replace", "rshift" },
	buffer = {
		"create", "fromstring", "tostring", "len", "readi8", "readu8", "readi16",
		"readu16", "readi32", "readu32", "readf32", "readf64", "writei8", "writeu8",
		"writei16", "writeu16", "writei32", "writeu32", "writef32", "writef64",
		"readstring", "writestring", "copy", "fill",
	},
	debug = {
		"getproto", "getprotos", "getconstants", "getconstant", "getstack", "setstack",
		"getupvalue", "getupvalues", "setupvalue", "traceback", "info",
		"profilebegin", "profileend",
	},
	vector = {
		"create", "magnitude", "normalize", "dot", "cross", "angle", "floor",
		"ceil", "abs", "sign", "clamp", "min", "max",
	},
}

-- ============================================================
-- 工具函数
-- ============================================================
local function getInstanceChildren(instance)
	if not instance then return {} end
	local ok, children = pcall(function() return instance:GetChildren() end)
	return ok and children or {}
end

local function isIdentChar(c)
	return c ~= "" and c:match("[%a%d_]") ~= nil
end

local function getWordStart(text, cursorPos)
	local i = cursorPos
	while i >= 1 do
		if not isIdentChar(text:sub(i, i)) then return i + 1 end
		i = i - 1
	end
	return 1
end

local function getWordEnd(text, cursorPos)
	local i = cursorPos
	while i <= #text do
		if not isIdentChar(text:sub(i, i)) then return i - 1 end
		i = i + 1
	end
	return #text
end

local function isInsideStringOrComment(lineText, cursorPos)
	local inString = false
	local stringChar = nil
	local i = 1
	while i < cursorPos do
		local c = lineText:sub(i, i)
		local n = lineText:sub(i + 1, i + 1)
		if inString then
			if c == "\\" then i = i + 2
			elseif c == stringChar then inString = false stringChar = nil i = i + 1
			else i = i + 1 end
		else
			if c == "-" and n == "-" then return false, true
			elseif c == '"' or c == "'" then inString = true stringChar = c i = i + 1
			else i = i + 1 end
		end
	end
	return inString, false
end

local function isInLongString(beforeCursor)
	local opens, closes = 0, 0
	for _ in beforeCursor:gmatch("%[%[") do opens = opens + 1 end
	for _ in beforeCursor:gmatch("%]%]") do closes = closes + 1 end
	return opens > closes
end

local function toStr(v)
	if type(v) == "string" then return v end
	if type(v) == "number" then return tostring(v) end
	if type(v) == "table" then
		if v.Name then return tostring(v.Name) end
		if v.Type then return tostring(v.Type) end
		if v.ClassName then return tostring(v.ClassName) end
		local parts = {}
		for k, val in pairs(v) do parts[#parts + 1] = tostring(k) .. "=" .. tostring(val) end
		return "{" .. table.concat(parts, ", ") .. "}"
	end
	return tostring(v)
end

local function getTypeName(v)
	if type(v) == "string" then return v end
	if type(v) == "table" then
		if v.Type then
			if type(v.Type) == "table" then return v.Type.ScriptType or v.Type.EngineType end
			return v.Type
		end
		return v.ScriptType or v.EngineType
	end
	return nil
end

-- ============================================================
-- ReflectionService 缓存
-- ============================================================
local classCache, methodCache, propertyCache, eventCache, memberCache = {}, {}, {}, {}, {}

local function initClassCache()
	for _, class in ipairs(ReflectionService:GetClasses()) do
		classCache[class.Name] = {
			superclass = class.Superclass,
			subclasses = class.Subclasses,
			tags = class.Tags or {},
		}
	end
end

local function getMethods(className)
	if methodCache[className] then return methodCache[className] end
	local list = {}
	local ok, res = pcall(function() return ReflectionService:GetMethodsOfClass(className) end)
	if ok and res then list = res end
	methodCache[className] = list
	return list
end

local function getProperties(className)
	if propertyCache[className] then return propertyCache[className] end
	local list = {}
	local ok, res = pcall(function() return ReflectionService:GetPropertiesOfClass(className) end)
	if ok and res then list = res end
	propertyCache[className] = list
	return list
end

local function getEvents(className)
	if eventCache[className] then return eventCache[className] end
	local list = {}
	local ok, res = pcall(function() return ReflectionService:GetEventsOfClass(className) end)
	if ok and res then list = res end
	eventCache[className] = list
	return list
end

local function getAllMembers(className)
	if memberCache[className] then
		local c = memberCache[className]
		return c.methods, c.properties, c.events
	end
	local methods, properties, events = {}, {}, {}
	local seen = {}
	local current = className
	while current and not seen[current] do
		seen[current] = true
		for _, m in ipairs(getMethods(current)) do
			if not methods[m.Name] then methods[m.Name] = m end
		end
		for _, p in ipairs(getProperties(current)) do
			if not properties[p.Name] then properties[p.Name] = p end
		end
		for _, e in ipairs(getEvents(current)) do
			if not events[e.Name] then events[e.Name] = e end
		end
		local info = classCache[current]
		current = info and info.superclass
	end
	memberCache[className] = { methods = methods, properties = properties, events = events }
	return methods, properties, events
end

local function getGlobalInstance(name)
	local ok, val = pcall(function() return getfenv()[name] end)
	if ok and typeof(val) == "Instance" then return val end
	return nil
end

local function getGlobalClass(name)
	local ok, val = pcall(function() return getfenv()[name] end)
	if ok and val ~= nil and typeof(val) ~= "Instance" then return type(val) end
	return nil
end

-- ============================================================
-- 表达式类型推断
-- ============================================================
local parseTableLiteral

local function inferLiteralType(expr)
	expr = expr:gsub("^%s+", ""):gsub("%s+$", "")
	if expr:match("^%-?%d+%.?%d*$") then return "number" end
	if expr:match('^".*"$') or expr:match("^'.*'$") then return "string" end
	if expr == "true" or expr == "false" then return "boolean" end
	if expr == "nil" then return "nil" end
	if expr:match("^%{") then return "table" end
	if expr:match("^function%s*%(") then return "function" end
	return nil
end

local function splitTableFields(inner)
	local parts = {}
	local depth = 0
	local start = 1
	local inString = false
	local stringChar = nil
	local i = 1
	while i <= #inner do
		local c = inner:sub(i, i)
		if inString then
			if c == "\\" then i = i + 2
			elseif c == stringChar then inString = false stringChar = nil i = i + 1
			else i = i + 1 end
		else
			if c == '"' or c == "'" then inString = true stringChar = c i = i + 1
			elseif c == "{" or c == "(" or c == "[" then depth = depth + 1 i = i + 1
			elseif c == "}" or c == ")" or c == "]" then depth = depth - 1 i = i + 1
			elseif c == "," and depth == 0 then
				parts[#parts + 1] = inner:sub(start, i - 1)
				start = i + 1
				i = i + 1
			else i = i + 1 end
		end
	end
	if start <= #inner then parts[#parts + 1] = inner:sub(start) end
	return parts
end

local function inferCallReturn(expr, vars)
	expr = expr:gsub("^%s+", ""):gsub("%s+$", "")
	local cls = expr:match('Instance%.new%s*%(%s*["\']([%w_]+)["\']')
	if cls then return { className = cls } end
	local svc = expr:match('game:GetService%s*%(%s*["\']([%w_]+)["\']')
	if svc then return { className = svc } end
	local recv, method = expr:match("([%a_][%w_]*)%s*:%s*([%a_][%w_]*)%s*%(")
	if recv and method and vars[recv] and vars[recv].className then
		for _, m in ipairs(getMethods(vars[recv].className)) do
			if m.Name == method then
				local rt = toStr(m.ReturnType)
				if rt and rt ~= "" and rt ~= "nil" and classCache[rt] then
					return { className = rt }
				end
				return { type = rt or "unknown" }
			end
		end
	end
	return nil
end

local function resolveExprType(expr, vars)
	expr = expr:gsub("^%s+", ""):gsub("%s+$", "")
	if expr == "" then return { type = "unknown" } end

	if expr:match("^%{") then
		local t = parseTableLiteral(expr, vars)
		if t then return t end
		return { type = "table", fields = {} }
	end

	local lit = inferLiteralType(expr)
	if lit then return { type = lit } end

	local ok, gv = pcall(function() return getfenv()[expr] end)
	if ok and typeof(gv) == "Instance" then
		return { className = gv.ClassName, instance = gv }
	end

	local call = inferCallReturn(expr, vars)
	if call then return call end

	if vars[expr] then return vars[expr] end

	return { type = "unknown" }
end

parseTableLiteral = function(expr, vars)
	local inner = expr:match("^%s*%{%s*(.-)%s*%}%s*$")
	if not inner then return nil end
	local fields = {}
	if inner ~= "" then
		for _, part in ipairs(splitTableFields(inner)) do
			local key, val = part:match("^%s*([%a_][%w_]*)%s*=%s*(.+)$")
			if key and val then
				local t = resolveExprType(val, vars)
				if t then fields[key] = t end
			end
		end
	end
	return { type = "table", fields = fields }
end

-- ============================================================
-- 增量分析器：全量 parseLine，rebuildFrom 从 1 重建到光标行
-- ============================================================
local IncrementalAnalyzer = {}
IncrementalAnalyzer.__index = IncrementalAnalyzer

function IncrementalAnalyzer.new()
	return setmetatable({
		lines = {},
		lineTexts = {},
		scopeStack = nil,
		lastCursorLine = 0,
	}, IncrementalAnalyzer)
end

local function parseLine(line)
	local result = {
		locals = {},
		assigns = {},
		functions = {},
		blockOpen = false,
		blockClose = false,
	}

	local trimmed = line:gsub("^%s+", "")

	-- 单行 if ... end 判定
	local singleLineIf = trimmed:match("^if%s") and trimmed:match("end%s*$") and true or false
	if not singleLineIf then
		-- function 块：function name(...) / local function name(...) / local x = function(...)
		local isFuncBlock = false
		if trimmed:match("^function%s") or trimmed:match("^local%s+function%s") then
			isFuncBlock = true
		elseif trimmed:match("function%s*%(") and not trimmed:match("function%s*%([^)]*%)%s*.-end") then
			isFuncBlock = true
		end
		if isFuncBlock or trimmed:match("^do%s*$") or trimmed:match("^for%s") or
			trimmed:match("^while%s") or trimmed:match("^repeat%s*$") or trimmed:match("^if%s") then
			result.blockOpen = true
		end
		if trimmed:match("^end%s*$") or trimmed:match("^end%s*[^%w_]") or trimmed:match("^until%s") then
			result.blockClose = true
		end
	end

	-- 函数声明
	local fname, params = line:match("^%s*local%s+function%s+([%a_][%w_]*)%s*%(([^)]*)%)")
	if fname then
		result.functions[#result.functions + 1] = { name = fname, params = params or "", isLocal = true }
	else
		fname, params = line:match("^%s*function%s+([%a_][%w_]*)%s*%(([^)]*)%)")
		if fname then
			result.functions[#result.functions + 1] = { name = fname, params = params or "", isLocal = false }
		end
	end

	-- local name: Type [= expr]
	local aname, atype = line:match("local%s+([%a_][%w_]*)%s*:%s*([%a_][%w_%.]*)")
	if aname then
		local expr = line:match("local%s+" .. aname .. "%s*:%s*[%a_][%w_%.]*%s*=%s*(.+)$")
		result.locals[#result.locals + 1] = { name = aname, annotation = atype, exprText = expr }
	else
		local lname, lexpr = line:match("local%s+([%a_][%w_]*)%s*=%s*(.+)$")
		if lname then
			result.locals[#result.locals + 1] = { name = lname, exprText = lexpr }
		end
	end

	-- 普通赋值
	local sname, sexpr = line:match("^%s*([%a_][%w_]*)%s*=%s*(.+)$")
	if sname and not line:match("^%s*local%s") then
		result.assigns[#result.assigns + 1] = { name = sname, exprText = sexpr }
	end

	return result
end

-- 在作用域栈上处理一行，返回新的 depth
local function applyLineToScopes(l, scopes, depth)
	local function current() return scopes[depth] end
	local function pushScope()
		depth = depth + 1
		scopes[depth] = { vars = {}, functions = {} }
	end
	local function popScope()
		if depth > 1 then
			scopes[depth] = nil
			depth = depth - 1
		end
	end
	local function visibleVars()
		local merged = {}
		for i = 1, depth do
			for k, v in pairs(scopes[i].vars) do merged[k] = v end
		end
		return merged
	end
	local function declare(name, t)
		current().vars[name] = t
	end
	local function assign(name, t)
		for i = depth, 1, -1 do
			local v = scopes[i].vars[name]
			if v then
				if not v.locked then scopes[i].vars[name] = t end
				return
			end
		end
		current().vars[name] = t
	end

	-- 先处理块关闭
	if l.blockClose then popScope() end

	-- 函数声明
	for _, fn in ipairs(l.functions) do
		if fn.isLocal then
			current().vars[fn.name] = { type = "function" }
		else
			current().functions[fn.name] = { params = fn.params }
		end
	end

	-- 局部变量
	local vars = visibleVars()
	for _, d in ipairs(l.locals) do
		local t
		if d.annotation then
			local lower = d.annotation:lower()
			if BASE_TYPES[lower] then
				t = { type = lower, locked = true }
			else
				t = { className = d.annotation, locked = true }
			end
		else
			t = resolveExprType(d.exprText or "", vars)
			if not t then t = { type = "unknown" } end
		end
		declare(d.name, t)
	end

	-- 普通赋值
	for _, a in ipairs(l.assigns) do
		local t = resolveExprType(a.exprText or "", vars)
		if t then assign(a.name, t) end
	end

	-- 再处理块开启
	if l.blockOpen then pushScope() end

	return depth
end

function IncrementalAnalyzer:rebuildFrom(startLine, targetLine)
	local scopes = { { vars = {}, functions = {} } }
	local curDepth = 1
	for i = 1, targetLine do
		local l = self.lines[i]
		if l then
			curDepth = applyLineToScopes(l, scopes, curDepth)
		end
	end

	local mergedVars, mergedFuncs = {}, {}
	for i = 1, curDepth do
		for k, v in pairs(scopes[i].vars) do mergedVars[k] = v end
		for k, v in pairs(scopes[i].functions) do mergedFuncs[k] = v end
	end
	self.scopeStack = { vars = mergedVars, functions = mergedFuncs }
end

function IncrementalAnalyzer:update(text, cursorLine)
	local newLines = {}
	for line in text:gmatch("[^\r\n]*") do newLines[#newLines + 1] = line end

	local newCache = {}
	for i = 1, #newLines do
		newCache[i] = parseLine(newLines[i])
	end

	self.lines = newCache
	self.lineTexts = newLines
	self:rebuildFrom(1, #newLines)
	self.lastCursorLine = cursorLine
end

function IncrementalAnalyzer:getVisible(cursorLine)
	if not self.scopeStack then self:rebuildFrom(1, #self.lines) end
	return self.scopeStack.vars, self.scopeStack.functions
end
-- ============================================================
-- 补全生成
-- ============================================================
local function buildSuggestions(context, vars, functions)
	local suggestions = {}
	local before = context.beforeCursor

	-- local 后输入变量名
	if before:match("local%s+[%a_%w_]*$") then
		suggestions[#suggestions + 1] = { label = "function", kind = "keyword", detail = "关键字", insertText = "function" }
		return suggestions
	end

	-- local name: 后补全类型
	if before:match("local%s+[%a_][%w_]*%s*:%s*[%a_%w_]*$") then
		for name in pairs(BASE_TYPES) do
			suggestions[#suggestions + 1] = { label = name, kind = "type", detail = "基础类型", insertText = name }
		end
		for name in pairs(classCache) do
			suggestions[#suggestions + 1] = { label = name, kind = "type", detail = "Roblox 类", insertText = name }
		end
		return suggestions
	end

	-- 字符串内补全
	if context.inString then
		if before:match('game:GetService%s*%(%s*["\']?[%w_]*$') then
			for name, info in pairs(classCache) do
				if table.find(info.tags, "Service") then
					suggestions[#suggestions + 1] = { label = name, kind = "service", detail = "Roblox 服务", insertText = '"' .. name .. '"' }
				end
			end
			return suggestions
		end
		if before:match('Instance%.new%s*%(%s*["\']?[%w_]*$') then
			for name in pairs(classCache) do
				suggestions[#suggestions + 1] = { label = name, kind = "class", detail = "Roblox 类", insertText = '"' .. name .. '"' }
			end
			return suggestions
		end
		local childMatch = before:match(":%s*(FindFirstChild[%w_]*)%s*%(%s*[\"']?([%w_]*)$")
		if childMatch then
			local serviceName = context.text:match("game:GetService%s*%(%s*[\"']([%w_]+)[\"']%s*%)")
			local root = workspace
			if serviceName then
				local ok, svc = pcall(function() return game:GetService(serviceName) end)
				if ok and svc then root = svc end
			end
			for _, child in ipairs(getInstanceChildren(root)) do
				suggestions[#suggestions + 1] = { label = child.Name, kind = "child", detail = child.ClassName, insertText = '"' .. child.Name .. '"' }
			end
			return suggestions
		end
		return suggestions
	end

	local function addMembers(className, instance, sep)
		local methods, properties, events = getAllMembers(className)
		if sep == "." then
			if instance then
				for _, child in ipairs(getInstanceChildren(instance)) do
					suggestions[#suggestions + 1] = { label = child.Name, kind = "child", detail = child.ClassName .. " (子项)", insertText = child.Name }
				end
			end
			for name, p in pairs(properties) do
				local pType = getTypeName(p.Type) or "unknown"
				local detail = classCache[pType] and (pType .. " (实例)") or pType
				suggestions[#suggestions + 1] = { label = name, kind = "property", detail = detail, insertText = name }
			end
			for name, e in pairs(events) do
				suggestions[#suggestions + 1] = { label = name, kind = "event", detail = getTypeName(e.EventType) or "unknown", insertText = name }
			end
		end
		for name, m in pairs(methods) do
			local detail = m.ReturnType and ("-> " .. getTypeName(m.ReturnType)) or ""
			suggestions[#suggestions + 1] = { label = name, kind = "method", detail = detail, insertText = name .. "()" }
		end
	end

	-- 多级字段路径 a.b.c.
	local path = before:match("([%a_][%w_%.]*)%s*[%.:]%s*[%a_%w_]*$")
	if path and path:find("%.") then
		local parts = {}
		for p in path:gmatch("[%a_][%w_]*") do parts[#parts + 1] = p end
		local current = vars[parts[1]]
		for i = 2, #parts do
			if current and current.fields and current.fields[parts[i]] then
				current = current.fields[parts[i]]
			else
				current = nil
				break
			end
		end
		if current and current.fields then
			for name, f in pairs(current.fields) do
				suggestions[#suggestions + 1] = { label = name, kind = "field", detail = f.className or f.type or "unknown", insertText = name }
			end
			return suggestions
		end
	end

	local varPrefix, sep = before:match("([%a_][%w_]*)%s*([%.:])%s*[%a_%w_]*$")
	if varPrefix then
		local className, instance, fields, baseType = nil, nil, nil, nil
		if vars[varPrefix] then
			local v = vars[varPrefix]
			className = v.className
			instance = v.instance
			fields = v.fields
			baseType = v.type
		else
			local inst = getGlobalInstance(varPrefix)
			if inst then
				className = inst.ClassName
				instance = inst
			end
		end

		if className then
			addMembers(className, instance, sep)
			return suggestions
		end

		if fields then
			for name, f in pairs(fields) do
				suggestions[#suggestions + 1] = { label = name, kind = "field", detail = f.className or f.type or "unknown", insertText = name }
			end
			return suggestions
		end

		if TABLE_MEMBERS[varPrefix] then
			for _, name in ipairs(TABLE_MEMBERS[varPrefix]) do
				suggestions[#suggestions + 1] = { label = name, kind = "function", detail = name, insertText = name .. "()" }
			end
			return suggestions
		end

		if baseType then
			return suggestions
		end
	end

	-- 基础分支：变量（跳过已在 functions 里的名字，避免重复）
	for name, t in pairs(vars) do
		if not functions[name] then
			suggestions[#suggestions + 1] = { label = name, kind = "variable", detail = t.className or t.type or "unknown", insertText = nil }
		end
	end
	for name, f in pairs(functions) do
		suggestions[#suggestions + 1] = { label = name, kind = "function", detail = "function(" .. (f.params or "") .. ")", insertText = name .. "()" }
	end
	for _, name in ipairs(GLOBAL_FUNCTIONS) do
		suggestions[#suggestions + 1] = { label = name, kind = "globalFunction", detail = "全局函数", insertText = name .. "()" }
	end
	for _, name in ipairs(KEYWORDS) do
		suggestions[#suggestions + 1] = { label = name, kind = "keyword", detail = "关键字", insertText = name }
	end
	for _, name in ipairs(GLOBAL_NAMES) do
		if not vars[name] then
			local inst = getGlobalInstance(name)
			local gcls = not inst and getGlobalClass(name)
			if inst then
				suggestions[#suggestions + 1] = { label = name, kind = "global", detail = inst.ClassName, insertText = nil }
			elseif gcls then
				suggestions[#suggestions + 1] = { label = name, kind = "global", detail = gcls, insertText = nil }
			end
		end
	end
	return suggestions
end

local function isSubsequence(needle, haystack)
	local i, j = 1, 1
	while i <= #needle and j <= #haystack do
		if needle:sub(i, i):lower() == haystack:sub(j, j):lower() then i = i + 1 end
		j = j + 1
	end
	return i > #needle
end

local function filterSuggestions(suggestions, prefix)
	if prefix == "" then return suggestions end
	local lowerPrefix = prefix:lower()
	local exact, fuzzy = {}, {}
	for _, item in ipairs(suggestions) do
		if not item._lower then item._lower = item.label:lower() end
		if item._lower:sub(1, #lowerPrefix) == lowerPrefix then
			exact[#exact + 1] = item
		elseif isSubsequence(lowerPrefix, item._lower) then
			fuzzy[#fuzzy + 1] = item
		end
	end
	for _, item in ipairs(fuzzy) do exact[#exact + 1] = item end
	return exact
end

function Completion:buildContext(textBox)
	local text = textBox.Text
	local cursor = textBox.CursorPosition
	local beforeCursor = text:sub(1, cursor - 1)
	local lineStart = (beforeCursor:match(".*()\n") or 0) + 1
	local lineText = text:sub(lineStart, cursor - 1)
	local inString, inComment = isInsideStringOrComment(lineText, #lineText + 1)
	if isInLongString(beforeCursor) then inString = true end

	local wordStart = getWordStart(lineText, #lineText)
	return {
		text = text, cursorPos = cursor, lineText = lineText,
		beforeCursor = beforeCursor, inString = inString, inComment = inComment,
		wordPrefix = lineText:sub(wordStart), wordStart = wordStart, lineStart = lineStart,
	}
end

-- ============================================================
-- UI
-- ============================================================
local function getOrCreateGui()
	local screenGui = gethui():FindFirstChild("CompletionGui")
	if not screenGui then
		screenGui = Instance.new("ScreenGui")
		screenGui.Name = "CompletionGui"
		screenGui.ResetOnSpawn = false
		screenGui.DisplayOrder = 9999
		screenGui.IgnoreGuiInset = true
		screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		screenGui.Parent = gethui()
	end
	return screenGui
end

local function createSuggestionFrame(parent)
	local frame = Instance.new("Frame")
	frame.Name = "CompletionPopup"
	frame.Visible = false
	frame.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
	frame.BorderSizePixel = 1
	frame.BorderColor3 = Color3.fromRGB(80, 80, 80)
	frame.ZIndex = 10000
	frame.Size = UDim2.new(0, 280, 0, 200)
	frame.ClipsDescendants = true
	frame.Parent = parent

	local list = Instance.new("ScrollingFrame")
	list.Name = "List"
	list.Size = UDim2.new(1, 0, 1, 0)
	list.BackgroundTransparency = 1
	list.BorderSizePixel = 0
	list.ScrollBarThickness = 4
	list.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
	list.CanvasSize = UDim2.new(0, 0, 0, 0)
	list.ZIndex = 10001
	list.Parent = frame

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 2)
	layout.Parent = list

	return frame, list
end

local function createItemFrame(parent)
	local item = Instance.new("TextButton")
	item.Name = "Item"
	item.Size = UDim2.new(1, -4, 0, 22)
	item.BackgroundColor3 = Color3.fromRGB(60, 90, 160)
	item.BackgroundTransparency = 1
	item.BorderSizePixel = 0
	item.Text = ""
	item.AutoButtonColor = false
	item.ZIndex = 10002
	item.Parent = parent

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Size = UDim2.new(0, 120, 1, 0)
	label.Position = UDim2.new(0, 4, 0, 0)
	label.BackgroundTransparency = 1
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextColor3 = Color3.fromRGB(220, 220, 220)
	label.TextSize = 14
	label.Font = Enum.Font.Code
	label.ZIndex = 10002
	label.TextTruncate = Enum.TextTruncate.AtEnd
	label.Parent = item

	local detail = Instance.new("TextLabel")
	detail.Name = "Detail"
	detail.Size = UDim2.new(1, -128, 1, 0)
	detail.Position = UDim2.new(0, 124, 0, 0)
	detail.BackgroundTransparency = 1
	detail.TextXAlignment = Enum.TextXAlignment.Left
	detail.TextColor3 = Color3.fromRGB(140, 140, 140)
	detail.TextSize = 12
	detail.Font = Enum.Font.Code
	detail.ZIndex = 10002
	detail.TextTruncate = Enum.TextTruncate.AtEnd
	detail.Parent = item

	return item, label, detail
end

local function getCursorScreenPos(textBox)
	local text = textBox.Text
	local cursor = textBox.CursorPosition
	local before = text:sub(1, cursor - 1)
	local lineIndex = select(2, before:gsub("\n", ""))
	local lineStart = (before:match(".*()\n") or 0) + 1
	local lineText = before:sub(lineStart)

	local lineHeight = TextService:GetTextSize("X", textBox.TextSize, textBox.Font, Vector2.new(math.huge, math.huge)).Y
	local textWidth = TextService:GetTextSize(lineText, textBox.TextSize, textBox.Font, Vector2.new(math.huge, math.huge)).X

	local absPos = textBox.AbsolutePosition
	local inset = GuiService:GetGuiInset()
	local x = absPos.X + textWidth + inset.X + 20
	local y = absPos.Y + 4 + lineIndex * lineHeight + inset.Y
	return Vector2.new(x, y), lineHeight
end

-- ============================================================
-- 绑定
-- ============================================================
local function bind(textBox, options)
	options = options or {}
	local self = setmetatable({ providers = options.providers or {} }, Completion)

	local screenGui = getOrCreateGui()
	local frame, list = createSuggestionFrame(screenGui)

	local currentItems, selectedIndex, visible = {}, 0, false
	local itemFrames = {}
	local activeWordStart, activeWordEnd = 0, 0
	local lastCursor = textBox.CursorPosition or 1
	local completionOpen = false
	local connections = {}

	local function clearItems()
		for _, f in ipairs(itemFrames) do
			if f and f.Parent then
				f:Destroy()
			end
		end
		itemFrames = {}
	end

	local function hide()
		if frame and frame.Parent then
			frame.Visible = false
		end
		visible = false
		completionOpen = false
		activeWordStart, activeWordEnd = 0, 0
		clearItems()
	end

	local function refreshSelection()
		for j, ff in ipairs(itemFrames) do
			ff.BackgroundTransparency = (j == selectedIndex) and 0 or 1
		end
	end

	local function renderItems(items, wordStart, wordEnd)
		if not frame or not frame.Parent then return end
		clearItems()
		currentItems = items
		if #items == 0 then hide() return end
		visible = true
		completionOpen = true
		activeWordStart, activeWordEnd = wordStart, wordEnd

		local cursorPos, lineHeight = getCursorScreenPos(textBox)
		local popupHeight = math.min(#items * 24 + 4, 200)
		local viewportY = workspace.CurrentCamera.ViewportSize.Y

		if cursorPos.Y + popupHeight > viewportY then
			frame.AnchorPoint = Vector2.new(0, 1)
			frame.Position = UDim2.fromOffset(cursorPos.X, cursorPos.Y - 2)
		else
			frame.AnchorPoint = Vector2.new(0, 0)
			frame.Position = UDim2.fromOffset(cursorPos.X, cursorPos.Y + lineHeight)
		end

		frame.Visible = true
		frame.Size = UDim2.fromOffset(280, popupHeight)

		for i, item in ipairs(items) do
			local f, label, detail = createItemFrame(list)
			label.Text = item.label
			detail.Text = item.detail or ""
			f.LayoutOrder = i
			f.MouseEnter:Connect(function()
				selectedIndex = i
				refreshSelection()
			end)
			f.MouseButton1Click:Connect(function()
				self:acceptSuggestion(textBox, item)
				hide()
			end)
			itemFrames[#itemFrames + 1] = f
		end
		list.CanvasSize = UDim2.fromOffset(0, #items * 24)
		selectedIndex = 1
		refreshSelection()
	end

	local analyzer = IncrementalAnalyzer.new()

	local function triggerCompletion()
		if not textBox:IsFocused() then return end
		if not frame or not frame.Parent then return end
		local text = textBox.Text
		local cursor = textBox.CursorPosition
		local beforeCursor = text:sub(1, cursor - 1)

		local cursorLine = 1
		for _ in beforeCursor:gmatch("\n") do cursorLine = cursorLine + 1 end

		analyzer:update(text, cursorLine)
		local vars, functions = analyzer:getVisible(cursorLine)

		local ctx = self:buildContext(textBox)
		local suggestions = buildSuggestions(ctx, vars, functions)
		suggestions = filterSuggestions(suggestions, ctx.wordPrefix)
		if #suggestions == 0 then
			if completionOpen then hide() end
			return
		end

		local lineStart = (beforeCursor:match(".*()\n") or 0) + 1
		local lineText = text:sub(lineStart, cursor - 1)
		local wordStartInLine = getWordStart(lineText, #lineText)
		local wordStart = lineStart + wordStartInLine - 1
		local wordEnd = getWordEnd(text, cursor)
		renderItems(suggestions, wordStart, wordEnd)
	end

	connections[#connections + 1] = textBox:GetPropertyChangedSignal("Text"):Connect(function()
		if not frame or not frame.Parent then return end
		local cursor = textBox.CursorPosition
		local prevChar = ""
		if cursor > 1 then prevChar = textBox.Text:sub(cursor - 1, cursor - 1) end

		local isForward = cursor > lastCursor
		local isTriggerChar = isIdentChar(prevChar) or prevChar == "." or prevChar == ":"

		local ctx = self:buildContext(textBox)
		local allowTrigger = not ctx.inComment
		if ctx.inString then
			allowTrigger = ctx.beforeCursor:match('game:GetService%s*%(%s*["\']?[%w_]*$')
				or ctx.beforeCursor:match('Instance%.new%s*%(%s*["\']?[%w_]*$')
				or ctx.beforeCursor:match(":%s*(FindFirstChild[%w_]*)%s*%(%s*[\"']?[%w_]*$")
				or false
		end

		if not completionOpen then
			if isForward and isTriggerChar and allowTrigger then triggerCompletion() end
		else
			if cursor >= activeWordStart and cursor <= activeWordEnd and isTriggerChar and allowTrigger then
				triggerCompletion()
			else
				hide()
			end
		end
		lastCursor = cursor
	end)

	connections[#connections + 1] = textBox:GetPropertyChangedSignal("CursorPosition"):Connect(function()
		if not frame or not frame.Parent then return end
		local cursor = textBox.CursorPosition
		if completionOpen and (cursor < activeWordStart or cursor > activeWordEnd) then hide() end
	end)

	connections[#connections + 1] = textBox.FocusLost:Connect(function()
		task.wait(0.1)
		if not frame or not frame.Parent then return end
		if not textBox:IsFocused() then hide() end
	end)

	connections[#connections + 1] = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not frame or not frame.Parent then return end
		if gameProcessed or not textBox:IsFocused() or not visible then return end
		if input.KeyCode == Enum.KeyCode.Tab then
			if selectedIndex > 0 and currentItems[selectedIndex] then
				self:acceptSuggestion(textBox, currentItems[selectedIndex])
				hide()
				textBox:CaptureFocus()
			end
		elseif input.KeyCode == Enum.KeyCode.Escape then
			hide()
		elseif input.KeyCode == Enum.KeyCode.Up then
			selectedIndex = math.max(1, selectedIndex - 1)
			refreshSelection()
		elseif input.KeyCode == Enum.KeyCode.Down then
			selectedIndex = math.min(#itemFrames, selectedIndex + 1)
			refreshSelection()
		end
	end)

	self.frame = frame
	self.list = list
	self.renderItems = renderItems
	self.triggerCompletion = triggerCompletion
	self.hide = hide
	self.connections = connections
	self.analyzer = analyzer
	return self
end

function Completion:unbind()
	if self.connections then
		for _, conn in ipairs(self.connections) do
			if conn and conn.Connected then
				conn:Disconnect()
			end
		end
		self.connections = {}
	end
	if self.hide then
		self.hide()
	end
	if self.frame and self.frame.Parent then
		self.frame:Destroy()
	end
	self.frame = nil
	self.list = nil
	self.renderItems = nil
	self.triggerCompletion = nil
	self.hide = nil
	self.analyzer = nil
end

function Completion:acceptSuggestion(textBox, item)
	local text = textBox.Text
	local cursor = textBox.CursorPosition
	local beforeCursor = text:sub(1, cursor - 1)
	local lineStart = (beforeCursor:match(".*()\n") or 0) + 1
	local lineText = text:sub(lineStart, cursor - 1)
	local wordStart = getWordStart(lineText, #lineText)
	local absWordStart = lineStart + wordStart - 1
	local insertText = item.insertText or item.label
	textBox.Text = text:sub(1, absWordStart - 1) .. insertText .. text:sub(cursor)
	textBox.CursorPosition = absWordStart + #insertText
end

initClassCache()

Completion.bind = bind
return Completion
