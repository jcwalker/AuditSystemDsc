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
