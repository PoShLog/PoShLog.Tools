using namespace Microsoft.PowerShell.Commands

function Bootstrap {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true)]
		[string]$RequiredModulesFile,

		[Parameter(Mandatory = $false)]
		[ValidateSet("CurrentUser", "AllUsers")]
		[string]$Scope = "CurrentUser"
	)

	[ModuleSpecification[]]$RequiredModules = Import-LocalizedData -BaseDirectory (Split-Path $RequiredModulesFile -Parent) -FileName (Split-Path $RequiredModulesFile -Leaf)
	$Policy = (Get-PSRepository PSGallery).InstallationPolicy
	Set-PSRepository PSGallery -InstallationPolicy Trusted
	try {
		$RequiredModules | Install-Module -Scope $Scope -Repository PSGallery -SkipPublisherCheck -Verbose
	}
	finally {
		Set-PSRepository PSGallery -InstallationPolicy $Policy
	}
	$RequiredModules | Import-Module
}