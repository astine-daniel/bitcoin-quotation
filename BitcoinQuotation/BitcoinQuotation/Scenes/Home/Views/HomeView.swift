import SwiftUI

struct HomeView: View {
    init() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = .systemGray6
        navigationBarAppearance.shadowColor = nil

        let appearance = UINavigationBar
            .appearance(whenContainedInInstancesOf: [UINavigationController.self])

        appearance.standardAppearance = navigationBarAppearance
        appearance.scrollEdgeAppearance = navigationBarAppearance
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    VStack(alignment: .center) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Last quotation")
                                    .font(.headline)
                                Text("USD 10,000")
                                    .font(.largeTitle)
                            }

                            Spacer()
                        }
                        .padding([.top, .leading, .trailing], 20)
                        .padding(.bottom, 80)

                        .background(Color(.systemGray6))

                        VStack {
                            LineChartView(data: [1, 2, 3, 10, 50, 34, 100, 8, 4, 1, 40, 45],
                                          title: "Market Price (USD)")
                                .background(Color(.white))
                                .cornerRadius(20)
                                .shadow(radius: 20)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding(.horizontal, 40)
                        .offset(y: -60)
                        .padding(.bottom, -60)
                    }

                    Spacer()
                }
            }
            .navigationBarTitle("Bitcoin Quotation")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#if DEBUG
struct HomeViewPreviews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
#endif
