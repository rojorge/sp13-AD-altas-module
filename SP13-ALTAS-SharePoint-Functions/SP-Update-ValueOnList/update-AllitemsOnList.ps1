 [CmdletBinding(SupportsShouldProcess=$true)]
      param
      (
      
        [Parameter(Mandatory=$True,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
        HelpMessage='¿Url del site?')]
        $URL,
        [Parameter(Mandatory=$True,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
        HelpMessage='¿Nombre de la lista?')]
        $nameList,
        [Parameter(Mandatory=$True,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
          HelpMessage='¿Nombre de la columana por la que buscar?')]
        $columnToSeekby,
        [Parameter(Mandatory=$True,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
          HelpMessage='¿Valor por el que buscar?')]
        $uniqueValue,
        [Parameter(Mandatory=$True,
        ValueFromPipeline=$false,
        ValueFromPipelineByPropertyName=$True,
          HelpMessage='¿Nombre de columna que actualizar?')]
        [string]$columnToUpdate,
        [Parameter(Mandatory=$True,
        ValueFromPipeline=$false,
        ValueFromPipelineByPropertyName=$True,
          HelpMessage='¿Nuevo valor?')]
        [string]$newValue
        


      )

#TFGR


<#
.Synopsis
  Update all the items that match with a criteria
  
.DESCRIPTION
  This script is used to update all the items in a SharePoin list that matchs a criteria.
  Value to seek by,the column where it has to be macthed, column to update and new value for this column are provided

.EXAMPLE
 C:\Scripts\SP13-ALTAS-SharePoint-Functions\SP-Update-ValueOnList\update-AllitemsOnList.ps1 -URL $URL -nameList $nameList -columnToSeekby "Email" -uniqueValue $_.email -columnToUpdate "estado" -newValue "error"
 

.INPUTS
    Site or subsite URL where the list is
    Name of the list
    Column where the items have to be filtered
    Value to look for
    Column to update
    Value to update this column
    
.OUTPUTS
  $null

.NOTES  
    Written by Jorge Martinez, 
    I take no responsibility for any issues caused by this script.
.FUNCTIONALITY
    Update all the items that match with a criteria in a sharepont list
    
.REPOSITORY
    https://github.com/rojorge/SP13-ALTAS-SharePoint-Functions
    
#>

Add-PSSnapin Microsoft.SharePoint.PowerShell -EA SilentlyContinue

#Incializamos las variables

$items=@()

### MAIN ###
#Accedemos al site
$site = Get-SPWeb $URL

#cogemos la lista
$list = $site.Lists[$nameList]

#cogemos los elementos de la lista
$items = $list.Items

#Filtramos los elementos que tenemos que actualizar
$objectsToModify=$items|?{$_[$columnToSeekBy] -eq $uniqueValue}

#Actualizamos los elementos
$objectsToModify|%{
    $_[$columnToUpdate]=$newValue
    $_.Update()
    }                                                       


$site.Dispose()






  