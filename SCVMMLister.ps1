<#
.SYNOPSIS
  Showing all Cluster and VirtualMachine in cluster reading from SCVMM
.DESCRIPTION
  Connecting to SCVMM Server for loading SCVMM Module and get All Cluster and VirtualMachine
.OUTPUTS
  .Gridview
.NOTES
  Version:        1.0
  Author:         Letalys
  Creation Date:  05/04/2023
  Purpose/Change: Initial script development
#>

clear-Host
$Code = {
    Import-Module virtualmachinemanager

    $VMMServer = Get-VMMServer -ComputerName "<Your SCVMM Server>"
    $Clusters = Get-SCVMHostCluster

    $ClusteringList = [System.Collections.ArrayList]::new()

    Start-Sleep -Seconds 5 
    Foreach($Cluster in $Clusters){
        #Write-host -ForegroundColor Yellow $Cluster.ClusterName

        Foreach($PhysMachine in $($Cluster | Get-SCVMHost)){
            #Write-host -ForegroundColor green "`t"$PhysMachine.Name

            Foreach($VM in $($PhysMachine | Get-VM)){
                 #Write-host "`t`t"$VM.Name
				write-host -nonewline "."
                 $PSObject = New-Object -TypeName PSObject
                 $PSObject | Add-Member -MemberType Noteproperty -Name "Cluster" -Value $Cluster.ClusterName
                 $PSObject | Add-Member -MemberType Noteproperty -Name "MachinePhysique" -Value $PhysMachine.Name
                 $PSObject | Add-Member -MemberType Noteproperty -Name "MachinePhysiqueOS" -Value $PhysMachine.OperatingSystem
                 $PSObject | Add-Member -MemberType Noteproperty -Name "MachineVirtuelle" -Value $VM.Name
                 $PSObject | Add-Member -MemberType Noteproperty -Name "MachineVirtuelleOS" -Value $VM.OperatingSystem
                 $PSObject | Add-Member -MemberType Noteproperty -Name "MachineVirtuelleStatus" -Value $VM.VirtualMachineState
                 $ClusteringList.Add($PSObject) | Out-Null
            }
        }  
    }
    return $ClusteringList   
}

#The user account need to be Reading Administrator group.
# The server need to accept remote Powershell


Write-Host "Start Execution, retrieving data, Wait..."

$Result = Invoke-Command -ComputerName "<Your SCVMM Server>" -ScriptBlock $Code -Credential $Cred
$Result | Select-Object Cluster,MachinePhysique,MachinePhysiqueOS,MachineVirtuelle,MachineVirtuelleOS,MachineVirtuelleStatus |  Out-GridView -Title "Liste des $($Result.Count) Machines virtuelles"

write-host ""
Write-Host "Ending process"
Read-Host "Push enter to end."
