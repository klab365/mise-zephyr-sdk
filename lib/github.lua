-- lib/github.lua
-- Shared GitHub API helpers for sdk-ng release metadata.

local M = {}

local REPO_API_URL = "https://api.github.com/repos/zephyrproject-rtos/sdk-ng"

function M.get(path)
	local http = require("http")
	local headers = {
		["Accept"] = "application/vnd.github+json",
		["User-Agent"] = "mise-zephyr-sdk-plugin",
	}
	local token = os.getenv("GITHUB_TOKEN")

	if token ~= nil and token ~= "" then
		headers["Authorization"] = "Bearer " .. token
	end

	local resp, err = http.get({
		url = REPO_API_URL .. path,
		headers = headers,
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

function M.get_all(path)
	local result = {}
	local page = 1
	local separator = "?"

	if path:find("?", 1, true) then
		separator = "&"
	end

	while true do
		local items = M.get(path .. separator .. "page=" .. page)

		if #items == 0 then
			break
		end

		for _, item in ipairs(items) do
			table.insert(result, item)
		end

		page = page + 1
	end

	return result
end

return M
