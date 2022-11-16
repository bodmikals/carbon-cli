<#
.DESCRIPTION
This cmdlet removes all or a specific connection from the CBC_CURRENT_CONNECTIONS.
.PARAMETER Server
Specifies the server you want to disconnect. It accepts '*' for all servers, server name,
array of server names or Server object.
.OUTPUTS
.NOTES
-------------------------- Example 1 --------------------------
Disconnect-CBCServer *
It disconnects all current connections.

-------------------------- Example 2 --------------------------
Disconnect-CBCServer [$ServerObj, $ServerObj1]
It disconnects the specified Server Object from the current connections.

-------------------------- Example 3 --------------------------
Disconnect-CBCServer ["Server", "Server1"]
It searches for Servers with this names from the current connections and disconnects them.
.LINK
Online Version: http://devnetworketc/
#>
function Disconnect-CBCServer {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        $Server
    )

    if ($Server -eq '*') {
        $CBC_CONFIG.currentConnections = [System.Collections.ArrayList]@()
    } elseif ($Server -is [array]) {
        if ($Server.Count -eq 0) {
            Write-Error "Empty array" -ErrorAction "Stop"
        }

        # array of Hashtables
        if ($Server[0] -is [PSCustomObject]) {
            $Server | ForEach-Object {
                $CBC_CONFIG.currentConnections.Remove($_)
            }
        }

        # array of Strings
        if ($Server[0] -is [string]) {
            foreach ($s in $Server) {
                $tmpCurrentConnections = $CBC_CONFIG.currentConnections | Where-Object { $_.Uri -eq $s }
                foreach ($c in $tmpCurrentConnections) {
                    $CBC_CONFIG.currentConnections.Remove($c)
                }
            }
        }
    } elseif ($Server -is [PSCustomObject]) {
        $CBC_CONFIG.currentConnections.Remove($Server)
    } elseif ($Server -is [string]) {
        $tmpCurrentConnections = $CBC_CONFIG.currentConnections | Where-Object { $_.Uri -eq $Server }
        foreach ($c in $tmpCurrentConnections) {
            $CBC_CONFIG.currentConnections.Remove($c)
        }
    }
}