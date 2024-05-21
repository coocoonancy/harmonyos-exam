import { Constants } from '../../common'
import router from '@ohos.router';
import picker from '@ohos.file.picker'

interface ICardItem {
  leftTitle: string
  rightValue: string,
  showArrow?: boolean,
  onClick?: () => void
}
@Entry
@Component
export struct UserCenter {
  @State
  showSheet: boolean = false



  @Builder
  getCardItem(item: ICardItem) {
    Row() {
      Text(item.leftTitle)
        .fontSize(14)
        .fontColor($r("app.color.text_second_color"))
        .height(44)

      Row({ space: 6 }) {
        if (item.showArrow) {
          Image($r('app.media.ic_right'))
            .width(16)
            .height(16)
            .fillColor($r("app.color.gray_color"))
        }
        if (item.rightValue) {
          Text(item.rightValue)
            .fontSize(14)
            .fontColor($r("app.color.text_second_color"))
        }
      }.height(44)
    }
    .onClick(() => {
      item.onClick && item.onClick()
    })
    .padding({
      left: 20,
      right: 20
    })
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .backgroundColor($r("app.color.white"))
  }

  @Builder
  getShowResult(item: ICardItem) {
    Column() {
      Text(item.leftTitle)
        .fontSize(10)
        .fontColor($r("app.color.gray_color"))
        .margin({ top: 10 })
      Text(item.rightValue)
        .fontWeight(400)
        .padding({ top: 5 })
    }
  }

  @Builder
  getSheetContent() {
    Column({ space: 20 }) {
      TextInput({
        text: "",
        placeholder: '请输入您的昵称'
      })
        .width('100%')
      Button("修改昵称")
        .backgroundColor($r("app.color.blue_light_color"))
        .width("100%")

    }
    .height('100%')
    .padding(20)
  }
  async selectImg() {
    let selectPhoto = new picker.PhotoViewPicker()
      await selectPhoto.select({
      maxSelectNumber: 1,
      MIMEType: picker.PhotoViewMIMETypes.IMAGE_TYPE
    })
  }
  build() {
    Row() {
      Column({ space: 20 }) {
        // 用户昵称和头像部分
        Row() {
          Row() {
            // 头像+昵称
            Column() {
              Image($r('app.media.user_dark'))
                .width(64)
                .aspectRatio(1)
                .borderRadius(32)
                .interpolation(ImageInterpolation.High)//减轻低清晰度图片在放大显示时出现的锯齿问题
                .onClick(() => {
                  this.selectImg()
                })
              Text("未命名")
                .fontSize(16)
                .fontWeight(400)
                .fontColor($r("app.color.text_main_color"))
                .margin({ top: 12 })
                .onClick(() => {
                  this.showSheet = true
                })

            }
            .translate({
              y: -32
            })

            Row({ space: 35 }) {
              this.getShowResult({ leftTitle: '已刷题数(道)', rightValue: '40' })
              this.getShowResult({ leftTitle: '错题数量(道)', rightValue: '40' })
            }
            .justifyContent(FlexAlign.End)
            .layoutWeight(1)
          }.height(80)
          .backgroundColor($r("app.color.white"))
          .borderRadius(8)
          .padding({
            left: 20,
            right: 20
          })
        }
        .width('100%')
        .padding({
          left: 20,
          right: 20
        })
        .margin({
          top: 100
        })

        // 手机号码，上次登录时间部分
        Column() {
          Column() {
            this.getCardItem({ leftTitle: '手机号码', rightValue: "13812345678" })
            this.getCardItem({ leftTitle: '上次登录时间', rightValue: "2024-05-01 12:23" })
          }
          .borderRadius(8)
          .clip(true)
        }
        .width("100%")
        .padding({
          left: 20,
          right: 20
        })

        // 手机号码，上次登录时间部分
        Column() {
          Column() {
            this.getCardItem({
              leftTitle: '登出', rightValue: '', showArrow: true,
              onClick: () => {
                router.replaceUrl({
                  url: Constants.PAGE_LOGIN
                })
              }
            })
          }
          .clip(true)
          .borderRadius(8)
        }
        .width("100%")
        .padding({
          left: 20,
          right: 20
        })
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
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
    .bindSheet($$this.showSheet, this.getSheetContent, {
      height: '40%'
    })
  }
}