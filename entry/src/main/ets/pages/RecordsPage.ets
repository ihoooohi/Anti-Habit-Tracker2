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
      // 如果当前选择的习惯不在新的习惯列表中，重置选择
      if (this.selectedHabit && !habits.find(h => h.id === this.selectedHabit!.id)) {
        this.selectedHabit = null;
      }
      // 如果没有选择习惯且有习惯数据，默认选择第一个
      if (!this.selectedHabit && habits.length > 0) {
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
    
    // 如果选择了特定习惯，只计算该习惯的数据
    const habitsToCheck = this.selectedHabit ? [this.selectedHabit] : this.habits;
    
    habitsToCheck.forEach(habit => {
      // 检查是否是成功的日期（在最后破戒日期之后且不是今天之后的日期）
      const today = new Date();
      today.setHours(0, 0, 0, 0); // 重置时间部分
      const checkDate = new Date(targetDate);
      checkDate.setHours(0, 0, 0, 0);
      const breakDate = new Date(habit.lastBreakDate);
      breakDate.setHours(0, 0, 0, 0);
      
      if (checkDate > breakDate && checkDate <= today) {
        dayData.isSuccessDay = true;
        dayData.successCount++;
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
    const d1 = new Date(date1);
    const d2 = new Date(date2);
    d1.setHours(0, 0, 0, 0);
    d2.setHours(0, 0, 0, 0);
    return d1.getTime() === d2.getTime();
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
    .backgroundColor((day.isSuccessDay || day.isFailureDay) ? '#F8F9FA' : Color.Transparent)
    .borderRadius(4)
    .onClick(() => {
      // 只有有数据的日期才显示详情
      if (day.isSuccessDay || day.isFailureDay) {
        this.showDayDetails(day);
      }
    })
  }

  showDayDetails(day: CalendarDay) {
    if (!day.isSuccessDay && !day.isFailureDay) return;
    
    let message = `${day.date.getFullYear()}年${day.date.getMonth() + 1}月${day.date.getDate()}日\n\n`;
    
    if (day.isSuccessDay) {
      message += `✅ 成功坚持: ${day.successCount}个习惯\n`;
    }
    
    if (day.isFailureDay) {
      message += `❌ 失败记录: ${day.failureCount}次\n\n`;
      
      // 显示具体的失败原因
      const habitsToCheck = this.selectedHabit ? [this.selectedHabit] : this.habits;
      habitsToCheck.forEach(habit => {
        habit.failureLogs.forEach(log => {
          if (this.isSameDate(log.date, day.date)) {
            message += `• ${habit.name}: ${log.reason}\n`;
          }
        });
      });
    }
    
    AlertDialog.show({
      title: '日期详情',
      message: message,
      confirm: {
        value: '确定',
        action: () => {}
      }
    });
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
        // 添加"全部习惯"选项
        Column() {
          Row({ space: 12 }) {
            Circle()
              .width(8)
              .height(8)
              .fill(this.selectedHabit === null ? '#FF6B35' : '#DDD')

            Text('全部习惯')
              .fontSize(14)
              .fontColor(this.selectedHabit === null ? '#FF6B35' : '#333')
              .layoutWeight(1)

            Text(`${this.habits.length}个`)
              .fontSize(12)
              .fontColor('#666')
          }
          .width('100%')
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .backgroundColor(this.selectedHabit === null ? '#FFF3F0' : Color.Transparent)
          .borderRadius(6)
          .onClick(() => {
            this.selectedHabit = null;
            this.generateCalendar();
          })

          Divider()
            .width('90%')
            .color('#E0E0E0')
            .margin({ top: 5, bottom: 5 })
        }
        
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
        .height(120)
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
