// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_session_history.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetStudySessionHistoryCollection on Isar {
  IsarCollection<StudySessionHistory> get studySessionHistorys =>
      this.collection();
}

const StudySessionHistorySchema = CollectionSchema(
  name: r'StudySessionHistory',
  id: 4495893776649691327,
  properties: {
    r'answerCount': PropertySchema(
      id: 0,
      name: r'answerCount',
      type: IsarType.long,
    ),
    r'averageAnswerTimeMs': PropertySchema(
      id: 1,
      name: r'averageAnswerTimeMs',
      type: IsarType.long,
    ),
    r'correctCount': PropertySchema(
      id: 2,
      name: r'correctCount',
      type: IsarType.long,
    ),
    r'endedAt': PropertySchema(
      id: 3,
      name: r'endedAt',
      type: IsarType.dateTime,
    ),
    r'packName': PropertySchema(
      id: 4,
      name: r'packName',
      type: IsarType.string,
    ),
    r'sessionDay': PropertySchema(
      id: 5,
      name: r'sessionDay',
      type: IsarType.dateTime,
    ),
    r'sessionId': PropertySchema(
      id: 6,
      name: r'sessionId',
      type: IsarType.string,
    ),
    r'startedAt': PropertySchema(
      id: 7,
      name: r'startedAt',
      type: IsarType.dateTime,
    ),
    r'totalStudyTimeMs': PropertySchema(
      id: 8,
      name: r'totalStudyTimeMs',
      type: IsarType.long,
    ),
    r'uniqueCardCount': PropertySchema(
      id: 9,
      name: r'uniqueCardCount',
      type: IsarType.long,
    ),
    r'wrongCount': PropertySchema(
      id: 10,
      name: r'wrongCount',
      type: IsarType.long,
    ),
  },
  estimateSize: _studySessionHistoryEstimateSize,
  serialize: _studySessionHistorySerialize,
  deserialize: _studySessionHistoryDeserialize,
  deserializeProp: _studySessionHistoryDeserializeProp,
  idName: r'id',
  indexes: {
    r'sessionId': IndexSchema(
      id: 6949518585047923839,
      name: r'sessionId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'sessionId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
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
        ),
      ],
    ),
    r'sessionDay': IndexSchema(
      id: 2097484500333025716,
      name: r'sessionDay',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'sessionDay',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'startedAt': IndexSchema(
      id: 8114395319341636597,
      name: r'startedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'startedAt',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'endedAt': IndexSchema(
      id: 6537651538163225198,
      name: r'endedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'endedAt',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},
  getId: _studySessionHistoryGetId,
  getLinks: _studySessionHistoryGetLinks,
  attach: _studySessionHistoryAttach,
  version: '3.1.0+1',
);

int _studySessionHistoryEstimateSize(
  StudySessionHistory object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.packName.length * 3;
  bytesCount += 3 + object.sessionId.length * 3;
  return bytesCount;
}

void _studySessionHistorySerialize(
  StudySessionHistory object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.answerCount);
  writer.writeLong(offsets[1], object.averageAnswerTimeMs);
  writer.writeLong(offsets[2], object.correctCount);
  writer.writeDateTime(offsets[3], object.endedAt);
  writer.writeString(offsets[4], object.packName);
  writer.writeDateTime(offsets[5], object.sessionDay);
  writer.writeString(offsets[6], object.sessionId);
  writer.writeDateTime(offsets[7], object.startedAt);
  writer.writeLong(offsets[8], object.totalStudyTimeMs);
  writer.writeLong(offsets[9], object.uniqueCardCount);
  writer.writeLong(offsets[10], object.wrongCount);
}

StudySessionHistory _studySessionHistoryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = StudySessionHistory();
  object.answerCount = reader.readLong(offsets[0]);
  object.averageAnswerTimeMs = reader.readLong(offsets[1]);
  object.correctCount = reader.readLong(offsets[2]);
  object.endedAt = reader.readDateTime(offsets[3]);
  object.id = id;
  object.packName = reader.readString(offsets[4]);
  object.sessionDay = reader.readDateTime(offsets[5]);
  object.sessionId = reader.readString(offsets[6]);
  object.startedAt = reader.readDateTime(offsets[7]);
  object.totalStudyTimeMs = reader.readLong(offsets[8]);
  object.uniqueCardCount = reader.readLong(offsets[9]);
  object.wrongCount = reader.readLong(offsets[10]);
  return object;
}

P _studySessionHistoryDeserializeProp<P>(
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
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _studySessionHistoryGetId(StudySessionHistory object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _studySessionHistoryGetLinks(
  StudySessionHistory object,
) {
  return [];
}

void _studySessionHistoryAttach(
  IsarCollection<dynamic> col,
  Id id,
  StudySessionHistory object,
) {
  object.id = id;
}

extension StudySessionHistoryByIndex on IsarCollection<StudySessionHistory> {
  Future<StudySessionHistory?> getBySessionId(String sessionId) {
    return getByIndex(r'sessionId', [sessionId]);
  }

  StudySessionHistory? getBySessionIdSync(String sessionId) {
    return getByIndexSync(r'sessionId', [sessionId]);
  }

  Future<bool> deleteBySessionId(String sessionId) {
    return deleteByIndex(r'sessionId', [sessionId]);
  }

  bool deleteBySessionIdSync(String sessionId) {
    return deleteByIndexSync(r'sessionId', [sessionId]);
  }

  Future<List<StudySessionHistory?>> getAllBySessionId(
    List<String> sessionIdValues,
  ) {
    final values = sessionIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'sessionId', values);
  }

  List<StudySessionHistory?> getAllBySessionIdSync(
    List<String> sessionIdValues,
  ) {
    final values = sessionIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'sessionId', values);
  }

  Future<int> deleteAllBySessionId(List<String> sessionIdValues) {
    final values = sessionIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'sessionId', values);
  }

  int deleteAllBySessionIdSync(List<String> sessionIdValues) {
    final values = sessionIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'sessionId', values);
  }

  Future<Id> putBySessionId(StudySessionHistory object) {
    return putByIndex(r'sessionId', object);
  }

  Id putBySessionIdSync(StudySessionHistory object, {bool saveLinks = true}) {
    return putByIndexSync(r'sessionId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllBySessionId(List<StudySessionHistory> objects) {
    return putAllByIndex(r'sessionId', objects);
  }

  List<Id> putAllBySessionIdSync(
    List<StudySessionHistory> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'sessionId', objects, saveLinks: saveLinks);
  }
}

extension StudySessionHistoryQueryWhereSort
    on QueryBuilder<StudySessionHistory, StudySessionHistory, QWhere> {
  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterWhere>
  anySessionDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'sessionDay'),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterWhere>
  anyStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'startedAt'),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterWhere>
  anyEndedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'endedAt'),
      );
    });
  }
}

extension StudySessionHistoryQueryWhere
    on QueryBuilder<StudySessionHistory, StudySessionHistory, QWhereClause> {
  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterWhereClause>
  idNotEqualTo(Id id) {
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

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterWhereClause>
  idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterWhereClause>
  sessionIdEqualTo(String sessionId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'sessionId', value: [sessionId]),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterWhereClause>
  sessionIdNotEqualTo(String sessionId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'sessionId',
                lower: [],
                upper: [sessionId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'sessionId',
                lower: [sessionId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'sessionId',
                lower: [sessionId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'sessionId',
                lower: [],
                upper: [sessionId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterWhereClause>
  packNameEqualTo(String packName) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'packName', value: [packName]),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterWhereClause>
  packNameNotEqualTo(String packName) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'packName',
                lower: [],
                upper: [packName],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'packName',
                lower: [packName],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'packName',
                lower: [packName],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'packName',
                lower: [],
                upper: [packName],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterWhereClause>
  sessionDayEqualTo(DateTime sessionDay) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'sessionDay', value: [sessionDay]),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterWhereClause>
  sessionDayNotEqualTo(DateTime sessionDay) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'sessionDay',
                lower: [],
                upper: [sessionDay],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'sessionDay',
                lower: [sessionDay],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'sessionDay',
                lower: [sessionDay],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'sessionDay',
                lower: [],
                upper: [sessionDay],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterWhereClause>
  sessionDayGreaterThan(DateTime sessionDay, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'sessionDay',
          lower: [sessionDay],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterWhereClause>
  sessionDayLessThan(DateTime sessionDay, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'sessionDay',
          lower: [],
          upper: [sessionDay],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterWhereClause>
  sessionDayBetween(
    DateTime lowerSessionDay,
    DateTime upperSessionDay, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'sessionDay',
          lower: [lowerSessionDay],
          includeLower: includeLower,
          upper: [upperSessionDay],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterWhereClause>
  startedAtEqualTo(DateTime startedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'startedAt', value: [startedAt]),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterWhereClause>
  startedAtNotEqualTo(DateTime startedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'startedAt',
                lower: [],
                upper: [startedAt],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'startedAt',
                lower: [startedAt],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'startedAt',
                lower: [startedAt],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'startedAt',
                lower: [],
                upper: [startedAt],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterWhereClause>
  startedAtGreaterThan(DateTime startedAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'startedAt',
          lower: [startedAt],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterWhereClause>
  startedAtLessThan(DateTime startedAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'startedAt',
          lower: [],
          upper: [startedAt],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterWhereClause>
  startedAtBetween(
    DateTime lowerStartedAt,
    DateTime upperStartedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'startedAt',
          lower: [lowerStartedAt],
          includeLower: includeLower,
          upper: [upperStartedAt],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterWhereClause>
  endedAtEqualTo(DateTime endedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'endedAt', value: [endedAt]),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterWhereClause>
  endedAtNotEqualTo(DateTime endedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'endedAt',
                lower: [],
                upper: [endedAt],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'endedAt',
                lower: [endedAt],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'endedAt',
                lower: [endedAt],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'endedAt',
                lower: [],
                upper: [endedAt],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterWhereClause>
  endedAtGreaterThan(DateTime endedAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'endedAt',
          lower: [endedAt],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterWhereClause>
  endedAtLessThan(DateTime endedAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'endedAt',
          lower: [],
          upper: [endedAt],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterWhereClause>
  endedAtBetween(
    DateTime lowerEndedAt,
    DateTime upperEndedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'endedAt',
          lower: [lowerEndedAt],
          includeLower: includeLower,
          upper: [upperEndedAt],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension StudySessionHistoryQueryFilter
    on
        QueryBuilder<
          StudySessionHistory,
          StudySessionHistory,
          QFilterCondition
        > {
  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  answerCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'answerCount', value: value),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  answerCountGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'answerCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  answerCountLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'answerCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  answerCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'answerCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  averageAnswerTimeMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'averageAnswerTimeMs', value: value),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  averageAnswerTimeMsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'averageAnswerTimeMs',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  averageAnswerTimeMsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'averageAnswerTimeMs',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  averageAnswerTimeMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'averageAnswerTimeMs',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  correctCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'correctCount', value: value),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  correctCountGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'correctCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  correctCountLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'correctCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  correctCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'correctCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  endedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'endedAt', value: value),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  endedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'endedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  endedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'endedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  endedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'endedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  packNameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'packName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  packNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'packName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  packNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'packName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  packNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'packName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  packNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'packName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  packNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'packName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  packNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'packName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  packNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'packName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  packNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'packName', value: ''),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  packNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'packName', value: ''),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  sessionDayEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sessionDay', value: value),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  sessionDayGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sessionDay',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  sessionDayLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sessionDay',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  sessionDayBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sessionDay',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  sessionIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'sessionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  sessionIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sessionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  sessionIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sessionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  sessionIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sessionId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  sessionIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'sessionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  sessionIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'sessionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  sessionIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'sessionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  sessionIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'sessionId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  sessionIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sessionId', value: ''),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  sessionIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'sessionId', value: ''),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  startedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'startedAt', value: value),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  startedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'startedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  startedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'startedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  startedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'startedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  totalStudyTimeMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'totalStudyTimeMs', value: value),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  totalStudyTimeMsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'totalStudyTimeMs',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  totalStudyTimeMsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'totalStudyTimeMs',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  totalStudyTimeMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'totalStudyTimeMs',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  uniqueCardCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'uniqueCardCount', value: value),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  uniqueCardCountGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'uniqueCardCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  uniqueCardCountLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'uniqueCardCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  uniqueCardCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'uniqueCardCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  wrongCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'wrongCount', value: value),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  wrongCountGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'wrongCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  wrongCountLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'wrongCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterFilterCondition>
  wrongCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'wrongCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension StudySessionHistoryQueryObject
    on
        QueryBuilder<
          StudySessionHistory,
          StudySessionHistory,
          QFilterCondition
        > {}

extension StudySessionHistoryQueryLinks
    on
        QueryBuilder<
          StudySessionHistory,
          StudySessionHistory,
          QFilterCondition
        > {}

extension StudySessionHistoryQuerySortBy
    on QueryBuilder<StudySessionHistory, StudySessionHistory, QSortBy> {
  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterSortBy>
  sortByAnswerCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'answerCount', Sort.asc);
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterSortBy>
  sortByAnswerCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'answerCount', Sort.desc);
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterSortBy>
  sortByAverageAnswerTimeMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'averageAnswerTimeMs', Sort.asc);
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterSortBy>
  sortByAverageAnswerTimeMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'averageAnswerTimeMs', Sort.desc);
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterSortBy>
  sortByCorrectCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctCount', Sort.asc);
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterSortBy>
  sortByCorrectCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctCount', Sort.desc);
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterSortBy>
  sortByEndedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endedAt', Sort.asc);
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterSortBy>
  sortByEndedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endedAt', Sort.desc);
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterSortBy>
  sortByPackName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packName', Sort.asc);
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterSortBy>
  sortByPackNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packName', Sort.desc);
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterSortBy>
  sortBySessionDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionDay', Sort.asc);
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterSortBy>
  sortBySessionDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionDay', Sort.desc);
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterSortBy>
  sortBySessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.asc);
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterSortBy>
  sortBySessionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.desc);
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterSortBy>
  sortByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.asc);
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterSortBy>
  sortByStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.desc);
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterSortBy>
  sortByTotalStudyTimeMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalStudyTimeMs', Sort.asc);
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterSortBy>
  sortByTotalStudyTimeMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalStudyTimeMs', Sort.desc);
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterSortBy>
  sortByUniqueCardCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uniqueCardCount', Sort.asc);
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterSortBy>
  sortByUniqueCardCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uniqueCardCount', Sort.desc);
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterSortBy>
  sortByWrongCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wrongCount', Sort.asc);
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterSortBy>
  sortByWrongCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wrongCount', Sort.desc);
    });
  }
}

extension StudySessionHistoryQuerySortThenBy
    on QueryBuilder<StudySessionHistory, StudySessionHistory, QSortThenBy> {
  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterSortBy>
  thenByAnswerCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'answerCount', Sort.asc);
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterSortBy>
  thenByAnswerCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'answerCount', Sort.desc);
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterSortBy>
  thenByAverageAnswerTimeMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'averageAnswerTimeMs', Sort.asc);
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterSortBy>
  thenByAverageAnswerTimeMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'averageAnswerTimeMs', Sort.desc);
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterSortBy>
  thenByCorrectCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctCount', Sort.asc);
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterSortBy>
  thenByCorrectCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctCount', Sort.desc);
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterSortBy>
  thenByEndedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endedAt', Sort.asc);
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterSortBy>
  thenByEndedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endedAt', Sort.desc);
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterSortBy>
  thenByPackName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packName', Sort.asc);
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterSortBy>
  thenByPackNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packName', Sort.desc);
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterSortBy>
  thenBySessionDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionDay', Sort.asc);
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterSortBy>
  thenBySessionDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionDay', Sort.desc);
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterSortBy>
  thenBySessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.asc);
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterSortBy>
  thenBySessionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.desc);
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterSortBy>
  thenByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.asc);
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterSortBy>
  thenByStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.desc);
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterSortBy>
  thenByTotalStudyTimeMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalStudyTimeMs', Sort.asc);
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterSortBy>
  thenByTotalStudyTimeMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalStudyTimeMs', Sort.desc);
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterSortBy>
  thenByUniqueCardCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uniqueCardCount', Sort.asc);
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterSortBy>
  thenByUniqueCardCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uniqueCardCount', Sort.desc);
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterSortBy>
  thenByWrongCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wrongCount', Sort.asc);
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QAfterSortBy>
  thenByWrongCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wrongCount', Sort.desc);
    });
  }
}

extension StudySessionHistoryQueryWhereDistinct
    on QueryBuilder<StudySessionHistory, StudySessionHistory, QDistinct> {
  QueryBuilder<StudySessionHistory, StudySessionHistory, QDistinct>
  distinctByAnswerCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'answerCount');
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QDistinct>
  distinctByAverageAnswerTimeMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'averageAnswerTimeMs');
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QDistinct>
  distinctByCorrectCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'correctCount');
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QDistinct>
  distinctByEndedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endedAt');
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QDistinct>
  distinctByPackName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'packName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QDistinct>
  distinctBySessionDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sessionDay');
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QDistinct>
  distinctBySessionId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sessionId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QDistinct>
  distinctByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startedAt');
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QDistinct>
  distinctByTotalStudyTimeMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalStudyTimeMs');
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QDistinct>
  distinctByUniqueCardCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uniqueCardCount');
    });
  }

  QueryBuilder<StudySessionHistory, StudySessionHistory, QDistinct>
  distinctByWrongCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'wrongCount');
    });
  }
}

extension StudySessionHistoryQueryProperty
    on QueryBuilder<StudySessionHistory, StudySessionHistory, QQueryProperty> {
  QueryBuilder<StudySessionHistory, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<StudySessionHistory, int, QQueryOperations>
  answerCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'answerCount');
    });
  }

  QueryBuilder<StudySessionHistory, int, QQueryOperations>
  averageAnswerTimeMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'averageAnswerTimeMs');
    });
  }

  QueryBuilder<StudySessionHistory, int, QQueryOperations>
  correctCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'correctCount');
    });
  }

  QueryBuilder<StudySessionHistory, DateTime, QQueryOperations>
  endedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endedAt');
    });
  }

  QueryBuilder<StudySessionHistory, String, QQueryOperations>
  packNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'packName');
    });
  }

  QueryBuilder<StudySessionHistory, DateTime, QQueryOperations>
  sessionDayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sessionDay');
    });
  }

  QueryBuilder<StudySessionHistory, String, QQueryOperations>
  sessionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sessionId');
    });
  }

  QueryBuilder<StudySessionHistory, DateTime, QQueryOperations>
  startedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startedAt');
    });
  }

  QueryBuilder<StudySessionHistory, int, QQueryOperations>
  totalStudyTimeMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalStudyTimeMs');
    });
  }

  QueryBuilder<StudySessionHistory, int, QQueryOperations>
  uniqueCardCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uniqueCardCount');
    });
  }

  QueryBuilder<StudySessionHistory, int, QQueryOperations>
  wrongCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'wrongCount');
    });
  }
}
