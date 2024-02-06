import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/layouts/cubit/social_cubit.dart';
import 'package:social_app/layouts/social_layout.dart';
import 'package:social_app/modules/login/login_screen.dart';
import 'package:social_app/shared/bloc_observer.dart';
import 'package:social_app/shared/components/components.dart';
import 'package:social_app/shared/components/constants.dart';
import 'package:social_app/shared/cubit/cubit.dart';
import 'package:social_app/shared/cubit/states.dart';
import 'package:social_app/shared/network/local/cache_helper.dart';
import 'package:social_app/shared/styles/themes.dart';

//==========================================================================================================================================================

Future<void> firebaseBackgroundMessagingHandler(RemoteMessage message) async {
  // print('on background message');
  messageScreen(message: 'backgroundMessage', state: ToastStates.SUCCESS);
}

void main() async {
  // sure that the every thing in this method was finished then open the app
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      // options: DefaultFirebaseOptions.currentPlatform,
      );

  // var token = await FirebaseMessaging.instance.getToken();

  // print('The Token: ');
  // print(token);
  // opened and in it
  // forground fcm
  FirebaseMessaging.onMessage.listen((event) {
    // print(event.data.toString());
    messageScreen(message: 'onMessage', state: ToastStates.SUCCESS);
  });

  // when click on notification to open app
  FirebaseMessaging.onMessageOpenedApp.listen((event) {
    // print(event.data.toString());
    messageScreen(message: 'openedMessage', state: ToastStates.SUCCESS);
  });

  // app closed
  // background fcm
  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundMessagingHandler);

  Bloc.observer = MyBlocObserver();
  await CacheHelper.init();

  bool? isDark = CacheHelper.getData(key: 'isDark');

  Widget widget;

  uId = CacheHelper.getData(key: 'uId');

  if (uId != null) {
    widget = const SocialLayout();
  } else {
    widget = LoginScreen();
  }
  runApp(MyApp(
    isDark ?? false,
    widget,
  ));
}

//==========================================================================================================================================================

class MyApp extends StatelessWidget {
  final bool isDark;
  final Widget startWidget;

  const MyApp(this.isDark, this.startWidget, {super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (buildcontext) =>
              DarkCubit()..changeAppMode(isShared: isDark),
        ),
        BlocProvider(create: (buildContext) {
          if (startWidget is! LoginScreen) {
            return SocialCubit()
              ..getUserData()
              ..getLoggedInUserPostsData();
          }
          return SocialCubit();
        }),
      ],
      child: BlocConsumer<DarkCubit, DarkStates>(
          listener: (context, state) {},
          builder: (context, state) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: DarkCubit.get(context).isDark
                  ? ThemeMode.dark
                  : ThemeMode.light,
              home: startWidget,
            );
          }),
    );
  }
}

//==========================================================================================================================================================

