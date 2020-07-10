function Build-Dependencies {
	param(
		[Parameter(Mandatory = $true)]
		[string]$CsProjPath,
		
		[Parameter(Mandatory = $true)]
		[string]$ModuleDirectory,

		[Parameter(Mandatory = $false)]
		[ValidateSet('quiet', 'q', 'minimal', 'm', 'normal', 'n', 'detailed', 'd', 'diagnostic', 'diag')]
		[Alias('v')]
		[string]$Verbosity = 'm',

		[Parameter(Mandatory = $false)]
		[switch]$IsExtensionModule
	)

	$projectRoot = Split-Path $CsProjPath -Parent
	$libFolder = "$ModuleDirectory\lib"
	$projectName = (Get-Item $CsProjPath).BaseName

	# Builds all libraries that PoShLog depends on
	dotnet publish -c Release $CsProjPath -o $libFolder --verbosity $Verbosity

	# Remove unecessary files
	Remove-Item "$libFolder\*.json" -Force -ErrorAction SilentlyContinue
	Remove-Item "$libFolder\*.pdb" -Force -ErrorAction SilentlyContinue
	Remove-Item "$libFolder\System.Management.Automation.dll" -Force -ErrorAction SilentlyContinue

	if ($IsExtensionModule) {
		Remove-Item "$libFolder\Serilog.dll" -Force -ErrorAction SilentlyContinue
		Remove-Item "$libFolder\Dependencies.dll" -Force -ErrorAction SilentlyContinue

		Get-ChildItem $libFolder | Where-Object { $_.Name -like "*$projectName*" } | Remove-Item -Force
	}

	# Remove unecessary bin and obj folders
	Remove-Item -Path @("$projectRoot\bin", "$projectRoot\obj") -Recurse -Force
}