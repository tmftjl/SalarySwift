// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $EmployeesTable extends Employees
    with TableInfo<$EmployeesTable, Employee> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EmployeesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<int> isActive = GeneratedColumn<int>(
      'is_active', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name, isActive, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'employees';
  @override
  VerificationContext validateIntegrity(Insertable<Employee> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Employee map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Employee(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $EmployeesTable createAlias(String alias) {
    return $EmployeesTable(attachedDatabase, alias);
  }
}

class Employee extends DataClass implements Insertable<Employee> {
  final int id;
  final String name;
  final int isActive;
  final int createdAt;
  const Employee(
      {required this.id,
      required this.name,
      required this.isActive,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['is_active'] = Variable<int>(isActive);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  EmployeesCompanion toCompanion(bool nullToAbsent) {
    return EmployeesCompanion(
      id: Value(id),
      name: Value(name),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory Employee.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Employee(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      isActive: serializer.fromJson<int>(json['isActive']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'isActive': serializer.toJson<int>(isActive),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  Employee copyWith({int? id, String? name, int? isActive, int? createdAt}) =>
      Employee(
        id: id ?? this.id,
        name: name ?? this.name,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
      );
  Employee copyWithCompanion(EmployeesCompanion data) {
    return Employee(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Employee(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, isActive, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Employee &&
          other.id == this.id &&
          other.name == this.name &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class EmployeesCompanion extends UpdateCompanion<Employee> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> isActive;
  final Value<int> createdAt;
  const EmployeesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  EmployeesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.isActive = const Value.absent(),
    required int createdAt,
  })  : name = Value(name),
        createdAt = Value(createdAt);
  static Insertable<Employee> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? isActive,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  EmployeesCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<int>? isActive,
      Value<int>? createdAt}) {
    return EmployeesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<int>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EmployeesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SalaryRecordsTable extends SalaryRecords
    with TableInfo<$SalaryRecordsTable, SalaryRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SalaryRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _employeeIdMeta =
      const VerificationMeta('employeeId');
  @override
  late final GeneratedColumn<int> employeeId = GeneratedColumn<int>(
      'employee_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES employees (id)'));
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('active'));
  static const VerificationMeta _batchKeyMeta =
      const VerificationMeta('batchKey');
  @override
  late final GeneratedColumn<String> batchKey = GeneratedColumn<String>(
      'batch_key', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, employeeId, amount, status, batchKey, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'salary_records';
  @override
  VerificationContext validateIntegrity(Insertable<SalaryRecord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('employee_id')) {
      context.handle(
          _employeeIdMeta,
          employeeId.isAcceptableOrUnknown(
              data['employee_id']!, _employeeIdMeta));
    } else if (isInserting) {
      context.missing(_employeeIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('batch_key')) {
      context.handle(_batchKeyMeta,
          batchKey.isAcceptableOrUnknown(data['batch_key']!, _batchKeyMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SalaryRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SalaryRecord(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      employeeId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}employee_id'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      batchKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}batch_key']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SalaryRecordsTable createAlias(String alias) {
    return $SalaryRecordsTable(attachedDatabase, alias);
  }
}

class SalaryRecord extends DataClass implements Insertable<SalaryRecord> {
  final int id;
  final int employeeId;
  final double amount;
  final String status;
  final String? batchKey;
  final int createdAt;
  const SalaryRecord(
      {required this.id,
      required this.employeeId,
      required this.amount,
      required this.status,
      this.batchKey,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['employee_id'] = Variable<int>(employeeId);
    map['amount'] = Variable<double>(amount);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || batchKey != null) {
      map['batch_key'] = Variable<String>(batchKey);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  SalaryRecordsCompanion toCompanion(bool nullToAbsent) {
    return SalaryRecordsCompanion(
      id: Value(id),
      employeeId: Value(employeeId),
      amount: Value(amount),
      status: Value(status),
      batchKey: batchKey == null && nullToAbsent
          ? const Value.absent()
          : Value(batchKey),
      createdAt: Value(createdAt),
    );
  }

  factory SalaryRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SalaryRecord(
      id: serializer.fromJson<int>(json['id']),
      employeeId: serializer.fromJson<int>(json['employeeId']),
      amount: serializer.fromJson<double>(json['amount']),
      status: serializer.fromJson<String>(json['status']),
      batchKey: serializer.fromJson<String?>(json['batchKey']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'employeeId': serializer.toJson<int>(employeeId),
      'amount': serializer.toJson<double>(amount),
      'status': serializer.toJson<String>(status),
      'batchKey': serializer.toJson<String?>(batchKey),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  SalaryRecord copyWith(
          {int? id,
          int? employeeId,
          double? amount,
          String? status,
          Value<String?> batchKey = const Value.absent(),
          int? createdAt}) =>
      SalaryRecord(
        id: id ?? this.id,
        employeeId: employeeId ?? this.employeeId,
        amount: amount ?? this.amount,
        status: status ?? this.status,
        batchKey: batchKey.present ? batchKey.value : this.batchKey,
        createdAt: createdAt ?? this.createdAt,
      );
  SalaryRecord copyWithCompanion(SalaryRecordsCompanion data) {
    return SalaryRecord(
      id: data.id.present ? data.id.value : this.id,
      employeeId:
          data.employeeId.present ? data.employeeId.value : this.employeeId,
      amount: data.amount.present ? data.amount.value : this.amount,
      status: data.status.present ? data.status.value : this.status,
      batchKey: data.batchKey.present ? data.batchKey.value : this.batchKey,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SalaryRecord(')
          ..write('id: $id, ')
          ..write('employeeId: $employeeId, ')
          ..write('amount: $amount, ')
          ..write('status: $status, ')
          ..write('batchKey: $batchKey, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, employeeId, amount, status, batchKey, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SalaryRecord &&
          other.id == this.id &&
          other.employeeId == this.employeeId &&
          other.amount == this.amount &&
          other.status == this.status &&
          other.batchKey == this.batchKey &&
          other.createdAt == this.createdAt);
}

class SalaryRecordsCompanion extends UpdateCompanion<SalaryRecord> {
  final Value<int> id;
  final Value<int> employeeId;
  final Value<double> amount;
  final Value<String> status;
  final Value<String?> batchKey;
  final Value<int> createdAt;
  const SalaryRecordsCompanion({
    this.id = const Value.absent(),
    this.employeeId = const Value.absent(),
    this.amount = const Value.absent(),
    this.status = const Value.absent(),
    this.batchKey = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SalaryRecordsCompanion.insert({
    this.id = const Value.absent(),
    required int employeeId,
    required double amount,
    this.status = const Value.absent(),
    this.batchKey = const Value.absent(),
    required int createdAt,
  })  : employeeId = Value(employeeId),
        amount = Value(amount),
        createdAt = Value(createdAt);
  static Insertable<SalaryRecord> custom({
    Expression<int>? id,
    Expression<int>? employeeId,
    Expression<double>? amount,
    Expression<String>? status,
    Expression<String>? batchKey,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (employeeId != null) 'employee_id': employeeId,
      if (amount != null) 'amount': amount,
      if (status != null) 'status': status,
      if (batchKey != null) 'batch_key': batchKey,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SalaryRecordsCompanion copyWith(
      {Value<int>? id,
      Value<int>? employeeId,
      Value<double>? amount,
      Value<String>? status,
      Value<String?>? batchKey,
      Value<int>? createdAt}) {
    return SalaryRecordsCompanion(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      batchKey: batchKey ?? this.batchKey,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (employeeId.present) {
      map['employee_id'] = Variable<int>(employeeId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (batchKey.present) {
      map['batch_key'] = Variable<String>(batchKey.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SalaryRecordsCompanion(')
          ..write('id: $id, ')
          ..write('employeeId: $employeeId, ')
          ..write('amount: $amount, ')
          ..write('status: $status, ')
          ..write('batchKey: $batchKey, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $EmployeesTable employees = $EmployeesTable(this);
  late final $SalaryRecordsTable salaryRecords = $SalaryRecordsTable(this);
  late final EmployeeDao employeeDao = EmployeeDao(this as AppDatabase);
  late final SalaryRecordDao salaryRecordDao =
      SalaryRecordDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [employees, salaryRecords];
}

typedef $$EmployeesTableCreateCompanionBuilder = EmployeesCompanion Function({
  Value<int> id,
  required String name,
  Value<int> isActive,
  required int createdAt,
});
typedef $$EmployeesTableUpdateCompanionBuilder = EmployeesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<int> isActive,
  Value<int> createdAt,
});

class $$EmployeesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EmployeesTable,
    Employee,
    $$EmployeesTableFilterComposer,
    $$EmployeesTableOrderingComposer,
    $$EmployeesTableCreateCompanionBuilder,
    $$EmployeesTableUpdateCompanionBuilder> {
  $$EmployeesTableTableManager(_$AppDatabase db, $EmployeesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$EmployeesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$EmployeesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> isActive = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
          }) =>
              EmployeesCompanion(
            id: id,
            name: name,
            isActive: isActive,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<int> isActive = const Value.absent(),
            required int createdAt,
          }) =>
              EmployeesCompanion.insert(
            id: id,
            name: name,
            isActive: isActive,
            createdAt: createdAt,
          ),
        ));
}

class $$EmployeesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $EmployeesTable> {
  $$EmployeesTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get isActive => $state.composableBuilder(
      column: $state.table.isActive,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter salaryRecordsRefs(
      ComposableFilter Function($$SalaryRecordsTableFilterComposer f) f) {
    final $$SalaryRecordsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.salaryRecords,
        getReferencedColumn: (t) => t.employeeId,
        builder: (joinBuilder, parentComposers) =>
            $$SalaryRecordsTableFilterComposer(ComposerState($state.db,
                $state.db.salaryRecords, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$EmployeesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $EmployeesTable> {
  $$EmployeesTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get isActive => $state.composableBuilder(
      column: $state.table.isActive,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$SalaryRecordsTableCreateCompanionBuilder = SalaryRecordsCompanion
    Function({
  Value<int> id,
  required int employeeId,
  required double amount,
  Value<String> status,
  Value<String?> batchKey,
  required int createdAt,
});
typedef $$SalaryRecordsTableUpdateCompanionBuilder = SalaryRecordsCompanion
    Function({
  Value<int> id,
  Value<int> employeeId,
  Value<double> amount,
  Value<String> status,
  Value<String?> batchKey,
  Value<int> createdAt,
});

class $$SalaryRecordsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SalaryRecordsTable,
    SalaryRecord,
    $$SalaryRecordsTableFilterComposer,
    $$SalaryRecordsTableOrderingComposer,
    $$SalaryRecordsTableCreateCompanionBuilder,
    $$SalaryRecordsTableUpdateCompanionBuilder> {
  $$SalaryRecordsTableTableManager(_$AppDatabase db, $SalaryRecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$SalaryRecordsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$SalaryRecordsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> employeeId = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> batchKey = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
          }) =>
              SalaryRecordsCompanion(
            id: id,
            employeeId: employeeId,
            amount: amount,
            status: status,
            batchKey: batchKey,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int employeeId,
            required double amount,
            Value<String> status = const Value.absent(),
            Value<String?> batchKey = const Value.absent(),
            required int createdAt,
          }) =>
              SalaryRecordsCompanion.insert(
            id: id,
            employeeId: employeeId,
            amount: amount,
            status: status,
            batchKey: batchKey,
            createdAt: createdAt,
          ),
        ));
}

class $$SalaryRecordsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $SalaryRecordsTable> {
  $$SalaryRecordsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get amount => $state.composableBuilder(
      column: $state.table.amount,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get batchKey => $state.composableBuilder(
      column: $state.table.batchKey,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$EmployeesTableFilterComposer get employeeId {
    final $$EmployeesTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.employeeId,
        referencedTable: $state.db.employees,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$EmployeesTableFilterComposer(ComposerState(
                $state.db, $state.db.employees, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$SalaryRecordsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $SalaryRecordsTable> {
  $$SalaryRecordsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get amount => $state.composableBuilder(
      column: $state.table.amount,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get batchKey => $state.composableBuilder(
      column: $state.table.batchKey,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$EmployeesTableOrderingComposer get employeeId {
    final $$EmployeesTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.employeeId,
        referencedTable: $state.db.employees,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$EmployeesTableOrderingComposer(ComposerState(
                $state.db, $state.db.employees, joinBuilder, parentComposers)));
    return composer;
  }
}

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$EmployeesTableTableManager get employees =>
      $$EmployeesTableTableManager(_db, _db.employees);
  $$SalaryRecordsTableTableManager get salaryRecords =>
      $$SalaryRecordsTableTableManager(_db, _db.salaryRecords);
}
