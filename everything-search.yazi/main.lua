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
        realtime = true,
        debounce = 0.1
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

    --  | fzf --ansi --exact --no-sort --reverse
    -- local es_command_string = string.format('es.exe "%s" -path "%s"', query, parentDir)

    -- local output, err = Command("es"):cwd(tostring(parentDir)):arg({query, "-path", parentDir}):output()
    local output, err = Command("es"):arg({query}):output()


end

return {
    entry = entry
}
