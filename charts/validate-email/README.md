# validate-email

![Version: 0.2.5](https://img.shields.io/badge/Version-0.2.5-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.2.0](https://img.shields.io/badge/AppVersion-0.2.0-informational?style=flat-square)

# validate-email

Check email validity.

## Introduction

This code will validate an email address if it is active. When you run it, make sure your host is allowed outbound access to port 25. Some VPS providers will ont allow that.

Can be run with [webook](https://github.com/adnanh/webhook) in BASH or with [Flask](https://flask.palletsprojects.com/en/stable/) in Python.

## Running the program in BASH
The Bash version will only allow bearer token authentication with a username/password combination.

**Locally in BASH**

This is not meant to be run from the console. Use the docker version below. If absolutely you need to run it, then, first update the `VALIDATE_API_USER` and `VALIDATE_API_PASSWORD` variables in the `.env` file or declare them as environment variables. Then run the app. An example below with declaring the env variables on the fly

```bash
$  VALIDATE_API_USER=validate_user VALIDATE_API_PASSWORD=validate_password ./src/bash_entrypoint.sh
VALIDATE_API_PASSWORD=validate_password
VALIDATE_API_USER=validate_user
BEARER_TOKEN=dmFsaWRhdGVfdXNlcjp2YWxpZGF0ZV9wYXNzd29yZAo=
[webhook] 2024/12/06 18:01:06 version 2.8.0 starting
[webhook] 2024/12/06 18:01:06 setting up os signal watcher
[webhook] 2024/12/06 18:01:06 attempting to load hooks from ./src/valid_email.yml
[webhook] 2024/12/06 18:01:06 os signal watcher ready
[webhook] 2024/12/06 18:01:06 found 1 hook(s) in file
[webhook] 2024/12/06 18:01:06   loaded: validate_email
[webhook] 2024/12/06 18:01:06 serving hooks on http://0.0.0.0:9001/hooks/{id}
```

Then issue the call with curl:

```bash
VALIDATE_HOSTNAME="http://vps3.cloudalbania.com" # replace with the hostname you are running this, could be also 127.0.0.1
VALIDATE_URL="$VALIDATE_HOSTNAME:9001/hooks/validate_email"
VALIDATE_API_USER="validate_user" # update with your user here
VALIDATE_API_PASSWORD="validate_password" # update with your password here
VALIDATE_AUTH_HEADER="Authorization: Bearer $(echo $VALIDATE_API_USER:$VALIDATE_API_PASSWORD | base64)"

$ curl -s --url "$VALIDATE_URL" \
  -X POST -d '{"email":"besmirtv@gmail.com"}' \
  -H "Content-type: Application/json" \
  -H "$VALIDATE_AUTH_HEADER" | jq

{
  "email": "besmirtv@gmail.com",
  "status": "true"
}
```

**Bash in docker version**

Start it with the following. Remember that `VALIDATE_API_USER` and `VALIDATE_API_PASSWORD` are mandatory.

```
# docker run --rm -it \
  -e VALIDATE_API_USER="validate_user" \
  -e VALIDATE_API_PASSWORD="validate_password" \
  -p 9001:9001 \
  registry.gitlab.com/besmirzanaj/validate-email:webhook
Emulate Docker CLI using podman. Create /etc/containers/nodocker to quiet msg.
Show some variables for debug purposes
VALIDATE_API_USER=validate_user
VALIDATE_API_PASSWORD=validate_password
BEARER_TOKEN=dmFsaWRhdGVfdXNlcjp2YWxpZGF0ZV9wYXNzd29yZAo=
[webhook] 2024/12/07 00:28:40 version 2.8.2 starting
[webhook] 2024/12/07 00:28:40 setting up os signal watcher
[webhook] 2024/12/07 00:28:40 attempting to load hooks from ./src/valid_email.yml
[webhook] 2024/12/07 00:28:40 found 1 hook(s) in file
[webhook] 2024/12/07 00:28:40   loaded: validate_email
[webhook] 2024/12/07 00:28:40 serving hooks on http://0.0.0.0:9001/hooks/{id}
[webhook] 2024/12/07 00:28:40 os signal watcher ready
```

Validate

```bash
VALIDATE_HOSTNAME="http://vps1.cloudalbania.com" # replace with the hostname you are running this, could be also 127.0.0.1
VALIDATE_URL="$VALIDATE_HOSTNAME:9001/hooks/validate_email"
VALIDATE_API_USER="validate_user" # update with your user here
VALIDATE_API_PASSWORD="validate_password" # update with your password here
VALIDATE_AUTH_HEADER="Authorization: Bearer $(echo $VALIDATE_API_USER:$VALIDATE_API_PASSWORD | base64)"

curl -s --url "$VALIDATE_URL" \
  -X POST -d '{"email":"besmirtv@gmail.com"}' \
  -H "Content-type: Application/json" \
  -H "$VALIDATE_AUTH_HEADER" | jq

{
  "email": "besmirtv@gmail.com",
  "status": "true"
}
```

## Running the program in Python

### Build and run the app locally

```console
python3 -m venv .venv
. .venv/bin/activate
pip install -r requirements.txt
python src/valid_email.py
```

### TODO - est with no Auth validation

```
$ curl -s http://127.0.0.1:9001/validate_email -X POST -d '{"email":"besmirtv@gmail.com"}' -H 'Content-type: Application/json' | jq
{
  "email": "besmirtv@gmail.com",
  "status": "OK"
}
```

or

```
$ curl -s http://127.0.0.1:9001/validate_email -X POST -d @test.json -H 'Content-type: Application/json' | jq
{
  "email": "besmirzanaj@gmail.com",
  "status": "OK"
}
```

### Test with JWT Authentication

Either provide some environment values or create an `.env` file with the following structure:

```bash
$ cat .env
VALIDATE_JWT_SECRET_KEY="RANDOM_JWT_SECRET_KEY"
VALIDATE_API_USER="validate"
VALIDATE_API_PASSWORD="aiheihoi3wua4lei4ooph7aideiSha7"
```

#### Accessing straight to IP/domain port 9001

Login to get the token. Demo username and password below. Please change the environment variables as above for a prod environment.

```json
{
  "username": "validate",
  "password": "aiheihoi3wua4lei4ooph7aideiSha7"
}
```

Use the username and the password to get a new JWT token. Curl command:

```bash
VALIDATE_HOSTNAME="https://vps3.cloudalbania.com" # Update with your hostname. It can be also 127.0.0.1
VALIDATE_LOGIN_URL="$VALIDATE_HOSTNAME:9001/login"
VALIDATE_TOKEN=$(curl -X POST "$VALIDATE_LOGIN_URL" -H "Content-Type: application/json" -d '{"username": "validate", "password": "aiheihoi3wua4lei4ooph7aideiSha7"}' -s | jq .access_token -r)

echo $VALIDATE_TOKEN
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.<long_base64>.7pWZ7bwRu5lk0ww-vs5IaeYx-HoD3a2VZm4_Gi8Y0x0
```

Then use the token with the API on the `/validate_email` endpoint:

```bash
VALIDATE_API_URL="$VALIDATE_HOSTNAME:9001/validate_email"
curl -s "$VALIDATE_API_URL" -X POST -d '{"email":"besmirtv@gmail.com"}' -H 'Content-type: Application/json' -H "Authorization: Bearer $VALIDATE_TOKEN"

{
  "email": "besmirtv@gmail.com",
  "status": "true"
}
```

#### Accessing with cloudflare proxy/tunnel

```bash
VALIDATE_HOSTNAME=verify.cloudalbania.com
VALIDATE_LOGIN_URL="https://$VALIDATE_HOSTNAME/login"
VALIDATE_TOKEN=$(curl -X POST "$VALIDATE_LOGIN_URL" -H "Content-Type: application/json" -d '{"username": "validate", "password": "aiheihoi3wua4lei4ooph7aideiSha7"}' -s | jq .access_token -r)

echo $VALIDATE_TOKEN
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.<long_base64>.7pWZ7bwRu5lk0ww-vs5IaeYx-HoD3a2VZm4_Gi8Y0x0
```

Then use the token with the API

```bash
VALIDATE_API_URL="http://$VALIDATE_HOSTNAME/validate_email"
curl -s "$VALIDATE_API_URL" -X POST -d '{"email":"besmirtv@gmail.com"}' -H 'Content-type: Application/json' -H "Authorization: Bearer $VALIDATE_TOKEN"

{
  "email": "besmirtv@gmail.com",
  "status": "true"
}
```

## Helm

Install locally from the repo:
helm install validate-email-release besmirzanaj/validate-email --namespace validate-email --create-namespace

Uninstall
helm uninstall validate-email-release --namespace validate-email

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| credentials.validate_api_password | string | `nil` |  |
| credentials.validate_api_user | string | `nil` |  |
| credentials.validate_jwt_key | string | `nil` |  |
| fullnameOverride | string | `""` |  |
| image.pullPolicy | string | `"Always"` |  |
| image.repository | string | `"registry.gitlab.com/besmirzanaj/validate-email"` |  |
| image.tag | string | `"python"` |  |
| imagePullSecrets | list | `[]` |  |
| ingress.annotations | object | `{}` |  |
| ingress.className | string | `""` |  |
| ingress.enabled | bool | `false` |  |
| ingress.hosts[0].host | string | `"chart-example.local"` |  |
| ingress.hosts[0].paths[0].path | string | `"/"` |  |
| ingress.hosts[0].paths[0].pathType | string | `"ImplementationSpecific"` |  |
| ingress.tls | list | `[]` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| podAnnotations | object | `{}` |  |
| podLabels | object | `{}` |  |
| podSecurityContext | object | `{}` |  |
| replicaCount | int | `1` |  |
| resources.limits.cpu | string | `"100m"` |  |
| resources.limits.memory | string | `"128Mi"` |  |
| resources.requests.cpu | string | `"100m"` |  |
| resources.requests.memory | string | `"128Mi"` |  |
| securityContext | object | `{}` |  |
| service.port | int | `9001` |  |
| service.type | string | `"ClusterIP"` |  |
| tolerations | list | `[]` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
