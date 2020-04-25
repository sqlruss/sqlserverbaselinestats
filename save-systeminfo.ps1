Function Save-SystemInfo
{
    [CmdletBinding()]
    Param
    (
    [Parameter(Mandatory=$True, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)][ValidateNotNullOrEmpty()]
    [string]$TargetServer,

    [Parameter(Mandatory=$True)][ValidateNotNullOrEmpty()]
    [string]$MonitorServer,

    [Parameter(Mandatory=$False)]
    [string] $EnvironmentDescription = ''
    )

    Begin
    {
        Set-Strictmode -Version Latest
    }

    Process #enumerates pipeline input; ignored for param input
    {
        ForEach ($Computer in $TargetServer) #enumerates param input; effectively ignored for pipeline input
        {
            Try
            {
                'win32_operatingsystem call for ' + $Computer | Write-Debug
                $WinInfo = Get-WmiObject -Class win32_operatingsystem -ComputerName $Computer
            }
            Catch
            {
                'Failed to call win32_operatingsystem for ' + $Computer | Write-Warning
                throw
            }
            Try 
            {
                'win32_computersystem call for ' + $Computer | Write-Debug
                $PCInfo = Get-WmiObject -Class win32_computersystem -ComputerName $Computer
            }
            Catch 
            {
                throw
            }
            Try 
            {
                'win32_processor call for ' + $Computer | Write-debug
                $Proc = Get-WmiObject -Class win32_processor -ComputerName $Computer
            }
            Catch 
            {
                throw
            }

            $ProcInfo = $Proc | Select-Object Name, NumberOfCores, NumberOfLogicalProcessors, NumberOfProcessors -Unique

            $WindowsInfo = New-Object -TypeName PSObject -Property @{
                MachineName = $PCInfo.Name
                IPAddress = (Test-Connection -ComputerName $Computer -Count 1).IPV4Address.IPAddressToString
                Model = $PCInfo.Model
                CPUSockets = ($Proc | Measure-Object).Count
                CoresPerSocket = $ProcInfo.NumberOfCores
                LogicalCPUPerCore = $ProcInfo.NumberOfLogicalProcessors  
                MemoryGB = ($PCInfo.TotalPhysicalMemory / 1024 / 1024 / 1024)
                WindowsVersion = $WinInfo.Version
                WindowsVersionDescription = $WinInfo.Caption
                WindowsProductLevel = $WinInfo.CSDVersion
                WindowsInstallDate = $WinInfo.InstallDate.Substring(0,8)
                LastBootDate = $WinInfo.LastBootUpTime.Substring(0,8)
                Description = $EnvironmentDescription
                #Architecture = $WinInfo.OSArchitecture # only present on 2008 and up. in description on 2003
                }

$InsertResults =
@"
IF EXISTS(SELECT * FROM BaselineStats.dbo.SystemInfo WHERE MachineName = '$($WindowsInfo.MachineName)') 
UPDATE BaselineStats.dbo.SystemInfo 
SET SystemInfoDate = GETUTCDATE(), 
IPAddress = '$($WindowsInfo.IPAddress)', 
Model = '$($WindowsInfo.Model)', 
CPUSockets = '$($WindowsInfo.CPUSockets)', 
CoresPerSocket = '$($WindowsInfo.CoresPerSocket)', 
LogicalCPUPerCore = '$($WindowsInfo.LogicalCPUPerCore)', 
MemoryGB = '$($WindowsInfo.MemoryGB)', 
WindowsVersion = '$($WindowsInfo.WindowsVersion)', 
WindowsVersionDescription = '$($WindowsInfo.WindowsVersionDescription)', 
WindowsProductLevel = '$($WindowsInfo.WindowsProductLevel)', 
LastBootDate = '$($WindowsInfo.LastBootDate)', 
[Description] = '$($WindowsInfo.Description)'
WHERE MachineName = '$($WindowsInfo.MachineName)'
ELSE
INSERT INTO BaselineStats.dbo.SystemInfo
(
MachineName, 
IPAddress,
Model, 
CPUSockets, 
CoresPerSocket, 
LogicalCPUPerCore, 
MemoryGB, 
WindowsVersion, 
WindowsVersionDescription, 
WindowsProductLevel, 
LastBootDate, 
Description 
)
VALUES 
(
'$($WindowsInfo.MachineName)', 
'$($WindowsInfo.IPAddress)', 
'$($WindowsInfo.Model)', 
'$($WindowsInfo.CPUSockets)',
'$($WindowsInfo.CoresPerSocket)', 
'$($WindowsInfo.LogicalCPUPerCore)', 
'$($WindowsInfo.MemoryGB)', 
'$($WindowsInfo.WindowsVersion)', 
'$($WindowsInfo.WindowsVersionDescription)', 
'$($WindowsInfo.WindowsProductLevel)', 
'$($WindowsInfo.LastBootDate)', 
'$($WindowsInfo.Description)' 
);
"@
            Try 
            {
                'Attempting insert for ' + $Computer | Write-Debug
                Invoke-sqlcmd -ServerInstance $MonitorServer -Query "$InsertResults" -ErrorAction Stop -ConnectionTimeout 15 -QueryTimeout 60
            }
            catch 
            {
                'Failed to insert results for ' + $Computer | Write-Error
            }
        }
    }
    End{}
}
