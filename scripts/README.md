# Hugo 文章导入脚本使用说明

这些脚本帮助你自动从 `D:\OneDrive\writing\essays` 导入文章到 Hugo 博客。

## 脚本列表

### 1. `publish.ps1` - 发布博客更改 ⭐

**用法：**
```powershell
# 快速发布（会提示输入提交信息）
.\scripts\publish.ps1

# 或直接指定提交信息
.\scripts\publish.ps1 -Message "更新2025年度总结文章"
```

**功能：**
- 自动检测并显示所有更改（新增、修改、删除的文章）
- 提交所有更改并推送到 GitHub
- 自动触发 GitHub Actions 部署
- 适用于编辑、更新或删除文章后的发布

**使用场景：**
- ✏️ 在 blog 目录直接编辑了文章
- 🗑️ 删除了某篇文章
- 🖼️ 更新了文章中的图片
- 🎨 修改了 CSS 样式
- ⚙️ 更改了配置文件

**示例：**
```powershell
# 场景1: 修改文章内容后
# 编辑 content/posts/2025年度总结/index.md
.\scripts\publish.ps1 -Message "修复2025年度总结中的错别字"

# 场景2: 删除文章
# 删除 content/posts/旧文章/
.\scripts\publish.ps1 -Message "删除过时的草稿文章"

# 场景3: 更新图片
# 替换 content/posts/文章/images/图片.jpg
.\scripts\publish.ps1 -Message "更新文章配图"
```

---

### 2. `import-article.ps1` - 导入单篇文章

**用法：**
```powershell
# 基本导入（不发布）
.\scripts\import-article.ps1 -ArticleName "文章目录名"

# 导入并直接发布到 GitHub
.\scripts\import-article.ps1 -ArticleName "文章目录名" -Publish
```

**功能：**
- 从 essays 目录复制指定文章到 `content/posts/`
- 自动检测是否已有 front matter
- 如果没有，会提示你输入分类、标签等信息
- 自动复制文章中的图片
- 可选直接提交并推送到 GitHub

**示例：**
```powershell
# 导入"2025年度总结"文章
.\scripts\import-article.ps1 -ArticleName "2025年度总结"

# 导入并发布
.\scripts\import-article.ps1 -ArticleName "投资笔记" -Publish
```

---

### 3. `list-new-articles.ps1` - 批量导入新文章

**用法：**
```powershell
.\scripts\list-new-articles.ps1
```

**功能：**
- 自动扫描 essays 目录
- 列出所有未导入的文章
- 可以选择导入单篇、多篇或全部
- 批量处理后可统一提交推送

**交互流程：**
```
发现 3 篇新文章:

[1] 读书笔记-2025
    标题: 2025年读书笔记

[2] 投资总结-Q1
    标题: 2025年第一季度投资总结

[3] 技术随笔
    标题: Doom Emacs 配置心得

请输入要导入的文章编号（多个用逗号分隔，输入 'all' 导入全部，按 Enter 退出）: 1,2

将导入 2 篇文章
...
所有文章导入完成！
是否要提交并推送到 GitHub？(y/n): y
```

---

## 工作流程建议

### 方式一：直接在 blog 目录编辑并发布 ⭐ 推荐
```powershell
# 1. 直接在 blog 目录编辑文章
# 编辑 D:\OneDrive\repo\blog\content\posts\文章名\index.md

# 2. 发布更改
cd D:\OneDrive\repo\blog
.\scripts\publish.ps1

# 就这么简单！
```

### 方式二：从 essays 导入新文章并发布
```powershell
# 在 Doom Emacs 中写完文章后
# 直接导入并发布
.\scripts\import-article.ps1 -ArticleName "我的新文章" -Publish
```

### 方式三：积累几篇再统一发布
```powershell
# 运行批量导入脚本
.\scripts\list-new-articles.ps1

# 选择要导入的文章编号
# 脚本会一次性处理并可选推送到 GitHub
```

### 方式四：先预览再发布
```powershell
# 1. 编辑文章
# 编辑 content/posts/文章名/index.md

# 2. 本地预览
hugo server -D
# 打开浏览器访问 http://localhost:1313/blog/

# 3. 确认无误后发布
.\scripts\publish.ps1
```

---

## Front Matter 说明

脚本会自动添加以下 front matter（如果文章还没有的话）：

```yaml
---
title: "文章标题"          # 从第一行标题提取
date: 2025-12-29          # 当前日期
draft: false              # 是否草稿
categories: ["分类1"]      # 文章分类
tags: ["标签1", "标签2"]   # 文章标签
---
```

**常用分类建议：**
- 年度总结
- 读书笔记
- 投资笔记
- 技术随笔
- 生活随笔

**常用标签建议：**
- 生活
- 投资
- 阅读
- 技术
- Emacs
- 家庭

---

## 注意事项

1. **路径要求：** 文章必须是 page bundle 格式：
   ```
   文章目录名/
   ├── index.md
   └── images/
       ├── 图片1.jpg
       └── 图片2.png
   ```

2. **编码：** 脚本会使用 UTF-8 编码读写文件

3. **已存在文章：** 如果目标位置已有同名文章，会提示是否覆盖

4. **Git 配置：** 确保已配置好 Git 用户名和邮箱

5. **GitHub 认证：** 确保已完成 GitHub 认证（gh auth login）

---

## 快速开始

```powershell
# 进入博客目录
cd D:\OneDrive\repo\blog

# 场景1: 编辑/更新/删除文章后发布
.\scripts\publish.ps1

# 场景2: 导入 essays 中的新文章
.\scripts\list-new-articles.ps1
# 或
.\scripts\import-article.ps1 -ArticleName "文章目录名"
```

---

## 常见操作速查

| 操作 | 命令 |
|------|------|
| 发布任何更改 | `.\scripts\publish.ps1` |
| 修改文章内容 | 编辑 `content/posts/文章/index.md` 后运行 `publish.ps1` |
| 删除文章 | 删除 `content/posts/文章/` 文件夹后运行 `publish.ps1` |
| 更新图片 | 替换 `content/posts/文章/images/` 中的图片后运行 `publish.ps1` |
| 导入新文章 | `.\scripts\import-article.ps1 -ArticleName "文章名"` |
| 批量导入 | `.\scripts\list-new-articles.ps1` |
| 本地预览 | `hugo server -D` 然后访问 http://localhost:1313/blog/ |
