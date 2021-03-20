{.define(shellNoDebugOutput).}
{.define(shellNoDebugCommand).}
import shell
import strutils
import osproc
import os
import sequtils
import strformat

const SH = """
#!/bin/sh
if stage checkError;then
    stage fixStyle
else
    exit 1
fi
"""

proc getStagedFiles*(pattern: string = ""): seq[string] =
  const cached = "--cached"
  const nameOnly = "--name-only"
  const filter = "--diff-filter=d"
  var res: tuple[output: string, exitCode: int]
  let ptn = "\"" & pattern & "\""
  if pattern.len > 0:
    res = shellVerbose:
      git diff ($cached) ($nameOnly) ($filter) ($ptn)
  else:
    res = shellVerbose:
      git diff ($cached) ($nameOnly) ($filter)
  if res[0].len > 0:
    result = res[0].splitLines().filterIt(fileExists(it))

proc checkError*(files: seq[string]): int =
  for file in files.filterIt(it.endsWith(".nim")):
    let (output, exitCode) = execCmdEx("nim " &
        "check --hints:off --colors:on  " & file)
    if exitCode != 0:
      shell:
        git restore "--staged" ($file)
    result = exitCode
    stdout.write(output)

proc checkStyle*(files: seq[string]): int =
  # not used
  # https://github.com/nim-lang/Nim/blob/27b081d1f77604ee47c886e69dbc52f53ea3741f/doc/nimfix.rst#L18
  # --overwriteFiles:on|off overwrite the original nim files. DEFAULT is ON!
  # --wholeProject overwrite every processed file.
  # --checkExtern:on|off style check also extern names
  # --styleCheck:on|off|auto performs style checking for identifiers

  for file in files.filterIt(it.endsWith(".nim")):
    let (output, exitCode) = execCmdEx("nimfix " &
        "--styleCheck:error --hints:off --colors:on  " & file)
    if exitCode != 0:
      result = exitCode
    stdout.write(output)

proc fixStyle*(files: seq[string]): int =
  when (NimMajor, NimMinor, NimPatch) >= (1, 3, 5):
    if files.len > 0:
      let files = files.filterIt(it.endsWith(".nim")).join(" ")
      if files.len > 0:
        let (output, exitCode) = execCmdEx("nimpretty " &
            "--indent:2 --maxLineLen:120 " & files)
        if exitCode != 0:
          result = exitCode
  else:
    for file in files.filterIt(it.endsWith(".nim")):
      let (output, exitCode) = execCmdEx("nimpretty " &
          "--indent:2 --maxLineLen:120 " & file)
      if exitCode != 0:
        result = exitCode

      stdout.write(output)

proc listFiles(pattern: string): seq[string] =
  result = toSeq(walkPattern(pattern))

when isMainModule and not defined(release):
  let files = getStagedFiles()
  discard checkError(files)
  discard fixStyle(files)

when isMainModule and defined(release):
  import cligen

  proc fixStyleD(allFiles: bool = false, pattern: string = "**/*.nim"): bool =
    let files = if allFiles: listFiles(pattern) else: getStagedFiles(pattern)

    result = fixStyle(files).bool

  proc checkErrorD(allFiles: bool = false, pattern: string = "**/*.nim"): bool =
    let files = if allFiles: listFiles(pattern) else: getStagedFiles(pattern)

    result = checkError(files).bool

  proc init(): void =
    if dirExists(".git"):
      writeFile ".git/hooks/pre-commit", SH
      inclFilePermissions ".git/hooks/pre-commit", {fpUserExec, fpGroupExec, fpOthersExec}
    else:
      stderr.write("Please run git init first\n")

  proc gitignore() =
    const c = staticRead(currentSourcePath.parentDir() / "gitignore.tpl")
    writeFile ".gitignore", c

  dispatchMulti(
    [init, doc = "init pre commit git hook"],
    [gitignore, doc = "init .gitignore"],
    [fixStyleD, cmdName = "fixStyle", doc = "fix code style through `nimpretty`", help = {
      "pattern": "limit to files matching this glob pattern",
      "allFiles": "include all files, not just the staged ones"
    }],
    [checkErrorD, cmdName = "checkError", doc = "check error through `nim check`", help = {
      "pattern": "limit to files matching this glob pattern",
      "allFiles": "include all files, not just the staged ones"
    }]
  )

