# kitchen_compass_terraform
## 概要  
kitchen compassアプリケーションのインフラ管理リポジトリ  

## 構成図
![img](img/architecture.drawio.png)

## デプロイ方法
### 前提
- tfstate格納用バケットを作成し、teraform.tfに記載します
```t
terraform {
  backend "s3" {
    bucket       = <バケット名>
    key          = "app/terraform.tfstate"
    region       = "ap-northeast-1"
    encrypt      = true
    use_lockfile = true
  }
}
```
- Route53で事前にドメインを購入します

### 手順
- terraform.tfvarsを編集します
```
// システム名
system = "kitcom"
// 環境名
env    = "prd"
// リージョン
region = "ap-northeast-1"
# Ubuntu 20.04 LTS
ami_id = "ami-00247e9dc9591c233"
# ドメイン名
domain_name = <購入したドメイン名>
# キーペア名
key_name = "kitcom"
```

- initします
```
terraform init
```

- planとapplyを実行します
```
terraform plan
terraform apply
```
