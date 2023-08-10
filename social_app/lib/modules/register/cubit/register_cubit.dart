import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/models/user_model.dart';
import 'package:social_app/modules/register/cubit/register_states.dart';

//================================================================================================================================

class RegisterCubit extends Cubit<RegisterStates> {
  RegisterCubit() : super(RegisterInitialState());

  static RegisterCubit get(context) => BlocProvider.of(context);

//================================================================================================================================

  void userRegister({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) {
    emit(RegisterLoadingState());

    FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((value) {
      
      userCreate(email: email, name: name, phone: phone, uId: value.user!.uid);

    }).catchError((error) {
      emit(RegisterErrorState(error.toString()));
    });
  }

//================================================================================================================================


  void userCreate({
    required String email,
    required String name,
    required String phone,
    required String uId,
  }) {
    UserModel model = UserModel(
      name: name,
      email: email,
      phone: phone,
      uId: uId,
      isEmailVerified: false,
      bio: 'write your bio...',
      image: 'https://www.pngkey.com/png/detail/115-1150152_default-profile-picture-avatar-png-green.png',
      cover: 'https://i.stack.imgur.com/cEz3G.jpg',
    );
    FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .set(model.toMap())
        .then((value) {
      emit(CreateUserSuccessState());
    }).catchError((error) {
      emit(CreateUserErrorState(error.toString()));
    });
  }

//================================================================================================================================

  IconData passwordIcon = Icons.visibility_outlined;
  bool isClicked = true;

  void changeIcon() {
    isClicked = !isClicked;
    passwordIcon =
        isClicked ? Icons.visibility_outlined : Icons.visibility_off_outlined;
    emit(ChangePasswordVisibilityState());
  }

//================================================================================================================================
}


//================================================================================================================================
