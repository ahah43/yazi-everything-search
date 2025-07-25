-- %AppData%\yazi\config\plugins\everything-search.yazi\main.lua
local M = {}

function M.search()
    local query = ya.input('Search with Everything: ')
    if query then
        ya.notify("You entered: " .. query, "info", 3000)
    else
        ya.notify("Input cancelled.", "info", 1500)
    end
end

return M
