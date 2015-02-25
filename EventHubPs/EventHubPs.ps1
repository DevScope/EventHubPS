$moduleHome= (split-path -parent $MyInvocation.MyCommand.Definition)

[System.Reflection.Assembly]::LoadFile((gi $moduleHome\Microsoft.ServiceBus.dll)) | Out-Null
[System.Reflection.Assembly]::LoadFile((gi $moduleHome\Newtonsoft.Json.dll)) | Out-Null
[System.Reflection.Assembly]::LoadFile((gi $moduleHome\Microsoft.Hadoop.Avro.dll)) | Out-Null

#$endpoint = "Endpoint=sb://canoassb.servicebus.windows.net/;SharedAccessKeyName=ps;SharedAccessKey=LwtGPBCLHle0MDO5ro8mRy8xGEQqUk/nZI2wZBKXQyM="
#$SharedAccessKeyName = 'ps'
#$SharedAccessKey = 'LwtGPBCLHle0MDO5ro8mRy8xGEQqUk/nZI2wZBKXQyM='
$deviceName = $env:COMPUTERNAME


#[Microsoft.Hadoop.Avro]::AvroSerializer

<#
.Synopsis
   Publish generic/anonymous data messages to Azure EventHubs
.DESCRIPTION
   Cmdlet utility to pipe generic/anonymous data messages to Azure EventHubs
.EXAMPLE
   get-service | SendTo-EventHub -endpoint $connectionString -hubName $hubName
#>
function SendTo-EventHub
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        # PSObject
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $data,

        # Endpoint connectionString
        [string]
        $endpoint,

        # Hub Name
        [string]
        $hubName = 'ingestion',

        #$SharedAccessKeyName = 'ps',
        #$SharedAccessKey = 'LwtGPBCLHle0MDO5ro8mRy8xGEQqUk/nZI2wZBKXQyM=',
        $source = $env:COMPUTERNAME
    )

    Begin
    {
        $all = @()
    }
    Process
    {
        $all += $_
        #TODO: batch?
    }
    End
    {
        $json = $all | ConvertTo-Json
        $data =  New-Object Microsoft.ServiceBus.Messaging.EventData -argu ( ,[byte[]][char[]]($json -join '') )
        $data.PartitionKey = $source
        $client = [Microsoft.ServiceBus.Messaging.EventHubClient]::CreateFromConnectionString($endpoint, $hubName)
        $client.Send($data)
    }
}
