--! This is the main.lua file for the simplest Yazi plugin.
--! It demonstrates how to create a basic functional plugin that displays a notification.

-- Annotation: @sync entry
-- This annotation tells Yazi that the 'entry' function should be run synchronously
-- when the plugin is called. This is suitable for quick operations like notifications.

--- @sync entry

-- The 'entry' function is the main entry point for functional plugins.
-- It receives two arguments:
-- 1. `_`: This is typically `cx` (context), but we don't need it for this simple example,
--    so we use `_` to indicate it's unused.
-- 2. `job`: This contains information about the job that triggered the plugin,
--    including any arguments passed to the plugin. We don't need it here either.
local function entry(_, job)
    -- Display a notification using Yazi's built-in notification system.
    -- cx.notify() is a Yazi API function available in the plugin context.
    -- The first argument is the title of the notification.
    -- The second argument is the message body.
    -- The third argument (optional) is the kind of notification (e.g., "info", "success", "warn", "error").
    -- We'll use "info" for a general message.
    cx.notify("Yazi Test Plugin", "Hello from the simplest Yazi plugin!", "info")
end

-- Return a table containing the functions that Yazi should expose.
-- In this case, we're exposing the 'entry' function.
return {
    entry = entry,
}
