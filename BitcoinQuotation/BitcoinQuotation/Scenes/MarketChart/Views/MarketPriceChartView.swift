import SwiftUI

struct MarketPriceChartView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 10.0) {
            Text("Market Price (USD)")
                .font(.callout)
                .fontWeight(.semibold)

            Text("Average USD market price \nacross major bitcoin exchanges")
                .multilineTextAlignment(.center)
                .font(.footnote)

            Text("Drag over the line to se the values")
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .font(.title)
                .padding(.top, 40.0)
                .padding(.bottom, 15.0)
                .padding(.horizontal, 10.0)

            LineChartView(data: [1, 2, 3, 10, 50, 34, 100, 8, 4, 1, 40, 45])

            Spacer()
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .padding(.horizontal, 10)
        .padding(.top, 40.0)
        .navigationBarTitle("Market Price", displayMode: .inline)
    }
}

#if DEBUG
struct MarketPriceChartViewPreviews: PreviewProvider {
    static var previews: some View {
        MarketPriceChartView()
    }
}
#endif
