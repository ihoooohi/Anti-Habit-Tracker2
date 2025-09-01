// entry/src/main/ets/pages/EditProfilePage.ets
import common from '@ohos.app.ability.common';
import { eventBus } from '../util/eventBus';
import { EditProfileDialog } from '../view/EditProfileDialog';
import { profileStorage, ProfileInfo } from '../util/ProfileStorage';
import { ImagePicker } from '../util/ImagePicker';

@Entry
@Component
export struct EditProfilePage {
  // 分开 UI 显示 Resource 和存储 string
  @State avatarUri: string = 'default';
  @State nickname: string = '反习惯达人';
  @State signature: string = '日复一日，功不唐捐';

  @State currentEditField: 'nickname' | 'signature' | '' = '';
  @State inputValue: string = '';

  private context: common.UIAbilityContext | null = null;

  // 先声明 controller，不在初始化时引用自身
  private inputDialogController: CustomDialogController | null = null;

  // 增加事件回调引用
  private profileUpdatedCallback: (data: ProfileInfo) => void = () => {};

  aboutToAppear() {
    // 明确断言类型，避免隐式 any
    this.context = getContext(this) as common.UIAbilityContext;

    if (this.context) {
      profileStorage
        .loadProfile(this.context as common.UIAbilityContext)
        .then((profile: ProfileInfo) => { // <- 显式标注 ProfileInfo
          this.avatarUri = profile.avatarUri || 'default';
          this.nickname = profile.nickname;
          this.signature = profile.signature;
        })
        .catch((e: Error) => { // <- 显式标注 Error，避免隐式 any
          console.error('loadProfile error', e);
        });
    }

    // 延迟初始化弹窗 controller
    if (!this.inputDialogController) {
      this.inputDialogController = new CustomDialogController({
        builder: this.EditProfileDialogBuilder,
        autoCancel: true,
        alignment: DialogAlignment.Center
      });
    }

    // 订阅 profileUpdated 事件
    this.profileUpdatedCallback = (data: ProfileInfo) => {
      if (data.avatarUri !== undefined) this.avatarUri = data.avatarUri;
      if (data.nickname !== undefined) this.nickname = data.nickname;
      if (data.signature !== undefined) this.signature = data.signature;
    };
    eventBus.on('profileUpdated', this.profileUpdatedCallback);
  }

  // 取消订阅，避免内存泄漏
  aboutToDisappear() {
    eventBus.off('profileUpdated', this.profileUpdatedCallback);
  }

  private onEdit(field: 'nickname' | 'signature') {
    this.currentEditField = field;
    this.inputValue = field === 'nickname' ? this.nickname : this.signature; // 赋值给 inputValue
    this.inputDialogController?.open();
  }

  // 保存时写入存储并广播
  private async onConfirm(value: string) {
    if (!this.context) return;

    if (this.currentEditField === 'nickname') {
      this.nickname = value;
    } else if (this.currentEditField === 'signature') {
      this.signature = value;
    }

    // 保存 string 路径
    const profileToSave: ProfileInfo = {
      avatarUri: this.avatarUri, // 存储字符串
      nickname: this.nickname,
      signature: this.signature
    };

    try {
      await profileStorage.saveProfile(this.context as common.UIAbilityContext, profileToSave);
      eventBus.emit('profileUpdated', profileToSave);
    } catch (e) {
      console.error('saveProfile error', e as Error);
    }

    this.currentEditField = '';
    this.inputDialogController?.close();
  }


  @Builder
  private EditProfileDialogBuilder() {
    EditProfileDialog({
      controller: this.inputDialogController!,
      fieldName: this.currentEditField === 'nickname' ? '昵称' : '个性签名',
      initialValue: this.inputValue,
      onConfirm: (value: string): void => {
        void this.onConfirm(value);
      }
    });
  }


  @Builder
  private InfoRow(label: string, editable: boolean, field?: 'nickname' | 'signature') {
    Row({ space: 10 }) {
      Text(label).fontSize(16).fontColor('#333333').padding({ left: 15 });

      Text(field === 'nickname' ? this.nickname : this.signature)
        .fontSize(16)
        .fontColor('#666666')
        .padding({ right: 15 });
    }
    .width('90%')
    .height(60)
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .onClick(() => {
      if (editable && field) this.onEdit(field);
    });

    Divider().color('#E0E0E0').width('90%').margin({ left: '10%' });
  }

  // 点击头像，调用相册
  private async onChangeAvatar() {
    if (!this.context) return;

    const uri = await ImagePicker.pickImage(this.context);
    if (uri) {
      this.avatarUri = uri;

      const profileToSave: ProfileInfo = {
        avatarUri: this.avatarUri,
        nickname: this.nickname,
        signature: this.signature
      };

      try {
        await profileStorage.saveProfile(this.context, profileToSave);
        eventBus.emit('profileUpdated', profileToSave); // 同步更新到我的页面
      } catch (e) {
        console.error('save avatar error', e as Error);
      }
    }
  }


  build() {
    Column() {
      Text('个人资料').fontSize(24).fontWeight('bold').margin({ top: 20, bottom: 20 });

      Row({ space: 15 }) {
        Text("头像").fontSize(16).fontColor('#333333').padding({ left: 15 });
        Image(this.avatarUri && this.avatarUri !== 'default' ? this.avatarUri : $r('app.media.ic_default_avatar'))
          .width(70)
          .height(70)
          .borderRadius(8)
          .margin({ right: 15 })
          .border({ width: 2, color: '#FFFFFF' });
      }
      .width('90%')
      .height(100)
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor('#FFFFFF')
      .borderRadius(8)
      .onClick(() => {
        void this.onChangeAvatar(); // 调用相册
      });

      Divider().width('90%').color('#E0E0E0').margin({ left: '5%' });

      // 调用方式：传 field（InfoRow 内部会读取 this.nickname / this.signature）
      this.InfoRow('昵称', true, 'nickname');
      this.InfoRow('个性签名', true, 'signature');
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F3F5')
    .alignItems(HorizontalAlign.Center);
  }
}
