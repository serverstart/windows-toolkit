# RDP Performance Feedback Tool
# PowerShell GUI für Server-Performance-Bewertung

# Parameter
param(
    [string]$Trigger = "manual",
    [string]$Payload = ""
)

# Windows Forms laden (MUSS zuerst kommen!)
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Konfiguration
$phpEndpoint = "https://luna.server-start.de/api/survey/remote-arbeitsplatz"

# Formular erstellen
$form = New-Object System.Windows.Forms.Form
$form.Text = "Server Performance Feedback - serverstart managed IT"
$form.Size = New-Object System.Drawing.Size(600, 320)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.MinimizeBox = $false
$form.TopMost = $true

# Frage-Label
$labelQuestion = New-Object System.Windows.Forms.Label
$labelQuestion.Text = "Wie zufrieden sind Sie gerade im Moment mit der Server-Performance?"
$labelQuestion.Location = New-Object System.Drawing.Point(20, 20)
$labelQuestion.Size = New-Object System.Drawing.Size(540, 40)
$labelQuestion.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$labelQuestion.TextAlign = "MiddleCenter"
$form.Controls.Add($labelQuestion)

# Beschreibungstext
$labelDescription = New-Object System.Windows.Forms.Label
$labelDescription.Text = "Diese Umfrage hilft uns, die Server-Performance kontinuierlich zu ueberwachen und zu verbessern. Ihr Feedback ist wichtig! Bitte klicken Sie auf die entsprechende Bewertung."
$labelDescription.Location = New-Object System.Drawing.Point(30, 65)
$labelDescription.Size = New-Object System.Drawing.Size(520, 50)
$labelDescription.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$labelDescription.TextAlign = "MiddleCenter"
$labelDescription.ForeColor = [System.Drawing.Color]::FromArgb(100, 100, 100)
$form.Controls.Add($labelDescription)

# Funktion zum Senden des Feedbacks
function Send-Feedback {
    param([int]$Rating)
    
    $hostname = $env:COMPUTERNAME
    $username = $env:USERNAME
    
    try {
        # Alle Buttons deaktivieren
        foreach ($ctrl in $form.Controls) {
            if ($ctrl -is [System.Windows.Forms.Button]) {
                $ctrl.Enabled = $false
            }
        }

        # Header
        $headers = @{
            "Accept" = "application/json"
            "Content-Type" = "application/json"
        }
        
        # POST-Daten vorbereiten
        $body = @{
            hostname = $hostname
            username = $username
            rating = $Rating
            trigger = $Trigger
        }
        
        # Payload nur hinzufügen wenn vorhanden
        if (-not [string]::IsNullOrWhiteSpace($Payload)) {
            $body.payload = $Payload
        }

        $bodyAsJson = $body | ConvertTo-Json
        
        # HTTP-Request senden
        $response = Invoke-WebRequest -Uri $phpEndpoint -Method POST -Body $bodyAsJson -Headers $headers -TimeoutSec 5 -UseBasicParsing
        
        if ($response.StatusCode -eq 200) {
            [System.Windows.Forms.MessageBox]::Show(
                "Vielen Dank für Ihr Feedback!",
                "Erfolgreich",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Information
            )
            $form.Close()
        } else {
            throw "Server antwortete mit Status: $($response.StatusCode)"
        }
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show(
            "Fehler beim Senden des Feedbacks:`n$($_.Exception.Message)",
            "Fehler",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        )
        
        # Buttons wieder aktivieren
        foreach ($ctrl in $form.Controls) {
            if ($ctrl -is [System.Windows.Forms.Button]) {
                $ctrl.Enabled = $true
            }
        }
    }
}

# Bewertungs-Buttons erstellen (0-5)
$buttonWidth = 70
$buttonHeight = 70
$spacing = 12
$totalWidth = (6 * $buttonWidth) + (5 * $spacing)
$startX = ($form.ClientSize.Width - $totalWidth) / 2

$colors = @(
    [System.Drawing.Color]::FromArgb(220, 53, 69),   # 0 - Rot
    [System.Drawing.Color]::FromArgb(220, 53, 69),   # 1 - Rot
    [System.Drawing.Color]::FromArgb(255, 193, 7),   # 2 - Orange
    [System.Drawing.Color]::FromArgb(255, 235, 59),  # 3 - Gelb
    [System.Drawing.Color]::FromArgb(40, 167, 69),   # 4 - Grün
    [System.Drawing.Color]::FromArgb(40, 167, 69)    # 5 - Grün
)

for ($i = 0; $i -le 5; $i++) {
    $button = New-Object System.Windows.Forms.Button
    $button.Text = $i.ToString()
    $button.Location = New-Object System.Drawing.Point(($startX + $i * ($buttonWidth + $spacing)), 120)
    $button.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
    $button.Font = New-Object System.Drawing.Font("Segoe UI", 18, [System.Drawing.FontStyle]::Bold)
    $button.BackColor = $colors[$i]
    $button.ForeColor = [System.Drawing.Color]::White
    $button.FlatStyle = "Flat"
    $button.Tag = $i
    
    # Event-Handler
    $button.Add_Click({
        param($sender, $e)
        Send-Feedback -Rating $sender.Tag
    })
    
    $form.Controls.Add($button)
}

# Skala-Label
$labelScale = New-Object System.Windows.Forms.Label
$labelScale.Text = "0 = Sehr unzufrieden                                                            5 = Sehr zufrieden"
$labelScale.Location = New-Object System.Drawing.Point(20, 210)
$labelScale.Size = New-Object System.Drawing.Size(540, 20)
$labelScale.Font = New-Object System.Drawing.Font("Segoe UI", 8)
$labelScale.TextAlign = "MiddleCenter"
$labelScale.ForeColor = [System.Drawing.Color]::Gray
$form.Controls.Add($labelScale)

# Formular anzeigen
[void]$form.ShowDialog()