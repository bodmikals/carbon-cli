class CbcServer {
	[ValidateNotNullOrEmpty()] [string]$Uri
	[ValidateNotNullOrEmpty()] [string]$Org
	[ValidateNotNullOrEmpty()] [SecureString]$Token
	[string]$Notes

	[string] ToString () {
		return "[" + $this.Org + "] " + $this.Uri
	}

	CbcServer ([string]$Uri_, [string]$Org_, [SecureString]$Token_, [string]$Notes_) {
		$this.Uri = $Uri_
		$this.Org = $Org_
		$this.Token = $Token_
		$this.Notes = $Notes_

	}

	CbcServer ([string]$Uri_, [string]$Org_, [SecureString]$Token_) {
		$this.Uri = $Uri_
		$this.Org = $Org_
		$this.Token = $Token_
		$this.Notes = ""

	}

	[bool] IsConnected ($defaultServers) {
		foreach ($defaultServer in $defaultServers) {
			if (($this.Uri -eq $defaultServer.Uri) -and
				($this.Org -eq $defaultServer.Org)) {
				return $true
			}
		}
		return $false
	}
}

class CbcConnections {
	[string]$FullPath
	[System.Xml.XmlDocument]$XmlDocument

	CbcConnections ([string]$FullPath) {
		$this.FullPath = $FullPath
		$DirPath = Split-Path $FullPath

		# Trying to create the dir within the path and the file itself
		if (-not (Test-Path -Path $DirPath)) {
			try {
				New-Item -Path $DirPath -Type Directory | Write-Debug
			}
			catch {
				Write-Error "Cannot create directory $(DirPath)" -ErrorAction Stop
			}
		}

		if (-not (Test-Path -Path $this.FullPath)) {
			try {
				New-Item -Path $this.FullPath | Write-Debug
				# Initialize an empty structure
				Add-Content $this.FullPath "<CBCServers></CBCServers>"
			}
			catch {
				Write-Error -Message "Cannot create file $(this.FullPath)" -ErrorAction Stop
			}
		}

		$this.XmlDocument = New-Object System.Xml.XmlDocument
		$this.XmlDocument.Load($this.FullPath)
	}

	SaveToFile ($Server) {
		try {
			# Convert the token to a secure string. On Win machines this will use Windows Data Encryption API to encrypt/decrypt the string
			#$secureToken = ConvertTo-SecureString $Server.Token -AsPlainText
			# Convert the secure string to a regular encrypted string so it can be stored in a file
			$secureTokenAsEncryptedString = $Server.Token | ConvertFrom-SecureString
			$ServerElement = $this.XmlDocument.CreateElement("CBCServer")
			$ServerElement.SetAttribute("Uri", $Server.Uri)
			$ServerElement.SetAttribute("Org", $Server.Org)
			$ServerElement.SetAttribute("Token", $secureTokenAsEncryptedString)
			$ServerElement.SetAttribute("Notes", $Server.Notes)

			$ServersNode = $this.XmlDocument.SelectSingleNode("CBCServers")
			$ServersNode.AppendChild($ServerElement)
			$this.XmlDocument.Save($this.FullPath)
		}
		catch {
			Write-Error -Message "Cannot store the server to the file $(this.FullPath)"
		}
	}

	[void] RemoveFromFile ($Server) {
		$Node = $this.XmlDocument.SelectSingleNode($("//CBCServer[@Uri = '{0}'][@Org = '{1}']" -f $Server.Uri, $Server.Org))
		$Node.ParentNode.RemoveChild($Node) | Out-Null
		$this.XmlDocument.Save($this.FullPath)
	}

	[bool] IsInFile ($Server) {
		$Node = $this.XmlDocument.SelectSingleNode($("//CBCServer[@Uri = '{0}'][@Org = '{1}']" -f $Server.Uri, $Server.Org))
		if (-not $Node) {
			return $false
		}
		return $true
	}
}

class CbcDevice {

	[string]$Id
	[string]$Status
	[string]$Group
	[string]$TargetPriority
	[string]$User
	[string]$Name
	[string]$Os
	[string]$LastContactTime
	[string]$SensorKitType
	[CbcServer]$Server
	[string]$DeploymentType
	[string]$LastDevicePolicyChangedTime
	[string]$LastDevicePolicyRequestedTime
	[string]$LastExternalIpAddress
	[string]$LastInternalIpAddress
	[string]$LastLocation
	[string]$LastPolicyUpdatedTime
	[string]$LastReportedTime
	[string]$LastResetTime
	[string]$LastShutdownTime
	[string]$MacAddress
	[string]$OrganizationId
	[string]$OrganizationName
	[string]$OsVersion
	[bool]$PassiveMode
	[string]$PolicyId
	[string]$PolicyName
	[string]$PolicyOverride
	[bool]$Quarantined
	[bool]$SensorOutOfDate
	[bool]$SensorPendingUpdate
	[string]$SensorVersion
	[string]$DeregisteredTime
	[string]$DeviceOwnerId
	[string]$RegisteredTime
	[string]$AvEngine
	[string]$AvLastScanTime
	[string]$AvStatus
	[long]$VulnerabilityScore
	[string]$VulnerabilitySeverity
	[string]$HostBasedFirewallReasons
	[string]$HostBasedFirewallStatus
	[string]$SensorGatewayUrl
	[string]$SensorGatewayUuid
	[string]$CurrentSensorPolicyName
	[string]$LastUserName
	[string[]]$SensorStates
	[string]$ActivationCode
	[string]$ApplianceName
	[string]$ApplianceUuid
	[bool]$BaseDevice
	[string]$ClusterName
	[string]$ComplianceStatus
	[string]$DatacenterName
	[string]$EsxHostName
	[string]$EsxHostUuid
	[bool]$GoldenDevice
	[int]$GoldenDeviceId
	[string]$GoldenDeviceStatus
	[bool]$NsxEnabled
	[string]$VcenterHostUrl
	[string]$VcenterName
	[string]$VcenterUuid
	[string]$VdiProdvider
	[bool]$VirtualMachine
	[string]$VirtualPrivateCloudId
	[string]$VirtualizationProvider
	[string]$VmIp
	[string]$VmName
	[string]$VmUuid
	[string]$AutoScalingGroupName
	[string]$CloudProviderAccountId
	[string]$CloudProviderResourceId
	[string[]]$CloudProviderTags
	[string]$CloudProviderResourceGroup
	[string]$CloudProviderScaleGroup
	[string]$CloudProviderNetwork
	[string]$CloudProviderManagedIdentity
	[string]$InfrastructureProvider
	CbcDevice (
		[string]$Id_,
		[string]$Status_,
		[string]$Group_,
		[string]$TargetPriority_,
		[string]$User_,
		[string]$Name_,
		[string]$Os_,
		[string]$LastContactTime_,
		[string]$SensorKitType_,
		[CbcServer]$Server_,
		[string]$DeploymentType_,
		[string]$LastDevicePolicyChangedTime_,
		[string]$LastDevicePolicyRequestedTime_,
		[string]$LastExternalIpAddress_,
		[string]$LastInternalIpAddress_,
		[string]$LastLocation_,
		[string]$LastPolicyUpdatedTime_,
		[string]$LastReportedTime_,
		[string]$LastResetTime_,
		[string]$LastShutdownTime_,
		[string]$MacAddress_,
		[string]$OrganizationId_,
		[string]$OrganizationName_,
		[string]$OsVersion_,
		[bool]$PassiveMode_,
		[string]$PolicyId_,
		[string]$PolicyName_,
		[string]$PolicyOverride_,
		[bool]$Quarantined_,
		[bool]$SensorOutOfDate_,
		[bool]$SensorPendingUpdate_,
		[string]$SensorVersion_,
		[string]$DeregisteredTime_,
		[string]$DeviceOwnerId_,
		[string]$RegisteredTime_,
		[string]$AvEngine_,
		[string]$AvLastScanTime_,
		[string]$AvStatus_,
		[long]$VulnerabilityScore_,
		[string]$VulnerabilitySeverity_,
		[string]$HostBasedFirewallReasons_,
		[string]$HostBasedFirewallStatus_,
		[string]$SensorGatewayUrl_,
		[string]$SensorGatewayUuid_,
		[string]$CurrentSensorPolicyName_,
		[string]$LastUserName_,
		[string[]]$SensorStates_,
		[string]$ActivationCode_,
		[string]$ApplianceName_,
		[string]$ApplianceUuid_,
		[bool]$BaseDevice_,
		[string]$ClusterName_,
		[string]$ComplianceStatus_,
		[string]$DatacenterName_,
		[string]$EsxHostName_,
		[string]$EsxHostUuid_,
		[bool]$GoldenDevice_,
		[int]$GoldenDeviceId_,
		[string]$GoldenDeviceStatus_,
		[bool]$NsxEnabled_,
		[string]$VcenterHostUrl_,
		[string]$VcenterName_,
		[string]$VcenterUuid_,
		[string]$VdiProdvider_,
		[bool]$VirtualMachine_,
		[string]$VirtualPrivateCloudId_,
		[string]$VirtualizationProvider_,
		[string]$VmIp_,
		[string]$VmName_,
		[string]$VmUuid_,
		[string]$AutoScalingGroupName_,
		[string]$CloudProviderAccountId_,
		[string]$CloudProviderResourceId_,
		[string[]]$CloudProviderTags_,
		[string]$CloudProviderResourceGroup_,
		[string]$CloudProviderScaleGroup_,
		[string]$CloudProviderNetwork_,
		[string]$CloudProviderManagedIdentity_,
		[string]$InfrastructureProvider_
	) {
		$this.Id = $Id_
		$this.Status = $Status_
		$this.Group = $Group_
		$this.TargetPriority = $TargetPriority_
		$this.User = $User_
		$this.Name = $Name_
		$this.Os = $Os_
		$this.LastContactTime = $LastContactTime_
		$this.SensorKitType = $SensorKitType_
		$this.Server = $Server_
		$this.DeploymentType = $DeploymentType_
		$this.LastDevicePolicyChangedTime = $LastDevicePolicyChangedTime_
		$this.LastDevicePolicyRequestedTime = $LastDevicePolicyRequestedTime_
		$this.LastExternalIpAddress = $LastExternalIpAddress_
		$this.LastInternalIpAddress = $LastInternalIpAddress_
		$this.LastLocation = $LastLocation_
		$this.LastPolicyUpdatedTime = $LastPolicyUpdatedTime_
		$this.LastReportedTime = $LastReportedTime_
		$this.LastResetTime = $LastResetTime_
		$this.LastShutdownTime = $LastShutdownTime_
		$this.MacAddress = $MacAddress_
		$this.OrganizationId = $OrganizationId_
		$this.OrganizationName = $OrganizationName_
		$this.OsVersion = $OsVersion_
		$this.PassiveMode = $PassiveMode_
		$this.PolicyId = $PolicyId_
		$this.PolicyName = $PolicyName_
		$this.PolicyOverride = $PolicyOverride_
		$this.Quarantined = $Quarantined_
		$this.SensorOutOfDate = $SensorOutOfDate_
		$this.SensorPendingUpdate = $SensorPendingUpdate_
		$this.SensorVersion = $SensorVersion_
		$this.DeregisteredTime = $DeregisteredTime_
		$this.DeviceOwnerId = $DeviceOwnerId_
		$this.RegisteredTime = $RegisteredTime_
		$this.AvEngine = $AvEngine_
		$this.AvLastScanTime = $AvLastScanTime_
		$this.AvStatus = $AvStatus_
		$this.VulnerabilityScore = $VulnerabilityScore_
		$this.VulnerabilitySeverity = $VulnerabilitySeverity_
		$this.HostBasedFirewallReasons = $HostBasedFirewallReasons_
		$this.HostBasedFirewallStatus = $HostBasedFirewallStatus_
		$this.SensorGatewayUrl = $SensorGatewayUrl_
		$this.SensorGatewayUuid = $SensorGatewayUuid_
	}
}

class CbcPolicy {

	[string]$Id
	[string]$Name
	[string]$Description
	[string]$PriorityLevel
	[int]$NumberDevices
	[int]$Position
	[bool]$SystemEnabled
	[CbcServer]$Server

	CbcPolicy (
		[string]$Id_,
		[string]$Name_,
		[string]$Description_,
		[string]$PriorityLevel_,
		[int]$NumberDevices_,
		[int]$Position_,
		[bool]$SystemEnabled_,
		[CbcServer]$Server_
	) {
		$this.Id = $Id_
		$this.Name = $Name_
		$this.Description = $Description_
		$this.PriorityLevel = $PriorityLevel_
		$this.NumberDevices = $NumberDevices_
		$this.Position = $Position_
		$this.SystemEnabled = $SystemEnabled_
		$this.Server = $Server_
	}
}


class CbcPolicyDetails {

	[string]$Id
	[string]$Name
	[string]$Description
	[string]$PriorityLevel
	[int]$Position
	[bool]$SystemEnabled
	[System.Management.Automation.PSObject[]]$Rules
	[System.Management.Automation.PSObject[]]$AVSettings
	[System.Management.Automation.PSObject[]]$SensorSettings
	[System.Management.Automation.PSObject]$ManagedDetectionResponsePermissions
	[CbcServer]$Server

	CbcPolicyDetails (
		[string]$Id_,
		[string]$Name_,
		[string]$Description_,
		[string]$PriorityLevel_,
		[int]$Position_,
		[bool]$SystemEnabled_,
		[System.Management.Automation.PSObject[]]$Rules_,
		[System.Management.Automation.PSObject[]]$AVSettings_,
		[System.Management.Automation.PSObject[]]$SensorSettings_,
		[System.Management.Automation.PSObject]$ManagedDetectionResponsePermissions_,
		[CbcServer]$Server_
	) {
		$this.Id = $Id_
		$this.Name = $Name_
		$this.Description = $Description_
		$this.PriorityLevel = $PriorityLevel_
		$this.Position = $Position_
		$this.SystemEnabled = $SystemEnabled_
		$this.Rules = $Rules_
		$this.AVSettings = $AVSettings_
		$this.SensorSettings = $SensorSettings_
		$this.ManagedDetectionResponsePermissions = $ManagedDetectionResponsePermissions_
		$this.Server = $Server_
	}
}

class CbcAlert {

	[string]$Id
	[string]$DeviceId
	[string]$BackendTimestamp
	[string]$FirstEventTimestamp
	[string]$LastEventTimestamp
	[string]$LastUpdateTimestamp
	[string]$DevicePolicyId
	[string]$DevicePolicy
	[int]$Severity
	[array]$Tags
	[string]$DeviceTargetValue
	[string]$ThreatId
	[string]$Type
	[PSCustomObject]$Workflow
	[CbcServer]$Server

	CbcAlert (
		[string]$Id_,
		[string]$DeviceId_,
		[string]$BackendTimestamp_,
		[string]$FirstEventTimestamp_,
		[string]$LastEventTimestamp_,
		[string]$LastUpdateTimestamp_,
		[string]$DevicePolicyId_,
		[string]$DevicePolicy_,
		[int]$Severity_,
		[array]$Tags_,
		[string]$DeviceTargetValue_,
		[string]$ThreatId_,
		[string]$Type_,
		[PSCustomObject]$Workflow_,
		[CbcServer]$Server_
	) {
		$this.Id = $Id_
		$this.DeviceId = $DeviceId_
		$this.BackendTimestamp = $BackendTimestamp_
		$this.FirstEventTimestamp = $FirstEventTimestamp_
		$this.LastEventTimestamp = $LastEventTimestamp_
		$this.LastUpdateTimestamp = $LastUpdateTimestamp_
		$this.DevicePolicyId = $DevicePolicyId_
		$this.DevicePolicy = $DevicePolicy_
		$this.Severity = $Severity_
		$this.Tags = $Tags_
		$this.DeviceTargetValue = $DeviceTargetValue_
		$this.ThreatId = $ThreatId_
		$this.Type = $Type_
		$this.Workflow = $Workflow_
		$this.Server = $Server_
	}
}

class CbcObservation {
	[string]$Id
	[string]$AlertCategory
	[array]$AlertId
	[string]$BackendTimestamp
	[string[]]$BlockedHash
	[string]$DeviceExternalIp
	[string]$DeviceId
	[string]$DeviceInternalIp
	[string]$DeviceOs
	[string]$DevicePolicy
	[string]$DevicePolicyId
	[string]$DeviceSensorVersion
	[string]$EventId
	[string]$EventType
	[string]$ObservationId
	[string]$ObservationType
	[string[]]$ProcessCmdline
	[string]$ProcessEffectiveReputation
	[string]$ProcessHash
	[string]$ProcessName
	[string]$RuleId
	[string[]]$TTP
	[CbcServer]$Server

	CbcObservation (
		[string]$Id_,
		[string]$AlertCategory_,
		[array]$AlertId_,
		[string]$BackendTimestamp_,
		[string[]]$BlockedHash_,
		[string]$DeviceExternalIp_,
		[string]$DeviceId_,
		[string]$DeviceInternalIp_,
		[string]$DeviceOs_,
		[string]$DevicePolicy_,
		[string]$DevicePolicyId_,
		[string]$DeviceSensorVersion_,
		[string]$EventId_,
		[string]$EventType_,
		[string]$ObservationId_,
		[string]$ObservationType_,
		[string]$ProcessCmdline_,
		[string]$ProcessEffectiveReputation_,
		[string]$ProcessHash_,
		[string]$ProcessName_,
		[string]$RuleId_,
		[string[]]$TTP_,
		[CbcServer]$Server_
	) {
		$this.Id = $Id_
		$this.AlertCategory = $AlertCategory_
		$this.AlertId = $AlertId_
		$this.BackendTimestamp = $BackendTimestamp_
		$this.BlockedHash = $BlockedHash_
		$this.DeviceExternalIp = $DeviceExternalIp_
		$this.DeviceId = $DeviceId_
		$this.DeviceInternalIp = $DeviceInternalIp_
		$this.DeviceOs = $DeviceOs_
		$this.DevicePolicy = $DevicePolicy_
		$this.DevicePolicyId = $DevicePolicyId_
		$this.DeviceSensorVersion = $DeviceSensorVersion_
		$this.EventId = $EventId_
		$this.EventType = $EventType_
		$this.ObservationId = $ObservationId_
		$this.ObservationType = $ObservationType_
		$this.ProcessCmdline = $ProcessCmdline_
		$this.ProcessEffectiveReputation = $ProcessEffectiveReputation_
		$this.ProcessHash = $ProcessHash_
		$this.ProcessName = $ProcessName_
		$this.RuleId = $RuleId_
		$this.TTP = $TTP_
		$this.Server = $Server_
	}
}


class CbcObservationDetails {
	[string]$Id
	[string]$AlertCategory
	[array]$AlertId
	[string]$BackendTimestamp
	[string[]]$BlockedHash
	[string]$DeviceExternalIp
	[string]$DeviceId
	[string]$DeviceInternalIp
	[string]$DeviceOs
	[string]$DevicePolicy
	[string]$DevicePolicyId
	[string]$DeviceSensorVersion
	[string]$EventId
	[string]$EventType
	[string]$ObservationId
	[string]$ObservationType
	[string]$ParentCmdline
	[string[]]$ProcessCmdline
	[string]$ProcessEffectiveReputation
	[string]$ProcessHash
	[string]$RuleId
	[string[]]$TTP
	[CbcServer]$Server

	CbcObservationDetails (
		[string]$Id_,
		[string]$AlertCategory_,
		[array]$AlertId_,
		[string]$BackendTimestamp_,
		[string[]]$BlockedHash_,
		[string]$DeviceExternalIp_,
		[string]$DeviceId_,
		[string]$DeviceInternalIp_,
		[string]$DeviceOs_,
		[string]$DevicePolicy_,
		[string]$DevicePolicyId_,
		[string]$DeviceSensorVersion_,
		[string]$EventId_,
		[string]$EventType_,
		[string]$ObservationId_,
		[string]$ObservationType_,
		[string]$ParentCmdline_,
		[string]$ProcessCmdline_,
		[string]$ProcessEffectiveReputation_,
		[string]$ProcessHash_,
		[string]$RuleId_,
		[string[]]$TTP_,
		[CbcServer]$Server_
	) {
		$this.Id = $Id_
		$this.AlertCategory = $AlertCategory_
		$this.AlertId = $AlertId_
		$this.BackendTimestamp = $BackendTimestamp_
		$this.BlockedHash = $BlockedHash_
		$this.DeviceExternalIp = $DeviceExternalIp_
		$this.DeviceId = $DeviceId_
		$this.DeviceInternalIp = $DeviceInternalIp_
		$this.DeviceOs = $DeviceOs_
		$this.DevicePolicy = $DevicePolicy_
		$this.DevicePolicyId = $DevicePolicyId_
		$this.DeviceSensorVersion = $DeviceSensorVersion_
		$this.EventId = $EventId_
		$this.EventType = $EventType_
		$this.ObservationId = $ObservationId_
		$this.ObservationType = $ObservationType_
		$this.ParentCmdline = $ParentCmdline_
		$this.ProcessCmdline = $ProcessCmdline_
		$this.ProcessEffectiveReputation = $ProcessEffectiveReputation_
		$this.ProcessHash = $ProcessHash_
		$this.RuleId = $RuleId_
		$this.TTP = $TTP_
		$this.Server = $Server_
	}
}


class CbcProcess {
	[string]$Id
	[string]$AlertCategory
	[array]$AlertId
	[string]$BackendTimestamp
	[string[]]$BlockedHash
	[string]$DeviceExternalIp
	[string]$DeviceId
	[string]$DeviceInternalIp
	[string]$DeviceOs
	[string]$DevicePolicy
	[string]$DevicePolicyId
	[string]$DeviceSensorVersion
	[string]$EventType
	[string]$ParentGuid
	[string[]]$ProcessCmdline
	[string]$ProcessEffectiveReputation
	[string]$ProcessGuid
	[string]$ProcessHash
	[string]$ProcessName
	[string[]]$TTP
	[CbcServer]$Server

	CbcProcess (
		[string]$Id_,
		[string]$AlertCategory_,
		[array]$AlertId_,
		[string]$BackendTimestamp_,
		[string[]]$BlockedHash_,
		[string]$DeviceExternalIp_,
		[string]$DeviceId_,
		[string]$DeviceInternalIp_,
		[string]$DeviceOs_,
		[string]$DevicePolicy_,
		[string]$DevicePolicyId_,
		[string]$DeviceSensorVersion_,
		[string]$EventType_,
		[string]$ParentGuid_,
		[string]$ProcessCmdline_,
		[string]$ProcessEffectiveReputation_,
		[string]$ProcessGuid_,
		[string]$ProcessHash_,
		[string]$ProcessName_,
		[string[]]$TTP_,
		[CbcServer]$Server_
	) {
		$this.Id = $Id_
		$this.AlertCategory = $AlertCategory_
		$this.AlertId = $AlertId_
		$this.BackendTimestamp = $BackendTimestamp_
		$this.BlockedHash = $BlockedHash_
		$this.DeviceExternalIp = $DeviceExternalIp_
		$this.DeviceId = $DeviceId_
		$this.DeviceInternalIp = $DeviceInternalIp_
		$this.DeviceOs = $DeviceOs_
		$this.DevicePolicy = $DevicePolicy_
		$this.DevicePolicyId = $DevicePolicyId_
		$this.DeviceSensorVersion = $DeviceSensorVersion_
		$this.EventType = $EventType_
		$this.ParentGuid = $ParentGuid_
		$this.ProcessCmdline = $ProcessCmdline_
		$this.ProcessEffectiveReputation = $ProcessEffectiveReputation_
		$this.ProcessGuid = $ProcessGuid_
		$this.ProcessHash = $ProcessHash_
		$this.ProcessName = $ProcessName_
		$this.TTP = $TTP_
		$this.Server = $Server_
	}
}

class CbcProcessDetails {
	[string]$Id
	[string]$AlertCategory
	[array]$AlertId
	[string]$BackendTimestamp
	[string[]]$BlockedHash
	[string]$DeviceExternalIp
	[string]$DeviceId
	[string]$DeviceInternalIp
	[string]$DeviceOs
	[string]$DevicePolicy
	[string]$DevicePolicyId
	[string]$EventType
	[string]$ParentCmdline
	[string]$ParentGuid
	[string[]]$ProcessCmdline
	[string]$ProcessEffectiveReputation
	[string]$ProcessGuid
	[string]$ProcessHash
	[string]$ProcessName
	[string[]]$TTP
	[CbcServer]$Server

	CbcProcessDetails (
		[string]$Id_,
		[string]$AlertCategory_,
		[array]$AlertId_,
		[string]$BackendTimestamp_,
		[string[]]$BlockedHash_,
		[string]$DeviceExternalIp_,
		[string]$DeviceId_,
		[string]$DeviceInternalIp_,
		[string]$DeviceOs_,
		[string]$DevicePolicy_,
		[string]$DevicePolicyId_,
		[string]$EventType_,
		[string]$ParentCmdline_,
		[string]$ParentGuid_,
		[string]$ProcessCmdline_,
		[string]$ProcessEffectiveReputation_,
		[string]$ProcessGuid_,
		[string]$ProcessHash_,
		[string]$ProcessName_,
		[string[]]$TTP_,
		[CbcServer]$Server_
	) {
		$this.Id = $Id_
		$this.AlertCategory = $AlertCategory_
		$this.AlertId = $AlertId_
		$this.BackendTimestamp = $BackendTimestamp_
		$this.BlockedHash = $BlockedHash_
		$this.DeviceExternalIp = $DeviceExternalIp_
		$this.DeviceId = $DeviceId_
		$this.DeviceInternalIp = $DeviceInternalIp_
		$this.DeviceOs = $DeviceOs_
		$this.DevicePolicy = $DevicePolicy_
		$this.DevicePolicyId = $DevicePolicyId_
		$this.EventType = $EventType_
		$this.ParentCmdline = $ParentCmdline_
		$this.ParentGuid = $ParentGuid_
		$this.ProcessCmdline = $ProcessCmdline_
		$this.ProcessEffectiveReputation = $ProcessEffectiveReputation_
		$this.ProcessGuid = $ProcessGuid_
		$this.ProcessHash = $ProcessHash_
		$this.ProcessName = $ProcessName_
		$this.TTP = $TTP_
		$this.Server = $Server_
	}
}

class CbcJob {
	[string]$Id
	[string]$Type
	[string]$Status
	[CbcServer]$Server

	CbcJob (
		[string]$Id_,
		[string]$Type_,
		[string]$Status_,
		[CbcServer]$Server_
	) {
		$this.Id = $Id_
		$this.Type = $Type_
		$this.Status = $Status_
		$this.Server = $Server_
	}
}

class CbcFeed {
	[string]$Id
	[string]$Name
	[string]$Owner
	[string]$ProviderUrl
	[string]$Summary
	[string]$Category
	[bool]$Alertable
	[string]$Access
	[CbcServer]$Server

	CbcFeed (
		[string]$Id_,
		[string]$Name_,
		[string]$Owner_,
		[string]$ProviderUrl_,
		[string]$Summary_,
		[string]$Category_,
		[bool]$Alertable_,
		[string]$Access_,
		[CbcServer]$Server_
	) {
		$this.Id = $Id_
		$this.Name = $Name_
		$this.Owner = $Owner_
		$this.ProviderUrl = $ProviderUrl_
		$this.Summary = $Summary_
		$this.Category = $Category_
		$this.Alertable = $Alertable_
		$this.Access = $Access_
		$this.Server = $Server_
	}
}

class CbcFeedDetails {
	[string]$Id
	[string]$Name
	[string]$Owner
	[string]$ProviderUrl
	[string]$Summary
	[string]$Category
	[bool]$Alertable
	[string]$Access
	[System.Object[]]$Reports
	[CbcServer]$Server

	CbcFeedDetails (
		[string]$Id_,
		[string]$Name_,
		[string]$Owner_,
		[string]$ProviderUrl_,
		[string]$Summary_,
		[string]$Category_,
		[bool]$Alertable_,
		[string]$Access_,
		[System.Object[]]$Reports_,
		[CbcServer]$Server_
	) {
		$this.Id = $Id_
		$this.Name = $Name_
		$this.Owner = $Owner_
		$this.ProviderUrl = $ProviderUrl_
		$this.Summary = $Summary_
		$this.Category = $Category_
		$this.Alertable = $Alertable_
		$this.Access = $Access_
		$this.Reports = $Reports_
		$this.Server = $Server_
	}
}

class CbcReport {
	[string]$Id
	[string]$Title
	[string]$Description
	[int]$Severity
	[string]$Link
	[System.Object[]]$IocsV2
	[string]$Visibility
	[string]$FeedId
	[CbcServer]$Server

	CbcReport (
		[string]$Id_,
		[string]$Title_,
		[string]$Description_,
		[int]$Severity_,
		[string]$Link_,
		[System.Object[]]$IocsV2_,
		[string]$Visibility_,
		[string]$FeedId_,
		[CbcServer]$Server_
	) {
		$this.Id = $Id_
		$this.Title = $Title_
		$this.Description = $Description_
		$this.Severity = $Severity_
		$this.Link = $Link_
		$this.IocsV2 = $IocsV2_
		$this.Visibility = $Visibility_
		$this.IocsV2 = $IocsV2_
		$this.FeedId = $FeedId_
		$this.Server = $Server_
	}
}

class CbcWatchlist {
	[string]$Id
	[string]$Name
	[string]$Description
	[bool]$AlertsEnabled
	[bool]$TagsEnabled
	[bool]$AlertClassificationEnabled
	[string]$FeedId
	[CbcServer]$Server

	CbcWatchlist (
		[string]$Id_,
		[string]$Name_,
		[string]$Description_,
		[bool]$AlertsEnabled_,
		[bool]$TagsEnabled_,
		[bool]$AlertClassificationEnabled_,
		[string]$FeedId_,
		[CbcServer]$Server_
	) {
		$this.Id = $Id_
		$this.Name = $Name_
		$this.Description = $Description_
		$this.AlertsEnabled = $AlertsEnabled_
		$this.TagsEnabled = $TagsEnabled_
		$this.AlertClassificationEnabled = $AlertClassificationEnabled_
		$this.FeedId = $FeedId_
		$this.Server = $Server_
	}
}

class CbcIoc {
	[string]$Id
	[string]$MatchType
	[string[]]$Values
	[string]$Field
	[string]$Link
	[string]$FeedId
	[string]$ReportId
	[CbcServer]$Server

	CbcIoc (
		[string]$Id_,
		[string]$MatchType_,
		[string]$Values_,
		[string]$Field_,
		[string]$Link_,
		[string]$FeedId_,
		[string]$ReportId_,
		[CbcServer]$Server_
	) {
		$this.Id = $Id_
		$this.MatchType = $MatchType_
		$this.Values = $Values_
		$this.Field = $Field_
		$this.Link = $Link_
		$this.FeedId = $FeedId_
		$this.ReportId = $ReportId_
		$this.Server = $Server_
	}
}
