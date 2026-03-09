// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import 'contract/local/i_message_service.dart' as _i482;
import 'contract/local/i_navigation_service.dart' as _i752;
import 'screens/arrange_puzzle/arrange_puzzle_view_model.dart' as _i318;
import 'screens/connect_meaning/connnect_meaning_view_model.dart' as _i429;
import 'screens/fill_gaps_screen/fill_gaps_view_model.dart' as _i137;
import 'screens/home/surah_selection_view_model.dart' as _i679;
import 'screens/login_screen/login_screen_view_model.dart' as _i52;
import 'screens/profile_screen/profile_screen_view_model.dart' as _i583;
import 'screens/surah_learning_path/surah_learning_path_view_model.dart'
    as _i492;
import 'services/audio_cache_service.dart' as _i970;
import 'services/firestore_service.dart' as _i735;
import 'services/message_service.dart' as _i806;
import 'services/navigation_service.dart' as _i912;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.factory<_i429.ConnnectMeaningViewModel>(
      () => _i429.ConnnectMeaningViewModel(),
    );
    gh.factory<_i137.FillGapsViewModel>(() => _i137.FillGapsViewModel());
    gh.factory<_i52.LoginScreenViewModel>(() => _i52.LoginScreenViewModel());
    gh.factory<_i492.SurahLearningPathViewModel>(
      () => _i492.SurahLearningPathViewModel(),
    );
    gh.factory<_i583.ProfileScreenViewModel>(
      () => _i583.ProfileScreenViewModel(gh<_i735.FirestoreService>()),
    );
    gh.singleton<_i970.AudioCacheService>(() => _i970.AudioCacheService());
    gh.singleton<_i735.FirestoreService>(() => _i735.FirestoreService());
    gh.singleton<_i752.INavigationService>(() => _i912.NavigationService());
    gh.singleton<_i482.IMessageService>(() => _i806.MessageService());
    gh.factory<_i318.ArrangePuzzleViewModel>(
      () => _i318.ArrangePuzzleViewModel(gh<_i735.FirestoreService>()),
    );
    gh.factory<_i679.SurahSelectionScreenViewModel>(
      () => _i679.SurahSelectionScreenViewModel(gh<_i735.FirestoreService>()),
    );
    return this;
  }
}
