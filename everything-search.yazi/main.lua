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
	
	local query, event = input:recv()
    -- Check if the user cancelled or provided an empty query.
    if not query or query:len() == 0 then
        ya.notify({
			title = "Search Cancelled",
            content = "What to search for?",
            level = "info",
            timeout = 5,
        })
        return -- Exit the plugin
    end

	local h = hovered()
	local parentDir = h.url.base

	local search_command = string.format(
		'cmd.exe /C es.exe "%s" -path "%s" | fzf --ansi --exact --no-sort --reverse',
        query,
        parentDir
    )
	
	-- ya.notify({
	-- 		title = "Search Cancelled",
    --         content = "search_command = " .. search_command,
    --         level = "info",
    --         timeout = 5,
    --     })

    
	local ok, result = ya.exec(search_command, { capture = true, block = true, stream = true })
    -- Handle the result of the command execution.
    if not ok then
        -- If the command itself failed to run (e.g., es.exe or fzf not found).
        ya.notify({
            title = "Search Error",
            content = "Failed to run search command. Ensure 'Everything' (es.exe) and 'fzf' are installed and in your system's PATH. Error: " .. (result or "Unknown"),
            level = "error",
            timeout = 5,
        })
        return
    end

end

return { entry = entry }