import * as React from 'react';
import * as ReactDom from 'react-dom';
import { Version } from '@microsoft/sp-core-library';
import {
  IPropertyPaneConfiguration,
  PropertyPaneTextField
} from '@microsoft/sp-property-pane';
import { BaseClientSideWebPart } from '@microsoft/sp-webpart-base';

import * as strings from 'HolidayDashboardWebPartStrings';
import HolidayDashboard from './components/HolidayDashboard';
import { IHolidayDashboardProps } from './components/IHolidayDashboardProps';

export interface IHolidayDashboardWebPartProps {
  description: string;
  listName: string;
}

export default class HolidayDashboardWebPart extends BaseClientSideWebPart<IHolidayDashboardWebPartProps> {

  public render(): void {
    const element: React.ReactElement<IHolidayDashboardProps> = React.createElement(
      HolidayDashboard,
      {
        description: this.properties.description,
        context: this.context,
        listName: this.properties.listName || 'Company Holidays',
        displayMode: this.displayMode
      }
    );

    ReactDom.render(element, this.domElement);
  }

  protected onDispose(): void {
    ReactDom.unmountComponentAtNode(this.domElement);
  }

  protected get dataVersion(): Version {
    return Version.parse('1.0');
  }

  protected getPropertyPaneConfiguration(): IPropertyPaneConfiguration {
    return {
      pages: [
        {
          header: {
            description: strings.PropertyPaneDescription
          },
          groups: [
            {
              groupName: strings.BasicGroupName,
              groupFields: [
                PropertyPaneTextField('description', {
                  label: strings.DescriptionFieldLabel
                }),
                PropertyPaneTextField('listName', {
                  label: strings.ListNameFieldLabel,
                  description: strings.ListNameFieldDescription
                })
              ]
            }
          ]
        }
      ]
    };
  }
}