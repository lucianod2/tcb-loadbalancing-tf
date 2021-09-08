# Google Cloud Platform Load balancing
Implementation of Cloud Load Balancing between regions in the US and Europe for global high availability and intelligent traffic distribution based on user proximity and location

Use an existing project in your account with the following APIs enabled: 
Compute Engine API
Cloud Build API
Cloud Run API
Cloud Resource Manager API
Cloud Pub/Sub API

## Steps 

# 1-Stage Unzipping APP
Unzip Europe App
```
unzip bootcamp-gcp-modulo-lb-files-app-finlandia.zip
```
Unzip USA App
```
unzip bootcamp-gcp-modulo-lb-files-app-eua.zip
```
# 2-Stage Build and Deploy
# Cloud Build
Build Europe App
```
cd ~/bootcamp-gcp-modulo-lb-files-app-finlandia
gcloud builds submit --tag gcr.io/$GOOGLE_PROJECT_ID/appkidsflixfinlandia
```
Build Europe App
```
cd ~/bootcamp-gcp-modulo-lb-files-app-eua
gcloud builds submit --tag gcr.io/$GOOGLE_PROJECT_ID/appkidsflixeua
```
# 3-Stage Terraform - Install Terraform
```
cd ../
terraform init
terraform plan -var=project_id=$GOOGLE_PROJECT_ID -var=ssl=false -var=domain=null -var=website=<your-website-url> -out=mytfplan
terraform apply mytfplan
terraform destroy -var=project_id=$GOOGLE_PROJECT_ID -var=ssl=false -var=domain=null -var=website=website=<your-website-url> 
```

```
Updating in progress...

```
*Live :v:
*Love :heart:
*Learn :see_no_evil: :hear_no_evil: :speak_no_evil:

:rocket::rocket::rocket:
*GCP
*Cloud Build
*Cloud Run
*Terraform
*pracima
*thecloudbootcamp
