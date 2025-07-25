-- Definitive yazi v0.2+ plugin for Everything Search
-- This version uses a single shell process to correctly handle the es | fzf pipeline.

return {
    -- The setup function is the main entry point called by yazi when the plugin is loaded.
    setup = function(self)
        -- Define default configuration for the plugin.
        self.config = {
            es_path = "es.exe",
            fzf_path = "fzf.exe",
        }

        -- Define the keymap that this plugin provides.
        self.keymaps = {
            {
                name = "search",
                desc = "Search with Everything and fzf",
                run = function() self:search() end,
            },
        }
    end,

    -- Main logic function for the plugin.
    search = function(self)
        local query = ya.input({ prompt = "Search with Everything: " })
        if not query or query == "" then
            return
        end

        -- Construct the full command string for the shell.
        -- We put the query in quotes to handle spaces correctly.
        local full_command = string.format('%s "%s" | %s', self.config.es_path, query, self.config.fzf_path)

        -- Use a single process to run the entire pipeline via the shell.
        -- This is the correct way to handle interactive commands like fzf.
        ya.process.run({
            -- On Windows, we use 'cmd /c'. On Linux/macOS, it would be 'sh -c'.
            cmd = "cmd.exe",
            args = { "/c", full_command },

            -- The callback now runs after the entire pipeline (including fzf) is done.
            on_done = function(success, stdout, stderr)
                -- If stderr has content, it means one of the commands failed.
                if stderr and stderr ~= "" then
                    ya.notify({ title = "Search Error", content = stderr, level = "error" })
                    return
                end

                -- If not successful and no stderr, the user likely cancelled (e.g., pressed Esc in fzf).
                if not success then
                    ya.notify({ title = "Search cancelled", level = "info" })
                    return
                end

                -- Clean up fzf's output and open the selected item.
                local selected = stdout:gsub("[\r\n]", "")
                if selected ~= "" then
                    ya.manager_emit("open", { selected })
                end
            end,
        })
    end,
}
