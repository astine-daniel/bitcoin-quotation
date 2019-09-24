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
                    ZStack(alignment: .topLeading) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Market price")
                                    .font(.headline)
                                Text("USD 10,000")
                                    .font(.largeTitle)
                            }

                            Spacer()
                        }
                        .padding([.top, .leading, .trailing], 20)
                        .padding(.bottom, 80)
                        
                    }

                    Spacer()
                }
                .background(Color(.systemGray6))
            }
            .navigationBarTitle("Bitcoin Quotation")
        }
    }
}

#if DEBUG
struct HomeViewPreviews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
#endif
