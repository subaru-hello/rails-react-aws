## デプロイ

### api

```
$ aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin 061293269148.dkr.ecr.ap-northeast-1.amazonaws.com
Login Succeeded

Logging in with your password grants your terminal complete access to your account. 
For better security, log in with a limited-privilege personal access token. Learn more at https://docs.docker.com/go/access-tokens/

SubarunoMacBook-puro-3:api subaru$ docker build -f prd/Dockerfile -t api .
$ docker tag api:latest 061293269148.dkr.ecr.ap-northeast-1.amazonaws.com/api:latest
$ docker push 061293269148.dkr.ecr.ap-northeast-1.amazonaws.com/api:latest
```

### blog-web

```
SubarunoMacBook-puro-3:blog-web subaru$ yarn run build
$ aws s3 cp ./build s3://blog-subaru-web/ --recursive --profile admin
```