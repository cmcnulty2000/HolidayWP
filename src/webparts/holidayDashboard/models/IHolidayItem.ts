export interface IHolidayItem {
  Id: number;
  Title: string;
  HolidayDate: string;
  HolidayType?: string;
  HolidayTag?: string;
  HolidayGraphic?: {
    Description: string;
    Url: string;
  };
  Created: string;
  Modified: string;
}