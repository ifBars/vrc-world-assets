param(
    [string]$Path = "questions.txt"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $Path)) {
    throw "Question file not found: $Path"
}

$lines = Get-Content -LiteralPath $Path
$categoryCount = 0
$questionCount = 0
$currentCategory = $null
$currentCategoryQuestionCount = 0
$errors = New-Object System.Collections.Generic.List[string]

for ($i = 0; $i -lt $lines.Count; $i++) {
    $lineNumber = $i + 1
    $line = $lines[$i].Trim()

    if ($line.Length -eq 0 -or $line.StartsWith("//")) {
        continue
    }

    if ($line.StartsWith("## ")) {
        if ($currentCategory -ne $null -and $currentCategoryQuestionCount -eq 0) {
            $errors.Add("Line ${lineNumber}: category '$currentCategory' has no questions.")
        }

        $currentCategory = $line.Substring(3).Trim()
        $currentCategoryQuestionCount = 0

        if ($currentCategory.Length -eq 0) {
            $errors.Add("Line ${lineNumber}: category name is empty.")
        } else {
            $categoryCount++
        }

        continue
    }

    if ($line.StartsWith("- ")) {
        if ($currentCategory -eq $null) {
            $errors.Add("Line ${lineNumber}: question appears before any category.")
        }

        $question = $line.Substring(2).Trim()
        if ($question.Length -eq 0) {
            $errors.Add("Line ${lineNumber}: question is empty.")
        } else {
            $questionCount++
            $currentCategoryQuestionCount++
        }

        continue
    }

    $errors.Add("Line ${lineNumber}: expected '## Category' or '- Question'.")
}

if ($currentCategory -ne $null -and $currentCategoryQuestionCount -eq 0) {
    $errors.Add("End of file: category '$currentCategory' has no questions.")
}

if ($categoryCount -eq 0) {
    $errors.Add("No categories found.")
}

if ($questionCount -eq 0) {
    $errors.Add("No questions found.")
}

if ($errors.Count -gt 0) {
    foreach ($errorMessage in $errors) {
        Write-Error $errorMessage
    }

    exit 1
}

Write-Host "Question file is valid: $categoryCount categories, $questionCount questions."
