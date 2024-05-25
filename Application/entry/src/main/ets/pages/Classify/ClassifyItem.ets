import { QuestionClassify } from '../../models'

@Component
export struct ClassifyItem {
  item: QuestionClassify = new QuestionClassify()

  build() {
    Flex() {
      Image(this.item.image_url || $r('app.media.ic_cover1'))
        .alignSelf(ItemAlign.Center)
        .height(80)
        .width(60)
        .borderRadius(10)

      Column() {
        Column() {
          Text(this.item.title)
            .fontSize(14)
            .fontWeight(500)
            .textAlign(TextAlign.Start)
        }
        .alignSelf(ItemAlign.Start)
        .margin({ left: 10, top: 8 })

        Row() {
          Text('0')
            .fontColor('#3266EE')
            .fontSize(12)
            .fontWeight(400)
          Text(`/${this.item.num}节 | 已学进度：10%`)
            .fontColor($r("app.color.gray_color"))
            .fontSize(12)
            .fontWeight(400)
        }
        .width(137)
        .alignSelf(ItemAlign.Start)
        .margin({ top: 24, left: 10 })

        Divider()
          .alignSelf(ItemAlign.Start)
          .margin({ left: 10, top: 6 })
      }
    }
    .height(96)
    .backgroundColor(Color.White)
    .borderRadius(9)
    .padding(10)

  }
}