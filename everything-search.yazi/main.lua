--! This is the main.lua file for the 'everything-search-smart.yazi' plugin.
--! It combines interactive input with 'Everything' (es.exe) and 'fzf'
--! to search for files/folders in the current directory and navigate to the selection.
--!
--! NOTE: This plugin is specifically for Windows and requires:
--!   - 'Everything' (Voidtools) installed and 'es.exe' in PATH.
--!   - 'fzf' installed and in PATH.

--- @sync entry

-- Function to display an input prompt to the user.
-- This is adapted from the 'smart filter' plugin's prompt mechanism.
local function prompt()
    return ya.input {
        title = "Everything Search:", -- Title for the input prompt
        prompt = "Enter search query:",
        pos = { "center", w = 50 },
        -- realtime = true, -- Removed: fzf handles realtime filtering, not Yazi's internal filter
        -- debounce = 0.1,  -- Removed: Not needed since realtime is handled by fzf
    }
end

-- The main entry point for the plugin.
local function entry()
    -- Get the input prompt object.
    local input = prompt()

    -- Wait for the user to provide input (or cancel).
    -- input:recv() returns the value and the event type.
    -- event == 1 typically means Enter was pressed (submit).
    -- If the user presses Esc or closes the prompt, value will be nil or empty.
    local query, event = input:recv()

    -- Check if the user cancelled or provided an empty query.
    if not query or query:len() == 0 then
        ya.notify({
            title = "Search Cancelled",
            content = "No search query provided. Operation aborted.",
            level = "info",
            timeout = 2,
        })
        return -- Exit the plugin
    end

    -- Get the current working directory from Yazi's context.
    -- This is crucial for 'es.exe' to limit its search to the current directory.
    local current_dir = cx.active.current.cwd.path

    -- Construct the command to execute.
    -- We use 'cmd.exe /C' to ensure the pipe (`|`) works correctly on Windows.
    -- 'es.exe' searches for the query within the current directory.
    -- 'fzf' provides interactive fuzzy filtering of the results.
    local search_command = string.format(
        'cmd.exe /C es.exe "%s" -path "%s" | fzf --ansi --exact --no-sort --reverse',
        query,
        current_dir
    )

    -- Execute the command.
    -- 'capture = true' to get the output from fzf (the selected line).
    -- 'block = true' to keep Yazi's UI waiting while fzf is interactive.
    -- 'stream = true' is generally good practice for external commands.
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

    -- Process the selected path from fzf's output.
    -- fzf typically outputs the selected line followed by a newline.
    local selected_path = result:match("^(.*)\n?$")

    -- If a path was selected (fzf returned a non-empty string).
    if selected_path and selected_path:len() > 0 then
        -- Use ya.reveal() to navigate Yazi to the selected file or folder.
        ya.reveal(selected_path)
        ya.notify({
            title = "Search Result",
            content = "Navigated to: " .. selected_path,
            level = "success",
            timeout = 3,
        })
    else
        -- If no item was selected in fzf (e.g., user pressed Esc in fzf, or no results).
        ya.notify({
            title = "Search Result",
            content = "No item selected or no results found for your query.",
            level = "info",
            timeout = 2,
        })
    end
end

-- Return the plugin's exposed functions.
return {
    entry = entry,
}
