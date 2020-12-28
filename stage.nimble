# Package

version       = "0.3.1"
author        = "bung87"
description   = "nim tasks apply to git hooks"
license       = "MIT"
srcDir        = "src"
bin = @["stage"]


# Dependencies

requires "nim >= 1.2.4"
requires "shell"
requires "cligen >= 1.3.2"

let sh = """
#!/bin/sh
if stage checkError;then
    stage fixStyle
else
    exit 1
fi
"""
if dirExists(".git"):
  writeFile ".git/hooks/pre-commit",sh
  exec "chmod 0755 .git/hooks/pre-commit"
  # inclFilePermissions ".git/hooks/pre-commit",{fpUserExec,fpGroupExec,fpOthersExec}
