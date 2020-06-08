# Package

version       = "0.1.0"
author        = "bung87"
description   = "nim tasks apply to git hooks"
license       = "MIT"
srcDir        = "src"
bin = @["stage"]


# Dependencies

requires "nim >= 1.3.3"
requires "shell"
requires "cligen"

let sh = """
cat << EOF > .git/hooks/pre-commit
#!/bin/sh
if stage checkError;then
    stage fixStyle
fi
EOF
chmod +x .git/hooks/pre-commit
"""
exec sh