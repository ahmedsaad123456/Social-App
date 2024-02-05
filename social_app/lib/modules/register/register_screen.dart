import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
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
        } else if (state is CreateUserErrorState) {
          // Show error message on registration error
          messageScreen(message: state.error, state: ToastStates.ERROR);
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
                        'REGISTER',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(
                              color: Colors.black,
                            ),
                      ),
                      Text(
                        'Register now to communicate with friends',
                        style:
                            Theme.of(context).textTheme.titleMedium!.copyWith(
                                  color: Colors.grey,
                                ),
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      defaultFormField(
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
                      const SizedBox(
                        height: 15.0,
                      ),
                      defaultFormField(
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
                        prefix: Icons.lock_outlined, // Lock icon
                        suffix: RegisterCubit.get(context).passwordIcon,
                        suffixPressed: () {
                          RegisterCubit.get(context).changeIcon();
                        },
                        isPassword: RegisterCubit.get(context).isClicked,
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                      defaultFormField(
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
                              RegisterCubit.get(context).userRegister(
                                email: emailController.text,
                                password: passwordController.text,
                                name: nameController.text,
                                phone: phoneController.text,
                              );
                            }
                          },
                          prefix: Icons.phone),
                      const SizedBox(
                        height: 30.0,
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
                        fallback: (context) =>
                            const Center(child: CircularProgressIndicator()),
                      ),
                      const SizedBox(
                        height: 15.0,
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

