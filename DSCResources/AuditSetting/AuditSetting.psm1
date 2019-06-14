$script:resourceModulePath = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$script:modulesFolderPath = Join-Path -Path $script:resourceModulePath -ChildPath 'Modules'

$script:resourceHelperModulePath = Join-Path -Path $script:modulesFolderPath -ChildPath 'AuditSystemDsc.Common'
Import-Module -Name (Join-Path -Path $script:resourceHelperModulePath -ChildPath 'AuditSystemDsc.Common.psm1')

$script:localizedData = Get-LocalizedData -ResourceName 'AuditSetting'

<#
    .SYNOPSIS
        Retrieves the current state of the setting being audited.
    .PARAMETER Query
        A WQL query used to retrieve the setting to be audited.
    .PARAMETER Property
        The property name to be audited.
        Not used in Get-TargetResource.
    .PARAMETER Operator
        The comparison operator used to craft the condition that defines compliance.
        Not used in Get-TargetResource.
    .PARAMETER DesiredValue
        Specifies the desired value of the property being audited.
        Not used in Get-TargetResource.
#>
function Get-TargetResource
{
    [OutputType([System.Collections.Hashtable])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [string]
        $Query,

        [Parameter(Mandatory=$true)]
        [string]
        $Property,

        [Parameter(Mandatory=$true)]
        [string]
        $Operator,

        [Parameter(Mandatory=$true)]
        [string]
        $DesiredValue
    )

    $queryResult = Get-CimInstance -Query $Query

    return @{
        Query = $Query
        Property = $Property
        Operator = $Operator
        DesiredValue = $DesiredValue
        ResultString = $(Write-PropertyValue -Object $queryResult)
    }
}

<#
    .SYNOPSIS
        This function is not used in the auditing process.
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Query,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Property,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Operator,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DesiredValue
    )

}

<#
    .SYNOPSIS
        Determines if the setting being audited is compliant.
    .PARAMETER Query
        A WQL query used to retrieve the setting to be audited.
    .PARAMETER Property
        The property name to be audited.
    .PARAMETER Operator
        The comparison operator used to craft the condition that defines compliance.
    .PARAMETER DesiredValue
        Specifies the desired value of the property being audited.
#>
function Test-TargetResource
{
    [OutputType([System.Boolean])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [string]
        $Query,

        [Parameter(Mandatory=$true)]
        [string]
        $Property,

        [Parameter(Mandatory=$true)]
        [string]
        $Operator,

        [Parameter(Mandatory=$true)]
        [string]
        $DesiredValue
    )

    try
    {
        $result = $true
        $queryResult = Get-CimInstance -Query $Query -ErrorAction Stop

        foreach ($instance in $queryResult)
        {
            $condition = "'$DesiredValue' $Operator '$($instance.$Property)'"
            $isCompliant = [scriptBlock]::Create($condition).Invoke()

            if ([bool]$isCompliant -eq $false)
            {
                Write-Verbose -Message ($localizedData.NotInDesiredState -f $Property, $condition)
                foreach ($propertyItem in $(Write-PropertyValue $instance))
                {
                    Write-Verbose -Message $propertyItem
                }
                $result = $false
            }
        }
        return $result
    }
    catch
    {
        Write-Warning -Message $PSItem
        return $false
    }
}

<#
    .SYNOPSIS
        Displays the properties and values in a string array of an object.
    .PARAMETER Object
        The object that contains the pproperties and values to be displayed.
#>
function Write-PropertyValue
{
    [OutputType([System.String])]
    [CmdletBinding()]
    param
    (
        [object[]]
        $Object
    )

    foreach ($instance in $Object)
    {
        $propertyNames = $instance | Get-Member -MemberType Properties

        foreach ($propertyName in $propertyNames.Name)
        {
            if ([string]::IsNullOrWhiteSpace($instance.$propertyName) -eq $false)
            {
                "$propertyName`: $(([string]$instance.$propertyName).Trim())"
            }
        }
    }
}

Export-ModuleMember -Function 'Get-TargetResource','Set-TargetResource','Test-TargetResource'
