# K-Dense 科学代理技能：Codex 安装器

这个仓库提供一个可重复执行的安装器，将
[K-Dense-AI/scientific-agent-skills](https://github.com/K-Dense-AI/scientific-agent-skills)
中的 Agent Skills 安装到**当前项目**的 `.agents/skills` 目录。安装器会查找全部
`SKILL.md` 目录，因此可随上游新增的科学技能一起安装，而不依赖硬编码的技能清单。

## Codex Web 安装

在包含本仓库的 Codex 终端中运行：

```bash
./scripts/install-scientific-agent-skills.sh
```

默认安装位置是当前仓库的 `.agents/skills`，而不是 `/root/.codex/skills`。这点在
Codex Web 中很重要：终端容器的 `/root` 目录可能会在命令或任务之间重置；项目工作区则
会随任务保留。完成后，从**同一仓库**新开一个 Codex 会话以加载技能。

### 验证安装

```bash
find .agents/skills -name SKILL.md | head -20
```

若该命令显示 K-Dense 的 `SKILL.md` 文件，安装已写入当前项目。若需要长期保留，请将
`.agents/skills` 添加到项目版本控制，或将其存放在您的组织提供的持久工作区中。

### 常用选项

```bash
# 将已安装的同名技能更新为上游版本
./scripts/install-scientific-agent-skills.sh --refresh

# 安装到另一个持久目录
./scripts/install-scientific-agent-skills.sh --target /workspace/my-project/.agents/skills

# 从已下载的 ZIP 安装（适用于离线或受限网络环境）
./scripts/install-scientific-agent-skills.sh --archive scientific-agent-skills-main.zip
```

安装器优先使用有效的本地 ZIP；本地文件不可用时，会从上游 GitHub 下载当前 `main`
分支的归档。它会在下载失败、归档损坏或找不到 `SKILL.md` 时退出并返回非零状态，避免
把不完整内容写入项目技能目录。
