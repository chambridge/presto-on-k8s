OS := $(shell uname)
ifeq ($(OS),Darwin)
	PREFIX	=
else
	PREFIX	= sudo
endif


help:
	@echo "Please use \`make <target>' where <target> is one of:"
	@echo "--- Commands using an OpenShift Cluster ---"
	@echo "  setup-pull-secret                  setup the pull secret for the Red Hat registry (assumes OCP4/CRC)"
	@echo "  setup-metastore-secret             setup your metastore s3 bucket secrets"
	@echo "      key=<s3 bucket access key>           @param - Required. The AWS access key for authentication"
	@echo "      secret=<s3 bucket secret>            @param - Required. The AWS secret for authentication"
	@echo "  deploy-metastore                   edit the metastore.yaml and deploy the hive metastore"
	@echo "      s3bucket=<s3 path>                     @param - Required. The AWS S3 bucket"
	@echo "  deploy-presto                      deploy the presto-coordinator and worker"
	@echo "  deploy-redash                      deploy the redash UI"
	@echo "  init-redash                        initialize the redash UI"
	@echo ""
	@echo "--- Commands using Docker Compose ---"
	@echo "  docker-up                          run docker-compose up -d"
	@echo "      s3bucket=<s3 path>                     @param - Required. The AWS S3 bucket"
	@echo "  docker-down                        shut down all containers"
	@echo "  docker-logs                        connect to console logs for all services"

setup-pull-secret:
	oc get secret pull-secret --namespace=openshift-config --export -o yaml | oc apply -f -

setup-metastore-secret:
	@cp deploy/s3-secret.yaml testing/s3-secret.yaml
	@sed -i "" 's/a29rdS1kYg==/$(shell printf "$(shell echo $(or $(key),aws_key))" | base64)/g' testing/s3-secret.yaml
	@sed -i "" 's/cG9zdGdyZXM=/$(shell printf "$(shell echo $(or $(secret),aws_secret))" | base64)/g' testing/s3-secret.yaml
	oc apply -f testing/s3-secret.yaml

deploy-metastore:
	@cp deploy/metastore.yaml testing/metastore.yaml
	@mkdir -p testing/metastore/hadoop-config/
	@cp deploy/metastore/hadoop-config/core-site.xml testing/metastore/hadoop-config/core-site.xml
	@sed -i "" 's/s3path/$(shell echo $(or $(s3bucket),metastore))/g' testing/metastore/hadoop-config/core-site.xml
	oc create secret generic hadoop-config --from-file=testing/metastore/hadoop-config/core-site.xml --type=Opaque
	oc process -f testing/metastore.yaml -p S3_PATH="$(shell echo $(or $(s3bucket),metastore))" | oc create -f -

deploy-presto:
	@cp deploy/presto.yaml testing/presto.yaml
	oc process -f testing/presto.yaml | oc create -f -

deploy-redash:
	@cp deploy/redash.yaml testing/redash.yaml
	oc process -f testing/redash.yaml | oc create -f -

init-redash:
	oc exec -it $$(oc get pods -o jsonpath='{.items[?(.status.phase=="Running")].metadata.name}' -l app=redash) -c server /app/bin/docker-entrypoint create_db

docker-down:
	docker-compose down

docker-logs:
	docker-compose logs -f

docker-metastore-setup:
	@cp -fr deploy/metastore/ testing/metastore/
	@cp -fr deploy/hadoop/ testing/hadoop/
	@sed -i "" 's/s3path/$(shell echo $(or $(s3bucket),metastore))/g' testing/hadoop/hadoop-config/core-site.xml
	@sed -i "" 's/s3path/$(shell echo $(or $(s3bucket),metastore))/g' testing/metastore/hive-config/hive-site.xml

docker-metastore-up: docker-metastore-setup
	docker-compose up -d hive-metastore

docker-presto-setup:
	@cp -fr deploy/presto/ testing/presto/
	@cp -fr deploy/hadoop/ testing/hadoop/
	@sed -i "" 's/s3path/$(shell echo $(or $(s3bucket),metastore))/g' testing/hadoop/hadoop-config/core-site.xml

docker-presto-up: docker-presto-setup
	docker-compose up -d presto

docker-up: docker-metastore-setup docker-presto-setup
	docker-compose up -d