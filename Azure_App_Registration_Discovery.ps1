param(
    $appid,
    $tenantid,
    $secret
)

$body = @{
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    Client_Id     = $appid
    Client_Secret = $secret
}

function ConnectAzure {
    $connection = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantid/oauth2/v2.0/token" -Method POST -Body $body
    $token = $connection.access_token

    $secureToken = ConvertTo-SecureString -String $token -AsPlainText -Force
    $global:result = Connect-MgGraph -AccessToken $secureToken

    if ($global:result -notmatch "Welcome To Microsoft Graph") {
        Exit
    }
}

function AppLld {
    ConnectAzure
    $apps = Get-MgApplication -All

    $lldObject = foreach ($app in $apps) {
        foreach ($keyCredential in $app.KeyCredentials) {
            [PSCustomObject] @{
                "{#CREDENTIALTYPE}" = "KeyCredentials"
                "{#DISPLAYNAME}"     = $app.DisplayName
                "{#APPID}"           = $app.AppId
                "{#KEYID}"           = $keyCredential.KeyId
                "{#AADAPPOBJID}"     = $app.Id
            }
        }

        foreach ($passwordCredential in $app.PasswordCredentials) {
            [PSCustomObject] @{
                "{#CREDENTIALTYPE}" = "PasswordCredentials"
                "{#DISPLAYNAME}"     = $app.DisplayName
                "{#APPID}"           = $app.AppId
                "{#KEYID}"           = $passwordCredential.KeyId
                "{#AADAPPOBJID}"     = $app.Id
            }
        }
    }

    $lldObject | ConvertTo-Json
}

switch ($args[0]) {
    'lld'    { AppLld }
    'keyTtl' { 
        $global:aadAppObjId = $args[1]
        $global:KeyId = $args[2]
        AppKeyTtl 
    }
}