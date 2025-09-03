// entry/src/main/ets/view/BreakConfirmDialog.ets

@CustomDialog
export struct BreakConfirmDialog {
  controller: CustomDialogController;
  onConfirm: () => void = () => {};
  onCancel: () => void = () => {};

  build() {
    Column({ space: 20 }) {
      Text('⚠️ 你确定破戒了吗？')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)

      Text('确认后会清零坚持天数')
        .fontSize(16)
        .fontColor('#666')
        .textAlign(TextAlign.Center)

      Row({ space: 15 }) {
        Button('取消')
          .layoutWeight(1)
          .backgroundColor('#F5F5F5')
          .fontColor('#333')
          .onClick(() => {
            this.onCancel();
            this.controller.close();
          })

        Button('确认破戒')
          .layoutWeight(1)
          .type(ButtonType.Capsule)
          .backgroundColor('#FF4444')
          .fontColor(Color.White)
          .onClick(() => {
            this.onConfirm();
            this.controller.close();
          })
      }
      .width('100%')
    }
    .width('90%')
    .padding(25)
    .backgroundColor(Color.White)
    .borderRadius(20)
  }
}
