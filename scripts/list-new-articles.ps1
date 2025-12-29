# 列出所有尚未导入的文章
# 用法: .\scripts\list-new-articles.ps1

$EssaysDir = "D:\OneDrive\writing\essays"
$BlogDir = "D:\OneDrive\repo\blog"
$BlogPostsDir = Join-Path $BlogDir "content\posts"

Write-Host "扫描 essays 目录..." -ForegroundColor Cyan
Write-Host "Essays 路径: $EssaysDir" -ForegroundColor Gray
Write-Host "Blog 路径: $BlogPostsDir`n" -ForegroundColor Gray

# 获取所有 essays 中的文章目录
$essayArticles = Get-ChildItem -Path $EssaysDir -Directory | Where-Object {
    Test-Path (Join-Path $_.FullName "index.md")
}

# 获取已导入的文章
$importedArticles = if (Test-Path $BlogPostsDir) {
    Get-ChildItem -Path $BlogPostsDir -Directory | Select-Object -ExpandProperty Name
} else {
    @()
}

# 找出未导入的文章
$newArticles = $essayArticles | Where-Object {
    $_.Name -notin $importedArticles
}

if ($newArticles.Count -eq 0) {
    Write-Host "没有发现新文章，所有文章都已导入。" -ForegroundColor Green
    exit 0
}

Write-Host "发现 $($newArticles.Count) 篇新文章:`n" -ForegroundColor Yellow

$i = 1
$articleList = @()
foreach ($article in $newArticles) {
    $indexMd = Join-Path $article.FullName "index.md"
    $firstLine = (Get-Content $indexMd -First 1 -Encoding UTF8) -replace '^#+\s*', ''

    Write-Host "[$i] $($article.Name)" -ForegroundColor Cyan
    Write-Host "    标题: $firstLine" -ForegroundColor Gray

    $articleList += @{
        Index = $i
        Name = $article.Name
        Title = $firstLine
    }
    $i++
}

Write-Host "`n" -NoNewline
$choice = Read-Host "请输入要导入的文章编号（多个用逗号分隔，输入 'all' 导入全部，按 Enter 退出）"

if ([string]::IsNullOrWhiteSpace($choice)) {
    Write-Host "操作已取消" -ForegroundColor Red
    exit 0
}

$selectedArticles = @()
if ($choice -eq 'all') {
    $selectedArticles = $articleList
} else {
    $indices = $choice -split ',' | ForEach-Object { [int]$_.Trim() }
    $selectedArticles = $articleList | Where-Object { $_.Index -in $indices }
}

Write-Host "`n将导入 $($selectedArticles.Count) 篇文章" -ForegroundColor Green

foreach ($article in $selectedArticles) {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "正在处理: $($article.Name)" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Cyan

    & "$BlogDir\scripts\import-article.ps1" -ArticleName $article.Name
}

Write-Host "`n所有文章导入完成！" -ForegroundColor Green
$publish = Read-Host "是否要提交并推送到 GitHub？(y/n)"

if ($publish -eq 'y') {
    Set-Location $BlogDir
    git add content/posts

    $commitMessage = @"
添加 $($selectedArticles.Count) 篇新文章

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
"@

    git commit -m $commitMessage
    git push

    Write-Host "`n已推送到 GitHub！" -ForegroundColor Green
    Write-Host "查看部署状态: https://github.com/william-guo-2012/blog/actions" -ForegroundColor Cyan
}
