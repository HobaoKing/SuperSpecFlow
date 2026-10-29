# 配置刷新

Refresher 在后台线程拉取配置条目，规范化（去空白、转小写）后发布快照。公开接口保持不变：`refresh_async()` 返回可 `join()` 的线程对象，`snapshot()` 返回 `(version, value)`。

契约：调用方用 version 判断是否有新配置，因此 snapshot 的 version 与 value 必须来自同一次成功刷新，读到新 version 时必须同时读到对应 value。每次成功刷新 version 加一；fetch 抛错时快照保持不变。

使用 `/usr/bin/python3 -B -m unittest -v` 验证。

近期 CI 失败日志（同一提交，多次运行中偶发）：

```
FAIL: test_refresh_publishes_new_snapshot
AssertionError: Tuples differ: (0, None) != (1, ['b', 'a'])
```

```
FAIL: test_refresh_publishes_new_snapshot
AssertionError: Tuples differ: (1, None) != (1, ['b', 'a'])
```
