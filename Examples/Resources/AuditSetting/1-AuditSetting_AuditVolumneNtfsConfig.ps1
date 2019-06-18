<#PSScriptInfo
.VERSION 1.0.0
.GUID dfbc4888-efec-4229-a2b6-fe6a25012e61
.AUTHOR Jason Walker
.COMPANYNAME
.COPYRIGHT (c) 2019 Jason Walker. All rights reserved.
.TAGS DSCConfiguration
.LICENSEURI https://github.com/jcwalker/AuditSystemDsc/blob/dev/LICENSE
.PROJECTURI https://github.com/jcwalker/AuditSystemDsc/
.ICONURI
.EXTERNALMODULEDEPENDENCIES
.REQUIREDSCRIPTS
.EXTERNALSCRIPTDEPENDENCIES
.RELEASENOTES First version.
.PRIVATEDATA
#>

#Requires -module FileContentDsc

<#
    .DESCRIPTION
    Set the `Level` entry in the [Logging] section to `Information`
    in the file `c:\myapp\myapp.ini`.
#>
Configuration IniSettingsFile_SetPlainTextEntry_Config
{
    Import-DSCResource -ModuleName FileContentDsc

    Node localhost
    {
        IniSettingsFile SetLogging
        {
            Path    = 'c:\myapp\myapp.ini'
            Section = 'Logging'
            Key     = 'Level'
            Text    = 'Information'
        }
    }
}
configuration AuditSetting_AuditVolumneNtfsConfig
{
    Import-DscResource -ModuleName AuditSystemDsc

    node localhost
    {
        AuditSetting AuditNtfsVolumne
        {
            Query = "SELECT * FROM Win32_LogicalDisk WHERE DriveType = '3'"
            Property = "FileSystem"
            DesiredValue = 'NTFS'
            Operator = '-eq'
        }
    }
}
