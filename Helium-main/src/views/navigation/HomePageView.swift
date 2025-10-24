import SwiftUI

struct HomePageView: View {
    @State private var isNowEnabled: Bool = false
    @State private var buttonDisabled: Bool = false
    @State private var showAlert: Bool = false
    @State private var showLoading: Bool = false
    @State private var alertMessage: String = ""

    var body: some View {
        ZStack {
            // 主视图内容
            NavigationView {
                VStack {
                    Spacer()
                    Image("dajidaji")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .shadow(radius: 8)
                        .padding(.bottom, 20)

                    Text("三角洲·SK")
                        .font(.title)
                        .foregroundColor(.black)
                        .padding(.bottom, 30)

                    Text(isNowEnabled ? "请注意演戏！" : "点击下方开启")
                        .font(.headline)
                        .foregroundColor(isNowEnabled ? .green : .gray)
                        .padding(.bottom, 15)

                    Button(action: {
                        withAnimation {
                            startLoadingThenToggleHUD()
                        }
                    }) {
                        Text(isNowEnabled ? "关闭绘制" : "打开绘制")
                            .frame(maxWidth: .infinity, maxHeight: 50)
                            .background(isNowEnabled ? Color.green : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal, 20)
                    }
                    .disabled(buttonDisabled || showLoading)

                    Spacer()
                }
                .background(
                    LinearGradient(gradient: Gradient(colors: [.white, .gray.opacity(0.1)]), startPoint: .top, endPoint: .bottom)
                        .edgesIgnoringSafeArea(.all)
                )
                .onAppear {
                    isNowEnabled = IsHUDEnabledBridger()
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("提示"),
                        message: Text(alertMessage),
                        dismissButton: .default(Text("关闭"))
                    )
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())

            if showLoading {
                ProgressView("加载中...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .zIndex(1)
            }
        }
    }

    func startLoadingThenToggleHUD() {
        showLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showLoading = false
            let action = isNowEnabled ? "disable" : "enable"
            toggleHUD(action == "enable")
        }
    }

    func toggleHUD(_ isActive: Bool) {
        Haptic.shared.play(.medium)
        if isNowEnabled == isActive { return }
        SetHUDEnabledBridger(isActive)

        buttonDisabled = true
        waitForNotificationBridger({
            isNowEnabled = isActive
            buttonDisabled = false
        }, !isNowEnabled)
    }
}
