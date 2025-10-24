import SwiftUI

struct ContentView: View {
    @State private var headHp = true
    @State private var jungleTimer = true
    @State private var minionJungle = true
    @State private var heroRay = false
    @State private var heroBox = true
    @State private var floatSkill = true
    @State private var directMode = true
    @State private var skillTest = false
    @State private var rayColor = Color.red
    @State private var indicatorColor = Color.green
    @State private var boxColor = Color.green
    @State private var minionColor = Color.green
    @State private var jungleColor = Color.green

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Hertz Ultra配置")) {
                    Toggle("头像血量", isOn: $headHp)
                    Toggle("野怪计时", isOn: $jungleTimer)
                    Toggle("兵线 野怪", isOn: $minionJungle)
                    Toggle("英雄 射线", isOn: $heroRay)
                    Toggle("英雄 方框", isOn: $heroBox)
                    Toggle("悬浮 技能", isOn: $floatSkill)
                    Toggle("直指 模式", isOn: $directMode)
                }
                
                Section(header: Text("技能 调试")) {
                    Toggle("技能 调试", isOn: $skillTest)
                }
                
                Section(header: Text("颜色设置")) {
                    ColorPicker("射线 颜色", selection: $rayColor)
                    ColorPicker("指示 颜色", selection: $indicatorColor)
                    ColorPicker("方框 颜色", selection: $boxColor)
                    ColorPicker("兵线 颜色", selection: $minionColor)
                    ColorPicker("野怪 颜色", selection: $jungleColor)
                }
            }
            .navigationBarTitle("配置", displayMode: .inline)
        }
    }
   
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
