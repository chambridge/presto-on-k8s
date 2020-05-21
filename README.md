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
make deploy-metastore username=<db user> password=<db password> s3path=<s3bucket>
```

3. Deploy Presto services (coordinator, workers, and cli)

4. Deploy Redash.

Assumptions: Working OpenShift 4 deployment and S3 object store (AWS).

Things you may need to modify:
* Memory settings and worker counts.

# Hive Metastore Service

Dockerfile for Metastore
 * Uses [Hive Metastore Standalone service](https://cwiki.apache.org/confluence/display/Hive/AdminManual+Metastore+3.0+Administration).

Yaml for PostgresSQL
 * Simple and not optimized.

Yaml for init-schemas
 * One-time K8s job to initiate the Postgres tables.

Yaml for Metastore

# Presto Coordinator/Workers/CLI

Dockerfile for PrestoSql.

Script: autoconfig_and_launch.sh
 * Generate final presto config files at pod startup time.

Yaml for Presto Coordinator/Workers

Dockerfile for Presto CLI
 * Simple image to make interactive use of Presto easier.
