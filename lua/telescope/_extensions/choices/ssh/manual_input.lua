---@type remote-nvim.RemoteNeovim
local remote_nvim = require("remote-nvim")

local function ssh_manual_action(_)
  local co = coroutine.running()

  vim.ui.input({ prompt = "ssh " }, function(ssh_input)
    vim.schedule(function()
      local ssh_args = vim.trim(ssh_input or "")
      if ssh_args == "" then
        if co then
          coroutine.resume(co)
        end
        return
      end
      local ssh_host = ssh_args:match("%S+@%S+")

      --- If there is only one parameter provided, it must be remote host
      if #vim.split(ssh_args, "%s") == 1 then
        ssh_host = ssh_args
      end

      if ssh_host == nil or ssh_host == "" then
        vim.notify("Could not automatically determine host", vim.log.levels.WARN)
        vim.ui.input({ prompt = "Enter hostname in conn. string: " }, function(host_input)
          vim.schedule(function()
            ssh_host = host_input or ""

            -- If no valid host name has been provided, exit
            if ssh_host == "" then
              vim.notify("Failed to determine the host to connect to. Aborting..", vim.log.levels.ERROR)
              if co then
                coroutine.resume(co)
              end
              return
            end

            remote_nvim.session_provider
              :get_or_initialize_session({
                host = ssh_host,
                provider_type = "ssh",
                conn_opts = { ssh_args },
              })
              :launch_neovim()
            if co then
              coroutine.resume(co)
            end
          end)
        end)
      else
        remote_nvim.session_provider
          :get_or_initialize_session({
            host = ssh_host,
            provider_type = "ssh",
            conn_opts = { ssh_args },
          })
          :launch_neovim()
        if co then
          coroutine.resume(co)
        end
      end
    end)
  end)

  if co then
    coroutine.yield()
  end
end

return {
  name = "Remote SSH: Set up using connection string",
  value = "remote-ssh-manual-input",
  action = ssh_manual_action,
  priority = 80,
  help = [[
## Description

Allows you to pass your own SSH connection string. Useful if you want to connect to a SSH host temporarily but do not want to add it to your `ssh_config` file.

Supports both key-based and password-based authentication.
]],
}
