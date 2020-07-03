{.define(shellNoDebugOutput).}
{.define(shellNoDebugCommand).}
import shell
import strutils
import strformat
import osproc
import os
import sequtils

proc getStagedFiles*(pattern: string = ""): seq[string] =
  var stdout = shellVerbose:
    git diff "--cached""--name-only""--diff-filter=d" ($pattern)

  result = stdout.output.splitLines().filterIt(fileExists(it))

proc checkError*(files: seq[string]): int =
  for file in files.filterIt(it.endsWith(".nim")):
    let (output, exitCode) = execCmdEx("nim " & "check --hints:off --colors:on  " & file)
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
    let (output, exitCode) = execCmdEx("nimfix " & "--styleCheck:error --hints:off --colors:on  " & file)
    if exitCode != 0:
      result = exitCode
    stdout.write(output)

proc fixStyle*(files: seq[string]): int =
  for file in files.filterIt(it.endsWith(".nim")):
    let (output, exitCode) = execCmdEx("nimpretty " & "indent:2 --maxLineLen:120 " & file)
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

  dispatchMulti(
    [fixStyleD, cmdName = "fixStyle", help = {
      "pattern": "limit to files matching this glob pattern",
      "allFiles": "include all files, not just the staged ones"
    }],
    [checkErrorD, cmdName = "checkError", help = {
      "pattern": "limit to files matching this glob pattern",
      "allFiles": "include all files, not just the staged ones"
    }]
  )

