#####################################################
# 
#  Install Solr 6.6.2 Docker Container
# 
#####################################################

[CmdletBinding()]
param(
    [switch] $remove
)

$ErrorActionPreference = 'Stop'

. $PSScriptRoot\settings.ps1

if (Get-Module("solr")) {
    Remove-Module "solr"
}
Import-Module "$SolrDockerPath\solr.psm1" -Verbose

function Install-SolrDocker {
    try {
        Install-Solr -DockerComposeFile $DockerComposeFile -SolrDataRootPath $SolrRoot
        Install-SolrCertificate -DockerContainer $DockerContainer `
                            -KeystoreFile $KeystoreFile `
                            -KeystorePassword $KeystorePassword `
                            -P12Path $P12KeystoreFile
    }
    catch {
        write-host "Caught an exception:" -ForegroundColor Red
        write-host "Exception Type: $($_.Exception.GetType().FullName)" -ForegroundColor Red
        write-host "Exception Message: $($_.Exception.Message)" -ForegroundColor Red
    }
    
}

if ($remove) {
    Write-Host "*******************************************************" -ForegroundColor Green
    Write-Host " Uninstalling Solr" -ForegroundColor Green
    Uninstall-Solr -DockerComposeFile $DockerComposeFile `
                    -SolrDataRoot $SolrRoot `
                    -P12KeystoreFile $P12KeystoreFile `
                    -KeystorePassword $KeystorePassword
    Write-Host "** Finish un-installing Solr *****************************" -ForegroundColor Green
} else {
    Write-Host "*******************************************************" -ForegroundColor Green
    Write-Host " Installing Solr" -ForegroundColor Green

    Install-SolrDocker

    Write-Host "** Finish installing Solr *****************************" -ForegroundColor Green
}