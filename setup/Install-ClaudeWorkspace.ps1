[CmdletBinding()]
param(
    # 작업 루트: MD·API·데이터 폴더를 둘 위치 (예: D:\Claude). 비워 두면 대화형 창에서 물어본다.
    [string]$Root = '',
    # Package: 이 스크립트 옆 payload\ 에서 복사 / GitHub: tonysskim 저장소에서 내려받기 / Auto: payload가 있으면 Package, 없으면 GitHub
    [ValidateSet('Auto', 'Package', 'GitHub')][string]$Source = 'Auto',
    # 다른 컴퓨터에서 가져온 API\.env 파일 경로. 주면 <Root>\API\.env 로 복사한다 (패키지에는 키가 들어 있지 않다).
    [string]$EnvFile = '',
    # Claude Code 홈 폴더. 기본 ~\.claude. 시험용으로만 바꾼다.
    [string]$ClaudeHome = '',
    # 필요한 프로그램(winget) 설치를 건너뛴다
    [switch]$SkipTools,
    # Python 패키지 설치를 건너뛴다
    [switch]$SkipPython,
    # 전역 지침·기억 파일 등 Claude 홈 반영을 건너뛴다 (시험용)
    [switch]$SkipClaudeHome
)

# Claude Code 작업 환경 설치·갱신 스크립트.
# 이식패키지(payload) 또는 GitHub에서 MD·API·데이터 세 저장소를 <Root>에 놓고, 전역 지침·기억 파일·private 템플릿을 준비한다.
# 두 경로(패키지/GitHub)는 같은 커밋을 설치하므로 결과가 같다. 이미 설치된 곳에서 다시 실행하면 저장소를 pull 로 갱신한다.
# 하지 않는 것: 예약 자동화 등록, 텔레그램 설정, API 키 입력(사용자가 .env 를 가져오거나 Set-ApiKey.ps1 로 등록), Git 커밋·푸시.

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
try { [Console]::OutputEncoding = [Text.UTF8Encoding]::new($false) } catch { }
$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$utf8 = [Text.UTF8Encoding]::new($false)
$report = [ordered]@{}
$warnings = New-Object System.Collections.Generic.List[string]
$script:NativeExitCode = 0

$repositories = @(
    [pscustomobject]@{ Folder = 'MD';     GitHub = 'tonysskim/MD' },
    [pscustomobject]@{ Folder = 'API';    GitHub = 'tonysskim/API' },
    [pscustomobject]@{ Folder = '데이터'; GitHub = 'tonysskim/data' }
)

function Write-Step([string]$Text) { Write-Host ''; Write-Host ("== {0}" -f $Text) -ForegroundColor Cyan }
function Add-Warning([string]$Text) { $script:warnings.Add($Text); Write-Warning $Text }

function Invoke-Native {
    # 외부 프로그램(git, gh, python 등)을 실행하고 stdout+stderr 를 문자열 배열로 돌려준다.
    # Windows PowerShell 5.1 은 $ErrorActionPreference=Stop 상태에서 외부 프로그램의 stderr 출력을 오류로 던지므로 잠시 낮춘다.
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

function Get-ProjectDirectoryName([string]$Path) {
    # Claude Code 는 작업 폴더 경로의 영숫자 이외 글자를 모두 '-' 로 바꿔 ~\.claude\projects 아래 폴더 이름으로 쓴다.
    $chars = foreach ($c in $Path.ToCharArray()) { if ($c -match '[A-Za-z0-9]') { $c } else { '-' } }
    return (-join $chars)
}

function Refresh-Path {
    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')
}

function Test-Command([string]$Name) { return [bool](Get-Command $Name -ErrorAction SilentlyContinue) }

function Install-Tool([string]$Command, [string]$WingetId, [string]$Display) {
    if (Test-Command $Command) { Write-Host ("  {0}: 있음" -f $Display); return $true }
    if ($SkipTools) { Add-Warning ("{0} 이(가) 없습니다 (-SkipTools 로 설치를 건너뜀)" -f $Display); return $false }
    if (-not (Test-Command 'winget')) { Add-Warning ("{0} 이(가) 없고 winget 도 없어 자동 설치할 수 없습니다. 직접 설치해 주세요." -f $Display); return $false }
    Write-Host ("  {0}: 없음 → winget 으로 설치합니다 ({1})" -f $Display, $WingetId)
    Invoke-Native 'winget' @('install', '--id', $WingetId, '--exact', '--accept-package-agreements', '--accept-source-agreements', '--disable-interactivity') | ForEach-Object { Write-Host ("    {0}" -f $_) }
    Refresh-Path
    if (Test-Command $Command) { Write-Host ("  {0}: 설치 완료" -f $Display); return $true }
    Add-Warning ("{0} 자동 설치에 실패했습니다. 직접 설치한 뒤 이 스크립트를 다시 실행해 주세요." -f $Display)
    return $false
}

function Test-GitLfs {
    if (-not (Test-Command 'git')) { return $false }
    Invoke-Native 'git' @('lfs', 'version') | Out-Null
    return ($script:NativeExitCode -eq 0)
}

# ---------------------------------------------------------------- 0. 입력 확인
Write-Step '설치 위치'
if ([string]::IsNullOrWhiteSpace($Root)) {
    if ([Environment]::UserInteractive -and $Host.Name -ne 'ServerRemoteHost') {
        $suggested = Join-Path $env:USERPROFILE 'Claude'
        $answer = Read-Host ("작업 루트 폴더를 입력하세요 (Enter = {0})" -f $suggested)
        $Root = if ([string]::IsNullOrWhiteSpace($answer)) { $suggested } else { $answer }
    } else {
        throw '-Root <작업 루트 경로> 를 지정해 주세요. 예: -Root D:\Claude'
    }
}
$Root = [IO.Path]::GetFullPath($Root).TrimEnd('\')
if ($Root -match '[^\x00-\x7F]') { Add-Warning '작업 루트 경로에 한글 등 비ASCII 글자가 있습니다. 동작은 하지만 영문 경로를 권합니다.' }
New-Item -ItemType Directory -Force -Path $Root | Out-Null
if ([string]::IsNullOrWhiteSpace($ClaudeHome)) { $ClaudeHome = Join-Path $HOME '.claude' }
$ClaudeHome = [IO.Path]::GetFullPath($ClaudeHome).TrimEnd('\')
$payload = Join-Path $scriptDir 'payload'
if ($Source -eq 'Auto') { $Source = if (Test-Path -LiteralPath $payload -PathType Container) { 'Package' } else { 'GitHub' } }
if ($Source -eq 'Package' -and -not (Test-Path -LiteralPath $payload -PathType Container)) { throw "payload 폴더가 없습니다: $payload" }
Write-Host ("  작업 루트: {0}" -f $Root)
Write-Host ("  설치 방식: {0}" -f $Source)
Write-Host ("  Claude 홈: {0}" -f $ClaudeHome)
$report.root = $Root; $report.source = $Source; $report.claude_home = $ClaudeHome

$manifest = $null
$manifestPath = Join-Path $scriptDir 'manifest.json'
if (Test-Path -LiteralPath $manifestPath -PathType Leaf) {
    $manifest = [IO.File]::ReadAllText($manifestPath, $utf8) | ConvertFrom-Json
}

# ---------------------------------------------------------------- 1. 필요한 프로그램
Write-Step '필요한 프로그램 확인'
$gitOk = Install-Tool 'git' 'Git.Git' 'Git'
$ghOk = Install-Tool 'gh' 'GitHub.cli' 'GitHub CLI'
$pyOk = Install-Tool 'python' 'Python.Python.3.14' 'Python'
if ($pyOk) {
    $pyVersion = (Invoke-Native 'python' @('--version')) -join ''
    if ($pyVersion -notmatch 'Python 3\.') {
        $pyOk = $false
        Add-Warning ("python 명령이 실제 Python 이 아닙니다 ({0}). Microsoft Store 별칭이면 설정 > 앱 > 앱 실행 별칭에서 끄고 Python 을 설치해 주세요." -f $pyVersion)
    } else { Write-Host ("  {0}" -f $pyVersion) }
}
$lfsOk = $false
if ($gitOk) {
    $lfsOk = Test-GitLfs
    if ($lfsOk) { Write-Host '  Git LFS: 있음' }
    else { [void](Install-Tool 'git-lfs' 'GitHub.GitLFS' 'Git LFS'); $lfsOk = Test-GitLfs }
    if ($lfsOk) { Invoke-Native 'git' @('lfs', 'install', '--skip-repo') | Out-Null }
}
if (-not $gitOk) { throw 'Git 이 없으면 진행할 수 없습니다.' }
$excelOk = [bool](Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\excel.exe' -ErrorAction SilentlyContinue)
Write-Host ("  Excel: {0}" -f $(if ($excelOk) { '있음' } else { '없음 (Excel COM 을 쓰는 도구는 이 컴퓨터에서 실행할 수 없음)' }))
$report.tools = [ordered]@{ git = $gitOk; gh = $ghOk; git_lfs = $lfsOk; python = $pyOk; excel = $excelOk }

# ---------------------------------------------------------------- 2. 저장소 설치 또는 갱신
Write-Step '저장소 설치'
if ($Source -eq 'GitHub') {
    if (-not $ghOk) { throw 'GitHub 방식에는 GitHub CLI(gh) 가 필요합니다.' }
    Invoke-Native 'gh' @('auth', 'status') | Out-Null
    if ($script:NativeExitCode -ne 0) { throw 'GitHub 에 로그인되어 있지 않습니다. 터미널에서 gh auth login 을 먼저 실행해 주세요 (브라우저 코드 인증).' }
}
$repoReport = @()
foreach ($repo in $repositories) {
    $target = Join-Path $Root $repo.Folder
    $gitDir = Join-Path $target '.git'
    $mode = ''
    if (Test-Path -LiteralPath $gitDir -PathType Container) {
        $mode = 'update'
        Write-Host ("  {0}: 이미 있음 → pull 로 갱신" -f $repo.Folder)
        $dirty = @(Invoke-Git $target @('status', '--porcelain'))
        if ($dirty.Count -gt 0) {
            Add-Warning ("{0} 에 커밋되지 않은 변경이 있어 갱신하지 않았습니다. 정리한 뒤 다시 실행하세요." -f $repo.Folder)
        } else {
            $pull = Invoke-Native 'git' @('-C', $target, 'pull', '--ff-only')
            if ($script:NativeExitCode -ne 0) { Add-Warning ("{0} 갱신 실패: {1}" -f $repo.Folder, ($pull -join ' ')) }
            else { Write-Host ("    {0}" -f (($pull | Where-Object { $_ } | Select-Object -Last 1) -join '')) }
        }
    } else {
        if ((Test-Path -LiteralPath $target) -and @(Get-ChildItem -LiteralPath $target -Force).Count -gt 0) {
            throw ("대상 폴더가 비어 있지 않은데 Git 저장소가 아닙니다: {0}" -f $target)
        }
        if ($Source -eq 'Package') {
            $mode = 'package'
            $sourceDir = Join-Path $payload $repo.Folder
            if (-not (Test-Path -LiteralPath (Join-Path $sourceDir '.git') -PathType Container)) { throw ("패키지에 {0} 저장소가 없습니다: {1}" -f $repo.Folder, $sourceDir) }
            Write-Host ("  {0}: 패키지에서 복사" -f $repo.Folder)
            Invoke-Native 'robocopy' @($sourceDir, $target, '/E', '/NFL', '/NDL', '/NJH', '/NJS', '/NP', '/R:2', '/W:1') | Out-Null
            if ($script:NativeExitCode -ge 8) { throw ("{0} 복사 실패 (robocopy 코드 {1})" -f $repo.Folder, $script:NativeExitCode) }
        } else {
            $mode = 'clone'
            Write-Host ("  {0}: GitHub 에서 내려받기 ({1})" -f $repo.Folder, $repo.GitHub)
            $clone = Invoke-Native 'gh' @('repo', 'clone', $repo.GitHub, $target)
            if ($script:NativeExitCode -ne 0) { throw ("{0} 내려받기 실패: {1}" -f $repo.Folder, ($clone -join ' ')) }
        }
    }
    if ($lfsOk) {
        Invoke-Native 'git' @('-C', $target, 'lfs', 'install', '--local') | Out-Null
        Invoke-Native 'git' @('-C', $target, 'lfs', 'checkout') | Out-Null
    }
    # Git 작성자 정보가 없으면 패키지 명세의 값을 넣는다 (비밀값 아님)
    $name = (Invoke-Native 'git' @('-C', $target, 'config', 'user.name')) -join ''
    if ([string]::IsNullOrWhiteSpace($name) -and $manifest -and $manifest.git_user) {
        Invoke-Native 'git' @('-C', $target, 'config', 'user.name', [string]$manifest.git_user.name) | Out-Null
        Invoke-Native 'git' @('-C', $target, 'config', 'user.email', [string]$manifest.git_user.email) | Out-Null
    }
    $head = (Invoke-Git $target @('rev-parse', '--short', 'HEAD')) -join ''
    $status = @(Invoke-Git $target @('status', '--porcelain'))
    $remote = (Invoke-Native 'git' @('-C', $target, 'remote', 'get-url', 'origin')) -join ''
    $lfsPending = @()
    if ($lfsOk) { $lfsPending = @(Invoke-Native 'git' @('-C', $target, 'lfs', 'ls-files') | Where-Object { $_ -match '^\S+ - ' }) }
    if ($lfsPending.Count -gt 0) { Add-Warning ("{0}: LFS 파일 {1}개가 아직 포인터 상태입니다. 인터넷 연결 후 git -C `"{2}`" lfs pull 을 실행하세요." -f $repo.Folder, $lfsPending.Count, $target) }
    Write-Host ("    커밋 {0} / 변경 {1}건 / origin {2}" -f $head, $status.Count, $remote)
    $repoReport += [ordered]@{ folder = $repo.Folder; path = $target; mode = $mode; commit = $head; clean = ($status.Count -eq 0); origin = $remote; lfs_pending = $lfsPending.Count }
}
$report.repositories = $repoReport

# ---------------------------------------------------------------- 3. Python 패키지
Write-Step 'Python 패키지'
$requirements = Join-Path $Root '데이터\requirements.txt'
if ($SkipPython) { Write-Host '  건너뜀 (-SkipPython)' }
elseif (-not $pyOk) { Add-Warning 'Python 이 없어 패키지를 설치하지 못했습니다.' }
elseif (-not (Test-Path -LiteralPath $requirements -PathType Leaf)) { Add-Warning ("requirements.txt 가 없습니다: {0}" -f $requirements) }
else {
    $pip = Invoke-Native 'python' @('-m', 'pip', 'install', '--quiet', '--disable-pip-version-check', '-r', $requirements)
    if ($script:NativeExitCode -ne 0) { Add-Warning ('Python 패키지 설치가 실패했습니다. 인터넷 연결을 확인한 뒤 python -m pip install -r 데이터\requirements.txt 를 다시 실행하세요. ' + (($pip | Select-Object -Last 2) -join ' ')) }
    else { Write-Host '  설치 완료 (openpyxl, pandas, xlrd, pypdf, pdfplumber)' }
}
$pyImport = $null
if ($pyOk) {
    $pyImport = (Invoke-Native 'python' @('-c', "import openpyxl, pandas, xlrd, pypdf, pdfplumber; print('ok')")) -join ''
    $report.python_packages = $pyImport
}

# ---------------------------------------------------------------- 4. API 키 저장 파일
Write-Step 'API 키 저장 파일 (.env)'
$apiRoot = Join-Path $Root 'API'
$envTarget = Join-Path $apiRoot '.env'
if (-not [string]::IsNullOrWhiteSpace($EnvFile)) {
    if (-not (Test-Path -LiteralPath $EnvFile -PathType Leaf)) { throw ("-EnvFile 경로에 파일이 없습니다: {0}" -f $EnvFile) }
    Copy-Item -LiteralPath $EnvFile -Destination $envTarget -Force
    Write-Host ("  .env 를 복사했습니다: {0}" -f $envTarget)
}
$initialiser = Join-Path $apiRoot 'scripts\Initialize-ApiAccess.ps1'
$missingAliases = @()
if (Test-Path -LiteralPath $initialiser -PathType Leaf) {
    $status = & $initialiser -SkipRegistration
    $missingAliases = @($status.credential_providers | Where-Object status -ne 'READY' | ForEach-Object alias)
} else { Add-Warning 'API 초기화 스크립트를 찾지 못했습니다.' }
$report.env_file = $envTarget
$report.missing_api_keys = $missingAliases

# ---------------------------------------------------------------- 5. Claude 홈 (전역 지침·private·기억)
Write-Step 'Claude Code 설정 파일'
$mdRoot = Join-Path $Root 'MD'
if ($SkipClaudeHome) { Write-Host '  건너뜀 (-SkipClaudeHome)' }
else {
    $globalTarget = Join-Path $ClaudeHome 'CLAUDE.md'
    if (Test-Path -LiteralPath $globalTarget -PathType Leaf) {
        $existing = [IO.File]::ReadAllText($globalTarget, $utf8)
        if ($existing -notmatch 'Sync-GlobalGuidance\.ps1') {
            $backup = Join-Path $ClaudeHome 'CLAUDE.md.before-install'
            Copy-Item -LiteralPath $globalTarget -Destination $backup -Force
            Add-Warning ("기존 전역 지침이 이 저장소에서 만든 것이 아니어서 {0} 에 보관하고 새로 만들었습니다." -f $backup)
        }
    }
    $sync = Join-Path $mdRoot 'setup\Sync-GlobalGuidance.ps1'
    $syncResult = & $sync -WorkspaceRoot $Root -ClaudeHome $ClaudeHome
    $report.global_guidance = $syncResult.target

    # private 폴더: 개인 맥락은 컴퓨터마다 따로 둔다. 없는 파일만 템플릿에서 만든다.
    $privateDir = Join-Path $mdRoot 'private'
    New-Item -ItemType Directory -Force -Path $privateDir | Out-Null
    $created = @()
    foreach ($template in Get-ChildItem -LiteralPath (Join-Path $mdRoot 'setup\private-template') -File) {
        $dest = Join-Path $privateDir $template.Name
        if (-not (Test-Path -LiteralPath $dest)) { Copy-Item -LiteralPath $template.FullName -Destination $dest; $created += $template.Name }
    }
    Write-Host ("  private 폴더: 새로 만든 파일 {0}" -f $(if ($created.Count) { $created -join ', ' } else { '없음(이미 있음)' }))
    $report.private_created = $created

    # 기억 파일: 저장소에 담긴 시작 기억을 이 컴퓨터의 프로젝트 기억 폴더에 넣는다. 이미 있는 파일은 덮어쓰지 않는다.
    $memoryCopied = @()
    $memoryRoot = Join-Path $mdRoot 'setup\claude-home\memory'
    if (Test-Path -LiteralPath $memoryRoot -PathType Container) {
        foreach ($folder in Get-ChildItem -LiteralPath $memoryRoot -Directory) {
            $projectPath = Join-Path $Root $folder.Name
            $projectDir = Join-Path (Join-Path $ClaudeHome 'projects') (Get-ProjectDirectoryName $projectPath)
            $memoryDir = Join-Path $projectDir 'memory'
            New-Item -ItemType Directory -Force -Path $memoryDir | Out-Null
            foreach ($file in Get-ChildItem -LiteralPath $folder.FullName -File) {
                $dest = Join-Path $memoryDir $file.Name
                if (Test-Path -LiteralPath $dest) { continue }
                $content = [IO.File]::ReadAllText($file.FullName, $utf8).Replace('{{CLAUDE_ROOT}}', $Root)
                [IO.File]::WriteAllText($dest, $content, $utf8)
                $memoryCopied += ("{0}\{1}" -f $folder.Name, $file.Name)
            }
        }
    }
    Write-Host ("  기억 파일: {0}개 복사" -f $memoryCopied.Count)
    $report.memory_copied = $memoryCopied

    # 예약 자동화는 등록하지 않는다. 정의 파일 위치만 알린다.
    $taskDefinition = Join-Path $mdRoot 'setup\claude-home\scheduled-tasks\daily-md-update\SKILL.md'
    if (Test-Path -LiteralPath $taskDefinition -PathType Leaf) {
        Write-Host '  예약 자동화(daily-md-update)는 등록하지 않았습니다. 사용자가 이 컴퓨터에도 등록할지 따로 결정합니다.'
        $report.scheduled_task_definition = $taskDefinition
    }
}

# ---------------------------------------------------------------- 6. 요약
Write-Step '설치 결과'
foreach ($r in $repoReport) {
    Write-Host ("  {0,-6} {1}  커밋 {2}  {3}" -f $r.folder, $r.path, $r.commit, $(if ($r.clean) { '정상' } else { '변경 있음' }))
}
if ($report.global_guidance) { Write-Host ("  전역 지침: {0}" -f $report.global_guidance) }
Write-Host ("  Python 패키지: {0}" -f $(if ($pyImport -eq 'ok') { '정상' } elseif ($pyImport) { '문제 있음' } else { '확인 안 함' }))
if ($missingAliases.Count -gt 0) {
    Write-Host ("  등록 필요한 API 키 {0}개: {1}" -f $missingAliases.Count, ($missingAliases -join ', ')) -ForegroundColor Yellow
    Write-Host ("    → 미리 채울 필요는 없습니다. 작업 중 키가 필요하면 Claude 가 그때 사용자에게 물어보고 등록합니다 (2026-09-16 사용자 결정). 원래 컴퓨터의 API\.env 를 가져왔다면 {0} 에 두면 됩니다." -f $envTarget)
} else { Write-Host '  API 키: 모두 등록됨' }
if ($warnings.Count -gt 0) {
    Write-Host ''
    Write-Host ("  주의 {0}건:" -f $warnings.Count) -ForegroundColor Yellow
    foreach ($w in $warnings) { Write-Host ("   - {0}" -f $w) -ForegroundColor Yellow }
}
$report.warnings = @($warnings)
Write-Host ''
Write-Host '다음 할 일'
Write-Host ("  1. Claude Code 에서 {0}, {1}, {2} 를 각각 작업 폴더로 엽니다. 처음 열 때 폴더 신뢰 확인 창이 한 번 뜹니다." -f (Join-Path $Root 'MD'), (Join-Path $Root 'API'), (Join-Path $Root '데이터'))
Write-Host '  2. API 키는 미리 채우지 않아도 됩니다. 작업 중 필요하면 Claude 가 물어봅니다. 상태 확인: API\scripts\Get-ApiAccessStatus.ps1'
Write-Host '  3. 매일 지침 검토 자동화(daily-md-update)를 이 컴퓨터에도 둘지는 Claude 에게 따로 말해 결정합니다.'
[pscustomobject]$report
