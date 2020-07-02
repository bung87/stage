# Package

version       = "0.1.0"
author        = "bung87"
description   = "nim tasks apply to git hooks"
license       = "MIT"
srcDir        = "src"
bin = @["stage"]


# Dependencies

requires "nim >= 1.2.4"
requires "shell"
requires "cligen"

let sh = """
#!/bin/sh
if stage checkError;then
    stage fixStyle
else
    exit 1
fi
"""
writeFile ".git/hooks/pre-commit",sh
exec "chmod 0755 .git/hooks/pre-commit"
# inclFilePermissions ".git/hooks/pre-commit",{fpUserExec,fpGroupExec,fpOthersExec}
