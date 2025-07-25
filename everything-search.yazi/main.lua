local function entry(_, job)
    ya.notify({
        title = "Yazi Test Plugin",
        content = "Hello from the simplest Yazi plugin!",
        level = "info", -- "info", "success", "warn", "error"
        timeout = 3,    -- Notification display duration in seconds
    })
end
return {
    entry = entry,
}
-- -- 
-- 
 
-- local function entry()
--     local query = ya.input({
--         title = "Search Current Directory (Everything)", -- Updated title
--         prompt = "Enter search query:",                  -- Text displayed to the user
--         -- You can add a `default = "initial_text"` here if you want a pre-filled value.
--     })
--     if not query or query:len() == 0 then
--         ya.notify({
--             title = "Search Cancelled",
--             content = "No search query provided. Operation aborted.",
--             level = "info", -- "info", "success", "warn", "error"
--             timeout = 2,    -- Notification display duration in seconds
--         })
--         return -- Exit the plugin function
--     end
--     local current_dir = cx.active.current.cwd.path

--     local search_command = string.format(
--         'cmd.exe /C es.exe "%s" -path "%s" | fzf --ansi --exact --no-sort --reverse',
--         query,
--         current_dir
--     )

--     local ok, result = ya.exec(search_command, { capture = true, block = true, stream = true })
--     if not ok then
--         ya.notify({
--             title = "Search Error",
--             content = "Failed to run search command. Ensure 'Everything' (es.exe) and 'fzf' are installed and in your system's PATH. Error: " .. (result or "Unknown"),
--             level = "error",
--             timeout = 5,
--         })
--         return
--     end
--     local selected_path = result:match("^(.*)\n?$")
--     if selected_path and selected_path:len() > 0 then
--         ya.reveal(selected_path)
--         ya.notify({
--             title = "Search Result",
--             content = "Navigated to: " .. selected_path,
--             level = "success",
--             timeout = 3,
--         })
--     else
--         ya.notify({
--             title = "Search Result",
--             content = "No item selected or no results found for your query.",
--             level = "info",
--             timeout = 2,
--         })
--     end
-- end
-- return {
--     entry = entry,
-- }

 
