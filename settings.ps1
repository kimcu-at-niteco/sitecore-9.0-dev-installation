# Solution parameters
$SolutionPrefix = "SC90"
$SitePostFix = "dev.local"
$webroot = "D:\inetpub\wwwroot"

#$SitecoreVersion = "9.0.0 rev. 171002"
$SitecoreVersion = "9.0.1 rev. 171219"
$InstallerVersion = "1.1.0"

# Assets and prerequisites
$AssetsRoot = "$PSScriptRoot\build\assets"
$AssetsPSRepository = "https://sitecore.myget.org/F/sc-powershell/api/v2/"
$AssetsPSRepositoryName = "SitecoreGallery"

$LicenseFile = "$AssetsRoot\license.xml"

# Certificates
$CertPath = Join-Path "$AssetsRoot" "Certificates"

# SQL Parameters
$SqlServer = "localhost"
$SqlAdminUser = "sa"
$SqlAdminPassword = "Niteco@2017"

# XConnect Parameters
$XConnectConfiguration = "$AssetsRoot\xconnect-xp0.json"
$XConnectCertificateConfiguration = "$AssetsRoot\xconnect-createcert.json"
$XConnectSolrConfiguration = "$AssetsRoot\xconnect-solr.json"
$XConnectPackage = "$AssetsRoot\Sitecore $SitecoreVersion (OnPrem)_xp0xconnect.scwdp.zip"
$XConnectSiteName = "${SolutionPrefix}_xconnect.$SitePostFix"
$XConnectCert = "$SolutionPrefix.$SitePostFix.xConnect.Client"
$XConnectSiteRoot = Join-Path $webroot -ChildPath $XConnectSiteName
$XConnectSqlCollectionUser = "collectionuser"
$XConnectSqlCollectionPassword = "Test12345"

# Sitecore Parameters
$SitecoreSolrConfiguration = "$AssetsRoot\sitecore-solr.json"
$SitecoreConfiguration = "$AssetsRoot\sitecore-xp0.json"
$SitecoreSSLConfiguration = "$PSScriptRoot\build\certificates\sitecore-ssl.json"
$SitecorePackage = "$AssetsRoot\Sitecore $SitecoreVersion (OnPrem)_single.scwdp.zip"
$SitecoreSiteName = "$SolutionPrefix.$SitePostFix"
$SitecoreSiteRoot = Join-Path $webroot -ChildPath $SitecoreSiteName

#Solr Docker
$SolrDockerPath = "$PSScriptRoot\build\SolrDocker"
$DockerComposeFile = Join-Path $SolrDockerPath "docker-compose.yml"
$DockerContainer = "SC90-Solr-662"
$KeystoreFile= "solr-ssl.keystore.jks"
$P12KeystoreFile= "$PSScriptRoot\build\SolrDocker\solr-ssl.keystore.p12"
$KeystorePassword= "secret"

# Solr Parameters
$SolrUrl = "https://localhost:8983/solr"
#$SolrRoot = "D:\\_sitecore-dev\\SolrData"
$SolrRoot = "$PSScriptRoot\\build\\SolrDocker\\SolrData"