# Comprehensive fix for Container Apps connectivity
Write-Host "Starting comprehensive Container Apps connectivity fix..." -ForegroundColor Green

# Step 1: Restart Container Apps to ensure they're running properly
Write-Host "Restarting Container Apps..." -ForegroundColor Yellow
az containerapp revision restart --name ca-frontend --resource-group Yousef-rg
az containerapp revision restart --name ca-backend --resource-group Yousef-rg

# Wait for restart to complete
Write-Host "Waiting for Container Apps to restart..." -ForegroundColor Yellow
Start-Sleep -Seconds 60

# Step 2: Check Container Apps status
Write-Host "Checking Container Apps status..." -ForegroundColor Yellow
$frontendStatus = az containerapp show --name ca-frontend --resource-group Yousef-rg --query "properties.provisioningState" --output tsv
$backendStatus = az containerapp show --name ca-backend --resource-group Yousef-rg --query "properties.provisioningState" --output tsv

Write-Host "Frontend Status: $frontendStatus" -ForegroundColor Cyan
Write-Host "Backend Status: $backendStatus" -ForegroundColor Cyan

# Step 3: Test internal connectivity (this won't work from outside VNet but will show DNS resolution)
Write-Host "Testing DNS resolution..." -ForegroundColor Yellow
nslookup ca-frontend.internal.whitedesert-4d6c9740.westus2.azurecontainerapps.io
nslookup ca-backend.internal.whitedesert-4d6c9740.westus2.azurecontainerapps.io

# Step 4: Check Application Gateway backend health
Write-Host "Checking Application Gateway backend health..." -ForegroundColor Yellow
az network application-gateway show-backend-health --name agw-yousef-burgerbuilder --resource-group Yousef-rg --query "backendAddressPools[].backendHttpSettingsCollection[].servers[]" --output table

# Step 5: Test endpoints
Write-Host "Testing endpoints through Application Gateway..." -ForegroundColor Yellow
try {
    $frontendResponse = Invoke-WebRequest -Uri "http://4.246.67.74" -Method Get -ErrorAction SilentlyContinue
    Write-Host "Frontend Response: $($frontendResponse.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "Frontend Error: $($_.Exception.Message)" -ForegroundColor Red
}

try {
    $backendResponse = Invoke-WebRequest -Uri "http://4.246.67.74/api/health" -Method Get -ErrorAction SilentlyContinue
    Write-Host "Backend Response: $($backendResponse.StatusCode)" -ForegroundColor Green
    Write-Host "Backend Content: $($backendResponse.Content)" -ForegroundColor Green
} catch {
    Write-Host "Backend Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "Connectivity fix completed!" -ForegroundColor Green