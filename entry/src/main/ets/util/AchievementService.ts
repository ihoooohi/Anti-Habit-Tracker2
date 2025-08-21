// entry/src/main/ets/util/AchievementService.ts

import { AntiHabit } from '../model/AntiHabit';
import { ALL_ACHIEVEMENTS } from './AchievementList';
import { calculateDaysBetween } from './DateUtil';

class AchievementService {
  /**
   * 检查一个习惯并返回新解锁的成就
   * @param habit 要检查的习惯对象
   * @returns 返回新解锁的 Achievement 对象数组，如果没有则返回空数组
   */
  checkAndUnlock(habit: AntiHabit): string[] {
    const newUnlockedNames: string[] = [];
    const days = calculateDaysBetween(habit.lastBreakDate, new Date());

    ALL_ACHIEVEMENTS.forEach(achievement => {
      // 检查：1. 是否达到里程碑天数  2. 这个成就是否尚未解锁
      if (days >= achievement.milestone && !habit.unlockedAchievements.includes(achievement.id)) {
        // 解锁！
        habit.unlockedAchievements.push(achievement.id);
        newUnlockedNames.push(achievement.name);
      }
    });

    return newUnlockedNames;
  }
}

export const achievementService = new AchievementService();