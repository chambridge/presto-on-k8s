OS := $(shell uname)
ifeq ($(OS),Darwin)
	PREFIX	=
else
	PREFIX	= sudo
endif


help:
	@echo "Please use \`make <target>' where <target> is one of:"
	@echo "--- Setup Commands ---"
	@echo "  setup-pull-secret                  setup the pull secret for the Red Hat registry (assumes OCP4/CRC)"
	@echo "  setup-metastore-secret             setup your metastore s3 bucket secrets"
	@echo "      key=<s3 bucket access key>           @param - Optional. The AWS access key for authentication"
	@echo "      secret=<s3 bucket secret>            @param - Optional. The AWS secret for authentication"
	@echo "  deploy-metastore                   edit the metastore.yaml and deploy the hive metastore"
	@echo "      s3bucket=<s3 path>                     @param - Optional. The AWS S3 bucket"
	@echo "  deploy-presto                     deploy the presto-coordinator and worker"
	@echo "  deploy-redash                     deploy the redash UI"
	@echo "  init-redash                       initialize the redash UI"


setup-pull-secret:
	oc get secret pull-secret --namespace=openshift-config --export -o yaml | oc apply -f -

setup-metastore-secret:
	@cp deploy/s3-secret.yaml testing/s3-secret.yaml
	@sed -i "" 's/a29rdS1kYg==/$(shell printf "$(shell echo $(or $(key),aws_key))" | base64)/g' testing/s3-secret.yaml
	@sed -i "" 's/cG9zdGdyZXM=/$(shell printf "$(shell echo $(or $(secret),aws_secret))" | base64)/g' testing/s3-secret.yaml
	oc apply -f testing/s3-secret.yaml

deploy-metastore:
	@cp deploy/metastore.yaml testing/metastore.yaml
	@cp deploy/core-site.xml testing/core-site.xml
	@sed -i "" 's/s3path/$(shell echo $(or $(s3bucket),metastore))/g' testing/core-site.xml
	oc create secret generic hadoop-config --from-file=testing/core-site.xml --type=Opaque
	oc process -f testing/metastore.yaml -p S3_PATH="$(shell echo $(or $(s3bucket),metastore))" | oc create -f -

deploy-presto:
	@cp deploy/presto.yaml testing/presto.yaml
	oc process -f testing/presto.yaml | oc create -f -

deploy-redash:
	@cp deploy/redash.yaml testing/redash.yaml
	oc process -f testing/redash.yaml | oc create -f -

init-redash:
	oc exec -it $$(oc get pods -o jsonpath='{.items[?(.status.phase=="Running")].metadata.name}' -l app=redash) -c server /app/bin/docker-entrypoint create_db

