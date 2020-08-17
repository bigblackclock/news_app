import 'package:get_it/get_it.dart';
import 'package:news_app/data/news_api.dart';
import 'package:news_app/data/persistent_database.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerSingleton<NewsAPI>(NewsAPI.create());
  locator.registerSingleton<PersistentDatabase>(PersistentDatabase());
}