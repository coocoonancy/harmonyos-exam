import { CloudDataBase } from '.'
import { QuestionClassify } from '../models'

export class QuestionClassifyService {
  // 获取大类
  static async getQuestionClassify() {
    const database = await CloudDataBase.getCloudDataBase()
    return database!.collection<QuestionClassify>(QuestionClassify)
      .query()
      .orderByAsc("id")
      .get()
  }

  // 获取数据分类详细的id
  static async getQuestionClassifyDetail(classifyId: number) {
    const database = await CloudDataBase.getCloudDataBase()
    return database!.collection<QuestionClassify>(QuestionClassify).query()
      .equalTo("is_del", false)
      .equalTo("id", classifyId)
      .get()
  }
}