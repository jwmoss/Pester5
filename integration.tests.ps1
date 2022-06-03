param (
    [Parameter()]
    [string]
    $File,

    ## Path to custom module that holds wrapper functions around invoke-restmethod
    [String]
    $PathToScript = "C:\Github\Pester5\Get-Airport.ps1"
)

BeforeDiscovery {
    ## Store the data from the json file to be re-used
    $data = Get-Content $file | ConvertFrom-Json
}


Describe "Website" -Tag "Website" {
    
    BeforeAll {
        . $PathToScript
    }

    Context "<_>" -Foreach $data.City {
        It "<_>'s Website is online" {
           (Invoke-WebRequest -Uri (Get-Airport -City $_).Website).StatusCode | Should -Be 200
        }
    }
}

Describe "AirportCode" -Tag "Code" {
    
    BeforeAll {
        . $PathToScript
    }

    Context "<_>" -Foreach $data.City {
        It "<_>'s Code is only 3 characters" {
            (Measure-Object -InputObject ((Get-Airport -City Raleigh).code) -Character).Characters | Should -Be 3
        }
    }
}