import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart'; 
import 'package:flutter/material.dart'; 
import 'package:flutter_bloc/flutter_bloc.dart'; 
import 'package:social_app/layouts/social_layout.dart'; 
import 'package:social_app/modules/login/cubit/login_cubit.dart'; 
import 'package:social_app/modules/login/cubit/login_states.dart'; 
import 'package:social_app/modules/register/register_screen.dart'; 
import 'package:social_app/shared/components/components.dart'; 
import 'package:social_app/shared/network/local/cache_helper.dart'; 

//================================================================================================================================

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key}); 
  final emailController = TextEditingController(); // Controller for email input field
  final passwordController = TextEditingController(); // Controller for password input field
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
            navigateAndFinish(context, const SocialLayout()); // Navigate to main app layout
          });
        }
      }, builder: (context, state) {
        return Scaffold(
          appBar: AppBar(), 
          body: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LOGIN', // Title
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(
                              color: Colors.black,
                            ),
                      ),
                      Text(
                        'Login now to communicate with friends', // Subtitle
                        style:
                            Theme.of(context).textTheme.titleMedium!.copyWith(
                                  color: Colors.grey,
                                ),
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      defaultFormField(
                          controller: emailController,
                          type: TextInputType.emailAddress,
                          label: 'Email', // Email input field
                          validate: (value) {
                            if (value!.isEmpty) {
                              return 'please enter your email address';
                            }
                            return null;
                          },
                          prefix: Icons.email_outlined), // Email icon
                      const SizedBox(
                        height: 15.0,
                      ),
                      defaultFormField(
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
                        suffix: LoginCubit.get(context).passwordIcon,
                        suffixPressed: () {
                          LoginCubit.get(context).changeIcon();
                        },
                        isPassword: LoginCubit.get(context).isClicked,
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      ConditionalBuilder(
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
                        fallback: (context) =>
                            const Center(child: CircularProgressIndicator()), // Loading indicator
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Don\'t have an account? '), // Sign up prompt
                          defaultTextButton(
                              fun: () {
                                navigateTo(context, RegisterScreen()); // Navigate to register screen
                              },
                              text: 'Register now') // Register now button
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

//================================================================================================================================
