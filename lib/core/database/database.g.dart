// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ClipboardItemsTableTable extends ClipboardItemsTable
    with TableInfo<$ClipboardItemsTableTable, ClipboardItemEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClipboardItemsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('text'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastUsedAtMeta = const VerificationMeta(
    'lastUsedAt',
  );
  @override
  late final GeneratedColumn<int> lastUsedAt = GeneratedColumn<int>(
    'last_used_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceAppMeta = const VerificationMeta(
    'sourceApp',
  );
  @override
  late final GeneratedColumn<String> sourceApp = GeneratedColumn<String>(
    'source_app',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    content,
    type,
    createdAt,
    lastUsedAt,
    sourceApp,
    isFavorite,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clipboard_items_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ClipboardItemEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_used_at')) {
      context.handle(
        _lastUsedAtMeta,
        lastUsedAt.isAcceptableOrUnknown(
          data['last_used_at']!,
          _lastUsedAtMeta,
        ),
      );
    }
    if (data.containsKey('source_app')) {
      context.handle(
        _sourceAppMeta,
        sourceApp.isAcceptableOrUnknown(data['source_app']!, _sourceAppMeta),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ClipboardItemEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClipboardItemEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      lastUsedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_used_at'],
      ),
      sourceApp: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_app'],
      ),
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
    );
  }

  @override
  $ClipboardItemsTableTable createAlias(String alias) {
    return $ClipboardItemsTableTable(attachedDatabase, alias);
  }
}

class ClipboardItemEntity extends DataClass
    implements Insertable<ClipboardItemEntity> {
  final int id;
  final String content;
  final String type;
  final int createdAt;
  final int? lastUsedAt;
  final String? sourceApp;
  final bool isFavorite;
  const ClipboardItemEntity({
    required this.id,
    required this.content,
    required this.type,
    required this.createdAt,
    this.lastUsedAt,
    this.sourceApp,
    required this.isFavorite,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['content'] = Variable<String>(content);
    map['type'] = Variable<String>(type);
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || lastUsedAt != null) {
      map['last_used_at'] = Variable<int>(lastUsedAt);
    }
    if (!nullToAbsent || sourceApp != null) {
      map['source_app'] = Variable<String>(sourceApp);
    }
    map['is_favorite'] = Variable<bool>(isFavorite);
    return map;
  }

  ClipboardItemsTableCompanion toCompanion(bool nullToAbsent) {
    return ClipboardItemsTableCompanion(
      id: Value(id),
      content: Value(content),
      type: Value(type),
      createdAt: Value(createdAt),
      lastUsedAt: lastUsedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUsedAt),
      sourceApp: sourceApp == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceApp),
      isFavorite: Value(isFavorite),
    );
  }

  factory ClipboardItemEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClipboardItemEntity(
      id: serializer.fromJson<int>(json['id']),
      content: serializer.fromJson<String>(json['content']),
      type: serializer.fromJson<String>(json['type']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      lastUsedAt: serializer.fromJson<int?>(json['lastUsedAt']),
      sourceApp: serializer.fromJson<String?>(json['sourceApp']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'content': serializer.toJson<String>(content),
      'type': serializer.toJson<String>(type),
      'createdAt': serializer.toJson<int>(createdAt),
      'lastUsedAt': serializer.toJson<int?>(lastUsedAt),
      'sourceApp': serializer.toJson<String?>(sourceApp),
      'isFavorite': serializer.toJson<bool>(isFavorite),
    };
  }

  ClipboardItemEntity copyWith({
    int? id,
    String? content,
    String? type,
    int? createdAt,
    Value<int?> lastUsedAt = const Value.absent(),
    Value<String?> sourceApp = const Value.absent(),
    bool? isFavorite,
  }) => ClipboardItemEntity(
    id: id ?? this.id,
    content: content ?? this.content,
    type: type ?? this.type,
    createdAt: createdAt ?? this.createdAt,
    lastUsedAt: lastUsedAt.present ? lastUsedAt.value : this.lastUsedAt,
    sourceApp: sourceApp.present ? sourceApp.value : this.sourceApp,
    isFavorite: isFavorite ?? this.isFavorite,
  );
  ClipboardItemEntity copyWithCompanion(ClipboardItemsTableCompanion data) {
    return ClipboardItemEntity(
      id: data.id.present ? data.id.value : this.id,
      content: data.content.present ? data.content.value : this.content,
      type: data.type.present ? data.type.value : this.type,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastUsedAt: data.lastUsedAt.present
          ? data.lastUsedAt.value
          : this.lastUsedAt,
      sourceApp: data.sourceApp.present ? data.sourceApp.value : this.sourceApp,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClipboardItemEntity(')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('type: $type, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUsedAt: $lastUsedAt, ')
          ..write('sourceApp: $sourceApp, ')
          ..write('isFavorite: $isFavorite')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    content,
    type,
    createdAt,
    lastUsedAt,
    sourceApp,
    isFavorite,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClipboardItemEntity &&
          other.id == this.id &&
          other.content == this.content &&
          other.type == this.type &&
          other.createdAt == this.createdAt &&
          other.lastUsedAt == this.lastUsedAt &&
          other.sourceApp == this.sourceApp &&
          other.isFavorite == this.isFavorite);
}

class ClipboardItemsTableCompanion
    extends UpdateCompanion<ClipboardItemEntity> {
  final Value<int> id;
  final Value<String> content;
  final Value<String> type;
  final Value<int> createdAt;
  final Value<int?> lastUsedAt;
  final Value<String?> sourceApp;
  final Value<bool> isFavorite;
  const ClipboardItemsTableCompanion({
    this.id = const Value.absent(),
    this.content = const Value.absent(),
    this.type = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
    this.sourceApp = const Value.absent(),
    this.isFavorite = const Value.absent(),
  });
  ClipboardItemsTableCompanion.insert({
    this.id = const Value.absent(),
    required String content,
    this.type = const Value.absent(),
    required int createdAt,
    this.lastUsedAt = const Value.absent(),
    this.sourceApp = const Value.absent(),
    this.isFavorite = const Value.absent(),
  }) : content = Value(content),
       createdAt = Value(createdAt);
  static Insertable<ClipboardItemEntity> custom({
    Expression<int>? id,
    Expression<String>? content,
    Expression<String>? type,
    Expression<int>? createdAt,
    Expression<int>? lastUsedAt,
    Expression<String>? sourceApp,
    Expression<bool>? isFavorite,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (content != null) 'content': content,
      if (type != null) 'type': type,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUsedAt != null) 'last_used_at': lastUsedAt,
      if (sourceApp != null) 'source_app': sourceApp,
      if (isFavorite != null) 'is_favorite': isFavorite,
    });
  }

  ClipboardItemsTableCompanion copyWith({
    Value<int>? id,
    Value<String>? content,
    Value<String>? type,
    Value<int>? createdAt,
    Value<int?>? lastUsedAt,
    Value<String?>? sourceApp,
    Value<bool>? isFavorite,
  }) {
    return ClipboardItemsTableCompanion(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      sourceApp: sourceApp ?? this.sourceApp,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (lastUsedAt.present) {
      map['last_used_at'] = Variable<int>(lastUsedAt.value);
    }
    if (sourceApp.present) {
      map['source_app'] = Variable<String>(sourceApp.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClipboardItemsTableCompanion(')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('type: $type, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUsedAt: $lastUsedAt, ')
          ..write('sourceApp: $sourceApp, ')
          ..write('isFavorite: $isFavorite')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ClipboardItemsTableTable clipboardItemsTable =
      $ClipboardItemsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [clipboardItemsTable];
}

typedef $$ClipboardItemsTableTableCreateCompanionBuilder =
    ClipboardItemsTableCompanion Function({
      Value<int> id,
      required String content,
      Value<String> type,
      required int createdAt,
      Value<int?> lastUsedAt,
      Value<String?> sourceApp,
      Value<bool> isFavorite,
    });
typedef $$ClipboardItemsTableTableUpdateCompanionBuilder =
    ClipboardItemsTableCompanion Function({
      Value<int> id,
      Value<String> content,
      Value<String> type,
      Value<int> createdAt,
      Value<int?> lastUsedAt,
      Value<String?> sourceApp,
      Value<bool> isFavorite,
    });

class $$ClipboardItemsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ClipboardItemsTableTable> {
  $$ClipboardItemsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceApp => $composableBuilder(
    column: $table.sourceApp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ClipboardItemsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ClipboardItemsTableTable> {
  $$ClipboardItemsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceApp => $composableBuilder(
    column: $table.sourceApp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ClipboardItemsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClipboardItemsTableTable> {
  $$ClipboardItemsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceApp =>
      $composableBuilder(column: $table.sourceApp, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );
}

class $$ClipboardItemsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClipboardItemsTableTable,
          ClipboardItemEntity,
          $$ClipboardItemsTableTableFilterComposer,
          $$ClipboardItemsTableTableOrderingComposer,
          $$ClipboardItemsTableTableAnnotationComposer,
          $$ClipboardItemsTableTableCreateCompanionBuilder,
          $$ClipboardItemsTableTableUpdateCompanionBuilder,
          (
            ClipboardItemEntity,
            BaseReferences<
              _$AppDatabase,
              $ClipboardItemsTableTable,
              ClipboardItemEntity
            >,
          ),
          ClipboardItemEntity,
          PrefetchHooks Function()
        > {
  $$ClipboardItemsTableTableTableManager(
    _$AppDatabase db,
    $ClipboardItemsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClipboardItemsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClipboardItemsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ClipboardItemsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int?> lastUsedAt = const Value.absent(),
                Value<String?> sourceApp = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
              }) => ClipboardItemsTableCompanion(
                id: id,
                content: content,
                type: type,
                createdAt: createdAt,
                lastUsedAt: lastUsedAt,
                sourceApp: sourceApp,
                isFavorite: isFavorite,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String content,
                Value<String> type = const Value.absent(),
                required int createdAt,
                Value<int?> lastUsedAt = const Value.absent(),
                Value<String?> sourceApp = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
              }) => ClipboardItemsTableCompanion.insert(
                id: id,
                content: content,
                type: type,
                createdAt: createdAt,
                lastUsedAt: lastUsedAt,
                sourceApp: sourceApp,
                isFavorite: isFavorite,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ClipboardItemsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClipboardItemsTableTable,
      ClipboardItemEntity,
      $$ClipboardItemsTableTableFilterComposer,
      $$ClipboardItemsTableTableOrderingComposer,
      $$ClipboardItemsTableTableAnnotationComposer,
      $$ClipboardItemsTableTableCreateCompanionBuilder,
      $$ClipboardItemsTableTableUpdateCompanionBuilder,
      (
        ClipboardItemEntity,
        BaseReferences<
          _$AppDatabase,
          $ClipboardItemsTableTable,
          ClipboardItemEntity
        >,
      ),
      ClipboardItemEntity,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ClipboardItemsTableTableTableManager get clipboardItemsTable =>
      $$ClipboardItemsTableTableTableManager(_db, _db.clipboardItemsTable);
}
