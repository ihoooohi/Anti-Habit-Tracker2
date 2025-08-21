// entry/src/main/ets/view/AddHabitDialog.ets

@CustomDialog
export struct AddHabitDialog {
  // controller 是由 CustomDialogController 自动注入的，我们只需要声明它
  // 让它能够调用 close 方法即可
  controller: CustomDialogController;
  // 这个回调函数由父组件传递
  onConfirm: (name: string) => void = () => {};

  // 自己的状态变量
  @State habitName: string = '';

  // 不再需要显式定义 constructor

  build() {
    Column({ space: 20 }) {
      Text('添加一个新习惯')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)

      TextInput({ placeholder: '例如：不吃夜宵' })
        .onChange((value) => {
          this.habitName = value;
        })

      Row({ space: 12 }) {
        Button('取消')
          .onClick(() => {
            this.controller.close(); // 正确关闭弹窗
          })
          .layoutWeight(1)
          .backgroundColor('#EFEFEF')
          .fontColor(Color.Black)

        Button('确定')
          .onClick(() => {
            if (this.habitName.trim() !== '') {
              // 调用父组件传来的 onConfirm 函数
              this.onConfirm(this.habitName.trim());
              this.controller.close();
            }
          })
          .layoutWeight(1)
      }
    }
    .width('80%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(15)
  }
}