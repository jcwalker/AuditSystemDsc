#region HEADER
$script:dscModuleName = 'AuditSystemDsc'
$script:dscResourceName = 'AuditSetting'

# Unit Test Template Version: 1.2.4
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone', 'https://github.com/PowerShell/DscResource.Tests.git', (Join-Path -Path $script:moduleRoot -ChildPath 'DscResource.Tests'))
}

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'DSCResource.Tests' -ChildPath 'TestHelper.psm1')) -Force

$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:dscModuleName `
    -DSCResourceName $script:dscResourceName `
    -ResourceType 'Mof' `
    -TestType Unit

#endregion HEADER

function Invoke-TestCleanup
{
    Restore-TestEnvironment -TestEnvironment $TestEnvironment

    # TODO: Other Optional Cleanup Code Goes Here...
}

# Begin Testing
try
{
    InModuleScope $script:dscResourceName {
        Describe 'AuditSetting\Get-TargetResource' -Tag 'Get' {
            BeforeAll {
                $parameters = @{
                    Query = 'SELECT * FROM Win32_ClassName'
                    Property = 'Property1'
                    DesiredValue = 'InDesiredState'
                    Operator = '-eq'
                }
            }

            Context 'When the system is in the desired state' {
                BeforeAll {
                    Mock -CommandName Get-CimInstance
                }
 
                It 'Should return a hashtable' {
                    $getTargetResourceResult = Get-TargetResource @parameters
                    {$getTargetResourceResult -is [hashtable]} | Should -Be $true

                    Assert-MockCalled -CommandName Get-CimInstance -Exactly -Times 1 -Scope It
                }
        }
        }

        Describe 'AuditSetting\Test-TargetResource' -Tag 'Test' {
            BeforeAll {
                $parameters = @{
                    Query = 'SELECT * FROM Win32_ClassName'
                    Property = 'Property1'
                    DesiredValue = 'InDesiredState'
                    Operator = '-eq'
                }
            }

            Context 'When the system is in the desired state' {
                Mock Write-PropertyValue
                Mock Get-CimInstance -MockWith {
                    [PSCustomObject]@{
                        Property1 = $parameters.DesiredValue
                    }
                }

                It 'Should return TRUE' {
                    $testTargetResourceResult = Test-TargetResource @parameters
                    $testTargetResourceResult | Should -Be $true

                    Assert-MockCalled -CommandName Get-CimInstance -Exactly -Times 1 -Scope It
                    Assert-MockCalled -CommandName Write-PropertyValue -Exactly -Times 0 -Scope It
                }
            }

            Context 'When the system is not in the desired state' {
                Mock Write-PropertyValue -MockWith {"'Property1 = 'NotInDesiredState'"}
                Mock Get-CimInstance -MockWith {
                    [PSCustomObject]@{
                        Property1 = 'NotInDesiredState'
                    }
                }

                It 'Should return FALSE' {
                    $testTargetResourceResult = Test-TargetResource @parameters
                    $testTargetResourceResult | Should -Be $false

                    Assert-MockCalled -CommandName Get-CimInstance -Exactly -Times 1 -Scope It
                    Assert-MockCalled -CommandName Write-PropertyValue -Exactly -Times 1 -Scope It
                }
            }

            Context 'When the Query is invalid' {
                Mock Get-CimInstance -MockWith {throw}
                Mock Write-PropertyValue
                Mock Write-Warning

                It 'Should call Write-Warning' {
                    $testTargetResourceResult = Test-TargetResource @parameters

                    Assert-MockCalled -CommandName Get-CimInstance -Exactly -Times 1 -Scope It
                    Assert-MockCalled -CommandName Write-PropertyValue -Exactly -Times 0 -Scope It
                    Assert-MockCalled -CommandName Write-Warning -Exactly -Times 1 -Scope It
                }
            }
        }

        Describe 'AuditSetting\Write-PropertyValue' -Tag 'Helper' {
            $writeWarningParameters = @{
                Object = @(
                    [PSCustomObject]@{
                        Property1 = 'Value1'
                    }
                    [PSCustomObject]@{
                        Property2 = 'Value2'
                    }
                )
            }
            It 'Should return the correct strings' {
                $result = Write-PropertyValue @writeWarningParameters

                "Property1: Value1" | Should -BeIn $result
                "Property2: Value2" | Should -BeIn $result
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
