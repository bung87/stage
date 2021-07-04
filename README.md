# stage  ![Build Status](https://github.com/bung87/stage/workflows/Test/badge.svg)  

install this package will create `pre-commit` file under `.git/hooks`  
do `nim check`,`nimpretty` to staged files and `git add` after tasks done.  

## Usage  
```
Usage:
  stage {SUBCMD}  [sub-command options & parameters]
where {SUBCMD} is one of:
  help        print comprehensive or per-cmd help
  init        init pre commit git hook
  ghWorkflow  init github workflow file
  gitignore   init .gitignore
  fixStyle    fix code style through `nimpretty`
  checkError  check error through `nim check`
  workflow    checkError,fixStyle and run git add
```
