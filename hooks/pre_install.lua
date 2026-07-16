-- hooks/pre_install.lua
-- Resolves the download URL for the "minimal" SDK tarball matching the
-- current OS/arch (host tools + registration script, no toolchains --
-- those get pulled by setup.sh in post_install.lua).

local platform = require("platform")
local github = require("github")

function PLUGIN:PreInstall(ctx)
	local version = ctx.version

	local token, perr = platform.asset_token()
	if not token then
		error(perr)
	end

	-- Look up the actual release so we get the real asset URL and can
	-- verify the file exists, rather than guessing the URL shape.
	local release = github.get("/releases/tags/v" .. version)
	local pattern = "zephyr%-sdk%-.*_" .. token .. "_minimal%.tar%.xz"

	local asset_url = nil
	local asset_name = nil
	for _, asset in ipairs(release.assets) do
		if asset.name:match(pattern) then
			asset_url = asset.browser_download_url
			asset_name = asset.name
			break
		end
	end

	if not asset_url then
		error("no matching asset found for platform '" .. token .. "' in zephyr-sdk release v" .. version)
	end

	return {
		version = version,
		url = asset_url,
		note = "Installing Zephyr SDK " .. version .. " (" .. asset_name .. ")",
	}
end
