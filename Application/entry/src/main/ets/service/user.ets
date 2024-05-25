import { UserInfo } from '../models';
import { CloudDataBase } from './common';

export class UserServices {
  static async updateUserInfo(user: UserInfo) {
    const dataBase = await CloudDataBase.getCloudDataBase()
    const result = dataBase!.collection<UserInfo>(UserInfo)
      .upsert(user)
    return result
  }

  static async getUserInfoByUserId(userId: string) {
    const dataBase = await CloudDataBase.getCloudDataBase()
    const result = dataBase!.collection<UserInfo>(UserInfo)
      .query()
      .limit(1)
      .equalTo("user_id", userId)
      .get()
    return result
  }
}