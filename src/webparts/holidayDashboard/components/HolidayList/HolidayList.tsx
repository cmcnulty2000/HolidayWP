import * as React from 'react';
import { IHolidayItem } from '../../models/IHolidayItem';
import { HolidayService } from '../../services/HolidayService';
import styles from './HolidayList.module.scss';
import { Text } from 'office-ui-fabric-react/lib/Text';
import { IconButton } from 'office-ui-fabric-react/lib/Button';
import { Icon } from 'office-ui-fabric-react/lib/Icon';
import { List } from 'office-ui-fabric-react/lib/List';

export interface IHolidayListProps {
  holidays: IHolidayItem[];
  onBack: () => void;
  holidayService: HolidayService;
}

export const HolidayList: React.FunctionComponent<IHolidayListProps> = (props) => {
  const { holidays, onBack, holidayService } = props;

  const renderHolidayItem = (item: IHolidayItem): JSX.Element => {
    const daysUntil = holidayService.getDaysUntilHoliday(item.HolidayDate);
    const formattedDate = holidayService.formatDate(item.HolidayDate);

    const getDaysUntilText = (days: number): string => {
      if (days === 0) return 'Today';
      if (days === 1) return 'Tomorrow';
      if (days < 7) return `${days} days`;
      if (days < 14) return `Next week`;
      if (days < 30) return `${Math.ceil(days / 7)} weeks`;
      return `${Math.ceil(days / 30)} months`;
    };

    return (
      <div key={item.Id} className={styles.holidayItem}>
        <div className={styles.dateColumn}>
          <Text variant="medium" className={styles.daysUntil}>
            {getDaysUntilText(daysUntil)}
          </Text>
          <Text variant="small" className={styles.date}>
            {formattedDate}
          </Text>
        </div>
        
        <div className={styles.contentColumn}>
          <div className={styles.titleRow}>
            <Text variant="mediumPlus" className={styles.title}>
              {item.Title}
            </Text>
            {item.HolidayType && (
              <div className={`${styles.tag} ${styles[item.HolidayType.toLowerCase()]}`}>
                {item.HolidayType}
              </div>
            )}
          </div>
          
          {item.HolidayTag && (
            <Text variant="small" className={styles.tag}>
              {item.HolidayTag}
            </Text>
          )}
        </div>
        
        {item.HolidayGraphic?.Url && (
          <div className={styles.imageColumn}>
            <img 
              src={item.HolidayGraphic.Url} 
              alt={item.HolidayGraphic.Description || item.Title}
              className={styles.holidayImage}
            />
          </div>
        )}
      </div>
    );
  };

  return (
    <div className={styles.holidayList}>
      <div className={styles.header}>
        <IconButton
          iconProps={{ iconName: 'Back' }}
          title="Back to holiday card"
          onClick={onBack}
          className={styles.backButton}
        />
        <Text variant="xLarge" className={styles.title}>
          Upcoming Holidays
        </Text>
      </div>
      
      <div className={styles.content}>
        {holidays.length === 0 ? (
          <div className={styles.noHolidays}>
            <Icon iconName="Calendar" className={styles.icon} />
            <Text variant="mediumPlus">No upcoming holidays found</Text>
            <Text variant="small">Check back later for updates</Text>
          </div>
        ) : (
          <List
            items={holidays}
            onRenderCell={renderHolidayItem}
            className={styles.holidaysList}
          />
        )}
      </div>
    </div>
  );
};