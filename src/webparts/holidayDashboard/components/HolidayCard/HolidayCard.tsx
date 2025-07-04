import * as React from 'react';
import { IHolidayItem } from '../../models/IHolidayItem';
import { HolidayService } from '../../services/HolidayService';
import { DisplayMode } from '@microsoft/sp-core-library';
import styles from './HolidayCard.module.scss';
import { Text } from 'office-ui-fabric-react/lib/Text';
import { Icon } from 'office-ui-fabric-react/lib/Icon';

export interface IHolidayCardProps {
  holiday: IHolidayItem | null;
  displayMode: DisplayMode;
  onClick: () => void;
  holidayService: HolidayService;
}

export const HolidayCard: React.FunctionComponent<IHolidayCardProps> = (props) => {
  const { holiday, displayMode, onClick, holidayService } = props;

  if (!holiday) {
    return (
      <div className={`${styles.holidayCard} ${styles.noHoliday}`} onClick={onClick}>
        <div className={styles.content}>
          <Icon iconName="Calendar" className={styles.icon} />
          <Text variant="mediumPlus" className={styles.title}>
            No upcoming holidays
          </Text>
          <Text variant="small" className={styles.subtitle}>
            Click to view all holidays
          </Text>
        </div>
      </div>
    );
  }

  const isSmallView = displayMode === DisplayMode.Edit;
  const daysUntil = holidayService.getDaysUntilHoliday(holiday.HolidayDate);
  const formattedDate = holidayService.formatDate(holiday.HolidayDate);

  const getDaysUntilText = (days: number): string => {
    if (days === 0) return 'Today';
    if (days === 1) return 'Tomorrow';
    if (days < 7) return `In ${days} days`;
    if (days < 14) return `Next week`;
    if (days < 30) return `In ${Math.ceil(days / 7)} weeks`;
    return `In ${Math.ceil(days / 30)} months`;
  };

  return (
    <div className={`${styles.holidayCard} ${isSmallView ? styles.small : styles.medium}`} onClick={onClick}>
      <div className={styles.content}>
        {!isSmallView && holiday.HolidayGraphic?.Url && (
          <div className={styles.imageContainer}>
            <img 
              src={holiday.HolidayGraphic.Url} 
              alt={holiday.HolidayGraphic.Description || holiday.Title}
              className={styles.holidayImage}
            />
          </div>
        )}
        
        <div className={styles.textContent}>
          <div className={styles.header}>
            <Text variant={isSmallView ? "medium" : "xLarge"} className={styles.title}>
              {holiday.Title}
            </Text>
            {holiday.HolidayType && (
              <div className={`${styles.tag} ${styles[holiday.HolidayType.toLowerCase()]}`}>
                {holiday.HolidayType}
              </div>
            )}
          </div>
          
          <Text variant={isSmallView ? "small" : "medium"} className={styles.date}>
            {formattedDate}
          </Text>
          
          <Text variant="small" className={styles.countdown}>
            {getDaysUntilText(daysUntil)}
          </Text>
          
          {!isSmallView && (
            <Text variant="small" className={styles.clickHint}>
              Click to view all upcoming holidays
            </Text>
          )}
        </div>
      </div>
    </div>
  );
};