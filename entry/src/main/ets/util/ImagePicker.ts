import picker from '@ohos.file.picker';
import common from '@ohos.app.ability.common';

export class ImagePicker {
  static async pickImage(context: common.UIAbilityContext): Promise<string | null> {
    try {
      const photoPicker = new picker.PhotoViewPicker();
      const result = await photoPicker.select({
        MIMEType: picker.PhotoViewMIMETypes.IMAGE_TYPE, // 仅图片
        maxSelectNumber: 1
      });

      if (result && result.photoUris && result.photoUris.length > 0) {
        console.info('Image selected: ' + result.photoUris[0]);
        return result.photoUris[0]; // 返回图片本地路径
      }
      return null;
    } catch (err) {
      console.error('pickImage error', JSON.stringify(err));
      return null;
    }
  }
}
