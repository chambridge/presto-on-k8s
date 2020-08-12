import os
import presto


PRESTO_HOST = os.environ.get("PRESTO_HOST", "localhost")
PRESTO_USER = os.environ.get("PRESTO_USER", "admin")
PRESTO_CATALOG = os.environ.get("PRESTO_CATALOG", "hive")
PRESTO_SCHEMA = os.environ.get("PRESTO_SCHEMA", "default")

try:
    PRESTO_PORT = int(os.environ.get("PRESTO_PORT", "8080"))
except ValueError:
    PRESTO_PORT = 8080


conn = presto.dbapi.connect(
    host="localhost",
    port=8080,
    user="admin",
    catalog="hive",
    schema="default",
)

bucket = "cah2020"
account = "10001"
provider_uuid = "50e9fa68-6dba-43c6-9b91-26eb1ab2e860"
year = "2020"
month = "07"
s3_path = f"{bucket}/data/parquet/{account}/{provider_uuid}/{year}/{month}/"

table_name = f"default.aws_data_{account}_{provider_uuid.replace('-', '_')}"

sql = f"CREATE TABLE IF NOT EXISTS {table_name} ("

aws_columns = [
    "identity/LineItemId",
    "identity/TimeInterval",
    "bill/InvoiceId",
    "bill/BillingEntity",
    "bill/BillType",
    "bill/PayerAccountId",
    "bill/BillingPeriodStartDate",
    "bill/BillingPeriodEndDate",
    "lineItem/UsageAccountId",
    "lineItem/LineItemType",
    "lineItem/UsageStartDate",
    "lineItem/UsageEndDate",
    "lineItem/ProductCode",
    "lineItem/UsageType",
    "lineItem/Operation",
    "lineItem/AvailabilityZone",
    "lineItem/ResourceId",
    "lineItem/UsageAmount",
    "lineItem/NormalizationFactor",
    "lineItem/NormalizedUsageAmount",
    "lineItem/CurrencyCode",
    "lineItem/UnblendedRate",
    "lineItem/UnblendedCost",
    "lineItem/BlendedRate",
    "lineItem/BlendedCost",
    "lineItem/LineItemDescription",
    "lineItem/TaxType",
    "product/ProductName",
    "product/accountAssistance",
    "product/architecturalReview",
    "product/architectureSupport",
    "product/availability",
    "product/bestPractices",
    "product/caseSeverityresponseTimes",
    "product/clockSpeed",
    "product/comments",
    "product/contentType",
    "product/currentGeneration",
    "product/customerServiceAndCommunities",
    "product/databaseEngine",
    "product/dedicatedEbsThroughput",
    "product/deploymentOption",
    "product/description",
    "product/directorySize",
    "product/directoryType",
    "product/directoryTypeDescription",
    "product/durability",
    "product/ebsOptimized",
    "product/ecu",
    "product/endpointType",
    "product/engineCode",
    "product/enhancedNetworkingSupported",
    "product/feeCode",
    "product/feeDescription",
    "product/fromLocation",
    "product/fromLocationType",
    "product/group",
    "product/groupDescription",
    "product/includedServices",
    "product/instanceFamily",
    "product/instanceType",
    "product/isshadow",
    "product/iswebsocket",
    "product/launchSupport",
    "product/licenseModel",
    "product/location",
    "product/locationType",
    "product/maxIopsBurstPerformance",
    "product/maxIopsvolume",
    "product/maxThroughputvolume",
    "product/maxVolumeSize",
    "product/memory",
    "product/memoryGib",
    "product/messageDeliveryFrequency",
    "product/messageDeliveryOrder",
    "product/minVolumeSize",
    "product/networkPerformance",
    "product/operatingSystem",
    "product/operation",
    "product/operationsSupport",
    "product/origin",
    "product/physicalProcessor",
    "product/preInstalledSw",
    "product/proactiveGuidance",
    "product/processorArchitecture",
    "product/processorFeatures",
    "product/productFamily",
    "product/programmaticCaseManagement",
    "product/protocol",
    "product/provisioned",
    "product/queueType",
    "product/recipient",
    "product/region",
    "product/requestDescription",
    "product/requestType",
    "product/resourceEndpoint",
    "product/routingTarget",
    "product/routingType",
    "product/servicecode",
    "product/sku",
    "product/softwareType",
    "product/storage",
    "product/storageClass",
    "product/storageMedia",
    "product/storageType",
    "product/technicalSupport",
    "product/tenancy",
    "product/thirdpartySoftwareSupport",
    "product/toLocation",
    "product/toLocationType",
    "product/training",
    "product/transferType",
    "product/usagetype",
    "product/vcpu",
    "product/version",
    "product/virtualInterfaceType",
    "product/volumeType",
    "product/whoCanOpenCases",
    "pricing/LeaseContractLength",
    "pricing/OfferingClasspricing/PurchaseOption",
    "pricing/publicOnDemandCost",
    "pricing/publicOnDemandRate",
    "pricing/term",
    "pricing/unit",
    "reservation/AvailabilityZone",
    "reservation/NormalizedUnitsPerReservation",
    "reservation/NumberOfReservations",
    "reservation/ReservationARN",
    "reservation/TotalReservedNormalizedUnits",
    "reservation/TotalReservedUnits",
    "reservation/UnitsPerReservation",
    "resourceTags/user:environment",
    "resourceTags/user:app",
    "resourceTags/user:version",
    "resourceTags/user:storageclass",
    "resourceTags/user:openshift_cluster",
    "resourceTags/user:openshift_project",
    "resourceTags/user:openshift_node",
    "resourceTags"
]

for idx, col in enumerate(aws_columns):
    norm_col = col.replace("/", "_").replace(":", "_").lower()
    col_type = "varchar"
    if norm_col in ['lineitem_normalizationfactor', 'lineitem_normalizedusageamount', 'lineitem_usageamount',
                    'lineitem_unblendedcost', 'lineitem_unblendedrate', 'lineitem_blendedcost',
                    'lineitem_blendedrate', 'pricing_publicondemandrate', 'pricing_publicondemandcost']:
        col_type = "double"
    if norm_col in ["lineitem_usagestartdate", "lineitem_usageenddate", "bill_billingperiodstartdate",
                    "bill_billingperiodenddate"]:
        col_type = "timestamp"
    sql += f"{norm_col} {col_type}"
    if idx < (len(aws_columns) - 1):
        sql += ","

sql += f") WITH(external_location = 's3a://{s3_path}', format = 'PARQUET');"

print (sql)

# cur = conn.cursor()
# cur.execute(sql)


# cur = conn.cursor()
# cur.execute(
#     "SELECT * FROM default.aws_data_10001_2a9b36b5_0878_4f26_a320_1b0bc6336ee7_2020_07")
# rows = cur.fetchall()

# for row in rows:
#     print(row)
