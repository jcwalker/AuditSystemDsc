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
