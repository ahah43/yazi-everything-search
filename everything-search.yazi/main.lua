--- @since 25.5.31
-- Synchronously get the current working directory of the active pane.
local root = ya.sync(function()
    return cx.active.current.cwd
end)

-- Synchronously get information about the currently hovered item.
local hovered = ya.sync(function()
    local h = cx.active.current.hovered
    if not h then
        return {} -- Return an empty table if nothing is hovered
    end

    return {
        url = h.url,
        is_dir = h.cha.is_dir,
        -- 'unique' indicates if there's only one file in the current directory,
        -- which might be useful for certain context-aware actions.
        unique = #cx.active.current.files == 1
    }
end)

-- Function to prompt the user for search input.
local function prompt()
    return ya.input {
        title = "EveryThing Search:",
        -- Position the input box in the center with a width of 50 characters.
        pos = { "center", w = 50 },
        -- realtime = false, -- Uncomment for non-realtime input
        -- debounce = 0.1   -- Uncomment to add a debounce to input
    }
end

-- Main entry point for the plugin.
local function entry()
    -- Prompt the user for a search query.
    local query, event = prompt()

    -- Check if the user cancelled or provided an empty query.
    -- Reverted to your original cancellation check, as you indicated it worked better.
    if not query or query:len() == 0 then
        ya.notify({
            title = "Search Cancelled",
            content = "No search query provided or input cancelled.",
            level = "info",
            timeout = 3 -- Display for 3 seconds
        })
        return -- Exit the plugin if no query or cancelled
    end

    -- Get the current working directory as the parent directory for the search scope.
    local parentDir = root()

    -- Define fzf options for a better interactive experience.
    -- --ansi: Interpret ANSI color codes (useful if es.exe outputs colors).
    -- --no-sort: Display results in the order es.exe provides them.
    -- --reverse: Start fzf in reverse video mode (bottom-up).
    local fzf_options = "--ansi --no-sort --reverse"

    -- Construct the full command string for the shell.
    -- This correctly builds the `es.exe ... | fzf.exe ...` pipeline.
    -- Using -path with es.exe scopes the search to the parentDir.
    local full_command = string.format('es.exe -path "%s" "%s" | fzf.exe %s', parentDir, query, fzf_options)

    -- Notify the user that the search has started.
    ya.notify({
        title = "Everything Search",
        content = "Searching for '" .. query .. "' in '" .. parentDir .. "'...",
        level = "info",
        timeout = 3
    })

    -- DEBUG: Log the full command being executed. This will appear in Yazi's log file.
    ya.log("Everything Search Plugin: Full command: " .. full_command)

    -- Execute the entire pipeline using Yazi's Command builder.
    -- This is the most reliable way to handle external commands and pipes.
    local output, err = Command("cmd"):arg({ "/c", full_command }):output():spawn()

    -- Handle any errors during command execution.
    if err then
        -- DEBUG: Log the error details.
        ya.log("Everything Search Plugin: Command execution error: " .. tostring(err))
        ya.notify({
            title = "Plugin Error",
            content = "Failed to execute search command. Please ensure 'es.exe' and 'fzf.exe' are in your system's PATH. Check Yazi logs for details. Error: " .. tostring(err),
            level = "error",
            timeout = 8 -- Increased timeout for critical error message
        })
        return
    end

    -- DEBUG: Log the stdout and stderr from the command.
    ya.log("Everything Search Plugin: Command stdout: " .. (output.stdout or "nil"))
    ya.log("Everything Search Plugin: Command stderr: " .. (output.stderr or "nil"))

    -- Check if stderr has content, which often indicates an error from es.exe or fzf.exe
    if output.stderr and output.stderr:len() > 0 then
        ya.log("Everything Search Plugin: Detected stderr output: " .. output.stderr)
        ya.notify({
            title = "Search Command Warning/Error",
            content = "Command produced error output. Check Yazi logs. Stderr: " .. output.stderr:sub(1, 100) .. (output.stderr:len() > 100 and "..." or ""), -- Truncate for notification
            level = "warn",
            timeout = 8
        })
    end

    -- Clean the result from fzf (which typically has a trailing newline).
    local selected = output.stdout:gsub("[\r\n]", "")

    -- If fzf returns an empty string, it means the user didn't select anything.
    if selected:len() == 0 then
        ya.notify({
            title = "Everything Search",
            content = "No item selected from search results or no results found.",
            level = "info",
            timeout = 3
        })
        return
    end

    -- Notify the user about the selected item.
    ya.notify({
        title = "Everything Search",
        content = "Selected: " .. selected,
        level = "success",
        timeout = 3
    })

    -- Attempt to open or navigate to the selected item in Yazi.
    -- ya.open will try to open the file/directory.
    -- If it's a directory, Yazi will navigate into it.
    -- If it's a file, Yazi will open it with the default application.
    ya.open(selected)
end

-- Return the entry function as the plugin's main callable.
return {
    entry = entry
}
