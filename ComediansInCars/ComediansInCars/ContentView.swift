import SwiftUI

struct ContentView: View {
    @State private var user = ""
    @State private var password = ""
    @State private var isCreatingUser = false
    @State private var isLoading = false
    @State private var loginError = false
    @State private var showProfile = false
    @State private var loggedIn = false
    let apiManager = APIManager()
    
    var body: some View {
        NavigationView {
            VStack {
                Image("FullSizeRender")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 350, height: 350)
                    .padding(.bottom, 20)
                
                TextField("Username", text: $user)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .autocapitalization(.none)
                    .keyboardType(.default)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button("Login") {
                    apiManager.login(user: user, password: password) { result in
                        switch result {
                        case .success(let loginResponse):
                            if loginResponse.message == "success" {
                                    loggedIn = true
                                    showProfile = true // Set showProfile to true
                                } else {
                                    // Display error message on failure
                                    print("Login failed: \(loginResponse.message)")
                                    loginError = true
                                }
                        case .failure(let error):
                            // Display error message on failure
                            print("Login failed: \(error.localizedDescription)")
                            loginError = true
                        }
                    }
                }
                .padding()
                .buttonStyle(FilledButton())
                
                
                Button("Don't have an account? Create one") {
                    isCreatingUser.toggle()
                    apiManager.create_user(user: user, password: password) { result in
                        switch result {
                        case .success(let loginResponse):
                            if loginResponse.message == "success" {
                                    loggedIn = true
                                    showProfile = true // Set showProfile to true
                                } else {
                                    // Display error message on failure
                                    print("Login failed: \(loginResponse.message)")
                                    loginError = true
                                }
                        case .failure(let error):
                            // Display error message on failure
                            print("Login failed: \(error.localizedDescription)")
                            loginError = true
                        }
                    }
                }
                .padding()
                
                if loggedIn {
                    NavigationLink(destination: ProfileView(user:user), isActive: $showProfile) {
                        EmptyView()
                    }
                }
                
            }
            .alert(isPresented: $loginError) {
                Alert(title: Text("Login Failed"), message: Text("Wrong email or password"), dismissButton: .default(Text("OK")))
            }
            .navigationTitle("Login")
            .padding(.top, 30)
        }
    }
}

struct FilledButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}


struct AddFriendView: View {
    @State private var friendUsername = ""
    @State private var isAddingFriend = false
    
    var body: some View {
        VStack {
            Spacer()
            
            TextField("Comedian's username", text: $friendUsername)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .autocapitalization(.none)
            
            Toggle("Add comedian", isOn: $isAddingFriend)
                .padding()
            
            Button("Add") {
                // Perform add friend action
                print("Adding comedian with username: \(friendUsername)")
                friendUsername = ""
                isAddingFriend = false
            }
            .disabled(friendUsername.isEmpty)
            .padding()
            .buttonStyle(FilledButton())
            
            Spacer()
        }
        .navigationTitle("Add Friend")
        .padding(.top, 30)
    }
}

struct ProfileView: View {
    var user: String
    @State private var friendUsername = ""
    @State private var isFeatureOn = false
    @State private var friends: [Friend] = []
    let apiManager = APIManager()

    var body: some View {
        VStack {
            Spacer()

            Text("Hej Komiker \(user)")
                .font(.largeTitle)
                .bold()
                .padding()

            HStack {
                TextField("Comedian's Username", text: $friendUsername)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                Button("Add Comedian") {
                    addFriend()
                }
                .padding(.horizontal)
                .buttonStyle(FilledButton())
            }

            Spacer()

            Toggle("Ja, du kan ringe til mig", isOn: $isFeatureOn)
                .onChange(of: isFeatureOn, perform: { value in
                    setActivity()
                })
                .toggleStyle(SwitchToggleStyle(tint: isFeatureOn ? Color.green : Color.red))
                .padding()

            Spacer()

            List(friends, id: \.name) { friend in
                HStack {
                    VStack(alignment: .leading) {
                        Text(friend.name)
                            .font(.headline)
                        Text(friend.active ? "Active" : "Inactive")
                            .font(.subheadline)
                            .foregroundColor(friend.active ? .green : .red)
                    }
                    Spacer()
                    Image(systemName: "person.fill")
                        .foregroundColor(friend.active ? .green : .red)
                }
            }
            .onAppear {
                // Load initial friends list
                loadFriends()
                
                // Start a timer to update the friends list every 5 seconds
                Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
                    loadFriends()
                }
            }
        }
        .padding(.top, 30)
    }

    private func addFriend() {
        apiManager.addFriend(friend: friendUsername, currentUser: user) { result in
            switch result {
            case .success(let response):
                print(response.message)
                // Reload the friends list
                loadFriends()
            case .failure(let error):
                print(error.localizedDescription)
                // Handle the failure error
            }
        }

        friendUsername = ""
    }

    private func loadFriends() {
        apiManager.getFriends(forUser: user) { result in
            switch result {
            case .success(let friends):
                self.friends = friends
            case .failure(let error):
                print(error.localizedDescription)
                // Handle the failure error
            }
        }
    }

    private func setActivity() -> some View {
        apiManager.setActivity(user: user, active: isFeatureOn) { result in
            switch result {
            case .success(let response):
                if let message = response.message {
                    print("Response message: \(message)")
                }
                if let data = response.data {
                    print("Response data: \(data)")
                }
            case .failure(let error):
                print("Error: \(error)")
            }
        }
        return EmptyView()
    }
}
