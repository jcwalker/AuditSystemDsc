<#PSScriptInfo
.VERSION 1.0.0
.GUID 0ea958da-bb97-41c6-a76f-9125930e72b3
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
configuration AuditSetting_AuditUsersPasswordNotRequiredConfig
{
    Import-DscResource -ModuleName AuditSystemDsc

    node localhost
    {
        AuditSetting LocalAccountWithoutPassword
        {
            Query = "SELECT * FROM Win32_UserAccount WHERE Disabled = $false"
            Property = "PasswordRequired"
            DesiredValue = $true
            Operator = '-eq'
        }
    }
}
