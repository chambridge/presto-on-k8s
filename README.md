# presto-on-ocp4
Setup for running Presto with Hive Metastore on OpenShift 4 as extended from [this blog post](https://medium.com/@joshua_robinson/presto-powered-s3-data-warehouse-on-kubernetes-aea89d2f40e8). Additionally, there is are Docker Compose instructions for alternate development environments.

## Assumptions
This project utilizes Red Hat software and assumes you have access to registry.redhat.io for both the OpenShift 4 and Docker Compose setup.

Deploying Presto on OpenShift 4 assumes you have a working OpenShift 4 cluster.

Both the OpenShift 4 deployment and Docker Compose setup assumes you have access to the S3 object store (AWS).

# OpenShift 4 Deployment

1. Setup pull secret in your project
```
oc project <project>
make setup-pull-secret
```

2. Deploy Hive Metastore (using Embedded Derby)

```
make setup-metastore-secret key=<aws access key> secret=<aws secret>
make deploy-metastore s3bucket=<s3bucket>
```

3. Deploy Presto services (coordinator, workers)

```
make deploy-presto
```

4. Deploy Redash.

```
make deploy-redash
```

5. Initialize Redash.
```
make init-redash
```

Things you may need to modify:
* Memory settings and worker counts.

## What's next

You can log into presto with the CLI:

```
oc exec -it presto-coordinator-0 presto-cli -- --server presto:8080 --catalog hive  --schema default
```

Now that your connection works you can generate some data in s3 with the following command:

```
./gendata.sh <s3bucket-with-path>
```

From here you can port-foward or create a route for redash and and start querying and building charts as discussed in the blog above.


# Docker Compose Deployment

1. Copy the example.env file to .env and update your AWS credential values
```
cp example.env .env
```

2. Source the .env file for use with Docker Compose
```
source .env
```

3. Start Docker Compose with S3 bucket
```
make docker-up s3bucket=<s3bucket>
```

4. View the Docker logs
```
make docker-logs
```

5. Launch the [presto UI - http://localhost:8080](http://localhost:8080)

6. Shutdown the containers
```
make docker-down
```
