//================================================================================================================================

// Abstract class representing various states for registration
abstract class RegisterStates {}


// Initial state for registration
class RegisterInitialState extends RegisterStates {} 

//================================================================================================================================

// State representing loading during registration
class RegisterLoadingState extends RegisterStates {} 


// State representing successful registration
class RegisterSuccessState extends RegisterStates {} 


// State representing registration error
class RegisterErrorState extends RegisterStates { 
  final String error;

  RegisterErrorState(this.error); 
}

// State representing successful user creation
class CreateUserSuccessState extends RegisterStates {

  // User ID of the logged-in user
  final String uId; 

  CreateUserSuccessState(this.uId);

}

 // State representing user creation error
class CreateUserErrorState extends RegisterStates {
  final String error; 

  CreateUserErrorState(this.error); 
}

//================================================================================================================================


// State representing change in password visibility
class ChangePasswordVisibilityState extends RegisterStates {} 

//================================================================================================================================
