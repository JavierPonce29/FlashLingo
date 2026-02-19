// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deck_settings.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDeckSettingsCollection on Isar {
  IsarCollection<DeckSettings> get deckSettings => this.collection();
}

const DeckSettingsSchema = CollectionSchema(
  name: r'DeckSettings',
  id: 3489020271710213188,
  properties: {
    r'alpha': PropertySchema(
      id: 0,
      name: r'alpha',
      type: IsarType.double,
    ),
    r'beta': PropertySchema(
      id: 1,
      name: r'beta',
      type: IsarType.double,
    ),
    r'enableWriteMode': PropertySchema(
      id: 2,
      name: r'enableWriteMode',
      type: IsarType.bool,
    ),
    r'initialNt': PropertySchema(
      id: 3,
      name: r'initialNt',
      type: IsarType.double,
    ),
    r'lapseFixedInterval': PropertySchema(
      id: 4,
      name: r'lapseFixedInterval',
      type: IsarType.double,
    ),
    r'lapseTolerance': PropertySchema(
      id: 5,
      name: r'lapseTolerance',
      type: IsarType.long,
    ),
    r'lastNewCardStudyDate': PropertySchema(
      id: 6,
      name: r'lastNewCardStudyDate',
      type: IsarType.dateTime,
    ),
    r'learningSteps': PropertySchema(
      id: 7,
      name: r'learningSteps',
      type: IsarType.doubleList,
    ),
    r'maxReviewsPerDay': PropertySchema(
      id: 8,
      name: r'maxReviewsPerDay',
      type: IsarType.long,
    ),
    r'newCardIntraDayMinutes': PropertySchema(
      id: 9,
      name: r'newCardIntraDayMinutes',
      type: IsarType.long,
    ),
    r'newCardMinCorrectReps': PropertySchema(
      id: 10,
      name: r'newCardMinCorrectReps',
      type: IsarType.long,
    ),
    r'newCardsPerDay': PropertySchema(
      id: 11,
      name: r'newCardsPerDay',
      type: IsarType.long,
    ),
    r'newCardsSeenToday': PropertySchema(
      id: 12,
      name: r'newCardsSeenToday',
      type: IsarType.long,
    ),
    r'offset': PropertySchema(
      id: 13,
      name: r'offset',
      type: IsarType.double,
    ),
    r'pMin': PropertySchema(
      id: 14,
      name: r'pMin',
      type: IsarType.double,
    ),
    r'packName': PropertySchema(
      id: 15,
      name: r'packName',
      type: IsarType.string,
    ),
    r'useFixedIntervalOnLapse': PropertySchema(
      id: 16,
      name: r'useFixedIntervalOnLapse',
      type: IsarType.bool,
    ),
    r'writeModeMaxReps': PropertySchema(
      id: 17,
      name: r'writeModeMaxReps',
      type: IsarType.long,
    ),
    r'writeModeThreshold': PropertySchema(
      id: 18,
      name: r'writeModeThreshold',
      type: IsarType.long,
    )
  },
  estimateSize: _deckSettingsEstimateSize,
  serialize: _deckSettingsSerialize,
  deserialize: _deckSettingsDeserialize,
  deserializeProp: _deckSettingsDeserializeProp,
  idName: r'id',
  indexes: {
    r'packName': IndexSchema(
      id: -4088498089984738832,
      name: r'packName',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'packName',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _deckSettingsGetId,
  getLinks: _deckSettingsGetLinks,
  attach: _deckSettingsAttach,
  version: '3.1.0+1',
);

int _deckSettingsEstimateSize(
  DeckSettings object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.learningSteps.length * 8;
  bytesCount += 3 + object.packName.length * 3;
  return bytesCount;
}

void _deckSettingsSerialize(
  DeckSettings object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.alpha);
  writer.writeDouble(offsets[1], object.beta);
  writer.writeBool(offsets[2], object.enableWriteMode);
  writer.writeDouble(offsets[3], object.initialNt);
  writer.writeDouble(offsets[4], object.lapseFixedInterval);
  writer.writeLong(offsets[5], object.lapseTolerance);
  writer.writeDateTime(offsets[6], object.lastNewCardStudyDate);
  writer.writeDoubleList(offsets[7], object.learningSteps);
  writer.writeLong(offsets[8], object.maxReviewsPerDay);
  writer.writeLong(offsets[9], object.newCardIntraDayMinutes);
  writer.writeLong(offsets[10], object.newCardMinCorrectReps);
  writer.writeLong(offsets[11], object.newCardsPerDay);
  writer.writeLong(offsets[12], object.newCardsSeenToday);
  writer.writeDouble(offsets[13], object.offset);
  writer.writeDouble(offsets[14], object.pMin);
  writer.writeString(offsets[15], object.packName);
  writer.writeBool(offsets[16], object.useFixedIntervalOnLapse);
  writer.writeLong(offsets[17], object.writeModeMaxReps);
  writer.writeLong(offsets[18], object.writeModeThreshold);
}

DeckSettings _deckSettingsDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DeckSettings();
  object.alpha = reader.readDouble(offsets[0]);
  object.beta = reader.readDouble(offsets[1]);
  object.enableWriteMode = reader.readBool(offsets[2]);
  object.id = id;
  object.initialNt = reader.readDouble(offsets[3]);
  object.lapseFixedInterval = reader.readDouble(offsets[4]);
  object.lapseTolerance = reader.readLong(offsets[5]);
  object.lastNewCardStudyDate = reader.readDateTimeOrNull(offsets[6]);
  object.learningSteps = reader.readDoubleList(offsets[7]) ?? [];
  object.maxReviewsPerDay = reader.readLong(offsets[8]);
  object.newCardIntraDayMinutes = reader.readLong(offsets[9]);
  object.newCardMinCorrectReps = reader.readLong(offsets[10]);
  object.newCardsPerDay = reader.readLong(offsets[11]);
  object.newCardsSeenToday = reader.readLong(offsets[12]);
  object.offset = reader.readDouble(offsets[13]);
  object.pMin = reader.readDouble(offsets[14]);
  object.packName = reader.readString(offsets[15]);
  object.useFixedIntervalOnLapse = reader.readBool(offsets[16]);
  object.writeModeMaxReps = reader.readLong(offsets[17]);
  object.writeModeThreshold = reader.readLong(offsets[18]);
  return object;
}

P _deckSettingsDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readDoubleList(offset) ?? []) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    case 12:
      return (reader.readLong(offset)) as P;
    case 13:
      return (reader.readDouble(offset)) as P;
    case 14:
      return (reader.readDouble(offset)) as P;
    case 15:
      return (reader.readString(offset)) as P;
    case 16:
      return (reader.readBool(offset)) as P;
    case 17:
      return (reader.readLong(offset)) as P;
    case 18:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _deckSettingsGetId(DeckSettings object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _deckSettingsGetLinks(DeckSettings object) {
  return [];
}

void _deckSettingsAttach(
    IsarCollection<dynamic> col, Id id, DeckSettings object) {
  object.id = id;
}

extension DeckSettingsByIndex on IsarCollection<DeckSettings> {
  Future<DeckSettings?> getByPackName(String packName) {
    return getByIndex(r'packName', [packName]);
  }

  DeckSettings? getByPackNameSync(String packName) {
    return getByIndexSync(r'packName', [packName]);
  }

  Future<bool> deleteByPackName(String packName) {
    return deleteByIndex(r'packName', [packName]);
  }

  bool deleteByPackNameSync(String packName) {
    return deleteByIndexSync(r'packName', [packName]);
  }

  Future<List<DeckSettings?>> getAllByPackName(List<String> packNameValues) {
    final values = packNameValues.map((e) => [e]).toList();
    return getAllByIndex(r'packName', values);
  }

  List<DeckSettings?> getAllByPackNameSync(List<String> packNameValues) {
    final values = packNameValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'packName', values);
  }

  Future<int> deleteAllByPackName(List<String> packNameValues) {
    final values = packNameValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'packName', values);
  }

  int deleteAllByPackNameSync(List<String> packNameValues) {
    final values = packNameValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'packName', values);
  }

  Future<Id> putByPackName(DeckSettings object) {
    return putByIndex(r'packName', object);
  }

  Id putByPackNameSync(DeckSettings object, {bool saveLinks = true}) {
    return putByIndexSync(r'packName', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByPackName(List<DeckSettings> objects) {
    return putAllByIndex(r'packName', objects);
  }

  List<Id> putAllByPackNameSync(List<DeckSettings> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'packName', objects, saveLinks: saveLinks);
  }
}

extension DeckSettingsQueryWhereSort
    on QueryBuilder<DeckSettings, DeckSettings, QWhere> {
  QueryBuilder<DeckSettings, DeckSettings, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension DeckSettingsQueryWhere
    on QueryBuilder<DeckSettings, DeckSettings, QWhereClause> {
  QueryBuilder<DeckSettings, DeckSettings, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterWhereClause> packNameEqualTo(
      String packName) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'packName',
        value: [packName],
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterWhereClause>
      packNameNotEqualTo(String packName) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'packName',
              lower: [],
              upper: [packName],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'packName',
              lower: [packName],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'packName',
              lower: [packName],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'packName',
              lower: [],
              upper: [packName],
              includeUpper: false,
            ));
      }
    });
  }
}

extension DeckSettingsQueryFilter
    on QueryBuilder<DeckSettings, DeckSettings, QFilterCondition> {
  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition> alphaEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'alpha',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      alphaGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'alpha',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition> alphaLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'alpha',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition> alphaBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'alpha',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition> betaEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'beta',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      betaGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'beta',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition> betaLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'beta',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition> betaBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'beta',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      enableWriteModeEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'enableWriteMode',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      initialNtEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'initialNt',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      initialNtGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'initialNt',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      initialNtLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'initialNt',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      initialNtBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'initialNt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      lapseFixedIntervalEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lapseFixedInterval',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      lapseFixedIntervalGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lapseFixedInterval',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      lapseFixedIntervalLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lapseFixedInterval',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      lapseFixedIntervalBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lapseFixedInterval',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      lapseToleranceEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lapseTolerance',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      lapseToleranceGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lapseTolerance',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      lapseToleranceLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lapseTolerance',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      lapseToleranceBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lapseTolerance',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      lastNewCardStudyDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastNewCardStudyDate',
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      lastNewCardStudyDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastNewCardStudyDate',
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      lastNewCardStudyDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastNewCardStudyDate',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      lastNewCardStudyDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastNewCardStudyDate',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      lastNewCardStudyDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastNewCardStudyDate',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      lastNewCardStudyDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastNewCardStudyDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      learningStepsElementEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'learningSteps',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      learningStepsElementGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'learningSteps',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      learningStepsElementLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'learningSteps',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      learningStepsElementBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'learningSteps',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      learningStepsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'learningSteps',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      learningStepsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'learningSteps',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      learningStepsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'learningSteps',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      learningStepsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'learningSteps',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      learningStepsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'learningSteps',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      learningStepsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'learningSteps',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      maxReviewsPerDayEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maxReviewsPerDay',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      maxReviewsPerDayGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'maxReviewsPerDay',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      maxReviewsPerDayLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'maxReviewsPerDay',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      maxReviewsPerDayBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'maxReviewsPerDay',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      newCardIntraDayMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'newCardIntraDayMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      newCardIntraDayMinutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'newCardIntraDayMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      newCardIntraDayMinutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'newCardIntraDayMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      newCardIntraDayMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'newCardIntraDayMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      newCardMinCorrectRepsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'newCardMinCorrectReps',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      newCardMinCorrectRepsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'newCardMinCorrectReps',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      newCardMinCorrectRepsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'newCardMinCorrectReps',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      newCardMinCorrectRepsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'newCardMinCorrectReps',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      newCardsPerDayEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'newCardsPerDay',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      newCardsPerDayGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'newCardsPerDay',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      newCardsPerDayLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'newCardsPerDay',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      newCardsPerDayBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'newCardsPerDay',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      newCardsSeenTodayEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'newCardsSeenToday',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      newCardsSeenTodayGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'newCardsSeenToday',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      newCardsSeenTodayLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'newCardsSeenToday',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      newCardsSeenTodayBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'newCardsSeenToday',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition> offsetEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'offset',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      offsetGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'offset',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      offsetLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'offset',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition> offsetBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'offset',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition> pMinEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pMin',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      pMinGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pMin',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition> pMinLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pMin',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition> pMinBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pMin',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      packNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'packName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      packNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'packName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      packNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'packName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      packNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'packName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      packNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'packName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      packNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'packName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      packNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'packName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      packNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'packName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      packNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'packName',
        value: '',
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      packNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'packName',
        value: '',
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      useFixedIntervalOnLapseEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'useFixedIntervalOnLapse',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      writeModeMaxRepsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'writeModeMaxReps',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      writeModeMaxRepsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'writeModeMaxReps',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      writeModeMaxRepsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'writeModeMaxReps',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      writeModeMaxRepsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'writeModeMaxReps',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      writeModeThresholdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'writeModeThreshold',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      writeModeThresholdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'writeModeThreshold',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      writeModeThresholdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'writeModeThreshold',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterFilterCondition>
      writeModeThresholdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'writeModeThreshold',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension DeckSettingsQueryObject
    on QueryBuilder<DeckSettings, DeckSettings, QFilterCondition> {}

extension DeckSettingsQueryLinks
    on QueryBuilder<DeckSettings, DeckSettings, QFilterCondition> {}

extension DeckSettingsQuerySortBy
    on QueryBuilder<DeckSettings, DeckSettings, QSortBy> {
  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy> sortByAlpha() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alpha', Sort.asc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy> sortByAlphaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alpha', Sort.desc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy> sortByBeta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'beta', Sort.asc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy> sortByBetaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'beta', Sort.desc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy>
      sortByEnableWriteMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableWriteMode', Sort.asc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy>
      sortByEnableWriteModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableWriteMode', Sort.desc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy> sortByInitialNt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initialNt', Sort.asc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy> sortByInitialNtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initialNt', Sort.desc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy>
      sortByLapseFixedInterval() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lapseFixedInterval', Sort.asc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy>
      sortByLapseFixedIntervalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lapseFixedInterval', Sort.desc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy>
      sortByLapseTolerance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lapseTolerance', Sort.asc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy>
      sortByLapseToleranceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lapseTolerance', Sort.desc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy>
      sortByLastNewCardStudyDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastNewCardStudyDate', Sort.asc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy>
      sortByLastNewCardStudyDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastNewCardStudyDate', Sort.desc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy>
      sortByMaxReviewsPerDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxReviewsPerDay', Sort.asc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy>
      sortByMaxReviewsPerDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxReviewsPerDay', Sort.desc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy>
      sortByNewCardIntraDayMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newCardIntraDayMinutes', Sort.asc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy>
      sortByNewCardIntraDayMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newCardIntraDayMinutes', Sort.desc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy>
      sortByNewCardMinCorrectReps() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newCardMinCorrectReps', Sort.asc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy>
      sortByNewCardMinCorrectRepsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newCardMinCorrectReps', Sort.desc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy>
      sortByNewCardsPerDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newCardsPerDay', Sort.asc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy>
      sortByNewCardsPerDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newCardsPerDay', Sort.desc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy>
      sortByNewCardsSeenToday() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newCardsSeenToday', Sort.asc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy>
      sortByNewCardsSeenTodayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newCardsSeenToday', Sort.desc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy> sortByOffset() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'offset', Sort.asc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy> sortByOffsetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'offset', Sort.desc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy> sortByPMin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pMin', Sort.asc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy> sortByPMinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pMin', Sort.desc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy> sortByPackName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packName', Sort.asc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy> sortByPackNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packName', Sort.desc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy>
      sortByUseFixedIntervalOnLapse() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'useFixedIntervalOnLapse', Sort.asc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy>
      sortByUseFixedIntervalOnLapseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'useFixedIntervalOnLapse', Sort.desc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy>
      sortByWriteModeMaxReps() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'writeModeMaxReps', Sort.asc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy>
      sortByWriteModeMaxRepsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'writeModeMaxReps', Sort.desc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy>
      sortByWriteModeThreshold() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'writeModeThreshold', Sort.asc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy>
      sortByWriteModeThresholdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'writeModeThreshold', Sort.desc);
    });
  }
}

extension DeckSettingsQuerySortThenBy
    on QueryBuilder<DeckSettings, DeckSettings, QSortThenBy> {
  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy> thenByAlpha() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alpha', Sort.asc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy> thenByAlphaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alpha', Sort.desc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy> thenByBeta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'beta', Sort.asc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy> thenByBetaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'beta', Sort.desc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy>
      thenByEnableWriteMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableWriteMode', Sort.asc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy>
      thenByEnableWriteModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableWriteMode', Sort.desc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy> thenByInitialNt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initialNt', Sort.asc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy> thenByInitialNtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initialNt', Sort.desc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy>
      thenByLapseFixedInterval() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lapseFixedInterval', Sort.asc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy>
      thenByLapseFixedIntervalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lapseFixedInterval', Sort.desc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy>
      thenByLapseTolerance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lapseTolerance', Sort.asc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy>
      thenByLapseToleranceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lapseTolerance', Sort.desc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy>
      thenByLastNewCardStudyDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastNewCardStudyDate', Sort.asc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy>
      thenByLastNewCardStudyDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastNewCardStudyDate', Sort.desc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy>
      thenByMaxReviewsPerDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxReviewsPerDay', Sort.asc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy>
      thenByMaxReviewsPerDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxReviewsPerDay', Sort.desc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy>
      thenByNewCardIntraDayMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newCardIntraDayMinutes', Sort.asc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy>
      thenByNewCardIntraDayMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newCardIntraDayMinutes', Sort.desc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy>
      thenByNewCardMinCorrectReps() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newCardMinCorrectReps', Sort.asc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy>
      thenByNewCardMinCorrectRepsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newCardMinCorrectReps', Sort.desc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy>
      thenByNewCardsPerDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newCardsPerDay', Sort.asc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy>
      thenByNewCardsPerDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newCardsPerDay', Sort.desc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy>
      thenByNewCardsSeenToday() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newCardsSeenToday', Sort.asc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy>
      thenByNewCardsSeenTodayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newCardsSeenToday', Sort.desc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy> thenByOffset() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'offset', Sort.asc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy> thenByOffsetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'offset', Sort.desc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy> thenByPMin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pMin', Sort.asc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy> thenByPMinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pMin', Sort.desc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy> thenByPackName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packName', Sort.asc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy> thenByPackNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packName', Sort.desc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy>
      thenByUseFixedIntervalOnLapse() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'useFixedIntervalOnLapse', Sort.asc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy>
      thenByUseFixedIntervalOnLapseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'useFixedIntervalOnLapse', Sort.desc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy>
      thenByWriteModeMaxReps() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'writeModeMaxReps', Sort.asc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy>
      thenByWriteModeMaxRepsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'writeModeMaxReps', Sort.desc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy>
      thenByWriteModeThreshold() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'writeModeThreshold', Sort.asc);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QAfterSortBy>
      thenByWriteModeThresholdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'writeModeThreshold', Sort.desc);
    });
  }
}

extension DeckSettingsQueryWhereDistinct
    on QueryBuilder<DeckSettings, DeckSettings, QDistinct> {
  QueryBuilder<DeckSettings, DeckSettings, QDistinct> distinctByAlpha() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'alpha');
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QDistinct> distinctByBeta() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'beta');
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QDistinct>
      distinctByEnableWriteMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'enableWriteMode');
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QDistinct> distinctByInitialNt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'initialNt');
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QDistinct>
      distinctByLapseFixedInterval() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lapseFixedInterval');
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QDistinct>
      distinctByLapseTolerance() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lapseTolerance');
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QDistinct>
      distinctByLastNewCardStudyDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastNewCardStudyDate');
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QDistinct>
      distinctByLearningSteps() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'learningSteps');
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QDistinct>
      distinctByMaxReviewsPerDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maxReviewsPerDay');
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QDistinct>
      distinctByNewCardIntraDayMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'newCardIntraDayMinutes');
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QDistinct>
      distinctByNewCardMinCorrectReps() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'newCardMinCorrectReps');
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QDistinct>
      distinctByNewCardsPerDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'newCardsPerDay');
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QDistinct>
      distinctByNewCardsSeenToday() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'newCardsSeenToday');
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QDistinct> distinctByOffset() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'offset');
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QDistinct> distinctByPMin() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pMin');
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QDistinct> distinctByPackName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'packName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QDistinct>
      distinctByUseFixedIntervalOnLapse() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'useFixedIntervalOnLapse');
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QDistinct>
      distinctByWriteModeMaxReps() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'writeModeMaxReps');
    });
  }

  QueryBuilder<DeckSettings, DeckSettings, QDistinct>
      distinctByWriteModeThreshold() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'writeModeThreshold');
    });
  }
}

extension DeckSettingsQueryProperty
    on QueryBuilder<DeckSettings, DeckSettings, QQueryProperty> {
  QueryBuilder<DeckSettings, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DeckSettings, double, QQueryOperations> alphaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'alpha');
    });
  }

  QueryBuilder<DeckSettings, double, QQueryOperations> betaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'beta');
    });
  }

  QueryBuilder<DeckSettings, bool, QQueryOperations> enableWriteModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'enableWriteMode');
    });
  }

  QueryBuilder<DeckSettings, double, QQueryOperations> initialNtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'initialNt');
    });
  }

  QueryBuilder<DeckSettings, double, QQueryOperations>
      lapseFixedIntervalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lapseFixedInterval');
    });
  }

  QueryBuilder<DeckSettings, int, QQueryOperations> lapseToleranceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lapseTolerance');
    });
  }

  QueryBuilder<DeckSettings, DateTime?, QQueryOperations>
      lastNewCardStudyDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastNewCardStudyDate');
    });
  }

  QueryBuilder<DeckSettings, List<double>, QQueryOperations>
      learningStepsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'learningSteps');
    });
  }

  QueryBuilder<DeckSettings, int, QQueryOperations> maxReviewsPerDayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maxReviewsPerDay');
    });
  }

  QueryBuilder<DeckSettings, int, QQueryOperations>
      newCardIntraDayMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'newCardIntraDayMinutes');
    });
  }

  QueryBuilder<DeckSettings, int, QQueryOperations>
      newCardMinCorrectRepsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'newCardMinCorrectReps');
    });
  }

  QueryBuilder<DeckSettings, int, QQueryOperations> newCardsPerDayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'newCardsPerDay');
    });
  }

  QueryBuilder<DeckSettings, int, QQueryOperations>
      newCardsSeenTodayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'newCardsSeenToday');
    });
  }

  QueryBuilder<DeckSettings, double, QQueryOperations> offsetProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'offset');
    });
  }

  QueryBuilder<DeckSettings, double, QQueryOperations> pMinProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pMin');
    });
  }

  QueryBuilder<DeckSettings, String, QQueryOperations> packNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'packName');
    });
  }

  QueryBuilder<DeckSettings, bool, QQueryOperations>
      useFixedIntervalOnLapseProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'useFixedIntervalOnLapse');
    });
  }

  QueryBuilder<DeckSettings, int, QQueryOperations> writeModeMaxRepsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'writeModeMaxReps');
    });
  }

  QueryBuilder<DeckSettings, int, QQueryOperations>
      writeModeThresholdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'writeModeThreshold');
    });
  }
}
