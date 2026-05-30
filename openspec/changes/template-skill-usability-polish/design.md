# Design: template-skill-usability-polish

## Architecture Summary

模板只增加本地填写提示，不变成长篇教程。Skills 保持阶段职责：`ssf-build` 负责 build gate，Karpathy/Git 详细纪律通过引用对应 skill 减少重复；`ssf-retro` 和 `ssf-archive` 补齐一致性缺口。

## Template Guidance Style

每个骨架模板最多加入 2-3 行短说明或一行 example row。说明必须保留 placeholders，不写入项目特定内容。

## Review Gate

本 child 的实现前必须写入 `engineering/template-skill-usability-polish/review-consensus.md`。
