// entry/src/main/ets/pages/AchievementPage.ets

import router from '@ohos.router';
import { Achievement } from '../model/Achievement';
import { AntiHabit } from '../model/AntiHabit';
import { ALL_ACHIEVEMENTS } from '../util/AchievementList';
// 定义路由参数类型接口
interface RouteParams {
  habit: AntiHabit;
}

@Entry
@Component
struct AchievementPage {
  // 这样可以避免在构造函数中立即访问路由参数
  @State habit: AntiHabit | null = null;
  aboutToAppear() {
    const params = router.getParams() as RouteParams;
    if (params && params.habit) {
      // 从序列化的数据中重建 AntiHabit 对象
      this.habit = AntiHabit.fromJSON(params.habit);
    } else {
      console.error('AchievementPage: Failed to get habit from router params.');
      // 可以在这里处理错误，比如返回上一页或显示错误信息
      router.back();
    }
  }

  build() {
    // 确保 this.habit 不是 null 时才渲染UI，防止报错
    if (this.habit) {

      Column() {
        // 1. 自定义标题栏，包含返回按钮和标题
        Row() {
          // 返回按钮
          Image($r('app.media.ic_back')) // 请确保你有名为ic_back.xml的返回图标
            .width(60).height(60)
            .padding(15)
            .objectFit(ImageFit.Contain)
            // ⭐ 解决方案二：添加一个看不见的背景色
            .backgroundColor(Color.Transparent)
            .onClick(()=> {
              router.back();
            })

          // 页面标题
          Text(`"${this.habit.name}" 成就殿堂`)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
            .margin({ left: -32 }) // 负margin让标题在视觉上更居中

          // 使用 Blank 组件占位，帮助标题居中
          Blank().width(24)
        }
        .width('100%')
        .height(56) // 标准标题栏高度
        .padding({ left: 10, right: 10 })
        .backgroundColor(Color.White)
        .shadow({ radius: 3, color: '#1F000000' })


        // 2. 使用 Grid 网格布局来展示所有徽章
        Grid() {
          ForEach(ALL_ACHIEVEMENTS, (achieve: Achievement) => {
            GridItem() {
              Column({ space: 8 }) {
                // 在 build 函数内部，使用 $r() 加载资源路径字符串
                Image($r(achieve.icon))
                  .width(80).height(80)
                // 根据成就是否已解锁，动态设置灰度和透明度
                  .grayscale(this.habit!.unlockedAchievements.includes(achieve.id) ? 0 : 1)
                  .opacity(this.habit!.unlockedAchievements.includes(achieve.id) ? 1 : 0.6)

                Text(achieve.name)
                  .fontSize(16).fontWeight(FontWeight.Bold)
                Text(achieve.description)
                  .fontSize(12).fontColor(Color.Gray)
                  .textAlign(TextAlign.Center)
                  .margin({ top: 4 })
              }
              .padding(10)
              .alignItems(HorizontalAlign.Center)
            }
          })
        }
        .columnsTemplate('1fr 1fr') // 每行显示2个徽章
        .rowsGap(15)
        .columnsGap(15)
        .padding(15)
        .layoutWeight(1) // 占据剩余所有空间

      }
      .width('100%').height('100%').backgroundColor('#F1F3F5')
    }
  }
}


