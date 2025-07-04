# Holiday Dashboard Web Part - Deployment Guide

This guide provides step-by-step instructions for deploying the Holiday Dashboard web part to your SharePoint environment.

## Pre-Deployment Setup

### 1. Create the SharePoint List

Before deploying the web part, you need to create a SharePoint list to store holiday information.

#### Step 1: Create the List
1. Navigate to your SharePoint site
2. Click **Settings** (gear icon) → **Site Contents**
3. Click **+ New** → **List**
4. Choose **Blank list**
5. Name the list: **Company Holidays**
6. Click **Create**

#### Step 2: Configure List Columns

Add the following columns to your list:

**1. Title Column (already exists)**
- Type: Single line of text
- Required: Yes
- Description: Name of the holiday

**2. HolidayDate Column**
1. Click **+ Add column** → **Date and time**
2. Column name: **HolidayDate**
3. Required: **Yes**
4. Include time: **No** (date only)
5. Default value: **None**
6. Click **Save**

**3. HolidayType Column**
1. Click **+ Add column** → **Choice**
2. Column name: **HolidayType**
3. Required: **No**
4. Choices (one per line):
   ```
   Public
   Company
   Optional
   Religious
   ```
5. Default value: **Public**
6. Display choices using: **Drop-Down Menu**
7. Click **Save**

**4. HolidayTag Column**
1. Click **+ Add column** → **Single line of text**
2. Column name: **HolidayTag**
3. Required: **No**
4. Description: Additional tag or description
5. Click **Save**

**5. HolidayGraphic Column**
1. Click **+ Add column** → **Image**
2. Column name: **HolidayGraphic**
3. Required: **No**
4. Description: Holiday image or graphic
5. Click **Save**

### 2. Add Sample Holiday Data

Add some sample holidays to test the web part:

| Title | HolidayDate | HolidayType | HolidayTag | HolidayGraphic |
|-------|-------------|-------------|------------|----------------|
| New Year's Day | 2024-01-01 | Public | Federal Holiday | [Upload image] |
| Presidents Day | 2024-02-19 | Public | Federal Holiday | [Upload image] |
| Memorial Day | 2024-05-27 | Public | Federal Holiday | [Upload image] |
| Independence Day | 2024-07-04 | Public | Federal Holiday | [Upload image] |
| Labor Day | 2024-09-02 | Public | Federal Holiday | [Upload image] |
| Thanksgiving | 2024-11-28 | Public | Federal Holiday | [Upload image] |
| Christmas Day | 2024-12-25 | Public | Federal Holiday | [Upload image] |
| Company Retreat | 2024-06-15 | Company | Team Building | [Upload image] |
| Diwali | 2024-10-31 | Religious | Optional | [Upload image] |

## SharePoint Framework Deployment

### 1. Build the Solution

```bash
# Install dependencies (if not already done)
npm install

# Build the solution for production
gulp build
gulp bundle --ship
gulp package-solution --ship
```

### 2. Deploy to App Catalog

1. Navigate to your SharePoint Admin Center
2. Go to **Apps** → **App Catalog**
3. Click **Distribute apps for SharePoint**
4. Click **Upload** and select the `.sppkg` file from `sharepoint/solution/` folder
5. In the deployment dialog:
   - Check **Make this solution available to all sites in the organization**
   - Click **Deploy**

### 3. Add API Permissions (if required)

The web part uses SharePoint REST API which should work automatically, but if you encounter permission issues:

1. Go to SharePoint Admin Center
2. Navigate to **Advanced** → **API access**
3. Approve any pending requests for the Holiday Dashboard web part

## Web Part Configuration

### 1. Add Web Part to Page

1. Navigate to the page where you want to add the web part
2. Edit the page
3. Click **+** to add a web part
4. Search for **Holiday Dashboard**
5. Add the web part to your page

### 2. Configure Web Part Properties

1. Click the **Edit** (pencil) icon on the web part
2. In the property pane:
   - **Description**: Enter a description (optional)
   - **Holiday List Name**: Enter "Company Holidays" or your custom list name
3. Click **Republish** to save changes

## Testing and Validation

### 1. Verify Basic Functionality

- [ ] Web part loads without errors
- [ ] Next upcoming holiday is displayed
- [ ] Holiday information is accurate
- [ ] Graphics display correctly (if present)

### 2. Test Interactive Features

- [ ] Click on the web part to view full holiday list
- [ ] Back button returns to card view
- [ ] All holidays for the year are displayed
- [ ] Holiday types are color-coded correctly

### 3. Test Responsive Design

- [ ] Small view (edit mode) displays correctly
- [ ] Medium view (read mode) shows graphics
- [ ] Layout adapts to different screen sizes

### 4. Test Error Scenarios

- [ ] Web part handles missing list gracefully
- [ ] Empty list shows appropriate message
- [ ] Invalid list name shows error message

## Permissions and Security

### Required Permissions

The web part requires the following permissions:
- **Read** access to the SharePoint site
- **Read** access to the holiday list
- **Read** access to any images stored in SharePoint

### Recommended Security Settings

1. **List Permissions**: Grant read access to all users who need to view holidays
2. **Site Permissions**: Ensure users have at least **Read** permissions to the site
3. **Image Libraries**: If storing images separately, ensure appropriate read permissions

## Customization Options

### 1. Custom List Schema

If you need different columns:
1. Modify the `IHolidayItem` interface in `src/webparts/holidayDashboard/models/IHolidayItem.ts`
2. Update the `HolidayService` class to handle new fields
3. Rebuild and redeploy the solution

### 2. Styling Customization

To customize the appearance:
1. Modify the SCSS files in the `components` folders
2. Update color schemes for holiday types
3. Adjust responsive breakpoints as needed

### 3. Additional Holiday Types

To add new holiday types:
1. Add choices to the SharePoint list
2. Update CSS classes in the SCSS files
3. Define color schemes for new types

## Troubleshooting

### Common Deployment Issues

**Issue**: Web part not appearing in web part gallery
- **Solution**: Ensure the solution is deployed and activated in the app catalog

**Issue**: Permission errors when accessing the list
- **Solution**: Check user permissions to the SharePoint site and list

**Issue**: Images not displaying
- **Solution**: Verify image URLs are accessible and users have read permissions

**Issue**: Date formatting issues
- **Solution**: Check regional settings in SharePoint site settings

### Performance Considerations

- **List Size**: The web part loads all upcoming holidays. For large lists, consider implementing pagination
- **Image Size**: Optimize images for web to improve loading performance
- **Caching**: Consider implementing caching for frequently accessed data

## Maintenance

### Regular Tasks

1. **Update Holiday Data**: Add new holidays as they are announced
2. **Remove Past Holidays**: Archive or delete past holidays to improve performance
3. **Update Images**: Refresh holiday graphics as needed
4. **Monitor Performance**: Check web part loading times and user feedback

### Backup and Recovery

1. **Export List Data**: Regularly export holiday list data
2. **Document Customizations**: Keep records of any customizations made
3. **Version Control**: Maintain version control for the web part code

## Support and Maintenance

For ongoing support:
1. Monitor SharePoint health dashboard
2. Review user feedback and usage analytics
3. Plan for SharePoint Framework version updates
4. Test web part after major SharePoint updates

## Appendix

### Sample PowerShell Scripts

#### Create List via PowerShell
```powershell
# Connect to SharePoint
Connect-PnPOnline -Url "https://yourtenant.sharepoint.com/sites/yoursite"

# Create the list
New-PnPList -Title "Company Holidays" -Template GenericList

# Add columns
Add-PnPField -List "Company Holidays" -DisplayName "HolidayDate" -InternalName "HolidayDate" -Type DateTime -Required
Add-PnPField -List "Company Holidays" -DisplayName "HolidayType" -InternalName "HolidayType" -Type Choice -Choices @("Public","Company","Optional","Religious")
Add-PnPField -List "Company Holidays" -DisplayName "HolidayTag" -InternalName "HolidayTag" -Type Text
Add-PnPField -List "Company Holidays" -DisplayName "HolidayGraphic" -InternalName "HolidayGraphic" -Type ThumbnailImage
```

### Additional Resources

- [SharePoint Framework Documentation](https://docs.microsoft.com/en-us/sharepoint/dev/spfx/)
- [Office UI Fabric React Components](https://developer.microsoft.com/en-us/fluentui#/controls/web)
- [SharePoint REST API Reference](https://docs.microsoft.com/en-us/sharepoint/dev/sp-add-ins/complete-basic-operations-using-sharepoint-rest-endpoints)