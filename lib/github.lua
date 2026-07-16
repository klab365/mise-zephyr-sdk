-- lib/github.lua
-- Shared GitHub API helpers for sdk-ng release metadata.

local M = {}

local REPO_API_URL = "https://api.github.com/repos/zephyrproject-rtos/sdk-ng"

function M.get(path)
	local http = require("http")

	local resp, err = http.get({
		url = REPO_API_URL .. path,
		headers = {
			["Accept"] = "application/vnd.github+json",
			["User-Agent"] = "mise-zephyr-sdk-plugin",
		},
	})

	if err ~= nil then
		error("failed to fetch GitHub API path " .. path .. ": " .. err)
	end
	if resp.status_code ~= 200 then
		error("GitHub API returned status " .. resp.status_code .. " for path " .. path .. ": " .. resp.body)
	end

	local json = require("json")
	return json.decode(resp.body)
end

return M
