import { ClassifyItem } from './ClassifyItem' //练习列表项组件
import router from '@ohos.router'
import { Constants } from '../../common'
import { QuestionClassify } from '../../models'
import { QuestionClassifyService } from '../../service'

@Entry
@Component
export struct ClassifyList {
  @State
  classifyList: QuestionClassify[] = []

  aboutToAppear(): void {
    this.getQuestionClassify()
  }

  async getQuestionClassify() {
    this.classifyList = await QuestionClassifyService.getQuestionClassify()
  }

  build() {
    Row() {
      List({ space: 15 }) {
        ForEach(this.classifyList, (item: QuestionClassify) => {
          ClassifyItem({ item })
            .onClick(() => {
              router.pushUrl({
                url: Constants.PAGE_PAPER_LIST, params: {
                  classifyId: item.id // 大类 -> 试卷 携带 大类的id 用来获取哪个大类的试卷
                }
              })
            })
        })
      }
      .width('100%')
      .height('100%')
      .padding(15)
    }
    .height('100%')
    .padding({
      top: AppStorage.get("topHeight"),
      bottom: AppStorage.get("bottomHeight")
    })
    .linearGradient({
      colors: [
        ['#ccdffc', 0],
        [$r("app.color.gray_light_color"), 1]
      ]
    })
  }
}