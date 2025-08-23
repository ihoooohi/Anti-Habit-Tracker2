// entry/src/main/ets/view/FailureLogDialog.ets

@CustomDialog
export struct FailureLogDialog {
  controller: CustomDialogController;
  // 回调函数，将用户输入的原因传递回主页面
  onConfirm: (reason: string) => void = () => {};

  // 预设的几个常用原因
  private presetReasons: string[] = ['压力', '无聊', '社交', '疲劳', '诱惑'];
  // 用户当前选择或输入的原因
  @State selectedReason: string = '';

  build() {
    Column({ space: 20 }) {
      Text('记录失败原因')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)

      Text('别灰心，记录下来，下次做得更好！')
        .fontSize(14)
        .fontColor(Color.Gray)

      // 预设原因区域
      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Start }) {
        ForEach(this.presetReasons, (reason: string) => {
          Button(reason)
            .type(ButtonType.Capsule)
            .backgroundColor(this.selectedReason === reason ? '#FF6B35' : '#F0F0F0')
            .fontColor(this.selectedReason === reason ? Color.White : Color.Black)
            .margin({ right: 10, bottom: 10 })
            .onClick(() => {
              this.selectedReason = reason;
            })
        })
      }

      // 自定义原因输入框
      TextArea({
        placeholder: '或者输入自定义原因...',
        text: this.selectedReason
      })
        .height(80)
        .backgroundColor('#F7F7F7')
        .onChange((value: string) => {
          this.selectedReason = value;
        })

      // 操作按钮
      Row({ space: 15 }) {
        Button('跳过')
          .layoutWeight(1)
          .backgroundColor('#F5F5F5')
          .fontColor('#333')
          .onClick(() => {
            // 用户选择跳过，传递一个默认原因
            this.onConfirm('未记录');
            this.controller.close();
          })

        Button('确认重置')
          .layoutWeight(1)
          .type(ButtonType.Capsule)
          .backgroundColor('#FF4444')
          .onClick(() => {
            // 确保原因不为空
            const reasonToConfirm = this.selectedReason.trim() === '' ? '未记录' : this.selectedReason;
            this.onConfirm(reasonToConfirm);
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
