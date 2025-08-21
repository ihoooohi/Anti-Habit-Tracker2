
export class Achievement {
  id: number;           // 唯一ID
  name: string;         // 成就名称，如“坚持3天”
  description: string;  // 描述，如“小试牛刀，初见成效！”
  milestone: number;    // 解锁需要的里程碑天数
  icon: string ;       // 徽章图标资源

  constructor(id: number, name: string, description: string, milestone: number, icon: string) {
    this.id = id;
    this.name = name;
    this.description = description;
    this.milestone = milestone;
    this.icon = icon;
  }
}