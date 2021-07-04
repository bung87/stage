# Package

version       = "0.3.5"
author        = "bung87"
description   = "nim tasks apply to git hooks"
license       = "MIT"
srcDir        = "src"
bin = @["stage"]
installExt = @["nim","tpl"]


# Dependencies

requires "nim >= 1.2.4"
requires "shell >= 0.4.3"
requires "cligen >= 1.3.2"

let sh = """
#!/bin/sh
stage workflow
"""
if dirExists(".git"):
  writeFile ".git/hooks/pre-commit",sh
  exec "chmod 0755 .git/hooks/pre-commit"
  # inclFilePermissions ".git/hooks/pre-commit",{fpUserExec,fpGroupExec,fpOthersExec}
