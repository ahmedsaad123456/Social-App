import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/layouts/cubit/social_cubit.dart';
import 'package:social_app/layouts/social_layout.dart';
import 'package:social_app/modules/register/cubit/register_cubit.dart';
import 'package:social_app/modules/register/cubit/register_states.dart';
import 'package:social_app/shared/components/components.dart';
import 'package:social_app/shared/components/constants.dart';
import 'package:social_app/shared/network/local/cache_helper.dart';

//================================================================================================================================

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});
  final emailController =
      TextEditingController(); // Controller for email input field
  final passwordController =
      TextEditingController(); // Controller for password input field
  final nameController =
      TextEditingController(); // Controller for name input field
  final phoneController =
      TextEditingController(); // Controller for phone input field

  final formKey = GlobalKey<FormState>(); // Form key for form validation

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterCubit(), // Create instance of RegisterCubit
      child: BlocConsumer<RegisterCubit, RegisterStates>(
          listener: (context, state) {
        if (state is CreateUserSuccessState) {
          // Show success message on successful registration
          messageScreen(
              message: 'Register Success', state: ToastStates.SUCCESS);
          // Save user ID in cache helper
          CacheHelper.saveData(key: 'uId', value: state.uId).then((value) {
            uId = state.uId;
            SocialCubit.get(context).getUserData();
            SocialCubit.get(context).getLoggedInUserPostsData();
            navigateAndFinish(
                context, const SocialLayout()); // Navigate to main app layout
          });
        } else if (state is RegisterErrorState) {
          // Show error message on registration error
          messageScreen(message: state.error, state: ToastStates.ERROR);
        }
      }, builder: (context, state) {
        SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(statusBarColor:  Color.fromRGBO(143, 148, 251, 1)));
        return Scaffold(
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              child: Container(
                child: Column(
                  children: <Widget>[
                    Container(
                      height: 400,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('assets/images/background.png'),
                              fit: BoxFit.fill)),
                      child: Stack(
                        children: <Widget>[
                          Positioned(
                            left: 30,
                            width: 80,
                            height: 200,
                            child: Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/light-1.png'))),
                            ),
                          ),
                          Positioned(
                            left: 140,
                            width: 80,
                            height: 150,
                            child: Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/light-2.png'))),
                            ),
                          ),
                          Positioned(
                            right: 40,
                            top: 40,
                            width: 80,
                            height: 150,
                            child: Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/clock.png'))),
                            ),
                          ),
                          Positioned(
                            child: Container(
                              margin: EdgeInsets.only(top: 50),
                              child: Center(
                                child: Text(
                                  "Register",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 30, right: 30, bottom: 30),
                      child: Column(
                        children: <Widget>[
                          Form(
                            key: formKey,
                            child: Column(
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: defaultFormField(
                                      controller: nameController,
                                      type: TextInputType.name,
                                      label: 'Name',
                                      validate: (value) {
                                        if (value!.isEmpty) {
                                          return 'please enter your name';
                                        }
                                        return null;
                                      },
                                      prefix: Icons.person),
                                ),
                                const SizedBox(
                                  height: 5.0,
                                ),
                                Container(
                                  padding: EdgeInsets.all(8.0),
                                  child: defaultFormField(
                                      controller: emailController,
                                      type: TextInputType.emailAddress,
                                      label: 'Email',
                                      validate: (value) {
                                        if (value!.isEmpty) {
                                          return 'please enter your email address';
                                        }
                                        return null;
                                      },
                                      prefix: Icons.email_outlined),
                                ),
                                const SizedBox(
                                  height: 5.0,
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: defaultFormField(
                                    controller: passwordController,
                                    type: TextInputType.visiblePassword,
                                    label: 'Password', // Password input field
                                    validate: (value) {
                                      if (value!.isEmpty) {
                                        return 'please enter your password';
                                      }
                                      return null;
                                    },
                                    prefix: Icons.lock_outlined, // Lock icon
                                    suffix:
                                        RegisterCubit.get(context).passwordIcon,
                                    suffixPressed: () {
                                      RegisterCubit.get(context).changeIcon();
                                    },
                                    isPassword:
                                        RegisterCubit.get(context).isClicked,
                                  ),
                                ),
                                const SizedBox(
                                  height: 5.0,
                                ),
                                Container(
                                  padding: EdgeInsets.all(8.0),
                                  child: defaultFormField(
                                      controller: phoneController,
                                      type: TextInputType.phone,
                                      label: 'Phone',
                                      validate: (value) {
                                        if (value!.isEmpty) {
                                          return 'please enter your phone';
                                        }
                                        return null;
                                      },
                                      onSubmit: (value) {
                                        if (formKey.currentState!.validate()) {
                                          RegisterCubit.get(context)
                                              .userRegister(
                                            email: emailController.text,
                                            password: passwordController.text,
                                            name: nameController.text,
                                            phone: phoneController.text,
                                          );
                                        }
                                      },
                                      prefix: Icons.phone),
                                ),
                                const SizedBox(
                                  height: 15.0,
                                ),
                              ],
                            ),
                          ),
                          ConditionalBuilder(
                            condition: state is! RegisterLoadingState,
                            builder: (context) => defaultButton(
                                function: () {
                                  if (formKey.currentState!.validate()) {
                                    RegisterCubit.get(context).userRegister(
                                      email: emailController.text,
                                      password: passwordController.text,
                                      name: nameController.text,
                                      phone: phoneController.text,
                                    );
                                  }
                                },
                                text: 'REGISTER',
                                isUpperCase: true),
                            fallback: (context) => const Center(
                                child: CircularProgressIndicator()),
                          ),
                          const SizedBox(
                            height: 15.0,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ));
      }),
    );
  }
}

//================================================================================================================================

