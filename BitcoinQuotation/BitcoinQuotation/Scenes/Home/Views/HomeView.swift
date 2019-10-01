import SwiftUI

struct HomeView: View {
    @ObservedObject private var statsViewModel: StatsViewModel
    @ObservedObject private var chartDataViewModel: ChartDataViewModel

    init() {
        self.statsViewModel = StatsViewModel()
        self.chartDataViewModel = ChartDataViewModel()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                VStack(alignment: .center) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Last quotation")
                                .font(.headline)

                            if statsViewModel.isLoading == false && statsViewModel.stats != nil {
                                Text("USD \(formated(value: statsViewModel.stats!.marketPriceInUSD))")
                                    .font(.title)
                            } else {
                                ActivityIndicator(style: .medium)
                            }
                        }

                        Spacer()
                    }
                    .padding([.top, .leading], 20)
                    .padding(.trailing, 10)
                    .padding(.bottom, 80)
                    .background(Color(.systemGray6))

                    NavigationLink(destination: MarketPriceChartView().environmentObject(self.chartDataViewModel)) {
                        VStack {
                            VStack(alignment: chartDataViewModel.isLoading ? .center : .leading, spacing: 10.0) {
                                if chartDataViewModel.isLoading {
                                    ActivityIndicator(style: .medium)
                                } else {
                                    Text("Market price")
                                        .font(.callout)
                                        .padding(20)
                                        .foregroundColor(Color(.label))

                                    LineChartView(data: chartDataViewModel.values.map { $0.value })
                                }
                            }
                            .background(Color(UIColor(dynamicProvider: {
                                switch $0.userInterfaceStyle {
                                case .dark: return .black
                                default: return .white
                                }
                            })))
                            .cornerRadius(20)
                            .shadow(color: Color(UIColor(dynamicProvider: {
                                switch $0.userInterfaceStyle {
                                case .dark: return UIColor.white.withAlphaComponent(0.33)
                                default: return UIColor.black.withAlphaComponent(0.33)
                                }
                            })), radius: 20)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding(.horizontal, 40)
                        .offset(y: -60)
                        .padding(.bottom, -60)
                    }
                }

                Spacer()
            }
        }
        .navigationBarTitle("Bitcoin Quotation")
        .onAppear {
            self.statsViewModel.loadStats()
            self.chartDataViewModel.loadData()
        }
    }
}

private extension HomeView {
    func formated(value: Decimal) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.usesGroupingSeparator = true
        numberFormatter.numberStyle = .currency
        numberFormatter.currencySymbol = ""

        return numberFormatter
            .string(from: NSDecimalNumber(decimal: value)) ?? "-"
    }
}

#if DEBUG
struct HomeViewPreviews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
#endif
