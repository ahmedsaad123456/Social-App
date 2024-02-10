import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/layouts/cubit/social_cubit.dart';
import 'package:social_app/layouts/social_layout.dart';
import 'package:social_app/modules/login/cubit/login_cubit.dart';
import 'package:social_app/modules/login/cubit/login_states.dart';
import 'package:social_app/modules/register/register_screen.dart';
import 'package:social_app/shared/components/components.dart';
import 'package:social_app/shared/components/constants.dart';
import 'package:social_app/shared/network/local/cache_helper.dart';

//================================================================================================================================

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final emailController =
      TextEditingController(); // Controller for email input field
  final passwordController =
      TextEditingController(); // Controller for password input field
  final formKey = GlobalKey<FormState>(); // Form key for form validation

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(),
      child: BlocConsumer<LoginCubit, LoginStates>(listener: (context, state) {
        // Listen to state changes in LoginCubit
        if (state is LoginErrorState) {
          // Show error message if user login fails
          messageScreen(message: state.error, state: ToastStates.ERROR);
        } else if (state is LoginSuccessState) {
          // Show success message if user login succeeds
          messageScreen(message: 'Login success', state: ToastStates.SUCCESS);

          // Save user ID in cache helper
          CacheHelper.saveData(key: 'uId', value: state.uId).then((value) {
            uId = state.uId;
            SocialCubit.get(context).getUserData();
            SocialCubit.get(context).getLoggedInUserPostsData();

            navigateAndFinish(
                context, const SocialLayout()); // Navigate to main app layout
          });
        }
      }, builder: (context, state) {
        SystemChrome.setSystemUIOverlayStyle(
            const SystemUiOverlayStyle(statusBarColor:  Color.fromRGBO(143, 148, 251, 1)));
        return Scaffold(
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              child: Container(
                child: Column(
                  children: <Widget>[
                    Container(
                      height: 400,
                      decoration: const BoxDecoration(
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
                              decoration: const BoxDecoration(
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
                              decoration: const BoxDecoration(
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
                              decoration: const BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/clock.png'))),
                            ),
                          ),
                          Positioned(
                            child: Container(
                              margin: const EdgeInsets.only(top: 50),
                              child: const Center(
                                child: Text(
                                  "Login",
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
                      padding: const EdgeInsets.all(30.0),
                      child: Column(
                        children: <Widget>[
                          Form(
                            key: formKey,
                            child: Column(
                              children: <Widget>[
                                Container(
                                  padding: const EdgeInsets.all(8.0),

                                  child: defaultFormField(
                                      controller: emailController,
                                      type: TextInputType.emailAddress,
                                      label: 'Email', // Email input field
                                      validate: (value) {
                                        if (value!.isEmpty) {
                                          return 'please enter your email address';
                                        }
                                        return null;
                                      },
                                      prefix:
                                          Icons.email_outlined), // Email icon
                                ),
                                const SizedBox(
                                  height: 15.0,
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8.0),
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
                                    onSubmit: (value) {
                                      if (formKey.currentState!.validate()) {
                                        LoginCubit.get(context).userLogin(
                                            email: emailController.text,
                                            password: passwordController.text);
                                      }
                                    },
                                    prefix: Icons.lock_outlined, // Lock icon
                                    suffix:
                                        LoginCubit.get(context).passwordIcon,
                                    suffixPressed: () {
                                      LoginCubit.get(context).changeIcon();
                                    },
                                    isPassword:
                                        LoginCubit.get(context).isClicked,
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Center(
                            child: ConditionalBuilder(
                              condition: state is! LoginLoadingState,
                              builder: (context) => defaultButton(
                                  function: () {
                                    if (formKey.currentState!.validate()) {
                                      LoginCubit.get(context).userLogin(
                                          email: emailController.text,
                                          password: passwordController.text);
                                    }
                                  },
                                  text: 'LOGIN', // Login button text
                                  isUpperCase: true),
                              fallback: (context) => const Center(
                                  child:
                                      CircularProgressIndicator()), // Loading indicator
                            ),
                          ),
                          const SizedBox(
                            height: 15.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Expanded(
                                child: Text('Don\'t have an account? '),
                              ), // Sign up prompt
                              Expanded(
                                child: defaultTextButton(
                                    fun: () {
                                      navigateTo(context,
                                          RegisterScreen()); // Navigate to register screen
                                    },
                                    text: 'Register now'),
                              ) // Register now button
                            ],
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

