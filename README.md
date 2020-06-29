# InputModifier - Keyboard and input view modifier for swiftUI

Copy the [InputModifier.swift](https://raw.githubusercontent.com/richieshilton/InputModifier/master/InputModifier.swift) file into your project and start using it.

View Example Usage (simply add `.keyboardPadding()`)
```
var body: some View {
  List {
    TextField("Search here", text: $searchText)
    ForEach( ...
    ...
  }.keyboardPadding()
}
```

Inspired and assisted by patrickbdev's [InputLayoutGuide](https://github.com/patrickbdev/InputLayoutGuide)
