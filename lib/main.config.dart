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
import 'services/message_service.dart' as _i806;
import 'services/navigation_service.dart' as _i912;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.singleton<_i752.INavigationService>(() => _i912.NavigationService());
    gh.singleton<_i482.IMessageService>(() => _i806.MessageService());
    return this;
  }
}
