// entry/src/main/ets/util/HabitStorage.ts

import preferences from '@ohos.data.preferences';
import { AntiHabit } from '../model/AntiHabit';


const PREFERENCES_NAME = 'habit_store'; // 存储文件的名称
const HABITS_KEY = 'habit_list_key';    // 存储习惯列表的键

class HabitStorage {
  private pref: preferences.Preferences | null = null;

  // 获取 Preferences 实例的异步方法
  private async getPreferences(context): Promise<preferences.Preferences> {
    if (this.pref !== null) {
      return this.pref;
    }
    this.pref = await preferences.getPreferences(context, PREFERENCES_NAME);
    return this.pref;
  }

  /**
   * 保存习惯列表到本地
   * @param context 应用的上下文，用于获取 Preferences 实例
   * @param habits 要保存的习惯数组
   */
  async saveHabits(context, habits: AntiHabit[]): Promise<void> {
    try {
      const prefs = await this.getPreferences(context);
      // 1. 将对象数组转换成 JSON 字符串
      const habitsJson = JSON.stringify(habits);
      // 2. 将字符串存入 Preferences
      await prefs.put(HABITS_KEY, habitsJson);
      await prefs.flush(); // 确保数据立即写入磁盘
      console.info('Habits saved successfully.');
    } catch (e) {
      console.error('Failed to save habits.', JSON.stringify(e));
    }
  }

  /**
   * 从本地加载习惯列表
   * @param context 应用的上下文
   * @returns 返回一个包含 AntiHabit 实例的数组
   */
  async loadHabits(context): Promise<AntiHabit[]> {
    try {
      const prefs = await this.getPreferences(context);
      // 1. 从 Preferences 读取字符串，如果不存在，默认返回空数组的字符串 '[]'
      const habitsJson = await prefs.get(HABITS_KEY, '[]') as string;
      // 2. 将 JSON 字符串解析成通用的对象数组
      const rawHabits = JSON.parse(habitsJson);

      if (!Array.isArray(rawHabits)) {
        return [];
      }

      // 3. 关键！使用 AntiHabit.fromJSON 将通用对象转换回 AntiHabit 类的实例
      // 这样可以确保所有字段（包括 failureLogs）都被正确恢复
      return rawHabits.map(item => AntiHabit.fromJSON(item));
    } catch (e) {
      console.error('Failed to load habits.', JSON.stringify(e));
      return []; // 如果加载失败，返回一个空数组防止应用崩溃
    }
  }
}

// 导出单例，确保整个应用只有一个存储实例
export const habitStorage = new HabitStorage();