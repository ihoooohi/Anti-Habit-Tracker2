// import { AntiHabit } from '../model/AntiHabit';
// import { calculateDaysBetween } from '../util/DateUtil';
// import { AddHabitDialog } from '../view/AddHabitDialog';
// import { habitStorage } from '../util/HabitStorage';
// import common from '@ohos.app.ability.common';
// import { achievementService } from '../util/AchievementService';
// import router from '@ohos.router';
//
// interface AchievementDialogParams {
//   names: string[];
// }
//
// @Entry
// @Component
// struct Index {
//   @State habits: AntiHabit[] = [];
//   @State habitToDeleteIndex: number = -1;
//   @State newAchievementNames: string[] = [];
//
//   private context: common.UIAbilityContext | null = null;
//
//   private deleteDialogController: CustomDialogController = new CustomDialogController({
//     builder: this.DeleteConfirmDialog,
//     autoCancel: true
//   });
//
//   private achievementDialogController: CustomDialogController = new CustomDialogController({
//     builder: () => {
//       this.AchievementUnlockedDialog({ names: this.newAchievementNames })
//     },
//     autoCancel: true,
//     alignment: DialogAlignment.Center
//   });
//
//   @Builder
//   private buildAddHabitDialog() {
//     AddHabitDialog({
//       controller: this.dialogController,
//       onConfirm: (name: string) => {
//         this.addNewHabit(name);
//       }
//     })
//   }
//
//   private dialogController: CustomDialogController = new CustomDialogController({
//     builder: this.buildAddHabitDialog,
//     autoCancel: true,
//     alignment: DialogAlignment.Center
//   });
//
//   onPageShow() {
//     this.context = getContext(this) as common.UIAbilityContext;
//     habitStorage.loadHabits(this.context).then(loadedHabits => {
//       let anyChange = false;
//       let allNewNames: string[] = [];
//
//       loadedHabits.forEach(habit => {
//         const newlyUnlocked = achievementService.checkAndUnlock(habit);
//         if (newlyUnlocked.length > 0) {
//           anyChange = true;
//           allNewNames.push(...newlyUnlocked);
//         }
//       });
//
//       this.habits = loadedHabits;
//
//       if (anyChange) {
//         this.newAchievementNames = allNewNames;
//         this.achievementDialogController.open();
//         if (this.context) {
//           habitStorage.saveHabits(this.context, this.habits);
//         }
//       }
//     })
//   }
//
//   async resetHabit(index: number) {
//     if (!this.context) return;
//     const oldHabit = this.habits[index];
//     const updatedHabit = new AntiHabit(oldHabit.id, oldHabit.name, new Date(), []);
//     this.habits[index] = updatedHabit;
//     await habitStorage.saveHabits(this.context, this.habits);
//   }
//
//   async addNewHabit(name: string) {
//     if (!this.context) return;
//     const newId = new Date().getTime();
//     const newHabit = new AntiHabit(newId, name, new Date());
//     this.habits.unshift(newHabit);
//     await habitStorage.saveHabits(this.context, this.habits);
//   }
//
//   async deleteHabit(index: number) {
//     if (!this.context || index < 0 || index >= this.habits.length) {
//       return;
//     }
//     this.habits.splice(index, 1);
//     await habitStorage.saveHabits(this.context, this.habits);
//   }
//
//   @Builder AchievementUnlockedDialog(params: AchievementDialogParams) {
//     Column({ space: 20 }) {
//       Text('恭喜！')
//         .fontSize(24).fontWeight(FontWeight.Bold)
//       Text(`你解锁了新的成就：\n${params.names.join('、')}`)
//         .fontSize(18)
//         .textAlign(TextAlign.Center)
//         .lineHeight(24)
//       Button('太棒了！')
//         .width('80%')
//         .type(ButtonType.Capsule)
//         .onClick(() => {
//           this.achievementDialogController.close()
//         })
//     }.width('80%').padding(25).backgroundColor(Color.White).borderRadius(20)
//   }
//
//   @Builder DeleteConfirmDialog() {
//     Column({ space: 20 }) {
//       Text('确认删除')
//         .fontSize(22).fontWeight(FontWeight.Bold)
//       Text('你确定要删除这个习惯吗？\n此操作不可撤销。')
//         .fontSize(16).textAlign(TextAlign.Center).fontColor(Color.Gray)
//       Row({ space: 15 }) {
//         Button('取消')
//           .layoutWeight(1)
//           .onClick(() => {
//             this.deleteDialogController.close();
//           })
//         Button('确认删除')
//           .layoutWeight(1)
//           .type(ButtonType.Capsule)
//           .backgroundColor('#ff4d4f')
//           .onClick(() => {
//             if (this.habitToDeleteIndex !== -1) {
//               this.deleteHabit(this.habitToDeleteIndex);
//             }
//             this.deleteDialogController.close();
//           })
//       }
//       .width('100%')
//     }
//     .width('80%')
//     .padding(25)
//     .backgroundColor(Color.White)
//     .borderRadius(20)
//   }
//
//   build() {
//     Stack({alignContent: Alignment.BottomEnd}) {
//       // 悬浮添加按钮固定到页面右下角
//       Button({ type: ButtonType.ROUNDED_RECTANGLE }) {
//         Image($r('app.media.built'))
//           .width(30)
//           .height(30)
//           .fillColor(Color.White)
//
//       }
//       .width(56)
//       .height(56)
//       .backgroundColor('#ffffffff')
//       .shadow({ radius: 10, color: '#1F000000' })
//       .onClick(() => {
//         this.dialogController.open();
//       })
//       .zIndex(999) // 确保按钮层级高于滚动内容
//       .align(Alignment.Center) // 关键：固定到右下角
//       .margin({ right: '5%', bottom: '5%' }) // 离边框 20px
//
//       Column() {
//         Text('今天你“没做”什么？')
//           .fontSize(30)
//           .fontWeight(FontWeight.Bold)
//           .width('100%')
//           .textAlign(TextAlign.Center)
//           .padding({ top: 40, bottom: 20 })
//
//         List({ space: 12, initialIndex: 0 }) {
//           ForEach(this.habits, (habit: AntiHabit, index: number) => {
//             ListItem() {
//               Stack({alignContent: Alignment.BottomEnd}) {
//                 // 白色卡片内容
//                 Column() {
//                   Row() {
//                     Text(habit.name)
//                       .fontSize(20)
//                       .layoutWeight(1)
//                     Text(`${calculateDaysBetween(habit.lastBreakDate, new Date())} 天`)
//                       .fontSize(24)
//                       .fontWeight(FontWeight.Bold)
//                       .fontColor('#3cba54')
//                   }
//                   .width('100%')
//                   .padding({ top: 20, left: 20, right: 20, bottom: 15 })
//                   .onClick(() => {
//                     if (!this.context) return;
//                     const habitData = this.habits[index].toJSON();
//                     this.getUIContext().getRouter().pushUrl({
//                       url: 'pages/AchievementPage',
//                       params: { habit: habitData }
//                     }, (err) => {
//                       if (err) console.error('跳转失败:', err);
//                     })
//                   })
//
//                   Button('我失败了...', { type: ButtonType.Capsule })
//                     .width('60%')
//                     .height(40)
//                     .backgroundColor('#ffef4e4e')
//                     .fontColor(Color.White)
//                     .margin({ bottom: 15 })
//                     .onClick(() => {
//                       this.resetHabit(index);
//                     })
//                 }
//                 .width('100%')
//                 .backgroundColor(Color.White)
//                 .borderRadius(15)
//                 .shadow({ radius: 6, color: '#1F000000', offsetX: 2, offsetY: 4 })
//                 .alignItems(HorizontalAlign.Center)
//
//                 // 删除按钮固定在卡片右上角
//                 Image($r('app.media.ic_delete'))
//                   .width(28)
//                   .height(28)
//                   .fillColor(Color.Gray)
//                   .padding(8)
//                   .onClick(() => {
//                     this.habitToDeleteIndex = index;
//                     this.deleteDialogController.open();
//                   })
//                   .align(Alignment.Top) // 关键：对齐到右上角
//                   .margin({ top: 7, right: 7 })
//               }
//             }
//           })
//         }
//         .width('100%')
//         .layoutWeight(1)
//         .edgeEffect(EdgeEffect.Spring)
//       }
//       .width('100%')
//       .height('100%')
//
//
//
//     }
//     .width('100%')
//     .height('100%')
//     .backgroundColor('#F1F3F5')
//
//
//   }
// }
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
  @State totalDays: number = 0; // 新增：总天数统计
  @State todayProgress: number = 0; // 新增：今日进度

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

  // 新增：计算统计数据
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
      this.calculateStats(); // 计算统计数据

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
    this.calculateStats(); // 重新计算统计数据
  }

  async addNewHabit(name: string) {
    if (!this.context) return;
    const newId = new Date().getTime();
    const newHabit = new AntiHabit(newId, name, new Date());
    this.habits.unshift(newHabit);
    await habitStorage.saveHabits(this.context, this.habits);
    this.calculateStats(); // 重新计算统计数据
  }

  async deleteHabit(index: number) {
    if (!this.context || index < 0 || index >= this.habits.length) {
      return;
    }
    this.habits.splice(index, 1);
    await habitStorage.saveHabits(this.context, this.habits);
    this.calculateStats(); // 重新计算统计数据
  }

  // 新增：获取天数对应的颜色
  private getDaysColor(days: number): string {
    if (days >= 30) return '#00C853'; // 深绿色
    if (days >= 14) return '#4CAF50'; // 绿色
    if (days >= 7) return '#8BC34A';  // 浅绿色
    if (days >= 3) return '#FFC107';  // 黄色
    return '#FF5722'; // 橙红色
  }

  // 新增：获取徽章文字
  private getBadgeText(days: number): string {
    if (days >= 30) return '💎';
    if (days >= 14) return '🏆';
    if (days >= 7) return '🥇';
    if (days >= 3) return '🥈';
    return '🥉';
  }

  @Builder AchievementUnlockedDialog(params: AchievementDialogParams) {
    Column({ space: 20 }) {
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

  @Builder DeleteConfirmDialog() {
    Column({ space: 20 }) {
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

  // 新增：统计卡片Builder
  @Builder
  StatsCard() {
    Row({ space: 20 }) {
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

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      // 改进的悬浮添加按钮
      Button({ type: ButtonType.Circle }) {
        Text('+')
          .fontSize(24)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
      }
      .width(60)
      .height(60)
      .backgroundColor('#FF6B35')
      .shadow({
        radius: 15,
        color: '#40FF6B35',
        offsetY: 6
      })
      .onClick(() => {
        this.dialogController.open();
      })
      .zIndex(999)
      .margin({ right: 20, bottom: 100 })

      Column() {
        // 改进的标题区域
        Column({ space: 10 }) {
          Text('今天你"没做"什么？')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333')
            .textAlign(TextAlign.Center)

          Text('坚持就是胜利 💪')
            .fontSize(16)
            .fontColor('#666')
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .padding({ top: 40, bottom: 10 })

        // 新增：统计卡片
        this.StatsCard()

        // 改进的习惯列表
        if (this.habits.length > 0) {
          List({ space: 15, initialIndex: 0 }) {
            ForEach(this.habits, (habit: AntiHabit, index: number) => {
              ListItem() {
                Stack({ alignContent: Alignment.TopEnd }) {
                  // 改进的卡片设计
                  Column() {
                    Row({ space: 15 }) {
                      // 左侧徽章
                      Text(this.getBadgeText(calculateDaysBetween(habit.lastBreakDate, new Date())))
                        .fontSize(24)
                        .width(50)
                        .height(50)
                        .textAlign(TextAlign.Center)
                        .backgroundColor('#F8F9FA')
                        .borderRadius(25)
                        .border({
                          width: 2,
                          color: this.getDaysColor(calculateDaysBetween(habit.lastBreakDate, new Date()))
                        })

                      // 中间内容
                      Column({ space: 5 }) {
                        Text(habit.name)
                          .fontSize(18)
                          .fontWeight(FontWeight.Medium)
                          .fontColor('#333')
                          .maxLines(1)
                          .textOverflow({ overflow: TextOverflow.Ellipsis })

                        Text(`已坚持 ${calculateDaysBetween(habit.lastBreakDate, new Date())} 天`)
                          .fontSize(14)
                          .fontColor('#666')
                      }
                      .alignItems(HorizontalAlign.Start)
                      .layoutWeight(1)

                      // 右侧天数显示
                      Text(`${calculateDaysBetween(habit.lastBreakDate, new Date())}`)
                        .fontSize(24)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(this.getDaysColor(calculateDaysBetween(habit.lastBreakDate, new Date())))
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

                    // 改进的失败按钮
                    Button('我失败了 😔', { type: ButtonType.Capsule })
                      .width('70%')
                      .height(40)
                      .backgroundColor('#FF5252')
                      .fontColor(Color.White)
                      .fontSize(14)
                      .margin({ bottom: 20 })
                      .onClick(() => {
                        this.resetHabit(index);
                      })
                  }
                  .width('100%')
                  .backgroundColor(Color.White)
                  .borderRadius(15)
                  .shadow({
                    radius: 8,
                    color: '#1A000000',
                    offsetX: 0,
                    offsetY: 4
                  })
                  .alignItems(HorizontalAlign.Center)

                  // 改进的删除按钮
                  Button({ type: ButtonType.Circle }) {
                    Text('×')
                      .fontSize(18)
                      .fontColor('#999')
                  }
                  .width(20)
                  .height(20)
                  .backgroundColor('#F5F5F5')
                  .onClick(() => {
                    this.habitToDeleteIndex = index;
                    this.deleteDialogController.open();
                  })
                  .margin({ top: 10, right: 10 })
                }
              }
            })
          }
          .width('90%')
          .layoutWeight(1)
          .edgeEffect(EdgeEffect.Spring)
        } else {
          // 空状态显示
          Column({ space: 20 }) {
            Text('📝')
              .fontSize(64)
              .opacity(0.5)

            Text('还没有追踪任何习惯')
              .fontSize(18)
              .fontColor('#999')

            Text('点击右下角的 + 按钮添加第一个习惯吧！')
              .fontSize(14)
              .fontColor('#BBB')
              .textAlign(TextAlign.Center)
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        }
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
  }
}