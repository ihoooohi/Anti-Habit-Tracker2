// entry/src/main/ets/util/DateUtil.ts

export function calculateDaysBetween(startDate: Date, endDate: Date): number {
  // 为了精确计算天数，我们将日期的时间部分都设置为0点0分0秒
  const start = new Date(startDate.getFullYear(), startDate.getMonth(), startDate.getDate());
  const end = new Date(endDate.getFullYear(), endDate.getMonth(), endDate.getDate());

  // 计算两个日期之间的毫秒差
  const diffInMs = end.getTime() - start.getTime();

  // 将毫秒差转换为天数
  const days = Math.floor(diffInMs / (1000 * 60 * 60 * 24));

  return days;
}