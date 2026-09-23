import 'package:flutter/widgets.dart';
import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'data/repositories/progress_repository.dart';
import 'presentation/state/app_state.dart';
import 'services/ads_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Local storage: single JSON document in a Hive box.
  final dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);
  final box = await Hive.openBox<String>('nevermindspark_state');
  final repository = ProgressRepository(HiveProgressStore(box));

  // Kick off ad init early so the first banner/rewarded ad has headroom to
  // load. Failure here is non-fatal — the UI hides ads gracefully.
  AdsService.instance.init();

  runApp(App(appState: AppState(repository: repository)));
}