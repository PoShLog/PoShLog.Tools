function Build-Dependencies {
	param(
		[Parameter(Mandatory = $true)]
		[string]$CsProjPath,
		
		[Parameter(Mandatory = $true)]
		[string]$ModuleDirectory,

		[Parameter(Mandatory = $false)]
		[string]$OutputFolderName = 'lib',

		[Parameter(Mandatory = $false)]
		[ValidateSet('quiet', 'q', 'minimal', 'm', 'normal', 'n', 'detailed', 'd', 'diagnostic', 'diag')]
		[Alias('v')]
		[string]$Verbosity = 'm',

		[Parameter(Mandatory = $false)]
		[switch]$IsExtensionModule
	)

	$projectRoot = Split-Path $CsProjPath -Parent

	$libsDirectory = "$ModuleDirectory\lib"
	if($null -ne $OutputFolderName){
		$libsDirectory = "$ModuleDirectory\$OutputFolderName"
	}
	New-Item -Path $libsDirectory -ItemType Directory -Force | Out-Null

	$projectName = (Get-Item $CsProjPath).BaseName

	# Builds all libraries that PoShLog depends on
	dotnet publish -c Release $CsProjPath -o $libsDirectory --verbosity $Verbosity

	# Remove unecessary files
	Remove-Item "$libsDirectory\*.json" -Force -ErrorAction SilentlyContinue
	Remove-Item "$libsDirectory\*.pdb" -Force -ErrorAction SilentlyContinue
	Remove-Item "$libsDirectory\System.Management.Automation.dll" -Force -ErrorAction SilentlyContinue

	if ($IsExtensionModule) {
		Remove-Item "$libsDirectory\Serilog.dll" -Force -ErrorAction SilentlyContinue
		Remove-Item "$libsDirectory\Dependencies.dll" -Force -ErrorAction SilentlyContinue

		Get-ChildItem $libsDirectory | Where-Object { $_.Name -like "*$projectName*" } | Remove-Item -Force
	}

	# Remove unecessary bin and obj folders
	Remove-Item -Path @("$projectRoot\bin", "$projectRoot\obj") -Recurse -Force
}