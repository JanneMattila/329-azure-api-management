Param (
    [Parameter(HelpMessage="Deployment target resource group")] 
    [string] $ResourceGroupName = "rg-apim-local",

    [Parameter(HelpMessage="Deployment target resource group location")] 
    [string] $Location = "North Europe",

    [Parameter(HelpMessage="API Management Name")] 
    [string] $APIMName = "contosoapim-local",

    [Parameter(HelpMessage="API HttpBinAPI ServiceUrl")] 
    [string] $APIHttpBinAPIServiceUrl = "https://httpbin.org",

    [string] $Template = "$PSScriptRoot\azuredeploy.json",
    [string] $TemplateParameters = "$PSScriptRoot\azuredeploy.parameters.json"
)

$ErrorActionPreference = "Stop"

$date = (Get-Date).ToString("yyyy-MM-dd-HH-mm-ss")
$deploymentName = "Local-$date"

if ([string]::IsNullOrEmpty($env:RELEASE_DEFINITIONNAME))
{
    Write-Host (@"
Not executing inside Azure DevOps Release Management.
Make sure you have done "Login-AzAccount" and
"Select-AzureRmSubscription -SubscriptionName name"
so that script continues to work correctly for you.
"@)
}
else
{
    $deploymentName = $env:RELEASE_RELEASENAME
}

if ($null -eq (Get-AzResourceGroup -Name $ResourceGroupName -Location $Location -ErrorAction SilentlyContinue))
{
    Write-Warning "Resource group '$ResourceGroupName' doesn't exist and it will be created."
    New-AzResourceGroup -Name $ResourceGroupName -Location $Location -Verbose
}

# Additional parameters that we pass to the template deployment
$additionalParameters = New-Object -TypeName hashtable
$additionalParameters['apimName'] = $APIMName

# API Endpoint Service Urls:
$additionalParameters['apiHttpBinAPIServiceUrl'] = $APIHttpBinAPIServiceUrl

$result = New-AzResourceGroupDeployment `
    -DeploymentName $deploymentName `
    -ResourceGroupName $ResourceGroupName `
    -TemplateFile $Template `
    -TemplateParameterFile $TemplateParameters `
    @additionalParameters `
    -Mode Complete -Force `
    -Verbose

if ($result.Outputs.apimGateway -eq $null)
{
    Throw "Template deployment didn't return web app information correctly and therefore deployment is cancelled."
}

$result

$apimGateway = $result.Outputs.apimGateway.value

# Publish variable to the Azure DevOps agents so that they
# can be used in follow-up tasks such as application deployment
Write-Host "##vso[task.setvariable variable=Custom.APIMGateway;]$apimGateway"

Write-Host "Validating that our *MANDATORY* API is up and running..."
$webAppUri = "$apimGateway/httpbin/get"
$running = 0
for ($i = 0; $i -lt 60; $i++)
{
    try 
    {
        $request = Invoke-WebRequest -Uri $webAppUri -UseBasicParsing -DisableKeepAlive -ErrorAction SilentlyContinue
        Write-Host "API status code $($request.StatusCode)."

        if ($request.StatusCode -eq 200)
        {
            Write-Host "API is up and running."
            $running++
        }
    }
    catch
    {
        Start-Sleep -Seconds 3
    }

    if ($running -eq 1)
    {
        return
    }
}

Throw "Mandatory API didn't respond on defined time."
