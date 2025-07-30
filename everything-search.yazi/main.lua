local function fail(s, ...)
	ya.notify { title = "my_plugin_name", content = string.format(s, ...), timeout = 5, level = "error" }
end

local function entry(_)
	local _permit = ya.hide()
	local cmd_args = "es | fzf"

	local child, err = Command("cmd")
		:arg({ "/c", cmd_args })
		:stdin(Command.INHERIT)
		:stdout(Command.PIPED)
		:stderr(Command.PIPED)
		:spawn()

	if not child then
		return fail("Spawn command failed with error code %s.", err)
	end

	local output, err = child:wait_with_output()
	if not output then
		return fail("Cannot read command output, error code %s", err)
	elseif not output.status.success and output.status.code ~= 130 then
		return fail("Spawn command exited with error code %s", output.status.code)
	end

	local target = output.stdout:gsub("\n$", "")

	if target ~= "" then
		local is_dir = target:sub(-1) == "/"
		ya.manager_emit(is_dir and "cd" or "reveal", { target })
	end
end

return { entry = entry }