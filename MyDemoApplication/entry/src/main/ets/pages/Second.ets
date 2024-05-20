// Second.ets

import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

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

          this.onBackClick()
        })
      }
      .width('100%')
    }
    .height('100%')
  }

  // @Entry装饰的组件有 onPageShow, onPageHide, onBackPress
  // @Component装饰的组件有 aboutToAppear, onPageShow

  // 在build()函数之前执行
  aboutToAppear() {
    console.info('aboutToAppear')
  }

  onPageShow() {
    console.info('onPageShow')

    // 获取 router 传递过来的参数对象
    const params = router.getParams()
    console.info(`id: ${params["id"]}, info: ${params["info"]}`)
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

  onBackClick() {
    // router.back( { url: 'pages/Index'})

    // 返回前给个提示
    // router.showAlertBeforeBackPage({
    //   message: '您还没有完成支付，确定要返回吗？'
    // });
    //
    // router.back()

    // 弹出自定义的询问框
    promptAction.showDialog({
      message: '您还没有完成支付，确定要返回吗？',
      buttons: [
        {
          text: '取消',
          color: '#FF0000'
        },
        {
          text: '确认',
          color: '#0099FF'
        }
      ]
    }).then((result) => {
      if (result.index === 0) {
        // 用户点击了“取消”按钮
        console.info('User canceled the operation.');
      } else if (result.index === 1) {
        // 用户点击了“确认”按钮
        console.info('User confirmed the operation.');
        // 调用router.back()方法，返回上一个页面
        router.back();
      }
    }).catch((err) => {
      console.error(`Invoke showDialog failed, code is ${err.code}, message is ${err.message}`);
    })
  }

}