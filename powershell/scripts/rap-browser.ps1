param(
    [string]$Url = "https://luna.server-start.de/survey/remote-arbeitsplatz",
    [string]$Hostname = $env:COMPUTERNAME,
    [string]$Username = $env:USERNAME,
    [string]$Trigger = "manual"
)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$fullUrl = "$Url`?hostname=$Hostname&username=$Username&trigger=$Trigger"

$form = New-Object System.Windows.Forms.Form
$form.Text = "serverstart managed IT - Remote-Arbeitsplatz"
$form.Size = New-Object System.Drawing.Size(900, 600)
$form.StartPosition = "CenterScreen"
$form.TopMost = $true

# Icon setzen (falls vorhanden)
$iconPath = "$env:ProgramData\serverstart\assets\images\serverstart.ico"
if (Test-Path $iconPath) {
    $form.Icon = New-Object System.Drawing.Icon($iconPath)
}

$browser = New-Object System.Windows.Forms.WebBrowser
$browser.Dock = "Fill"
$browser.ScriptErrorsSuppressed = $true
$browser.Navigate($fullUrl)
$form.Controls.Add($browser)

# Timer für regelmäßige Prüfung
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 500  # Alle 500ms prüfen
$timer.Add_Tick({
    # Fenster im Vordergrund halten
    if (-not $form.Focused) {
        $form.Activate()
    }
    
    # Prüfen ob Webseite "CLOSE" im Titel hat
    if ($browser.Document.Title -match "CLOSE") {
        $form.Close()
    }
})
$timer.Start()

$form.Add_FormClosing({ $timer.Stop(); $timer.Dispose() })

[void]$form.ShowDialog()