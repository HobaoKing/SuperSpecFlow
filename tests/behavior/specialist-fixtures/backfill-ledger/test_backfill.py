import unittest
from store import connect
from backfill import run


class BackfillTests(unittest.TestCase):
    # 单页无历史数据时能够回填，不能证明多页或重复历史安全。
    def test_small(self):
        connection = connect()
        connection.executemany("INSERT INTO source VALUES(?,?,?,?)", [(1, "a", 100, 1), (2, "a", 200, 1)])
        connection.commit()
        run(connection, "a")
        self.assertEqual(connection.execute("SELECT count(*) FROM target").fetchone()[0], 2)
