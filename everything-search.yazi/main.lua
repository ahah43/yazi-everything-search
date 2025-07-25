-- local function entry(_, job)
--     ya.notify({
--         title = "Yazi Test Plugin",
--         content = "Hello from the simplest Yazi plugin!",
--         level = "info", -- "info", "success", "warn", "error"
--         timeout = 3,    -- Notification display duration in seconds
--     })
-- end
-- return {
--     entry = entry,
-- }
-- -- 
-- 
 
--! This is the main.lua file for the 'current-dir-search.yazi' plugin.
--! It allows searching for files and folders by name within the current directory
--! using 'es.exe' (Everything search engine) and 'fzf' (fuzzy finder),
--! and then navigates Yazi to the selected item.
--!
--! NOTE: This version of the plugin is specifically for Windows and requires
--! 'Everything' (Voidtools) to be installed and 'es.exe' to be in your system's PATH.
--! It also requires 'fzf' to be installed and in your system's PATH.

--- @sync entry

-- Define the main entry point for the plugin.
-- This function will be called when the plugin is activated via its keybinding.
local function entry()
    -- Step 1: Prompt the user for a search query.
    -- ya.input() displays an input prompt in Yazi's interface.
    -- It returns the entered text or `nil` if the user cancels the input.
    local query = ya.input({
        title = "Search Current Directory (Everything)", -- Updated title
        prompt = "Enter search query:",                  -- Text displayed to the user
        -- You can add a `default = "initial_text"` here if you want a pre-filled value.
    })

    -- Step 2: Check if the user provided a query.
    -- If the query is `nil` (cancelled) or empty, notify the user and exit.
    if not query or query:len() == 0 then
        ya.notify({
            title = "Search Cancelled",
            content = "No search query provided. Operation aborted.",
            level = "info", -- "info", "success", "warn", "error"
            timeout = 2,    -- Notification display duration in seconds
        })
        return -- Exit the plugin function
    end

    -- Get the current working directory from Yazi's context.
    -- This is crucial for 'es.exe' to limit its search to the current directory.
    local current_dir = cx.active.current.cwd.path

    -- Step 3: Construct the command to execute using 'es.exe' and 'fzf'.
    -- We're building a command that first uses `es.exe` to find files/folders within
    -- the current directory, and then pipes (`|`) the results to `fzf` for interactive selection.
    --
    -- `es.exe`:
    --   - `"%s"`: This is a placeholder for the user's `query`.
    --   - `-path "%s"`: Tells `es.exe` to limit the search to the specified directory.
    --     We pass the `current_dir` here.
    --
    -- `fzf`:
    --   - `--ansi`: Enable ANSI color codes in fzf's output (if `es.exe` uses them).
    --   - `--exact`: Perform an exact match (no fuzzy matching for input by default,
    --     though fzf itself is fuzzy).
    --   - `--no-sort`: Don't sort results, keep `es.exe`'s order.
    --   - `--reverse`: Display results from bottom to top (often preferred for fzf).
    --
    -- `cmd.exe /C`: On Windows, `ya.exec` might not directly support shell pipes (`|`).
    -- Wrapping the command in `cmd.exe /C "..."` ensures it's executed by the command
    -- interpreter, which handles pipes correctly.
    local search_command = string.format(
        'cmd.exe /C es.exe "%s" -path "%s" | fzf --ansi --exact --no-sort --reverse',
        query,
        current_dir
    )

    -- Step 4: Execute the command and capture its output.
    -- `ya.exec()` runs an external command.
    --   - `capture = true`: Tells Yazi to capture the standard output of the command.
    --   - `block = true`: Makes Yazi's UI wait until the command completes. This is
    --     necessary for `fzf` as it's an interactive tool.
    --   - `stream = true`: Allows for streaming output, though for `fzf` we mostly care
    --     about the final selected line.
    local ok, result = ya.exec(search_command, { capture = true, block = true, stream = true })

    -- Step 5: Handle the command execution result.
    if not ok then
        -- If `ya.exec` itself failed (e.g., command not found, permissions), notify the user.
        ya.notify({
            title = "Search Error",
            content = "Failed to run search command. Ensure 'Everything' (es.exe) and 'fzf' are installed and in your system's PATH. Error: " .. (result or "Unknown"),
            level = "error",
            timeout = 5,
        })
        return
    end

    -- Step 6: Process the selected path from `fzf`.
    -- `fzf` outputs the selected line followed by a newline. We remove the newline.
    local selected_path = result:match("^(.*)\n?$")

    -- If a path was selected (i.e., `fzf` returned a non-empty string).
    if selected_path and selected_path:len() > 0 then
        -- `ya.reveal()` navigates Yazi's file list to the specified path.
        -- This is ideal for a search plugin, as it shows the user where the file is.
        ya.reveal(selected_path)
        ya.notify({
            title = "Search Result",
            content = "Navigated to: " .. selected_path,
            level = "success",
            timeout = 3,
        })
    else
        -- If `fzf` returned an empty string (user didn't select anything or no results).
        ya.notify({
            title = "Search Result",
            content = "No item selected or no results found for your query.",
            level = "info",
            timeout = 2,
        })
    end
end

-- Return a table containing the functions that Yazi should expose as part of this plugin.
-- Here, we're exposing only the `entry` function.
return {
    entry = entry,
}

 
