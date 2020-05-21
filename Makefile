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
	@echo "  setup-db-secret                    setup your database secrets"
	@echo "      username=<db username>               @param - Optional. The database username for using basic authentication"
	@echo "      password=<db password>               @param - Optional. The database password for using basic authentication"
	@echo "  deploy-db                          deploy postgres for use with the hive metastore"
	@echo "      namespace=<namespace>                @param - Optional. The deploy namespace (default koku)"
	@echo "  setup-metastore-secret             setup your metastore s3 bucket secrets"
	@echo "      key=<s3 bucket access key>           @param - Optional. The AWS access key for authentication"
	@echo "      secret=<s3 bucket secret>            @param - Optional. The AWS secret for authentication"
	@echo "  deploy-metastore                   edit the metastore.yaml and deploy the hive metastore"
	@echo "      username=<db username>               @param - Optional. The database username for basic authentication"
	@echo "      password=<db password>               @param - Optional. The database password for basic authentication"
	@echo "      s3path=<s3 path>                     @param - Optional. The AWS S3 path"
	@echo "      namespace=<namespace>                @param - Optional. The deploy namespace (default koku)"


setup-pull-secret:
    oc get secret pull-secret --namespace=openshift-config --export -o yaml | oc apply -f -

setup-db-secret:
	@cp deploy/db-secret.yaml testing/db-secret.yaml
	@sed -i "" 's/cG9zdGdyZXM=/$(shell printf "$(shell echo $(or $(username),postgres))" | base64)/g' testing/db-secret.yaml
	@sed -i "" 's/cG9zdGdyZXM=/$(shell printf "$(shell echo $(or $(password),postgres))" | base64)/g' testing/db-secret.yaml
	oc apply -f testing/db-secret.yaml

setup-metastore-secret:
	@cp deploy/s3-secret.yaml testing/s3-secret.yaml
	@sed -i "" 's/cG9zdGdyZXM=/$(shell printf "$(shell echo $(or $(username),postgres))" | base64)/g' testing/s3-secret.yaml
	@sed -i "" 's/cG9zdGdyZXM=/$(shell printf "$(shell echo $(or $(password),postgres))" | base64)/g' testing/s3-secret.yaml
	oc apply -f testing/s3-secret.yaml

deploy-db:
	@cp deploy/postgres.yaml testing/postgres.yaml
	oc process -f testing/postgres.yaml -p NAMESPACE="$(shell echo $(or $(namespace),koku))" | oc create -f -

deploy-metastore:
	@cp deploy/metastore.yaml testing/metastore.yaml
	@cp deploy/core-site.xml testing/core-site.xml
	@sed -i "" 's/s3path/$(shell echo $(or $(s3path),metastore))/g' testing/core-site.xml
	oc create secret generic hadoop-config --from-file=testing/core-site.xml --type=Opaque
	oc process -f testing/metastore.yaml -p DB_USER="$(shell echo $(or $(username),postgres))" -p DB_PASSWORD="$(shell echo $(or $(password),postgres))" -p S3_PATH="$(shell echo $(or $(s3path),metastore))" | oc create -f -