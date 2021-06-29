param(
    [Parameter(Mandatory = $true)]
    [string] $S3Bucket,
   
    [Parameter(Mandatory = $true)]
    [string] $S3Folder,
   
    [Parameter(Mandatory = $true)]
    [string] $LMFunctionNames ,
   
    [Parameter(Mandatory = $true)]
    [string] $Region,

    [Parameter(Mandatory = $true)]
    [string] $destFile,

    [Parameter(Mandatory = $false)]
    [string]$LMEnvVariables,
    
    [Parameter(Mandatory = $true)]
    [string] $ReleaseVersion,

    [Parameter(Mandatory = $true)]
    [string] $DeployedBy
)

Function Send-TeamsMessage {
    param (
        [Parameter(Mandatory=$true)]
        [string] $ServiceName,
        
        [Parameter(Mandatory=$true)]
        [string] $DeploymentEnvironment,

        [Parameter(Mandatory=$true)]
        [string] $ReleaseVersion, 
        
        [Parameter(Mandatory=$true)]
        [string] $status, 

        [Parameter(Mandatory=$false)]
        [string] $StatusMessage,

        [Parameter(Mandatory=$false)]
        [string] $displayNameOfDeployer
    )
    $uri = "https://outlook.office.com/webhook/6c26b56d-6480-4ed6-8ef2-7124f2ca3773@96ece526-9c7d-48b0-8daf-8b93c90a5d18/IncomingWebhook/3d6fec2d81f145fe9353dbbf16cacc89/eaab0f92-9c51-486c-ae72-b36b5af3bd05"
    #$status = 'success' 

    $body = ConvertTo-Json -Depth 4 @{
        title    = "Deployment Notification"
        text     = "Deployment Status :: $status"
        sections = @(
            @{
                activityTitle    = $ServiceName
                activitySubtitle = "Release :: $ReleaseVersion "
                #activityText     = "Deployment is $status"
                activityImage    = 'data:image/png;base64,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' # this value would be a path to a nice image you would like to display in notifications
            },
            @{
                title = 'Details'
                facts = @(
                    @{
                        name  = 'DeploymentEnvironment'
                        value = $DeploymentEnvironment
                    },
                    @{
                        name  = 'ReleaseVersion'
                        value = $ReleaseVersion
                    },
                    @{
                        name  = 'Error(If any)'
                        value = $StatusMessage
                    },
                    @{
                        name  = 'DeployedBy'
                        value = $displayNameOfDeployer
                    }
                )
            }
        )
    }


    Invoke-RestMethod -uri $uri -Method Post -body $body -ContentType 'application/json'
}

Function Update-LMFuntionEventSourceMapping {
    param(
        [Parameter(Mandatory = $true)]
        [boolean] $ShouldEnable,

        [Parameter(Mandatory = $true)]
        [string] $LambdaFunctionName,

        [Parameter(Mandatory = $true)]
        [string] $Region
    )

    $LmEventSrcMapping = Get-LMEventSourceMappingList -FunctionName $LambdaFunctionName -Region $Region
    Update-LMEventSourceMapping -FunctionName $LambdaFunctionName -BatchSize 1 -UUID $LmEventSrcMapping.UUID -Enabled $ShouldEnable -Region $Region -Force -EA Stop

    if ($ShouldEnable) {
        $OperationStatus = "Enabled"
        $msg = "Enabling event source mapping is in process..."
    }
    else {
        $OperationStatus = "Disabled"
        $msg = "Disabling event source mapping is in process..."
    }
    while ((Get-LMEventSourceMappingList -FunctionName $LambdaFunctionName -Region $Region ).State -ne $OperationStatus) {
        Write-Host $msg
        Start-Sleep  5

    }

}

try {
    $FolderPath = "mntvolume"
    $S3Params = @{
        BucketName    = $S3Bucket
        Folder        = $FolderPath
        KeyPrefix     = $S3Folder
        Region        = $Region
        SearchPattern = $destFile
    }

    $item = Get-Item "$FolderPath/$destFile" -EA SilentlyContinue
    if ($item) {
        Write-Host "[$($destFile)] exists in the directory[$($FolderPath)]"
    }
    else {
        Write-Host "[$($destFile)] does not exists in the current directory[$($FolderPath)]"
    }
    if ((Get-S3Object -BucketName $S3Bucket -KeyPrefix $S3Folder).Key -contains "$($S3Folder + '/' + $destFile)") {
        Write-Host "[$destFile] is already present in S3 Bucket[$($S3Bucket)]"
    }
    else {
        Write-Host "File [$($destFile)] is not available in S3 bucket[$($S3Bucket)]. Starting upload now..."
        Write-Host "Uploading [$($destFile)] to S3 storage bucket[$($S3Bucket)]... "
        $S3Params
        Write-S3Object @S3Params -EA Stop
        if ((Get-S3Object -BucketName $S3Bucket -KeyPrefix $S3Folder).Key -contains "$($S3Folder + '/' + $destFile)") {
            Write-Host "[$destFile] successfully uploaded to S3 Bucket[$($S3Bucket)]"
        }
        else {
            Write-Host "File [$($destFile)] failed to upload to S3 bucket[$($S3Bucket)]"
        }
    }

    #Building Environment variables as Hashtable from Input string
    $LMFunctionEnvVariables = @{ }
    if($LMEnvVariables){
        $splitenvs = $LMEnvVariables.Split(",")
        foreach ($splitenv in $splitenvs) {
            $LMFunctionEnvVariables.Add($splitenv.Split('=')[0].Replace('Env_', ''), $splitenv.Split('=', 2)[1])
        }
    }
    #Adding ReleaseVersion as environment variable to track versions from portal
    $LMFunctionEnvVariables.Add('ReleaseVersion', $ReleaseVersion)
    #Change code source in lambda to new $destFile, based on environment
    $LMFunctions = $LMFunctionNames.Split(',')
    $LMFunctions
    foreach ($LMFunction in $LMFunctions) {
        Write-Host "Checking if lambda fucntion[$($LMFunction) is having event source mapping...]"
        $LmEventSrcMappingCheck = Get-LMEventSourceMappingList -FunctionName $LMFunction -Region $Region
        if ($LmEventSrcMappingCheck) {
            Write-Host "Disabling SQS trigger for function[$($LMFunction)]..."
            Update-LMFuntionEventSourceMapping -ShouldEnable $false -LambdaFunctionName $LMFunction -Region $Region
            Write-Host "Disabled SQS trigger for function[$($LMFunction)]"
        }
        Write-Host "Updating Lambda function[$($LMFunction)] with package[$($destFile)]..."
        $UpdateLMCode = Update-LMFunctionCode -FunctionName $LMFunction -BucketName $S3Bucket -Key $($S3Folder + '/' + $destFile) -Region $Region -EA Stop
        Write-Host "Successfully updated Lambda function[$($LMFunction)] with package[$($destFile)]"
    
        #Enabling SQS Trigger which is disabled before Updating LambdaFunctionCode
        if ($LmEventSrcMappingCheck) {
            Write-Host "Enabling SQS trigger for function[$($LMFunction)]..."
            Update-LMFuntionEventSourceMapping -ShouldEnable $true -LambdaFunctionName $LMFunction -Region $Region
            Write-Host "Enabled SQS trigger for function[$($LMFunction)]"
        }


        #Set environment variables in lambda, based on environment
        Write-Host "Updating/Adding Environment Values to Lambda function[$($LMFunction)]... "
        $UpdateLMConfig = Update-LMFunctionConfiguration -FunctionName $LMFunction -Environment_Variable $LMFunctionEnvVariables -Region $Region -EA Stop
        Write-Host "Updated/Added environment values to Lambda function[$($LMFunction)]"

        try{
            Write-Host "Sending deployment notification to teams channel"
            $DeployedBy
            $LMFunction
            $Environment.ToUpper()
            $ReleaseVersion
            $DeployStatus
            Send-TeamsMessage -ServiceName $LMFunction -DeploymentEnvironment $Environment.ToUpper() -ReleaseVersion $ReleaseVersion -status $DeployStatus -displayNameOfDeployer $DeployedBy
            Write-Host "Deployment notification sent to teams channel"
        }catch{
            $teamsexception = $_
            Write-Host "Sending deployment notification failed with error :: `n $teamsexception"
        }
    }
}
catch {
    $Exception = $_
    Write-Host "Updating Lambda function[$($LMFunction)] failed with error :: $($Exception)"
}