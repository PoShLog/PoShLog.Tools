function Expand-VersionFromBranch {
	param(
		[Parameter(Mandatory = $true)]
		[string]$BranchName
	)

	if ($BranchName -match 'releases/v?(?<version>\d+\.\d+\.\d+)-?(?<label>\w+)?') {
		[Version]$targetVersion = $Matches.version

		Set-PipelineVariable -Name 'MajorVersion' -Value $targetVersion.Major
		Set-PipelineVariable -Name 'MinorVersion' -Value $targetVersion.Minor
		Set-PipelineVariable -Name 'BugfixVersion' -Value $targetVersion.Build
		Set-PipelineVariable -Name 'VersionLabel' -Value $Matches.label

		$FullVersion = "$($targetVersion.Major).$($targetVersion.Minor).$($targetVersion.Build)"
		if (-not [string]::IsNullOrEmpty($Matches.label)) {
			$FullVersion += "-$($Matches.label)"
		}

		Set-PipelineVariable -Name 'FullVersion' -Value $FullVersion
	}
	else {
		throw 'Could not parse version number from branch name!'
	}
}