import { Constants } from '../../common/index';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import cloud, { VerifyCodeAction } from '@hw-agconnect/cloud';

@Extend(TextInput)
function commonStyle() {
  .width(280)
  .height(40)
  .backgroundColor('#F9F9F9')
  .placeholderColor($r("app.color.gray_light_color"))
  .fontColor($r("app.color.gray_color"))
}

@Extend(Button)
function commonButtonStyle() {
  .width(280)
  .height(48)
}

@Entry
@Component
struct Login {
  @State
  mobile: string = "18367194153"
  @State
  code: string = ""
  @State
  timeCount: number = 60
  timer: number = -1

  // 检查手机号合法
  checkMobile() {
    return !!(this.mobile && new RegExp('^1[3-9]\\d{9}$').test(this.mobile))
  }

  // 检查验证码合法性
  checkCode() {
    return !!(this.code && new RegExp('^\\d{6}$').test(this.code))
  }

  async sendCode() {
    if (this.timeCount < 60) return;
    await cloud.auth().requestVerifyCode({
      action: VerifyCodeAction.REGISTER_LOGIN,
      lang: 'zh_CN',
      sendInterval: 60,
      verifyCodeType: {
        countryCode: '86',
        phoneNumber: this.mobile,
        kind: 'phone'
      }
    })
    this.beginCount()
  }

  beginCount() {
    this.timer = setInterval(() => {
      if (this.timeCount === 0) {
        clearInterval(this.timer)
        this.timeCount = 60
        return
      }
      this.timeCount--
    }, 1000)
  }

  async login() {
    try {
      router.pushUrl({
        url: Constants.PAGE_INDEX
      })
    } catch (error) {
      promptAction.showToast({ message: error.message })
    }
  }

  build() {
    Row() {
      Column({ space: 24 }) {
        Image($r('app.media.ic_logo'))
          .margin({ top: 108 })
          .width(90)
          .aspectRatio(1)

        Text('欢迎使用鸿盟刷题')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)

        TextInput({ placeholder: '请输入手机号', text: this.mobile })
          .commonStyle()
          .height(48)
          .onChange((value) => {
            this.mobile = value;
          })

        Stack({ alignContent: Alignment.End }) {
          TextInput({ placeholder: '请输入验证码', text: this.code })
            .commonStyle()
            .height(48)
            .onChange((value) => {
              this.code = value;
            })
          Text(this.timeCount < 60 ? `${this.timeCount}秒` : '获取验证码')
            .fontSize(13)
            .fontColor($r("app.color.send_disable_color"))
            .margin({
              right: 10
            })
            .enabled(this.checkMobile() && this.timeCount === 60)
            .onClick(() => {
              this.sendCode()
            })
        }

        Button('登录')
          .enabled(true)
          .commonButtonStyle()
          .onClick(() => {
            this.login()
          })

      }
      .width('100%')
      .height('100%')
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