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
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
      'year', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _monthMeta = const VerificationMeta('month');
  @override
  late final GeneratedColumn<int> month = GeneratedColumn<int>(
      'month', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
      'amount', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, employeeId, year, month, amount];
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
    if (data.containsKey('year')) {
      context.handle(
          _yearMeta, year.isAcceptableOrUnknown(data['year']!, _yearMeta));
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    if (data.containsKey('month')) {
      context.handle(
          _monthMeta, month.isAcceptableOrUnknown(data['month']!, _monthMeta));
    } else if (isInserting) {
      context.missing(_monthMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {employeeId, year, month},
      ];
  @override
  SalaryRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SalaryRecord(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      employeeId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}employee_id'])!,
      year: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}year'])!,
      month: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}month'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount'])!,
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
  final int year;
  final int month;
  final int amount;
  const SalaryRecord(
      {required this.id,
      required this.employeeId,
      required this.year,
      required this.month,
      required this.amount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['employee_id'] = Variable<int>(employeeId);
    map['year'] = Variable<int>(year);
    map['month'] = Variable<int>(month);
    map['amount'] = Variable<int>(amount);
    return map;
  }

  SalaryRecordsCompanion toCompanion(bool nullToAbsent) {
    return SalaryRecordsCompanion(
      id: Value(id),
      employeeId: Value(employeeId),
      year: Value(year),
      month: Value(month),
      amount: Value(amount),
    );
  }

  factory SalaryRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SalaryRecord(
      id: serializer.fromJson<int>(json['id']),
      employeeId: serializer.fromJson<int>(json['employeeId']),
      year: serializer.fromJson<int>(json['year']),
      month: serializer.fromJson<int>(json['month']),
      amount: serializer.fromJson<int>(json['amount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'employeeId': serializer.toJson<int>(employeeId),
      'year': serializer.toJson<int>(year),
      'month': serializer.toJson<int>(month),
      'amount': serializer.toJson<int>(amount),
    };
  }

  SalaryRecord copyWith(
          {int? id, int? employeeId, int? year, int? month, int? amount}) =>
      SalaryRecord(
        id: id ?? this.id,
        employeeId: employeeId ?? this.employeeId,
        year: year ?? this.year,
        month: month ?? this.month,
        amount: amount ?? this.amount,
      );
  SalaryRecord copyWithCompanion(SalaryRecordsCompanion data) {
    return SalaryRecord(
      id: data.id.present ? data.id.value : this.id,
      employeeId:
          data.employeeId.present ? data.employeeId.value : this.employeeId,
      year: data.year.present ? data.year.value : this.year,
      month: data.month.present ? data.month.value : this.month,
      amount: data.amount.present ? data.amount.value : this.amount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SalaryRecord(')
          ..write('id: $id, ')
          ..write('employeeId: $employeeId, ')
          ..write('year: $year, ')
          ..write('month: $month, ')
          ..write('amount: $amount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, employeeId, year, month, amount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SalaryRecord &&
          other.id == this.id &&
          other.employeeId == this.employeeId &&
          other.year == this.year &&
          other.month == this.month &&
          other.amount == this.amount);
}

class SalaryRecordsCompanion extends UpdateCompanion<SalaryRecord> {
  final Value<int> id;
  final Value<int> employeeId;
  final Value<int> year;
  final Value<int> month;
  final Value<int> amount;
  const SalaryRecordsCompanion({
    this.id = const Value.absent(),
    this.employeeId = const Value.absent(),
    this.year = const Value.absent(),
    this.month = const Value.absent(),
    this.amount = const Value.absent(),
  });
  SalaryRecordsCompanion.insert({
    this.id = const Value.absent(),
    required int employeeId,
    required int year,
    required int month,
    required int amount,
  })  : employeeId = Value(employeeId),
        year = Value(year),
        month = Value(month),
        amount = Value(amount);
  static Insertable<SalaryRecord> custom({
    Expression<int>? id,
    Expression<int>? employeeId,
    Expression<int>? year,
    Expression<int>? month,
    Expression<int>? amount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (employeeId != null) 'employee_id': employeeId,
      if (year != null) 'year': year,
      if (month != null) 'month': month,
      if (amount != null) 'amount': amount,
    });
  }

  SalaryRecordsCompanion copyWith(
      {Value<int>? id,
      Value<int>? employeeId,
      Value<int>? year,
      Value<int>? month,
      Value<int>? amount}) {
    return SalaryRecordsCompanion(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      year: year ?? this.year,
      month: month ?? this.month,
      amount: amount ?? this.amount,
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
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (month.present) {
      map['month'] = Variable<int>(month.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SalaryRecordsCompanion(')
          ..write('id: $id, ')
          ..write('employeeId: $employeeId, ')
          ..write('year: $year, ')
          ..write('month: $month, ')
          ..write('amount: $amount')
          ..write(')'))
        .toString();
  }
}

class $BatchesTable extends Batches with TableInfo<$BatchesTable, SalaryBatch> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BatchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _startYearMeta =
      const VerificationMeta('startYear');
  @override
  late final GeneratedColumn<int> startYear = GeneratedColumn<int>(
      'start_year', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _startMonthMeta =
      const VerificationMeta('startMonth');
  @override
  late final GeneratedColumn<int> startMonth = GeneratedColumn<int>(
      'start_month', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _endYearMeta =
      const VerificationMeta('endYear');
  @override
  late final GeneratedColumn<int> endYear = GeneratedColumn<int>(
      'end_year', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _endMonthMeta =
      const VerificationMeta('endMonth');
  @override
  late final GeneratedColumn<int> endMonth = GeneratedColumn<int>(
      'end_month', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, startYear, startMonth, endYear, endMonth, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'batches';
  @override
  VerificationContext validateIntegrity(Insertable<SalaryBatch> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('start_year')) {
      context.handle(_startYearMeta,
          startYear.isAcceptableOrUnknown(data['start_year']!, _startYearMeta));
    } else if (isInserting) {
      context.missing(_startYearMeta);
    }
    if (data.containsKey('start_month')) {
      context.handle(
          _startMonthMeta,
          startMonth.isAcceptableOrUnknown(
              data['start_month']!, _startMonthMeta));
    } else if (isInserting) {
      context.missing(_startMonthMeta);
    }
    if (data.containsKey('end_year')) {
      context.handle(_endYearMeta,
          endYear.isAcceptableOrUnknown(data['end_year']!, _endYearMeta));
    } else if (isInserting) {
      context.missing(_endYearMeta);
    }
    if (data.containsKey('end_month')) {
      context.handle(_endMonthMeta,
          endMonth.isAcceptableOrUnknown(data['end_month']!, _endMonthMeta));
    } else if (isInserting) {
      context.missing(_endMonthMeta);
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
  SalaryBatch map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SalaryBatch(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      startYear: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}start_year'])!,
      startMonth: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}start_month'])!,
      endYear: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}end_year'])!,
      endMonth: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}end_month'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $BatchesTable createAlias(String alias) {
    return $BatchesTable(attachedDatabase, alias);
  }
}

class SalaryBatch extends DataClass implements Insertable<SalaryBatch> {
  final int id;
  final int startYear;
  final int startMonth;
  final int endYear;
  final int endMonth;
  final int createdAt;
  const SalaryBatch(
      {required this.id,
      required this.startYear,
      required this.startMonth,
      required this.endYear,
      required this.endMonth,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['start_year'] = Variable<int>(startYear);
    map['start_month'] = Variable<int>(startMonth);
    map['end_year'] = Variable<int>(endYear);
    map['end_month'] = Variable<int>(endMonth);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  BatchesCompanion toCompanion(bool nullToAbsent) {
    return BatchesCompanion(
      id: Value(id),
      startYear: Value(startYear),
      startMonth: Value(startMonth),
      endYear: Value(endYear),
      endMonth: Value(endMonth),
      createdAt: Value(createdAt),
    );
  }

  factory SalaryBatch.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SalaryBatch(
      id: serializer.fromJson<int>(json['id']),
      startYear: serializer.fromJson<int>(json['startYear']),
      startMonth: serializer.fromJson<int>(json['startMonth']),
      endYear: serializer.fromJson<int>(json['endYear']),
      endMonth: serializer.fromJson<int>(json['endMonth']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'startYear': serializer.toJson<int>(startYear),
      'startMonth': serializer.toJson<int>(startMonth),
      'endYear': serializer.toJson<int>(endYear),
      'endMonth': serializer.toJson<int>(endMonth),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  SalaryBatch copyWith(
          {int? id,
          int? startYear,
          int? startMonth,
          int? endYear,
          int? endMonth,
          int? createdAt}) =>
      SalaryBatch(
        id: id ?? this.id,
        startYear: startYear ?? this.startYear,
        startMonth: startMonth ?? this.startMonth,
        endYear: endYear ?? this.endYear,
        endMonth: endMonth ?? this.endMonth,
        createdAt: createdAt ?? this.createdAt,
      );
  SalaryBatch copyWithCompanion(BatchesCompanion data) {
    return SalaryBatch(
      id: data.id.present ? data.id.value : this.id,
      startYear: data.startYear.present ? data.startYear.value : this.startYear,
      startMonth:
          data.startMonth.present ? data.startMonth.value : this.startMonth,
      endYear: data.endYear.present ? data.endYear.value : this.endYear,
      endMonth: data.endMonth.present ? data.endMonth.value : this.endMonth,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SalaryBatch(')
          ..write('id: $id, ')
          ..write('startYear: $startYear, ')
          ..write('startMonth: $startMonth, ')
          ..write('endYear: $endYear, ')
          ..write('endMonth: $endMonth, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, startYear, startMonth, endYear, endMonth, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SalaryBatch &&
          other.id == this.id &&
          other.startYear == this.startYear &&
          other.startMonth == this.startMonth &&
          other.endYear == this.endYear &&
          other.endMonth == this.endMonth &&
          other.createdAt == this.createdAt);
}

class BatchesCompanion extends UpdateCompanion<SalaryBatch> {
  final Value<int> id;
  final Value<int> startYear;
  final Value<int> startMonth;
  final Value<int> endYear;
  final Value<int> endMonth;
  final Value<int> createdAt;
  const BatchesCompanion({
    this.id = const Value.absent(),
    this.startYear = const Value.absent(),
    this.startMonth = const Value.absent(),
    this.endYear = const Value.absent(),
    this.endMonth = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  BatchesCompanion.insert({
    this.id = const Value.absent(),
    required int startYear,
    required int startMonth,
    required int endYear,
    required int endMonth,
    required int createdAt,
  })  : startYear = Value(startYear),
        startMonth = Value(startMonth),
        endYear = Value(endYear),
        endMonth = Value(endMonth),
        createdAt = Value(createdAt);
  static Insertable<SalaryBatch> custom({
    Expression<int>? id,
    Expression<int>? startYear,
    Expression<int>? startMonth,
    Expression<int>? endYear,
    Expression<int>? endMonth,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startYear != null) 'start_year': startYear,
      if (startMonth != null) 'start_month': startMonth,
      if (endYear != null) 'end_year': endYear,
      if (endMonth != null) 'end_month': endMonth,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  BatchesCompanion copyWith(
      {Value<int>? id,
      Value<int>? startYear,
      Value<int>? startMonth,
      Value<int>? endYear,
      Value<int>? endMonth,
      Value<int>? createdAt}) {
    return BatchesCompanion(
      id: id ?? this.id,
      startYear: startYear ?? this.startYear,
      startMonth: startMonth ?? this.startMonth,
      endYear: endYear ?? this.endYear,
      endMonth: endMonth ?? this.endMonth,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (startYear.present) {
      map['start_year'] = Variable<int>(startYear.value);
    }
    if (startMonth.present) {
      map['start_month'] = Variable<int>(startMonth.value);
    }
    if (endYear.present) {
      map['end_year'] = Variable<int>(endYear.value);
    }
    if (endMonth.present) {
      map['end_month'] = Variable<int>(endMonth.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BatchesCompanion(')
          ..write('id: $id, ')
          ..write('startYear: $startYear, ')
          ..write('startMonth: $startMonth, ')
          ..write('endYear: $endYear, ')
          ..write('endMonth: $endMonth, ')
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
  late final $BatchesTable batches = $BatchesTable(this);
  late final EmployeeDao employeeDao = EmployeeDao(this as AppDatabase);
  late final SalaryRecordDao salaryRecordDao =
      SalaryRecordDao(this as AppDatabase);
  late final BatchDao batchDao = BatchDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [employees, salaryRecords, batches];
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
  required int year,
  required int month,
  required int amount,
});
typedef $$SalaryRecordsTableUpdateCompanionBuilder = SalaryRecordsCompanion
    Function({
  Value<int> id,
  Value<int> employeeId,
  Value<int> year,
  Value<int> month,
  Value<int> amount,
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
            Value<int> year = const Value.absent(),
            Value<int> month = const Value.absent(),
            Value<int> amount = const Value.absent(),
          }) =>
              SalaryRecordsCompanion(
            id: id,
            employeeId: employeeId,
            year: year,
            month: month,
            amount: amount,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int employeeId,
            required int year,
            required int month,
            required int amount,
          }) =>
              SalaryRecordsCompanion.insert(
            id: id,
            employeeId: employeeId,
            year: year,
            month: month,
            amount: amount,
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

  ColumnFilters<int> get year => $state.composableBuilder(
      column: $state.table.year,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get month => $state.composableBuilder(
      column: $state.table.month,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get amount => $state.composableBuilder(
      column: $state.table.amount,
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

  ColumnOrderings<int> get year => $state.composableBuilder(
      column: $state.table.year,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get month => $state.composableBuilder(
      column: $state.table.month,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get amount => $state.composableBuilder(
      column: $state.table.amount,
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

typedef $$BatchesTableCreateCompanionBuilder = BatchesCompanion Function({
  Value<int> id,
  required int startYear,
  required int startMonth,
  required int endYear,
  required int endMonth,
  required int createdAt,
});
typedef $$BatchesTableUpdateCompanionBuilder = BatchesCompanion Function({
  Value<int> id,
  Value<int> startYear,
  Value<int> startMonth,
  Value<int> endYear,
  Value<int> endMonth,
  Value<int> createdAt,
});

class $$BatchesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BatchesTable,
    SalaryBatch,
    $$BatchesTableFilterComposer,
    $$BatchesTableOrderingComposer,
    $$BatchesTableCreateCompanionBuilder,
    $$BatchesTableUpdateCompanionBuilder> {
  $$BatchesTableTableManager(_$AppDatabase db, $BatchesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$BatchesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$BatchesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> startYear = const Value.absent(),
            Value<int> startMonth = const Value.absent(),
            Value<int> endYear = const Value.absent(),
            Value<int> endMonth = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
          }) =>
              BatchesCompanion(
            id: id,
            startYear: startYear,
            startMonth: startMonth,
            endYear: endYear,
            endMonth: endMonth,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int startYear,
            required int startMonth,
            required int endYear,
            required int endMonth,
            required int createdAt,
          }) =>
              BatchesCompanion.insert(
            id: id,
            startYear: startYear,
            startMonth: startMonth,
            endYear: endYear,
            endMonth: endMonth,
            createdAt: createdAt,
          ),
        ));
}

class $$BatchesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $BatchesTable> {
  $$BatchesTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get startYear => $state.composableBuilder(
      column: $state.table.startYear,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get startMonth => $state.composableBuilder(
      column: $state.table.startMonth,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get endYear => $state.composableBuilder(
      column: $state.table.endYear,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get endMonth => $state.composableBuilder(
      column: $state.table.endMonth,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$BatchesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $BatchesTable> {
  $$BatchesTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get startYear => $state.composableBuilder(
      column: $state.table.startYear,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get startMonth => $state.composableBuilder(
      column: $state.table.startMonth,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get endYear => $state.composableBuilder(
      column: $state.table.endYear,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get endMonth => $state.composableBuilder(
      column: $state.table.endMonth,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$EmployeesTableTableManager get employees =>
      $$EmployeesTableTableManager(_db, _db.employees);
  $$SalaryRecordsTableTableManager get salaryRecords =>
      $$SalaryRecordsTableTableManager(_db, _db.salaryRecords);
  $$BatchesTableTableManager get batches =>
      $$BatchesTableTableManager(_db, _db.batches);
}
