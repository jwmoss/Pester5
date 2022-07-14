function Invoke-IntegrationTest {
    <#
    .SYNOPSIS
        Wrapper around a few pester features for pester 5
    .DESCRIPTION
        Wrapper around Pester that incorporates passing in a data file.
    .NOTES
        This function drives integration with Pester 5.
    .LINK
        Specify a URI to a help page, this will show when Get-Help -Online is used.
    .EXAMPLE
        Invoke-IntegrationTest -WorkEnvironment Prod -TestSuite Proxy
        Starts Pester and runs just the proxy tests against prod environment
    #>
    [CmdletBinding()]
    param (
        [ValidateSet(
            "Website",
            "Code"
        )]
        [String]
        $TestSuite,

        [String]
        $File = "/Users/jwmoss/Github/Pester5/airport.json",

        [String]
        $Tests = "/Users/jwmoss/Github/Pester5/integration.tests.ps1",

        [Switch]
        $CI
    )
    
    ## Store the container in a variable
    ## Pass in a json file that contains data, such as paths to HTTP endpoints for whatever work environment is selected
    $Container = New-PesterContainer -Path $Tests -Data @{ 
        File = $File
    }
    
    ## Build a pester configuration
    $config = New-PesterConfiguration

    ## If a specific test suite is requested, define the tag using the .filter.tag option with pester configuration
    if ($TestSuite) {
        $config.Filter.Tag = $testSuite
    }

    ## If running in CI, output as Nunit.xml 
    if ($CI) {
        if (Test-Path "airport.xml") {
            Remove-Item -Path "airport.xml" -Force
        }
        $config.TestResult.OutputFormat = "NUnitXML"
        $config.TestResult.OutputPath = "airport.xml"
        $config.TestResult.Enabled = $true
        $config.Run.Container = $Container
        $config.Run.Exit = $true
        Invoke-Pester -Configuration $Config
    }

    ## If not running in CI, then output
    else {
        $config.Run.Container = $Container
        $config.Output.Verbosity = "Detailed"
        Invoke-Pester -Configuration $Config
    }
}