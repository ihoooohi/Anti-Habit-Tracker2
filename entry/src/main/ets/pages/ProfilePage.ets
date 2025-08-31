// entry/src/main/ets/pages/ProfilePage.ets
import common from '@ohos.app.ability.common';
import { AntiHabit } from '../model/AntiHabit';
import { calculateDaysBetween } from '../util/DateUtil';
import { habitStorage } from '../util/HabitStorage';
import { eventBus } from '../util/eventBus';
import { router } from '@kit.ArkUI';
import { profileStorage, ProfileInfo } from '../util/ProfileStorage';

// 定义事件数据类型
interface ProfileUpdateEvent {
  avatarUri?: string;
  nickname?: string;
  signature?: string;
}

@Entry
@Component
export struct ProfilePage {
  @State totalDays: number = 0;
  @State longestStreak: number = 0;
  @State totalAchievements: number = 0;
  @State updateTrigger: number = 0; // 用于强制UI更新

  @State avatarUri: string = '';
  @State nickname: string = '反习惯达人'; // 用户名
  @State signature: string = '日复一日，功不唐捐'; // 个性签名

  private context: common.UIAbilityContext | null = null;
  // 添加事件回调引用
  private habitsUpdatedCallback: () => void = () => {};
  private profileUpdatedCallback: (data: ProfileUpdateEvent) => void = () => {};

  aboutToAppear() {
    this.context = getContext(this) as common.UIAbilityContext;
    this.loadAndCalculateStats();

    if (this.context) {
      profileStorage.loadProfile(this.context).then((profile: ProfileInfo) => {
        this.avatarUri = profile.avatarUri;
        this.nickname = profile.nickname;
        this.signature = profile.signature;
      });
    }

    // 监听习惯更新事件
    this.habitsUpdatedCallback = () => {
      setTimeout(() => {
        this.loadAndCalculateStats();
      }, 100);
    };
    eventBus.on('habitsUpdated', this.habitsUpdatedCallback);

    // 监听个人资料更新
    this.profileUpdatedCallback = (data: ProfileUpdateEvent) => {
      if (data.avatarUri !== undefined) this.avatarUri = data.avatarUri;
      if (data.nickname !== undefined) this.nickname = data.nickname;
      if (data.signature !== undefined) this.signature = data.signature;
    };
    eventBus.on('profileUpdated', this.profileUpdatedCallback);
  }

  // 页面即将消失时取消订阅
  aboutToDisappear() {
    eventBus.off('habitsUpdated', this.habitsUpdatedCallback);
    eventBus.off('profileUpdated', this.profileUpdatedCallback);
  }

  // 页面显示时刷新数据
  onPageShow() {
    if (this.context) {
      this.loadAndCalculateStats();

      // 保证重新进入时能显示最新资料
      profileStorage.loadProfile(this.context).then((profile: ProfileInfo) => {
        this.avatarUri = profile.avatarUri;
        this.nickname = profile.nickname;
        this.signature = profile.signature;
      });
    }
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

      // 先清零所有状态，然后设置新值
      this.totalDays = 0;
      this.longestStreak = 0;
      this.totalAchievements = 0;
      this.updateTrigger++;

      // 使用setTimeout确保UI能正确更新
      setTimeout(() => {
        this.totalDays = total;
        this.longestStreak = longest;
        this.totalAchievements = achievements;
        this.updateTrigger++;
      }, 10);
    }).catch((error: Error) => {
      console.error('ProfilePage: 加载习惯数据失败', error);
    });
  }

  @Builder
  ProfileCard() {
    Row({ space: 15 }) {
      // 头像
      Image(this.avatarUri ? this.avatarUri : $r('app.media.startIcon'))
        .width(60)
        .height(60)
        .borderRadius(30)
        .border({ width: 2, color: Color.White })

      // 用户名和签名
      Column({ space: 5 }) {
        Text(this.nickname)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.Black)
        Text(this.signature)
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
    // 点击进入个人资料页面
    .onClick(() => {
      router.pushUrl({
        url: 'pages/EditProfilePage'
      });
    })
  }

  @Builder
  CoreStatsCard() {
    // 采用竖向列表样式，更简洁
    Column() {
      // 直接使用Row组件确保状态绑定正确
      Row({ space: 15 }) {
        Text('📅')
          .fontSize(20)
          .width(24)
          .textAlign(TextAlign.Center)
        Text('总坚持天数')
          .fontSize(16)
          .fontColor(Color.Black)
        Blank()
        Text(`${this.totalDays}天`)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FF6B35')
      }
      .width('100%')
      .height(55)
      .padding({ left: 10, right: 10 })

      Divider().width('90%').color('#E0E0E0').margin({ left: '10%' })

      Row({ space: 15 }) {
        Text('🏆')
          .fontSize(20)
          .width(24)
          .textAlign(TextAlign.Center)
        Text('最长单项纪录')
          .fontSize(16)
          .fontColor(Color.Black)
        Blank()
        Text(`${this.longestStreak}天`)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FF6B35')
      }
      .width('100%')
      .height(55)
      .padding({ left: 10, right: 10 })

      Divider().width('90%').color('#E0E0E0').margin({ left: '10%' })

      Row({ space: 15 }) {
        Text('🌟')
          .fontSize(20)
          .width(24)
          .textAlign(TextAlign.Center)
        Text('已解锁成就')
          .fontSize(16)
          .fontColor(Color.Black)
        Blank()
        Text(`${this.totalAchievements}个`)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FF6B35')
      }
      .width('100%')
      .height(55)
      .padding({ left: 10, right: 10 })
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
