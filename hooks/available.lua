-- hooks/available.lua
-- Lists installable versions by reading GitHub releases for
-- zephyrproject-rtos/sdk-ng. No hardcoded version list, so new SDK
-- releases show up automatically without touching this plugin.

function PLUGIN:Available(ctx)
	local github = require("github")
	local releases = github.get("/releases?per_page=100")
	local result = {}

	for _, release in ipairs(releases) do
		-- tags look like "v0.17.4"
		local version = release.tag_name:gsub("^v", "")
		local note = nil
		if release.prerelease then
			note = "prerelease"
		end

		table.insert(result, {
			version = version,
			note = note,
		})
	end

	return result
end
