//import SwiftUI
//
//// MARK: - Date Picker Component
//struct DatePickerComponent: View {
//    @State private var showDatePicker = false
//    @State private var selectedDate = Date()
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 4) {
//            Text("Select Date")
//                .font(.caption)
//                .foregroundColor(.gray)
//
//            Button(action: {
//                showDatePicker.toggle()
//            }) {
//                HStack {
//                    Text("Select date")
//                        .foregroundColor(.gray)
//                    Spacer()
//                    Text(selectedDate, style: .date)
//                        .foregroundColor(.blue)
//                }
//                .padding()
//                .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.4)))
//            }
//        }
//        .sheet(isPresented: $showDatePicker) {
//            DatePicker("Pick a date", selection: $selectedDate, displayedComponents: .date)
//                .datePickerStyle(GraphicalDatePickerStyle())
//                .padding()
//        }
//    }
//}
//
//// MARK: - Preview
//struct DatePickerView: View {
//    @State private var textValue = ""
//    @State private var selectedBudget = "Monthly"
//    
//    var body: some View {
//        VStack(spacing: 20) {
//           
//            DatePickerComponent()
//        }
//        .padding()
//    }
//}
//
//struct DatePickerView_Previews: PreviewProvider {
//    static var previews: some View {
//        DatePickerView()
//    }
//}
