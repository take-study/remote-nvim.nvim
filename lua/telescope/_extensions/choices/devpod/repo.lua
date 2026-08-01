---@type remote-nvim.RemoteNeovim
local remote_nvim = require("remote-nvim")

local function repo_action(_)
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

      local uri_components = vim.split(git_uri, "/", { trimempty = true })

      remote_nvim.session_provider
        :get_or_initialize_session({
          host = git_uri,
          provider_type = "devpod",
          unique_host_id = ("%s-remote"):format(uri_components[#uri_components]),
          devpod_opts = {
            provider = "docker",
            source_opts = {
              type = "repo",
              id = git_uri,
            },
          },
        })
        :launch_neovim()
      if co then
        coroutine.resume(co)
      end
    end)
  end)

  if co then
    coroutine.yield()
  end
end

return {
  name = "Dev Containers: Open remote repo",
  value = "devpod-remote-repo",
  action = repo_action,
  priority = 60,
  help = [[
## Description

Launch devcontainer project from remote repository. Would be launched on the default branch. If you wish to alter the branch, use 'Dev Containers: Open remote branch'.
]],
}
