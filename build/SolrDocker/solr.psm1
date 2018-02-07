
function Install-Solr {
    param(
        [string] $DockerComposeFile,
        [string] $SolrDataRootPath
    )

    If(!(Test-Path $SolrDataRootPath))
    {
        New-Item -ItemType Directory -Force -Path $SolrDataRootPath
    }

    & docker-compose --file $DockerComposeFile up -d --build
}

function Get-KeyTool {
    try {
        $path = $Env:JAVA_HOME + '\keytool.exe'
        Write-Host $path
        if (Test-Path $path) {
            $keytool = (Get-Command $path).Source
        }
    } catch {
        $keytool = Read-Host "keytool.exe not on path. Enter path to keytool (found in JRE bin folder)"

        if([string]::IsNullOrEmpty($keytool) -or -not (Test-Path $keytool)) {
            Write-Error "Keytool path was invalid."
        }
    }

    return $keytool
}

function Uninstall-Solr {
    param(
        [string] $DockerComposeFile,
        [string] $SolrDataRoot,
        [string] $P12KeystoreFile,
        [string] $KeystorePassword
    )
    Write-Host "Remove the container of Solr in Docker."
    & docker-compose --file $DockerComposeFile down

    Write-Host "Remove the Solr Data"
    If((Test-Path $SolrDataRoot))
    {
        Remove-Item -Path $SolrDataRoot -Force -Recurse
    }

    #Remove certificate from KeyStore
    Write-Host "Remove certificate from KeyStore."
    $certPath = Join-Path $PSScriptRoot $P12KeystoreFile
    Write-Host $certPath
    $keytool = Get-KeyTool
    & $keytool -delete -alias "solr-ssl" -storetype JKS -keystore $P12KeystoreFile -storepass $KeystorePassword
    

    #Remove ssl certificates
    Write-Host ''
    Write-Host 'Removing Solr-SSl Certificate from CA'
    Get-ChildItem -Path "Cert:\LocalMachine\Root" | Where-Object -Property FriendlyName -eq "solr-ssl" | Remove-Item
    Write-Host 'Remove Solr-SSl Certificate from CA successfully'
}

function Remove-P12File {
    param(
        [string] $P12KeyStoreFile
    )
    
    if((Test-Path $P12Path)) {
        Write-Host "Removing $P12Path..."
        Remove-Item $P12Path
    }
}

function Install-SolrCertificate {
    param(
        [string] $DockerContainer,
        [string] $KeystoreFile,
        [string] $KeystorePassword,
        [string] $P12Path
    )

    Write-Host ""
    Write-Host "Removing the current .p12 key to generate the new one......."
    Remove-P12File -P12KeyStoreFile $P12Path
    Write-Host "Removed successful `'$P12Path`'"

    Write-Host ''
    Write-Host 'get cert from docker container'
    # get cert from docker container
    # cert location in docker: /opt/solr/server/etc/solr-ssl.keystore.jks
    $dockerPath = $("$DockerContainer`:/opt/solr/server/etc/$KeystoreFile")
    Write-Host "First arg: $dockerPath"
    & docker cp $dockerPath $PSScriptRoot
    $certPath = Join-Path $PSScriptRoot $KeystoreFile
    if (Test-Path $certPath){
        Write-Host "Cert `'$certPath`' has been copied successfully."
    }
    else {
        Write-Host "Cannot find cert at location `'$certPath`'"
    }

    Write-Host ''
    Write-Host 'Generating .p12 to import to Windows...'
    $keytool = Get-KeyTool
    & $keytool -importkeystore -srckeystore $certPath -destkeystore $P12Path -srcstoretype jks -deststoretype pkcs12 -srcstorepass $KeystorePassword -deststorepass $KeystorePassword

    Write-Host ''
    Write-Host 'Trusting generated SSL certificate...'
    Write-Verbose "Installing cert `'$P12Path`'"
    $secureStringKeystorePassword = ConvertTo-SecureString -String $KeystorePassword -Force -AsPlainText
    $root = Import-PfxCertificate -FilePath $P12Path -Password $secureStringKeystorePassword -CertStoreLocation Cert:\LocalMachine\Root
    Write-Host "Solr SSL certificate was imported from docker container `'$DockerContainer`' and is now locally trusted. (added as root CA)"
}

function Remove-SitecoreSolrCore {
    param(
        [string] $SolrUrl,
        [string] $SolutionPrefix
    )

    $indexes =  "${SolutionPrefix}_core_index",
                "${SolutionPrefix}_master_index",
                "${SolutionPrefix}_web_index",
                "${SolutionPrefix}_marketingdefinitions_master",
                "${SolutionPrefix}_marketingdefinitions_web",
                "${SolutionPrefix}_marketing_asset_index_master",
                "${SolutionPrefix}_marketing_asset_index_web",
                "${SolutionPrefix}_testing_index",
                "${SolutionPrefix}_suggested_test_index",
                "${SolutionPrefix}_fxm_master_index",
                "${SolutionPrefix}_fxm_web_index",
                "${SolutionPrefix}_xdb",
                "${SolutionPrefix}_xdb_rebuild"

    $Action = "UNLOAD"
    Write-Host "Removing Sitecore Solr Cores..................."
    foreach($core in $indexes){
        $uriParameters = "core=$core"
        Write-Host "Removing $core"
        $uri = "$SolrUrl/admin/cores?action=$Action&$uriParameters&deleteInstanceDir=true"
        $SolrRequest = [System.Net.WebRequest]::Create($uri)
        $SolrResponse = $SolrRequest.GetResponse()
        try {
            If ($SolrResponse.StatusCode -ne 200) {
                throw "Could not contact Solr on '$SolrUrl'. Response status was '$SolrResponse.StatusCode'"
            }
        }
        finally {
            $SolrResponse.Close()
        }
    }
    Write-Host "Removed successfully Sitecore Solr Cores."

}