
// CustomBtn.ets

@Component
struct CustomBtn {
  @Link showText: string

  build() {
    Row() {
      Column() {
        Text(this.showText)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
    }
    .height('100%')
  }
}