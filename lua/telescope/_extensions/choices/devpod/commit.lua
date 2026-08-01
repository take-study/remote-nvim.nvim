---@type remote-nvim.RemoteNeovim
local remote_nvim = require("remote-nvim")

local function commit_action(_)
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

      vim.ui.input({ prompt = "Commit: " }, function(commit)
        vim.schedule(function()
          commit = vim.trim(commit or "")
          if commit == "" then
            if co then
              coroutine.resume(co)
            end
            return
          end

          local uri_components = vim.split(git_uri, "/", { trimempty = true })

          remote_nvim.session_provider
            :get_or_initialize_session({
              host = ("%s@sha256:%s"):format(git_uri, commit),
              provider_type = "devpod",
              unique_host_id = ("%s-%s"):format(uri_components[#uri_components], commit),
              devpod_opts = {
                provider = "docker",
                source_opts = {
                  type = "commit",
                  id = commit,
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
  name = "Dev Containers: Open remote commit",
  value = "devpod-remote-commit",
  action = commit_action,
  priority = 50,
  help = [[
## Description

Launch devcontainer project from remote SHA commit.
]],
}
