--- @since 25.5.31

local hovered = ya.sync(function()
	local h = cx.active.current.hovered
	if not h then
		return {}
	end

	return {
		url = h.url,
		is_dir = h.cha.is_dir,
		unique = #cx.active.current.files == 1,
	}
end)

local function prompt()
	return ya.input {
		title = "EveryThing Search:",
		pos = { "center", w = 50 },
		position = { "center", w = 50 }, -- TODO: remove
		realtime = true,
		debounce = 0.1,
	}
end

local function entry()
	local input = prompt()
	local current_dir = cx.active.current.cwd.path
	
	local query, event = input:recv()
    -- Check if the user cancelled or provided an empty query.
    if not query or query:len() == 0 then
        ya.notify({
            title = "Search Cancelled",
            content = "DIR: " .. current_dir,
            level = "info",
            timeout = 5,
        })
        return -- Exit the plugin
    end
	
	

	-- while true do
	-- 	local value, event = input:recv()
	-- 	if event ~= 1 and event ~= 3 then
	-- 		ya.emit("escape", { filter = true })
	-- 		break
	-- 	end

	-- 	ya.emit("filter_do", { value, smart = true })

	-- 	local h = hovered()
	-- 	if h.unique and h.is_dir then
	-- 		ya.emit("escape", { filter = true })
	-- 		ya.emit("enter", {})
	-- 		input = prompt()
	-- 	elseif event == 1 then
	-- 		ya.emit("escape", { filter = true })
	-- 		ya.emit(h.is_dir and "enter" or "open", { h.url })
	-- 		break
	-- 	end
	-- end
end

return { entry = entry }