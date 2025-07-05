import { SPHttpClient, SPHttpClientResponse } from '@microsoft/sp-http';
import { WebPartContext } from '@microsoft/sp-webpart-base';
import { IHolidayItem } from '../models/IHolidayItem';

export class HolidayService {
  private context: WebPartContext;
  private listName: string;

  constructor(context: WebPartContext, listName: string = 'Company Holidays') {
    this.context = context;
    this.listName = listName;
  }

  public async getUpcomingHolidays(): Promise<IHolidayItem[]> {
    const today = new Date().toISOString();
    const nextYear = new Date();
    nextYear.setFullYear(nextYear.getFullYear() + 1);
    
    const selectFields = 'Id,Title,HolidayDate,HolidayType,HolidayTag,HolidayGraphic,Created,Modified';
    const filterQuery = `HolidayDate ge '${today}' and HolidayDate le '${nextYear.toISOString()}'`;
    const orderBy = 'HolidayDate asc';
    
    const endpoint = `${this.context.pageContext.web.absoluteUrl}/_api/web/lists/getbytitle('${this.listName}')/items?$select=${selectFields}&$filter=${filterQuery}&$orderby=${orderBy}`;

    try {
      const response: SPHttpClientResponse = await this.context.spHttpClient.get(
        endpoint,
        SPHttpClient.configurations.v1
      );

      if (response.ok) {
        const data = await response.json();
        return data.value as IHolidayItem[];
      } else {
        console.error('Error fetching holidays:', response.statusText);
        return [];
      }
    } catch (error) {
      console.error('Error fetching holidays:', error);
      return [];
    }
  }

  public async getNextUpcomingHoliday(): Promise<IHolidayItem | null> {
    const holidays = await this.getUpcomingHolidays();
    return holidays.length > 0 ? holidays[0] : null;
  }

  public formatDate(dateString: string): string {
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', {
      weekday: 'long',
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    });
  }

  public getDaysUntilHoliday(dateString: string): number {
    const today = new Date();
    const holidayDate = new Date(dateString);
    const diffTime = holidayDate.getTime() - today.getTime();
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    return diffDays;
  }
}