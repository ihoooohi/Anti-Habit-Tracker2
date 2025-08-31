// entry/src/main/ets/pages/RecordsPage.ets
import common from '@ohos.app.ability.common';
import { AntiHabit, FailureLog } from '../model/AntiHabit';
import { habitStorage } from '../util/HabitStorage';
import { calculateDaysBetween } from '../util/DateUtil';
import { eventBus } from '../util/eventBus';

interface CalendarDay {
  date: Date;
  isCurrentMonth: boolean;
  isToday: boolean;
  isSuccessDay: boolean; // 成功戒掉习惯的日期
  isFailureDay: boolean; // 失败的日期
  failureCount: number; // 失败次数
  successCount: number; // 成功的习惯数量
}

@Entry
@Component
export struct RecordsPage {
  @State habits: AntiHabit[] = [];
  @State currentDate: Date = new Date();
  @State calendarDays: CalendarDay[] = [];
  @State selectedHabit: AntiHabit | null = null;
  @State showHabitSelector: boolean = false;

  private context: common.UIAbilityContext | null = null;
  // 在顶部定义一个变量存储回调引用
  private habitsUpdatedCallback: () => void = () => {};

  aboutToAppear() {
    this.context = getContext(this) as common.UIAbilityContext;
    this.loadHabits();
    // 监听习惯更新事件，并保存回调引用
    this.habitsUpdatedCallback = () => {
      this.loadHabits();
    };
    eventBus.on('habitsUpdated', this.habitsUpdatedCallback);
  }

  // 页面即将消失时取消订阅
  aboutToDisappear() {
    eventBus.off('habitsUpdated', this.habitsUpdatedCallback);
  }

  loadHabits() {
    if (!this.context) return;
    
    habitStorage.loadHabits(this.context).then(habits => {
      this.habits = habits;
      if (habits.length > 0 && !this.selectedHabit) {
        this.selectedHabit = habits[0];
      }
      this.generateCalendar();
    });
  }

  generateCalendar() {
    const year = this.currentDate.getFullYear();
    const month = this.currentDate.getMonth();
    
    // 获取当月第一天
    const firstDay = new Date(year, month, 1);
    // 获取当月最后一天
    const lastDay = new Date(year, month + 1, 0);
    
    // 获取日历开始日期（包含上月末尾几天）
    const startDate = new Date(firstDay);
    startDate.setDate(startDate.getDate() - firstDay.getDay());
    
    // 获取日历结束日期（包含下月开头几天）
    const endDate = new Date(lastDay);
    endDate.setDate(endDate.getDate() + (6 - lastDay.getDay()));
    
    const days: CalendarDay[] = [];
    const currentDate = new Date(startDate);
    const today = new Date();
    
    while (currentDate <= endDate) {
      const dayData: CalendarDay = {
        date: new Date(currentDate),
        isCurrentMonth: currentDate.getMonth() === month,
        isToday: this.isSameDate(currentDate, today),
        isSuccessDay: false,
        isFailureDay: false,
        failureCount: 0,
        successCount: 0
      };
      
      // 计算这一天的成功和失败情况
      this.calculateDayStatus(dayData);
      
      days.push(dayData);
      currentDate.setDate(currentDate.getDate() + 1);
    }
    
    this.calendarDays = days;
  }

  calculateDayStatus(dayData: CalendarDay) {
    const targetDate = dayData.date;
    
    this.habits.forEach(habit => {
      // 检查是否是成功的日期（在最后破戒日期之后）
      if (targetDate > habit.lastBreakDate) {
        const daysSinceBreak = calculateDaysBetween(habit.lastBreakDate, targetDate);
        if (daysSinceBreak > 0) {
          dayData.isSuccessDay = true;
          dayData.successCount++;
        }
      }
      
      // 检查失败记录
      habit.failureLogs.forEach(log => {
        if (this.isSameDate(log.date, targetDate)) {
          dayData.isFailureDay = true;
          dayData.failureCount++;
        }
      });
    });
  }

  isSameDate(date1: Date, date2: Date): boolean {
    return date1.getFullYear() === date2.getFullYear() &&
           date1.getMonth() === date2.getMonth() &&
           date1.getDate() === date2.getDate();
  }

  previousMonth() {
    this.currentDate = new Date(this.currentDate.getFullYear(), this.currentDate.getMonth() - 1, 1);
    this.generateCalendar();
  }

  nextMonth() {
    this.currentDate = new Date(this.currentDate.getFullYear(), this.currentDate.getMonth() + 1, 1);
    this.generateCalendar();
  }

  @Builder
  CalendarHeader() {
    Row() {
      Button('<')
        .type(ButtonType.Circle)
        .width(40)
        .height(40)
        .backgroundColor('#FF6B35')
        .fontColor(Color.White)
        .onClick(() => this.previousMonth())

      Text(`${this.currentDate.getFullYear()}年${this.currentDate.getMonth() + 1}月`)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      Button('>')
        .type(ButtonType.Circle)
        .width(40)
        .height(40)
        .backgroundColor('#FF6B35')
        .fontColor(Color.White)
        .onClick(() => this.nextMonth())
    }
    .width('90%')
    .margin({ top: 20, bottom: 10 })
  }

  @Builder
  WeekHeader() {
    Row() {
      ForEach(['日', '一', '二', '三', '四', '五', '六'], (day: string) => {
        Text(day)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#666')
          .textAlign(TextAlign.Center)
          .layoutWeight(1)
      })
    }
    .width('90%')
    .height(40)
    .backgroundColor('#F5F5F5')
    .borderRadius(8)
    .margin({ bottom: 10 })
  }

  @Builder
  CalendarGrid() {
    Column() {
      ForEach(this.getWeeks(), (week: CalendarDay[]) => {
        Row() {
          ForEach(week, (day: CalendarDay) => {
            this.DayCell(day)
          })
        }
        .width('100%')
        .height(50)
      })
    }
    .width('90%')
  }

  @Builder
  DayCell(day: CalendarDay) {
    Stack() {
      // 背景色
      if (day.isToday) {
        Circle()
          .width(40)
          .height(40)
          .fill('#FF6B35')
          .opacity(0.2)
      }
      
      // 成功和失败的指示器
      if (day.isSuccessDay || day.isFailureDay) {
        Row() {
          if (day.isSuccessDay) {
            Circle()
              .width(6)
              .height(6)
              .fill('#4CAF50')
          }
          if (day.isFailureDay) {
            Circle()
              .width(6)
              .height(6)
              .fill('#F44336')
              .margin({ left: day.isSuccessDay ? 2 : 0 })
          }
        }
        .position({ x: '50%', y: '75%' })
        .markAnchor({ x: '50%', y: '50%' })
      }
      
      // 日期数字
      Text(day.date.getDate().toString())
        .fontSize(16)
        .fontColor(day.isCurrentMonth ? 
          (day.isToday ? '#FF6B35' : '#333') : 
          '#CCC')
        .fontWeight(day.isToday ? FontWeight.Bold : FontWeight.Normal)
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Center)
    .layoutWeight(1)
    .onClick(() => {
      // 可以添加点击事件显示详细信息
      this.showDayDetails(day);
    })
  }

  showDayDetails(day: CalendarDay) {
    // 这里可以添加显示详细信息的逻辑
    console.info(`点击日期: ${day.date.toDateString()}`);
    console.info(`成功次数: ${day.successCount}, 失败次数: ${day.failureCount}`);
  }

  getWeeks(): CalendarDay[][] {
    const weeks: CalendarDay[][] = [];
    for (let i = 0; i < this.calendarDays.length; i += 7) {
      weeks.push(this.calendarDays.slice(i, i + 7));
    }
    return weeks;
  }

  @Builder
  LegendCard() {
    Column({ space: 15 }) {
      Text('图例说明')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .alignSelf(ItemAlign.Start)

      Row({ space: 20 }) {
        Row({ space: 8 }) {
          Circle()
            .width(12)
            .height(12)
            .fill('#4CAF50')
          Text('成功坚持')
            .fontSize(14)
            .fontColor('#666')
        }

        Row({ space: 8 }) {
          Circle()
            .width(12)
            .height(12)
            .fill('#F44336')
          Text('失败记录')
            .fontSize(14)
            .fontColor('#666')
        }

        Row({ space: 8 }) {
          Circle()
            .width(12)
            .height(12)
            .fill('#FF6B35')
            .opacity(0.3)
          Text('今天')
            .fontSize(14)
            .fontColor('#666')
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
    }
    .width('90%')
    .padding(15)
    .backgroundColor(Color.White)
    .borderRadius(10)
    .shadow({ radius: 4, color: '#1A000000', offsetY: 2 })
    .margin({ top: 20 })
  }

  @Builder
  HabitSelectorCard() {
    Column({ space: 10 }) {
      Text('选择习惯')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .alignSelf(ItemAlign.Start)

      if (this.habits.length > 0) {
        List({ space: 8 }) {
          ForEach(this.habits, (habit: AntiHabit, index: number) => {
            ListItem() {
              Row({ space: 12 }) {
                Circle()
                  .width(8)
                  .height(8)
                  .fill(this.selectedHabit?.id === habit.id ? '#FF6B35' : '#DDD')

                Text(habit.name)
                  .fontSize(14)
                  .fontColor(this.selectedHabit?.id === habit.id ? '#FF6B35' : '#333')
                  .layoutWeight(1)

                Text(`${calculateDaysBetween(habit.lastBreakDate, new Date())}天`)
                  .fontSize(12)
                  .fontColor('#666')
              }
              .width('100%')
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .backgroundColor(this.selectedHabit?.id === habit.id ? '#FFF3F0' : Color.Transparent)
              .borderRadius(6)
            }
            .onClick(() => {
              this.selectedHabit = habit;
              this.generateCalendar();
            })
          })
        }
        .width('100%')
        .height(150)
        .scrollBar(BarState.Off)   // 关闭滚动条
      } else {
        Text('暂无习惯记录')
          .fontSize(14)
          .fontColor('#999')
          .textAlign(TextAlign.Center)
          .width('100%')
          .padding(20)
      }
    }
    .width('90%')
    .padding(15)
    .backgroundColor(Color.White)
    .borderRadius(10)
    .shadow({ radius: 4, color: '#1A000000', offsetY: 2 })
    .margin({ top: 20 })
  }

  build() {
    Column() {
      Text('习惯记录')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .width('90%')
        .textAlign(TextAlign.Start)
        .margin({ top: 20, bottom: 10 })

      Scroll() {
        Column() {
          // 习惯选择器
          this.HabitSelectorCard()

          // 日历头部
          this.CalendarHeader()

          // 星期标题
          this.WeekHeader()

          // 日历网格
          this.CalendarGrid()

          // 图例说明
          this.LegendCard()

          Blank()
            .height(20)
        }
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)   // 关闭滚动条
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F3F5')
    .alignItems(HorizontalAlign.Center)
  }
}
