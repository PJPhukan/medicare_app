// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $OutboxTableTable extends OutboxTable
    with TableInfo<$OutboxTableTable, OutboxRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _featureMeta =
      const VerificationMeta('feature');
  @override
  late final GeneratedColumn<String> feature = GeneratedColumn<String>(
      'feature', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
      'action', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, feature, action, payload, createdAt, retryCount];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox';
  @override
  VerificationContext validateIntegrity(Insertable<OutboxRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('feature')) {
      context.handle(_featureMeta,
          feature.isAcceptableOrUnknown(data['feature']!, _featureMeta));
    } else if (isInserting) {
      context.missing(_featureMeta);
    }
    if (data.containsKey('action')) {
      context.handle(_actionMeta,
          action.isAcceptableOrUnknown(data['action']!, _actionMeta));
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OutboxRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      feature: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}feature'])!,
      action: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
    );
  }

  @override
  $OutboxTableTable createAlias(String alias) {
    return $OutboxTableTable(attachedDatabase, alias);
  }
}

class OutboxRow extends DataClass implements Insertable<OutboxRow> {
  final String id;
  final String feature;
  final String action;
  final String payload;
  final int createdAt;
  final int retryCount;
  const OutboxRow(
      {required this.id,
      required this.feature,
      required this.action,
      required this.payload,
      required this.createdAt,
      required this.retryCount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['feature'] = Variable<String>(feature);
    map['action'] = Variable<String>(action);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<int>(createdAt);
    map['retry_count'] = Variable<int>(retryCount);
    return map;
  }

  OutboxTableCompanion toCompanion(bool nullToAbsent) {
    return OutboxTableCompanion(
      id: Value(id),
      feature: Value(feature),
      action: Value(action),
      payload: Value(payload),
      createdAt: Value(createdAt),
      retryCount: Value(retryCount),
    );
  }

  factory OutboxRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxRow(
      id: serializer.fromJson<String>(json['id']),
      feature: serializer.fromJson<String>(json['feature']),
      action: serializer.fromJson<String>(json['action']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'feature': serializer.toJson<String>(feature),
      'action': serializer.toJson<String>(action),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<int>(createdAt),
      'retryCount': serializer.toJson<int>(retryCount),
    };
  }

  OutboxRow copyWith(
          {String? id,
          String? feature,
          String? action,
          String? payload,
          int? createdAt,
          int? retryCount}) =>
      OutboxRow(
        id: id ?? this.id,
        feature: feature ?? this.feature,
        action: action ?? this.action,
        payload: payload ?? this.payload,
        createdAt: createdAt ?? this.createdAt,
        retryCount: retryCount ?? this.retryCount,
      );
  OutboxRow copyWithCompanion(OutboxTableCompanion data) {
    return OutboxRow(
      id: data.id.present ? data.id.value : this.id,
      feature: data.feature.present ? data.feature.value : this.feature,
      action: data.action.present ? data.action.value : this.action,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxRow(')
          ..write('id: $id, ')
          ..write('feature: $feature, ')
          ..write('action: $action, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, feature, action, payload, createdAt, retryCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxRow &&
          other.id == this.id &&
          other.feature == this.feature &&
          other.action == this.action &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt &&
          other.retryCount == this.retryCount);
}

class OutboxTableCompanion extends UpdateCompanion<OutboxRow> {
  final Value<String> id;
  final Value<String> feature;
  final Value<String> action;
  final Value<String> payload;
  final Value<int> createdAt;
  final Value<int> retryCount;
  final Value<int> rowid;
  const OutboxTableCompanion({
    this.id = const Value.absent(),
    this.feature = const Value.absent(),
    this.action = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OutboxTableCompanion.insert({
    required String id,
    required String feature,
    required String action,
    required String payload,
    required int createdAt,
    this.retryCount = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        feature = Value(feature),
        action = Value(action),
        payload = Value(payload),
        createdAt = Value(createdAt);
  static Insertable<OutboxRow> custom({
    Expression<String>? id,
    Expression<String>? feature,
    Expression<String>? action,
    Expression<String>? payload,
    Expression<int>? createdAt,
    Expression<int>? retryCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (feature != null) 'feature': feature,
      if (action != null) 'action': action,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (retryCount != null) 'retry_count': retryCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OutboxTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? feature,
      Value<String>? action,
      Value<String>? payload,
      Value<int>? createdAt,
      Value<int>? retryCount,
      Value<int>? rowid}) {
    return OutboxTableCompanion(
      id: id ?? this.id,
      feature: feature ?? this.feature,
      action: action ?? this.action,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (feature.present) {
      map['feature'] = Variable<String>(feature.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxTableCompanion(')
          ..write('id: $id, ')
          ..write('feature: $feature, ')
          ..write('action: $action, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MedicinesTableTable extends MedicinesTable
    with TableInfo<$MedicinesTableTable, MedicineRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicinesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _rawJsonMeta =
      const VerificationMeta('rawJson');
  @override
  late final GeneratedColumn<String> rawJson = GeneratedColumn<String>(
      'raw_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, rawJson, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medicines';
  @override
  VerificationContext validateIntegrity(Insertable<MedicineRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('raw_json')) {
      context.handle(_rawJsonMeta,
          rawJson.isAcceptableOrUnknown(data['raw_json']!, _rawJsonMeta));
    } else if (isInserting) {
      context.missing(_rawJsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MedicineRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MedicineRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      rawJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}raw_json'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $MedicinesTableTable createAlias(String alias) {
    return $MedicinesTableTable(attachedDatabase, alias);
  }
}

class MedicineRow extends DataClass implements Insertable<MedicineRow> {
  final String id;
  final String rawJson;
  final int updatedAt;
  const MedicineRow(
      {required this.id, required this.rawJson, required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['raw_json'] = Variable<String>(rawJson);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  MedicinesTableCompanion toCompanion(bool nullToAbsent) {
    return MedicinesTableCompanion(
      id: Value(id),
      rawJson: Value(rawJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory MedicineRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MedicineRow(
      id: serializer.fromJson<String>(json['id']),
      rawJson: serializer.fromJson<String>(json['rawJson']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'rawJson': serializer.toJson<String>(rawJson),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  MedicineRow copyWith({String? id, String? rawJson, int? updatedAt}) =>
      MedicineRow(
        id: id ?? this.id,
        rawJson: rawJson ?? this.rawJson,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  MedicineRow copyWithCompanion(MedicinesTableCompanion data) {
    return MedicineRow(
      id: data.id.present ? data.id.value : this.id,
      rawJson: data.rawJson.present ? data.rawJson.value : this.rawJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MedicineRow(')
          ..write('id: $id, ')
          ..write('rawJson: $rawJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, rawJson, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MedicineRow &&
          other.id == this.id &&
          other.rawJson == this.rawJson &&
          other.updatedAt == this.updatedAt);
}

class MedicinesTableCompanion extends UpdateCompanion<MedicineRow> {
  final Value<String> id;
  final Value<String> rawJson;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const MedicinesTableCompanion({
    this.id = const Value.absent(),
    this.rawJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MedicinesTableCompanion.insert({
    required String id,
    required String rawJson,
    required int updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        rawJson = Value(rawJson),
        updatedAt = Value(updatedAt);
  static Insertable<MedicineRow> custom({
    Expression<String>? id,
    Expression<String>? rawJson,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rawJson != null) 'raw_json': rawJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MedicinesTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? rawJson,
      Value<int>? updatedAt,
      Value<int>? rowid}) {
    return MedicinesTableCompanion(
      id: id ?? this.id,
      rawJson: rawJson ?? this.rawJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (rawJson.present) {
      map['raw_json'] = Variable<String>(rawJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicinesTableCompanion(')
          ..write('id: $id, ')
          ..write('rawJson: $rawJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VitalsTableTable extends VitalsTable
    with TableInfo<$VitalsTableTable, VitalRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VitalsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _vitalConfigIdMeta =
      const VerificationMeta('vitalConfigId');
  @override
  late final GeneratedColumn<String> vitalConfigId = GeneratedColumn<String>(
      'vital_config_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _measuredAtMeta =
      const VerificationMeta('measuredAt');
  @override
  late final GeneratedColumn<int> measuredAt = GeneratedColumn<int>(
      'measured_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _rawJsonMeta =
      const VerificationMeta('rawJson');
  @override
  late final GeneratedColumn<String> rawJson = GeneratedColumn<String>(
      'raw_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, vitalConfigId, measuredAt, rawJson, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vitals';
  @override
  VerificationContext validateIntegrity(Insertable<VitalRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('vital_config_id')) {
      context.handle(
          _vitalConfigIdMeta,
          vitalConfigId.isAcceptableOrUnknown(
              data['vital_config_id']!, _vitalConfigIdMeta));
    } else if (isInserting) {
      context.missing(_vitalConfigIdMeta);
    }
    if (data.containsKey('measured_at')) {
      context.handle(
          _measuredAtMeta,
          measuredAt.isAcceptableOrUnknown(
              data['measured_at']!, _measuredAtMeta));
    } else if (isInserting) {
      context.missing(_measuredAtMeta);
    }
    if (data.containsKey('raw_json')) {
      context.handle(_rawJsonMeta,
          rawJson.isAcceptableOrUnknown(data['raw_json']!, _rawJsonMeta));
    } else if (isInserting) {
      context.missing(_rawJsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VitalRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VitalRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      vitalConfigId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}vital_config_id'])!,
      measuredAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}measured_at'])!,
      rawJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}raw_json'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $VitalsTableTable createAlias(String alias) {
    return $VitalsTableTable(attachedDatabase, alias);
  }
}

class VitalRow extends DataClass implements Insertable<VitalRow> {
  final String id;
  final String vitalConfigId;
  final int measuredAt;
  final String rawJson;
  final int updatedAt;
  const VitalRow(
      {required this.id,
      required this.vitalConfigId,
      required this.measuredAt,
      required this.rawJson,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['vital_config_id'] = Variable<String>(vitalConfigId);
    map['measured_at'] = Variable<int>(measuredAt);
    map['raw_json'] = Variable<String>(rawJson);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  VitalsTableCompanion toCompanion(bool nullToAbsent) {
    return VitalsTableCompanion(
      id: Value(id),
      vitalConfigId: Value(vitalConfigId),
      measuredAt: Value(measuredAt),
      rawJson: Value(rawJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory VitalRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VitalRow(
      id: serializer.fromJson<String>(json['id']),
      vitalConfigId: serializer.fromJson<String>(json['vitalConfigId']),
      measuredAt: serializer.fromJson<int>(json['measuredAt']),
      rawJson: serializer.fromJson<String>(json['rawJson']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'vitalConfigId': serializer.toJson<String>(vitalConfigId),
      'measuredAt': serializer.toJson<int>(measuredAt),
      'rawJson': serializer.toJson<String>(rawJson),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  VitalRow copyWith(
          {String? id,
          String? vitalConfigId,
          int? measuredAt,
          String? rawJson,
          int? updatedAt}) =>
      VitalRow(
        id: id ?? this.id,
        vitalConfigId: vitalConfigId ?? this.vitalConfigId,
        measuredAt: measuredAt ?? this.measuredAt,
        rawJson: rawJson ?? this.rawJson,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  VitalRow copyWithCompanion(VitalsTableCompanion data) {
    return VitalRow(
      id: data.id.present ? data.id.value : this.id,
      vitalConfigId: data.vitalConfigId.present
          ? data.vitalConfigId.value
          : this.vitalConfigId,
      measuredAt:
          data.measuredAt.present ? data.measuredAt.value : this.measuredAt,
      rawJson: data.rawJson.present ? data.rawJson.value : this.rawJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VitalRow(')
          ..write('id: $id, ')
          ..write('vitalConfigId: $vitalConfigId, ')
          ..write('measuredAt: $measuredAt, ')
          ..write('rawJson: $rawJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, vitalConfigId, measuredAt, rawJson, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VitalRow &&
          other.id == this.id &&
          other.vitalConfigId == this.vitalConfigId &&
          other.measuredAt == this.measuredAt &&
          other.rawJson == this.rawJson &&
          other.updatedAt == this.updatedAt);
}

class VitalsTableCompanion extends UpdateCompanion<VitalRow> {
  final Value<String> id;
  final Value<String> vitalConfigId;
  final Value<int> measuredAt;
  final Value<String> rawJson;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const VitalsTableCompanion({
    this.id = const Value.absent(),
    this.vitalConfigId = const Value.absent(),
    this.measuredAt = const Value.absent(),
    this.rawJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VitalsTableCompanion.insert({
    required String id,
    required String vitalConfigId,
    required int measuredAt,
    required String rawJson,
    required int updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        vitalConfigId = Value(vitalConfigId),
        measuredAt = Value(measuredAt),
        rawJson = Value(rawJson),
        updatedAt = Value(updatedAt);
  static Insertable<VitalRow> custom({
    Expression<String>? id,
    Expression<String>? vitalConfigId,
    Expression<int>? measuredAt,
    Expression<String>? rawJson,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vitalConfigId != null) 'vital_config_id': vitalConfigId,
      if (measuredAt != null) 'measured_at': measuredAt,
      if (rawJson != null) 'raw_json': rawJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VitalsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? vitalConfigId,
      Value<int>? measuredAt,
      Value<String>? rawJson,
      Value<int>? updatedAt,
      Value<int>? rowid}) {
    return VitalsTableCompanion(
      id: id ?? this.id,
      vitalConfigId: vitalConfigId ?? this.vitalConfigId,
      measuredAt: measuredAt ?? this.measuredAt,
      rawJson: rawJson ?? this.rawJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (vitalConfigId.present) {
      map['vital_config_id'] = Variable<String>(vitalConfigId.value);
    }
    if (measuredAt.present) {
      map['measured_at'] = Variable<int>(measuredAt.value);
    }
    if (rawJson.present) {
      map['raw_json'] = Variable<String>(rawJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VitalsTableCompanion(')
          ..write('id: $id, ')
          ..write('vitalConfigId: $vitalConfigId, ')
          ..write('measuredAt: $measuredAt, ')
          ..write('rawJson: $rawJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScheduleTableTable extends ScheduleTable
    with TableInfo<$ScheduleTableTable, ScheduleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScheduleTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _doseTimeIdMeta =
      const VerificationMeta('doseTimeId');
  @override
  late final GeneratedColumn<String> doseTimeId = GeneratedColumn<String>(
      'dose_time_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _scheduledTimeMeta =
      const VerificationMeta('scheduledTime');
  @override
  late final GeneratedColumn<int> scheduledTime = GeneratedColumn<int>(
      'scheduled_time', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _rawJsonMeta =
      const VerificationMeta('rawJson');
  @override
  late final GeneratedColumn<String> rawJson = GeneratedColumn<String>(
      'raw_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [doseTimeId, status, scheduledTime, rawJson, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schedule';
  @override
  VerificationContext validateIntegrity(Insertable<ScheduleRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('dose_time_id')) {
      context.handle(
          _doseTimeIdMeta,
          doseTimeId.isAcceptableOrUnknown(
              data['dose_time_id']!, _doseTimeIdMeta));
    } else if (isInserting) {
      context.missing(_doseTimeIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('scheduled_time')) {
      context.handle(
          _scheduledTimeMeta,
          scheduledTime.isAcceptableOrUnknown(
              data['scheduled_time']!, _scheduledTimeMeta));
    } else if (isInserting) {
      context.missing(_scheduledTimeMeta);
    }
    if (data.containsKey('raw_json')) {
      context.handle(_rawJsonMeta,
          rawJson.isAcceptableOrUnknown(data['raw_json']!, _rawJsonMeta));
    } else if (isInserting) {
      context.missing(_rawJsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {doseTimeId};
  @override
  ScheduleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScheduleRow(
      doseTimeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dose_time_id'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      scheduledTime: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}scheduled_time'])!,
      rawJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}raw_json'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ScheduleTableTable createAlias(String alias) {
    return $ScheduleTableTable(attachedDatabase, alias);
  }
}

class ScheduleRow extends DataClass implements Insertable<ScheduleRow> {
  final String doseTimeId;
  final String status;
  final int scheduledTime;
  final String rawJson;
  final int updatedAt;
  const ScheduleRow(
      {required this.doseTimeId,
      required this.status,
      required this.scheduledTime,
      required this.rawJson,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['dose_time_id'] = Variable<String>(doseTimeId);
    map['status'] = Variable<String>(status);
    map['scheduled_time'] = Variable<int>(scheduledTime);
    map['raw_json'] = Variable<String>(rawJson);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  ScheduleTableCompanion toCompanion(bool nullToAbsent) {
    return ScheduleTableCompanion(
      doseTimeId: Value(doseTimeId),
      status: Value(status),
      scheduledTime: Value(scheduledTime),
      rawJson: Value(rawJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory ScheduleRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScheduleRow(
      doseTimeId: serializer.fromJson<String>(json['doseTimeId']),
      status: serializer.fromJson<String>(json['status']),
      scheduledTime: serializer.fromJson<int>(json['scheduledTime']),
      rawJson: serializer.fromJson<String>(json['rawJson']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'doseTimeId': serializer.toJson<String>(doseTimeId),
      'status': serializer.toJson<String>(status),
      'scheduledTime': serializer.toJson<int>(scheduledTime),
      'rawJson': serializer.toJson<String>(rawJson),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  ScheduleRow copyWith(
          {String? doseTimeId,
          String? status,
          int? scheduledTime,
          String? rawJson,
          int? updatedAt}) =>
      ScheduleRow(
        doseTimeId: doseTimeId ?? this.doseTimeId,
        status: status ?? this.status,
        scheduledTime: scheduledTime ?? this.scheduledTime,
        rawJson: rawJson ?? this.rawJson,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ScheduleRow copyWithCompanion(ScheduleTableCompanion data) {
    return ScheduleRow(
      doseTimeId:
          data.doseTimeId.present ? data.doseTimeId.value : this.doseTimeId,
      status: data.status.present ? data.status.value : this.status,
      scheduledTime: data.scheduledTime.present
          ? data.scheduledTime.value
          : this.scheduledTime,
      rawJson: data.rawJson.present ? data.rawJson.value : this.rawJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleRow(')
          ..write('doseTimeId: $doseTimeId, ')
          ..write('status: $status, ')
          ..write('scheduledTime: $scheduledTime, ')
          ..write('rawJson: $rawJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(doseTimeId, status, scheduledTime, rawJson, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScheduleRow &&
          other.doseTimeId == this.doseTimeId &&
          other.status == this.status &&
          other.scheduledTime == this.scheduledTime &&
          other.rawJson == this.rawJson &&
          other.updatedAt == this.updatedAt);
}

class ScheduleTableCompanion extends UpdateCompanion<ScheduleRow> {
  final Value<String> doseTimeId;
  final Value<String> status;
  final Value<int> scheduledTime;
  final Value<String> rawJson;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const ScheduleTableCompanion({
    this.doseTimeId = const Value.absent(),
    this.status = const Value.absent(),
    this.scheduledTime = const Value.absent(),
    this.rawJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScheduleTableCompanion.insert({
    required String doseTimeId,
    required String status,
    required int scheduledTime,
    required String rawJson,
    required int updatedAt,
    this.rowid = const Value.absent(),
  })  : doseTimeId = Value(doseTimeId),
        status = Value(status),
        scheduledTime = Value(scheduledTime),
        rawJson = Value(rawJson),
        updatedAt = Value(updatedAt);
  static Insertable<ScheduleRow> custom({
    Expression<String>? doseTimeId,
    Expression<String>? status,
    Expression<int>? scheduledTime,
    Expression<String>? rawJson,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (doseTimeId != null) 'dose_time_id': doseTimeId,
      if (status != null) 'status': status,
      if (scheduledTime != null) 'scheduled_time': scheduledTime,
      if (rawJson != null) 'raw_json': rawJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScheduleTableCompanion copyWith(
      {Value<String>? doseTimeId,
      Value<String>? status,
      Value<int>? scheduledTime,
      Value<String>? rawJson,
      Value<int>? updatedAt,
      Value<int>? rowid}) {
    return ScheduleTableCompanion(
      doseTimeId: doseTimeId ?? this.doseTimeId,
      status: status ?? this.status,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      rawJson: rawJson ?? this.rawJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (doseTimeId.present) {
      map['dose_time_id'] = Variable<String>(doseTimeId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (scheduledTime.present) {
      map['scheduled_time'] = Variable<int>(scheduledTime.value);
    }
    if (rawJson.present) {
      map['raw_json'] = Variable<String>(rawJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleTableCompanion(')
          ..write('doseTimeId: $doseTimeId, ')
          ..write('status: $status, ')
          ..write('scheduledTime: $scheduledTime, ')
          ..write('rawJson: $rawJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotificationsTableTable extends NotificationsTable
    with TableInfo<$NotificationsTableTable, NotificationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
      'is_read', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_read" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _rawJsonMeta =
      const VerificationMeta('rawJson');
  @override
  late final GeneratedColumn<String> rawJson = GeneratedColumn<String>(
      'raw_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, type, isRead, rawJson, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notifications';
  @override
  VerificationContext validateIntegrity(Insertable<NotificationRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('is_read')) {
      context.handle(_isReadMeta,
          isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta));
    }
    if (data.containsKey('raw_json')) {
      context.handle(_rawJsonMeta,
          rawJson.isAcceptableOrUnknown(data['raw_json']!, _rawJsonMeta));
    } else if (isInserting) {
      context.missing(_rawJsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NotificationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotificationRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      isRead: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_read'])!,
      rawJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}raw_json'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $NotificationsTableTable createAlias(String alias) {
    return $NotificationsTableTable(attachedDatabase, alias);
  }
}

class NotificationRow extends DataClass implements Insertable<NotificationRow> {
  final String id;
  final String type;
  final bool isRead;
  final String rawJson;
  final int updatedAt;
  const NotificationRow(
      {required this.id,
      required this.type,
      required this.isRead,
      required this.rawJson,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['is_read'] = Variable<bool>(isRead);
    map['raw_json'] = Variable<String>(rawJson);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  NotificationsTableCompanion toCompanion(bool nullToAbsent) {
    return NotificationsTableCompanion(
      id: Value(id),
      type: Value(type),
      isRead: Value(isRead),
      rawJson: Value(rawJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory NotificationRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotificationRow(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      rawJson: serializer.fromJson<String>(json['rawJson']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'isRead': serializer.toJson<bool>(isRead),
      'rawJson': serializer.toJson<String>(rawJson),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  NotificationRow copyWith(
          {String? id,
          String? type,
          bool? isRead,
          String? rawJson,
          int? updatedAt}) =>
      NotificationRow(
        id: id ?? this.id,
        type: type ?? this.type,
        isRead: isRead ?? this.isRead,
        rawJson: rawJson ?? this.rawJson,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  NotificationRow copyWithCompanion(NotificationsTableCompanion data) {
    return NotificationRow(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      rawJson: data.rawJson.present ? data.rawJson.value : this.rawJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotificationRow(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('isRead: $isRead, ')
          ..write('rawJson: $rawJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, type, isRead, rawJson, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotificationRow &&
          other.id == this.id &&
          other.type == this.type &&
          other.isRead == this.isRead &&
          other.rawJson == this.rawJson &&
          other.updatedAt == this.updatedAt);
}

class NotificationsTableCompanion extends UpdateCompanion<NotificationRow> {
  final Value<String> id;
  final Value<String> type;
  final Value<bool> isRead;
  final Value<String> rawJson;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const NotificationsTableCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.isRead = const Value.absent(),
    this.rawJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotificationsTableCompanion.insert({
    required String id,
    required String type,
    this.isRead = const Value.absent(),
    required String rawJson,
    required int updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        type = Value(type),
        rawJson = Value(rawJson),
        updatedAt = Value(updatedAt);
  static Insertable<NotificationRow> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<bool>? isRead,
    Expression<String>? rawJson,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (isRead != null) 'is_read': isRead,
      if (rawJson != null) 'raw_json': rawJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotificationsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? type,
      Value<bool>? isRead,
      Value<String>? rawJson,
      Value<int>? updatedAt,
      Value<int>? rowid}) {
    return NotificationsTableCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      rawJson: rawJson ?? this.rawJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (rawJson.present) {
      map['raw_json'] = Variable<String>(rawJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationsTableCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('isRead: $isRead, ')
          ..write('rawJson: $rawJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProfessionalsTableTable extends ProfessionalsTable
    with TableInfo<$ProfessionalsTableTable, ProfessionalRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfessionalsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _rawJsonMeta =
      const VerificationMeta('rawJson');
  @override
  late final GeneratedColumn<String> rawJson = GeneratedColumn<String>(
      'raw_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, categoryId, rawJson, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'professionals';
  @override
  VerificationContext validateIntegrity(Insertable<ProfessionalRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('raw_json')) {
      context.handle(_rawJsonMeta,
          rawJson.isAcceptableOrUnknown(data['raw_json']!, _rawJsonMeta));
    } else if (isInserting) {
      context.missing(_rawJsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProfessionalRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfessionalRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id'])!,
      rawJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}raw_json'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ProfessionalsTableTable createAlias(String alias) {
    return $ProfessionalsTableTable(attachedDatabase, alias);
  }
}

class ProfessionalRow extends DataClass implements Insertable<ProfessionalRow> {
  final String id;
  final String categoryId;
  final String rawJson;
  final int updatedAt;
  const ProfessionalRow(
      {required this.id,
      required this.categoryId,
      required this.rawJson,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['category_id'] = Variable<String>(categoryId);
    map['raw_json'] = Variable<String>(rawJson);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  ProfessionalsTableCompanion toCompanion(bool nullToAbsent) {
    return ProfessionalsTableCompanion(
      id: Value(id),
      categoryId: Value(categoryId),
      rawJson: Value(rawJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory ProfessionalRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfessionalRow(
      id: serializer.fromJson<String>(json['id']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      rawJson: serializer.fromJson<String>(json['rawJson']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'categoryId': serializer.toJson<String>(categoryId),
      'rawJson': serializer.toJson<String>(rawJson),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  ProfessionalRow copyWith(
          {String? id, String? categoryId, String? rawJson, int? updatedAt}) =>
      ProfessionalRow(
        id: id ?? this.id,
        categoryId: categoryId ?? this.categoryId,
        rawJson: rawJson ?? this.rawJson,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ProfessionalRow copyWithCompanion(ProfessionalsTableCompanion data) {
    return ProfessionalRow(
      id: data.id.present ? data.id.value : this.id,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      rawJson: data.rawJson.present ? data.rawJson.value : this.rawJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfessionalRow(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('rawJson: $rawJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, categoryId, rawJson, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfessionalRow &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.rawJson == this.rawJson &&
          other.updatedAt == this.updatedAt);
}

class ProfessionalsTableCompanion extends UpdateCompanion<ProfessionalRow> {
  final Value<String> id;
  final Value<String> categoryId;
  final Value<String> rawJson;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const ProfessionalsTableCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.rawJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfessionalsTableCompanion.insert({
    required String id,
    required String categoryId,
    required String rawJson,
    required int updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        categoryId = Value(categoryId),
        rawJson = Value(rawJson),
        updatedAt = Value(updatedAt);
  static Insertable<ProfessionalRow> custom({
    Expression<String>? id,
    Expression<String>? categoryId,
    Expression<String>? rawJson,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (rawJson != null) 'raw_json': rawJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfessionalsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? categoryId,
      Value<String>? rawJson,
      Value<int>? updatedAt,
      Value<int>? rowid}) {
    return ProfessionalsTableCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      rawJson: rawJson ?? this.rawJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (rawJson.present) {
      map['raw_json'] = Variable<String>(rawJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfessionalsTableCompanion(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('rawJson: $rawJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DoseLogsTableTable extends DoseLogsTable
    with TableInfo<$DoseLogsTableTable, DoseLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DoseLogsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _doseTimeIdMeta =
      const VerificationMeta('doseTimeId');
  @override
  late final GeneratedColumn<String> doseTimeId = GeneratedColumn<String>(
      'dose_time_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _takenAtMeta =
      const VerificationMeta('takenAt');
  @override
  late final GeneratedColumn<String> takenAt = GeneratedColumn<String>(
      'taken_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, doseTimeId, status, takenAt, isSynced, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dose_logs';
  @override
  VerificationContext validateIntegrity(Insertable<DoseLogRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('dose_time_id')) {
      context.handle(
          _doseTimeIdMeta,
          doseTimeId.isAcceptableOrUnknown(
              data['dose_time_id']!, _doseTimeIdMeta));
    } else if (isInserting) {
      context.missing(_doseTimeIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('taken_at')) {
      context.handle(_takenAtMeta,
          takenAt.isAcceptableOrUnknown(data['taken_at']!, _takenAtMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
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
  DoseLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DoseLogRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      doseTimeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dose_time_id'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      takenAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}taken_at']),
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $DoseLogsTableTable createAlias(String alias) {
    return $DoseLogsTableTable(attachedDatabase, alias);
  }
}

class DoseLogRow extends DataClass implements Insertable<DoseLogRow> {
  final String id;
  final String doseTimeId;
  final String status;
  final String? takenAt;
  final bool isSynced;
  final int createdAt;
  const DoseLogRow(
      {required this.id,
      required this.doseTimeId,
      required this.status,
      this.takenAt,
      required this.isSynced,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['dose_time_id'] = Variable<String>(doseTimeId);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || takenAt != null) {
      map['taken_at'] = Variable<String>(takenAt);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  DoseLogsTableCompanion toCompanion(bool nullToAbsent) {
    return DoseLogsTableCompanion(
      id: Value(id),
      doseTimeId: Value(doseTimeId),
      status: Value(status),
      takenAt: takenAt == null && nullToAbsent
          ? const Value.absent()
          : Value(takenAt),
      isSynced: Value(isSynced),
      createdAt: Value(createdAt),
    );
  }

  factory DoseLogRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DoseLogRow(
      id: serializer.fromJson<String>(json['id']),
      doseTimeId: serializer.fromJson<String>(json['doseTimeId']),
      status: serializer.fromJson<String>(json['status']),
      takenAt: serializer.fromJson<String?>(json['takenAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'doseTimeId': serializer.toJson<String>(doseTimeId),
      'status': serializer.toJson<String>(status),
      'takenAt': serializer.toJson<String?>(takenAt),
      'isSynced': serializer.toJson<bool>(isSynced),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  DoseLogRow copyWith(
          {String? id,
          String? doseTimeId,
          String? status,
          Value<String?> takenAt = const Value.absent(),
          bool? isSynced,
          int? createdAt}) =>
      DoseLogRow(
        id: id ?? this.id,
        doseTimeId: doseTimeId ?? this.doseTimeId,
        status: status ?? this.status,
        takenAt: takenAt.present ? takenAt.value : this.takenAt,
        isSynced: isSynced ?? this.isSynced,
        createdAt: createdAt ?? this.createdAt,
      );
  DoseLogRow copyWithCompanion(DoseLogsTableCompanion data) {
    return DoseLogRow(
      id: data.id.present ? data.id.value : this.id,
      doseTimeId:
          data.doseTimeId.present ? data.doseTimeId.value : this.doseTimeId,
      status: data.status.present ? data.status.value : this.status,
      takenAt: data.takenAt.present ? data.takenAt.value : this.takenAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DoseLogRow(')
          ..write('id: $id, ')
          ..write('doseTimeId: $doseTimeId, ')
          ..write('status: $status, ')
          ..write('takenAt: $takenAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, doseTimeId, status, takenAt, isSynced, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DoseLogRow &&
          other.id == this.id &&
          other.doseTimeId == this.doseTimeId &&
          other.status == this.status &&
          other.takenAt == this.takenAt &&
          other.isSynced == this.isSynced &&
          other.createdAt == this.createdAt);
}

class DoseLogsTableCompanion extends UpdateCompanion<DoseLogRow> {
  final Value<String> id;
  final Value<String> doseTimeId;
  final Value<String> status;
  final Value<String?> takenAt;
  final Value<bool> isSynced;
  final Value<int> createdAt;
  final Value<int> rowid;
  const DoseLogsTableCompanion({
    this.id = const Value.absent(),
    this.doseTimeId = const Value.absent(),
    this.status = const Value.absent(),
    this.takenAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DoseLogsTableCompanion.insert({
    required String id,
    required String doseTimeId,
    required String status,
    this.takenAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        doseTimeId = Value(doseTimeId),
        status = Value(status),
        createdAt = Value(createdAt);
  static Insertable<DoseLogRow> custom({
    Expression<String>? id,
    Expression<String>? doseTimeId,
    Expression<String>? status,
    Expression<String>? takenAt,
    Expression<bool>? isSynced,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (doseTimeId != null) 'dose_time_id': doseTimeId,
      if (status != null) 'status': status,
      if (takenAt != null) 'taken_at': takenAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DoseLogsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? doseTimeId,
      Value<String>? status,
      Value<String?>? takenAt,
      Value<bool>? isSynced,
      Value<int>? createdAt,
      Value<int>? rowid}) {
    return DoseLogsTableCompanion(
      id: id ?? this.id,
      doseTimeId: doseTimeId ?? this.doseTimeId,
      status: status ?? this.status,
      takenAt: takenAt ?? this.takenAt,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (doseTimeId.present) {
      map['dose_time_id'] = Variable<String>(doseTimeId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (takenAt.present) {
      map['taken_at'] = Variable<String>(takenAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DoseLogsTableCompanion(')
          ..write('id: $id, ')
          ..write('doseTimeId: $doseTimeId, ')
          ..write('status: $status, ')
          ..write('takenAt: $takenAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $OutboxTableTable outboxTable = $OutboxTableTable(this);
  late final $MedicinesTableTable medicinesTable = $MedicinesTableTable(this);
  late final $VitalsTableTable vitalsTable = $VitalsTableTable(this);
  late final $ScheduleTableTable scheduleTable = $ScheduleTableTable(this);
  late final $NotificationsTableTable notificationsTable =
      $NotificationsTableTable(this);
  late final $ProfessionalsTableTable professionalsTable =
      $ProfessionalsTableTable(this);
  late final $DoseLogsTableTable doseLogsTable = $DoseLogsTableTable(this);
  late final OutboxDao outboxDao = OutboxDao(this as AppDatabase);
  late final MedicinesDao medicinesDao = MedicinesDao(this as AppDatabase);
  late final VitalsDao vitalsDao = VitalsDao(this as AppDatabase);
  late final ScheduleDao scheduleDao = ScheduleDao(this as AppDatabase);
  late final NotificationsDao notificationsDao =
      NotificationsDao(this as AppDatabase);
  late final ProfessionalsDao professionalsDao =
      ProfessionalsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        outboxTable,
        medicinesTable,
        vitalsTable,
        scheduleTable,
        notificationsTable,
        professionalsTable,
        doseLogsTable
      ];
}

typedef $$OutboxTableTableCreateCompanionBuilder = OutboxTableCompanion
    Function({
  required String id,
  required String feature,
  required String action,
  required String payload,
  required int createdAt,
  Value<int> retryCount,
  Value<int> rowid,
});
typedef $$OutboxTableTableUpdateCompanionBuilder = OutboxTableCompanion
    Function({
  Value<String> id,
  Value<String> feature,
  Value<String> action,
  Value<String> payload,
  Value<int> createdAt,
  Value<int> retryCount,
  Value<int> rowid,
});

class $$OutboxTableTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxTableTable> {
  $$OutboxTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get feature => $composableBuilder(
      column: $table.feature, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));
}

class $$OutboxTableTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxTableTable> {
  $$OutboxTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get feature => $composableBuilder(
      column: $table.feature, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));
}

class $$OutboxTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxTableTable> {
  $$OutboxTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get feature =>
      $composableBuilder(column: $table.feature, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);
}

class $$OutboxTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OutboxTableTable,
    OutboxRow,
    $$OutboxTableTableFilterComposer,
    $$OutboxTableTableOrderingComposer,
    $$OutboxTableTableAnnotationComposer,
    $$OutboxTableTableCreateCompanionBuilder,
    $$OutboxTableTableUpdateCompanionBuilder,
    (OutboxRow, BaseReferences<_$AppDatabase, $OutboxTableTable, OutboxRow>),
    OutboxRow,
    PrefetchHooks Function()> {
  $$OutboxTableTableTableManager(_$AppDatabase db, $OutboxTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> feature = const Value.absent(),
            Value<String> action = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OutboxTableCompanion(
            id: id,
            feature: feature,
            action: action,
            payload: payload,
            createdAt: createdAt,
            retryCount: retryCount,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String feature,
            required String action,
            required String payload,
            required int createdAt,
            Value<int> retryCount = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OutboxTableCompanion.insert(
            id: id,
            feature: feature,
            action: action,
            payload: payload,
            createdAt: createdAt,
            retryCount: retryCount,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OutboxTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OutboxTableTable,
    OutboxRow,
    $$OutboxTableTableFilterComposer,
    $$OutboxTableTableOrderingComposer,
    $$OutboxTableTableAnnotationComposer,
    $$OutboxTableTableCreateCompanionBuilder,
    $$OutboxTableTableUpdateCompanionBuilder,
    (OutboxRow, BaseReferences<_$AppDatabase, $OutboxTableTable, OutboxRow>),
    OutboxRow,
    PrefetchHooks Function()>;
typedef $$MedicinesTableTableCreateCompanionBuilder = MedicinesTableCompanion
    Function({
  required String id,
  required String rawJson,
  required int updatedAt,
  Value<int> rowid,
});
typedef $$MedicinesTableTableUpdateCompanionBuilder = MedicinesTableCompanion
    Function({
  Value<String> id,
  Value<String> rawJson,
  Value<int> updatedAt,
  Value<int> rowid,
});

class $$MedicinesTableTableFilterComposer
    extends Composer<_$AppDatabase, $MedicinesTableTable> {
  $$MedicinesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rawJson => $composableBuilder(
      column: $table.rawJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$MedicinesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicinesTableTable> {
  $$MedicinesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rawJson => $composableBuilder(
      column: $table.rawJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$MedicinesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicinesTableTable> {
  $$MedicinesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get rawJson =>
      $composableBuilder(column: $table.rawJson, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$MedicinesTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MedicinesTableTable,
    MedicineRow,
    $$MedicinesTableTableFilterComposer,
    $$MedicinesTableTableOrderingComposer,
    $$MedicinesTableTableAnnotationComposer,
    $$MedicinesTableTableCreateCompanionBuilder,
    $$MedicinesTableTableUpdateCompanionBuilder,
    (
      MedicineRow,
      BaseReferences<_$AppDatabase, $MedicinesTableTable, MedicineRow>
    ),
    MedicineRow,
    PrefetchHooks Function()> {
  $$MedicinesTableTableTableManager(
      _$AppDatabase db, $MedicinesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicinesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicinesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicinesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> rawJson = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MedicinesTableCompanion(
            id: id,
            rawJson: rawJson,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String rawJson,
            required int updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              MedicinesTableCompanion.insert(
            id: id,
            rawJson: rawJson,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MedicinesTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MedicinesTableTable,
    MedicineRow,
    $$MedicinesTableTableFilterComposer,
    $$MedicinesTableTableOrderingComposer,
    $$MedicinesTableTableAnnotationComposer,
    $$MedicinesTableTableCreateCompanionBuilder,
    $$MedicinesTableTableUpdateCompanionBuilder,
    (
      MedicineRow,
      BaseReferences<_$AppDatabase, $MedicinesTableTable, MedicineRow>
    ),
    MedicineRow,
    PrefetchHooks Function()>;
typedef $$VitalsTableTableCreateCompanionBuilder = VitalsTableCompanion
    Function({
  required String id,
  required String vitalConfigId,
  required int measuredAt,
  required String rawJson,
  required int updatedAt,
  Value<int> rowid,
});
typedef $$VitalsTableTableUpdateCompanionBuilder = VitalsTableCompanion
    Function({
  Value<String> id,
  Value<String> vitalConfigId,
  Value<int> measuredAt,
  Value<String> rawJson,
  Value<int> updatedAt,
  Value<int> rowid,
});

class $$VitalsTableTableFilterComposer
    extends Composer<_$AppDatabase, $VitalsTableTable> {
  $$VitalsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get vitalConfigId => $composableBuilder(
      column: $table.vitalConfigId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get measuredAt => $composableBuilder(
      column: $table.measuredAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rawJson => $composableBuilder(
      column: $table.rawJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$VitalsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $VitalsTableTable> {
  $$VitalsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get vitalConfigId => $composableBuilder(
      column: $table.vitalConfigId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get measuredAt => $composableBuilder(
      column: $table.measuredAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rawJson => $composableBuilder(
      column: $table.rawJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$VitalsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $VitalsTableTable> {
  $$VitalsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get vitalConfigId => $composableBuilder(
      column: $table.vitalConfigId, builder: (column) => column);

  GeneratedColumn<int> get measuredAt => $composableBuilder(
      column: $table.measuredAt, builder: (column) => column);

  GeneratedColumn<String> get rawJson =>
      $composableBuilder(column: $table.rawJson, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$VitalsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $VitalsTableTable,
    VitalRow,
    $$VitalsTableTableFilterComposer,
    $$VitalsTableTableOrderingComposer,
    $$VitalsTableTableAnnotationComposer,
    $$VitalsTableTableCreateCompanionBuilder,
    $$VitalsTableTableUpdateCompanionBuilder,
    (VitalRow, BaseReferences<_$AppDatabase, $VitalsTableTable, VitalRow>),
    VitalRow,
    PrefetchHooks Function()> {
  $$VitalsTableTableTableManager(_$AppDatabase db, $VitalsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VitalsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VitalsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VitalsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> vitalConfigId = const Value.absent(),
            Value<int> measuredAt = const Value.absent(),
            Value<String> rawJson = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              VitalsTableCompanion(
            id: id,
            vitalConfigId: vitalConfigId,
            measuredAt: measuredAt,
            rawJson: rawJson,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String vitalConfigId,
            required int measuredAt,
            required String rawJson,
            required int updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              VitalsTableCompanion.insert(
            id: id,
            vitalConfigId: vitalConfigId,
            measuredAt: measuredAt,
            rawJson: rawJson,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$VitalsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $VitalsTableTable,
    VitalRow,
    $$VitalsTableTableFilterComposer,
    $$VitalsTableTableOrderingComposer,
    $$VitalsTableTableAnnotationComposer,
    $$VitalsTableTableCreateCompanionBuilder,
    $$VitalsTableTableUpdateCompanionBuilder,
    (VitalRow, BaseReferences<_$AppDatabase, $VitalsTableTable, VitalRow>),
    VitalRow,
    PrefetchHooks Function()>;
typedef $$ScheduleTableTableCreateCompanionBuilder = ScheduleTableCompanion
    Function({
  required String doseTimeId,
  required String status,
  required int scheduledTime,
  required String rawJson,
  required int updatedAt,
  Value<int> rowid,
});
typedef $$ScheduleTableTableUpdateCompanionBuilder = ScheduleTableCompanion
    Function({
  Value<String> doseTimeId,
  Value<String> status,
  Value<int> scheduledTime,
  Value<String> rawJson,
  Value<int> updatedAt,
  Value<int> rowid,
});

class $$ScheduleTableTableFilterComposer
    extends Composer<_$AppDatabase, $ScheduleTableTable> {
  $$ScheduleTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get doseTimeId => $composableBuilder(
      column: $table.doseTimeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get scheduledTime => $composableBuilder(
      column: $table.scheduledTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rawJson => $composableBuilder(
      column: $table.rawJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$ScheduleTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ScheduleTableTable> {
  $$ScheduleTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get doseTimeId => $composableBuilder(
      column: $table.doseTimeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get scheduledTime => $composableBuilder(
      column: $table.scheduledTime,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rawJson => $composableBuilder(
      column: $table.rawJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ScheduleTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScheduleTableTable> {
  $$ScheduleTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get doseTimeId => $composableBuilder(
      column: $table.doseTimeId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get scheduledTime => $composableBuilder(
      column: $table.scheduledTime, builder: (column) => column);

  GeneratedColumn<String> get rawJson =>
      $composableBuilder(column: $table.rawJson, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ScheduleTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ScheduleTableTable,
    ScheduleRow,
    $$ScheduleTableTableFilterComposer,
    $$ScheduleTableTableOrderingComposer,
    $$ScheduleTableTableAnnotationComposer,
    $$ScheduleTableTableCreateCompanionBuilder,
    $$ScheduleTableTableUpdateCompanionBuilder,
    (
      ScheduleRow,
      BaseReferences<_$AppDatabase, $ScheduleTableTable, ScheduleRow>
    ),
    ScheduleRow,
    PrefetchHooks Function()> {
  $$ScheduleTableTableTableManager(_$AppDatabase db, $ScheduleTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScheduleTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScheduleTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScheduleTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> doseTimeId = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> scheduledTime = const Value.absent(),
            Value<String> rawJson = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ScheduleTableCompanion(
            doseTimeId: doseTimeId,
            status: status,
            scheduledTime: scheduledTime,
            rawJson: rawJson,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String doseTimeId,
            required String status,
            required int scheduledTime,
            required String rawJson,
            required int updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ScheduleTableCompanion.insert(
            doseTimeId: doseTimeId,
            status: status,
            scheduledTime: scheduledTime,
            rawJson: rawJson,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ScheduleTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ScheduleTableTable,
    ScheduleRow,
    $$ScheduleTableTableFilterComposer,
    $$ScheduleTableTableOrderingComposer,
    $$ScheduleTableTableAnnotationComposer,
    $$ScheduleTableTableCreateCompanionBuilder,
    $$ScheduleTableTableUpdateCompanionBuilder,
    (
      ScheduleRow,
      BaseReferences<_$AppDatabase, $ScheduleTableTable, ScheduleRow>
    ),
    ScheduleRow,
    PrefetchHooks Function()>;
typedef $$NotificationsTableTableCreateCompanionBuilder
    = NotificationsTableCompanion Function({
  required String id,
  required String type,
  Value<bool> isRead,
  required String rawJson,
  required int updatedAt,
  Value<int> rowid,
});
typedef $$NotificationsTableTableUpdateCompanionBuilder
    = NotificationsTableCompanion Function({
  Value<String> id,
  Value<String> type,
  Value<bool> isRead,
  Value<String> rawJson,
  Value<int> updatedAt,
  Value<int> rowid,
});

class $$NotificationsTableTableFilterComposer
    extends Composer<_$AppDatabase, $NotificationsTableTable> {
  $$NotificationsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isRead => $composableBuilder(
      column: $table.isRead, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rawJson => $composableBuilder(
      column: $table.rawJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$NotificationsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $NotificationsTableTable> {
  $$NotificationsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRead => $composableBuilder(
      column: $table.isRead, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rawJson => $composableBuilder(
      column: $table.rawJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$NotificationsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotificationsTableTable> {
  $$NotificationsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);

  GeneratedColumn<String> get rawJson =>
      $composableBuilder(column: $table.rawJson, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$NotificationsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $NotificationsTableTable,
    NotificationRow,
    $$NotificationsTableTableFilterComposer,
    $$NotificationsTableTableOrderingComposer,
    $$NotificationsTableTableAnnotationComposer,
    $$NotificationsTableTableCreateCompanionBuilder,
    $$NotificationsTableTableUpdateCompanionBuilder,
    (
      NotificationRow,
      BaseReferences<_$AppDatabase, $NotificationsTableTable, NotificationRow>
    ),
    NotificationRow,
    PrefetchHooks Function()> {
  $$NotificationsTableTableTableManager(
      _$AppDatabase db, $NotificationsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotificationsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotificationsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotificationsTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<bool> isRead = const Value.absent(),
            Value<String> rawJson = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              NotificationsTableCompanion(
            id: id,
            type: type,
            isRead: isRead,
            rawJson: rawJson,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String type,
            Value<bool> isRead = const Value.absent(),
            required String rawJson,
            required int updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              NotificationsTableCompanion.insert(
            id: id,
            type: type,
            isRead: isRead,
            rawJson: rawJson,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$NotificationsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $NotificationsTableTable,
    NotificationRow,
    $$NotificationsTableTableFilterComposer,
    $$NotificationsTableTableOrderingComposer,
    $$NotificationsTableTableAnnotationComposer,
    $$NotificationsTableTableCreateCompanionBuilder,
    $$NotificationsTableTableUpdateCompanionBuilder,
    (
      NotificationRow,
      BaseReferences<_$AppDatabase, $NotificationsTableTable, NotificationRow>
    ),
    NotificationRow,
    PrefetchHooks Function()>;
typedef $$ProfessionalsTableTableCreateCompanionBuilder
    = ProfessionalsTableCompanion Function({
  required String id,
  required String categoryId,
  required String rawJson,
  required int updatedAt,
  Value<int> rowid,
});
typedef $$ProfessionalsTableTableUpdateCompanionBuilder
    = ProfessionalsTableCompanion Function({
  Value<String> id,
  Value<String> categoryId,
  Value<String> rawJson,
  Value<int> updatedAt,
  Value<int> rowid,
});

class $$ProfessionalsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ProfessionalsTableTable> {
  $$ProfessionalsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rawJson => $composableBuilder(
      column: $table.rawJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$ProfessionalsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfessionalsTableTable> {
  $$ProfessionalsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rawJson => $composableBuilder(
      column: $table.rawJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ProfessionalsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfessionalsTableTable> {
  $$ProfessionalsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => column);

  GeneratedColumn<String> get rawJson =>
      $composableBuilder(column: $table.rawJson, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ProfessionalsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProfessionalsTableTable,
    ProfessionalRow,
    $$ProfessionalsTableTableFilterComposer,
    $$ProfessionalsTableTableOrderingComposer,
    $$ProfessionalsTableTableAnnotationComposer,
    $$ProfessionalsTableTableCreateCompanionBuilder,
    $$ProfessionalsTableTableUpdateCompanionBuilder,
    (
      ProfessionalRow,
      BaseReferences<_$AppDatabase, $ProfessionalsTableTable, ProfessionalRow>
    ),
    ProfessionalRow,
    PrefetchHooks Function()> {
  $$ProfessionalsTableTableTableManager(
      _$AppDatabase db, $ProfessionalsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfessionalsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfessionalsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfessionalsTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> categoryId = const Value.absent(),
            Value<String> rawJson = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProfessionalsTableCompanion(
            id: id,
            categoryId: categoryId,
            rawJson: rawJson,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String categoryId,
            required String rawJson,
            required int updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ProfessionalsTableCompanion.insert(
            id: id,
            categoryId: categoryId,
            rawJson: rawJson,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProfessionalsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProfessionalsTableTable,
    ProfessionalRow,
    $$ProfessionalsTableTableFilterComposer,
    $$ProfessionalsTableTableOrderingComposer,
    $$ProfessionalsTableTableAnnotationComposer,
    $$ProfessionalsTableTableCreateCompanionBuilder,
    $$ProfessionalsTableTableUpdateCompanionBuilder,
    (
      ProfessionalRow,
      BaseReferences<_$AppDatabase, $ProfessionalsTableTable, ProfessionalRow>
    ),
    ProfessionalRow,
    PrefetchHooks Function()>;
typedef $$DoseLogsTableTableCreateCompanionBuilder = DoseLogsTableCompanion
    Function({
  required String id,
  required String doseTimeId,
  required String status,
  Value<String?> takenAt,
  Value<bool> isSynced,
  required int createdAt,
  Value<int> rowid,
});
typedef $$DoseLogsTableTableUpdateCompanionBuilder = DoseLogsTableCompanion
    Function({
  Value<String> id,
  Value<String> doseTimeId,
  Value<String> status,
  Value<String?> takenAt,
  Value<bool> isSynced,
  Value<int> createdAt,
  Value<int> rowid,
});

class $$DoseLogsTableTableFilterComposer
    extends Composer<_$AppDatabase, $DoseLogsTableTable> {
  $$DoseLogsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get doseTimeId => $composableBuilder(
      column: $table.doseTimeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get takenAt => $composableBuilder(
      column: $table.takenAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$DoseLogsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DoseLogsTableTable> {
  $$DoseLogsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get doseTimeId => $composableBuilder(
      column: $table.doseTimeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get takenAt => $composableBuilder(
      column: $table.takenAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$DoseLogsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DoseLogsTableTable> {
  $$DoseLogsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get doseTimeId => $composableBuilder(
      column: $table.doseTimeId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get takenAt =>
      $composableBuilder(column: $table.takenAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$DoseLogsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DoseLogsTableTable,
    DoseLogRow,
    $$DoseLogsTableTableFilterComposer,
    $$DoseLogsTableTableOrderingComposer,
    $$DoseLogsTableTableAnnotationComposer,
    $$DoseLogsTableTableCreateCompanionBuilder,
    $$DoseLogsTableTableUpdateCompanionBuilder,
    (
      DoseLogRow,
      BaseReferences<_$AppDatabase, $DoseLogsTableTable, DoseLogRow>
    ),
    DoseLogRow,
    PrefetchHooks Function()> {
  $$DoseLogsTableTableTableManager(_$AppDatabase db, $DoseLogsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DoseLogsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DoseLogsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DoseLogsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> doseTimeId = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> takenAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DoseLogsTableCompanion(
            id: id,
            doseTimeId: doseTimeId,
            status: status,
            takenAt: takenAt,
            isSynced: isSynced,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String doseTimeId,
            required String status,
            Value<String?> takenAt = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            required int createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              DoseLogsTableCompanion.insert(
            id: id,
            doseTimeId: doseTimeId,
            status: status,
            takenAt: takenAt,
            isSynced: isSynced,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DoseLogsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DoseLogsTableTable,
    DoseLogRow,
    $$DoseLogsTableTableFilterComposer,
    $$DoseLogsTableTableOrderingComposer,
    $$DoseLogsTableTableAnnotationComposer,
    $$DoseLogsTableTableCreateCompanionBuilder,
    $$DoseLogsTableTableUpdateCompanionBuilder,
    (
      DoseLogRow,
      BaseReferences<_$AppDatabase, $DoseLogsTableTable, DoseLogRow>
    ),
    DoseLogRow,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$OutboxTableTableTableManager get outboxTable =>
      $$OutboxTableTableTableManager(_db, _db.outboxTable);
  $$MedicinesTableTableTableManager get medicinesTable =>
      $$MedicinesTableTableTableManager(_db, _db.medicinesTable);
  $$VitalsTableTableTableManager get vitalsTable =>
      $$VitalsTableTableTableManager(_db, _db.vitalsTable);
  $$ScheduleTableTableTableManager get scheduleTable =>
      $$ScheduleTableTableTableManager(_db, _db.scheduleTable);
  $$NotificationsTableTableTableManager get notificationsTable =>
      $$NotificationsTableTableTableManager(_db, _db.notificationsTable);
  $$ProfessionalsTableTableTableManager get professionalsTable =>
      $$ProfessionalsTableTableTableManager(_db, _db.professionalsTable);
  $$DoseLogsTableTableTableManager get doseLogsTable =>
      $$DoseLogsTableTableTableManager(_db, _db.doseLogsTable);
}
