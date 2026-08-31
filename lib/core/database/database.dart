import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';


part 'database.g.dart';

@DataClassName('ClipboardItemEntity')
class ClipboardItemsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get content => text()();
  TextColumn get type => text().withDefault(const Constant('text'))();
  TextColumn get contentHash => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get lastUsedAt => integer().nullable()();
  TextColumn get sourceApp => text().nullable()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [ClipboardItemsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  factory AppDatabase.inMemory() => AppDatabase(NativeDatabase.memory());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await customStatement(
          'CREATE INDEX idx_created_at ON clipboard_items_table (created_at DESC);',
        );
        await customStatement(
          'CREATE INDEX idx_is_favorite ON clipboard_items_table (is_favorite);',
        );
        await customStatement(
          'CREATE UNIQUE INDEX idx_content_hash ON clipboard_items_table (content_hash) WHERE content_hash IS NOT NULL;',
        );
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.addColumn(
            clipboardItemsTable,
            clipboardItemsTable.contentHash,
          );
          await customStatement(
            'CREATE UNIQUE INDEX IF NOT EXISTS idx_content_hash ON clipboard_items_table (content_hash) WHERE content_hash IS NOT NULL;',
          );
        }
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
