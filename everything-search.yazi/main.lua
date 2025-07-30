local function fail(s, ...)
    ya.notify {
        title = "my_plugin_name",
        content = string.format(s, ...),
        timeout = 5,
        level = "error"
    }
end
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
        } -- TODO: remove
        -- realtime = false,debounce = 0.1
    }
end

local function entry(_)
    local _permit = ya.hide() -- important
    -- local cmd_args = "fd -d 1 | fzf"
    -- local cmd_args = "es | fzf"

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
    local es_search_command = string.format('es "%s" -path "%s" | fzf', query, parentDir)

    --  ya.notify({
    --     title = "Search Started v123",
    --     content = "search_command = " .. es_search_command,
    --     level = "info",
    --     timeout = 5
    -- })

    local child, err = Command("pwsh"):arg({"/c", es_search_command}):stdin(Command.INHERIT):stdout(Command.PIPED):stderr(
        Command.PIPED):spawn()

    if not child then
        return fail("Spawn command failed with error code %s.", err)
    end

    local output, err = child:wait_with_output()
    if not output then
        return fail("Cannot read command output, error code %s", err)
    -- elseif not output.status.success and output.status.code ~= 130 then
    --     return fail("Spawn command exited with error code %s", output.status.code)
    end

    local target = output.stdout:gsub("\n$", "")

    if target ~= "" then
        local is_dir = target:sub(-1) == "/"
        ya.manager_emit(is_dir and "cd" or "reveal", {target})
    end
end

return {
    entry = entry
}
