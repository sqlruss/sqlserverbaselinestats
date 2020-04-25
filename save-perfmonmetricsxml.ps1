Function global:Save-PerfMonMetricsXML
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$True)][ValidateNotNullOrEmpty()]
        [string]$TargetServer,
        [Parameter(Mandatory=$True)][ValidateNotNullOrEmpty()]
        [string]$MonitorServer
    )

    BEGIN{}
    PROCESS
    {
        #$DebugPreference = "Continue"
        Set-Location C:\
        
    #Import-Module sqlps

    If($PSVersionTable.PSVersion.Major -eq 2)
    {
        add-pssnapin sqlserverprovidersnapin100; add-pssnapin sqlservercmdletsnapin100
    }

        $monitorDB = 'BaselineStats'
        $block =
        {
            $instance = 'SQLSERVER'
            $counters =
            @(
            "\Processor(_total)\% Processor Time",
            "\Processor(_total)\% Privileged Time",
            "\Process(sqlservr)\% Processor Time",
            "\Process(sqlservr)\% Privileged Time",
            "\Memory\Available MBytes",
            "\$($instance):Buffer Manager\Lazy Writes/sec",
            "\$($instance):Buffer Manager\Page Reads/sec",
            "\$($instance):Buffer Manager\Page Writes/sec",
            "\$($instance):Buffer Manager\Page Life Expectancy",
            "\$($instance):Buffer Manager\Free list stalls/sec",
            "\$($instance):Memory Manager\Total Server Memory (KB)",
            "\$($instance):Memory Manager\Target Server Memory (KB)",
            "\$($instance):Memory Manager\Memory Grants Pending",
            "\SQLServer:SQL Statistics\SQL Compilations/sec",
            "\SQLServer:SQL Statistics\SQL Re-Compilations/sec",
            "\SQLServer:SQL Statistics\Batch Requests/sec",
            "\SQLServer:General Statistics\Processes blocked",
            "\System\Processor Queue Length",
            "\PhysicalDisk(*)\Avg. Disk sec/Read",
            "\PhysicalDisk(*)\Avg. Disk sec/Write",
            "\PhysicalDisk(*)\Avg. Disk Bytes/Read",
            "\PhysicalDisk(*)\Avg. Disk Bytes/Write",
            "\PhysicalDisk(*)\Current Disk Queue Length",
            "\Paging File(_total)\% Usage",
            "\$($instance):Access Methods\Forwarded Records/sec",
            "\$($instance):Access Methods\Full Scans/sec",
            "\$($instance):Access Methods\Index Searches/sec",
            "\Network Interface(*)\Bytes Received/sec",
            "\Network Interface(*)\Bytes Sent/sec",
            "\Network Interface(*)\Output Queue Length"
            )
            $collections = Get-Counter -Counter $counters -SampleInterval 1 -MaxSamples 1 -ErrorAction SilentlyContinue
            $sampling = $collections.CounterSamples | Select-Object -Property TimeStamp, Path, Cookedvalue
            $xmlString = $sampling | ConvertTo-Xml -As String
            "EXEC [Queues].[InsertCounter] '$xmlString';"
        }

        $query = Invoke-Command -ComputerName $TargetServer -ScriptBlock $block

        "Captured perf mon metrics" | Write-Verbose

        #'Insert values into baseline database'
        Invoke-Sqlcmd -ServerInstance $monitorServer -Database $monitorDB -Query $query -ErrorAction Stop -ConnectionTimeout 15 -QueryTimeout 60

        "Recorded perf mon metrics" | Write-Verbose

    }
    END{}
}