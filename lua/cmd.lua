local Job = require("plenary.job")

local cmd = {}

function cmd.homeManager(options)
  Job:new {
    command = "home-manager",
    args = options.args,
    on_stderr = options.on_stderr,
    on_stdout = options.on_stdout,
    on_exit = options.on_exit,
    interactive = false
  }:start()
end

function cmd.nixPrefetchGit(owner, repo, rev)
  local args = {"--unpack", "--print-path", "https://github.com/" .. owner .. "/" .. repo .. "/archive/" .. rev .. ".tar.gz"}
  local path = Job:new {
    command = "nix-prefetch-url",
    args = args
  }:sync()[2]
  local hash = cmd.nixHash(path)
  local sha256 = cmd.base64(cmd.xxd(hash))
  return sha256
end

function cmd.nixHash(path)
  return Job:new {
    command = "nix-hash",
    args = {"--type", "sha256", path}
  }
end

function cmd.xxd(sha256)
  return Job:new {
    command = "xxd",
    args = {"-r", "-p"},
    writer = sha256
  }
end

function cmd.base64(binaryJob)
  return Job:new{
    command = "base64",
    writer = binaryJob
  }:sync()[1]
end

return cmd
