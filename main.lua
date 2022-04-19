-- main.lua
-- Implements the plugin's main entrypoint.

-- Load the library expansions.
dofolder(cPluginManager:GetCurrentPlugin():GetLocalFolder() .. "/libraries")

g_ExcludedFolders = table.todictionary{
	"craftscripts",
	"libraries",
	".",
	"..",
}

-- Load all the folders.
local EditsPath = cPluginManager:GetCurrentPlugin():GetLocalFolder()
for _, Folder in ipairs(cFile:GetFolderContents(EditsPath)) do repeat
	local Path = EditsPath .. "/" .. Folder
	if (not cFile:IsFolder(Path)) then
		break
	end

	if (g_ExcludedFolders[Folder]) then
		break
	end

	dofolder(Path)
until true end

PLUGIN = nil

function Initialize(a_Plugin)
	PLUGIN = a_Plugin
	PLUGIN:SetName(g_PluginInfo.Name)
	PLUGIN:SetVersion(g_PluginInfo.Version)

	InitializeConfiguration(a_Plugin:GetLocalFolder() .. "/config.cfg")

	-- Load the InfoReg shared library...
	dofile(cPluginManager:GetPluginsPath() .. "/InfoReg.lua")

	-- Bind all the commands...
	RegisterPluginInfoCommands();

--	if (g_Config.Updates.CheckForUpdates) then
--		cUpdater:CheckForNewerVersion()
--	end

	-- Initialize cSQLStorage...
	cSQLStorage:Get()

	cFile:CreateFolder("schematics")

	return true
end

function OnDisable()
	ForEachPlayerState(
		function(a_State)
			a_State:Save(a_State:GetUUID())
		end
	)
end
