import { Achievement } from '../model/Achievement';

// 定义所有可能的成就
export const ALL_ACHIEVEMENTS: Achievement[] = [
  new Achievement(1, '初窥门径', '成功坚持了第 1 天！', 1, 'app.media.built'),
  new Achievement(2, '渐入佳境', '连续坚持 3 天，继续加油！', 3, 'app.media.badge_3_day'),
  new Achievement(3, '小有成就', '坚持了整整一周！', 7, 'app.media.badge_7_day'),
  new Achievement(4, '习惯之力', '连续坚持 14 天！', 14, 'app.media.badge_14_day'),
  new Achievement(5, '月下独酌', '太棒了，坚持满一个月！', 30, 'app.media.badge_30_day'),
  new Achievement(6, '百日维新', '不可思议的 100 天！', 100, 'app.media.badge_100_day')
];