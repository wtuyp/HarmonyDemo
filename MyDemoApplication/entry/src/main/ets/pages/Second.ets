// Second.ets

import router from '@ohos.router';

@Entry
@Component
struct Second {
  @State message: string = 'Hi there'

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
        Button() {
          Text('Back')
            .fontSize(25)
            .fontWeight(FontWeight.Bold)
        }
        .type(ButtonType.Capsule)
        .margin({
          top: 20
        })
        .backgroundColor('#0D9FFB')
        .width('40%')
        .height('5%')
        .onClick(() => {
          console.info('back click')

          // router.back( { url: 'pages/Index'})
          router.back()
        })
      }
      .width('100%')
    }
    .height('100%')
  }

  // @Entry装饰的组件有 onPageShow, onPageHide, onBackPress
  // @Component装饰的组件有 aboutToAppear, onPageShow

  aboutToAppear() {
    console.info('aboutToAppear')
  }

  onPageShow() {
    console.info('onPageShow')
  }

  onBackPress() {
    console.info('onBackPress')
    return false
  }

  // 只有被@Entry装饰的组件才有onPageHide
  onPageHide() {
    console.info('onPageHide')
  }

  aboutToDisappear() {
    console.info('aboutToDisappear')
  }

}