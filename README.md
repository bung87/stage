# stage  

install this package will create `pre-commit` file under `.git/hooks`  
do `nim check`,`nimpretty` to staged files and `git add` after tasks done.  

## Usage  
```
Usage:
  stage {SUBCMD}  [sub-command options & parameters]
where {SUBCMD} is one of:
  help        print comprehensive or per-cmd help
  init        init pre commit git hook
  gitignore   init .gitignore
  fixStyle    fix code style through `nimpretty`
  checkError  check error through `nim check`
  workflow    combine all tasks and run git add
```
