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
