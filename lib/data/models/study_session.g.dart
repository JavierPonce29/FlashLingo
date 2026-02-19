// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_session.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetStudySessionCollection on Isar {
  IsarCollection<StudySession> get studySessions => this.collection();
}

const StudySessionSchema = CollectionSchema(
  name: r'StudySession',
  id: 5950026954574551040,
  properties: {
    r'currentIndex': PropertySchema(
      id: 0,
      name: r'currentIndex',
      type: IsarType.long,
    ),
    r'lastUpdated': PropertySchema(
      id: 1,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    ),
    r'packName': PropertySchema(
      id: 2,
      name: r'packName',
      type: IsarType.string,
    ),
    r'queueCardIds': PropertySchema(
      id: 3,
      name: r'queueCardIds',
      type: IsarType.longList,
    ),
    r'sessionDay': PropertySchema(
      id: 4,
      name: r'sessionDay',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _studySessionEstimateSize,
  serialize: _studySessionSerialize,
  deserialize: _studySessionDeserialize,
  deserializeProp: _studySessionDeserializeProp,
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
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _studySessionGetId,
  getLinks: _studySessionGetLinks,
  attach: _studySessionAttach,
  version: '3.1.0+1',
);

int _studySessionEstimateSize(
  StudySession object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.packName.length * 3;
  bytesCount += 3 + object.queueCardIds.length * 8;
  return bytesCount;
}

void _studySessionSerialize(
  StudySession object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.currentIndex);
  writer.writeDateTime(offsets[1], object.lastUpdated);
  writer.writeString(offsets[2], object.packName);
  writer.writeLongList(offsets[3], object.queueCardIds);
  writer.writeDateTime(offsets[4], object.sessionDay);
}

StudySession _studySessionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = StudySession();
  object.currentIndex = reader.readLong(offsets[0]);
  object.id = id;
  object.lastUpdated = reader.readDateTime(offsets[1]);
  object.packName = reader.readString(offsets[2]);
  object.queueCardIds = reader.readLongList(offsets[3]) ?? [];
  object.sessionDay = reader.readDateTime(offsets[4]);
  return object;
}

P _studySessionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readLongList(offset) ?? []) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _studySessionGetId(StudySession object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _studySessionGetLinks(StudySession object) {
  return [];
}

void _studySessionAttach(
    IsarCollection<dynamic> col, Id id, StudySession object) {
  object.id = id;
}

extension StudySessionByIndex on IsarCollection<StudySession> {
  Future<StudySession?> getByPackName(String packName) {
    return getByIndex(r'packName', [packName]);
  }

  StudySession? getByPackNameSync(String packName) {
    return getByIndexSync(r'packName', [packName]);
  }

  Future<bool> deleteByPackName(String packName) {
    return deleteByIndex(r'packName', [packName]);
  }

  bool deleteByPackNameSync(String packName) {
    return deleteByIndexSync(r'packName', [packName]);
  }

  Future<List<StudySession?>> getAllByPackName(List<String> packNameValues) {
    final values = packNameValues.map((e) => [e]).toList();
    return getAllByIndex(r'packName', values);
  }

  List<StudySession?> getAllByPackNameSync(List<String> packNameValues) {
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

  Future<Id> putByPackName(StudySession object) {
    return putByIndex(r'packName', object);
  }

  Id putByPackNameSync(StudySession object, {bool saveLinks = true}) {
    return putByIndexSync(r'packName', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByPackName(List<StudySession> objects) {
    return putAllByIndex(r'packName', objects);
  }

  List<Id> putAllByPackNameSync(List<StudySession> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'packName', objects, saveLinks: saveLinks);
  }
}

extension StudySessionQueryWhereSort
    on QueryBuilder<StudySession, StudySession, QWhere> {
  QueryBuilder<StudySession, StudySession, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterWhere> anySessionDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'sessionDay'),
      );
    });
  }
}

extension StudySessionQueryWhere
    on QueryBuilder<StudySession, StudySession, QWhereClause> {
  QueryBuilder<StudySession, StudySession, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<StudySession, StudySession, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterWhereClause> idBetween(
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

  QueryBuilder<StudySession, StudySession, QAfterWhereClause> packNameEqualTo(
      String packName) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'packName',
        value: [packName],
      ));
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterWhereClause>
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

  QueryBuilder<StudySession, StudySession, QAfterWhereClause> sessionDayEqualTo(
      DateTime sessionDay) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sessionDay',
        value: [sessionDay],
      ));
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterWhereClause>
      sessionDayNotEqualTo(DateTime sessionDay) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionDay',
              lower: [],
              upper: [sessionDay],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionDay',
              lower: [sessionDay],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionDay',
              lower: [sessionDay],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionDay',
              lower: [],
              upper: [sessionDay],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterWhereClause>
      sessionDayGreaterThan(
    DateTime sessionDay, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sessionDay',
        lower: [sessionDay],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterWhereClause>
      sessionDayLessThan(
    DateTime sessionDay, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sessionDay',
        lower: [],
        upper: [sessionDay],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterWhereClause> sessionDayBetween(
    DateTime lowerSessionDay,
    DateTime upperSessionDay, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sessionDay',
        lower: [lowerSessionDay],
        includeLower: includeLower,
        upper: [upperSessionDay],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension StudySessionQueryFilter
    on QueryBuilder<StudySession, StudySession, QFilterCondition> {
  QueryBuilder<StudySession, StudySession, QAfterFilterCondition>
      currentIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition>
      currentIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition>
      currentIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition>
      currentIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition> idBetween(
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

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition>
      lastUpdatedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition>
      lastUpdatedGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition>
      lastUpdatedLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition>
      lastUpdatedBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastUpdated',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition>
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

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition>
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

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition>
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

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition>
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

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition>
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

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition>
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

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition>
      packNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'packName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition>
      packNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'packName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition>
      packNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'packName',
        value: '',
      ));
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition>
      packNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'packName',
        value: '',
      ));
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition>
      queueCardIdsElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'queueCardIds',
        value: value,
      ));
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition>
      queueCardIdsElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'queueCardIds',
        value: value,
      ));
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition>
      queueCardIdsElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'queueCardIds',
        value: value,
      ));
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition>
      queueCardIdsElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'queueCardIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition>
      queueCardIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'queueCardIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition>
      queueCardIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'queueCardIds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition>
      queueCardIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'queueCardIds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition>
      queueCardIdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'queueCardIds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition>
      queueCardIdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'queueCardIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition>
      queueCardIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'queueCardIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition>
      sessionDayEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sessionDay',
        value: value,
      ));
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition>
      sessionDayGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sessionDay',
        value: value,
      ));
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition>
      sessionDayLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sessionDay',
        value: value,
      ));
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterFilterCondition>
      sessionDayBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sessionDay',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension StudySessionQueryObject
    on QueryBuilder<StudySession, StudySession, QFilterCondition> {}

extension StudySessionQueryLinks
    on QueryBuilder<StudySession, StudySession, QFilterCondition> {}

extension StudySessionQuerySortBy
    on QueryBuilder<StudySession, StudySession, QSortBy> {
  QueryBuilder<StudySession, StudySession, QAfterSortBy> sortByCurrentIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentIndex', Sort.asc);
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterSortBy>
      sortByCurrentIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentIndex', Sort.desc);
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterSortBy> sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterSortBy>
      sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterSortBy> sortByPackName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packName', Sort.asc);
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterSortBy> sortByPackNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packName', Sort.desc);
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterSortBy> sortBySessionDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionDay', Sort.asc);
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterSortBy>
      sortBySessionDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionDay', Sort.desc);
    });
  }
}

extension StudySessionQuerySortThenBy
    on QueryBuilder<StudySession, StudySession, QSortThenBy> {
  QueryBuilder<StudySession, StudySession, QAfterSortBy> thenByCurrentIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentIndex', Sort.asc);
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterSortBy>
      thenByCurrentIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentIndex', Sort.desc);
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterSortBy> thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterSortBy>
      thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterSortBy> thenByPackName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packName', Sort.asc);
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterSortBy> thenByPackNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packName', Sort.desc);
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterSortBy> thenBySessionDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionDay', Sort.asc);
    });
  }

  QueryBuilder<StudySession, StudySession, QAfterSortBy>
      thenBySessionDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionDay', Sort.desc);
    });
  }
}

extension StudySessionQueryWhereDistinct
    on QueryBuilder<StudySession, StudySession, QDistinct> {
  QueryBuilder<StudySession, StudySession, QDistinct> distinctByCurrentIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentIndex');
    });
  }

  QueryBuilder<StudySession, StudySession, QDistinct> distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<StudySession, StudySession, QDistinct> distinctByPackName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'packName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudySession, StudySession, QDistinct> distinctByQueueCardIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'queueCardIds');
    });
  }

  QueryBuilder<StudySession, StudySession, QDistinct> distinctBySessionDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sessionDay');
    });
  }
}

extension StudySessionQueryProperty
    on QueryBuilder<StudySession, StudySession, QQueryProperty> {
  QueryBuilder<StudySession, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<StudySession, int, QQueryOperations> currentIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentIndex');
    });
  }

  QueryBuilder<StudySession, DateTime, QQueryOperations> lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<StudySession, String, QQueryOperations> packNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'packName');
    });
  }

  QueryBuilder<StudySession, List<int>, QQueryOperations>
      queueCardIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'queueCardIds');
    });
  }

  QueryBuilder<StudySession, DateTime, QQueryOperations> sessionDayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sessionDay');
    });
  }
}
