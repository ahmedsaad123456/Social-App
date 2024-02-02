import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:flutter/material.dart'; 
import 'package:flutter_bloc/flutter_bloc.dart'; 
import 'package:social_app/modules/login/cubit/login_states.dart';

//================================================================================================================================

class LoginCubit extends Cubit<LoginStates> {
  LoginCubit() : super(LoginInitialState()); // Initial state for LoginCubit

  static LoginCubit get(context) => BlocProvider.of(context); // Static method to get instance of LoginCubit

//================================================================================================================================

  // Method to sign in a user 
  void userLogin({
    required String email,
    required String password,
  }) {
    emit(LoginLoadingState()); // Emit loading state
    FirebaseAuth.instance // Firebase authentication instance
        .signInWithEmailAndPassword(email: email, password: password) // Sign in with email and password
        .then((value) {
      emit(LoginSuccessState(value.user!.uid)); // Emit success state with user ID
    }).catchError((error) {
      emit(LoginErrorState(error.toString())); // Emit error state with error message
    });
  }

//================================================================================================================================

  IconData passwordIcon = Icons.visibility_outlined; // Icon for password visibility
  bool isClicked = true; // Flag to track password visibility

  // Method to toggle password visibility icon
  void changeIcon() {
    isClicked = !isClicked; // Toggle flag
    passwordIcon = // Change icon based on flag
        isClicked ? Icons.visibility_outlined : Icons.visibility_off_outlined;
    emit(ChangePasswordVisibilityState()); // Emit state to notify UI about icon change
  }

//================================================================================================================================
}

//================================================================================================================================
