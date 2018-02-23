## Install Sitecore 9.0 in Development
### Description
- This repository aims to setup the instance of Sitecore 9.0 automatically by utilize some resources or technologies
    - Docker: use to install Solr 6.6.2 with mapping volumn technique
    - Auto installation script from [Habitat](https://github.com/Sitecore/Habitat/tree/feature/v9)

### Prerequisite
1. [Docker for Windows](https://www.docker.com/docker-windows)
2. [Sitecore Experience Platform 9.0 Initial Release] (https://dev.sitecore.net/Downloads/Sitecore_Experience_Platform/90/Sitecore_Experience_Platform_90_Initial_Release.aspx)
3. Window PowerShell

### Before run the installation
1- Extract *Sitecore 9.0.0 rev. 171002 (WDP XP0 packages).zip* package.
2- Extract *XP0 Configuration files rev.171002.zip* which are *.json files. Those files are configuration need for running Sitecore Install Framework
3- Thereafter, copy the folling files to *build\assests*
    - Sitecore 9.0.0 rev. 171002 (OnPrem)_single.scwdp.zip
    - Sitecore 9.0.0 rev. 171002 (OnPrem)_xp0xconnect.scwdp.zip
    - All *.json files from step 2.
4- Next, it need to copy the Sitecore license file to *build\assests* as well.
5- *[Important]* - Because we are using docker for Solr within volumn mapping technique, hence we have to change some configurations to adapt with our choice
5.1- Remove or Comment-Out the *StopSolr* and *StartSolr* sections in the following files
- *sitecore-solr.json*:
    - *StopSolr* section: line #118 -> #126
    - *StartSolr* section: line #197 -> #205
- *xconnect-solr.json*:
    - *StopSolr* section: line #70 -> #78
    - *StartSolr* section: line #97 -> #105
5.2- Change the path of the *Solr.Server* folder in the following files
- *sitecore-solr.json*:
    > #Line 50: "Solr.Server":      "[variable('Solr.FullRoot')]",
    
- *xconnect-solr.json*:
    > #Line 50: "Solr.Server":      "[variable('Solr.FullRoot')]",

*_Notes:_*
As default, *Solr.Server* should be the *Solr.FullRoot/server/solr*, in which *Solr.FullRoot* is the physical path that the Solr was installed.

6- The last thing is modify the following files  by comment out or remove completely (whatever you want :D) the *StopSolr* and *StartSolr* sections. It can be found at:
- *sitecore-solr.json*:
    - *StopSolr* section: line #118 -> #126
    - *StartSolr* section: line #197 -> #205
- *xconnect-solr.json*:
    - *StopSolr* section: line #70 -> #78
    - *StartSolr* section: line #97 -> #105

### Configurations
Mostly, the configuration has been declared in *settings.ps1*. Therefore, it's important to note that before going to run the install scripts, it have to change the configuration values to match with our machine.

#### Required to change
1- SQL Server account
- $SqlServer
- $SqlAdminUser
- SqlAdminPassword

#### Optional
1- The *webroot* is not at _C:/Inetpub/wwwroor_. Suppose that is _D:/Inetpub/wwwroot_. It needs to change in the following files
- *build/assets/sitecore-XP0.json*: 
    - Default from Sitecore
    > "Site.PhysicalPath": "[joinpath(environment('SystemDrive'), 'inetpub', 'wwwroot', parameter('SiteName'))]", # Line#208 => C:/inetpub/wwwroot
    - Our change
    > "Site.PhysicalPath": "[joinpath('D:', 'inetpub', 'wwwroot', parameter('SiteName'))]", # => D:/inetpub/wwwroot
- *build/assets/xconnect-xp0.json*: 
    - Default from Sitecore
    > "Site.PhysicalPath": "[joinpath(environment('SystemDrive'), 'inetpub', 'wwwroot', parameter('SiteName'))]", # Line#136 => C:/inetpub/wwwroot
    - Our change
    > "Site.PhysicalPath": "[joinpath('D:', 'inetpub', 'wwwroot', parameter('SiteName'))]", # => D:/inetpub/wwwroot
- *settings.ps1*: change the value of *$webroot* variable to _D:\inetpub\wwwroot_


### Let our hand dirty
1. Install Solr via Docker
- Use the PowerShell Window, execute the script by this command
> .\install-solr.ps1
2. Install Sitecore 9.0 and their stuffs
- Use the PowerShell Window, execute the script by this command
> .\install-xp0.ps1

### Extra => Uninstall SC9.0 instance
1. Uninstall Sitecore 9.0
- Use the PowerShell Window, execute the script by this command
> .\uninstall-xp0.ps1

2. Uninstall Solr via docker
- Use the PowerShell Window, execute the script by this command
> .\install-solr.ps1 -remove