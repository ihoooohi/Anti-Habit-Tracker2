@CustomDialog
export struct EditProfileDialog {
  controller: CustomDialogController;

  fieldName: string = '';
  initialValue: string = '';
  onConfirm: (value: string) => void = () => {};

  @State inputValue: string = '';

  aboutToAppear() {
    this.inputValue = this.initialValue; // 确保弹窗打开时 inputValue 被初始化
  }

  build() {

    Column({ space: 15 }) {
      Text(`修改${this.fieldName}`)
        .fontSize(18)
        .fontWeight(FontWeight.Bold);

      TextInput({ placeholder: `请输入${this.fieldName}`, text: this.inputValue }) // 绑定 value
        .onChange((value: string) => {
          this.inputValue = value; // 更新状态
        })
        .fontSize(16)
        .width('100%')
        .height(40)
        .border({ width: 1, color: '#CCCCCC', radius: 5 })
        .padding({ left: 10, right: 10 });

      Row({ space: 12 }) {
        Button('取消')
          .layoutWeight(1)
          .backgroundColor('#EFEFEF')
          .fontColor(Color.Black)
          .onClick(() => this.controller.close());

        Button('确定')
          .layoutWeight(1)
          .type(ButtonType.Capsule)
          .backgroundColor('#FF6B35')
          .fontColor(Color.White)
          .onClick(() => {
            if (this.inputValue.trim() !== '') {
              this.onConfirm(this.inputValue.trim());
              this.controller.close();
            }
          });
      }.width('100%');
    }
    .width('80%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(15);
  }
}
