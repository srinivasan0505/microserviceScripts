param (
    [Parameter(Mandatory = $true)]
    [string] $ecsclustername,
    
    [Parameter(Mandatory = $false)]
    [string] $ecsservicename,
    
    [Parameter(Mandatory = $true)]
    [string] $taskdefname ,
    
    [Parameter(Mandatory = $true)]
    [string] $version,
    
    [Parameter(Mandatory = $true)]
    [string] $ecsregion, 
    
    [Parameter(Mandatory = $true)]
    [string] $UpdatedECRImage,

    [Parameter(Mandatory = $true)]
    [string] $microservicename , 

    [Parameter(Mandatory = $true)]
    [string] $Environment,

    [Parameter(Mandatory = $false)]
    [string] $subnets, 

    [Parameter(Mandatory = $false)]
    [string] $secuirtygroupid,

    [Parameter(Mandatory = $false)]
    [string] $vpcId,

    [Parameter(Mandatory = $false)]
    [string] $albname,

    [Parameter(Mandatory = $false)]
    [string] $servicepath,

    [Parameter(Mandatory = $false)]
    [string] $healthcheckpath,

    [Parameter(Mandatory = $false)]
    [string] $LMEnvVariables
)

#Function to Send Deployment Notification to Teams Channel
Function Send-TeamsMessage {
    param (
        [Parameter(Mandatory = $true)]
        [string] $ServiceName,
        
        [Parameter(Mandatory = $true)]
        [string] $DeploymentEnvironment,

        [Parameter(Mandatory = $true)]
        [string] $ReleaseVersion, 
        
        [Parameter(Mandatory = $true)]
        [string] $status, 

        [Parameter(Mandatory = $false)]
        [string] $StatusMessage
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
                    }
                )
            }
        )
    }


    Invoke-RestMethod -uri $uri -Method Post -body $body -ContentType 'application/json'
}
Function Build-EnvironmentalArray {
    param(
        [Parameter(Mandatory = $false)]
        [string] $FncEnvVariables = ""
    )
    #Building Environment variables as Hashtable from Input string
    Write-Host "Environment Variables String :: `n $($FncEnvVariables)"
    Write-Host "Creating array of Environment variables..."
    $LMFunctionEnvVariables = New-Object System.Collections.Generic.List[Amazon.ECS.Model.KeyValuePair]
    if ([string]::IsNullOrEmpty($FncEnvVariables) -eq $false ) {
        $splitenvs = $FncEnvVariables.Split("!;")
        foreach ($splitenv in $splitenvs) {
            $EnvKeyPair = New-Object "Amazon.ECS.Model.KeyValuePair"
            $EnvKeyPair.Name = $splitenv.Split('=')[0]
            $EnvKeyPair.Value = $splitenv.Split('=', 2)[1]
            $LMFunctionEnvVariables += $EnvKeyPair
        }
        return $LMFunctionEnvVariables
    }
    return $null
}
#Function to Updated Existing ECS Service
Function UpdateECSService {
    param(
    
        [Parameter(Mandatory = $true)]
        [string] $ecsclustername,
    
        [Parameter(Mandatory = $true)]
        [string] $ecssvcname,
    
        [Parameter(Mandatory = $true)]
        [string] $taskdefname ,
    
        [Parameter(Mandatory = $true)]
        [string] $version,
    
        [Parameter(Mandatory = $true)]
        [string] $ecsregion, 
    
        [Parameter(Mandatory = $true)]
        [string] $UpdatedECRImage
    )

    $region = $ecsregion
    Write-Host "Setting default AWS region[$region]... "
    Set-DefaultAWSRegion -Region $region

    Write-Host "Variables in ecsfargate:: `n $LMEnvVariables" 
    Write-Host "Getting current task definition[$taskdefname] details..."
    $definition = (Get-ECSTaskDefinitionDetail -TaskDefinition $taskdefname -Region $region -EA SilentlyContinue).TaskDefinition
    if ($definition) {
        try {
            $currentdefinitionversion = $definition.Revision
            Write-Host "Task definition [$taskdefname] found with latest revision number :: $currentdefinitionversion " 
            $sampledefinition = $definition.ContainerDefinitions
            $ContainerDefinitions = New-Object "System.Collections.Generic.List[Amazon.ECS.Model.ContainerDefinition]"

            Write-Host "Building Environmnet Variables..."
            $EnvKeyPair = Build-EnvironmentalArray -FncEnvVariables $LMEnvVariables
            Write-Host "Below are the environment variables: `n $($EnvKeyPair)"

            Write-Host "Building new task definition [$taskdefname] with latest image tag $version ... "
            if ($sampledefinition.MemoryReservation) {
                Write-Host "Container definition with MemoryReservation property..."
                $ContainerDefinitions.Add($(New-Object -TypeName "Amazon.ECS.Model.ContainerDefinition" -Property @{`
                                Name              = $sampledefinition.Name; `
                                Image             = $UpdatedECRImage ; `
                                PortMappings      = $sampledefinition.PortMappings ; `
                                LogConfiguration  = $sampledefinition.LogConfiguration ; `
                                EntryPoint        = $sampledefinition.EntryPoint ; `
                                Environment       = $EnvKeyPair ; `
                                MemoryReservation = $sampledefinition.MemoryReservation ; `
                                Cpu               = $sampledefinition.Cpu    
                        }))
            }
            else {
                Write-Host "Container definition with Memory property..."
                $ContainerDefinitions.Add($(New-Object -TypeName "Amazon.ECS.Model.ContainerDefinition" -Property @{`
                                Name             = $sampledefinition.Name; `
                                Image            = $UpdatedECRImage ; `
                                PortMappings     = $sampledefinition.PortMappings ; `
                                LogConfiguration = $sampledefinition.LogConfiguration ; `
                                EntryPoint       = $sampledefinition.EntryPoint ; `
                                Environment      = $EnvKeyPair ; `
                                Memory           = $sampledefinition.Memory ; `
                                Cpu              = $sampledefinition.Cpu    
                        }))
            }

            Write-Host "Registering a revision of task definition [$taskdefname]... "
            Write-Host "Exceution ARN [$($definition.ExecutionRoleArn)]"
            $registertaskdefinition = Register-ECSTaskDefinition -ContainerDefinition $ContainerDefinitions -Cpu $definition.Cpu -Family $definition.Family -ExecutionRoleArn $($definition.ExecutionRoleArn) -Memory $definition.Memory `
                -NetworkMode awsvpc -RequiresCompatibility "FARGATE" -Region $region
        
            if ($registertaskdefinition.TaskDefinition.Revision -ne $currentdefinitionversion ) {
                Write-Host "Successfully register a revision of task definition[$taskdefname], new revision number is [$($registertaskdefinition.TaskDefinition.Revision)] "
            }
            else {
                throw "Registering a revision of task definition [$taskdefname] failed "
            }
        }
        catch {
            Write-Host "Registering task definition failed with Error : $_ "
        }
    }
    else {
        Write-Host "Task definition $($taskdefname) is not found"
    }

    #Below code is to update ECS service with new revision of task definition from above

    $UpdatedTaskDefinition = $taskdefname + ":" + $($registertaskdefinition.TaskDefinition.Revision)

    if ($UpdatedTaskDefinition) {
        try {
            Write-Host "`n Updating ECS service[$ecssvcname] with new task definition [$UpdatedTaskDefinition]... "
            Update-ECSService -Cluster $ecsclustername -Service $ecssvcname -TaskDefinition $UpdatedTaskDefinition -ForceNewDeployment $true -Region $region
            Write-Host "`n ECS service[$ecssvcname] updated successfully with latest task definition revision[$UpdatedTaskDefinition] "
        }
        catch {
            Write-Host "Updating ECS Service failed with error : $_ "
        }
    }
    else {
        Write-Host "UpdatedTaskDefinition parameter is empty "
    }
}

#Function to Create New Service with all dependent resources
Function CreateECSService {
    param(
        [Parameter(Mandatory = $true)]
        [string] $ecsclustername,
        
        [Parameter(Mandatory = $true)]
        [string] $microservicename,

        [Parameter(Mandatory = $true)]
        [string] $ecsregion, 
        
        [Parameter(Mandatory = $true)]
        [string] $UpdatedECRImage,

        [Parameter(Mandatory = $true)]
        [string] $Environment,

        [Parameter(Mandatory = $true)]
        [string] $subnets, 
    
        [Parameter(Mandatory = $true)]
        [string] $secuirtygroupid,
    
        [Parameter(Mandatory = $true)]
        [string] $vpcId,

        [Parameter(Mandatory = $false)]
        [string] $albname,

        [Parameter(Mandatory = $false)]
        [string] $servicepath,

        [Parameter(Mandatory = $false)]
        [string] $healthcheckpath,

        [Parameter(Mandatory = $false)]
        [string] $LMEnvVariables
    )

    $Region = $ecsregion 
    $defname = "cce-$($Environment)-$($microservicename)-service-taskdef"
    $containername = "portal-$($microservicename)-service-$($Environment)-container"

    #Get sample task definition
    $sampledefname = "cce-new-service-taskdef"
    $sampledefinition = (Get-ECSTaskDefinitionDetail -TaskDefinition $sampledefname -Region $Region -EA SilentlyContinue).TaskDefinition

    #Entry Point
    $profile = "-Dspring.profiles.active=$($Environment)"

    #Log Configuration
    $Logconfig = New-Object Amazon.ECS.Model.LogConfiguration
    #$sampledefinition.LogConfiguration.Options
    $logoptions = New-Object "System.Collections.Generic.Dictionary``2[System.String,System.String]"
    $logoptions.Add('awslogs-group', $($sampledefinition.ContainerDefinitions.LogConfiguration.Options.'awslogs-group'.Replace('dev', $Environment)))
    $logoptions.Add('awslogs-region', $($sampledefinition.ContainerDefinitions.LogConfiguration.Options.'awslogs-region'))
    $logoptions.Add('awslogs-stream-prefix', $($sampledefinition.ContainerDefinitions.LogConfiguration.Options.'awslogs-stream-prefix').Replace('dev-new-service', $containername))
    $Logconfig.LogDriver = $sampledefinition.ContainerDefinitions.LogConfiguration.LogDriver
    $Logconfig.Options = $logoptions

    #Port Mappings
    $portmap = New-Object -TypeName "Amazon.ECS.Model.PortMapping"
    $portmap.ContainerPort = 8080
    $portmap.HostPort = 8080
    $portmap.Protocol = 'tcp'

    if ($LMEnvVariables -ne $null) {
        #$EnvKeyPair = New-Object "Amazon.ECS.Model.KeyValuePair"
        Write-Host "Building Environmnet Variables..."
        $EnvKeyPair = Build-EnvironmentalArray -FncEnvVariables $LMEnvVariables
        Write-Host "Below are the environment variables: `n $($EnvKeyPair)"
    }
    
    #Task Definition
    $ContainerDefinitions = New-Object "System.Collections.Generic.List[Amazon.ECS.Model.ContainerDefinition]"
        
    Write-Host "Building new task definition [$defname] with latest image tag $version..."
    $ContainerDefinitions.Add($(New-Object -TypeName "Amazon.ECS.Model.ContainerDefinition" -Property @{`
                    Name              = $containername ; `
                    Image             = $UpdatedECRImage ; `
                    PortMappings      = $portmap ; `
                    LogConfiguration  = $Logconfig ; `
                    EntryPoint        = $sampledefinition.ContainerDefinitions.Entrypoint.replace('-Dspring.profiles.active=dev', $profile) ; `
                    Environment       = $EnvKeyPair ; `
                    MemoryReservation = 512; `
                    Cpu               = 256;
            }))

    Write-Host "Registering a revision of task definition [$defname]..."
    Write-Host "Exceution ARN [$($sampledefinition.ExecutionRoleArn)]"
    $registertaskdefinition = Register-ECSTaskDefinition -ContainerDefinition $ContainerDefinitions -Cpu $sampledefinition.Cpu -Family $defname -ExecutionRoleArn $($sampledefinition.ExecutionRoleArn) -Memory $sampledefinition.Memory `
        -NetworkMode awsvpc -RequiresCompatibility "FARGATE" -Region $region
    Write-Host "Successfully registered new revision of task definition [$defname]"
    #Create ALB
    #$albnane = "cce-$($environment)-$($microservicename)-alb"
    
    #Get ALB details
    Write-Host "Getting ALB information [$albname]..."
    $alb = Get-ELB2LoadBalancer -Name $albname -Region $Region

    $subnetsids = @()
    foreach ($subnetid in $subnets.Split(',')) {
        $subnetsids += $subnetid
    }
    #$subnetids = $subnets #.Split(',')
    #Create Target Group
    $tgname = "cce-$($Environment)-$($microservicename)-tg"
    Write-Host "Creating target group [$tgname]..."
    $tg = New-ELB2TargetGroup -Name $tgname -HealthCheckEnabled $true -Port 8080 -HealthCheckPath $healthcheckpath -TargetType ip -VpcId $vpcId -Region $Region -Protocol HTTP
    
    #Create ELB
    #$alb = New-ELB2LoadBalancer -IpAddressType ipv4 -Name $albnane -Scheme internal -Type application -SecurityGroup $secuirtygroupid -Subnet $subnetsids -Region $Region
    #Creaet ELB Listener
    Write-Host "Defining ELB Listener Action..."
    $ELBListenerAction = New-Object Amazon.ElasticLoadBalancingV2.Model.Action -Property @{ `
            TargetGroupArn = $tg.TargetGroupArn ; `
            Type           = "forward" `
                    
    }
    #New-ELB2Listener -LoadBalancerArn $alb.LoadBalancerArn -DefaultAction $ELBListenerAction -Port 80 -Protocol HTTP -Region $Region
    
    #Object definition for path-based routing
    Write-Host "Defining ELB Listener Condition..."
    $ELBListenerCondition = New-Object -TypeName Amazon.ElasticLoadBalancingV2.Model.RuleCondition -Property @{
        Field  = "path-pattern"
        Values = $servicepath
    }
    Write-Host "Retrieving ELB HTTPS Listener..."
    $alblistener = Get-ELB2Listener -Region $Region -LoadBalancerArn $alb.LoadBalancerArn | Where-Object { $_.Port -eq 443 }
    Write-Host "Retrieving ELB HTTPS Rules..."
    $albrules = Get-ELB2Rule -ListenerArn $alblistener.ListenerArn -Region $Region
    $albpriority = ($albrules | Where-Object { $_.Priority -ne 'default' }).Priority #Get Current priority 
    $albpriority = $albpriority.Count + 2 #Add 1 to current priority length 
    Write-Host "Creating ELB path based rule for path[$servicepath] for forwarding traffic to target group[$tgname]..."
    New-ELB2Rule -Action $ELBListenerAction -Condition $ELBListenerCondition -ListenerArn $alblistener.ListenerArn -Region $Region -Priority $albpriority -EA Stop
    Write-Host "Successfully created ELB path based rule for path[$servicepath] for forwarding traffic to target group[$tgname]"
    Write-Host "URL for ALB[$($alb.LoadBalancerName)] :: $($alb.DNSName)"

    #Create ECS Service
    $nwecssvcname = "cce-ecs-$($Environment)-$($microservicename)-service"
    $ecsloadbalancerconfig = New-Object -TypeName "Amazon.ECS.Model.LoadBalancer"
    $ecsloadbalancerconfig.ContainerName = $containername
    $ecsloadbalancerconfig.TargetGroupArn = $tg.TargetGroupArn
    $ecsloadbalancerconfig.ContainerPort = 8080
    Write-Host "Creating ECS Service[$($nwecssvcname)] using task definition[$($registertaskdefinition.TaskDefinition.Family)] and version[$($registertaskdefinition.TaskDefinition.Revision)]"
    New-ECSService -Cluster $ecsclustername -LaunchType FARGATE -TaskDefinition "$($registertaskdefinition.TaskDefinition.Family):$($registertaskdefinition.TaskDefinition.Revision)"  -ServiceName $nwecssvcname -DesiredCount 2 -LoadBalancer $ecsloadbalancerconfig -AwsvpcConfiguration_Subnet $subnetsids -AwsvpcConfiguration_SecurityGroup $secuirtygroupid -HealthCheckGracePeriodSecond 360 -ErrorAction Stop
    Write-Host "Successfully created ECS Service[$($nwecssvcname)] with task definition [$($registertaskdefinition.TaskDefinition.Family)] and version[$($registertaskdefinition.TaskDefinition.Revision)]"

}

if ($ecsservicename -ne '') {
    $EcsServiceCheckName = $ecsservicename
}
else {
    $EcsServiceCheckName = "cce-ecs-$($Environment)-$($microservicename)-service"
}

#Check for ECS service
$CheckEcsService = Get-ECSService -Cluster $ecsclustername -Service $EcsServiceCheckName -Region $ecsregion
$DeployStatus = "Failed"
#Try - Catch loop to perform main operations of this script(To Create/Update ECS Service).
try {
    #If ECS is available alreday, invoke UpdateECSService function to update service. If not, invoke CreateECSService function to create ECS service along with Alb,Tg,TaskDefinition and ECS Service.
    if ([string]::IsNullOrEmpty($CheckEcsService.Services)) {
        Write-Host "ECS Service[$($EcsServiceCheckName) doesn't exist..Creating new ECS Service...]"
        if ([string]::IsNullOrEmpty($LMEnvVariables) -eq $true) {
            CreateECSService -ecsclustername $ecsclustername -microservicename $microservicename -ecsregion $ecsregion -UpdatedECRImage $UpdatedECRImage -Environment $Environment -subnets $subnets -secuirtygroupid $secuirtygroupid -vpcId $vpcId -albname $albname -servicepath $servicepath -healthcheckpath $healthcheckpath 
        }
        else {
            CreateECSService -ecsclustername $ecsclustername -microservicename $microservicename -ecsregion $ecsregion -UpdatedECRImage $UpdatedECRImage -Environment $Environment -subnets $subnets -secuirtygroupid $secuirtygroupid -vpcId $vpcId -albname $albname -servicepath $servicepath -healthcheckpath $healthcheckpath -LMEnvVariables $LMEnvVariables
        }
        Write-Host "Succesfully created ECS Service[$($EcsServiceCheckName)]"
        $DeployStatus = "Success"
    }
    else {
        Write-Host "ECS Service[$($EcsServiceCheckName)] exists...Updating existing service..."
        UpdateECSService -ecsclustername $ecsclustername -ecssvcname $EcsServiceCheckName -taskdefname $taskdefname -version $version -UpdatedECRImage $UpdatedECRImage -ecsregion $ecsregion -ErrorAction Stop
        Write-Host "Successfully updated ECS Service[$($EcsServiceCheckName)] with task definition[$($taskdefname):$($version)]"
        $DeployStatus = "Success"
    }
}
catch {
    $exception = $_
    Write-Host "Deployment failed with error:: `n $exception"
    Write-Host "Sending deployment notification to teams channel"
    Send-TeamsMessage -ServiceName $microservicename -DeploymentEnvironment $Environment.ToUpper() -ReleaseVersion $version -status $DeployStatus -StatusMessage $exception
    Write-Host "Deployment notification sent to teams channel"
}

try {
    Write-Host "Sending deployment notification to teams channel"
    Send-TeamsMessage -ServiceName $microservicename -DeploymentEnvironment $Environment.ToUpper() -ReleaseVersion $version -status $DeployStatus
    Write-Host "Deployment notification sent to teams channel"
}
catch {
    $teamsexception = $_
    Write-Host "Sending deployment notification failed with error :: `n $teamsexception"
}