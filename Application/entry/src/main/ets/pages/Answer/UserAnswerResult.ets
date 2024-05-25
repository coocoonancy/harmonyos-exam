import { AuthDefaultUser } from '@hw-agconnect/cloud/src/main/ets/auth/user/AuthDefaultUser'
import { AuthUser } from '@hw-agconnect/cloud'
import { QuestionClassify, QuestionUserAll, QuestionUserAnswer } from '../../models'
import router from '@ohos.router'
import { CommonRouterParams } from '../../models/common'
import { QuestionClassifyService, QuestionUserAllService, QuestionUserAnswerService } from '../../service'
import { Constants } from '../../common'


@Entry
@Component
struct UserAnswerResult {
  @StorageProp('user_auth_key')
  currentUser: AuthUser = new AuthDefaultUser()
  @State
  allAnswer: QuestionUserAnswer[] = [] // 存储用户对于这个试卷的所有题目的答案
  @State
  questionUserAll: QuestionUserAll = new QuestionUserAll()
  @State
  questionClassify: QuestionClassify = new QuestionClassify()

  aboutToAppear(): void {
    this.getAllAnswer()
  }

  // 获取所有的答案
  async getAllAnswer() {
    const params = router.getParams() as CommonRouterParams
    if (params.classifyId && params.paperId) {
      const res = await QuestionClassifyService.getQuestionClassifyDetail(params.classifyId)
      if (res.length) {
        this.questionClassify = res[0]
      }
      const list =
        await QuestionUserAllService.getQuestionUserDetail(params.classifyId, params.paperId, this.currentUser.getUid())
      if (list.length) {
        this.questionUserAll = list[0] // 拿结果
      }
      // 拿到所有的答案
      this.allAnswer =
        await QuestionUserAnswerService.getAnswerList(params.classifyId, params.paperId, this.currentUser.getUid())
    }
  }

  getOptionColor(isRight: boolean): ResourceColor {
    if (isRight) {
      return $r("app.color.right_full_color")
    } else {
      return $r("app.color.error_full_color")
    }
  }

  getTimeRange() {
    if (this.allAnswer.length > 0) {
      return (((this.allAnswer[this.allAnswer.length- 1].answer_time).getTime() -
      (this.allAnswer[0].answer_time).getTime()) / (1000 * 60))
        .toFixed(0)
    }
    return ""
  }

  build() {
    Navigation() {
      Column() {
        Scroll() {
          Column() {
            // 得分
            Column() {
              Stack({ alignContent: Alignment.Bottom }) {
                Gauge({ value: this.questionUserAll.score, min: 0, max: 100 })
                  .startAngle(-90)
                  .endAngle(90)
                  .colors([[$r("app.color.blue_light_color"), this.questionUserAll.score],
                    [$r("app.color.gray_full_color"), 100 - this.questionUserAll.score]])
                  .strokeWidth(20)
                  .width(200)
                Column() {
                  this.smallText('得分')
                  Text(this.questionUserAll.score.toString())
                    .fontSize(35)
                    .fontWeight(900)
                  this.smallText('/100')
                  Row() {
                    this.smallText('练习类型:')
                    Text(this.questionClassify.title)
                      .fontSize(12)
                      .fontColor(Color.Gray)
                  }
                  .width('100%')
                  .padding({ top: 50, bottom: 10 })
                  .justifyContent(FlexAlign.SpaceBetween)

                  Row() {
                    this.smallText('交卷时间:')
                    Text(this.questionUserAll.end_time.toString())
                      .fontSize(12)
                      .fontColor(Color.Gray)
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.SpaceBetween)
                }
              }
            }
            .padding(20)
            .width('100%')
            .backgroundColor(Color.White)
            .borderRadius(10)
            .margin({
              top: 20
            })

            // 考试情况
            Column() {
              Text('考试情况')
                .width('100%')
                .fontWeight(600)
                .padding({ top: 20, bottom: 10 })
              Row() {
                this.examItem({
                  title: '总题数',
                  num: this.allAnswer.length.toString(),
                  unit: "题",
                  fontColor: $r("app.color.blue_light_color")
                })
                this.examItem({
                  title: '答对',
                  num: this.allAnswer.filter(item => item.is_right).length.toString(),
                  unit: '题',
                  fontColor: $r("app.color.right_full_color")
                })
                this.examItem({
                  title: '答错',
                  num: this.allAnswer.filter(item =>!item.is_right).length.toString(),
                  unit: '题',
                  fontColor: $r("app.color.error_full_color")
                })
                this.examItem({
                  title: '总用时',
                  num: this.getTimeRange(),
                  unit: 'min',
                  fontColor: $r("app.color.error_full_color")
                })
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
              .backgroundColor(Color.White)
              .padding(20)
              .borderRadius(10)
            }


            // 答题卡
            Column() {
              Text('答题卡')
                .width('100%')
                .fontWeight(600)
                .padding({ top: 30, bottom: 10 })
              Column() {
                Row({ space: 15 }) {
                  Text('题目')
                    .layoutWeight(1)
                    .fontSize(14)
                  Row({ space: 8 }) {
                    Text()
                      .size({ width: 12, height: 12 })
                      .borderRadius(8)
                      .backgroundColor($r("app.color.gray_full_color"))
                    Text('未答')
                      .fontSize(12)
                  }

                  Row({ space: 8 }) {
                    Text()
                      .size({ width: 12, height: 12 })
                      .borderRadius(8)
                      .backgroundColor($r("app.color.right_full_color"))
                    Text('答对')
                      .fontSize(12)
                  }

                  Row({ space: 8 }) {
                    Text()
                      .size({ width: 12, height: 12 })
                      .borderRadius(8)
                      .backgroundColor($r("app.color.error_full_color"))
                    Text('答错')
                      .fontSize(12)
                  }
                }
                .width('100%')
                .padding(15)

                // 答题卡选项
                Flex({ wrap: FlexWrap.Wrap }) {
                  ForEach(this.allAnswer, (item: QuestionUserAnswer, index: number) => {
                    Row() {
                      Text((index + 1).toString())
                        .textAlign(TextAlign.Center)
                        .fontColor(Color.White)
                        .size({ width: 40, height: 40 })
                        .borderRadius(20)
                        .backgroundColor(this.getOptionColor(item.is_right))
                    }
                    .justifyContent(FlexAlign.Center)
                    .width('20%')
                    .aspectRatio(1)
                    .onClick(() => {
                      router.pushUrl({
                        url: Constants.PAGE_ANSWER_DETAIL,
                        params: {
                          classifyId: item.classify_id,
                          paperId: item.paper_id,
                          questionId: item.question_info_id
                        }
                      })
                    })
                  })
                }
              }
              .backgroundColor(Color.White)
              .borderRadius(10)
            }
          }
          .padding({ left: 15, right: 15, bottom: 50 })
          .width('100%')

        }
        .layoutWeight(1)

        Row() {
          Button("重新刷题")
            .width('60%')
            .onClick(async () => {
              // 删除用户结果
              await QuestionUserAllService.delQuestionQuestionUserAll(this.questionUserAll)
              await QuestionUserAnswerService.delAllAnswer(this.allAnswer) // 删除所有答案
              router.replaceUrl({
                url: Constants.PAGE_ANSWER_DETAIL,
                params: router.getParams() // 分类id还有试卷ID
              })
            })
            .backgroundColor($r("app.color.send_code_color"))
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')
        .height(70)
        .backgroundColor($r("app.color.white"))
      }
      .height('100%')
    }
    .titleMode(NavigationTitleMode.Mini)
    .title("答题结果")
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

  @Builder
  examItem(item: AnswerResult) {
    Column({ space: 15 }) {
      Text(item.title)
        .fontSize(13)
      Text() {
        Span(item.num.toString())
          .fontSize(16)
          .fontColor(item.fontColor)
        Span(item.unit)
          .fontColor(item.fontColor)
          .fontSize(12)
      }
    }
  }

  @Builder
  smallText(text: string, fontSize: number = 12) {
    Text(text)
      .fontSize(fontSize)
      .fontColor(Color.Gray)
  }
}

interface AnswerResult {
  title: string
  num: string
  unit: string
  fontColor: ResourceColor
}