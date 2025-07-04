import * as React from 'react';
import { IHolidayDashboardProps } from './IHolidayDashboardProps';
import { IHolidayItem } from '../models/IHolidayItem';
import { HolidayService } from '../services/HolidayService';
import { HolidayCard } from './HolidayCard/HolidayCard';
import { HolidayList } from './HolidayList/HolidayList';
import styles from './HolidayDashboard.module.scss';
import { Spinner, SpinnerSize } from 'office-ui-fabric-react/lib/Spinner';
import { MessageBar, MessageBarType } from 'office-ui-fabric-react/lib/MessageBar';

export interface IHolidayDashboardState {
  nextHoliday: IHolidayItem | null;
  allHolidays: IHolidayItem[];
  isLoading: boolean;
  showFullList: boolean;
  error: string | null;
}

export default class HolidayDashboard extends React.Component<IHolidayDashboardProps, IHolidayDashboardState> {
  private holidayService: HolidayService;

  constructor(props: IHolidayDashboardProps) {
    super(props);

    this.state = {
      nextHoliday: null,
      allHolidays: [],
      isLoading: true,
      showFullList: false,
      error: null
    };

    this.holidayService = new HolidayService(props.context, props.listName);
  }

  public async componentDidMount(): Promise<void> {
    await this.loadHolidays();
  }

  public async componentDidUpdate(prevProps: IHolidayDashboardProps): Promise<void> {
    if (prevProps.listName !== this.props.listName) {
      this.holidayService = new HolidayService(this.props.context, this.props.listName);
      await this.loadHolidays();
    }
  }

  private async loadHolidays(): Promise<void> {
    this.setState({ isLoading: true, error: null });

    try {
      const [nextHoliday, allHolidays] = await Promise.all([
        this.holidayService.getNextUpcomingHoliday(),
        this.holidayService.getUpcomingHolidays()
      ]);

      this.setState({
        nextHoliday,
        allHolidays,
        isLoading: false
      });
    } catch (error) {
      this.setState({
        error: 'Failed to load holiday data. Please check if the list exists and you have permission to access it.',
        isLoading: false
      });
    }
  }

  private onCardClick = (): void => {
    this.setState({ showFullList: true });
  }

  private onBackToCard = (): void => {
    this.setState({ showFullList: false });
  }

  public render(): React.ReactElement<IHolidayDashboardProps> {
    const { isLoading, nextHoliday, allHolidays, showFullList, error } = this.state;
    const { displayMode } = this.props;

    return (
      <div className={styles.holidayDashboard}>
        {isLoading && (
          <div className={styles.loadingContainer}>
            <Spinner size={SpinnerSize.large} label="Loading holidays..." />
          </div>
        )}

        {error && (
          <MessageBar messageBarType={MessageBarType.error}>
            {error}
          </MessageBar>
        )}

        {!isLoading && !error && (
          <>
            {showFullList ? (
              <HolidayList
                holidays={allHolidays}
                onBack={this.onBackToCard}
                holidayService={this.holidayService}
              />
            ) : (
              <HolidayCard
                holiday={nextHoliday}
                displayMode={displayMode}
                onClick={this.onCardClick}
                holidayService={this.holidayService}
              />
            )}
          </>
        )}
      </div>
    );
  }
}