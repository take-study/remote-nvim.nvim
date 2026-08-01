---@type remote-nvim.RemoteNeovim
local remote_nvim = require("remote-nvim")

local function pr_action(_)
  local co = coroutine.running()

  vim.ui.input({ prompt = "Git URI: " }, function(git_uri)
    vim.schedule(function()
      git_uri = vim.trim(git_uri or "")
      if git_uri == "" then
        if co then
          coroutine.resume(co)
        end
        return
      end
      git_uri = git_uri:gsub("/$", "")

      vim.ui.input({ prompt = "PR Number: " }, function(pr_number)
        vim.schedule(function()
          pr_number = vim.trim(pr_number or "")
          if pr_number == "" then
            if co then
              coroutine.resume(co)
            end
            return
          end

          local uri_components = vim.split(git_uri, "/", { trimempty = true })

          remote_nvim.session_provider
            :get_or_initialize_session({
              host = ("%s@pull/%s/head"):format(git_uri, pr_number),
              provider_type = "devpod",
              unique_host_id = ("%s-pr-%s"):format(uri_components[#uri_components], pr_number),
              devpod_opts = {
                provider = "docker",
                source_opts = {
                  type = "pr",
                  id = pr_number,
                  name = git_uri,
                },
              },
            })
            :launch_neovim()
          if co then
            coroutine.resume(co)
          end
        end)
      end)
    end)
  end)

  if co then
    coroutine.yield()
  end
end

return {
  name = "Dev Containers: Open remote PR",
  value = "devpod-remote-pr",
  action = pr_action,
  priority = 45,
  help = [[
## Description

Launch devcontainer project from remote PR.
]],
}
