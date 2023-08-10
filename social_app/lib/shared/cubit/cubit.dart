import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/shared/cubit/states.dart';
import 'package:social_app/shared/network/local/cache_helper.dart';






//==========================================================================================================================================================


class DarkCubit extends Cubit<DarkStates> {
  DarkCubit() : super(DarkInitialState());
  static DarkCubit get(context) => BlocProvider.of(context);

  bool isDark = false;

  void changeAppMode({bool? isShared}) {
    if (isShared != null) {
      isDark = isShared;
      emit(DarkcChangeState());
    } else{
      isDark = !isDark;

    CacheHelper.putData(key: 'isDark', value: isDark).then((value) {
      emit(DarkcChangeState());
    });

    }
    
  }
}

//==========================================================================================================================================================

