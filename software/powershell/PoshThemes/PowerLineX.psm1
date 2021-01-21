#requires -Version 2 -Modules posh-git

function Write-Theme {
    param(
        [bool]
        $lastCommandFailed,
        [string]
        $with
    )
    $lastColor = $sl.Colors.PromptBackgroundColor
    $authorityStatus = ((Invoke-CimMethod -InputObject $(Get-CimInstance Win32_Process -Filter "Handle=$PID") -MethodName GetOwner).User) -eq 'SYSTEM'

    $prompt = Write-Prompt -Object $sl.PromptSymbols.StartSymbol -ForegroundColor $sl.Colors.SessionInfoForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor

    $user = $sl.CurrentUser
    $computer = [System.Environment]::MachineName
    if ($authorityStatus) {
        $prompt += Write-Prompt -Object "$computer" -ForegroundColor $sl.Colors.SessionInfoForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor
    }
    else {
        if (Test-NotDefaultUser($user)) {
            $prompt += Write-Prompt -Object "$user@$computer" -ForegroundColor $sl.Colors.SessionInfoForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor
        }
    }

    if (Test-VirtualEnv) {
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.SegmentForwardSymbol) " -ForegroundColor $sl.Colors.SessionInfoBackgroundColor -BackgroundColor $sl.Colors.VirtualEnvBackgroundColor
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.VirtualEnvSymbol) $(Get-VirtualEnvName) " -ForegroundColor $sl.Colors.VirtualEnvForegroundColor -BackgroundColor $sl.Colors.VirtualEnvBackgroundColor
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.SegmentForwardSymbol) " -ForegroundColor $sl.Colors.VirtualEnvBackgroundColor -BackgroundColor $sl.Colors.PromptBackgroundColor
    }
    else {
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.SegmentForwardSymbol) " -ForegroundColor $sl.Colors.SessionInfoBackgroundColor -BackgroundColor $sl.Colors.PromptBackgroundColor
    }

    # Writes the drive portion.
    $path = (Get-ShortPath -dir $pwd).Replace('\', ' ' + [char]::ConvertFromUtf32(0xE0B1) + ' ') + ' '
    $prompt += Write-Prompt -Object $path -ForegroundColor $sl.Colors.PromptForegroundColor -BackgroundColor $sl.Colors.PromptBackgroundColor
    $status = Get-VCSStatus
    if ($status) {
        $themeInfo = Get-VcsInfo -status ($status)
        $lastColor = $themeInfo.BackgroundColor
        $prompt += Write-Prompt -Object $sl.PromptSymbols.SegmentForwardSymbol -ForegroundColor $sl.Colors.PromptBackgroundColor -BackgroundColor $lastColor
        $prompt += Write-Prompt -Object " $($themeInfo.VcInfo) " -BackgroundColor $lastColor -ForegroundColor $sl.Colors.GitForegroundColor
    }

    if ($with) {
        $prompt += Write-Prompt -Object $sl.PromptSymbols.SegmentForwardSymbol -ForegroundColor $lastColor -BackgroundColor $sl.Colors.WithBackgroundColor
        $prompt += Write-Prompt -Object " $($with.ToUpper()) " -BackgroundColor $sl.Colors.WithBackgroundColor -ForegroundColor $sl.Colors.WithForegroundColor
        $lastColor = $sl.Colors.WithBackgroundColor
    }

    If ($lastCommandFailed) {
        $errsign = "ERROR".Replace('\', ' ' + [char]::ConvertFromUtf32(0xE0B1) + ' ') + ' '
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.SegmentForwardSymbol) " -ForegroundColor $lastColor -BackgroundColor $errBackground
        $prompt += Write-Prompt -Object $errsign -ForegroundColor $errForeground -BackgroundColor $errBackground
        $lastColor = $errBackground
    }

    $prompt += Write-Prompt -Object $sl.PromptSymbols.SegmentForwardSymbol -ForegroundColor $lastColor

    # Writes the postfix to the prompt.
    $timeStamp = Get-Date -Format "hh:mm tt"
    $timestamp = " $timeStamp "

    if ($host.UI.RawUI.CursorPosition.X + $timestamp.Length + 10 -lt $host.UI.RawUI.WindowSize.Width) {
        $prompt += Set-CursorForRightBlockWrite -textLength ($timestamp.Length + 10)
        $prompt += Write-Prompt -Object $sl.PromptSymbols.Blur1Symbol -ForegroundColor $PromptForegroundColor
        $prompt += Write-Prompt -Object $sl.PromptSymbols.Blur2Symbol -ForegroundColor $PromptForegroundColor
        $prompt += Write-Prompt -Object $sl.PromptSymbols.Blur3Symbol -ForegroundColor $PromptForegroundColor
        $prompt += Write-Prompt $timeStamp -ForegroundColor $sl.Colors.GitForegroundColor -BackgroundColor $sl.Colors.PromptForegroundColor
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.ClockSymbol) " -ForegroundColor $sl.Colors.GitForegroundColor -BackgroundColor $sl.Colors.PromptForegroundColor
        $prompt += Write-Prompt -Object $sl.PromptSymbols.Blur3Symbol -ForegroundColor $PromptForegroundColor
        $prompt += Write-Prompt -Object $sl.PromptSymbols.Blur2Symbol -ForegroundColor $PromptForegroundColor
        $prompt += Write-Prompt -Object $sl.PromptSymbols.Blur1Symbol -ForegroundColor $PromptForegroundColor
    }

    $prompt += Set-Newline

    if ($with) {
        $prompt += Write-Prompt -Object "$($with.ToUpper()) " -BackgroundColor $sl.Colors.WithBackgroundColor -ForegroundColor $sl.Colors.WithForegroundColor
    }
    $prompt += Write-Prompt -Object "PS>" -ForegroundColor $sl.Colors.PromptSymbolColor
    $prompt += ' '
    $prompt
}

$sl = $global:ThemeSettings #local settings
$sl.PromptSymbols.SegmentForwardSymbol = [char]::ConvertFromUtf32(0xE0B0)
$sl.PromptSymbols.VirtualEnvSymbol = "🐍"
$sl.PromptSymbols.Blur1Symbol = [char]::ConvertFromUtf32(0x2591)
$sl.PromptSymbols.Blur2Symbol = [char]::ConvertFromUtf32(0x2592)
$sl.PromptSymbols.Blur3Symbol = [char]::ConvertFromUtf32(0x2593)
$sl.PromptSymbols.ClockSymbol = "⌚"
$sl.Colors.SessionInfoBackgroundColor = [ConsoleColor]::Cyan
$sl.Colors.SessionInfoForegroundColor = [ConsoleColor]::Black
$sl.Colors.PromptForegroundColor = [ConsoleColor]::White
$sl.Colors.PromptSymbolColor = [ConsoleColor]::White
$sl.Colors.PromptHighlightColor = [ConsoleColor]::DarkBlue
$sl.Colors.GitForegroundColor = [ConsoleColor]::Black
$sl.Colors.WithForegroundColor = [ConsoleColor]::White
$sl.Colors.WithBackgroundColor = [ConsoleColor]::DarkRed
$sl.Colors.VirtualEnvBackgroundColor = [System.ConsoleColor]::Red
$sl.Colors.VirtualEnvForegroundColor = [System.ConsoleColor]::White
$errForeground = [ConsoleColor]::White
$errBackground = [ConsoleColor]::DarkRed
