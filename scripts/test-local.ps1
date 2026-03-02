# Test Script for Echo Server
# Tests all endpoints locally or against a deployed URL

param(
    [string]$BaseUrl = "http://localhost:8080",
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"

Write-Host "=== Echo Server Test Suite ===" -ForegroundColor Cyan
Write-Host "Testing: $BaseUrl`n" -ForegroundColor Gray

$passed = 0
$failed = 0

function Test-Endpoint {
    param(
        [string]$Name,
        [string]$Method,
        [string]$Path,
        [string]$Body,
        [string]$ExpectedContains
    )
    
    $url = "$BaseUrl$Path"
    Write-Host -NoNewline "  $Name... "
    
    try {
        $params = @{
            Uri = $url
            Method = $Method
            ContentType = "application/json"
            TimeoutSec = 10
        }
        
        if ($Body) {
            $params.Body = $Body
        }
        
        $response = Invoke-RestMethod @params
        $responseJson = $response | ConvertTo-Json -Compress
        
        if ($ExpectedContains -and $responseJson -notlike "*$ExpectedContains*") {
            Write-Host "FAIL" -ForegroundColor Red
            if ($Verbose) {
                Write-Host "    Expected to contain: $ExpectedContains" -ForegroundColor Gray
                Write-Host "    Got: $responseJson" -ForegroundColor Gray
            }
            $script:failed++
            return
        }
        
        Write-Host "PASS" -ForegroundColor Green
        if ($Verbose) {
            Write-Host "    Response: $responseJson" -ForegroundColor Gray
        }
        $script:passed++
    }
    catch {
        Write-Host "FAIL" -ForegroundColor Red
        if ($Verbose) {
            Write-Host "    Error: $($_.Exception.Message)" -ForegroundColor Gray
        }
        $script:failed++
    }
}

Write-Host "Health Checks:" -ForegroundColor Yellow
Test-Endpoint -Name "GET /health" -Method GET -Path "/health" -ExpectedContains "healthy"

Write-Host "`nAPI Endpoints:" -ForegroundColor Yellow
Test-Endpoint -Name "POST /echo (simple)" -Method POST -Path "/echo" `
    -Body '{"message": "hello"}' -ExpectedContains "hello"

Test-Endpoint -Name "POST /echo (unicode)" -Method POST -Path "/echo" `
    -Body '{"message": "Hello 世界 🌍"}' -ExpectedContains "世界"

Test-Endpoint -Name "GET / (homepage)" -Method GET -Path "/" -ExpectedContains ""

# Summary
Write-Host ""
Write-Host "=== Results ===" -ForegroundColor Cyan
Write-Host "  Passed: $passed" -ForegroundColor Green
if ($failed -gt 0) {
    Write-Host "  Failed: $failed" -ForegroundColor Red
} else {
    Write-Host "  Failed: $failed" -ForegroundColor Gray
}

if ($failed -gt 0) {
    Write-Host ""
    Write-Host "Some tests failed. Run with -Verbose for details." -ForegroundColor Yellow
    exit 1
} else {
    Write-Host ""
    Write-Host "All tests passed!" -ForegroundColor Green
    exit 0
}
