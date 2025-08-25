import { AntiHabit, FailureLog } from '../model/AntiHabit';
import { calculateDaysBetween } from '../util/DateUtil';
import { AddHabitDialog } from '../view/AddHabitDialog';
import { habitStorage } from '../util/HabitStorage';
import common from '@ohos.app.ability.common';
import { achievementService } from '../util/AchievementService';
import router from '@ohos.router';
import { FailureLogDialog } from '../view/FailureLogDialog';
import { RecordsPage } from './RecordsPage'; // 1. 导入新页面
import { ProfilePage } from './ProfilePage'; // 1. 导入新页面

interface AchievementDialogParams {
  names: string[];
}

@Entry
@Component
struct Index {
  @State habits: AntiHabit[] = [];
  @State habitToDeleteIndex: number = -1;
  @State newAchievementNames: string[] = [];
  @State totalDays: number = 0;
  @State todayProgress: number = 0;
  @State habitToResetIndex: number = -1;
  @State currentTabIndex: number = 0; // 用于控制当前选中的Tab

  private context: common.UIAbilityContext | null = null;

  private failureLogDialogController: CustomDialogController = new CustomDialogController({
    builder: this.FailureLogDialogBuilder,
    autoCancel: true
  });

  @Builder
  private FailureLogDialogBuilder() {
    FailureLogDialog({
      controller: this.failureLogDialogController,
      onConfirm: (reason: string) => {
        if (this.habitToResetIndex !== -1) {
          this.logFailure(this.habitToResetIndex, reason);
        }
      }
    })
  }

  private deleteDialogController: CustomDialogController = new CustomDialogController({
    builder: this.DeleteConfirmDialog,
    autoCancel: true
  });

  private achievementDialogController: CustomDialogController = new CustomDialogController({
    builder: () => {
      this.AchievementUnlockedDialog({ names: this.newAchievementNames })
    },
    autoCancel: true,
    alignment: DialogAlignment.Center
  });

  @Builder
  private buildAddHabitDialog() {
    AddHabitDialog({
      controller: this.dialogController,
      onConfirm: (name: string) => {
        this.addNewHabit(name);
      }
    })
  }

  private dialogController: CustomDialogController = new CustomDialogController({
    builder: this.buildAddHabitDialog,
    autoCancel: true,
    alignment: DialogAlignment.Center
  });

  private calculateStats() {
    this.totalDays = this.habits.reduce((sum, habit) => {
      return sum + calculateDaysBetween(habit.lastBreakDate, new Date());
    }, 0);

    this.todayProgress = this.habits.length > 0 ?
    Math.round((this.habits.filter(h => calculateDaysBetween(h.lastBreakDate, new Date()) > 0).length / this.habits.length) * 100) : 0;
  }

  onPageShow() {
    this.context = getContext(this) as common.UIAbilityContext;
    habitStorage.loadHabits(this.context).then(loadedHabits => {
      let anyChange = false;
      let allNewNames: string[] = [];

      loadedHabits.forEach(habit => {
        const newlyUnlocked = achievementService.checkAndUnlock(habit);
        if (newlyUnlocked.length > 0) {
          anyChange = true;
          allNewNames.push(...newlyUnlocked);
        }
      });

      this.habits = loadedHabits;
      this.calculateStats();

      if (anyChange) {
        this.newAchievementNames = allNewNames;
        this.achievementDialogController.open();
        if (this.context) {
          habitStorage.saveHabits(this.context, this.habits);
        }
      }
    })
  }

  resetHabit(index: number) {
    this.habitToResetIndex = index;
    this.failureLogDialogController.open();
  }

  async logFailure(index: number, reason: string) {
    if (!this.context || index < 0 || index >= this.habits.length) {
      return;
    }

    const habitToUpdate = this.habits[index];
    const newLog: FailureLog = { date: new Date(), reason: reason };
    habitToUpdate.failureLogs.push(newLog);
    habitToUpdate.lastBreakDate = new Date();
    habitToUpdate.unlockedAchievements = [];
    this.habits[index] = AntiHabit.fromJSON(habitToUpdate.toJSON());
    await habitStorage.saveHabits(this.context, this.habits);
    this.calculateStats();
  }

  async addNewHabit(name: string) {
    if (!this.context) return;
    const newId = new Date().getTime();
    const newHabit = new AntiHabit(newId, name, new Date());
    this.habits.unshift(newHabit);
    await habitStorage.saveHabits(this.context, this.habits);
    this.calculateStats();
  }

  async deleteHabit(index: number) {
    if (!this.context || index < 0 || index >= this.habits.length) {
      return;
    }
    this.habits = this.habits.filter((_, i) => i !== index);
    await habitStorage.saveHabits(this.context, this.habits);
    this.calculateStats();
  }

  private getDaysColor(days: number): string {
    if (days >= 30) return '#00C853';
    if (days >= 14) return '#4CAF50';
    if (days >= 7) return '#8BC34A';
    if (days >= 3) return '#FFC107';
    return '#FF5722';
  }

  private getBadgeText(days: number): string {
    if (days >= 30) return '💎';
    if (days >= 14) return '🏆';
    if (days >= 7) return '🥇';
    if (days >= 3) return '🥈';
    return '🥉';
  }

  @Builder AchievementUnlockedDialog(params: AchievementDialogParams) {  Column({ space: 20 }) {
    // 添加动画效果
    Text('🎉')
      .fontSize(48)
      .animation({
        duration: 1000,
        curve: Curve.EaseInOut,
        iterations: -1,
        playMode: PlayMode.Alternate
      })

    Text('恭喜解锁新成就！')
      .fontSize(24)
      .fontWeight(FontWeight.Bold)
      .fontColor('#FF6B35')

    Text(`${params.names.join('、')}`)
      .fontSize(18)
      .textAlign(TextAlign.Center)
      .lineHeight(24)
      .fontColor('#333')
      .padding(10)
      .backgroundColor('#FFF3E0')
      .borderRadius(8)

    Button('太棒了！')
      .width('80%')
      .type(ButtonType.Capsule)
      .backgroundColor('#FF6B35')
      .onClick(() => {
        this.achievementDialogController.close()
      })
  }
  .width('85%')
  .padding(30)
  .backgroundColor(Color.White)
  .borderRadius(20)
  .shadow({ radius: 20, color: '#1F000000', offsetY: 8 })
  }
  @Builder DeleteConfirmDialog() { Column({ space: 20 }) {
    Text('⚠️')
      .fontSize(48)
      .fontColor('#FF4444')

    Text('确认删除')
      .fontSize(22)
      .fontWeight(FontWeight.Bold)

    Text('你确定要删除这个习惯吗？\n此操作不可撤销。')
      .fontSize(16)
      .textAlign(TextAlign.Center)
      .fontColor('#666')
      .lineHeight(22)

    Row({ space: 20 }) {
      Button('取消')
        .layoutWeight(1)
        .backgroundColor('#F5F5F5')
        .fontColor('#333')
        .onClick(() => {
          this.deleteDialogController.close();
        })

      Button('确认删除')
        .layoutWeight(1)
        .type(ButtonType.Capsule)
        .backgroundColor('#FF4444')
        .onClick(() => {
          if (this.habitToDeleteIndex !== -1) {
            this.deleteHabit(this.habitToDeleteIndex);
          }
          this.deleteDialogController.close();
        })
    }
    .width('100%')
  }
  .padding(30)
  }
  @Builder StatsCard() { Row({ space: 20 }) {
    // 总天数统计
    Column({ space: 5 }) {
      Text(`${this.totalDays}`)
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FF6B35')

      Text('总坚持天数')
        .fontSize(12)
        .fontColor('#666')
    }
    .layoutWeight(1)

    // 分隔线
    Divider()
      .vertical(true)
      .height(40)
      .color('#E0E0E0')

    // 习惯数量
    Column({ space: 5 }) {
      Text(`${this.habits.length}`)
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#4CAF50')

      Text('追踪习惯')
        .fontSize(12)
        .fontColor('#666')
    }
    .layoutWeight(1)

    // 分隔线
    Divider()
      .vertical(true)
      .height(40)
      .color('#E0E0E0')

    // 成功率
    Column({ space: 5 }) {
      Text(`${this.todayProgress}%`)
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2196F3')

      Text('当前成功率')
        .fontSize(12)
        .fontColor('#666')
    }
    .layoutWeight(1)
  }
  .width('90%')
  .height(80)
  .padding(20)
  .backgroundColor(Color.White)
  .borderRadius(15)
  .shadow({ radius: 8, color: '#1F000000', offsetY: 4 })
  .margin({ top: 20, bottom: 20 })
  }

  // 2. 为导航栏的每个按钮创建一个Builder
  @Builder
  TabButton(title: string, index: number) {
    Column() {
      // 这里可以放图标
      Text(title)
        .fontColor(this.currentTabIndex === index ? '#FF6B35' : '#999')
        .fontSize(12)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  // 3. 将原有的首页UI内容封装到一个Builder中
  @Builder
  HomePageContent() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Button({ type: ButtonType.Circle }) {
        Text('+').fontSize(24).fontColor(Color.White).fontWeight(FontWeight.Bold)
      }
      .width(60).height(60).backgroundColor('#FF6B35')
      .shadow({ radius: 15, color: '#40FF6B35', offsetY: 6 })
      .onClick(() => { this.dialogController.open(); })
      .zIndex(999).margin({ right: 20, bottom: 20 })

      Column() {
        Column({ space: 10 }) {
          Text('今天你"没做"什么？').fontSize(28).fontWeight(FontWeight.Bold).fontColor('#333').textAlign(TextAlign.Center)
          Text('坚持就是胜利 💪').fontSize(16).fontColor('#666').textAlign(TextAlign.Center)
        }.width('100%').padding({ top: 40, bottom: 10 })

        this.StatsCard()

        if (this.habits.length > 0) {
          List({ space: 15, initialIndex: 0 }) {
            ForEach(this.habits, (habit: AntiHabit, index: number) => {
              ListItem() {
                Stack({ alignContent: Alignment.TopEnd }) {
                  Column() {
                    Row({ space: 15 }) {
                      Text(this.getBadgeText(calculateDaysBetween(habit.lastBreakDate, new Date())))
                        .fontSize(24).width(50).height(50).textAlign(TextAlign.Center).backgroundColor('#F8F9FA').borderRadius(25)
                        .border({ width: 2, color: this.getDaysColor(calculateDaysBetween(habit.lastBreakDate, new Date())) })
                      Column({ space: 5 }) {
                        Text(habit.name).fontSize(18).fontWeight(FontWeight.Medium).fontColor('#333').maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
                        Text(`已坚持 ${calculateDaysBetween(habit.lastBreakDate, new Date())} 天`).fontSize(14).fontColor('#666')
                      }.alignItems(HorizontalAlign.Start).layoutWeight(1)
                      Text(`${calculateDaysBetween(habit.lastBreakDate, new Date())}`)
                        .fontSize(24).fontWeight(FontWeight.Bold).fontColor(this.getDaysColor(calculateDaysBetween(habit.lastBreakDate, new Date())))
                    }
                    .width('100%').padding({ top: 20, left: 20, right: 20, bottom: 15 })
                    .onClick(() => {
                      if (!this.context) return;
                      const habitData = this.habits[index].toJSON();
                      router.pushUrl({
                        url: 'pages/HabitDetailPage',
                        params: { habit: habitData }
                      }, (err) => { if (err) console.error('跳转失败:', err); })
                    })
                    Button('我失败了 😔', { type: ButtonType.Capsule })
                      .width('70%').height(40).backgroundColor('#FF5252').fontColor(Color.White).fontSize(14).margin({ bottom: 20 })
                      .onClick(() => { this.resetHabit(index); })
                  }
                  .width('100%').backgroundColor(Color.White).borderRadius(15)
                  .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 4 })
                  .alignItems(HorizontalAlign.Center)
                  Button({ type: ButtonType.Circle }) { Text('×').fontSize(18).fontColor('#999') }
                    .width(20).height(20).backgroundColor('#F5F5F5')
                    .onClick(() => { this.habitToDeleteIndex = index; this.deleteDialogController.open(); })
                    .margin({ top: 10, right: 10 })
                }
              }
            })
          }.width('90%').layoutWeight(1).edgeEffect(EdgeEffect.Spring)
        } else {
          Column({ space: 20 }) {
            Text('📝').fontSize(64).opacity(0.5)
            Text('还没有追踪任何习惯').fontSize(18).fontColor('#999')
            Text('点击右下角的 + 按钮添加第一个习惯吧！').fontSize(14).fontColor('#BBB').textAlign(TextAlign.Center)
          }.layoutWeight(1).justifyContent(FlexAlign.Center)
        }
      }.width('100%').height('100%').alignItems(HorizontalAlign.Center)
    }.width('100%').height('100%').backgroundColor('#F8F9FA')
  }

  build() {
    // 4. 使用Tabs作为根组件
    Tabs({ barPosition: BarPosition.End }) {
      TabContent() {
        this.HomePageContent() // 调用Builder显示首页内容
      }.tabBar(this.TabButton('首页', 0))

      TabContent() {
        RecordsPage()
      }.tabBar(this.TabButton('记录', 1))

      TabContent() {
        ProfilePage()
      }.tabBar(this.TabButton('我的', 2))
    }
    .onChange((index: number) => {
      this.currentTabIndex = index;
    })
    .width('100%')
    .height('100%')
  }
}