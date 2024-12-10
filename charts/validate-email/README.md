## Helm

helm repo add besmirzanaj https://besmirzanaj.github.io/charts

Install locally from the repo:
helm install validate-email-release besmirzanaj/validate-email --namespace validate-email --create-namespace

Uninstall
helm uninstall validate-email --namespace validate-email 