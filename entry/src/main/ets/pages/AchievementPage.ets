// // entry/src/main/ets/pages/AchievementPage.ets
//
// import router from '@ohos.router';
// import { Achievement } from '../model/Achievement';
// import { AntiHabit } from '../model/AntiHabit';
// import { ALL_ACHIEVEMENTS } from '../util/AchievementList';
// // 定义路由参数类型接口
// interface RouteParams {
//   habit: AntiHabit;
// }
//
// @Entry
// @Component
// struct AchievementPage {
//   // 这样可以避免在构造函数中立即访问路由参数
//   @State habit: AntiHabit | null = null;
//   aboutToAppear() {
//     const params = router.getParams() as RouteParams;
//     if (params && params.habit) {
//       // 从序列化的数据中重建 AntiHabit 对象
//       this.habit = AntiHabit.fromJSON(params.habit);
//     } else {
//       console.error('AchievementPage: Failed to get habit from router params.');
//       // 可以在这里处理错误，比如返回上一页或显示错误信息
//       router.back();
//     }
//   }
//
//   build() {
//     // 确保 this.habit 不是 null 时才渲染UI，防止报错
//     if (this.habit) {
//
//       Column() {
//         // 1. 自定义标题栏，包含返回按钮和标题
//         Row() {
//           // 返回按钮
//           Image($r('app.media.ic_back')) // 请确保你有名为ic_back.xml的返回图标
//             .width(60).height(60)
//             .padding(15)
//             .objectFit(ImageFit.Contain)
//             // ⭐ 解决方案二：添加一个看不见的背景色
//             .backgroundColor(Color.Transparent)
//             .onClick(()=> {
//               router.back();
//             })
//
//           // 页面标题
//           Text(`"${this.habit.name}" 成就殿堂`)
//             .fontSize(20)
//             .fontWeight(FontWeight.Bold)
//             .layoutWeight(1)
//             .textAlign(TextAlign.Center)
//             .margin({ left: -32 }) // 负margin让标题在视觉上更居中
//
//           // 使用 Blank 组件占位，帮助标题居中
//           Blank().width(24)
//         }
//         .width('100%')
//         .height(56) // 标准标题栏高度
//         .padding({ left: 10, right: 10 })
//         .backgroundColor(Color.White)
//         .shadow({ radius: 3, color: '#1F000000' })
//
//
//         // 2. 使用 Grid 网格布局来展示所有徽章
//         Grid() {
//           ForEach(ALL_ACHIEVEMENTS, (achieve: Achievement) => {
//             GridItem() {
//               Column({ space: 8 }) {
//                 // 在 build 函数内部，使用 $r() 加载资源路径字符串
//                 Image($r(achieve.icon))
//                   .width(80).height(80)
//                 // 根据成就是否已解锁，动态设置灰度和透明度
//                   .grayscale(this.habit!.unlockedAchievements.includes(achieve.id) ? 0 : 1)
//                   .opacity(this.habit!.unlockedAchievements.includes(achieve.id) ? 1 : 0.6)
//
//                 Text(achieve.name)
//                   .fontSize(16).fontWeight(FontWeight.Bold)
//                 Text(achieve.description)
//                   .fontSize(12).fontColor(Color.Gray)
//                   .textAlign(TextAlign.Center)
//                   .margin({ top: 4 })
//               }
//               .padding(10)
//               .alignItems(HorizontalAlign.Center)
//             }
//           })
//         }
//         .columnsTemplate('1fr 1fr') // 每行显示2个徽章
//         .rowsGap(15)
//         .columnsGap(15)
//         .padding(15)
//         .layoutWeight(1) // 占据剩余所有空间
//
//       }
//       .width('100%').height('100%').backgroundColor('#F1F3F5')
//     }
//   }
// }
//
//
import router from '@ohos.router';
import { Achievement } from '../model/Achievement';
import { AntiHabit } from '../model/AntiHabit';
import { ALL_ACHIEVEMENTS } from '../util/AchievementList';
import { calculateDaysBetween } from '../util/DateUtil';

interface RouteParams {
  habit: AntiHabit;
}

// 添加边框样式接口定义
interface BorderConfig {
  width: number;
  color: string;
  style: BorderStyle;
}

@Entry
@Component
struct AchievementPage {
  @State habit: AntiHabit | null = null;
  @State unlockedCount: number = 0;
  @State totalCount: number = 0;
  @State currentDays: number = 0;

  aboutToAppear() {
    const params = router.getParams() as RouteParams;
    if (params && params.habit) {
      this.habit = AntiHabit.fromJSON(params.habit);
      this.calculateStats();
    } else {
      console.error('AchievementPage: Failed to get habit from router params.');
      router.back();
    }
  }

  private calculateStats() {
    if (this.habit) {
      this.unlockedCount = this.habit.unlockedAchievements.length;
      this.totalCount = ALL_ACHIEVEMENTS.length;
      this.currentDays = calculateDaysBetween(this.habit.lastBreakDate, new Date());
    }
  }

  // 获取成就状态颜色
  private getAchievementColor(achievement: Achievement): string {
    if (this.habit?.unlockedAchievements.includes(achievement.id)) {
      return '#4CAF50'; // 已解锁：绿色
    }
    return '#E0E0E0'; // 未解锁：灰色
  }

  // 修复：使用明确的返回类型
  private getAchievementBorder(achievement: Achievement): BorderConfig {
    if (this.habit?.unlockedAchievements.includes(achievement.id)) {
      const unlockedBorder: BorderConfig = {
        width: 3,
        color: '#4CAF50',
        style: BorderStyle.Solid
      };
      return unlockedBorder;
    }

    const lockedBorder: BorderConfig = {
      width: 2,
      color: '#E0E0E0',
      style: BorderStyle.Dashed
    };
    return lockedBorder;
  }

  @Builder
  StatsHeader() {
    Column({ space: 15 }) {
      // 习惯名称和天数
      Column({ space: 10 }) {
        Text(`"${this.habit?.name}"`)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333')
          .textAlign(TextAlign.Center)

        Row({ space: 10 }) {
          Text('已坚持')
            .fontSize(16)
            .fontColor('#666')

          Text(`${this.currentDays}`)
            .fontSize(32)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF6B35')

          Text('天')
            .fontSize(16)
            .fontColor('#666')
        }
        .justifyContent(FlexAlign.Center)
      }

      // 成就进度条
      Column({ space: 8 }) {
        Row() {
          Text('成就进度')
            .fontSize(14)
            .fontColor('#666')

          Blank()

          Text(`${this.unlockedCount}/${this.totalCount}`)
            .fontSize(14)
            .fontColor('#666')
        }
        .width('100%')

        // 进度条
        Progress({
          value: this.unlockedCount,
          total: this.totalCount,
          type: ProgressType.Linear
        })
          .width('100%')
          .height(8)
          .color('#4CAF50')
          .backgroundColor('#E8F5E8')
          .borderRadius(4)
      }
      .width('100%')
    }
    .width('90%')
    .padding(25)
    .backgroundColor(Color.White)
    .borderRadius(15)
    .shadow({ radius: 8, color: '#1F000000', offsetY: 4 })
    .margin({ top: 20, bottom: 20 })
  }

  build() {
    if (this.habit) {
      Column() {
        // 改进的标题栏
        Row() {
          Button({ type: ButtonType.Circle }) {
            Text('←')
              .fontSize(20)
              .fontColor('#333')
          }
          .width(40)
          .height(40)
          .backgroundColor('#F5F5F5')
          .onClick(() => {
            router.back();
          })

          Text('成就殿堂')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
            .fontColor('#333')

          // 占位符保持标题居中
          Blank().width(40)
        }
        .width('100%')
        .height(60)
        .padding({ left: 15, right: 15 })
        .backgroundColor(Color.White)
        .shadow({ radius: 4, color: '#1F000000', offsetY: 2 })

        // 滚动内容
        Scroll() {
          Column() {
            // 统计头部
            this.StatsHeader()

            // 成就分类标题
            Text('🏆 全部成就')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333')
              .width('90%')
              .margin({ bottom: 15 })

            // 改进的成就网格
            Grid() {
              ForEach(ALL_ACHIEVEMENTS, (achievement: Achievement, index: number) => {
                GridItem() {
                  Column({ space: 12 }) {
                    // 成就图标容器
                    Stack() {
                      // 背景圆圈
                      Circle()
                        .width(80)
                        .height(80)
                        .fill(this.getAchievementColor(achievement))
                        .opacity(0.1)

                      // 成就图标
                      Image($r(achievement.icon))
                        .width(50)
                        .height(50)
                        .grayscale(this.habit!.unlockedAchievements.includes(achievement.id) ? 0 : 1)
                        .opacity(this.habit!.unlockedAchievements.includes(achievement.id) ? 1 : 0.4)

                      // // 已解锁徽章
                      // if (this.habit!.unlockedAchievements.includes(achievement.id)) {
                      //   Text('✓')
                      //     .fontSize(16)
                      //     .fontColor('#4CAF50')
                      //     .backgroundColor(Color.White)
                      //     .border({ color: '#4CAF50' })  // 绿色边框
                      //     .width(24)
                      //     .height(24)
                      //     .borderRadius(12)
                      //     .textAlign(TextAlign.Center)
                      //     .position({ x: 60, y: 5 })
                      // }
                    }
                    .border(this.getAchievementBorder(achievement))
                    .borderRadius(40)

                    // 成就信息
                    Column({ space: 4 }) {
                      Text(achievement.name)
                        .fontSize(14)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(this.habit!.unlockedAchievements.includes(achievement.id) ? '#333' : '#999')
                        .textAlign(TextAlign.Center)
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })

                      Text(achievement.description)
                        .fontSize(12)
                        .fontColor(this.habit!.unlockedAchievements.includes(achievement.id) ? '#666' : '#BBB')
                        .textAlign(TextAlign.Center)
                        .maxLines(2)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .lineHeight(16)
                    }
                    .width('100%')
                  }
                  .padding(15)
                  .backgroundColor(Color.White)
                  .borderRadius(12)
                  .shadow({
                    radius: this.habit!.unlockedAchievements.includes(achievement.id) ? 8 : 4,
                    color: '#1A000000',
                    offsetY: this.habit!.unlockedAchievements.includes(achievement.id) ? 4 : 2
                  })
                  .alignItems(HorizontalAlign.Center)
                  // 添加点击动画效果
                  .animation({
                    duration: 200,
                    curve: Curve.EaseInOut
                  })
                }
              })
            }
            .columnsTemplate('1fr 1fr')
            .rowsGap(15)
            .columnsGap(15)
            .width('90%')
            .margin({ bottom: 30 })
          }
          .alignItems(HorizontalAlign.Center)
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)

      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F8F9FA')
    }
  }
}