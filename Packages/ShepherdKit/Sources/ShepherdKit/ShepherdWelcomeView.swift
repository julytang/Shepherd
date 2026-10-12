import SwiftUI

public struct ShepherdWelcomeView: View {
    public init() {}

    public var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "leaf")
                .font(.system(size: 48))
                .foregroundStyle(.tint)
            Text("Shepherd")
                .font(.largeTitle.bold())
            Text("Your next chapter starts here.")
                .foregroundStyle(.secondary)
        }
        .padding(32)
    }
}

#Preview {
    ShepherdWelcomeView()
}
