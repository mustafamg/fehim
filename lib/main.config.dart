import 'package:get_it/get_it.dart' as i174;
import 'package:injectable/injectable.dart' as i526;

import 'contract/local/i_message_service.dart' as i482;
import 'contract/local/i_navigation_service.dart' as i752;
import 'screens/arrange_puzzle/arrange_puzzle_view_model.dart' as i318;
import 'screens/connect_meaning/connnect_meaning_view_model.dart' as i429;
import 'screens/home/surah_selection_view_model.dart' as i679;
import 'screens/surah_learning_path/surah_learning_path_view_model.dart'
    as i583;
import 'services/message_service.dart' as i806;
import 'services/navigation_service.dart' as i912;

extension GetItInjectableX on i174.GetIt {
  i174.GetIt init({
    String? environment,
    i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = i526.GetItHelper(this, environment, environmentFilter);
    gh.factory<i318.ArrangePuzzleViewModel>(
      () => i318.ArrangePuzzleViewModel(),
    );
    gh.factory<i429.ConnnectMeaningViewModel>(
      () => i429.ConnnectMeaningViewModel(),
    );
    gh.factory<i679.SurahSelectionScreenViewModel>(
      () => i679.SurahSelectionScreenViewModel(),
    );
    gh.factory<i583.SurahLearningPathViewModel>(
      () => i583.SurahLearningPathViewModel(),
    );
    gh.singleton<i752.INavigationService>(() => i912.NavigationService());
    gh.singleton<i482.IMessageService>(() => i806.MessageService());
    return this;
  }
}
