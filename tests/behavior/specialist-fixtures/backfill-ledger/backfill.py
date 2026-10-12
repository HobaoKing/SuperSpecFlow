# 分页复制本租户合格账目；写入后保存偏移，故障在批次落地之后注入。
def run(connection, tenant, batch_size=50, interrupt_after=None):
    record = connection.execute("SELECT watermark FROM checkpoint WHERE tenant=?", (tenant,)).fetchone()
    offset = record[0] if record else 0
    batches = 0
    while True:
        rows = connection.execute(
            "SELECT id,amount FROM source WHERE tenant=? AND eligible=1 AND id NOT IN "
            "(SELECT source_id FROM target WHERE tenant=?) ORDER BY id LIMIT ? OFFSET ?",
            (tenant, tenant, batch_size, offset)).fetchall()
        if not rows:
            return
        connection.executemany("INSERT INTO target VALUES(?,?,?)", [(ident, tenant, amount) for ident, amount in rows])
        connection.commit()
        batches += 1
        if interrupt_after is not None and batches >= interrupt_after:
            raise InterruptedError("after persisted batch")
        offset += len(rows)
        connection.execute("INSERT OR REPLACE INTO checkpoint VALUES(?,?)", (tenant, offset))
        connection.commit()
