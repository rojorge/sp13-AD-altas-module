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
        $valueToSeekBy,
        [Parameter(Mandatory=$True,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
        HelpMessage='¿Valor por el que buscar?')]
        $userAdmin
      )

#TFGR

<#
.Synopsis
  Reads a sharepoint list and returns all the elements that match the used criteria
  
.DESCRIPTION
  This script is used to obtain all the elements that matchs a criteria.
  Value to seek by and the column where it has to be macthed are provided

.EXAMPLE
  C:\Admon\SP13-ALTAS-SharePoint-Functions\sp-get-ItemsFromList\get-ItemsFromList.ps1 -URL $URL -nameList $nameList -columnToSeekby $columnToSeekBy -valueToSeekBy $valueToSeekBy -userAdmin $userAdmin

.INPUTS
    Site or subsite URL where the list is
    Name of the list
    The column where the items have to be filtered
    The value to look for.
    
.OUTPUTS
  [SPLIstItem]LIst

.NOTES  
    Written by Jorge Martinez, 
    I take no responsibility for any issues caused by this script.
.FUNCTIONALITY
    Reads a sharepoint list and returns all the elements that match the used criteria
    
.REPOSITORY
    https://github.com/rojorge/SP13-ALTAS-SharePoint-Functions
    
#>


Add-PSSnapin Microsoft.SharePoint.PowerShell -EA SilentlyContinue

# Inicialización
$web=@()
$list=@()
$items=@()
$itemsToReturn=@()


$web=get-spweb -Identity $URL

#Obtnemos la URL de la Web Application
$wa=$web.url.split("/")[0]+"//"+$web.url.split("/")[2]

#Obtenemos la WebApplication para poder habilitar el acceso con la identidad pasada por credenciales y asi poder ejecutar cmdlets sobre objetos que necesiten esas credenciales delegadas.
$siteID = Get-SPWebApplication -Identity $WA
$siteID.GrantAccessToProcessIdentity($userAdmin) 

#Cogemos la lista, esto neceista haber habilitado el acceso con credenciales delegadas
$list = $web.Lists[$nameList]

#cogemos todos los elementos
$items = $list.Items

# los filtramos
$itemsToReturn=$items|?{$_[$columnToSeekBy] -eq $valueToSeekBy}

# devolvemos el resultado
return $itemsToReturn

