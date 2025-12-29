# Hugo 博客发布脚本
# 用法: .\scripts\publish.ps1 [-Message "提交信息"]

param(
    [Parameter(Mandatory=$false)]
    [string]$Message = ""
)

$BlogDir = "D:\OneDrive\repo\blog"
Set-Location $BlogDir

# 检查是否有更改
$status = git status --porcelain
if ([string]::IsNullOrWhiteSpace($status)) {
    Write-Host "没有检测到任何更改，无需发布。" -ForegroundColor Yellow
    exit 0
}

Write-Host "检测到以下更改：`n" -ForegroundColor Cyan
git status --short

Write-Host "`n" -NoNewline

# 如果没有提供提交信息，则提示用户输入
if ([string]::IsNullOrWhiteSpace($Message)) {
    Write-Host "请描述本次更改（例如：更新文章、删除草稿、修复错别字）" -ForegroundColor Yellow
    $Message = Read-Host "提交信息"

    if ([string]::IsNullOrWhiteSpace($Message)) {
        Write-Host "错误: 提交信息不能为空" -ForegroundColor Red
        exit 1
    }
}

# 显示将要提交的内容
Write-Host "`n即将提交以下更改：" -ForegroundColor Cyan
git diff --stat

Write-Host "`n" -NoNewline
$confirm = Read-Host "确认提交并发布？(y/n)"

if ($confirm -ne 'y') {
    Write-Host "操作已取消" -ForegroundColor Red
    exit 0
}

# 添加所有更改
Write-Host "`n正在添加更改..." -ForegroundColor Cyan
git add -A

# 构建完整的提交信息（使用数组拼接避免 heredoc 问题）
$fullMessage = $Message + "`n`n" + "🤖 Generated with [Claude Code](https://claude.com/claude-code)`n`n" + "Co-Authored-By: Claude Sonnet 4.5 " + "<" + "noreply@anthropic.com" + ">"

# 提交
Write-Host "正在提交..." -ForegroundColor Cyan
git commit -m $fullMessage

# 推送到 GitHub
Write-Host "正在推送到 GitHub..." -ForegroundColor Cyan
git push

Write-Host "`n✅ 发布成功！" -ForegroundColor Green
Write-Host "GitHub Actions 正在自动部署网站..." -ForegroundColor Cyan
Write-Host "`n查看部署状态: https://github.com/william-guo-2012/blog/actions" -ForegroundColor Yellow
Write-Host "网站地址: https://william-guo-2012.github.io/blog/" -ForegroundColor Yellow
Write-Host "`n提示: 部署通常需要 1-2 分钟完成" -ForegroundColor Gray
