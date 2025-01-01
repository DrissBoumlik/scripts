# This is a list of powershell scripts I use on a daily basis

## Set environment variables from command line (no terminal restart needed)

> powershell -ExecutionPolicy Bypass -File "absolute\path\to\set-env.ps1" -variableName "YOUR_VARIABLE_NAME" -variableValue "YOUR_VARIABLE_VALUE"

where YOUR_VARIABLE_VALUE can be a path, or a name for an existing environment variable

## Switch on/off xdebug

> powershell -ExecutionPolicy Bypass -File "absolute\path\to\toggle-xdebug.ps1" -envVariableName php_now


## Update local and remote branches in one go

> powershell -ExecutionPolicy Bypass -File "absolute\path\to\update-branches.ps1" -Branches branch1,branch2 -Remotes origin1,origin2


## Get files count in each commit

> powershell -ExecutionPolicy Bypass -File "absolute\path\to\git-files.ps1"

## Get installed php versions
> powershell -ExecutionPolicy Bypass -File "absolute\path\to\list-php.ps1"

