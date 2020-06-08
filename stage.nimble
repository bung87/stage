# Package

version       = "0.1.0"
author        = "bung87"
description   = "A new awesome nimble package"
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
stage checkError
stage fixStyle
EOF
chmod +x .git/hooks/pre-commit
"""
exec sh