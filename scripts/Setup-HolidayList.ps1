# Holiday Dashboard - SharePoint List Setup Script
# This script creates the Company Holidays list and populates it with sample data

param(
    [Parameter(Mandatory=$true)]
    [string]$SiteUrl,
    
    [Parameter(Mandatory=$false)]
    [string]$ListName = "Company Holidays",
    
    [Parameter(Mandatory=$false)]
    [switch]$AddSampleData
)

# Import SharePoint PnP module
if (!(Get-Module -ListAvailable -Name PnP.PowerShell)) {
    Write-Host "Installing PnP.PowerShell module..." -ForegroundColor Yellow
    Install-Module -Name PnP.PowerShell -Force -AllowClobber
}

Import-Module PnP.PowerShell

try {
    # Connect to SharePoint
    Write-Host "Connecting to SharePoint site: $SiteUrl" -ForegroundColor Green
    Connect-PnPOnline -Url $SiteUrl -Interactive
    
    # Check if list already exists
    $existingList = Get-PnPList -Identity $ListName -ErrorAction SilentlyContinue
    if ($existingList) {
        Write-Host "List '$ListName' already exists. Skipping creation." -ForegroundColor Yellow
    } else {
        # Create the list
        Write-Host "Creating list: $ListName" -ForegroundColor Green
        $list = New-PnPList -Title $ListName -Template GenericList -Description "Company holidays and important dates"
        
        # Add HolidayDate column
        Write-Host "Adding HolidayDate column..." -ForegroundColor Green
        Add-PnPField -List $ListName -DisplayName "Holiday Date" -InternalName "HolidayDate" -Type DateTime -Required
        
        # Add HolidayType column with choices
        Write-Host "Adding HolidayType column..." -ForegroundColor Green
        $choiceField = "<Field Type='Choice' DisplayName='Holiday Type' Required='FALSE' Format='Dropdown' StaticName='HolidayType' Name='HolidayType'>
            <CHOICES>
                <CHOICE>Public</CHOICE>
                <CHOICE>Company</CHOICE>
                <CHOICE>Optional</CHOICE>
                <CHOICE>Religious</CHOICE>
            </CHOICES>
            <Default>Public</Default>
        </Field>"
        Add-PnPFieldFromXml -List $ListName -FieldXml $choiceField
        
        # Add HolidayTag column
        Write-Host "Adding HolidayTag column..." -ForegroundColor Green
        Add-PnPField -List $ListName -DisplayName "Holiday Tag" -InternalName "HolidayTag" -Type Text
        
        # Add HolidayGraphic column
        Write-Host "Adding HolidayGraphic column..." -ForegroundColor Green
        Add-PnPField -List $ListName -DisplayName "Holiday Graphic" -InternalName "HolidayGraphic" -Type ThumbnailImage
        
        Write-Host "List '$ListName' created successfully!" -ForegroundColor Green
    }
    
    # Add sample data if requested
    if ($AddSampleData) {
        Write-Host "Adding sample holiday data..." -ForegroundColor Green
        
        # Get current year
        $currentYear = (Get-Date).Year
        
        # Sample holidays data
        $holidays = @(
            @{
                Title = "New Year's Day"
                HolidayDate = "$currentYear-01-01"
                HolidayType = "Public"
                HolidayTag = "Federal Holiday"
            },
            @{
                Title = "Martin Luther King Jr. Day"
                HolidayDate = "$currentYear-01-15"
                HolidayType = "Public"
                HolidayTag = "Federal Holiday"
            },
            @{
                Title = "Presidents Day"
                HolidayDate = "$currentYear-02-19"
                HolidayType = "Public"
                HolidayTag = "Federal Holiday"
            },
            @{
                Title = "Memorial Day"
                HolidayDate = "$currentYear-05-27"
                HolidayType = "Public"
                HolidayTag = "Federal Holiday"
            },
            @{
                Title = "Independence Day"
                HolidayDate = "$currentYear-07-04"
                HolidayType = "Public"
                HolidayTag = "Federal Holiday"
            },
            @{
                Title = "Labor Day"
                HolidayDate = "$currentYear-09-02"
                HolidayType = "Public"
                HolidayTag = "Federal Holiday"
            },
            @{
                Title = "Columbus Day"
                HolidayDate = "$currentYear-10-14"
                HolidayType = "Public"
                HolidayTag = "Federal Holiday"
            },
            @{
                Title = "Veterans Day"
                HolidayDate = "$currentYear-11-11"
                HolidayType = "Public"
                HolidayTag = "Federal Holiday"
            },
            @{
                Title = "Thanksgiving"
                HolidayDate = "$currentYear-11-28"
                HolidayType = "Public"
                HolidayTag = "Federal Holiday"
            },
            @{
                Title = "Christmas Day"
                HolidayDate = "$currentYear-12-25"
                HolidayType = "Public"
                HolidayTag = "Federal Holiday"
            },
            @{
                Title = "Company Annual Picnic"
                HolidayDate = "$currentYear-06-15"
                HolidayType = "Company"
                HolidayTag = "Team Building"
            },
            @{
                Title = "Company Holiday Party"
                HolidayDate = "$currentYear-12-20"
                HolidayType = "Company"
                HolidayTag = "Celebration"
            },
            @{
                Title = "Good Friday"
                HolidayDate = "$currentYear-03-29"
                HolidayType = "Religious"
                HolidayTag = "Christian"
            },
            @{
                Title = "Diwali"
                HolidayDate = "$currentYear-10-31"
                HolidayType = "Religious"
                HolidayTag = "Hindu"
            },
            @{
                Title = "Floating Holiday"
                HolidayDate = "$currentYear-08-15"
                HolidayType = "Optional"
                HolidayTag = "Personal Choice"
            }
        )
        
        # Add each holiday to the list
        $counter = 0
        foreach ($holiday in $holidays) {
            try {
                # Only add future holidays
                $holidayDate = [DateTime]::Parse($holiday.HolidayDate)
                if ($holidayDate -gt (Get-Date)) {
                    Add-PnPListItem -List $ListName -Values @{
                        "Title" = $holiday.Title
                        "HolidayDate" = $holiday.HolidayDate
                        "HolidayType" = $holiday.HolidayType
                        "HolidayTag" = $holiday.HolidayTag
                    }
                    $counter++
                    Write-Host "  Added: $($holiday.Title)" -ForegroundColor Cyan
                }
            }
            catch {
                Write-Host "  Error adding $($holiday.Title): $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        
        Write-Host "Added $counter sample holidays to the list." -ForegroundColor Green
    }
    
    # Display list information
    $listInfo = Get-PnPList -Identity $ListName
    $itemCount = (Get-PnPListItem -List $ListName).Count
    
    Write-Host "`n=== List Information ===" -ForegroundColor Yellow
    Write-Host "List Name: $($listInfo.Title)" -ForegroundColor White
    Write-Host "List URL: $($listInfo.DefaultViewUrl)" -ForegroundColor White
    Write-Host "Item Count: $itemCount" -ForegroundColor White
    Write-Host "List ID: $($listInfo.Id)" -ForegroundColor White
    
    Write-Host "`n=== Next Steps ===" -ForegroundColor Yellow
    Write-Host "1. Review and customize the holiday data in the list" -ForegroundColor White
    Write-Host "2. Add holiday images to the HolidayGraphic column" -ForegroundColor White
    Write-Host "3. Deploy the Holiday Dashboard web part" -ForegroundColor White
    Write-Host "4. Configure the web part to use list name: '$ListName'" -ForegroundColor White
    
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
finally {
    Disconnect-PnPOnline
}

Write-Host "`nHoliday list setup completed successfully!" -ForegroundColor Green