# Устанавливает глобальные настройки Claude Code для работы через OmniRoute.
# Запуск: powershell -ExecutionPolicy Bypass -File .\install.ps1
$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$claudeDir = Join-Path $env:USERPROFILE '.claude'
New-Item -ItemType Directory -Force -Path (Join-Path $claudeDir 'agents') | Out-Null

$baseUrl = Read-Host 'Адрес OmniRoute [http://localhost:20128]'
if (-not $baseUrl) { $baseUrl = 'http://localhost:20128' }
$secureKey = Read-Host 'API-ключ OmniRoute' -AsSecureString
$key = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
  [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureKey))

Write-Host 'Скопируйте ID моделей (или комбо) из дашборда OmniRoute.'
$cheap = Read-Host 'Дешёвая модель для простых задач'
$main = Read-Host 'Основная модель для обычной работы'
$smart = Read-Host 'Сильная модель для планирования и сложных задач'

# Ключ хранится в переменной окружения пользователя, а не в файле настроек.
[Environment]::SetEnvironmentVariable('ANTHROPIC_AUTH_TOKEN', $key, 'User')

$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
foreach ($name in 'settings.json', 'CLAUDE.md', 'agents\quick.md') {
  $target = Join-Path $claudeDir $name
  if (Test-Path $target) { Copy-Item $target "$target.bak-$stamp" }
}

$settings = Get-Content (Join-Path $here 'settings.json') -Raw -Encoding UTF8
$settings = $settings.Replace('__BASE_URL__', $baseUrl).
  Replace('__CHEAP_MODEL__', $cheap).
  Replace('__MAIN_MODEL__', $main).
  Replace('__SMART_MODEL__', $smart)
$utf8 = New-Object Text.UTF8Encoding $false
[IO.File]::WriteAllText((Join-Path $claudeDir 'settings.json'), $settings, $utf8)
Copy-Item (Join-Path $here 'CLAUDE.md') (Join-Path $claudeDir 'CLAUDE.md') -Force
Copy-Item (Join-Path $here 'agents\quick.md') (Join-Path $claudeDir 'agents\quick.md') -Force

Write-Host "Готово. Старые файлы сохранены с суффиксом .bak-$stamp."
Write-Host 'Закройте все окна PowerShell, откройте новое и запустите claude.'
