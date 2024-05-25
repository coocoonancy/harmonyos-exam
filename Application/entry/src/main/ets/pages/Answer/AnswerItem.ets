import { AnswerItemModel } from '../../models/question'

@Preview
@Component
export default struct AnswerItem {
  @ObjectLink
  item: AnswerItemModel

  build() {
    Stack() {
      if (this.item.select) {
        Row()
          .width('100%')
          .height('100%')
          .linearGradient({ colors: [['#00bffa', 0], ['#0074f4', 1]] })
          .borderRadius(10)
      }
      Row() {
        Text() {
          Span(this.item.letter_text)
        }
        .fontColor(this.item.select ? $r('app.color.white') : $r('app.color.black'))
      }
      .width('100%')
      .height('100%')
      .padding(15)
    }
    .width('100%')
    .height(50)
    .backgroundColor($r('app.color.option_item_color'))
    .borderRadius(10)
  }
}