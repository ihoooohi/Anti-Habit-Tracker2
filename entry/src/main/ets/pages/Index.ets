import { AntiHabit } from '../model/AntiHabit';
import { calculateDaysBetween } from '../util/DateUtil';
import { AddHabitDialog } from '../view/AddHabitDialog';
import { habitStorage } from '../util/HabitStorage';
import common from '@ohos.app.ability.common';
import { achievementService } from '../util/AchievementService';
import router from '@ohos.router';

interface AchievementDialogParams {
  names: string[];
}

@Entry
@Component
struct Index {
  @State habits: AntiHabit[] = [];
  @State habitToDeleteIndex: number = -1;
  @State newAchievementNames: string[] = [];

  private context: common.UIAbilityContext | null = null;

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

      if (anyChange) {
        this.newAchievementNames = allNewNames;
        this.achievementDialogController.open();
        if (this.context) {
          habitStorage.saveHabits(this.context, this.habits);
        }
      }
    })
  }

  async resetHabit(index: number) {
    if (!this.context) return;
    const oldHabit = this.habits[index];
    const updatedHabit = new AntiHabit(oldHabit.id, oldHabit.name, new Date(), []);
    this.habits[index] = updatedHabit;
    await habitStorage.saveHabits(this.context, this.habits);
  }

  async addNewHabit(name: string) {
    if (!this.context) return;
    const newId = new Date().getTime();
    const newHabit = new AntiHabit(newId, name, new Date());
    this.habits.unshift(newHabit);
    await habitStorage.saveHabits(this.context, this.habits);
  }

  async deleteHabit(index: number) {
    if (!this.context || index < 0 || index >= this.habits.length) {
      return;
    }
    this.habits.splice(index, 1);
    await habitStorage.saveHabits(this.context, this.habits);
  }

  @Builder AchievementUnlockedDialog(params: AchievementDialogParams) {
    Column({ space: 20 }) {
      Text('恭喜！')
        .fontSize(24).fontWeight(FontWeight.Bold)
      Text(`你解锁了新的成就：\n${params.names.join('、')}`)
        .fontSize(18)
        .textAlign(TextAlign.Center)
        .lineHeight(24)
      Button('太棒了！')
        .width('80%')
        .type(ButtonType.Capsule)
        .onClick(() => {
          this.achievementDialogController.close()
        })
    }.width('80%').padding(25).backgroundColor(Color.White).borderRadius(20)
  }

  @Builder DeleteConfirmDialog() {
    Column({ space: 20 }) {
      Text('确认删除')
        .fontSize(22).fontWeight(FontWeight.Bold)
      Text('你确定要删除这个习惯吗？\n此操作不可撤销。')
        .fontSize(16).textAlign(TextAlign.Center).fontColor(Color.Gray)
      Row({ space: 15 }) {
        Button('取消')
          .layoutWeight(1)
          .onClick(() => {
            this.deleteDialogController.close();
          })
        Button('确认删除')
          .layoutWeight(1)
          .type(ButtonType.Capsule)
          .backgroundColor('#ff4d4f')
          .onClick(() => {
            if (this.habitToDeleteIndex !== -1) {
              this.deleteHabit(this.habitToDeleteIndex);
            }
            this.deleteDialogController.close();
          })
      }
      .width('100%')
    }
    .width('80%')
    .padding(25)
    .backgroundColor(Color.White)
    .borderRadius(20)
  }

  build() {
    Stack({alignContent: Alignment.BottomEnd}) {
      // 悬浮添加按钮固定到页面右下角
      Button({ type: ButtonType.ROUNDED_RECTANGLE }) {
        Image($r('app.media.built'))
          .width(30)
          .height(30)
          .fillColor(Color.White)

      }
      .width(56)
      .height(56)
      .backgroundColor('#ffffffff')
      .shadow({ radius: 10, color: '#1F000000' })
      .onClick(() => {
        this.dialogController.open();
      })
      .zIndex(999) // 确保按钮层级高于滚动内容
      .align(Alignment.Center) // 关键：固定到右下角
      .margin({ right: '5%', bottom: '5%' }) // 离边框 20px

      Column() {
        Text('今天你“没做”什么？')
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .textAlign(TextAlign.Center)
          .padding({ top: 40, bottom: 20 })

        List({ space: 12, initialIndex: 0 }) {
          ForEach(this.habits, (habit: AntiHabit, index: number) => {
            ListItem() {
              Stack({alignContent: Alignment.BottomEnd}) {
                // 白色卡片内容
                Column() {
                  Row() {
                    Text(habit.name)
                      .fontSize(20)
                      .layoutWeight(1)
                    Text(`${calculateDaysBetween(habit.lastBreakDate, new Date())} 天`)
                      .fontSize(24)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#3cba54')
                  }
                  .width('100%')
                  .padding({ top: 20, left: 20, right: 20, bottom: 15 })
                  .onClick(() => {
                    if (!this.context) return;
                    const habitData = this.habits[index].toJSON();
                    this.getUIContext().getRouter().pushUrl({
                      url: 'pages/AchievementPage',
                      params: { habit: habitData }
                    }, (err) => {
                      if (err) console.error('跳转失败:', err);
                    })
                  })

                  Button('我失败了...', { type: ButtonType.Capsule })
                    .width('60%')
                    .height(40)
                    .backgroundColor('#ffef4e4e')
                    .fontColor(Color.White)
                    .margin({ bottom: 15 })
                    .onClick(() => {
                      this.resetHabit(index);
                    })
                }
                .width('100%')
                .backgroundColor(Color.White)
                .borderRadius(15)
                .shadow({ radius: 6, color: '#1F000000', offsetX: 2, offsetY: 4 })
                .alignItems(HorizontalAlign.Center)

                // 删除按钮固定在卡片右上角
                Image($r('app.media.ic_delete'))
                  .width(28)
                  .height(28)
                  .fillColor(Color.Gray)
                  .padding(8)
                  .onClick(() => {
                    this.habitToDeleteIndex = index;
                    this.deleteDialogController.open();
                  })
                  .align(Alignment.Top) // 关键：对齐到右上角
                  .margin({ top: 7, right: 7 })
              }
            }
          })
        }
        .width('100%')
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')



    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F3F5')


  }
}
