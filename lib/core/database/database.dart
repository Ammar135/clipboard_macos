import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';


part 'database.g.dart';

@DataClassName('ClipboardItemEntity')
class ClipboardItemsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get content => text()();
  TextColumn get type => text().withDefault(const Constant('text'))();
  IntColumn get createdAt => integer()();
  IntColumn get lastUsedAt => integer().nullable()();
  TextColumn get sourceApp => text().nullable()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [ClipboardItemsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        // Create indexes
        await customStatement('CREATE INDEX idx_created_at ON clipboard_items_table (created_at DESC);');
        await customStatement('CREATE INDEX idx_is_favorite ON clipboard_items_table (is_favorite);');
      },
    );
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'clipboard_db',
      native: const DriftNativeOptions(
        // By default, drift_flutter stores the db in getApplicationDocumentsDirectory
        // However, we want it in Application Support. We can specify path manually if needed, 
        // but drift_flutter's default is fine for MVP (it uses getApplicationSupportDirectory on macOS).
      ),
    );
  }
}
