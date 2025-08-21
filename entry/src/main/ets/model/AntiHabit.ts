// entry/src/main/ets/model/AntiHabit.ts

export class AntiHabit {
  id: number;
  name: string;
  lastBreakDate: Date;
  unlockedAchievements: number[] = []; // 新增：用于存储已解锁成就的ID

  constructor(id: number, name: string, lastBreakDate: Date, unlockedAchievements: number[] = []) {
    this.id = id;
    this.name = name;
    this.lastBreakDate = lastBreakDate;
    this.unlockedAchievements = unlockedAchievements; // 初始化
  }
  // 新增：toJSON 方法，用于序列化
  toJSON() {
    return {
      id: this.id,
      name: this.name,
      // 将 Date 对象转换为 ISO 字符串（如 '2023-05-31T10:00:00.000Z'），这是标准的序列化格式
      lastBreakDate: this.lastBreakDate.toISOString(),
      unlockedAchievements: this.unlockedAchievements
    };
  }
  static fromJSON(data: AntiHabit): AntiHabit {
    // new Date(string) 可以将 ISO 格式的字符串转换回 Date 对象
    return new AntiHabit(
      data.id,
      data.name,
      new Date(data.lastBreakDate),
      data.unlockedAchievements
    );
  }
}

