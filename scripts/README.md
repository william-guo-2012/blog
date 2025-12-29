# Hugo 文章导入脚本使用说明

这些脚本帮助你自动从 `D:\OneDrive\writing\essays` 导入文章到 Hugo 博客。

## 脚本列表

### 1. `import-article.ps1` - 导入单篇文章

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

### 2. `list-new-articles.ps1` - 批量导入新文章

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

### 方式一：写完一篇发布一篇
```powershell
# 在 Doom Emacs 中写完文章后
# 直接导入并发布
.\scripts\import-article.ps1 -ArticleName "我的新文章" -Publish
```

### 方式二：积累几篇再统一发布
```powershell
# 运行批量导入脚本
.\scripts\list-new-articles.ps1

# 选择要导入的文章编号
# 脚本会一次性处理并可选推送到 GitHub
```

### 方式三：先导入预览，确认后再发布
```powershell
# 1. 先导入到本地（不发布）
.\scripts\import-article.ps1 -ArticleName "我的新文章"

# 2. 本地预览
hugo server -D

# 3. 确认无误后手动提交
git add content/posts/我的新文章
git commit -m "添加新文章: 我的新文章"
git push
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

# 查看有哪些新文章
.\scripts\list-new-articles.ps1

# 或直接导入指定文章
.\scripts\import-article.ps1 -ArticleName "文章目录名"
```
