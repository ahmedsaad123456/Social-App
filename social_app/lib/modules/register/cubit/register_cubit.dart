import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:flutter/material.dart'; 
import 'package:flutter_bloc/flutter_bloc.dart'; 
import 'package:social_app/models/user_model.dart'; 
import 'package:social_app/modules/register/cubit/register_states.dart'; 

//================================================================================================================================

class RegisterCubit extends Cubit<RegisterStates> {
  RegisterCubit() : super(RegisterInitialState()); 

  static RegisterCubit get(context) => BlocProvider.of(context); // Static method to get instance of RegisterCubit

//================================================================================================================================

  // Method to register a new user
  void userRegister({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) {
    emit(RegisterLoadingState()); // Emit loading state
    FirebaseAuth.instance // Firebase authentication instance
        .createUserWithEmailAndPassword(email: email, password: password) // Create user with email and password
        .then((value) {
      userCreate(email: email, name: name, phone: phone, uId: value.user!.uid); // Create user profile in Firestore
    }).catchError((error) {
      emit(RegisterErrorState(error.toString())); // Emit error state with error message
    });
  }

//================================================================================================================================

  // Method to create user profile in Firestore
  void userCreate({
    required String email,
    required String name,
    required String phone,
    required String uId,
  }) {
    UserModel model = UserModel( // Create UserModel object
      name: name,
      email: email,
      phone: phone,
      uId: uId,
      isEmailVerified: false,
      bio: 'write your bio...', // Default bio
      image: 'https://www.pngkey.com/png/detail/115-1150152_default-profile-picture-avatar-png-green.png', // Default profile image
      cover: 'https://i.stack.imgur.com/cEz3G.jpg', // Default cover image
    );
    FirebaseFirestore.instance // Firestore instance
        .collection('users') // Users collection
        .doc(uId) // Document ID
        .set(model.toMap()) // Set user data
        .then((value) {
      emit(CreateUserSuccessState(uId)); // Emit success state
    }).catchError((error) {
      emit(CreateUserErrorState(error.toString())); // Emit error state with error message
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
