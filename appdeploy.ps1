# Download all deployment files
#Invoke-WebRequest #"https://bitbucket.honeywell.com/projects/ENYDYHIJ/repos/portalservicescicd/raw/ecsfargate.ps1" -OutFile ecsfargate.ps1

echo $OctopusParameters['Octopus.Release.Number']
echo "Srinivasan"
echo $DOCKER_CLI_USER
echo $DOCKER_CLI_PASSWORD
echo $AWSACCESSID
echo $AWSACCESSKEY


# Construct version
$imgTag = $OctopusParameters['Octopus.Release.Number']

# Source and destination image name
$ecrImage = "cce-ecr-portalservices-$MS_SERVICENAME-service"
$artfImg = $artifactoryDeployServer + "/" + $ARTFIMAGE + ":" + $imgTag
$ecrImg = $ECR + "/" + $ecrImage + ":" + $imgTag

$DOCKER_CLI_PASSWORD | docker login --username $DOCKER_CLI_USER --password-stdin awsps-docker-stable-local.artifactory-na.honeywell.com

#Check for ECR, if not create a new ECR and push image to repo
docker pull awsps-docker-stable-local.artifactory-na.honeywell.com/awsps:latest
$checkEcr = docker run --rm -e AWSACCESSID=$AWSACCESSID -e AWSACCESSKEY=$AWSACCESSKEY -e AWSREGION=$AWSREGION awsps-docker-stable-local.artifactory-na.honeywell.com/awsps:latest -Command "(Get-ECRRepository -Region $AWSREGION | ?{`$_.RepositoryName -eq '$ecrImage'})"
if (!$checkEcr) {
    Write-Host "ECR Repo[$($ecrImage)] is not found..Creating new repo with name[$($ecrImage)]..."
    docker run --rm -e AWSACCESSID=$AWSACCESSID -e AWSACCESSKEY=$AWSACCESSKEY -e AWSREGION=$AWSREGION awsps-docker-stable-local.artifactory-na.honeywell.com/awsps:latest -Command "New-ECRRepository -RepositoryName $ecrImage -Region $AWSREGION"
    Write-Host "Successfully ECR Repo[$($ecrImage)]"
}
else {
    Write-Host "ECR Repo[$($ecrImage)] is found"
}

# Push to ECR (only when PortalServicesProject-DEV or PortalServicesProject-PROD)
if (($OctopusParameters['Octopus.Environment.Name'] -eq "PortalServicesProject-DEV") -or ($OctopusParameters['Octopus.Environment.Name'] -eq "PortalServicesProject-PROD")) {
    $cred = docker run --rm -e AWSACCESSID=$AWSACCESSID -e AWSACCESSKEY=$AWSACCESSKEY -e AWSREGION=$AWSREGION awsps-docker-stable-local.artifactory-na.honeywell.com/awsps:latest -Command "(Get-ECRLoginCommand -Region us-east-1).Password"
    docker logout awsps-docker-stable-local.artifactory-na.honeywell.com

    docker pull $artfImg
    docker tag $artfImg $ecrImg

    Write-Host "ECR :: $ECR"
    # Preparing --password-stdin
    $dcrcmd="`$cred | docker login --username AWS --password-stdin https://`$ECR"

    # Login to ECR and push
    # retry 5 times on failure because of TLS handshake issue
    $loginStatus = "Login Failed"
    $retryCount = 1
    while (($retryCount -le 5) -and ($loginStatus -ne "Login Succeeded")) {
        Write-Host("Login attempt " + $retryCount)
        $loginStatus = Invoke-Expression $dcrcmd
        $retryCount++
    }
    docker push $ecrImg
    docker logout $ECR
    docker rmi $artfImg
    docker rmi $ecrImg
}

#Building Environment value based on Octopus Environment
if ($OctopusParameters['Octopus.Environment.Name'] -eq "PortalServicesProject-PROD" ) {
    $environment = "prd"
}
else {
    $environment = ((($OctopusParameters['Octopus.Environment.Name']).Split('-'))[-1]).ToLower()
}

if ($ECSTaskDefinition) {
    $taskdefname = $ECSTaskDefinition
}
else {
    $taskdefname = "cce-$($environment)-$($MS_SERVICENAME)-service-taskdef"
}

if(!($SERVICEPATHRULE)){
    $SERVICEPATHRULE = " "
}
if(!($APPLBNAME)){
    $APPLBNAME = " "
}
if(!($SERVICEHEALTHCHECK)){
    $SERVICEHEALTHCHECK = " "
}
#Constructing ALB name based on environment
$APPLBNAME = "cce-$($environment)-portalservices-alb"

#Building a string from octopus variables prefixed with "environment."
$envvariables = ($OctopusParameters.Keys | Where-Object {$_ -like 'environment.*'} | ForEach-Object {"$($_.replace('environment.static.',''))=$($OctopusParameters[$_])"} ) -join "!;"
Write-Host "Variables :: `n $($envvariables)"

#Mount and run deployment script
$varWorkingDir = (pwd).path
if ((test-path variable:global:ECSSERVICE) -eq $true) {
    if([string]::IsNullOrEmpty($envvariables) -eq $true){
        Write-Host "envvariables variable is empty or null"
        docker run --rm -v "$($varWorkingDir):/mntvolume:Z" -e AWSACCESSID=$AWSACCESSID -e AWSACCESSKEY=$AWSACCESSKEY -e AWSREGION=$AWSREGION awsps-docker-stable-local.artifactory-na.honeywell.com/awsps:latest -file /mntvolume/ecsfargate.ps1 -ecsclustername $ECSCLUSTER -ecsservicename $ECSSERVICE -taskdefname $taskdefname -version $imgTag -ecsregion $AWSREGION -UpdatedECRImage $ecrImg -environment $environment -microservicename $MS_SERVICENAME -subnets $SUBNETS -secuirtygroupid $SECURITYGROUPID -vpcId $VPCID -servicepath $SERVICEPATHRULE -albname $APPLBNAME -healthcheckpath $SERVICEHEALTHCHECK
    }else{
        Write-Host "envvariables variable is not empty or null"
        docker run --rm -v "$($varWorkingDir):/mntvolume:Z" -e AWSACCESSID=$AWSACCESSID -e AWSACCESSKEY=$AWSACCESSKEY -e AWSREGION=$AWSREGION awsps-docker-stable-local.artifactory-na.honeywell.com/awsps:latest -file /mntvolume/ecsfargate.ps1 -ecsclustername $ECSCLUSTER -ecsservicename $ECSSERVICE -taskdefname $taskdefname -version $imgTag -ecsregion $AWSREGION -UpdatedECRImage $ecrImg -environment $environment -microservicename $MS_SERVICENAME -subnets $SUBNETS -secuirtygroupid $SECURITYGROUPID -vpcId $VPCID -servicepath $SERVICEPATHRULE -albname $APPLBNAME -healthcheckpath $SERVICEHEALTHCHECK -LMEnvVariables $envvariables
    }
}
else {
    if([string]::IsNullOrEmpty($envvariables) -eq $true){
        Write-Host "envvariables variable is empty or null"
        docker run --rm -v "$($varWorkingDir):/mntvolume:Z" -e AWSACCESSID=$AWSACCESSID -e AWSACCESSKEY=$AWSACCESSKEY -e AWSREGION=$AWSREGION awsps-docker-stable-local.artifactory-na.honeywell.com/awsps:latest -file /mntvolume/ecsfargate.ps1 -ecsclustername $ECSCLUSTER -taskdefname $taskdefname -version $imgTag -ecsregion $AWSREGION -UpdatedECRImage $ecrImg -environment $environment -microservicename $MS_SERVICENAME -subnets $SUBNETS -secuirtygroupid $SECURITYGROUPID -vpcId $VPCID -servicepath $SERVICEPATHRULE -albname $APPLBNAME -healthcheckpath $SERVICEHEALTHCHECK
    }else {
        Write-Host "envvariables variable is not empty or null"
        docker run --rm -v "$($varWorkingDir):/mntvolume:Z" -e AWSACCESSID=$AWSACCESSID -e AWSACCESSKEY=$AWSACCESSKEY -e AWSREGION=$AWSREGION awsps-docker-stable-local.artifactory-na.honeywell.com/awsps:latest -file /mntvolume/ecsfargate.ps1 -ecsclustername $ECSCLUSTER -taskdefname $taskdefname -version $imgTag -ecsregion $AWSREGION -UpdatedECRImage $ecrImg -environment $environment -microservicename $MS_SERVICENAME -subnets $SUBNETS -secuirtygroupid $SECURITYGROUPID -vpcId $VPCID -servicepath $SERVICEPATHRULE -albname $APPLBNAME -healthcheckpath $SERVICEHEALTHCHECK -LMEnvVariables $envvariables
    }
}

#Commentinf below line as its causing deployment failure if there are any other deployments happening using this docker image. 
#docker rmi awsps-docker-stable-local.artifactory-na.honeywell.com/awsps:latest
