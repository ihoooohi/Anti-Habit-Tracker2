// entry/src/main/ets/util/eventBus.ts
type Callback = (...args: any[]) => void;

class EventBus {
  private events: Record<string, Callback[]> = {};

  // 订阅事件
  on(event: string, callback: Callback) {
    if (!this.events[event]) this.events[event] = [];
    this.events[event].push(callback);
  }

  // 取消订阅
  off(event: string, callback: Callback) {
    if (!this.events[event]) return;
    this.events[event] = this.events[event].filter(cb => cb !== callback);
  }

  // 触发事件
  emit(event: string, ...args: any[]) {
    if (!this.events[event]) return;
    this.events[event].forEach(cb => cb(...args));
  }
}

// 导出单例
export const eventBus = new EventBus();
