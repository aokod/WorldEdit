
-- scripting.lua
-- Handlers for scripting-related commands.

-- Loads and executes a craftscript.
function HandleCraftScriptCommand(a_Split, a_Player)
	-- /script <script>

	local PlayerState = GetPlayerState(a_Player)

	if (not a_Split[2]) then
		a_Player:SendMessage(cChatColor.LightGray .. "Usage: " .. a_Split[1] .. " <script>")
		return true
	end

	local Succes, Err = PlayerState.CraftScript:SelectScript(a_Split[2])
	if (not Succes) then
		a_Player:SendMessage(cChatColor.LightGray .. Err)
		return true
	end

	local Arguments = a_Split
	table.remove(Arguments, 1); table.remove(Arguments, 1)

	local Succes, Err = PlayerState.CraftScript:Execute(a_Player, Arguments)
	if (not Succes) then
		a_Player:SendMessage(cChatColor.LightGray .. Err)
		return true
	end

	a_Player:SendMessage(cChatColor.LightGray .. "Executed that script.")
	return true
end

-- Executes the last used craftscript.
function HandleLastCraftScriptCommand(a_Split, a_Player)
	-- /ls

	local PlayerState = GetPlayerState(a_Player)

	local Arguments = a_Split
	table.remove(Arguments, 1)

	local Succes, Err = PlayerState.CraftScript:Execute(a_Player, Arguments)
	if (not Succes) then
		a_Player:SendMessage(cChatColor.LightGray .. Err)
		return true
	end

	a_Player:SendMessage(cChatColor.LightGray .. "Executed that script.")
	return true
end
