<#
.SYNOPSIS
    Recursively scan a directory for potential exposed credentials and security hazards.

.DESCRIPTION
    - Scans PowerShell and other text-based files for suspicious patterns (passwords, tokens, keys).
    - Highlights risky commands (Invoke-Expression, DownloadString, plaintext creds).
    - Outputs a CSV report and writes a summary to the console.
    - Captures context lines for each match.

.PARAMETER Path
    Root directory to scan.

.PARAMETER IncludeExtensions
    File extensions to include (default focuses on PowerShell & config files).

.PARAMETER ExcludeDirs
    Directories to exclude (e.g., .git, node_modules, bin, obj, packages).

.PARAMETER OutputCsv
    Path to CSV report file.

.PARAMETER ContextLines
    Number of lines of context before and after a match.

.NOTES
    Run in a PowerShell with appropriate permissions. This is a heuristic scanner—review findings manually.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$Path,

    [string[]]$IncludeExtensions = @(
        '.ps1', '.psm1', '.psd1', '.ps1xml', '.bat', '.cmd',
        '.ps', '.pssc', '.psrc', '.config', '.xml', '.json', '.yml', '.yaml',
        '.ini', '.txt', '.cs', '.vb', '.sql', '.ts', '.js'
    ),

    [string[]]$ExcludeDirs = @(
        '.git', '.svn', '.hg', '.idea', '.vscode', 'node_modules',
        'bin', 'obj', 'packages', '.venv', 'venv', 'dist', 'out', 'target'
    ),

    [string]$OutputCsv = "$(Join-Path -Path (Get-Location) -ChildPath ('CredentialScan_' + (Get-Date -Format yyyyMMdd_HHmmss) + '.csv'))",

    [int]$ContextLines = 2
)
begin {
    Write-Host "Starting scan in: $Path" -ForegroundColor Cyan
    if (-not (Test-Path $Path)) { throw "Path not found: $Path" }

    $BinaryExtensions = @(
        '.dll','.exe','.png','.jpg','.jpeg','.gif','.ico','.pdf',
        '.zip','.7z','.gz','.tar','.mp3','.mp4','.mov','.avi',
        '.pdb','.class','.jar','.so','.dylib'
    )

    # Enhanced suspicious regex patterns
    $PatternsPlus = @(
        # 1) Generic variable assignments that look like secrets
        #    $password = "xxx", $token='xxx', $secret = '...', $apiKey="...", $key='...'
        '(?in)^\s*\$([a-z0-9_]*?(pass(word)?|pwd|secret|token|apikey|api_key|key|cred|credential|auth|bearer|clientsecret|client_secret)[a-z0-9_]*)\s*=\s*["''][^"'']{4,}["'']',
        #    short variable names like $pw, $psw, $tk, $ak, $sk, $dbpass
        '(?in)^\s*\$(pw|psw|pwd|tk|tok|token|ak|sk|api|apikey|api_key|dbpass|dbpwd|passwd)\s*=\s*["''][^"'']{4,}["'']',

        # 2) Hashtable/splat style creds
        #    @{ Password = "..." } ; -Credential @{ UserName="x"; Password="y" }
        '(?in)(?:@{[^}]*\b(password|passwd|pwd|secret)\b\s*=\s*["''][^"'']{4,}["''][^}]*})',
        '(?in)-Credential\s+@{[^}]*\b(User(Name)?|Login|Uid)\b\s*=\s*["''][^"'']{1,}["'']\s*;\s*\b(Password|Pwd|Pass)\b\s*=\s*["''][^"'']{4,}["''][^}]*}',

        # 3) Inline named arguments: -Password "..."  -Token '...'
        '(?in)-(password|passwd|pwd|secret|token|apikey|api_key|clientsecret|client_secret)\s+["''][^"'']{4,}["'']',

        # 4) Connection strings (broader coverage)
        '(?i)\b(Server|Data Source|Host|Addr|Address)=[^;]+;[^;]*\b(Database|Initial Catalog)=[^;]+;[^;]*(User\s*ID|Uid|User|Username)=[^;]+;[^;]*(Password|Pwd)=[^;]+;',
        '(?i)\b(Driver|Provider)=[^;]+;[^;]*\b(Server|Host)=[^;]+;[^;]*(Uid|User|Username)=[^;]+;[^;]*(Pwd|Password)=[^;]+;',
        '(?i)\b(Endpoint|AccountEndpoint)=[^;]+;[^;]*(AccountKey|SharedAccessKey)=[^;]+;',
        '(?i)\bDefaultEndpointsProtocol=\w+;AccountName=[^;]+;AccountKey=[^;]+;',

        # 5) URLs with creds
        '(?i)\b[a-z]+:\/\/[^:\s\/]+:[^@\s\/]+@[^\/\s]+',

        # 6) Cloud/provider tokens and keys
        '(?i)\bAKIA[0-9A-Z]{16}\b',                               # AWS Access Key ID
        '(?i)\bASIA[0-9A-Z]{16}\b',
        '(?i)\baws_secret_access_key\s*[:=]\s*["''][A-Za-z0-9/+=]{40}["'']',
        '(?i)\bA3T[A-Z0-9]{16}\b',
        '(?i)\bAIza[0-9A-Za-z\-_]{35}\b',                         # Google API key
        '(?i)\bya29\.[0-9A-Za-z\-_]+\b',                          # Google OAuth
        '(?i)\bgh[pousr]_[0-9A-Za-z]{20,}\b',                     # GitHub tokens
        '(?i)\bglpat-[0-9A-Za-z\-_]{20,}\b',                      # GitLab PAT
        '(?i)\bslack-[a-z0-9_-]*xox[baprs]-[0-9A-Za-z-]{10,}\b',  # Slack tokens
        '(?i)\bsk_live_[0-9a-zA-Z]{24,}\b',                       # Stripe
        '(?i)\bsk_test_[0-9a-zA-Z]{24,}\b',
        '(?i)\bSG\.[A-Za-z0-9_\-]{16,}\.[A-Za-z0-9_\-]{16,}\b',   # SendGrid
        '(?i)\bEAACEdEose0cBA[0-9A-Za-z]+',                       # Old FB long-lived
        '(?i)\bTWILIO[A-Z0-9_]*[_-]?(AUTH|TOKEN)?[=:]\s*["'']?[A-Za-z0-9]{20,}["'']?',
        '(?i)\bDISCORD_TOKEN\s*[:=]\s*["''][A-Za-z0-9\._-]{20,}["'']',
        '(?i)\b(azure|aad|client|tenant).*?(secret|password)\s*[:=]\s*["''][^"'']{6,}["'']',

        # 7) JWTs and Base64-like blobs
        '(?i)\beyJ[A-Za-z0-9_\-]{10,}\.[A-Za-z0-9_\-]{10,}\.[A-Za-z0-9_\-]{10,}\b', # JWT
        '(?i)\b([A-Za-z0-9+/]{32,}={0,2})\b',                                       # Base64 blob (len >=32)
        # 8) Private keys
        '-----BEGIN (RSA|DSA|EC|OPENSSH|PGP) PRIVATE KEY-----',

        # 9) Risky PS commands (keep from original)
        '(?i)\bInvoke-Expression\b',
        '(?i)\bIEX\b',
        '(?i)\bDownloadString\b',
        '(?i)\bFromBase64String\b',
        '(?i)\bInvoke-WebRequest\b.*\b-UseBasicParsing\b',
        '(?i)\bAdd-Type\b.*?System\.Net\.WebClient',
        '(?i)\bConvertTo-SecureString\b.*-AsPlainText\b.*-Force',
        '(?i)\bPlainTextPassword\b'
    )

    # Optional entropy-based detector (catches random-looking secrets)
    $EnableEntropy = $true
    $EntropyMinLength = 20
    $EntropyThreshold = 3.5  # 0-~5.3; higher = stricter. 3.5 is moderate.

    # sets etc...
    $IncludeExtSet  = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
    $BinaryExtSet   = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
    $IncludeExtensions | ForEach-Object { [void]$IncludeExtSet.Add($_) }
    $BinaryExtensions  | ForEach-Object { [void]$BinaryExtSet.Add($_) }

    function Should-ScanFile([string]$filePath) {
        $ext = [IO.Path]::GetExtension($filePath)
        if ($BinaryExtSet.Contains($ext)) { return $false }
        if ($IncludeExtSet.Count -gt 0 -and -not $IncludeExtSet.Contains($ext)) { return $false }
        return $true
    }

    function Is-ExcludedDir([string]$fullPath) {
        foreach ($ex in $ExcludeDirs) {
            if ($fullPath -match [Regex]::Escape([IO.Path]::DirectorySeparatorChar + $ex + [IO.Path]::DirectorySeparatorChar)) {
                return $true
            }
        }
        return $false
    }

    # Shannon entropy helper
    function Get-Entropy([string]$s) {
        if (-not $s -or $s.Length -eq 0) { return 0 }
        $freq = @{}
        foreach ($c in $s.ToCharArray()) { $freq[$c] = 1 + ($freq[$c] | ForEach-Object {$_}) }
        $len = [double]$s.Length
        $sum = 0.0
        foreach ($kv in $freq.GetEnumerator()) {
            $p = $kv.Value / $len
            $sum += -$p * [Math]::Log($p, 2)
        }
        return $sum
    }

    $Results = New-Object System.Collections.Generic.List[object]
    $Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
}

process {
    $queue = New-Object System.Collections.Generic.Queue[System.IO.DirectoryInfo]
    $queue.Enqueue((Get-Item -LiteralPath $Path))

    while ($queue.Count -gt 0) {
        $dir = $queue.Dequeue()
        if (-not $dir.Exists) { continue }

        try {
            foreach ($subdir in $dir.EnumerateDirectories('*', [IO.SearchOption]::TopDirectoryOnly)) {
                if (Is-ExcludedDir($subdir.FullName)) { continue }
                $queue.Enqueue($subdir)
            }
        } catch { Write-Verbose "Dir access denied: $($dir.FullName) - $($_.Exception.Message)" }

        try {
            foreach ($file in $dir.EnumerateFiles('*', [IO.SearchOption]::TopDirectoryOnly)) {
                if (-not (Should-ScanFile $file.FullName)) { continue }

                $content = $null
                try {
                    $content = Get-Content -LiteralPath $file.FullName -Raw -ErrorAction Stop
                } catch {
                    try {
                        $bytes = [IO.File]::ReadAllBytes($file.FullName)
                        if ($bytes -contains 0) { continue }
                        $content = [Text.Encoding]::UTF8.GetString($bytes)
                    } catch {
                        Write-Verbose "File read failed: $($file.FullName) - $($_.Exception.Message)"
                        continue
                    }
                }
                if ([string]::IsNullOrWhiteSpace($content)) { continue }

                $lines = $content -split "`r?`n"

                # Pattern matches
                foreach ($pattern in $PatternsPlus) {
                    $matches = $null
                    try { $matches = [regex]::Matches($content, $pattern) } catch { continue }
                    if ($matches.Count -eq 0) { continue }

                    foreach ($m in $matches) {
                        $startIndex = $m.Index
                        $prefix = $content.Substring(0, [Math]::Min($startIndex, $content.Length))
                        $lineNumber = ($prefix -split "`r?`n").Count

                        $startCtx = [Math]::Max(1, $lineNumber - $ContextLines)
                        $endCtx   = [Math]::Min($lines.Count, $lineNumber + $ContextLines)
                        $ctxLines = @()
                        for ($i = $startCtx; $i -le $endCtx; $i++) {
                            $marker = if ($i -eq $lineNumber) { '>>' } else { '  ' }
                            $ctxLines += ('{0,3} {1} {2}' -f $i, $marker, $lines[$i-1])
                        }

                        # Classify
                        $type = 'CredentialOrSecret'
                        $val = $m.Value
                        if ($val -match 'PRIVATE KEY') { $type = 'PrivateKey' }
                        elseif ($val -match '(?i)AKIA|ASIA|aws_secret_access_key') { $type = 'AWSKey' }
                        elseif ($val -match '(?i)\bgh[pousr]_') { $type = 'GitHubToken' }
                        elseif ($val -match '(?i)glpat-') { $type = 'GitLabToken' }
                        elseif ($val -match '(?i)eyJ[A-Za-z0-9_\-]{10,}\.') { $type = 'JWT' }
                        elseif ($val -match '(?i)\b(Server|Data Source|Host|Addr|Address)=') { $type = 'DBConnection' }
                        elseif ($val -match '(?i)invoke-expression|iex|downloadstring') { $type = 'RiskyCommand' }

                        $Results.Add([pscustomobject]@{
                            File           = $file.FullName
                            FindingType    = $type
                            Pattern        = $pattern
                            MatchValue     = $val.Substring(0, [Math]::Min(160, $val.Length))
                            LineNumber     = $lineNumber
                            Context        = ($ctxLines -join "`n")
                        })
                    }
                }

                # Entropy scan on quoted strings and assignments (optional)
                if ($EnableEntropy) {
                    # Capture quoted strings and RHS of assignments that are quoted
                    $candPattern = '(?sx)
                        ["'']([A-Za-z0-9/_\-\.+=]{' + $EntropyMinLength + ',})["''] |
                        =\s*["'']([A-Za-z0-9/_\-\.+=]{' + $EntropyMinLength + ',})["'']
                    '
                    try {
                        $candMatches = [regex]::Matches($content, $candPattern)
                        foreach ($cm in $candMatches) {
                            $val = $cm.Groups[1].Value
                            if (-not $val) { $val = $cm.Groups[2].Value }
                            if (-not $val) { continue }
                            # skip obviously non-secrets (urls/emails/paths)
                            if ($val -match '^(http|https)://') { continue }
                            if ($val -match '^[\w\.-]+@[\w\.-]+\.\w{2,}$') { continue }
                            if ($val -match '^[A-Za-z]:(\\|/)' -or $val -match '[/\\]') { continue }

                            $H = Get-Entropy $val
                            if ($H -ge $EntropyThreshold) {
                                # Find approximate line number
                                $idx = $content.IndexOf($val)
                                $prefix = $content.Substring(0, [Math]::Min($idx, $content.Length))
                                $lineNumber = ($prefix -split "`r?`n").Count

                                $startCtx = [Math]::Max(1, $lineNumber - $ContextLines)
                                $endCtx   = [Math]::Min($lines.Count, $lineNumber + $ContextLines)
                                $ctxLines = @()
                                for ($i = $startCtx; $i -le $endCtx; $i++) {
                                    $marker = if ($i -eq $lineNumber) { '>>' } else { '  ' }
                                    $ctxLines += ('{0,3} {1} {2}' -f $i, $marker, $lines[$i-1])
                                }

                                $Results.Add([pscustomobject]@{
                                    File           = $file.FullName
                                    FindingType    = 'HighEntropyString'
                                    Pattern        = "Entropy>=$EntropyThreshold"
                                    MatchValue     = $val.Substring(0, [Math]::Min(160, $val.Length))
                                    LineNumber     = $lineNumber
                                    Context        = ($ctxLines -join "`n")
                                })
                            }
                        }
                    } catch { }
                }
            }
        } catch {
            Write-Verbose "File enumeration failed in: $($dir.FullName) - $($_.Exception.Message)"
            continue
        }
    }
}

end {
    $Stopwatch.Stop()
    if ($Results.Count -gt 0) {
        $Results |
            Sort-Object File, LineNumber |
            Export-Csv -NoTypeInformation -Path $OutputCsv -Encoding UTF8

        Write-Host "Scan complete. Findings: $($Results.Count)" -ForegroundColor Yellow
        Write-Host "Report saved to: $OutputCsv" -ForegroundColor Green

        $Results |
            Group-Object File |
            ForEach-Object {
                Write-Host "`nFile: $($_.Name)" -ForegroundColor Cyan
                $_.Group |
                    Sort-Object LineNumber |
                    ForEach-Object {
                        $color = switch ($_.FindingType) {
                            'PrivateKey' { 'Red' }
                            'AWSKey' { 'Red' }
                            'GitHubToken' { 'Red' }
                            'JWT' { 'Magenta' }
                            'DBConnection' { 'Yellow' }
                            'RiskyCommand' { 'Magenta' }
                            'HighEntropyString' { 'Yellow' }
                            default { 'Gray' }
                        }
                        Write-Host ("  [{0}] Line {1}: {2}" -f $_.FindingType, $_.LineNumber, $_.MatchValue) -ForegroundColor $color
                        Write-Host ($_.Context + "`n") -ForegroundColor DarkGray
                    }
            }
    } else {
        Write-Host "Scan complete. No suspicious patterns found." -ForegroundColor Green
    }
    Write-Host ("Elapsed: {0:g}" -f $Stopwatch.Elapsed)
}
