-- schematic.lua
-- Handlers for schematic-related commands.

function HandleSchematicMainCommand(a_Split, a_Player)
	-- //schem

	a_Player:SendMessage(cChatColor.LightGray .. "Usage: //schem <download [...] | import [...] | load [...] | save [...]>")
	return true
end

function HandleSchematicFormatsCommand(a_Split, a_Player)
	-- //schem formats

	-- We support only one format, MCEdit.
	a_Player:SendMessage(cChatColor.LightGray .. "Formats (1): MCEdit")
	return true
end

function HandleSchematicListCommand(a_Split, a_Player)
	-- //schem list

	-- Retrieve all the objects in the folder.
	local FolderContents = cFile:GetFolderContents("schematics")

	-- Filter out non-files and non-".schematic" files.
	local FileList = {}
	for idx, fnam in ipairs(FolderContents) do
		if (
			cFile:IsFile("schematics/" .. fnam) and
			fnam:match(".*%.schematic")
		) then
			table.insert(FileList, fnam:sub(1, fnam:len() - 10))  -- cut off the ".schematic" part of the name
		end
	end
	table.sort(FileList,
		function(f1, f2)
			return (string.lower(f1) < string.lower(f2))
		end
	)

	a_Player:SendMessage(cChatColor.LightGray .. "Schematics (" .. #FileList .. "): " .. table.concat(FileList, ", "))
	return true
end

function HandleSchematicDownloadCommand(a_Split, a_Player)
	-- //schem download <filename>

	if (#a_Split ~= 3) then
		a_Player:SendMessage(cChatColor.LightGray .. "Usage: //schem download <filename>")
		return true
	end
	local FileName = a_Split[3]

	local Path = "schematics/" .. FileName .. ".schematic"
	if not(cFile:IsFile(Path)) then
		a_Player:SendMessage(cChatColor.LightGray .. "Couldn't find that schematic.")
		return true
	end

	-- Take them to the web server in order to download their schematic.
	a_Player:SendMessage(cChatColor.LightGray .. "To download your schematic, go to: https://files.aedi.app/" .. Path)
	return true
end

function HandleSchematicLoadCommand(a_Split, a_Player)
	-- //schem load <filename>

	-- Check the FileName parameter...
	if (#a_Split ~= 3) then
		a_Player:SendMessage(cChatColor.LightGray .. "Usage: //schem load <filename>")
		return true
	end
	local FileName = a_Split[3]

	-- Check if the file exists.
	local Path = "schematics/" .. FileName .. ".schematic"
	if not(cFile:IsFile(Path)) then
		a_Player:SendMessage(cChatColor.LightGray .. "Couldn't find that schematic (" .. FileName .. ").")
		return true
	end

	-- Load the file onto the clipboard.
	local State = GetPlayerState(a_Player)
	if not(State.Clipboard:LoadFromSchematicFile(Path)) then
		a_Player:SendMessage(cChatColor.LightGray .. "Couldn't find that schematic (" .. FileName .. ").")
		return true
	end
	a_Player:SendMessage(cChatColor.LightGray .. "Loaded that schematic (" .. FileName .. ") onto your clipboard.")
	a_Player:SendMessage(cChatColor.LightGray .. "Size: " .. State.Clipboard:GetSizeDesc() .. ".")
	return true
end

function HandleSchematicSaveCommand(a_Split, a_Player)
	-- //schem save [format] <filename>

	-- Get the parameters from the command arguments:
	local FileName
	if (#a_Split == 4) then
		FileName = a_Split[4]
	elseif (#a_Split == 3) then
		FileName = a_Split[3]
	else
		a_Player:SendMessage(cChatColor.LightGray .. "Usage: //schem save [format] <filename>")
		return true
	end

	-- Check if there already is a schematic with that name, and if so if we are allowed to override it.
	if (not g_Config.Schematics.OverrideExistingFiles and cFile:IsFile("schematics/" .. FileName .. ".schematic")) then
		a_Player:SendMessage(cChatColor.LightGray .. "Couldn't write to a filename that's already taken.")
		return true
	end

	-- Check that there's data in the clipboard.
	local State = GetPlayerState(a_Player)
	if not(State.Clipboard:IsValid()) then
		a_Player:SendMessage(cChatColor.LightGray .. "Couldn't find anything on your clipboard to save.")
		return true
	end

	-- Save the clipboard.
	State.Clipboard:SaveToSchematicFile("schematics/" .. FileName .. ".schematic")
	a_Player:SendMessage(cChatColor.LightGray .. "Saved your clipboard as an operable schematic (" .. FileName .. ").")
	return true
end
