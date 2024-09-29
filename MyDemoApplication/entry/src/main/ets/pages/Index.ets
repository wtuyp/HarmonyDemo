// 路由
import router from '@ohos.router';
import mediaQuery from '@ohos.mediaquery';
import window from '@ohos.window';
import common from '@ohos.app.ability.common';

// 网络请求
import http from '@ohos.net.http';

// 全局 @Styles 要加 function
@Styles function globalStyles() {
  .width(150)
  .height(50)
  .backgroundColor(Color.Pink)
}

// 可以定义 Text 的私有属性，这些是无法在 @Styles 中定义的
@Extend(Text) function extendTextStyles(fontSize: number, textAlign: TextAlign) {
  .textAlign(textAlign)
  .fontColor(Color.Green)
  .fontSize(fontSize)
}

// 全局 Builder，按引用传递参数，会引起方法内的UI刷新
@Builder function overBuilder($$: { paramA1: string }) {
  Row() {
    Text(`全局Builder引用传递参数: ${$$.paramA1} `)
  }
}

// 全局 Builder，按值传递参数，不会引起方法内的UI刷新
@Builder function overBuilderValue(paramA1: string) {
  Row() {
    Text(`全局Builder按值传递参数: ${paramA1} `)
  }
}


// LocalStorage 实例并初始化
let storage = new LocalStorage({ 'NumberKey': 47 });


@Entry(storage)
@Component
struct Index {
  @State message: string = 'Hello World'
  @State linkMessage: string = '我是父组件传给子组件的linkMessage'
  @State propMessage: string = '我是父组件传给子组件的propMessage'
  @State builderMessage: string = 'builderMessage'
  @Provide('helloComponentsTapCount') helloComponentsTapCount: number = 0 // 父组件与子孙组件Consume数据绑定
  @LocalStorageLink('NumberKey') indexStoreLink: number = 1
  @StorageLink('AppStorageNumberKey') @Watch('indexAppStoreLinkChanged') indexAppStoreLink: number = 1
  @StorageLink('PersistentStorageNumberKey') indexPersistentStoreLink: number = 26; // PersistentStorage 同步属性

  listener = mediaQuery.matchMediaSync('(orientation: landscape)')

  aboutToAppear() {
    this.listener.on('change', this.onPortrait.bind(this))

    this.appStorageDemo()
    this.persistentStorageDemo()
  }

  onPortrait(mediaQueryResult) {
    if (mediaQueryResult.matches) {
      this.message = 'Landscape'
    } else {
      this.message = 'Portrait'
    }
  }

  // LocalStorage 的应用
  localStorageDemo() {
    let storage = new LocalStorage({ 'PropA': 47 }); // 创建新实例并使用给定对象初始化
    let propA: string = storage.get('PropA') // propA == 47
    let link1 = storage.link('PropA'); // link1.get() == 47
    let link2 = storage.link('PropA'); // link2.get() == 47
    let prop = storage.prop('PropA'); // prop.get() = 47

    link1.set(48);  // 双向同步: link1.get() == link2.get() == prop.get() == 48
    prop.set(1);    // 单向同步: prop.get() = 1; 而 link1.get() == link2.get() == 48
    link2.set(49);  // 双向同步: link1.get() == link2.get() == prop.get() == 49
  }

  // AppStorage 的应用
  appStorageDemo() {
    // AppStorage 实例并初始化
    AppStorage.SetOrCreate('AppStorageNumberKey', 47);

    let num: number = AppStorage.Get('AppStorageNumberKey')
    let link1 = AppStorage.Link('AppStorageNumberKey')  // link1.get() == 47
    let link2 = AppStorage.Link('AppStorageNumberKey')  // link2.get() == 47
    let prop = AppStorage.Prop('AppStorageNumberKey')   // prop.get() == 47

    link1.set(48) // 双向同步: link1.get() == link2.get() == prop.get() == 48
    prop.set(1)   // 单向同步: prop.get() == 1; 而 link1.get() == link2.get() == 48
    link2.set(49) // 双向同步: link1.get() == link2.get() == prop.get() == 49

    AppStorage.Delete('AppStorageNumberKey')
    AppStorage.Clear()
  }

  // PersistentStorage 应用
  persistentStorageDemo() {
    // PersistentStorage 中的 Key 是和 AppStorage 共用的。
    // 请参考图1流程图 https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V2/arkts-persiststorage-0000001474017166-V2
    PersistentStorage.PersistProps([
      { key: 'PersistentStorageNumberKey', defaultValue: '0' },
      { key: 'Key', defaultValue: '1' }
    ]);

    PersistentStorage.PersistProp('aProp', 48);

    let keys: Array<string> = PersistentStorage.Keys()

    // 通过 AppStorage 获取
    let aProp = AppStorage.Get('aProp')

    AppStorage.SetOrCreate('aProp', 50)
    aProp = AppStorage.Get('aProp') // aProp == 50
  }

  // 改变设备横竖屏状态函数
  private changeOrientation(isLandscape: boolean) {
    // 获取UIAbility实例的上下文信息
    let context = getContext(this) as common.UIAbilityContext;
    // 调用该接口手动改变设备横竖屏状态
    window.getLastWindow(context).then((lastWindow) => {
      lastWindow.setPreferredOrientation(isLandscape ? window.Orientation.LANDSCAPE : window.Orientation.PORTRAIT)
    });
  }

  indexAppStoreLinkChanged() {
    console.info(`indexAppStoreLink: ${this.indexAppStoreLink}`)
  }

  // 组件内 Builder
  @Builder builderFunction($$: { paramA1: string }) {
    Row() {
      Text(`组件内Builder引用传递参数: ${$$.paramA1}`)
    }
  }

  @Builder builderFunctionValue(paramA1: string) {
    Row() {
      Text(`组件内Builder按值传递参数: ${paramA1}`)
    }
  }


  // @Styles仅支持通用属性和通用事件。组件内 @Styles 不用加 function
  @Styles textStyle() {
    .width('20%')
    .height(50)
  }

  build() {
    Row() {
      Column() {
        // HelloComponent 中有BuilderParam修饰，可以用尾随闭包传参。
        HelloComponent({ linkMessage: $linkMessage, propMessage: this.propMessage }) {
          Text('这是父组件给子组件的[Text]，你可以点我').fontColor(Color.Red)
        }

        Column({ space: 5 }) {
          Text(this.linkMessage)
          Text(this.propMessage)
          Text('@Provide helloComponentsTapCount: ' + this.helloComponentsTapCount)
          Text('@LocalStorageLink indexStoreLink: ' + this.indexStoreLink)
          Text('@StorageLink indexAppStoreLink: ' + this.indexAppStoreLink)
        }
        .onClick(() => {
          this.helloComponentsTapCount++
          this.indexStoreLink += 3
          this.indexAppStoreLink += 5
        })
        .backgroundColor('#ffffd0d0')
        .width('100%')
        .padding(10)

        Text(this.message)
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 10 })
        Button() {
          Text('Next')
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
        }
        .type(ButtonType.Capsule)
        .margin({
          top: 20
        })
        .globalStyles()
        .onClick(() => {
          console.info(`Succeeded in clicking the 'Next' button.`)

          this.message = 'Hello, ArkTs!'
          router.pushUrl({ url: 'pages/Second', params: { 'id': 123, info: 'info'} })
        })

        Stack({}) {
          Column() {
          }
          .width('90%')
          .height('100%')
          .backgroundColor('#ff58b87c')

          Text('text')
            .width('60%')
            .height('60%')
            .backgroundColor('#ffc3f6aa')
          Button('button')
            .width('30%')
            .height('30%')
            .backgroundColor('#ff8ff3eb')
            .fontColor('#000')
        }
        .width('100%')
        .height(150)
        .margin({ top: 10 })
        .alignContent(Alignment.Center)

        Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween }) {
          Text('1').textStyle().backgroundColor(0xF5DEB3).extendTextStyles(10, TextAlign.Start)
          Text('2').textStyle().backgroundColor(0xD2B48C).extendTextStyles(20, TextAlign.Center)
          Text('3').textStyle().backgroundColor(0xF5DEB3).extendTextStyles(30, TextAlign.End)
        }
        .height(70)
        .width('90%')
        .padding(10)
        .margin(10)
        .backgroundColor(0xAFEEEE)
        // .direction(FlexDirection.Row)

        // 组件外 Builder
        overBuilder({ paramA1: this.builderMessage })
        overBuilderValue(this.builderMessage)

        // 组件内 Builder
        this.builderFunction({ paramA1: this.builderMessage })
        this.builderFunctionValue(this.builderMessage)

        Button('Click me')
          .onClick(() => {
            this.builderMessage = 'ArkUI';
          })
          .margin({ top: 10 })
      }

      .width('100%')
    }
    .height('100%')
  }
}

@Component
struct HelloComponent {
  @State message: string = "Hello, I'm Hello Component!"
  @BuilderParam builder: () => void
  @Link linkMessage: string // 双向绑定，子组件更新回传给父组件
  @Prop propMessage: string // 单向传值，子组件更新不会回传给父组件
  @Consume('helloComponentsTapCount') tapCount: number
  @LocalStorageLink('NumberKey') helloStoreLink: number = 1;
  @StorageLink('AppStorageNumberKey') helloAppStoreLink: number = 1

  build() {
    Column({ space: 5 }) {
      Text(this.message)
      this.builder()
      Text(this.linkMessage)
      Text(this.propMessage)
    }
    .padding(10)
    .backgroundColor('#F4F4F4')
    .width('100%')
    .onClick(() => {
      this.message = '您好，我是Hello子组件!'
      this.linkMessage = '子组件更新了linkMessage'
      this.propMessage = '子组件更新了PropMessage'
      this.tapCount++
      this.helloStoreLink += 2
      this.helloAppStoreLink += 10
    })
  }
}