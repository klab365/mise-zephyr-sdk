-- hooks/pre_install.lua
-- Resolves the download URL for the "minimal" SDK tarball matching the
-- current OS/arch (host tools + registration script, no toolchains --
-- those get pulled by setup.sh in post_install.lua).

local platform = require("platform")
local github = require("github")
local toolchains = require("toolchains")

function PLUGIN:PreInstall(ctx)
	local version = ctx.version
	toolchains.configured()

	local token, perr = platform.asset_token()
	if not token then
		error(perr)
	end

	-- Look up the actual release so we get the real asset URL and can
	-- verify the file exists, rather than guessing the URL shape.
	local release = github.get("/releases/tags/v" .. version)
	local assets = github.get_all("/releases/" .. release.id .. "/assets?per_page=100")
	local expected_asset_name = "zephyr-sdk-" .. version .. "_" .. token .. "_minimal.tar.xz"

	local asset_url = nil
	local asset_name = nil
	local sha256 = nil
	for _, asset in ipairs(assets) do
		if asset.name == expected_asset_name then
			asset_url = asset.browser_download_url
			asset_name = asset.name
			if asset.digest then
				sha256 = asset.digest:match("^sha256:(%x+)$")
			end
			break
		end
	end

	if not asset_url then
		error("no matching asset found for platform '" .. token .. "' in zephyr-sdk release v" .. version)
	end

	return {
		version = version,
		url = asset_url,
		sha256 = sha256,
		note = "Installing Zephyr SDK " .. version .. " (" .. asset_name .. ")",
	}
end
