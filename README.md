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

### Setup LocalStack (Make S3 bucket)

```bash
./sandbox/scripts/setup_localstack.sh 
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
