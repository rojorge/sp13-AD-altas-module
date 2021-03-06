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
        [string]$newValue,
        [Parameter(Mandatory=$False,
        ValueFromPipeline=$false,
        ValueFromPipelineByPropertyName=$True,
          HelpMessage='¿Nombre de columna que actualizar?')]
        [string]$secondaryColumnToSeekBy,
        [Parameter(Mandatory=$False,
        ValueFromPipeline=$false,
        ValueFromPipelineByPropertyName=$True,
          HelpMessage='¿Nuevo valor?')]
        [string]$secondaryUniqueValue

      )
################################################################
#############      Version 1.0       ###########################
###   git@pdihub.hi.inet:ITUSER/SP-Update-ValueOnList.git    ###
###                 Jorge Martínez Sanz                      ###
###                   Telefónica I+D                         ###
################################################################

Add-PSSnapin Microsoft.SharePoint.PowerShell -EA SilentlyContinue



################## Cogemos los datos de la lista #########

#$URL='https://colabora.tid.es/lync2013tid'
#$nameList = "Migración Usuarios"

#iniciailizar
#$itemsByGroup=@()
#$sipaddressbygroup=@()
$items=@()
#$URL='https://colabora.tid.es/lync2013tid'
#$nameList = "Migración Usuarios"

#Main

$site = Get-SPWeb $URL
$list = $site.Lists[$nameList]
$items = $list.Items
if ([string]::IsNullOrEmpty($secondaryUniqueValue)){ # si solo hay que buscar por un valor
    $objectamodificar=$items|?{$_[$columnToSeekBy] -eq $uniqueValue}
                                                       }
else {#si hay que buscar por 2 valores
    $objectamodificar=$items|?{(($_[$columnToSeekBy] -eq $uniqueValue) -and ($_[$secondaryColumnToSeekBy] -eq $secondaryUniqueValue))}
    }

if ($objectamodificar.count -gt 1) {
                                    $errorMessage="error en update-valueOnlist. Se ha encontrado mas de un elemento cuando el valor debería ser unico: $uniqueValue $secondaryColumnToSeekBy $secondaryUniqueValue mod"
                                    write-verbose $errorMessage
                                    return $errorMessage
                                    }
else {
    $objectamodificar[$columnToUpdate]=$newValue
    $objectamodificar.Update()
     }


$site.Dispose()



# ejemplo de ejecucion
#.\update-ValueOnList.ps1 -URL $site1 -nameList $nameList1 -columnToSeekby "Email" -uniqueValue "jorge1@tid.es" -columnToUpdate "Telefono" -newValue "666666601"     
  