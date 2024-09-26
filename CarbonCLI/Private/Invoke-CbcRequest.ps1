using module ../CarbonCLI.Classes.psm1
function Invoke-CbcRequest {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true,Position = 0)]
		[ValidateNotNullOrEmpty()]
		[CbcServer]$Server,

		[Parameter(Mandatory = $true,Position = 1)]
		[ValidateNotNullOrEmpty()]
		[string]$Endpoint,

		[Parameter(Mandatory = $true,Position = 2)]
		[string]$Method,

		[array]$Params,

		[System.Object]$Body
	)

	begin {
		Write-Verbose "[$($MyInvocation.MyCommand.Name)] function started"
	}

	process {
		$Headers = @{
			"X-AUTH-TOKEN" = $Server.Token | ConvertFrom-SecureString -AsPlainText
			"Content-Type" = "application/json"
			"User-Agent" = "CarbonCLI"
		}
		$Params =,$Server.Org + $Params
		$FormattedUri = $Endpoint -f $Params

		$FullUri = $Server.Uri + $FormattedUri
		Write-Debug "[$($MyInvocation.MyCommand.Name)] requesting: ${FullUri}"
		Write-Debug "[$($MyInvocation.MyCommand.Name)] with request body: ${Body}"
		Write-Debug "[$($MyInvocation.MyCommand.Name)] with method body: ${Method}"
		Write-Debug "[$($MyInvocation.MyCommand.Name)] with uri params body: ${Params}"
		try {
			$Response = Invoke-WebRequest -Uri $FullUri.TrimEnd("/") -Headers $Headers -Method $Method -Body $Body
			Write-Debug "[$($MyInvocation.MyCommand.Name)] got response with content: $($Response.Content)"
			Write-Debug "[$($MyInvocation.MyCommand.Name)] got status code: $($Response.StatusCode)"
			return $Response
		}
		catch {
			Write-Debug $_.Exception
			$StatusCode = $_.Exception.Response.StatusCode
			Write-Error "[$($MyInvocation.MyCommand.Name)] request to ${FullUri} failed. Status Code: ${StatusCode}"
			# return empty result for errors, so that it is not failing if it fails for one connection
			return @{"Content" = ""}
		}
		return $null
	}

	end {
		Write-Verbose "[$($MyInvocation.MyCommand.Name)] function finished"
	}
}
