#ARP Cache Poison Detect Script

#Get some Network Info and set the variables
$NICS = Get-WMIObject Win32_NetworkAdapterConfiguration | Where-Object {$_.IPEnabled}
 $IPAddress = $NICS.IPAddress[0]
 $DefaultGateway = $NICS.DefaultIPGateway[0]
 $TestMAC = arp -a | select-string -pattern $DefaultGateway | out-string
 $BaselineMAC = $TestMAC.Split(" ") | Select-string "^([0-9A-F]{2}[:-]){5}([0-9A-F]{2})$" | out-string
 $BaseMAC = $BaselineMAC -replace ("`n","") | out-string

##BEGIN MENU
$Title = "Default Gateway:`n$DefaultGateway `n Gateway MAC: $BaseMAC`n"
$message = "Do you trust this Info? (Y/N)?"
$Yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
    "Begin Monitoring for changes to the gateway MAC address"
$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
    "Manually type the MAC address."	
$Options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
$result = $host.ui.PromptForChoice($title, $message, $options, 0)

switch ($result)
	{
		0 {[string]$MAC = $BaseMAC}
		1 {[string]$MAC = Read-host 'MAC ADDRESS'}
	}
###END MENU

Write-Host "Monitoring Gateway MAC..."

do { 
	$TestMAC = arp -a | select-string -pattern $DefaultGateway | out-string
	$BaselineMAC = $TestMAC.Split(" ") | Select-string "^([0-9A-F]{2}[:-]){5}([0-9A-F]{2})$" | out-string
	$BaseMAC = $BaselineMAC -replace ("`n","") | out-string
	start-sleep -s 3
	Write-host "Monitoring..."
	}
until ($BaseMAC -notmatch $MAC)

Write-Host "ARP CACHE POISON ATTEMPT! $TestMAC" -background "red"
