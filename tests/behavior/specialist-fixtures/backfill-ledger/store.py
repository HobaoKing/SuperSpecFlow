import sqlite3


# 创建真实 SQLite 表；target 保留历史宽松结构，修复需兼容已有重复行。
def connect(path=":memory:"):
    connection = sqlite3.connect(path)
    connection.executescript("""
      CREATE TABLE IF NOT EXISTS source(id INTEGER PRIMARY KEY, tenant TEXT, amount INTEGER, eligible INTEGER);
      CREATE TABLE IF NOT EXISTS target(source_id INTEGER, tenant TEXT, amount INTEGER);
      CREATE TABLE IF NOT EXISTS checkpoint(tenant TEXT PRIMARY KEY, watermark INTEGER);
    """)
    return connection
