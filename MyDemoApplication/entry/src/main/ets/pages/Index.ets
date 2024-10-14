// 路由
import router from '@ohos.router';
import mediaQuery from '@ohos.mediaquery';
import window from '@ohos.window';
import common from '@ohos.app.ability.common';

// 网络请求
import http from '@ohos.net.http';

// 在全局定义时需在方法名前面添加 function 关键字，组件内定义时则不需要。

// @Styles 用于样式的重用，仅支持通用属性和通用事件。
// @Styles 方法不支持参数。
@Styles
function globalStyles() {
  .width(150)
  .height(50)
  .backgroundColor(Color.Pink)
}

// @Extend 定义扩展组件样式
// 和 @Styles 不同，@Extend 仅支持在全局定义，不支持在组件内部定义。
// 和 @Styles 不同，@Extend 支持封装指定组件的私有属性、私有事件和自身定义的全局方法。
// 和 @Styles 不同，@Extend 装饰的方法支持参数，开发者可以在调用时传递参数，调用遵循 TS 方法传值调用。
// @Extend 装饰的方法的参数可以为 function，作为 Event 事件的句柄。
// @Extend的 参数可以为状态变量，当状态变量改变时，UI可以正常的被刷新渲染。
@Extend(Text)
function textExtendStyles(fontSize: number, textAlign: TextAlign) {
  .textAlign(textAlign)
  .fontColor(Color.Green)
  .fontSize(fontSize)
}

// @Builder 通过按引用传递的方式传入参数，才会触发动态渲染UI，并且参数只能是一个。
// @Builder 传入的参数中同时包含按值传递和按引用传递两种方式，不会触发动态渲染UI。
class Tmp {
  paramA1: string = ''
}

@Builder
function overBuilderRef($$: Tmp) {
  Row() {
    Text(`全局Builder引用传递参数: ${$$.paramA1} `)
  }
}

// @Builder，按值传递参数，不会引起方法内的UI刷新
@Builder
function overBuilderValue(paramA1: string) {
  Row() {
    Text(`全局Builder按值传递参数: ${paramA1} `)
  }
}


// LocalStorage 是页面级的 UI 状态存储，通过 @Entry 装饰器接收的参数可以在页面内共享同一个 LocalStorage 实例。
// @LocalStorageProp 装饰的变量与 LocalStorage 中给定属性建立单向同步关系。
// @LocalStorageLink 装饰的变量与 LocalStorage 中给定属性建立双向同步关系。

// LocalStorage 实例并初始化
let storageParam: Record<string, number> = { 'NumberKey': 47 }
let storage = new LocalStorage(storageParam);

@Entry(storage)
@Component
struct Index {
  @State textHeight: number = 50
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

  onPortrait(mediaQueryResult: mediaQuery.MediaQueryResult) {
    if (mediaQueryResult.matches) {
      this.message = 'Landscape'
    } else {
      this.message = 'Portrait'
    }
  }

  // LocalStorage 的应用
  localStorageDemo() {
    let para: Record<string, number> = { 'PropA': 47 };
    let storage = new LocalStorage(para);                                   // 创建新实例并使用给定对象初始化
    let propA: string | undefined = storage.get('PropA')                    // propA == 47
    let link1: SubscribedAbstractProperty<number> = storage.link('PropA');  // link1.get() == 47
    let link2: SubscribedAbstractProperty<number> = storage.link('PropA');  // link2.get() == 47
    let prop: SubscribedAbstractProperty<number> = storage.prop('PropA');   // prop.get() = 47

    link1.set(48);  // 双向同步: link1.get() == link2.get() == prop.get() == 48
    prop.set(1);    // 单向同步: prop.get() = 1; 而 link1.get() == link2.get() == 48
    link2.set(49);  // 双向同步: link1.get() == link2.get() == prop.get() == 49
  }

  // AppStorage 应用全局的UI状态存储
  appStorageDemo() {
    // AppStorage 实例并初始化
    AppStorage.setOrCreate('AppStorageNumberKey', 47);

    let num: number | undefined = AppStorage.get('AppStorageNumberKey')
    let link1: SubscribedAbstractProperty<number> = AppStorage.link('AppStorageNumberKey')  // link1.get() == 47
    let link2: SubscribedAbstractProperty<number> = AppStorage.link('AppStorageNumberKey')  // link2.get() == 47
    let prop: SubscribedAbstractProperty<number> = AppStorage.prop('AppStorageNumberKey')   // prop.get() == 47

    link1.set(48) // 双向同步: link1.get() == link2.get() == prop.get() == 48
    prop.set(1)   // 单向同步: prop.get() == 1; 而 link1.get() == link2.get() == 48
    link2.set(49) // 双向同步: link1.get() == link2.get() == prop.get() == 49

    AppStorage.delete('AppStorageNumberKey')
    AppStorage.clear()
  }

  // PersistentStorage 应用
  persistentStorageDemo() {
    // PersistentStorage 中的 Key 是和 AppStorage 共用的。
    // 请参考图1流程图 https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V2/arkts-persiststorage-0000001474017166-V2
    PersistentStorage.persistProps([
      { key: 'PersistentStorageNumberKey', defaultValue: '0' },
      { key: 'Key', defaultValue: '1' }
    ]);

    PersistentStorage.persistProp('aProp', 48);

    let keys: Array<string> = PersistentStorage.keys()

    // 通过 AppStorage 获取
    let aProp : number | undefined = AppStorage.get('aProp')

    AppStorage.setOrCreate('aProp', 50)
    aProp = AppStorage.get('aProp') // aProp == 50
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
  @Builder
  builderFunctionRef($$: Tmp) {
    Row() {
      Text(`组件内Builder引用传递参数: ${$$.paramA1}`)
    }
  }

  @Builder
  builderFunctionValue(paramA1: string) {
    Row() {
      Text(`组件内Builder按值传递参数: ${paramA1}`)
    }
  }


  // 组件内的 @Styles 可以通过 this 访问组件的常量和状态变量，并可以在 @Styles 里通过事件来改变状态变量的值。
  // 组件内 @Styles 的优先级高于全局 @Styles。
  @Styles
  textStyle() {
    .width('20%')
    .height(this.textHeight)
    .onClick(() => {
      this.textHeight = 60
    })
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
          Text('1').textStyle().backgroundColor(0xF5DEB3).textExtendStyles(10, TextAlign.Start)
          Text('2').textStyle().backgroundColor(0xD2B48C).textExtendStyles(20, TextAlign.Center)
          Text('3').textStyle().backgroundColor(0xF5DEB3).textExtendStyles(30, TextAlign.End)
        }
        .height(70)
        .width('90%')
        .padding(10)
        .margin(10)
        .backgroundColor(0xAFEEEE)
        // .direction(FlexDirection.Row)

        // 组件外 Builder
        overBuilderRef({ paramA1: this.builderMessage })
        overBuilderValue(this.builderMessage)

        // 组件内 Builder
        this.builderFunctionRef({ paramA1: this.builderMessage })
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

  @Builder doNothingBuilder() {};
  @BuilderParam builder: () => void = this.doNothingBuilder
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