
[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)] $DockerComposeFile = "./build/SolrDocker/docker-compose.yml",
    [Parameter(Mandatory=$false)] $DockerContainer = "SC90-Solr-662",
    [Parameter(Mandatory=$false)] $KeystoreFile='solr-ssl.keystore.jks',
    [Parameter(Mandatory=$false)] $P12KeystoreFile='solr-ssl.keystore.p12',
    [Parameter(Mandatory=$false)] $KeystorePassword='secret',
    [switch] $UnInstallSolr
)

Import-Module .\build\SolrDocker\solr.psm1 -Verbose

$SolrBuildPath = "./build/SolrDocker/"
$P12KeystoreFile = Join-Path $SolrBuildPath $P12KeystoreFile

if ($UnInstallSolr) {
    Write-Host "*******************************************************" -ForegroundColor Green
    Write-Host " Uninstalling Solr" -ForegroundColor Green
    Uninstall-Solr -DockerComposeFile $DockerComposeFile `
                    -P12KeystoreFile $P12KeystoreFile `
                    -KeystorePassword $KeystorePassword
    Write-Host "*******************************************************" -ForegroundColor Green
} else {
    Write-Host "*******************************************************" -ForegroundColor Green
    Write-Host " Installing Solr" -ForegroundColor Green
    Install-Solr -DockerComposeFile $DockerComposeFile 
    Install-SolrCertificate -DockerContainer $DockerContainer `
                            -KeystoreFile $KeystoreFile `
                            -KeystorePassword $KeystorePassword `
                            -P12Path $P12KeystoreFile
    Write-Host "*******************************************************" -ForegroundColor Green
}