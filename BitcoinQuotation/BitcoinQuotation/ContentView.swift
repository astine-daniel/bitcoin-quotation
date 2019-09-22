import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("Bitcoin Quotation")
    }
}

#if DEBUG
struct ContentViewPreviews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
