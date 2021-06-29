function GetNewProps(){
    param($prefix)
    $tmpEnv = Get-ChildItem Env: | Where-Object {$_.Key -match $prefix} | ForEach-Object { "$($_.Key)=$($_.Value)"} 
    return $tmpEnv -join ","
} 
# Download all deployment files
Invoke-WebRequest "https://bitbucket.honeywell.com/projects/ENYDYHIJ/repos/portalservicescicd/raw/lambda-deploy.ps1" -OutFile lambda-deploy.ps1

# Construct version
$imgTag=$OctopusParameters['Octopus.Release.Number']
$releaseDeployedBy = $OctopusParameters['Octopus.Deployment.CreatedBy.DisplayName']

# Get source image to extract app.jar
$artfImg=$artifactoryDeployServer + "/" + $ARTFIMAGE + ":" + $imgTag
docker pull $artfImg
$containerID=docker run --rm -d $artfImg
$sourceFile=$containerID + ':/app.jar'
$destFile=$OctopusParameters["Octopus.Project.Name"] + "-" +  $imgTag + ".jar"
docker cp $sourceFile $destFile
docker stop $containerID
docker rmi $artfImg
dir

#Creating array of lambda environment variables from octopus variables with prefix 'Env_'
$envvariables = ($OctopusParameters.Keys | Where-Object {$_ -like 'Env_*'} | ForEach-Object {"$($_)=$($OctopusParameters[$_])"} ) -join ","

$DOCKER_CLI_PASSWORD | docker login --username $DOCKER_CLI_USER --password-stdin awsps-docker-stable-local.artifactory-na.honeywell.com

$varWorkingDir=(pwd).path
Write-Host "Pulling awsps image from artifactory"
docker pull awsps-docker-stable-local.artifactory-na.honeywell.com/awsps:latest
if($envvariables){
    docker run --rm -v "$($varWorkingDir):/mntvolume:Z" -e AWSACCESSID=$AWSACCESSID -e AWSACCESSKEY=$AWSACCESSKEY -e AWSREGION=$AWSREGION awsps-docker-stable-local.artifactory-na.honeywell.com/awsps:latest -file /mntvolume/lambda-deploy.ps1 -S3Bucket $S3Bucket -S3Folder $S3Folder -LMFunctionNames $LambdaFunctionName -destFile $destFile -Region $AWSREGION -LMEnvVariables $envvariables -ReleaseVersion $imgTag -DeployedBy $releaseDeployedBy
}else{
    docker run --rm -v "$($varWorkingDir):/mntvolume:Z" -e AWSACCESSID=$AWSACCESSID -e AWSACCESSKEY=$AWSACCESSKEY -e AWSREGION=$AWSREGION awsps-docker-stable-local.artifactory-na.honeywell.com/awsps:latest -file /mntvolume/lambda-deploy.ps1 -S3Bucket $S3Bucket -S3Folder $S3Folder -LMFunctionNames $LambdaFunctionName -destFile $destFile -Region $AWSREGION -ReleaseVersion $imgTag -DeployedBy $releaseDeployedBy
}

docker logout awsps-docker-stable-local.artifactory-na.honeywell.com
docker rmi awsps-docker-stable-local.artifactory-na.honeywell.com/awsps:latest
