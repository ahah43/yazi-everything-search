--- @since 25.5.31
local root = ya.sync(function()
    return cx.active.current.cwd
end)

local hovered = ya.sync(function()
    local h = cx.active.current.hovered
    if not h then
        return {}
    end

    return {
        url = h.url,
        is_dir = h.cha.is_dir,
        unique = #cx.active.current.files == 1
    }
end)

local function prompt()
    return ya.input {
        title = "EveryThing Search:",
        pos = {
            "center",
            w = 50
        },
        position = {
            "center",
            w = 50
        }, -- TODO: remove
        -- realtime = false,
        -- debounce = 0.1
    }
end

local function entry()
    -- local input = prompt()

    local query, event = prompt()
    -- Check if the user cancelled or provided an empty query.
    if not query or query:len() == 0 then
        ya.notify({
            title = "Search Cancelled",
            content = "What to search for?",
            level = "info",
            timeout = 5
        })
        return -- Exit the plugin
    end

    local h = hovered()
    -- local parentDir = h.url.base

    local parentDir = root()

    local es_search_command = string.format('es "%s" -path "%s"',
        query, parentDir)

    ya.notify({
        title = "Search Cancelled",
        content = "search_command = " .. es_search_command,
        level = "info",
        timeout = 5
    })

    -- 3. Construct the full command string for the shell.
	-- This correctly builds the `es ... | fzf ...` pipeline.
	-- Using -path with es.exe scopes the search.
	local fzf_options = "--ansi --no-sort --reverse"
	-- local full_command = string.format('es.exe -path "%s" "%s" | fzf.exe %s', current_dir, query, fzf_options)
	local full_command = string.format('es.exe -path "%s" "%s"', current_dir, query)

	-- Optional: A notification to debug the exact command being run.
	-- ya.notify({ title = "Debug", content = full_command, level = "info" })

	-- 4. Execute the entire pipeline using the Command builder and the shell.
	-- This is the most reliable way to handle pipes.
	local output, err = Command("cmd"):arg({ "/c", full_command }):output()
	

	-- 5. Handle the result.
	if err then
		ya.notify({ title = "Plugin Error", content = tostring(err), level = "error" })
		return
	end

	-- Clean the result from fzf (which has a trailing newline).
	local selected = output.stdout:gsub("[\r\n]", "")


end

return {
    entry = entry
}
