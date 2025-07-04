import { WebPartContext } from '@microsoft/sp-webpart-base';
import { DisplayMode } from '@microsoft/sp-core-library';

export interface IHolidayDashboardProps {
  description: string;
  context: WebPartContext;
  listName: string;
  displayMode: DisplayMode;
}