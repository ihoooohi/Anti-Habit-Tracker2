// entry/src/main/ets/pages/RecordsPage.ets
@Entry
@Component
export struct RecordsPage {
  build() {
    Column() {
      Text('记录页面')
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#F1F3F5')
  }
}
