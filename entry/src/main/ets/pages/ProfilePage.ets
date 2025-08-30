// entry/src/main/ets/pages/ProfilePage.ets
import common from '@ohos.app.ability.common';
import { AntiHabit } from '../model/AntiHabit';
import { calculateDaysBetween } from '../util/DateUtil';
import { habitStorage } from '../util/HabitStorage';

@Entry
@Component
export struct ProfilePage {
  @State totalDays: number = 0;
  @State longestStreak: number = 0;
  @State totalAchievements: number = 0;

  private context: common.UIAbilityContext | null = null;

  aboutToAppear() {
    this.context = getContext(this) as common.UIAbilityContext;
    this.loadAndCalculateStats();
  }

  loadAndCalculateStats() {
    if (!this.context) return;

    habitStorage.loadHabits(this.context).then(habits => {
      let total = 0;
      let longest = 0;
      let achievements = 0;

      habits.forEach(habit => {
        const currentStreak = calculateDaysBetween(habit.lastBreakDate, new Date());
        total += currentStreak;
        if (currentStreak > longest) {
          longest = currentStreak;
        }
        achievements += habit.unlockedAchievements.length;
      });

      this.totalDays = total;
      this.longestStreak = longest;
      this.totalAchievements = achievements;
    });
  }

  @Builder
  ProfileCard() {
    Row({ space: 15 }) {
      // 头像
      Image($r('app.media.startIcon'))
        .width(60)
        .height(60)
        .borderRadius(30)
        .border({ width: 2, color: Color.White })

      // 用户名和签名
      Column({ space: 5 }) {
        Text('反习惯达人')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.Black)
        Text('日复一日，功不唐捐')
          .fontSize(14)
          .fontColor(Color.Gray)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('90%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(15)
    .shadow({ radius: 8, color: '#1F000000', offsetY: 4 })
    .margin({ top: 20 })
  }

  @Builder
  CoreStatsCard() {
    // 采用竖向列表样式，更简洁
    Column() {
      // 封装每个统计项
      this.StatsRow('📅', '总坚持天数', `${this.totalDays}`)
      Divider().width('90%').color('#E0E0E0').margin({ left: '10%' })
      this.StatsRow('🏆', '最长单项纪录', `${this.longestStreak}`)
      Divider().width('90%').color('#E0E0E0').margin({ left: '10%' })
      this.StatsRow('🌟', '已解锁成就', `${this.totalAchievements}`)
    }
    .width('90%')
    .padding({ left: 15, right: 15 })
    .backgroundColor(Color.White)
    .borderRadius(15)
    .margin({ top: 20 })
  }

  // 单独封装一个Builder用于生成每一行，方便复用和修改
  @Builder
  StatsRow(icon: string, label: string, value: string) {
    Row({
      space: 15
    }) {
      Text(icon)
        .fontSize(20)
        .width(24)
        .textAlign(TextAlign.Center)

      Text(label)
        .fontSize(16)
        .fontColor(Color.Black)

      Blank()

      Text(value)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FF6B35')
    }
    .width('100%')
    .height(55)
    .padding({ left: 10, right: 10 })
  }

  build() {
    Column() {
      // 页面标题
      Text('我的')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .width('90%')
        .textAlign(TextAlign.Start)
        .margin({ top: 20, bottom: 10 })

      // 个人信息卡片
      this.ProfileCard()

      // 核心数据统计
      this.CoreStatsCard()

      // 其他内容可以从这里继续添加
      Blank() // 占位符，用于将内容推到顶部

    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F3F5')
    .alignItems(HorizontalAlign.Center)
  }
}
