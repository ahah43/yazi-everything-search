-- yazi plugin to search with Everything within the current directory and select with fzf.

-- A helper function to get the current working directory from yazi's UI.
-- This is the correct and modern way to do this.
local function get_cwd()
	return ya.sync(function() return cx.active.current.cwd end)
end

-- The main entry function for the plugin.
local function entry()
	-- 1. Get the search query from the user.
	-- We don't need `realtime` here, as we only act after the user presses Enter.
	local query = ya.input {
		title = "Search in current folder:",
		pos = { "center", w = 50 },
	}

	-- Exit if the user cancelled.
	if not query or query == "" then
		return
	end

	-- 2. Get the current directory from yazi.
	local current_dir = tostring(get_cwd())

	-- 3. Construct the full command string for the shell.
	-- This correctly builds the `es ... | fzf ...` pipeline.
	-- Using -path with es.exe scopes the search.
	local fzf_options = "--ansi --exact --no-sort --reverse"
	local full_command = string.format('es.exe -path "%s" "%s" | fzf.exe %s', current_dir, query, fzf_options)

	-- Optional: A notification to debug the exact command being run.
	-- ya.notify({ title = "Debug", content = full_command, level = "info" })

	-- 4. Execute the entire pipeline using the Command builder and the shell.
	-- This is the most reliable way to handle pipes.
	local output, err = Command("cmd"):args({ "/c", full_command }):output()

	-- 5. Handle the result.
	if err then
		ya.notify({ title = "Plugin Error", content = tostring(err), level = "error" })
		return
	end

	-- Clean the result from fzf (which has a trailing newline).
	local selected = output.stdout:gsub("[\r\n]", "")

	-- If a file was selected, emit an "open" event to have yazi open it.
	if selected ~= "" then
		ya.emit("open", { selected })
	end
end

return {
	entry = entry,
}