configuration AuditNtfsVolumne
{
    Import-DscResource -ModuleName AuditSystemDsc

    node localhost
    {
        AuditSetting AuditNtfsVolumne
        {
            Query = "SELECT * FROM Win32_LogicalDisk WHERE DriveType = '3'"
            Property = "FileSystem"
            DesiredProperty = 'NTFS'
            Operator = '-eq'          
        }
    }
}
