# Holiday Dashboard - Web Part Deployment Script
# This script builds and deploys the Holiday Dashboard web part to SharePoint

param(
    [Parameter(Mandatory=$false)]
    [string]$TenantUrl,
    
    [Parameter(Mandatory=$false)]
    [string]$AppCatalogUrl,
    
    [Parameter(Mandatory=$false)]
    [switch]$BuildOnly,
    
    [Parameter(Mandatory=$false)]
    [switch]$DeployOnly,
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipFeatureDeployment,
    
    [Parameter(Mandatory=$false)]
    [switch]$Overwrite
)

# Function to check if running in correct directory
function Test-SPFxProject {
    if (!(Test-Path "package.json") -or !(Test-Path "gulpfile.js")) {
        Write-Host "Error: This script must be run from the SharePoint Framework project root directory." -ForegroundColor Red
        exit 1
    }
    
    $packageJson = Get-Content "package.json" | ConvertFrom-Json
    if ($packageJson.dependencies.'@microsoft/sp-webpart-base') {
        Write-Host "✓ Confirmed SharePoint Framework project" -ForegroundColor Green
        return $true
    } else {
        Write-Host "Error: This doesn't appear to be a SharePoint Framework project." -ForegroundColor Red
        exit 1
    }
}

# Function to build the solution
function Build-Solution {
    Write-Host "`n=== Building Solution ===" -ForegroundColor Yellow
    
    # Clean previous builds
    Write-Host "Cleaning previous builds..." -ForegroundColor Green
    if (Test-Path "lib") { Remove-Item "lib" -Recurse -Force }
    if (Test-Path "dist") { Remove-Item "dist" -Recurse -Force }
    if (Test-Path "temp") { Remove-Item "temp" -Recurse -Force }
    
    # Run gulp clean
    Write-Host "Running gulp clean..." -ForegroundColor Green
    $result = & npm run clean 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Warning: Clean command failed, continuing..." -ForegroundColor Yellow
    }
    
    # Build the solution
    Write-Host "Building solution..." -ForegroundColor Green
    $result = & npx gulp build 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Build failed" -ForegroundColor Red
        Write-Host $result -ForegroundColor Red
        exit 1
    }
    
    # Bundle for production
    Write-Host "Bundling for production..." -ForegroundColor Green
    $result = & npx gulp bundle --ship 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Bundle failed" -ForegroundColor Red
        Write-Host $result -ForegroundColor Red
        exit 1
    }
    
    # Package solution
    Write-Host "Packaging solution..." -ForegroundColor Green
    $result = & npx gulp package-solution --ship 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Package failed" -ForegroundColor Red
        Write-Host $result -ForegroundColor Red
        exit 1
    }
    
    # Check if package was created
    $packagePath = "sharepoint/solution/*.sppkg"
    $package = Get-ChildItem $packagePath | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    
    if ($package) {
        Write-Host "✓ Solution packaged successfully: $($package.Name)" -ForegroundColor Green
        Write-Host "  Package size: $([math]::Round($package.Length / 1MB, 2)) MB" -ForegroundColor Cyan
        Write-Host "  Package path: $($package.FullName)" -ForegroundColor Cyan
        return $package
    } else {
        Write-Host "Error: Package file not found" -ForegroundColor Red
        exit 1
    }
}

# Function to deploy to SharePoint
function Deploy-ToSharePoint {
    param($PackageFile)
    
    Write-Host "`n=== Deploying to SharePoint ===" -ForegroundColor Yellow
    
    # Validate URLs
    if (!$TenantUrl -and !$AppCatalogUrl) {
        Write-Host "Error: Either TenantUrl or AppCatalogUrl must be specified for deployment" -ForegroundColor Red
        exit 1
    }
    
    # Determine App Catalog URL if not provided
    if (!$AppCatalogUrl -and $TenantUrl) {
        $AppCatalogUrl = $TenantUrl.Replace(".sharepoint.com", "-admin.sharepoint.com") + "/sites/appcatalog"
        Write-Host "Using App Catalog URL: $AppCatalogUrl" -ForegroundColor Cyan
    }
    
    # Import SharePoint PnP module
    if (!(Get-Module -ListAvailable -Name PnP.PowerShell)) {
        Write-Host "Installing PnP.PowerShell module..." -ForegroundColor Yellow
        Install-Module -Name PnP.PowerShell -Force -AllowClobber
    }
    
    Import-Module PnP.PowerShell
    
    try {
        # Connect to App Catalog
        Write-Host "Connecting to App Catalog: $AppCatalogUrl" -ForegroundColor Green
        Connect-PnPOnline -Url $AppCatalogUrl -Interactive
        
        # Check if app already exists
        $existingApp = Get-PnPApp -Identity "holiday-dashboard-webpart-client-side-solution" -ErrorAction SilentlyContinue
        
        if ($existingApp -and !$Overwrite) {
            Write-Host "Warning: App already exists in catalog. Use -Overwrite to replace it." -ForegroundColor Yellow
            
            # Ask for confirmation
            $response = Read-Host "Do you want to overwrite the existing app? (y/N)"
            if ($response -ne "y" -and $response -ne "Y") {
                Write-Host "Deployment cancelled." -ForegroundColor Yellow
                return
            }
        }
        
        # Upload the package
        Write-Host "Uploading package to App Catalog..." -ForegroundColor Green
        if ($existingApp) {
            # Update existing app
            $app = Add-PnPApp -Path $PackageFile.FullName -Overwrite
            Write-Host "✓ App updated in catalog" -ForegroundColor Green
        } else {
            # Add new app
            $app = Add-PnPApp -Path $PackageFile.FullName
            Write-Host "✓ App uploaded to catalog" -ForegroundColor Green
        }
        
        # Deploy the app
        if (!$SkipFeatureDeployment) {
            Write-Host "Deploying app..." -ForegroundColor Green
            Publish-PnPApp -Identity $app.Id -SkipFeatureDeployment
            Write-Host "✓ App deployed to tenant" -ForegroundColor Green
        } else {
            Write-Host "Skipping feature deployment (add -SkipFeatureDeployment was specified)" -ForegroundColor Yellow
        }
        
        # Display deployment information
        Write-Host "`n=== Deployment Information ===" -ForegroundColor Yellow
        Write-Host "App Name: $($app.Title)" -ForegroundColor White
        Write-Host "App ID: $($app.Id)" -ForegroundColor White
        Write-Host "Version: $($app.AppVersion)" -ForegroundColor White
        Write-Host "Deployed: $(if(!$SkipFeatureDeployment) {'Yes'} else {'No'})" -ForegroundColor White
        
    }
    catch {
        Write-Host "Error during deployment: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
    finally {
        Disconnect-PnPOnline
    }
}

# Main execution
Write-Host "Holiday Dashboard Web Part - Deployment Script" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

# Validate environment
Test-SPFxProject

# Build solution (unless DeployOnly is specified)
$package = $null
if (!$DeployOnly) {
    $package = Build-Solution
} else {
    # Find existing package
    $packagePath = "sharepoint/solution/*.sppkg"
    $package = Get-ChildItem $packagePath | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    
    if (!$package) {
        Write-Host "Error: No package found for deployment. Run without -DeployOnly first." -ForegroundColor Red
        exit 1
    }
    
    Write-Host "Using existing package: $($package.Name)" -ForegroundColor Green
}

# Deploy solution (unless BuildOnly is specified)
if (!$BuildOnly -and $package) {
    Deploy-ToSharePoint -PackageFile $package
    
    Write-Host "`n=== Next Steps ===" -ForegroundColor Yellow
    Write-Host "1. Go to your SharePoint Admin Center" -ForegroundColor White
    Write-Host "2. Navigate to the App Catalog" -ForegroundColor White
    Write-Host "3. Find the 'Holiday Dashboard' app and ensure it's deployed" -ForegroundColor White
    Write-Host "4. Add the web part to your SharePoint pages" -ForegroundColor White
    Write-Host "5. Configure the web part properties (list name, description)" -ForegroundColor White
} elseif ($BuildOnly) {
    Write-Host "`n=== Build Completed ===" -ForegroundColor Yellow
    Write-Host "Package ready for manual deployment: $($package.FullName)" -ForegroundColor White
    Write-Host "Use the following command to deploy:" -ForegroundColor White
    Write-Host "  .\scripts\Deploy-WebPart.ps1 -DeployOnly -AppCatalogUrl 'https://tenant-admin.sharepoint.com/sites/appcatalog'" -ForegroundColor Cyan
}

Write-Host "`n✓ Script completed successfully!" -ForegroundColor Green