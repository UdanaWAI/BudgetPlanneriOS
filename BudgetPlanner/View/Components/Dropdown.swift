import SwiftUI


// MARK: - Dropdown Component
struct Dropdown: View {
    @Binding var selectedOption: String
    let options: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Select Budget Type")
                .font(.caption)
                .foregroundColor(.gray)
            HStack{
                Picker(selection: $selectedOption, label: Text(selectedOption).foregroundColor(.black)) {
                    ForEach(options, id: \.self) { option in
                        Text(option).tag(option)
                    }
                }
                Spacer()
            }
            .pickerStyle(MenuPickerStyle())
            .padding(.vertical,8)
            .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.4)))
        }
    }
}


// MARK: - Preview
struct DropdownView: View {
    @State private var textValue = ""
    @State private var selectedBudget = "Monthly"
    
    var body: some View {
        VStack(spacing: 20) {
            
            Dropdown(selectedOption: $selectedBudget, options: ["Monthly", "Weekly", "Daily"])
            
        }
        .padding()
    }
}

struct DropdownView_Previews: PreviewProvider {
    static var previews: some View {
        DropdownView()
    }
}
