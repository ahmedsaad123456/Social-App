//================================================================================================================================

// Abstract class representing various states for login
import 'package:social_app/shared/components/constants.dart';

abstract class LoginStates {}

// Initial state for login
class LoginInitialState extends LoginStates {}
//================================================================================================================================

// State representing loading during login process
class LoginLoadingState extends LoginStates {}

// State representing successful login
class LoginSuccessState extends LoginStates {
  // User ID of the logged-in user
  final String uId;

  LoginSuccessState(this.uId);
}

// State representing login error
class LoginErrorState extends LoginStates {
  String error;

  LoginErrorState(this.error) {
    error = error.replaceAll(regex, "").trim();
  }
}

//================================================================================================================================

// State representing change in password visibility
class ChangePasswordVisibilityState extends LoginStates {} 

//================================================================================================================================
