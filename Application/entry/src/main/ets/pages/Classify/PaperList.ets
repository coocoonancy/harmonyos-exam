import { AuthUser } from '@hw-agconnect/cloud';
import router from '@ohos.router'
import { Constants } from '../../common/index';
import { QuestionPaper } from '../../models';
import { CommonRouterParams } from '../../models/common';
import { QuestionPaperService } from '../../service/paper';
import PaperItem from './PaperItem';
import { AuthDefaultUser } from '@hw-agconnect/cloud/src/main/ets/auth/user/AuthDefaultUser';
import { QuestionUserAllService } from '../../service';


@Entry
@Component
struct PaperList {
  @StorageProp('user_auth_key')
  currentUser: AuthUser = new AuthDefaultUser()
  @State
  list: QuestionPaper[] = []

  aboutToAppear(): void {
    this.getPaperList()
  }

  async getPaperList() {
    const params = router.getParams() as CommonRouterParams
    if (params && params.classifyId) {
      this.list = await QuestionPaperService.getQuestionPaperList(params.classifyId)
    }
  }

  build() {
    Navigation() {
      Column() {
        Stack({ alignContent: Alignment.End }) {
          Image($r("app.media.ic_read"))
            .width(20)
            .aspectRatio(1)
        }
        .width('100%')
        .padding({
          top: 20,
          bottom: 20,
          left: 15,
          right: 15
        })

        List() {
          ForEach(this.list, (item: QuestionPaper) => {
            ListItem() {
              PaperItem({ item })
                .onClick(async () => {
                  const list = await QuestionUserAllService.getQuestionUserDetail(item.classify_id, item.id!, this.currentUser.getUid())
                  if (list.length) {
                    // 说明有结果了 不能做题了 直接去结果页看结果
                    router.pushUrl({
                      url: Constants.PAGE_ANSWER_RESULT,
                      params: {
                        classifyId: item.classify_id,
                        paperId: item.id
                      }
                    })
                  } else {
                    router.pushUrl({
                      url: Constants.PAGE_ANSWER_DETAIL,
                      params: {
                        classifyId: item.classify_id,
                        paperId: item.id
                      }
                    })
                  }

                })
            }
          })
        }
        .divider({
          strokeWidth: 1,
          startMargin: 15,
          endMargin: 15,
          color: $r("app.color.gray_full_color")
        })
        .layoutWeight(1)
        .width('100%')
        .borderRadius(30)
        .backgroundColor($r("app.color.white"))
      }
      .height('100%')
    }.titleMode(NavigationTitleMode.Mini)
    .title("习题列表")
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