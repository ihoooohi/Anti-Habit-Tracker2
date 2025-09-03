import router from '@ohos.router';
import { Achievement } from '../model/Achievement';
import { AntiHabit, FailureLog } from '../model/AntiHabit'; // 引入FailureLog
import { ALL_ACHIEVEMENTS } from '../util/AchievementList';
import { calculateDaysBetween } from '../util/DateUtil';
import { eventBus } from '../util/eventBus';
import { habitStorage } from '../util/HabitStorage';
import common from '@ohos.app.ability.common';

interface RouteParams {
  habit: AntiHabit;
}

@Entry
@Component
struct HabitDetailPage { // 1. 重命名 Struct
  @State habit: AntiHabit | null = null;
  @State unlockedCount: number = 0;
  @State totalCount: number = 0;
  @State currentDays: number = 0;
  @State currentTabIndex: number = 0; // 用于控制Tabs
  
  private context: common.UIAbilityContext | null = null;
  private habitId: number = -1; // 存储习惯ID用于重新加载
  private boundOnHabitsUpdated: () => Promise<void> = async () => {}; // 初始化为空函数

  // 格式化日期
  private formatDate(date: Date): string {
    const year = date.getFullYear();
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    const hours = date.getHours().toString().padStart(2, '0');
    const minutes = date.getMinutes().toString().padStart(2, '0');
    return `${year}-${month}-${day} ${hours}:${minutes}`;
  }

  aboutToAppear() {
    const params = router.getParams() as RouteParams;
    if (params && params.habit) {
      this.habit = AntiHabit.fromJSON(params.habit);
      this.habitId = this.habit.id; // 保存习惯ID
      this.calculateStats();
      
      // 获取context
      this.context = getContext(this) as common.UIAbilityContext;
      
      // 绑定方法引用
      this.boundOnHabitsUpdated = this.onHabitsUpdated.bind(this);
      
      // 监听数据更新事件
      eventBus.on('habitsUpdated', this.boundOnHabitsUpdated);
    } else {
      console.error('HabitDetailPage: Failed to get habit from router params.');
      router.back();
    }
  }
  
  aboutToDisappear() {
    // 取消监听事件
    eventBus.off('habitsUpdated', this.boundOnHabitsUpdated);
  }
  
  // 当收到习惯更新事件时重新加载数据
  private async onHabitsUpdated() {
    if (this.context && this.habitId !== -1) {
      try {
        const habits = await habitStorage.loadHabits(this.context);
        const updatedHabit = habits.find(h => h.id === this.habitId);
        if (updatedHabit) {
          this.habit = updatedHabit;
          this.calculateStats();
        }
      } catch (error) {
        console.error('Failed to reload habit data:', error);
      }
    }
  }

  private calculateStats() {
    if (this.habit) {
      this.unlockedCount = this.habit.unlockedAchievements.length;
      this.totalCount = ALL_ACHIEVEMENTS.length;
      this.currentDays = calculateDaysBetween(this.habit.lastBreakDate, new Date());
    }
  }

  @Builder
  StatsHeader() {
    Column({ space: 15 }) {
      Column({ space: 10 }) {
        Text(`"${this.habit?.name}"`)
          .fontSize(24).fontWeight(FontWeight.Bold).fontColor('#333').textAlign(TextAlign.Center)
        Row({ space: 10 }) {
          Text('已坚持').fontSize(16).fontColor('#666')
          Text(`${this.currentDays}`).fontSize(32).fontWeight(FontWeight.Bold).fontColor('#FF6B35')
          Text('天').fontSize(16).fontColor('#666')
        }.justifyContent(FlexAlign.Center)
      }
      Column({ space: 8 }) {
        Row() {
          Text('成就进度').fontSize(14).fontColor('#666')
          Blank()
          Text(`${this.unlockedCount}/${this.totalCount}`).fontSize(14).fontColor('#666')
        }.width('100%')
        Progress({ value: this.unlockedCount, total: this.totalCount, type: ProgressType.Linear })
          .width('100%').height(8).color('#4CAF50').backgroundColor('#E8F5E8').borderRadius(4)
      }.width('100%')
    }
    .width('90%').padding(25).backgroundColor(Color.White).borderRadius(15)
    .shadow({ radius: 8, color: '#1F000000', offsetY: 4 }).margin({ top: 20, bottom: 20 })
  }

  @Builder
  AchievementList() {
    Grid() {
      ForEach(ALL_ACHIEVEMENTS, (achievement: Achievement) => {
        GridItem() {
          Column({ space: 12 }) {
            Stack() {
              Circle().width(80).height(80).fill(this.habit?.unlockedAchievements.includes(achievement.id) ? '#ff0ce715' : '#E0E0E0').opacity(0.1)
              Image($r(achievement.icon))
                .width(50).height(50)
                .grayscale(this.habit!.unlockedAchievements.includes(achievement.id) ? 0 : 1)
                .opacity(this.habit!.unlockedAchievements.includes(achievement.id) ? 1 : 0.4)
            }.borderRadius(40)
            Column({ space: 4 }) {
              Text(achievement.name)
                .fontSize(14).fontWeight(FontWeight.Medium).fontColor(this.habit!.unlockedAchievements.includes(achievement.id) ? '#333' : '#999')
                .textAlign(TextAlign.Center).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
              Text(achievement.description)
                .fontSize(12).fontColor(this.habit!.unlockedAchievements.includes(achievement.id) ? '#666' : '#BBB')
                .textAlign(TextAlign.Center).maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis }).lineHeight(16)
            }.width('100%')
          }
          .padding(15).backgroundColor(Color.White).borderRadius(12)
          .shadow({ radius: this.habit!.unlockedAchievements.includes(achievement.id) ? 8 : 4, color: '#1A000000', offsetY: this.habit!.unlockedAchievements.includes(achievement.id) ? 4 : 2 })
          .alignItems(HorizontalAlign.Center)
        }
      })
    }.columnsTemplate('1fr 1fr').rowsGap(15).columnsGap(15).width('90%').margin({ bottom: 30 }).scrollBar(BarState.Off)
  }

  @Builder
  FailureLogList() {
    if (this.habit && this.habit.failureLogs.length > 0) {
      List({ space: 12 }) {
        ForEach(this.habit.failureLogs.sort((a, b) => b.date.getTime() - a.date.getTime()), (log: FailureLog) => {
          ListItem() {
            Row({ space: 15 }) {
              Column({ space: 5 }) {
                Text(this.formatDate(log.date)).fontSize(14).fontColor('#666')
                Text(log.reason).fontSize(16).fontWeight(FontWeight.Medium).fontColor('#333').margin({ top: 4 })
              }.alignItems(HorizontalAlign.Start).layoutWeight(1)
            }
            .padding(20).backgroundColor(Color.White).borderRadius(10).shadow({ radius: 4, color: '#1A000000', offsetY: 2 })
          }
        })
      }.width('90%').padding({ top: 20, bottom: 20 }).scrollBar(BarState.Off)
    } else {
      Column() {
        Text('🎉').fontSize(64).opacity(0.5).margin({ bottom: 20 })
        Text('没有失败记录').fontSize(18).fontColor('#999')
        Text('你做得很好，继续保持！').fontSize(14).fontColor('#BBB').margin({ top: 10 })
      }.width('100%').height('100%').justifyContent(FlexAlign.Center)
    }
  }

  build() {
    if (this.habit) {
      Column() {
        Row() {
          Button({ type: ButtonType.Circle }) { Text('←').fontSize(20).fontColor('#333') }
            .width(40).height(40).backgroundColor('#F5F5F5')
            .onClick(() => { router.back(); })
          Text('习惯详情').fontSize(20).fontWeight(FontWeight.Bold).layoutWeight(1).textAlign(TextAlign.Center).fontColor('#333')
          Blank().width(40)
        }.width('100%').height(60).padding({ left: 15, right: 15 }).backgroundColor(Color.White).shadow({ radius: 4, color: '#1F000000', offsetY: 2 })

        Column(){
          this.StatsHeader()
          Tabs({ barPosition: BarPosition.Start }) {
            TabContent() { this.AchievementList() }.tabBar('成就殿堂')
            TabContent() { this.FailureLogList() }.tabBar('失败记录')
          }
          .vertical(false).barMode(BarMode.Fixed).barWidth(300).barHeight(50).animationDuration(300)
          .onChange((index: number) => { this.currentTabIndex = index; })
          .layoutWeight(1)
        }.width('100%').alignItems(HorizontalAlign.Center)
      }.width('100%').height('100%').backgroundColor('#F8F9FA')
    }
  }
}
