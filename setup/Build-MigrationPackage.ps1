[CmdletBinding()]
param(
    # 작업 루트 (MD·API·데이터가 든 폴더). 기본값: 이 스크립트(MD\setup)의 두 단계 위
    [string]$WorkspaceRoot = '',
    # 패키지를 만들 위치. 기본값: <작업 루트>\이식패키지
    [string]$Output = '',
    # 커밋되지 않은 변경이나 아직 푸시하지 않은 커밋이 있어도 계속 만든다 (그 변경은 패키지에 들어가지 않는다)
    [switch]$Force
)

# 이식패키지 생성기.
# MD·API·데이터 세 저장소의 "커밋된 상태(HEAD)"를 Git 저장소째로 복제해 payload\ 에 담고,
# 설치 스크립트·안내문·명세(manifest.json)를 함께 둔다. 커밋되지 않은 변경, .env, 결과 파일(output), private 폴더는 들어가지 않는다.
# GitHub 에 푸시된 커밋과 같은 커밋을 담으므로, 패키지로 설치한 결과와 GitHub 에서 내려받아 설치한 결과가 같다.

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
try { [Console]::OutputEncoding = [Text.UTF8Encoding]::new($false) } catch { }
$setupDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
if ([string]::IsNullOrWhiteSpace($WorkspaceRoot)) { $WorkspaceRoot = Split-Path -Parent (Split-Path -Parent $setupDir) }
$WorkspaceRoot = [IO.Path]::GetFullPath($WorkspaceRoot).TrimEnd('\')
if ([string]::IsNullOrWhiteSpace($Output)) { $Output = Join-Path $WorkspaceRoot '이식패키지' }
$Output = [IO.Path]::GetFullPath($Output).TrimEnd('\')
$utf8 = [Text.UTF8Encoding]::new($false)
$script:NativeExitCode = 0

$repositories = @(
    [pscustomobject]@{ Folder = 'MD';     GitHub = 'https://github.com/tonysskim/MD.git' },
    [pscustomobject]@{ Folder = 'API';    GitHub = 'https://github.com/tonysskim/API.git' },
    [pscustomobject]@{ Folder = '데이터'; GitHub = 'https://github.com/tonysskim/data.git' }
)

function Invoke-Native {
    # 외부 프로그램을 실행하고 stdout+stderr 를 문자열 배열로 돌려준다 (PowerShell 5.1 의 stderr 오류 승격을 피한다).
    param([string]$Command, [string[]]$Arguments)
    $previous = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $lines = & $Command @Arguments 2>&1 | ForEach-Object { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_.Exception.Message } else { [string]$_ } }
        $script:NativeExitCode = $LASTEXITCODE
    } finally { $ErrorActionPreference = $previous }
    return @($lines)
}

function Invoke-Git {
    param([string]$Repo, [string[]]$Arguments)
    $output = Invoke-Native 'git' (@('-C', $Repo) + $Arguments)
    if ($script:NativeExitCode -ne 0) { throw ("git {0} 실패 ({1}): {2}" -f ($Arguments -join ' '), $Repo, ($output -join "`n")) }
    return $output
}

Invoke-Native 'git' @('lfs', 'version') | Out-Null
if ($script:NativeExitCode -ne 0) { throw 'Git LFS 가 필요합니다.' }

Write-Host ("작업 루트: {0}" -f $WorkspaceRoot)
Write-Host ("패키지 위치: {0}" -f $Output)

# ---------------------------------------------------------------- 1. 저장소 상태 점검
$repoInfo = @()
foreach ($repo in $repositories) {
    $src = Join-Path $WorkspaceRoot $repo.Folder
    if (-not (Test-Path -LiteralPath (Join-Path $src '.git') -PathType Container)) { throw ("Git 저장소가 아닙니다: {0}" -f $src) }
    $branch = (Invoke-Git $src @('rev-parse', '--abbrev-ref', 'HEAD')) -join ''
    $head = (Invoke-Git $src @('rev-parse', 'HEAD')) -join ''
    $dirty = @(Invoke-Git $src @('status', '--porcelain'))
    Invoke-Native 'git' @('-C', $src, 'fetch', 'origin', '--quiet') | Out-Null
    $upstream = (Invoke-Native 'git' @('-C', $src, 'rev-parse', "origin/$branch")) -join ''
    $pushed = ($upstream -eq $head)
    Write-Host ("  {0}: {1} @ {2}{3}{4}" -f $repo.Folder, $branch, $head.Substring(0, 7), $(if ($dirty.Count) { " / 커밋 안 된 변경 $($dirty.Count)건" } else { '' }), $(if (-not $pushed) { ' / GitHub 와 다름' } else { '' }))
    if ($dirty.Count -gt 0 -and -not $Force) { throw ("{0} 에 커밋되지 않은 변경이 {1}건 있습니다. 커밋하거나 -Force 로 무시하세요 (패키지에는 커밋된 내용만 들어갑니다)." -f $repo.Folder, $dirty.Count) }
    if (-not $pushed -and -not $Force) { throw ("{0} 의 HEAD 가 GitHub(origin/{1})와 다릅니다. 푸시하거나 -Force 로 무시하세요." -f $repo.Folder, $branch) }
    $repoInfo += [pscustomobject]@{ Folder = $repo.Folder; Source = $src; Branch = $branch; Commit = $head; GitHub = $repo.GitHub; Dirty = $dirty.Count; Pushed = $pushed }
}

# ---------------------------------------------------------------- 2. payload 만들기 (커밋된 상태를 저장소째 복제)
$payload = Join-Path $Output 'payload'
New-Item -ItemType Directory -Force -Path $payload | Out-Null
foreach ($info in $repoInfo) {
    $dst = Join-Path $payload $info.Folder
    if (Test-Path -LiteralPath $dst) {
        # 안전장치: payload 아래의 저장소 폴더만 지운다
        if (-not $dst.StartsWith($payload + '\')) { throw "삭제 대상이 payload 밖입니다: $dst" }
        Remove-Item -LiteralPath $dst -Recurse -Force
    }
    Write-Host ("  {0}: 복제 중" -f $info.Folder)
    $env:GIT_LFS_SKIP_SMUDGE = '1'
    try {
        $clone = Invoke-Native 'git' @('clone', '--quiet', '--no-local', '--branch', $info.Branch, $info.Source, $dst)
        if ($script:NativeExitCode -ne 0) { throw ("{0} 복제 실패: {1}" -f $info.Folder, ($clone -join ' ')) }
    } finally { Remove-Item Env:GIT_LFS_SKIP_SMUDGE -ErrorAction SilentlyContinue }
    Invoke-Git $dst @('remote', 'set-url', 'origin', $info.GitHub) | Out-Null
    # LFS 실제 파일을 원본 저장소의 객체 저장소에서 가져온다 (인터넷 없이도 설치되도록)
    $lfsSrc = Join-Path $info.Source '.git\lfs\objects'
    if (Test-Path -LiteralPath $lfsSrc -PathType Container) {
        $lfsDst = Join-Path $dst '.git\lfs\objects'
        Invoke-Native 'robocopy' @($lfsSrc, $lfsDst, '/E', '/NFL', '/NDL', '/NJH', '/NJS', '/NP') | Out-Null
        if ($script:NativeExitCode -ge 8) { throw ("{0} LFS 객체 복사 실패" -f $info.Folder) }
    }
    Invoke-Native 'git' @('-C', $dst, 'lfs', 'install', '--local') | Out-Null
    Invoke-Native 'git' @('-C', $dst, 'lfs', 'checkout') | Out-Null
    $pending = @(Invoke-Native 'git' @('-C', $dst, 'lfs', 'ls-files') | Where-Object { $_ -match '^\S+ - ' })
    if ($pending.Count -gt 0) { throw ("{0}: LFS 파일 {1}개를 실제 파일로 만들지 못했습니다." -f $info.Folder, $pending.Count) }
    $status = @(Invoke-Git $dst @('status', '--porcelain'))
    if ($status.Count -gt 0) { throw ("{0}: 복제본이 깨끗하지 않습니다 ({1}건)" -f $info.Folder, $status.Count) }
    $cloneHead = (Invoke-Git $dst @('rev-parse', 'HEAD')) -join ''
    if ($cloneHead -ne $info.Commit) { throw ("{0}: 복제본 커밋이 원본과 다릅니다" -f $info.Folder) }
    # 개인 컴퓨터 전용 항목이 딸려 가지 않도록 확인
    foreach ($forbidden in @('.env', 'private')) {
        if (Test-Path -LiteralPath (Join-Path $dst $forbidden)) { throw ("{0}: 패키지에 들어가면 안 되는 항목이 있습니다: {1}" -f $info.Folder, $forbidden) }
    }
}

# ---------------------------------------------------------------- 3. 설치 스크립트·안내문·명세
foreach ($name in @('Install-ClaudeWorkspace.ps1', 'Sync-GlobalGuidance.ps1', 'BOOTSTRAP-PROMPT.md')) {
    Copy-Item -LiteralPath (Join-Path $setupDir $name) -Destination (Join-Path $Output $name) -Force
}
Copy-Item -LiteralPath (Join-Path $setupDir 'INSTALL.md') -Destination (Join-Path $Output 'README.md') -Force

$mdRepo = Join-Path $WorkspaceRoot 'MD'
$gitUser = [ordered]@{
    name  = (Invoke-Native 'git' @('-C', $mdRepo, 'config', 'user.name')) -join ''
    email = (Invoke-Native 'git' @('-C', $mdRepo, 'config', 'user.email')) -join ''
}
$manifest = [ordered]@{
    package          = 'Claude Code 작업 환경 이식패키지'
    built_at         = (Get-Date).ToString('yyyy-MM-ddTHH:mm:sszzz')
    built_with       = [ordered]@{ git = ((Invoke-Native 'git' @('--version')) -join ''); git_lfs = ((Invoke-Native 'git' @('lfs', 'version')) -join ''); python = ((Invoke-Native 'python' @('--version')) -join '') }
    workspace_layout = @('MD', 'API', '데이터')
    repositories     = @($repoInfo | ForEach-Object { [ordered]@{ folder = $_.Folder; github = $_.GitHub; branch = $_.Branch; commit = $_.Commit } })
    git_user         = $gitUser
    excluded         = @('API\.env (API 키)', 'MD\private (개인 맥락)', '결과 파일(output, logs, 캐시)', 'Claude 세션 기록', '텔레그램 자동화', '예약 자동화 등록')
    install          = 'powershell -NoProfile -ExecutionPolicy Bypass -File .\Install-ClaudeWorkspace.ps1 -Root <작업 루트> [-EnvFile <.env 경로>]'
}
[IO.File]::WriteAllText((Join-Path $Output 'manifest.json'), (($manifest | ConvertTo-Json -Depth 6) + "`n"), $utf8)

# ---------------------------------------------------------------- 4. 요약
$size = (Get-ChildItem -LiteralPath $Output -Recurse -File -Force | Measure-Object Length -Sum).Sum
Write-Host ''
Write-Host ("패키지 완료: {0} ({1:N0} MB)" -f $Output, ($size / 1MB))
foreach ($info in $repoInfo) { Write-Host ("  payload\{0}  커밋 {1}  ({2})" -f $info.Folder, $info.Commit.Substring(0, 7), $info.GitHub) }
[pscustomobject]@{ output = $Output; size_mb = [math]::Round($size / 1MB, 1); repositories = $repoInfo }
