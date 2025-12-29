# Hugo 文章导入脚本
# 用法: .\scripts\import-article.ps1 -ArticleName "文章目录名" [-Publish]

param(
    [Parameter(Mandatory=$true)]
    [string]$ArticleName,

    [Parameter(Mandatory=$false)]
    [switch]$Publish = $false
)

$EssaysDir = "D:\OneDrive\writing\essays"
$BlogDir = "D:\OneDrive\repo\blog"
$SourceDir = Join-Path $EssaysDir $ArticleName
$TargetDir = Join-Path $BlogDir "content\posts\$ArticleName"

# 检查源目录是否存在
if (-not (Test-Path $SourceDir)) {
    Write-Error "错误: 找不到文章目录 $SourceDir"
    exit 1
}

# 检查 index.md 是否存在
$SourceIndexMd = Join-Path $SourceDir "index.md"
if (-not (Test-Path $SourceIndexMd)) {
    Write-Error "错误: 找不到 $SourceIndexMd"
    exit 1
}

# 读取原文件内容
$content = Get-Content $SourceIndexMd -Raw -Encoding UTF8

# 检查是否已有 front matter
if ($content -match '^---\s*\n') {
    Write-Host "文章已包含 front matter，将直接复制" -ForegroundColor Yellow
    $needsFrontMatter = $false
} else {
    $needsFrontMatter = $true

    # 提取第一行作为标题
    $firstLine = ($content -split "`n")[0]
    $title = $firstLine -replace '^#+\s*', ''

    # 获取当前日期
    $date = Get-Date -Format "yyyy-MM-dd"

    # 让用户输入分类和标签
    Write-Host "`n文章标题: $title" -ForegroundColor Cyan
    Write-Host "发布日期: $date" -ForegroundColor Cyan

    $categories = Read-Host "`n请输入分类（用逗号分隔，如：年度总结,随笔）"
    $tags = Read-Host "请输入标签（用逗号分隔，如：生活,投资,阅读）"
    $draft = Read-Host "是否为草稿？(y/n，默认n)"

    $isDraft = if ($draft -eq 'y') { "true" } else { "false" }

    # 处理分类和标签
    $categoryArray = ($categories -split ',').Trim() | ForEach-Object { "`"$_`"" }
    $tagArray = ($tags -split ',').Trim() | ForEach-Object { "`"$_`"" }
    $categoryStr = $categoryArray -join ', '
    $tagStr = $tagArray -join ', '

    # 创建 front matter
    $frontMatter = @"
---
title: "$title"
date: $date
draft: $isDraft
categories: [$categoryStr]
tags: [$tagStr]
---

"@
}

# 创建目标目录
if (Test-Path $TargetDir) {
    Write-Host "`n警告: 目标目录已存在 $TargetDir" -ForegroundColor Yellow
    $overwrite = Read-Host "是否覆盖？(y/n)"
    if ($overwrite -ne 'y') {
        Write-Host "操作已取消" -ForegroundColor Red
        exit 0
    }
    Remove-Item $TargetDir -Recurse -Force
}

New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null

# 复制并处理 index.md
$targetIndexMd = Join-Path $TargetDir "index.md"
if ($needsFrontMatter) {
    $newContent = $frontMatter + $content
    Set-Content -Path $targetIndexMd -Value $newContent -Encoding UTF8
    Write-Host "`n已添加 front matter 并复制 index.md" -ForegroundColor Green
} else {
    Copy-Item $SourceIndexMd $targetIndexMd -Force
    Write-Host "`n已复制 index.md" -ForegroundColor Green
}

# 复制图片目录
$sourceImagesDir = Join-Path $SourceDir "images"
if (Test-Path $sourceImagesDir) {
    $targetImagesDir = Join-Path $TargetDir "images"
    Copy-Item $sourceImagesDir $targetImagesDir -Recurse -Force
    $imageCount = (Get-ChildItem $targetImagesDir -File).Count
    Write-Host "已复制 $imageCount 个图片文件" -ForegroundColor Green
}

Write-Host "`n文章导入完成！" -ForegroundColor Green
Write-Host "目标路径: $TargetDir" -ForegroundColor Cyan

# 如果指定了 -Publish 参数，则提交并推送
if ($Publish) {
    Write-Host "`n开始发布到 GitHub..." -ForegroundColor Cyan

    Set-Location $BlogDir

    # Git 操作
    git add "content/posts/$ArticleName"

    $commitMessage = @"
添加新文章: $title

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
"@

    git commit -m $commitMessage
    git push

    Write-Host "`n已推送到 GitHub，等待部署完成..." -ForegroundColor Green
    Write-Host "查看部署状态: https://github.com/william-guo-2012/blog/actions" -ForegroundColor Cyan
} else {
    Write-Host "`n提示: 使用 -Publish 参数可以直接提交并推送到 GitHub" -ForegroundColor Yellow
    Write-Host "示例: .\scripts\import-article.ps1 -ArticleName `"$ArticleName`" -Publish" -ForegroundColor Yellow
}
