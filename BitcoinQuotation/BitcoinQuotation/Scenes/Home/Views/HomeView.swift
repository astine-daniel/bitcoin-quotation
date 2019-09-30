import SwiftUI

struct HomeView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                VStack(alignment: .center) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Last quotation")
                                .font(.headline)
                            Text("USD 10,000")
                                .font(.title)
                        }

                        Spacer()
                    }
                    .padding([.top, .leading], 20)
                    .padding(.trailing, 10)
                    .padding(.bottom, 80)
                    .background(Color(.systemGray6))

                    NavigationLink(destination: MarketPriceChartView()) {
                        VStack {
                            VStack(alignment: .leading, spacing: 10.0) {
                                Text("Market price")
                                    .font(.callout)
                                    .padding(20)
                                    .foregroundColor(Color(.label))

                                LineChartView(data: [1, 2, 3, 10, 50, 34, 100, 8, 4, 1, 40, 45])
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
    }
}

#if DEBUG
struct HomeViewPreviews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
#endif
