import cloud, { Database, ObjectTypeInfo } from '@hw-agconnect/cloud'
import buffer from '@ohos.buffer';
import promptAction from '@ohos.promptAction';

export class CloudDataBase {
  // 云数据库实例
  static currentDataBase: Database | null

  // 获取云数据库

  static async getCloudDataBase() {
    if (!CloudDataBase.currentDataBase) {
      try {
        const context = getContext()
        const value = await context.resourceManager.getRawFileContent('schema.json');
        let json: string = buffer.from(value as ArrayBufferLike).toString("utf8");
        CloudDataBase.currentDataBase = cloud.database({
          objectTypeInfo: JSON.parse(json) as ObjectTypeInfo,
          zoneName: "question"
        })
      } catch (error) {
        promptAction.showToast({ message: error.message })
      }

    }
    return CloudDataBase.currentDataBase
  }
}