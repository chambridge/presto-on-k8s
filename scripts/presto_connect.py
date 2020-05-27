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
cur = conn.cursor()
cur.execute("SELECT * FROM system.runtime.nodes")
rows = cur.fetchall()

for row in rows:
    print(row)

