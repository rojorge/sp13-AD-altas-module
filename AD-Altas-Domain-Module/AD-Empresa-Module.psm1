<#
#TFGR

Este Modulo de powershell tienen varias funciones genericas para operar con el AD.

Las funciones son:
        get-LoginFromMail
        get-nameFromEmpresaUSER
        New-SWRandomPassword https://gallery.technet.microsoft.com/scriptcenter/Generate-a-random-and-5c879ed5#content      
        Add-EmpresaUser
        Add-UserToEmpresaGroup
        Send-customEmailFromUser Hay que definir $smtpServer(servidor de correo a usar),$emailTest (direccion de correo a enviar el mail en caso de test y $sender (email origen del correo) y añadir el cuerpo del mensaje que se quierea enviar, admite HTML para formateo el email
        add-usersFromGroupToGroup
        #TBD New-EmpresaUser
#>

function get-LoginFromMail {
    <#

    

    .Synopsis
       Generates from an email addres a string for samaccount name propuses. 
    .DESCRIPTION
       Generates from an email addres a string for samaccount name propueses. The result is the email addres without @ and domain, but if it is larger than 20 characters then it is cut to 18 characters and aded a secuncial numberb begginign from 01
    .EXAMPLE
       New-LoginFrom Mail "chiquitodelacalzadajr@handerl.com"
       chiquitodelacalzad01
    
    .OUTPUTS
       [String]
    .NOTES
       Written by Jorge Martinez, 
       I take no responsibility for any issues caused by this script.
    .FUNCTIONALITY
       Generates suitable string for a samaccountname
    

    #>
    [CmdletBinding(DefaultParameterSetName='FixedLength',ConfirmImpact='None')]
    [OutputType([String])]

     param
      (
        [Parameter(Mandatory=$True,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
        HelpMessage='¿email, please?')]
        
        [string]$email
    )

$templogin=$email.split("@")[0]
if ($templogin.Length -le 20) {$login=$templogin} #como el email es unico no puede estar repetido.
else {
     $i=1
     $continue=$true
     $templogin=$templogin.Substring(0,18)
     
     while ($continue)
     {
     if ($i -lt 10) {
                     $templogin+="0"
                     }
     $templogin+="$i"
    try{$tempuser=get-aduser $templogin
        $i+=1
        $templogin=$templogin.Substring(0,18)
        
        }
        catch 
    {
    $continue=$false
    } #catch
     
     
     

     }#end del while
      #$templogin
    
      }#else ge 20

return $templogin

#ej $userslong|%{$_.mail;$_.samaccountname;get-LoginFromMail -email $_.mail}

}# end del function

function get-nameFromEmpresaUSER {
  <#

    .Synopsis
       Generates a unic value for Display Name
    .DESCRIPTION
       With a name and a surname generates a user login NAME FIRSTNAME and if it already exits adds a secuncial number
    .EXAMPLE
       get-nameFromEmpresaUSER -name "jorge" -surname "Martinez"
       JORGE MARTINEZ
                 
    .OUTPUTS
       [String]
    .NOTES
       Written by Jorge Martinez, 
       I take no responsibility for any issues caused by this script.
    .FUNCTIONALITY
       Generates unic string suitable for a Display Name
    

    #>

 [CmdletBinding(SupportsShouldProcess=$true)]
      param
      (
        [Parameter(Mandatory=$True,
        ValueFromPipeline=$False,
        ValueFromPipelineByPropertyName=$True,
        HelpMessage='¿Nombre?')]
        $name,
        [Parameter(Mandatory=$True,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
        HelpMessage='¿Apellido/s?')]
        $surname
        )

$unicName=$name.ToUpper()+" "+$Surname.ToUpper()
$unicNameBucle=$unicName
$unico=$False
$sufix=""
$i=1
while ($unico -eq $False){    
    $userTemp=Get-ADUser -filter {name -eq $unicNameBucle}
    if ($userTemp -eq $null){
        $unico=$true
         } #end del if
    else {
        $unicNameBucle=$unicName
        $unicNameBucle+=$i
        $i+=1    
          } #end del else
        }#end del while 

return $unicNameBucle



}#end function

function New-SWRandomPassword {

    <#

    https://gallery.technet.microsoft.com/scriptcenter/Generate-a-random-and-5c879ed5#content

    .Synopsis
       Generates one or more complex passwords designed to fulfill the requirements for Active Directory
    .DESCRIPTION
       Generates one or more complex passwords designed to fulfill the requirements for Active Directory
    .EXAMPLE
       New-SWRandomPassword
       C&3SX6Kn

       Will generate one password with a length between 8  and 12 chars.
    .EXAMPLE
       New-SWRandomPassword -MinPasswordLength 8 -MaxPasswordLength 12 -Count 4
       7d&5cnaB
       !Bh776T"Fw
       9"C"RxKcY
       %mtM7#9LQ9h

       Will generate four passwords, each with a length of between 8 and 12 chars.
    .EXAMPLE
       New-SWRandomPassword -InputStrings abc, ABC, 123 -PasswordLength 4
       3ABa

       Generates a password with a length of 4 containing atleast one char from each InputString
    .EXAMPLE
       New-SWRandomPassword -InputStrings abc, ABC, 123 -PasswordLength 4 -FirstChar abcdefghijkmnpqrstuvwxyzABCEFGHJKLMNPQRSTUVWXYZ
       3ABa

       Generates a password with a length of 4 containing atleast one char from each InputString that will start with a letter from 
       the string specified with the parameter FirstChar
    .OUTPUTS
       [String]
    .NOTES
       Written by Simon Wåhlin, blog.simonw.se
       I take no responsibility for any issues caused by this script.
    .FUNCTIONALITY
       Generates random passwords
    .LINK
       http://blog.simonw.se/powershell-generating-random-password-for-active-directory/
   
    #>
    [CmdletBinding(DefaultParameterSetName='FixedLength',ConfirmImpact='None')]
    [OutputType([String])]
    Param
    (
        # Specifies minimum password length
        [Parameter(Mandatory=$false,
                   ParameterSetName='RandomLength')]
        [ValidateScript({$_ -gt 0})]
        [Alias('Min')] 
        [int]$MinPasswordLength = 8,
        
        # Specifies maximum password length
        [Parameter(Mandatory=$false,
                   ParameterSetName='RandomLength')]
        [ValidateScript({
                if($_ -ge $MinPasswordLength){$true}
                else{Throw 'Max value cannot be lesser than min value.'}})]
        [Alias('Max')]
        [int]$MaxPasswordLength = 12,

        # Specifies a fixed password length
        [Parameter(Mandatory=$false,
                   ParameterSetName='FixedLength')]
        [ValidateRange(1,2147483647)]
        [int]$PasswordLength = 8,
        
        # Specifies an array of strings containing charactergroups from which the password will be generated.
        # At least one char from each group (string) will be used.
        [String[]]$InputStrings = @('abcdefghijkmnpqrstuvwxyz', 'ABCEFGHJKLMNPQRSTUVWXYZ', '23456789', '!"#%&'),

        # Specifies a string containing a character group from which the first character in the password will be generated.
        # Useful for systems which requires first char in password to be alphabetic.
        [String] $FirstChar,
        
        # Specifies number of passwords to generate.
        [ValidateRange(1,2147483647)]
        [int]$Count = 1
    )
    Begin {
        Function Get-Seed{
            # Generate a seed for randomization
            $RandomBytes = New-Object -TypeName 'System.Byte[]' 4
            $Random = New-Object -TypeName 'System.Security.Cryptography.RNGCryptoServiceProvider'
            $Random.GetBytes($RandomBytes)
            [BitConverter]::ToUInt32($RandomBytes, 0)
        }
    }
    Process {
        For($iteration = 1;$iteration -le $Count; $iteration++){
            $Password = @{}
            # Create char arrays containing groups of possible chars
            [char[][]]$CharGroups = $InputStrings

            # Create char array containing all chars
            $AllChars = $CharGroups | ForEach-Object {[Char[]]$_}

            # Set password length
            if($PSCmdlet.ParameterSetName -eq 'RandomLength')
            {
                if($MinPasswordLength -eq $MaxPasswordLength) {
                    # If password length is set, use set length
                    $PasswordLength = $MinPasswordLength
                }
                else {
                    # Otherwise randomize password length
                    $PasswordLength = ((Get-Seed) % ($MaxPasswordLength + 1 - $MinPasswordLength)) + $MinPasswordLength
                }
            }

            # If FirstChar is defined, randomize first char in password from that string.
            if($PSBoundParameters.ContainsKey('FirstChar')){
                $Password.Add(0,$FirstChar[((Get-Seed) % $FirstChar.Length)])
            }
            # Randomize one char from each group
            Foreach($Group in $CharGroups) {
                if($Password.Count -lt $PasswordLength) {
                    $Index = Get-Seed
                    While ($Password.ContainsKey($Index)){
                        $Index = Get-Seed                        
                    }
                    $Password.Add($Index,$Group[((Get-Seed) % $Group.Count)])
                }
            }

            # Fill out with chars from $AllChars
            for($i=$Password.Count;$i -lt $PasswordLength;$i++) {
                $Index = Get-Seed
                While ($Password.ContainsKey($Index)){
                    $Index = Get-Seed                        
                }
                $Password.Add($Index,$AllChars[((Get-Seed) % $AllChars.Count)])
            }
            Write-Output -InputObject $(-join ($Password.GetEnumerator() | Sort-Object -Property Name | Select-Object -ExpandProperty Value))
        }
    }
}

function Add-EmpresaUser {
<#
    .Synopsis
       Add a user to the domain from a EMPRESA USER type Input
    
    .EXAMPLE
       Add-EmpresaUser [EMPRESA USER] $user
                        
    .OUTPUTS
       [Boolean]
    .NOTES
       Written by Jorge Martinez, 
       I take no responsibility for any issues caused by this script.
    .FUNCTIONALITY
       Add a user to the domain from a EMpresaUser type Input
#>


 [CmdletBinding(SupportsShouldProcess=$true)]
      param
      (
        [Parameter(Mandatory=$True,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
        HelpMessage='¿communities a la que tpertence')]
        $user
        )
  
$end=$true

$userprinicpalname = $user.Login + $user.Domain
$password=ConvertTo-SecureString $user.Password -AsPlainText -force
$unicName= get-nameFromEmpresaUSER -name $user.name -surname $user.surname


try {
$newUserAd=New-ADUser -SamAccountName $user.login -UserPrincipalName ($user.login+$user.domain) -AccountPassword $password -Name $unicName -Path $user.OU -DisplayName (($user.Name+" "+$user.Surname)).toUpper() -givenName $user.Name -Surname $user.Surname -Company $user.company -Enabled $True -EmailAddress $user.email -PasswordNeverExpires $True -PassThru

Set-ADUser $newUserAd -Company $user.Company
Set-ADUser $newUserAd -mobile $user.PhoneNumber

}#end del try

catch {
$end=$false
$user.ErrorMessage+="; Error en la creacion de usuarios en el AD "+ $user.login
        }# end del cacth

return $end


}

function Add-UserToEmpresaGroup {
 [CmdletBinding(SupportsShouldProcess=$true)]
      param
      (
        [Parameter(Mandatory=$True,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
        HelpMessage='¿communities a la que tpertence')]
        $user
        )

$end=$true

$tempstring=$user.ADGroupMemberShip
$grupos=@()
$i=0

while (($tempstring.substring(($tempstring.indexof(";"))+1)).contains(";"))
{

$grupos+=($tempstring.split(";")[0]).substring(0)
$tempstring=$tempstring.substring(($tempstring.indexof(";"))+1)

}
#Añado el ultimo grupo que no se ha tenido en cuenta

$grupos+=($tempstring.split(";")[0]).substring(0)



#y ahora añadimos los grupos


try {
    $grupos|%{
     $newAdGroupMember=Add-ADGroupMember $_ $user.login
     #remove-ADGroupMember $_ $user.login
         } #end del for
     }#end del try
    
catch{
    $end=$false
    $user.ErrorMessage+="; Error en la addicion del usuarios al grupo de AD " + $user.login
       }#end del catch



return $end

} #end del function

function Send-customEmailFromUser {

    <#

    .Synopsis
       send a custom email to a user
    .DESCRIPTION
       This function builds a custom email to send the user OR password
       $smtpServer,$sender and $emailTest must be defined
       $userEmailBody, $passwordEmailBody must be defined and HTML could be used for it.
              

    .EXAMPLE
       Send-customEmailFromUser -user [EMPRESA USER] -emailType [String] -test [Boolean]
       
    .OUTPUTS
       [String]
    .NOTES
       Written by Jorge Martinez, 
       I take no responsibility for any issues caused by this script.
    .FUNCTIONALITY
       Generates suitable string for a samaccountname
    

    #>



 [CmdletBinding(SupportsShouldProcess=$true)]
      param
      (
        [Parameter(Mandatory=$True,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
        HelpMessage='Usuario de tipo [EMPRESA USER]')]
        $user,
        [Parameter(Mandatory=$True,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
        HelpMessage='Password o Login')]
        $emailType,
        [Parameter(Mandatory=$True,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
        HelpMessage='¿es una prueba?')]
        [Boolean]$test

        )

$nombreUser=(($user.name)+" "+($user.surname)).toUpper()
$domainLoginMode=((($user.domain).split("@")[1]).split(".")[0]).toUpper()
$usuarioUser=$domainLoginMode+'\'+$user.login
$passwordUser=$user.password
$smtpServer=""
$sender=""
$emailTest=""




if ($emailType -eq "Login"){
$subject =@"
    Bienvenido 
"@   
$body = @"
<html>


</html>


"@


}#end del if Login

if ($emailType -eq "Password"){
$body = @"
<html>


</html>

"@
$subject=@"
   Información de acceso /  Informações de acesso / Access information
"@
}# end del if Password

if ($test){$mailuser=$emailTest}
else {$mailUser=$user.email}
write-verbose $mailuser

###############################


write-verbose $mailuser

################################

$MailMessage = @{
    To =$mailUser
    From = $sender
    Subject =$subject   
    Body =$body
    Smtpserver = $smtpServer
    BodyAsHtml = $true
    ErrorAction = "SilentlyContinue"
    encoding = [System.Text.Encoding]::UTF8
   
    }
 
Send-MailMessage @MailMessage
}

function add-usersFromGroupToGroup{

    <#

    .Synopsis
       Copy users from a domain group to another domain group
    .DESCRIPTION
       This function copy al the users in an existing domain group to another exsiting domain group
       
              

    .EXAMPLE
       add-usersFromGroupToGroup "grupo1","grupo2"
       
    .OUTPUTS
       None
    .NOTES
       Written by Jorge Martinez, 
       
    .FUNCTIONALITY
       Generates suitable string for a samaccountname
    
    #>

[CmdletBinding(SupportsShouldProcess=$true)]
      param
      (
      $grupoOrigen,
      $grupoDestino
      )


$usuarios=Get-ADGroupMember $grupoOrigen
$count=$usuarios.count
$diezPorCienDeCount=($count/10)
$i=10
$j=1
write-host $count
$usuarios|%{Add-ADGroupMember -Identity $grupoDestino -Members $_.samaccountname;$count-=1;if(($count/$diezPorCienDeCount) -eq (10-$j)){write-host $i;$j+=1;$i+=10}}
}




