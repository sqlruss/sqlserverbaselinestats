Function Save-InstanceInfo
{
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$True, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)][ValidateNotNullOrEmpty()]
        [string]$TargetServer,
    
        [Parameter(Mandatory=$True)][ValidateNotNullOrEmpty()]
        [string]$MonitorServer
    )

    Begin {
        Set-Strictmode -Version Latest
    }

    Process { #enumerates pipeline input; ignored for param input
        ForEach ($Computer in $TargetServer) { #enumerates param input; effectively ignored for pipeline input
            Try {
                $query = 'SELECT	
                SERVERPROPERTY(''ServerName'') /*Default+NamedInstance*/ AS SQLInstanceName,
                SERVERPROPERTY(''ComputerNamePhysicalNetBIOS'') AS ComputerNamePhysicalNetBIOS,
                SERVERPROPERTY(''IsClustered'') AS IsClustered,
                SERVERPROPERTY(''ProductVersion'') AS SQLProductVersion,
                SERVERPROPERTY(''ProductLevel'') AS SQLProductLevel,
                SERVERPROPERTY(''Edition'') AS SQLEdition,
                (SELECT MIN(CreateDate) FROM syslogins WHERE [SID] IN (0x010100000000000512000000,0x01020000000000052000000020020000)) AS [SQLInstallDate], 
                (SELECT Login_Time FROM [sysprocesses] WHERE [SPID] = 1) AS [SQLServiceLastRestart]'

                $InstanceInfo = invoke-sqlcmd -ServerInstance $Computer -Query $query -ConnectionTimeout 10 -QueryTimeout 30 -Verbose -ErrorAction Stop

                $InsertResults =
@"
IF EXISTS(SELECT * FROM BaselineStats.dbo.InstanceInfo WHERE SQLInstanceName = '$($InstanceInfo.SQLInstanceName)' AND ComputerNamePhysicalNetBIOS = '$($InstanceInfo.ComputerNamePhysicalNetBIOS)')
UPDATE BaselineStats.dbo.InstanceInfo 
SET InstanceInfoDate = GETUTCDATE(), 
IsClustered = '$($InstanceInfo.IsClustered)', 
SQLProductVersion = '$($InstanceInfo.SQLProductVersion)', 
SQLProductLevel = '$($InstanceInfo.SQLProductLevel)', 
SQLEdition = '$($InstanceInfo.SQLEdition)', 
SQLInstallDate = '$($InstanceInfo.SQLInstallDate)', 
SQLServiceLastRestart = '$($InstanceInfo.SQLServiceLastRestart)'
WHERE SQLInstanceName = '$($InstanceInfo.SQLInstanceName)' AND ComputerNamePhysicalNetBIOS = '$($InstanceInfo.ComputerNamePhysicalNetBIOS)'
ELSE
INSERT INTO [BaselineStats].[dbo].[InstanceInfo]
(
SQLInstanceName,
ComputerNamePhysicalNetBIOS,
IsClustered,
SQLProductVersion,
SQLProductLevel,
SQLEdition,
SQLInstallDate,
SQLServiceLastRestart
)
VALUES 
(
'$($InstanceInfo.SQLInstanceName)', 
'$($InstanceInfo.ComputerNamePhysicalNetBIOS)', 
'$($InstanceInfo.IsClustered)',
'$($InstanceInfo.SQLProductVersion)', 
'$($InstanceInfo.SQLProductLevel)', 
'$($InstanceInfo.SQLEdition)', 
'$($InstanceInfo.SQLInstallDate)', 
'$($InstanceInfo.SQLServiceLastRestart)'
)
"@
            } Catch {
                Write-Warning "Failed to query $Computer SQL Instance."
                throw
            }

            If ($?) { # if last command succeeded
                Try {
                    Invoke-sqlcmd -ServerInstance $MonitorServer -Query "$InsertResults" -ConnectionTimeout 15 -QueryTimeout 60 -ErrorAction Stop
                } Catch {
                    Write-Warning "Failed to insert data from $Computer to BaselineStats."
                }
            }

        }
    }
    End{}
}