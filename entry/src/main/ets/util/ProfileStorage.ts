// entry/src/main/ets/util/ProfileStorage.ts
import preferences from '@ohos.data.preferences';

const PREFERENCES_NAME = 'profile_store';
const PROFILE_KEY = 'profile_info_key';

export interface ProfileInfo {
  avatarUri: string;
  nickname: string;
  signature: string;
}

class ProfileStorage {
  private pref: preferences.Preferences | null = null;

  private async getPreferences(context): Promise<preferences.Preferences> {
    if (this.pref !== null) return this.pref;
    this.pref = await preferences.getPreferences(context, PREFERENCES_NAME);
    return this.pref;
  }

  /** 保存个人资料 */
  async saveProfile(context, profile: ProfileInfo): Promise<void> {
    try {
      const prefs = await this.getPreferences(context);
      await prefs.put(PROFILE_KEY, JSON.stringify(profile));
      await prefs.flush();
      console.info('Profile saved successfully.');
    } catch (e) {
      console.error('Failed to save profile.', JSON.stringify(e));
    }
  }

  /** 加载个人资料，如果没有则返回空字符串，页面决定默认头像 */
  async loadProfile(context): Promise<ProfileInfo> {
    try {
      const prefs = await this.getPreferences(context);
      const profileJson = await prefs.get(PROFILE_KEY, '') as string;

      if (!profileJson) {
        return {
          avatarUri: '', // 空值由页面处理默认头像
          nickname: '反习惯达人',
          signature: '日复一日，功不唐捐'
        };
      }

      const profile = JSON.parse(profileJson) as ProfileInfo;
      if (!profile.avatarUri) profile.avatarUri = ''; // 空值由页面处理
      return profile;
    } catch (e) {
      console.error('Failed to load profile.', JSON.stringify(e));
      return {
        avatarUri: '',
        nickname: '反习惯达人',
        signature: '日复一日，功不唐捐'
      };
    }
  }
}

export const profileStorage = new ProfileStorage();
