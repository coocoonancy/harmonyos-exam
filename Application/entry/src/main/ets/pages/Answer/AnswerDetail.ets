import AnswerItem from './AnswerItem'
import router from '@ohos.router'
import { Constants } from '../../common'
import { QuestionInfoService } from '../../service/question_info'
import { CommonRouterParams } from '../../models/common'
import { AnswerItemModel, QuestionInfo, QuestionTypeEnum, QuestionUserAll, QuestionUserAnswer } from '../../models'
import { QuestionUserAnswerService } from '../../service/question_user_answer'
import { AuthUser } from '@hw-agconnect/cloud'
import { AuthDefaultUser } from '@hw-agconnect/cloud/src/main/ets/auth/user/AuthDefaultUser'
import { QuestionUserAllService } from '../../service/question_user_all'
import promptAction from '@ohos.promptAction'
import emitter from '@ohos.events.emitter'

@Entry
@Component
struct AnswerDetail {
  @State
  showSubmit: boolean = false // 控制交卷按钮
  @State
  currentIndex: number = 0 // 当前在做题目
  @State
  isReadOnly: boolean = false // 是否只读状态
  @State
  list: QuestionInfo[] = []
  @State
  currentOptions: AnswerItemModel[] = [] // 当前题目的选项
  @State
  allAnswer: QuestionUserAnswer[] = [] // 存储用户对于这个试卷的所有题目的答案
  @StorageProp('user_auth_key')
  currentUser: AuthUser = new AuthDefaultUser()
  @State
  userAnswer: QuestionUserAnswer = new QuestionUserAnswer() // 用来入库的对象

  // 交卷
  async submitPaper() {
    // 写入结构
    const params = router.getParams() as CommonRouterParams
    if (params.classifyId && params.paperId) {
      const userResult = new QuestionUserAll()
      userResult.classify_id = params.classifyId
      userResult.paper_id = params.paperId
      userResult.user_id = this.currentUser.getUid()
      userResult.start_time = this.allAnswer[0].answer_time
      userResult.end_time = new Date()
      userResult.is_done = true // 是否做完了
      userResult.score =
        parseFloat(((this.allAnswer.filter(item => item.is_right).length / this.list.length) * 100).toFixed(2))

      await QuestionUserAllService.upsertQuestionUserAll(userResult)
      promptAction.showToast({ message: '交卷成功' })
      // emitter.emit("updateTop")
      //  this.allAnswer // 所有的答案
      router.replaceUrl({
        url: Constants.PAGE_ANSWER_RESULT,
        params
      })
    }


  }

  aboutToAppear(): void {
    this.getQuestionList()
  }

  // 获取所有的答案
  async getAllAnswer() {
    const params = router.getParams() as CommonRouterParams
    if (params.classifyId && params.paperId) {
      // 拿到所有的答案
      this.allAnswer =
        await QuestionUserAnswerService.getAnswerList(params.classifyId, params.paperId, this.currentUser.getUid())
      await this.initCurrentAnswer() // 初始化答案
    }
  }

  // 初始化当前问题的选项 目的是 当选择完毕之后 直接去入库
  initCurrentAnswer() {
    const params = router.getParams() as CommonRouterParams
    if (params.classifyId && params.paperId) {
      this.userAnswer = new QuestionUserAnswer() // 每次初始化时 重新new一下
      this.userAnswer.classify_id = params.classifyId // 大类id
      this.userAnswer.paper_id = params.paperId // 试卷id
      this.userAnswer.question_info_id = this.getCurrentQuestion()!.id! // 当前题目的id
      this.userAnswer.user_id = this.currentUser.getUid() // 用户id
      // 此时还需要从答案中找出 我是否已经入库了答案 如果入库了 把答案反选上去
      if (this.allAnswer.length) {
        const item = this.allAnswer.find(item => item.question_info_id === this.userAnswer.question_info_id)
        // 找答案 如果能够找到
        if (item) {
          this.userAnswer = item // 直接赋值item
          // 入库就是更新
          const res = JSON.parse(item.user_answer) as string[] // 用户的答案 还是数组 "['A', 'B']"
          res.forEach(letter => {
            this.currentOptions.find(item => item.letter === letter)!.select = true
          })
        }
        // 如果找不到 入库就是新增

      }

    }

  }

  // 获取当前选项的一个方法
  getCurrentOptions() {
    // 拿当前题目
    const question = this.getCurrentQuestion()
    if (question) {
      this.currentOptions = [] // 先设置为空
      const labelList = JSON.parse(question.answer_text) as string[]
      const letterList = JSON.parse(question.answer_letter) as string[]
      labelList.forEach((item: string, index: number) => {
        this.currentOptions.push(new AnswerItemModel({
          letter: letterList[index],
          letter_text: labelList[index],
          select: false
        }))
      })
    }
  }

  // 获取题目的列表
  async getQuestionList() {
    const params = router.getParams() as CommonRouterParams
    if (params.classifyId && params.paperId) {
      this.list = await QuestionInfoService.getQuestionList(params.classifyId, params.paperId)
      this.getCurrentOptions()
      this.getAllAnswer() // 获取所有答案
      this.checkCanSubmit() // 检查是否可卷
    }
  }

  // 获取当前正在做的题目
  getCurrentQuestion() {
    if (this.list.length && this.currentIndex > -1 && this.currentIndex < this.list.length) {
      return this.list[this.currentIndex]
    }
    return null
  }

  lastQuestion() {
    if (this.getLastEnable()) {
      this.currentIndex--
      this.getCurrentOptions()
      this.initCurrentAnswer()
    }

  }

  // 上一题是否可点
  getLastEnable() {
    return this.currentIndex > 0
  }

  // 下一题是否可点
  getNextEnable() {
    return this.currentIndex < this.list.length - 1
  }

  nextQuestion() {
    if (this.getNextEnable()) {
      this.currentIndex++
      this.getCurrentOptions()
      this.initCurrentAnswer() // 初始化的每道题的选项
    }
  }

  // 根据类型显示不同的题目
  getQuestionTypeText() {
    const question = this.getCurrentQuestion()
    if (question) {
      switch (question.question_type) {
        case QuestionTypeEnum.Judge:
          return "判断"
        case QuestionTypeEnum.Single:
          return "单选"
        case QuestionTypeEnum.Multi:
          return "多选"
      }
    }
    return ""
  }

  // 根据不同的题目类型进行不同的互斥处理
  async selectAnswer(item: AnswerItemModel) {
    const question = this.getCurrentQuestion()
    if (question) {
      // 单选和判断场景下 有互斥
      if (question.question_type === QuestionTypeEnum.Judge || question.question_type === QuestionTypeEnum.Single) {
        // 互斥处理
        // 根据当前选中状态来判断
        if (!item.select) {
          // 这种情况下需要互斥
          this.currentOptions.forEach(obj => {
            obj.select = false // 全部关闭
          })
          item.select = true // 只让当前点击的选中
        }
      } else {
        item.select = !item.select // 该怎么样还怎么样
      }
    }
    // 主要选择完了答案 不论选择的对不对 都要去检查能不能入库
    await this.writeUserAnswer()
    await this.getAllAnswer() // 重新获取一下所有的答案
    this.checkCanSubmit() // 检查可交卷
  }

  // 入库
  async writeUserAnswer() {
    // 当前的选项都得至少有一个选项被选中才可以入库
    const values = this.currentOptions.filter(item => item.select === true) // 拿到当前选项为true的集合
    if (values.length) {
      try {
        // 可以提交了
        const question = this.getCurrentQuestion()
        this.userAnswer.user_answer = JSON.stringify(values.map(item => item.letter).sort()) // 答案是什么 ["A"]
        this.userAnswer.answer_time = new Date() // 回答时间
        this.userAnswer.is_right = question?.right_answer_letter === this.userAnswer.user_answer // 这个题答没答对
        // 自己的答案和题目的答案进行一下对比
        await QuestionUserAnswerService.upsertQuestionAnswer(this.userAnswer) // 答案入库
      } catch (error) {
        AlertDialog.show({ message: "答案写入异常," + error.message })
      }

    }
  }

  // 检查是否可交卷
  async checkCanSubmit() {
    const params = router.getParams() as CommonRouterParams
    if (params.classifyId && params.paperId) {
      this.showSubmit =
        await QuestionUserAnswerService.getIsAllAnswer(params.classifyId, params.paperId, this.currentUser.getUid())
    }
  }

  build() {
    Navigation() {
      Column() {
        Column() {
          // 进度条
          Row() {
            Progress({ value: (this.currentIndex + 1), total: 10 })
              .margin({ right: 10 })
              .layoutWeight(1)
            Text() {
              Span((this.currentIndex + 1).toString())
                .fontWeight(900)
                .fontColor(Color.Gray)
              Span(`/${this.list.length}`)
                .fontWeight(900)
                .fontColor('#c4c4c4')
            }
          }
          .height(50)
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Center)

          if (this.getCurrentQuestion()) {
            // 如果当前题目不为空的情况下 才渲染题目
            // 题目类型
            Row() {
              Text(this.getQuestionTypeText())
                .fontSize(12)
                .fontColor(Color.Gray)
                .padding({
                  top: 2,
                  bottom: 2,
                  left: 10,
                  right: 10
                })
                .backgroundColor(Color.White)
            }
            .width('100%')

            // 题目内容
            Column({ space: 16 }) {
              Text(`${this.currentIndex + 1}. ${this.getCurrentQuestion()?.title}`)
                .width('100%')
              Column({ space: 8 }) {
                ForEach(this.currentOptions, (item: AnswerItemModel) => {
                  // 槽点 如果子组件的类型是ObjectLink 那么不能使用es6的省略属性写法
                  AnswerItem({ item: item })
                    .onClick(() => {
                      // item.select = !item.select
                      this.selectAnswer(item) // 选择某个题目
                    })
                }, (item: AnswerItemModel, index: number) => this.getCurrentQuestion()!.id + "_" + index + "_" +
                JSON.stringify(item))
                // ForEach中key的作用
                // index_+JSON.stringify(item)
              }
            }
            .width('100%')
            .margin({ top: 10 })

            if (this.isReadOnly) {
              Column({ space: 10 }) {
                // 显示答案
                Text("答案")
                  .fontColor($r("app.color.text_main_color"))
                  .width('100%')

                Row({ space: 20 }) {
                  Row({ space: 2 }) {
                    Text("正确答案: ")
                      .fontColor($r("app.color.text_main_color"))
                    Text("A")
                      .fontColor($r("app.color.right_full_color"))
                  }

                  Row({ space: 2 }) {
                    Text("您的答案: ")
                      .fontColor($r("app.color.text_main_color"))
                    Text("B")
                      .fontColor($r("app.color.error_full_color"))
                  }
                }
                .width('100%')

                Text("解析: ")
                  .fontColor($r("app.color.text_main_color"))
                  .width('100%')
                Row({ space: 2 }) {
                  Text("B")
                    .fontColor($r("app.color.right_full_color"))
                }
                .width('100%')
              }
              .width('100%')
              .padding(10)
              .margin({
                top: 50
              })
            }
          }


          Blank()
          // 交卷按钮
          Row() {
            Row() {
              Image($r('app.media.ic_left'))
                .fillColor(this.getLastEnable() ? $r("app.color.text_main_color") : $r("app.color.gray_color"))
                .width(18)
                .aspectRatio(1)
                .margin({ right: 15 })
              Text('上一题')
                .fontColor(this.getLastEnable() ? $r("app.color.text_main_color") : $r("app.color.gray_color"))

            }
            .layoutWeight(1)
            .onClick(() => {
              this.lastQuestion()
            })


            Row() {
              Text('下一题')
                .fontColor(this.getNextEnable() ? $r("app.color.text_main_color") : $r("app.color.gray_color"))
                .margin({ right: 15 })

              Image($r('app.media.ic_right'))
                .fillColor(this.getNextEnable() ? $r("app.color.text_main_color") : $r("app.color.gray_color"))
                .width(18)
                .aspectRatio(1)
            }
            .justifyContent(FlexAlign.End)
            .layoutWeight(1)
            .onClick(() => {
              this.nextQuestion()
            })

          }
          .height(50)
          .width('100%')

          if (this.showSubmit && !this.isReadOnly) {
            Row() {
              Button("交卷查看结果", {
                type: ButtonType.Normal
              })
                .borderRadius(48)
                .width(200)
                .height(48)
                .backgroundColor($r("app.color.send_code_color"))
                .onClick(() => {
                  this.submitPaper()
                })
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .margin({
              top: 20
            })
          }
        }
        .padding({ left: 15, right: 15 })
        .backgroundColor($r("app.color.white"))
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r("app.color.white"))
    }
    .titleMode(NavigationTitleMode.Mini)
    .title("在线模拟")
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