# Usage

## Docker

### Start

```bash
docker compose up -d
docker compose exec work bash
```

### Stop

```bash
docker compose down
```

### Build

```bash
docker compose build
```

### Restart LocalStack to reset data

```bash
docker compose restart localstack
```

## In the sandbox

### Make S3 bucket

```bash
BUCKET_NAME=localstack-tfstate

aws s3api create-bucket \
    --bucket ${BUCKET_NAME} \
    --create-bucket-configuration LocationConstraint=ap-northeast-1

aws s3api put-bucket-versioning \
    --bucket ${BUCKET_NAME} \
    --versioning-configuration Status=Enabled

aws s3api put-public-access-block \
    --bucket ${BUCKET_NAME} \
    --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

aws s3api put-bucket-encryption \
    --bucket ${BUCKET_NAME} \
    --server-side-encryption-configuration '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}'
```

### Run

#### Plan

```bash
terragrunt run-all plan
```

#### Apply

```bash
terragrunt run-all apply
```

#### Apply with approve

```bash
terragrunt run-all apply --terragrunt-no-auto-approve --terragrunt-parallelism 1
```

### Format

```bash
terragrunt hclfmt
terraform fmt --recursive
```
