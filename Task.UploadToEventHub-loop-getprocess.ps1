#add ;TransportType=Amqp for better performance
$endpoint = "Endpoint=sb://canoassb.servicebus.windows.net/;SharedAccessKeyName=push;SharedAccessKey=bndWDL3G7AbOtJAyne6fngFGtxX6Jxh8XkZ9AShwGDk=;TransportType=Amqp"
$hubName = 'iot'

cd (split-path -parent $MyInvocation.MyCommand.Definition)
#Import-Module EventHubPs
. .\EventHubPs\EventHubPs.ps1


while($true) {
    #collect something
    $EventData = 1..100 | %{ Get-Process | sort CPU -desc | select ProcessName,CPU -first 20}
    
    #preview
    $EventData | select -first 5 | ConvertTo-Json 

    #send it as one message
    (Measure-Command {
        $EventData | SendTo-EventHub -endpoint $endpoint -hubName $hubName # -source "partition"
    }).TotalSeconds

}
