// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deck_daily_stats.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDeckDailyStatsCollection on Isar {
  IsarCollection<DeckDailyStats> get deckDailyStats => this.collection();
}

const DeckDailyStatsSchema = CollectionSchema(
  name: r'DeckDailyStats',
  id: 7216952117725740970,
  properties: {
    r'averageAnswerTimeMs': PropertySchema(
      id: 0,
      name: r'averageAnswerTimeMs',
      type: IsarType.long,
    ),
    r'correctCount': PropertySchema(
      id: 1,
      name: r'correctCount',
      type: IsarType.long,
    ),
    r'learningReviewCount': PropertySchema(
      id: 2,
      name: r'learningReviewCount',
      type: IsarType.long,
    ),
    r'learningStudyTimeMs': PropertySchema(
      id: 3,
      name: r'learningStudyTimeMs',
      type: IsarType.long,
    ),
    r'newReviewCount': PropertySchema(
      id: 4,
      name: r'newReviewCount',
      type: IsarType.long,
    ),
    r'newStudyTimeMs': PropertySchema(
      id: 5,
      name: r'newStudyTimeMs',
      type: IsarType.long,
    ),
    r'packDayKey': PropertySchema(
      id: 6,
      name: r'packDayKey',
      type: IsarType.string,
    ),
    r'packName': PropertySchema(
      id: 7,
      name: r'packName',
      type: IsarType.string,
    ),
    r'quarterHourBuckets': PropertySchema(
      id: 8,
      name: r'quarterHourBuckets',
      type: IsarType.longList,
    ),
    r'reviewCount': PropertySchema(
      id: 9,
      name: r'reviewCount',
      type: IsarType.long,
    ),
    r'reviewStateCount': PropertySchema(
      id: 10,
      name: r'reviewStateCount',
      type: IsarType.long,
    ),
    r'reviewStudyTimeMs': PropertySchema(
      id: 11,
      name: r'reviewStudyTimeMs',
      type: IsarType.long,
    ),
    r'sessionCount': PropertySchema(
      id: 12,
      name: r'sessionCount',
      type: IsarType.long,
    ),
    r'studyDay': PropertySchema(
      id: 13,
      name: r'studyDay',
      type: IsarType.dateTime,
    ),
    r'totalStudyTimeMs': PropertySchema(
      id: 14,
      name: r'totalStudyTimeMs',
      type: IsarType.long,
    ),
    r'uniqueCardCount': PropertySchema(
      id: 15,
      name: r'uniqueCardCount',
      type: IsarType.long,
    ),
    r'wrongCount': PropertySchema(
      id: 16,
      name: r'wrongCount',
      type: IsarType.long,
    )
  },
  estimateSize: _deckDailyStatsEstimateSize,
  serialize: _deckDailyStatsSerialize,
  deserialize: _deckDailyStatsDeserialize,
  deserializeProp: _deckDailyStatsDeserializeProp,
  idName: r'id',
  indexes: {
    r'packDayKey': IndexSchema(
      id: 864724493064990128,
      name: r'packDayKey',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'packDayKey',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'packName': IndexSchema(
      id: -4088498089984738832,
      name: r'packName',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'packName',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'studyDay': IndexSchema(
      id: -4563311088739575611,
      name: r'studyDay',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'studyDay',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _deckDailyStatsGetId,
  getLinks: _deckDailyStatsGetLinks,
  attach: _deckDailyStatsAttach,
  version: '3.1.0+1',
);

int _deckDailyStatsEstimateSize(
  DeckDailyStats object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.packDayKey.length * 3;
  bytesCount += 3 + object.packName.length * 3;
  bytesCount += 3 + object.quarterHourBuckets.length * 8;
  return bytesCount;
}

void _deckDailyStatsSerialize(
  DeckDailyStats object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.averageAnswerTimeMs);
  writer.writeLong(offsets[1], object.correctCount);
  writer.writeLong(offsets[2], object.learningReviewCount);
  writer.writeLong(offsets[3], object.learningStudyTimeMs);
  writer.writeLong(offsets[4], object.newReviewCount);
  writer.writeLong(offsets[5], object.newStudyTimeMs);
  writer.writeString(offsets[6], object.packDayKey);
  writer.writeString(offsets[7], object.packName);
  writer.writeLongList(offsets[8], object.quarterHourBuckets);
  writer.writeLong(offsets[9], object.reviewCount);
  writer.writeLong(offsets[10], object.reviewStateCount);
  writer.writeLong(offsets[11], object.reviewStudyTimeMs);
  writer.writeLong(offsets[12], object.sessionCount);
  writer.writeDateTime(offsets[13], object.studyDay);
  writer.writeLong(offsets[14], object.totalStudyTimeMs);
  writer.writeLong(offsets[15], object.uniqueCardCount);
  writer.writeLong(offsets[16], object.wrongCount);
}

DeckDailyStats _deckDailyStatsDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DeckDailyStats();
  object.averageAnswerTimeMs = reader.readLong(offsets[0]);
  object.correctCount = reader.readLong(offsets[1]);
  object.id = id;
  object.learningReviewCount = reader.readLong(offsets[2]);
  object.learningStudyTimeMs = reader.readLong(offsets[3]);
  object.newReviewCount = reader.readLong(offsets[4]);
  object.newStudyTimeMs = reader.readLong(offsets[5]);
  object.packDayKey = reader.readString(offsets[6]);
  object.packName = reader.readString(offsets[7]);
  object.quarterHourBuckets = reader.readLongList(offsets[8]) ?? [];
  object.reviewCount = reader.readLong(offsets[9]);
  object.reviewStateCount = reader.readLong(offsets[10]);
  object.reviewStudyTimeMs = reader.readLong(offsets[11]);
  object.sessionCount = reader.readLong(offsets[12]);
  object.studyDay = reader.readDateTime(offsets[13]);
  object.totalStudyTimeMs = reader.readLong(offsets[14]);
  object.uniqueCardCount = reader.readLong(offsets[15]);
  object.wrongCount = reader.readLong(offsets[16]);
  return object;
}

P _deckDailyStatsDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readLongList(offset) ?? []) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    case 12:
      return (reader.readLong(offset)) as P;
    case 13:
      return (reader.readDateTime(offset)) as P;
    case 14:
      return (reader.readLong(offset)) as P;
    case 15:
      return (reader.readLong(offset)) as P;
    case 16:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _deckDailyStatsGetId(DeckDailyStats object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _deckDailyStatsGetLinks(DeckDailyStats object) {
  return [];
}

void _deckDailyStatsAttach(
    IsarCollection<dynamic> col, Id id, DeckDailyStats object) {
  object.id = id;
}

extension DeckDailyStatsByIndex on IsarCollection<DeckDailyStats> {
  Future<DeckDailyStats?> getByPackDayKey(String packDayKey) {
    return getByIndex(r'packDayKey', [packDayKey]);
  }

  DeckDailyStats? getByPackDayKeySync(String packDayKey) {
    return getByIndexSync(r'packDayKey', [packDayKey]);
  }

  Future<bool> deleteByPackDayKey(String packDayKey) {
    return deleteByIndex(r'packDayKey', [packDayKey]);
  }

  bool deleteByPackDayKeySync(String packDayKey) {
    return deleteByIndexSync(r'packDayKey', [packDayKey]);
  }

  Future<List<DeckDailyStats?>> getAllByPackDayKey(
      List<String> packDayKeyValues) {
    final values = packDayKeyValues.map((e) => [e]).toList();
    return getAllByIndex(r'packDayKey', values);
  }

  List<DeckDailyStats?> getAllByPackDayKeySync(List<String> packDayKeyValues) {
    final values = packDayKeyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'packDayKey', values);
  }

  Future<int> deleteAllByPackDayKey(List<String> packDayKeyValues) {
    final values = packDayKeyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'packDayKey', values);
  }

  int deleteAllByPackDayKeySync(List<String> packDayKeyValues) {
    final values = packDayKeyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'packDayKey', values);
  }

  Future<Id> putByPackDayKey(DeckDailyStats object) {
    return putByIndex(r'packDayKey', object);
  }

  Id putByPackDayKeySync(DeckDailyStats object, {bool saveLinks = true}) {
    return putByIndexSync(r'packDayKey', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByPackDayKey(List<DeckDailyStats> objects) {
    return putAllByIndex(r'packDayKey', objects);
  }

  List<Id> putAllByPackDayKeySync(List<DeckDailyStats> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'packDayKey', objects, saveLinks: saveLinks);
  }
}

extension DeckDailyStatsQueryWhereSort
    on QueryBuilder<DeckDailyStats, DeckDailyStats, QWhere> {
  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterWhere> anyStudyDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'studyDay'),
      );
    });
  }
}

extension DeckDailyStatsQueryWhere
    on QueryBuilder<DeckDailyStats, DeckDailyStats, QWhereClause> {
  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterWhereClause> idBetween(
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

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterWhereClause>
      packDayKeyEqualTo(String packDayKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'packDayKey',
        value: [packDayKey],
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterWhereClause>
      packDayKeyNotEqualTo(String packDayKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'packDayKey',
              lower: [],
              upper: [packDayKey],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'packDayKey',
              lower: [packDayKey],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'packDayKey',
              lower: [packDayKey],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'packDayKey',
              lower: [],
              upper: [packDayKey],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterWhereClause>
      packNameEqualTo(String packName) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'packName',
        value: [packName],
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterWhereClause>
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

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterWhereClause>
      studyDayEqualTo(DateTime studyDay) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'studyDay',
        value: [studyDay],
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterWhereClause>
      studyDayNotEqualTo(DateTime studyDay) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'studyDay',
              lower: [],
              upper: [studyDay],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'studyDay',
              lower: [studyDay],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'studyDay',
              lower: [studyDay],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'studyDay',
              lower: [],
              upper: [studyDay],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterWhereClause>
      studyDayGreaterThan(
    DateTime studyDay, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'studyDay',
        lower: [studyDay],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterWhereClause>
      studyDayLessThan(
    DateTime studyDay, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'studyDay',
        lower: [],
        upper: [studyDay],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterWhereClause>
      studyDayBetween(
    DateTime lowerStudyDay,
    DateTime upperStudyDay, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'studyDay',
        lower: [lowerStudyDay],
        includeLower: includeLower,
        upper: [upperStudyDay],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension DeckDailyStatsQueryFilter
    on QueryBuilder<DeckDailyStats, DeckDailyStats, QFilterCondition> {
  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      averageAnswerTimeMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'averageAnswerTimeMs',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      averageAnswerTimeMsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'averageAnswerTimeMs',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      averageAnswerTimeMsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'averageAnswerTimeMs',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      averageAnswerTimeMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'averageAnswerTimeMs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      correctCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'correctCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      correctCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'correctCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      correctCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'correctCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      correctCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'correctCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition> idBetween(
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

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      learningReviewCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'learningReviewCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      learningReviewCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'learningReviewCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      learningReviewCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'learningReviewCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      learningReviewCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'learningReviewCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      learningStudyTimeMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'learningStudyTimeMs',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      learningStudyTimeMsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'learningStudyTimeMs',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      learningStudyTimeMsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'learningStudyTimeMs',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      learningStudyTimeMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'learningStudyTimeMs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      newReviewCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'newReviewCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      newReviewCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'newReviewCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      newReviewCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'newReviewCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      newReviewCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'newReviewCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      newStudyTimeMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'newStudyTimeMs',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      newStudyTimeMsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'newStudyTimeMs',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      newStudyTimeMsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'newStudyTimeMs',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      newStudyTimeMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'newStudyTimeMs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      packDayKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'packDayKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      packDayKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'packDayKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      packDayKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'packDayKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      packDayKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'packDayKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      packDayKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'packDayKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      packDayKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'packDayKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      packDayKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'packDayKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      packDayKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'packDayKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      packDayKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'packDayKey',
        value: '',
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      packDayKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'packDayKey',
        value: '',
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
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

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
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

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
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

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
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

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
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

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
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

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      packNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'packName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      packNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'packName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      packNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'packName',
        value: '',
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      packNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'packName',
        value: '',
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      quarterHourBucketsElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'quarterHourBuckets',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      quarterHourBucketsElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'quarterHourBuckets',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      quarterHourBucketsElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'quarterHourBuckets',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      quarterHourBucketsElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'quarterHourBuckets',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      quarterHourBucketsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'quarterHourBuckets',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      quarterHourBucketsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'quarterHourBuckets',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      quarterHourBucketsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'quarterHourBuckets',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      quarterHourBucketsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'quarterHourBuckets',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      quarterHourBucketsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'quarterHourBuckets',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      quarterHourBucketsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'quarterHourBuckets',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      reviewCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reviewCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      reviewCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reviewCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      reviewCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reviewCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      reviewCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reviewCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      reviewStateCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reviewStateCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      reviewStateCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reviewStateCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      reviewStateCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reviewStateCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      reviewStateCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reviewStateCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      reviewStudyTimeMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reviewStudyTimeMs',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      reviewStudyTimeMsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reviewStudyTimeMs',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      reviewStudyTimeMsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reviewStudyTimeMs',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      reviewStudyTimeMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reviewStudyTimeMs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      sessionCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sessionCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      sessionCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sessionCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      sessionCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sessionCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      sessionCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sessionCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      studyDayEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'studyDay',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      studyDayGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'studyDay',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      studyDayLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'studyDay',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      studyDayBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'studyDay',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      totalStudyTimeMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalStudyTimeMs',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      totalStudyTimeMsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalStudyTimeMs',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      totalStudyTimeMsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalStudyTimeMs',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      totalStudyTimeMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalStudyTimeMs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      uniqueCardCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uniqueCardCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      uniqueCardCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'uniqueCardCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      uniqueCardCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'uniqueCardCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      uniqueCardCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'uniqueCardCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      wrongCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'wrongCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      wrongCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'wrongCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      wrongCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'wrongCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterFilterCondition>
      wrongCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'wrongCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension DeckDailyStatsQueryObject
    on QueryBuilder<DeckDailyStats, DeckDailyStats, QFilterCondition> {}

extension DeckDailyStatsQueryLinks
    on QueryBuilder<DeckDailyStats, DeckDailyStats, QFilterCondition> {}

extension DeckDailyStatsQuerySortBy
    on QueryBuilder<DeckDailyStats, DeckDailyStats, QSortBy> {
  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      sortByAverageAnswerTimeMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'averageAnswerTimeMs', Sort.asc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      sortByAverageAnswerTimeMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'averageAnswerTimeMs', Sort.desc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      sortByCorrectCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctCount', Sort.asc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      sortByCorrectCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctCount', Sort.desc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      sortByLearningReviewCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'learningReviewCount', Sort.asc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      sortByLearningReviewCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'learningReviewCount', Sort.desc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      sortByLearningStudyTimeMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'learningStudyTimeMs', Sort.asc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      sortByLearningStudyTimeMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'learningStudyTimeMs', Sort.desc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      sortByNewReviewCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newReviewCount', Sort.asc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      sortByNewReviewCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newReviewCount', Sort.desc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      sortByNewStudyTimeMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newStudyTimeMs', Sort.asc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      sortByNewStudyTimeMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newStudyTimeMs', Sort.desc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      sortByPackDayKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packDayKey', Sort.asc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      sortByPackDayKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packDayKey', Sort.desc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy> sortByPackName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packName', Sort.asc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      sortByPackNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packName', Sort.desc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      sortByReviewCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewCount', Sort.asc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      sortByReviewCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewCount', Sort.desc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      sortByReviewStateCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewStateCount', Sort.asc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      sortByReviewStateCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewStateCount', Sort.desc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      sortByReviewStudyTimeMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewStudyTimeMs', Sort.asc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      sortByReviewStudyTimeMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewStudyTimeMs', Sort.desc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      sortBySessionCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionCount', Sort.asc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      sortBySessionCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionCount', Sort.desc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy> sortByStudyDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studyDay', Sort.asc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      sortByStudyDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studyDay', Sort.desc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      sortByTotalStudyTimeMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalStudyTimeMs', Sort.asc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      sortByTotalStudyTimeMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalStudyTimeMs', Sort.desc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      sortByUniqueCardCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uniqueCardCount', Sort.asc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      sortByUniqueCardCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uniqueCardCount', Sort.desc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      sortByWrongCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wrongCount', Sort.asc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      sortByWrongCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wrongCount', Sort.desc);
    });
  }
}

extension DeckDailyStatsQuerySortThenBy
    on QueryBuilder<DeckDailyStats, DeckDailyStats, QSortThenBy> {
  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      thenByAverageAnswerTimeMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'averageAnswerTimeMs', Sort.asc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      thenByAverageAnswerTimeMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'averageAnswerTimeMs', Sort.desc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      thenByCorrectCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctCount', Sort.asc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      thenByCorrectCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctCount', Sort.desc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      thenByLearningReviewCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'learningReviewCount', Sort.asc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      thenByLearningReviewCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'learningReviewCount', Sort.desc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      thenByLearningStudyTimeMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'learningStudyTimeMs', Sort.asc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      thenByLearningStudyTimeMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'learningStudyTimeMs', Sort.desc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      thenByNewReviewCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newReviewCount', Sort.asc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      thenByNewReviewCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newReviewCount', Sort.desc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      thenByNewStudyTimeMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newStudyTimeMs', Sort.asc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      thenByNewStudyTimeMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newStudyTimeMs', Sort.desc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      thenByPackDayKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packDayKey', Sort.asc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      thenByPackDayKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packDayKey', Sort.desc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy> thenByPackName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packName', Sort.asc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      thenByPackNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packName', Sort.desc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      thenByReviewCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewCount', Sort.asc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      thenByReviewCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewCount', Sort.desc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      thenByReviewStateCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewStateCount', Sort.asc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      thenByReviewStateCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewStateCount', Sort.desc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      thenByReviewStudyTimeMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewStudyTimeMs', Sort.asc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      thenByReviewStudyTimeMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewStudyTimeMs', Sort.desc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      thenBySessionCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionCount', Sort.asc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      thenBySessionCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionCount', Sort.desc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy> thenByStudyDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studyDay', Sort.asc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      thenByStudyDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studyDay', Sort.desc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      thenByTotalStudyTimeMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalStudyTimeMs', Sort.asc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      thenByTotalStudyTimeMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalStudyTimeMs', Sort.desc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      thenByUniqueCardCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uniqueCardCount', Sort.asc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      thenByUniqueCardCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uniqueCardCount', Sort.desc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      thenByWrongCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wrongCount', Sort.asc);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QAfterSortBy>
      thenByWrongCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wrongCount', Sort.desc);
    });
  }
}

extension DeckDailyStatsQueryWhereDistinct
    on QueryBuilder<DeckDailyStats, DeckDailyStats, QDistinct> {
  QueryBuilder<DeckDailyStats, DeckDailyStats, QDistinct>
      distinctByAverageAnswerTimeMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'averageAnswerTimeMs');
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QDistinct>
      distinctByCorrectCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'correctCount');
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QDistinct>
      distinctByLearningReviewCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'learningReviewCount');
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QDistinct>
      distinctByLearningStudyTimeMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'learningStudyTimeMs');
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QDistinct>
      distinctByNewReviewCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'newReviewCount');
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QDistinct>
      distinctByNewStudyTimeMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'newStudyTimeMs');
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QDistinct> distinctByPackDayKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'packDayKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QDistinct> distinctByPackName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'packName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QDistinct>
      distinctByQuarterHourBuckets() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'quarterHourBuckets');
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QDistinct>
      distinctByReviewCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reviewCount');
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QDistinct>
      distinctByReviewStateCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reviewStateCount');
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QDistinct>
      distinctByReviewStudyTimeMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reviewStudyTimeMs');
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QDistinct>
      distinctBySessionCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sessionCount');
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QDistinct> distinctByStudyDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'studyDay');
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QDistinct>
      distinctByTotalStudyTimeMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalStudyTimeMs');
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QDistinct>
      distinctByUniqueCardCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uniqueCardCount');
    });
  }

  QueryBuilder<DeckDailyStats, DeckDailyStats, QDistinct>
      distinctByWrongCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'wrongCount');
    });
  }
}

extension DeckDailyStatsQueryProperty
    on QueryBuilder<DeckDailyStats, DeckDailyStats, QQueryProperty> {
  QueryBuilder<DeckDailyStats, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DeckDailyStats, int, QQueryOperations>
      averageAnswerTimeMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'averageAnswerTimeMs');
    });
  }

  QueryBuilder<DeckDailyStats, int, QQueryOperations> correctCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'correctCount');
    });
  }

  QueryBuilder<DeckDailyStats, int, QQueryOperations>
      learningReviewCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'learningReviewCount');
    });
  }

  QueryBuilder<DeckDailyStats, int, QQueryOperations>
      learningStudyTimeMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'learningStudyTimeMs');
    });
  }

  QueryBuilder<DeckDailyStats, int, QQueryOperations> newReviewCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'newReviewCount');
    });
  }

  QueryBuilder<DeckDailyStats, int, QQueryOperations> newStudyTimeMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'newStudyTimeMs');
    });
  }

  QueryBuilder<DeckDailyStats, String, QQueryOperations> packDayKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'packDayKey');
    });
  }

  QueryBuilder<DeckDailyStats, String, QQueryOperations> packNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'packName');
    });
  }

  QueryBuilder<DeckDailyStats, List<int>, QQueryOperations>
      quarterHourBucketsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quarterHourBuckets');
    });
  }

  QueryBuilder<DeckDailyStats, int, QQueryOperations> reviewCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reviewCount');
    });
  }

  QueryBuilder<DeckDailyStats, int, QQueryOperations>
      reviewStateCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reviewStateCount');
    });
  }

  QueryBuilder<DeckDailyStats, int, QQueryOperations>
      reviewStudyTimeMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reviewStudyTimeMs');
    });
  }

  QueryBuilder<DeckDailyStats, int, QQueryOperations> sessionCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sessionCount');
    });
  }

  QueryBuilder<DeckDailyStats, DateTime, QQueryOperations> studyDayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'studyDay');
    });
  }

  QueryBuilder<DeckDailyStats, int, QQueryOperations>
      totalStudyTimeMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalStudyTimeMs');
    });
  }

  QueryBuilder<DeckDailyStats, int, QQueryOperations>
      uniqueCardCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uniqueCardCount');
    });
  }

  QueryBuilder<DeckDailyStats, int, QQueryOperations> wrongCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'wrongCount');
    });
  }
}
