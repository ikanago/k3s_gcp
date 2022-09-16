# k3s GCP

## Prerequisites
1. Create project in GCP.
2. Install gcloud. See [Installing Cloud SDK](https://cloud.google.com/sdk/docs/install).
3. Login gcloud.
```bash
gcloud auth login
```
4. Run following command. This helps terraform access Google API. For more detail: [gcloud auth application-default](https://cloud.google.com/sdk/gcloud/reference/auth/application-default)
```bash
gcloud auth application-default login
```

## Usage
1. Initialize terraform project.
```bash
terraform init
```
2. Plan. Suuply your GCP project name in `PROJECT_ID`.
```bash
terraform plan -var "project=PROJECT_ID"
```
3. Apply.
```bash
terraform apply -var "project=PROJECT_ID"
```
4. Firewall to use IAP is enabled. So access VM by following command. Replace `INSTANCE_NAME` with the name of currently created instance.
```bash
gcloud beta compute ssh INSTANCE_NAME --tunnel-through-iap
```

