-- special.lua
-- Basic commands and handshake functions.

-- Complete the CUI handshake.
function HandleCuiCommand(a_Split, a_Player)
	-- /cui

	local State = GetPlayerState(a_Player)
	State.IsWECUIActivated = true
	State.Selection:NotifySelectionChanged()
	a_Player:SendMessage(cChatColor.LightGray .. "Completed the visualizer handshake.")
	return true
end

-- Gives the player the wand item.
function HandleWandCommand(a_Split, a_Player)
	-- //wand

	local Item = cItem(g_Config.WandItem) -- create the cItem object
	if (a_Player:GetInventory():AddItem(Item)) then -- check if the player got the item
		a_Player:SendMessage(cChatColor.LightGray .. "Gave you the selection wand.")
	else
		a_Player:SendMessage(cChatColor.LightGray .. "Couldn't fit the wand into your inventory.")
	end
	return true
end

-- Toggles if the wand is active or not.
function HandleToggleEditWandCommand(a_Split, a_Player)
	-- //togglewand

	local State = GetPlayerState(a_Player)
	if not(State.WandActivated) then
		State.WandActivated = true
		a_Player:SendMessage(cChatColor.LightGray .. "Disabled the selection wand for you.")
	else
		State.WandActivated = false
		a_Player:SendMessage(cChatColor.LightGray .. "Enabled the selection wand for you.")
	end
	return true
end
