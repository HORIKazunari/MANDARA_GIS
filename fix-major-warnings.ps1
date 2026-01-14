# fix-major-warnings.ps1
$ErrorActionPreference = "Stop"

Write-Host "=== Visual Basic 警告修正スクリプト ===" -ForegroundColor Cyan
Write-Host ""

# 修正対象ファイルと内容のマップ
$fixes = @(
    @{
        File = "mandara2\frmPrintRelated\frmPrint_TileMapOut.vb"
        Line = 355
        Old = "        Const adTypeText = 2, adSaveCreateOverwrite = 2"
        New = "        ' 未使用定数を削除"
        Description = "未使用定数削除"
    },
    @{
        File = "mandara2\spatial.vb"
        LineStart = 1650
        LineEnd = 1651
        Old = "        End Select`r`n    End Function"
        New = @"
            Case Else
                ' サポートされていない投影法
                x = 0
                y = 0
                Return False
        End Select
    End Function
"@
        Description = "Proj関数の戻り値パス追加"
    },
    @{
        File = "mandara2\spatial.vb"
        LineStart = 2093
        LineEnd = 2094
        Find = "    End Function"
        Context = "Get_MeshCode_from_LatLon"
        InsertBefore = "        Return Nothing"
        Description = "Get_MeshCode_from_LatLon関数の戻り値追加"
    }
)

$modifiedFiles = @()

foreach ($fix in $fixes) {
    $filePath = $fix.File
    
    if (-not (Test-Path $filePath)) {
        Write-Host "⚠ ファイルが見つかりません: $filePath" -ForegroundColor Red
        continue
    }
    
    Write-Host "処理中: $filePath" -ForegroundColor Yellow
    Write-Host "  $($fix.Description)" -ForegroundColor Gray
    
    try {
        $content = Get-Content $filePath -Encoding UTF8 -Raw
        $modified = $false
        
        if ($fix.Old -and $fix.New) {
            if ($content -match [regex]::Escape($fix.Old)) {
                $content = $content -replace [regex]::Escape($fix.Old), $fix.New
                $modified = $true
            }
        }
        
        if ($modified) {
            $content | Set-Content $filePath -Encoding UTF8 -NoNewline
            Write-Host "  ✓ 修正完了" -ForegroundColor Green
            $modifiedFiles += $filePath
        } else {
            Write-Host "  ⚠ パターンが見つかりませんでした" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "  ✗ エラー: $_" -ForegroundColor Red
    }
    
    Write-Host ""
}

Write-Host "=== 修正完了 ===" -ForegroundColor Cyan
Write-Host "修正したファイル数: $($modifiedFiles.Count)" -ForegroundColor Green
$modifiedFiles | ForEach-Object { Write-Host "  - $_" }
