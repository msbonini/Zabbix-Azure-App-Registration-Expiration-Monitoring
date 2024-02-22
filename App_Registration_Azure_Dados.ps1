param(
    [Parameter(Mandatory = $true)]
    [string]$appid,
    [Parameter(Mandatory = $true)]
    [string]$tenantid,
    [Parameter(Mandatory = $true)]
    [string]$secret,
    [Parameter(Mandatory = $true)]
    [string]$requestType
)

function ConnectAzure {
    $body = @{
        Grant_Type    = "client_credentials"
        Scope         = "https://graph.microsoft.com/.default"
        Client_Id     = $appid
        Client_Secret = $secret
        Tenant_Id     = $tenantid
    }

    try {
        $connection = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantid/oauth2/v2.0/token" -Method POST -Body $body
        $token = $connection.access_token

        if (-not $token) {
            throw "Failed to obtain access token"
        }

        $global:secureToken = ConvertTo-SecureString -String $token -AsPlainText -Force
        $global:result = Connect-MgGraph -AccessToken $global:secureToken

        if ($global:result -notmatch "Welcome To Microsoft Graph") {
            throw "Failed to connect to Microsoft Graph"
        }
    } catch {
        Write-Error "Error connecting to Azure: $_"
        Exit 1
    }
}

function Get-AppCredentials {
    ConnectAzure
    $apps = Get-MgApplication -All

    $credentials = foreach ($app in $apps) {
        foreach ($keyCredential in $app.KeyCredentials) {
            $daysRemaining = [math]::Ceiling(($keyCredential.EndDateTime - (Get-Date)).TotalDays)
            [PSCustomObject] @{
                "DISPLAYNOME"    = $app.DisplayName
                "DAYSREMAINING"  = [int]$daysRemaining  # Convertendo para inteiro para remover a parte decimal
                "APPID"          = $app.AppId
                "KEYID"          = $keyCredential.KeyId
                "AADAPPOBJID"    = $app.Id
            }
        }

        foreach ($passwordCredential in $app.PasswordCredentials) {
            $daysRemaining = [math]::Ceiling(($passwordCredential.EndDateTime - (Get-Date)).TotalDays)
            [PSCustomObject] @{
                "DISPLAYNOME"    = $app.DisplayName
                "DAYSREMAINING"  = [int]$daysRemaining  # Convertendo para inteiro para remover a parte decimal
                "APPID"          = $app.AppId
                "KEYID"          = $passwordCredential.KeyId
                "AADAPPOBJID"    = $app.Id
            }
        }
    }

    $credentials
}

# Chamada da função principal
$credentials = Get-AppCredentials
$jsonObject = $credentials | ConvertTo-Json -Depth 3
Write-Output $jsonObject
