// entry/src/main/ets/model/AntiHabit.ts

// 定义失败记录的结构
export interface FailureLog {
  date: Date;
  reason: string;
}

export class AntiHabit {
  id: number;
  name: string;
  lastBreakDate: Date;
  unlockedAchievements: number[] = [];
  failureLogs: FailureLog[] = []; // 新增：用于存储失败记录的数组

  constructor(id: number, name: string, lastBreakDate: Date, unlockedAchievements: number[] = [], failureLogs: FailureLog[] = []) {
    this.id = id;
    this.name = name;
    this.lastBreakDate = lastBreakDate;
    this.unlockedAchievements = unlockedAchievements;
    this.failureLogs = failureLogs; // 初始化
  }

  // toJSON 方法，用于序列化
  toJSON() {
    return {
      id: this.id,
      name: this.name,
      lastBreakDate: this.lastBreakDate.toISOString(),
      unlockedAchievements: this.unlockedAchievements,
      // 序列化 failureLogs 数组
      failureLogs: this.failureLogs.map(log => ({
        date: log.date.toISOString(),
        reason: log.reason
      }))
    };
  }

  // fromJSON 方法，用于反序列化
  static fromJSON(data: any): AntiHabit {
    // 反序列化 failureLogs 数组
    const failureLogs = (data.failureLogs || []).map((log: any) => ({
      date: new Date(log.date),
      reason: log.reason
    }));

    return new AntiHabit(
      data.id,
      data.name,
      new Date(data.lastBreakDate),
      data.unlockedAchievements || [],
      failureLogs
    );
  }
}

