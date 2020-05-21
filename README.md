# presto-on-ocp4
Setup for running Presto with Hive Metastore on OpenShift 4 as extended from [this blog post](https://medium.com/@joshua_robinson/presto-powered-s3-data-warehouse-on-kubernetes-aea89d2f40e8).

# How to Use

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

Assumptions: Working OpenShift 4 deployment and S3 object store (AWS).

Things you may need to modify:
* Memory settings and worker counts.

# What's next

You can log into presto with the CLI:

```
oc exec -it presto-coordinator-0 presto-cli -- --server presto:8080 --catalog hive  --schema default
```

Now that your connection works you can generate some data in s3 with the following command:

```
./gendata.sh <s3bucket-with-path>
```

From here you can port-foward or create a route for redash and and start querying and building charts as discussed in the blog above.