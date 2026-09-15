[CmdletBinding()]
param(
    # 작업 루트(MD·API·데이터가 든 폴더). 기본값: 이 스크립트(MD\setup)의 두 단계 위
    [string]$WorkspaceRoot = '',
    # Claude Code 홈 폴더. 기본값: ~\.claude
    [string]$ClaudeHome = ''
)

# MD\CLAUDE.md(저장소 원본)에서 전역 지침 ~\.claude\CLAUDE.md를 생성한다.
# 저장소 안의 지침은 작업 루트를 {{CLAUDE_ROOT}}로 적으므로, 이 스크립트가 실제 경로로 바꿔 넣는다.
# 루트 CLAUDE.md를 고칠 때마다 이 스크립트를 다시 실행한다. 생성된 전역 파일은 손으로 고치지 않는다.

$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.UTF8Encoding]::new($false) } catch { }
$setupDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
if ([string]::IsNullOrWhiteSpace($WorkspaceRoot)) { $WorkspaceRoot = Split-Path -Parent (Split-Path -Parent $setupDir) }
$WorkspaceRoot = [IO.Path]::GetFullPath($WorkspaceRoot).TrimEnd('\')
if ([string]::IsNullOrWhiteSpace($ClaudeHome)) { $ClaudeHome = Join-Path $HOME '.claude' }
$ClaudeHome = [IO.Path]::GetFullPath($ClaudeHome).TrimEnd('\')

$source = Join-Path $WorkspaceRoot 'MD\CLAUDE.md'
if (-not (Test-Path -LiteralPath $source -PathType Leaf)) { throw "루트 지침을 찾을 수 없습니다: $source" }

$utf8 = [Text.UTF8Encoding]::new($false)
$text = [IO.File]::ReadAllText($source, $utf8)
$newline = if ($text.Contains("`r`n")) { "`r`n" } else { "`n" }

# 1) 토큰을 실제 경로로 바꾼다
$token = '{{' + 'CLAUDE_ROOT' + '}}'
$expanded = $text.Replace($token, $WorkspaceRoot)
if ($expanded.Contains($token)) { Write-Warning '치환되지 않은 토큰이 남아 있습니다. 루트 CLAUDE.md를 확인해 주세요.' }

# 2) 첫 번째 절 첫 줄에 이 파일이 생성본임을 밝히는 줄을 넣는다 (토큰은 설명용으로 그대로 적는다)
$machineLine = "- This file is generated from ``$WorkspaceRoot\MD\CLAUDE.md`` by ``$WorkspaceRoot\MD\setup\Sync-GlobalGuidance.ps1`` with ``$token`` expanded to ``$WorkspaceRoot``. Edit the root file and rerun the script; do not edit this copy by hand."
$marker = '## Shared Standards' + $newline + $newline
$index = $expanded.IndexOf($marker)
if ($index -lt 0) { throw '루트 CLAUDE.md에서 "## Shared Standards" 절을 찾지 못했습니다.' }
$insertAt = $index + $marker.Length
$result = $expanded.Substring(0, $insertAt) + $machineLine + $newline + $expanded.Substring($insertAt)

# 3) 저장
New-Item -ItemType Directory -Force -Path $ClaudeHome | Out-Null
$target = Join-Path $ClaudeHome 'CLAUDE.md'
$changed = $true
if (Test-Path -LiteralPath $target -PathType Leaf) {
    $current = [IO.File]::ReadAllText($target, $utf8)
    $changed = ($current -ne $result)
}
if ($changed) {
    [IO.File]::WriteAllText($target, $result, $utf8)
    Write-Host ("전역 지침을 생성했습니다: {0} (작업 루트 {1})" -f $target, $WorkspaceRoot)
} else {
    Write-Host ("전역 지침이 이미 최신입니다: {0}" -f $target)
}
[pscustomobject]@{ target = $target; workspace_root = $WorkspaceRoot; changed = $changed }
