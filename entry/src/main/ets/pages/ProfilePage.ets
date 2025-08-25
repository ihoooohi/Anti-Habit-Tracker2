// entry/src/main/ets/pages/ProfilePage.ets
@Entry
@Component
export struct ProfilePage {
  build() {
    Column() {
      Text('我的页面')
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#F1F3F5')
  }
}
