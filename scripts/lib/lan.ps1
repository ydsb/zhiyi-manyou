# =============================================================================
#  ZhiYi Manyou - shared LAN detection helpers   [ASCII-only, see NOTE]
#
#  Dot-source this from other scripts:
#      . "$PSScriptRoot\lib\lan.ps1"
#
#  NOTE: ASCII-only ON PURPOSE, comments included. Windows PowerShell 5.1 parses
#        .ps1 as GBK on Chinese Windows unless the file carries a UTF-8 BOM, and
#        a stray Chinese string can shift the parser into "Unexpected token"
#        errors on unrelated lines. Keeping this file ASCII removes the failure
#        mode. (check-lan.ps1 builds its Chinese output from [char] codes for
#        the same reason.)
#
#  NOTE: PowerShell variable names are case-insensitive. Do not use $home/$pid.
# =============================================================================

# -----------------------------------------------------------------------------
# Get-LanIPv4
#
# Returns the IPv4 address other machines on the Wi-Fi should use, or $null.
#
# Why this is not just "the first non-loopback address":
#   Windows keeps several virtual adapters (Wi-Fi Direct "Local Area
#   Connection* N", Hyper-V, VMware, WSL). They can hold a stale static address
#   while DISCONNECTED. On the dev machine a down Wi-Fi Direct adapter carried
#   192.168.0.1 and was enumerated BEFORE the WLAN adapter, so callers that
#   simply took the first hit tried to reach 192.168.0.1:5173 -- a dead
#   address -- and reported failures for a perfectly healthy site.
#
#   The reliable discriminator is the default gateway: the interface that
#   actually carries LAN traffic is the one with a gateway.
#
# Returns a PSCustomObject:
#   Ip      : the chosen address (or $null)
#   Others  : every other non-loopback IPv4, for diagnostics
#   Source  : which rule matched, so a wrong pick is debuggable
# -----------------------------------------------------------------------------
function Get-LanIPv4 {
    [CmdletBinding()]
    param()

    # Full candidate list (used for the Others diagnostic field).
    $all = @()
    try {
        $all = @(Get-NetIPAddress -AddressFamily IPv4 -ErrorAction Stop |
            Where-Object { $_.IPAddress -notlike '127.*' -and $_.IPAddress -notlike '169.254.*' } |
            Select-Object -ExpandProperty IPAddress)
    } catch {
        # Fallback: parse ipconfig, which works without the NetTCPIP module.
        $all = @(ipconfig | Select-String 'IPv4' | ForEach-Object {
            if ($_ -match '(\d+\.\d+\.\d+\.\d+)') { $matches[1] }
        } | Where-Object { $_ -and $_ -notlike '127.*' -and $_ -notlike '169.254.*' })
    }
    $all = @($all | Sort-Object -Unique)

    # Addresses on Up, non-loopback interfaces that have a default gateway.
    $gatewayIps = @()
    try {
        foreach ($ni in [System.Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces()) {
            if ($ni.OperationalStatus.ToString() -ne 'Up') { continue }
            if ($ni.NetworkInterfaceType.ToString() -eq 'Loopback') { continue }
            $props = $ni.GetIPProperties()
            if (-not $props) { continue }
            if ($props.GatewayAddresses.Count -eq 0) { continue }
            foreach ($ua in $props.UnicastAddresses) {
                if ($ua.Address.AddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetwork) {
                    $gatewayIps += $ua.Address.ToString()
                }
            }
        }
    } catch { $gatewayIps = @() }
    $gatewayIps = @($gatewayIps | Sort-Object -Unique)

    $isPrivate = {
        param($a)
        return ($a -match '^(10|192\.168|172\.(1[6-9]|2\d|3[01]))\.')
    }

    $ip = $null
    $source = 'none'

    $cand = @($gatewayIps | Where-Object { & $isPrivate $_ })
    if ($cand.Count -gt 0) { $ip = $cand[0]; $source = 'gateway+private' }

    if (-not $ip) {
        $cand = @($gatewayIps)
        if ($cand.Count -gt 0) { $ip = $cand[0]; $source = 'gateway' }
    }
    if (-not $ip) {
        $cand = @($all | Where-Object { & $isPrivate $_ })
        if ($cand.Count -gt 0) { $ip = $cand[0]; $source = 'private-fallback' }
    }
    if (-not $ip) {
        if ($all.Count -gt 0) { $ip = $all[0]; $source = 'any-fallback' }
    }

    $others = @($all | Where-Object { $_ -ne $ip })

    [PSCustomObject]@{
        Ip     = $ip
        Others = $others
        Source = $source
    }
}

# -----------------------------------------------------------------------------
# Test-PortListening
#
# True when something is LISTENING on $Port. Pure netstat, no connection made.
# -----------------------------------------------------------------------------
function Test-PortListening {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)][int]$Port)

    $text = (netstat -ano 2>$null | Select-String 'LISTENING') -join "`n"
    return ($text -match ":$Port\s")
}

# -----------------------------------------------------------------------------
# Get-PortBindAddress
#
# Every local address a port is bound to, most-lan-visible first.
# Empty array when the port is not listening.
#
# Why "every" and not "the first row": netstat lists a port once per socket, so
# a server bound to all interfaces shows up as BOTH '[::]:5173' and
# '0.0.0.0:5173' (and sometimes '127.0.0.1:5173' from a second, local-only
# listener). Taking row [0] therefore picked '[::1]' on the dev machine and the
# checker announced "localhost only" for a site that was in fact reachable from
# the whole Wi-Fi. Order the results so '0.0.0.0' wins.
# -----------------------------------------------------------------------------
function Get-PortBindAddresses {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)][int]$Port)

    $rows = @(netstat -ano 2>$null | Select-String 'LISTENING' | Where-Object { $_.Line -match ":$Port\s" })
    if ($rows.Count -eq 0) { return @() }

    # netstat's local-address column is "IP:PORT" (e.g. '0.0.0.0:5173'), NOT a
    # bare IP. Comparing the raw column against '0.0.0.0' therefore never
    # matches and every listener looks local-only -- that bug made this checker
    # announce "localhost only" for a site reachable across the whole Wi-Fi.
    # Strip the port, and handle IPv6 '[::]:5173' where the brackets matter.
    $addrs = @($rows | ForEach-Object { ($_.Line.Trim() -split '\s+')[1] } |
        ForEach-Object {
            $a = $_
            if ($a -match '^\[(.+)\]:\d+$') { "[$($matches[1])]" }
            elseif ($a -match '^(.+):\d+$') { $matches[1] }
            else { $a }
        } | Sort-Object -Unique)

    # 0.0.0.0 (all IPv4 interfaces) is the one that makes the site reachable
    # from other devices; '[::]' also covers IPv6 but is reported second because
    # the LAN URL handed to users is IPv4.
    $rank = {
        param($a)
        if ($a -eq '0.0.0.0') { return 0 }
        if ($a -eq '[::]') { return 1 }
        if ($a -like '127.*' -or $a -eq '[::1]') { return 3 }
        return 2
    }
    return @($addrs | Sort-Object -Property @{ Expression = { & $rank $_ } })
}

# -----------------------------------------------------------------------------
# Get-PortBindAddress
#
# The single most-lan-visible bind address for a port, or '' when not listening.
# -----------------------------------------------------------------------------
function Get-PortBindAddress {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)][int]$Port)

    $all = @(Get-PortBindAddresses -Port $Port)
    if ($all.Count -eq 0) { return '' }
    return $all[0]
}

# -----------------------------------------------------------------------------
# Test-PortBoundAll
#
# True when the port is bound to every interface (IPv4 0.0.0.0 or IPv6 [::]),
# i.e. other devices on the LAN can reach it.
# -----------------------------------------------------------------------------
function Test-PortBoundAll {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)][int]$Port)

    $all = @(Get-PortBindAddresses -Port $Port)
    return (@($all | Where-Object { $_ -eq '0.0.0.0' -or $_ -eq '[::]' }).Count -gt 0)
}

# -----------------------------------------------------------------------------
# Test-HttpOk
#
# True when $Url answers with a 2xx/3xx status.
#
# Why not just Test-PortListening for a service check: a TCP port can be open
# and the process still unable to serve (still booting, wrong app on the port).
# For "is the NLP service usable" the port tells you almost nothing.
# -----------------------------------------------------------------------------
function Test-HttpOk {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$Url,
        [int]$TimeoutSec = 5
    )

    try {
        $resp = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec $TimeoutSec -ErrorAction Stop
        return ($resp.StatusCode -ge 200 -and $resp.StatusCode -lt 400)
    } catch {
        return $false
    }
}

# -----------------------------------------------------------------------------
# Get-ListeningPid
#
# Owning process id of whatever listens on $Port, or $null.
# -----------------------------------------------------------------------------
function Get-ListeningPid {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)][int]$Port)

    $rows = @(netstat -ano 2>$null | Select-String 'LISTENING' | Where-Object { $_.Line -match ":$Port\s" })
    if ($rows.Count -eq 0) { return $null }
    $parts = $rows[0].Line.Trim() -split '\s+'
    if ($parts.Count -lt 5) { return $null }
    return [int]$parts[-1]
}
