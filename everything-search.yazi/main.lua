-- yazi-everything-search: main.lua
-- This version adopts the structural and event-driven style of modern yazi plugins.

-- Helper function to run the external search process.
-- This encapsulates the core logic, keeping the entry point clean.
local function run_search(cfg)
	-- 1. Create the input prompt to get the user's query.
	local query = ya.input {
		title = "Search with Everything:",
		pos = { "center", w = 50 }, -- Use modern positioning syntax
	}

	-- If the user cancelled (e.g., pressed Esc), do nothing.
	if not query or query == "" then
		return
	end

	-- 2. Construct the full command to be run by the shell.
	-- This lets the shell correctly handle the pipe '|' between the two commands.
	local full_command = string.format('%s "%s" | %s', cfg.es_path, query, cfg.fzf_path)

	-- 3. Run the external process. This will block and take over the UI
	-- until fzf is closed by the user.
	ya.process.run({
		cmd = "cmd.exe",
		args = { "/c", full_command },
		on_done = function(success, stdout, stderr)
			-- Handle potential errors from `es` or `fzf`.
			if stderr and stderr ~= "" then
				ya.notify({ title = "Search Error", content = stderr, level = "error" })
				return
			end

			-- A non-success status usually means the user cancelled fzf.
			if not success then
				return
			end

			-- Clean the output from fzf (which includes a newline).
			local selected = stdout:gsub("[\r\n]", "")

			-- 4. Emit an 'open' event to let yazi handle opening the file or directory.
			-- This is the idiomatic way to perform actions.
			if selected ~= "" then
				ya.emit("open", { selected })
			end
		end,
	})
end

-- This is the main setup function for the plugin, as recommended by yazi docs.
local function setup(self)
	-- Define the plugin's default configuration.
	self.config = {
		es_path = "es.exe",
		fzf_path = "fzf.exe",
	}

	-- Define the keymap this plugin provides.
	self.keymaps = {
		{
			name = "search",
			desc = "Search files with Everything and fzf",
			-- The 'run' function calls our main logic, passing its own config.
			run = function() run_search(self.config) end,
		},
	}
end

-- The plugin's public interface, returned to yazi.
return {
	setup = setup,
}
