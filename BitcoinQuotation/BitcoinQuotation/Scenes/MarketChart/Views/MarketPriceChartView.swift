import SwiftUI

struct MarketPriceChartView: View {
    @EnvironmentObject private var chartDataViewModel: ChartDataViewModel
    @State private var currentIndex: Int?

    var body: some View {
        VStack(alignment: .center, spacing: 10.0) {
            Text("Market Price (USD)")
                .font(.callout)
                .fontWeight(.semibold)

            Text("Average USD market price \nacross major bitcoin exchanges")
                .multilineTextAlignment(.center)
                .font(.footnote)

            Text(currentValueText(from: currentIndex))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .font(.title)
                .padding(.top, 40.0)
                .padding(.bottom, 15.0)
                .padding(.horizontal, 10.0)

            LineChartView(data: chartDataViewModel.values.map { $0.value }) {
                self.currentIndex = $0
            }

            Spacer()
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .padding(.horizontal, 10)
        .padding(.top, 40.0)
        .navigationBarTitle("Market Price", displayMode: .inline)
    }
}

private extension MarketPriceChartView {
    func currentValueText(from index: Int?) -> String {
        guard let index = index else {
            return "Drag over the line to se the values"
        }

        let value = chartDataViewModel.values[index]

        let formatedValue = formated(value: value.value)
        let formatedDate = formated(value: value.date)

        return "\(formatedDate)\nUSD \(formatedValue)"
    }

    func formated(value: Decimal) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.usesGroupingSeparator = true
        numberFormatter.numberStyle = .currency
        numberFormatter.currencySymbol = ""

        return numberFormatter
            .string(from: NSDecimalNumber(decimal: value)) ?? "-"
    }

    func formated(value: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"

        return dateFormatter.string(from: value)
    }
}

#if DEBUG
struct MarketPriceChartViewPreviews: PreviewProvider {
    static var previews: some View {
        MarketPriceChartView()
    }
}
#endif
