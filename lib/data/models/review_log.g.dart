// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_log.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetReviewLogCollection on Isar {
  IsarCollection<ReviewLog> get reviewLogs => this.collection();
}

const ReviewLogSchema = CollectionSchema(
  name: r'ReviewLog',
  id: 8076174363960605985,
  properties: {
    r'cardOriginalId': PropertySchema(
      id: 0,
      name: r'cardOriginalId',
      type: IsarType.string,
    ),
    r'packName': PropertySchema(
      id: 1,
      name: r'packName',
      type: IsarType.string,
    ),
    r'rating': PropertySchema(
      id: 2,
      name: r'rating',
      type: IsarType.long,
    ),
    r'scheduledDays': PropertySchema(
      id: 3,
      name: r'scheduledDays',
      type: IsarType.long,
    ),
    r'timestamp': PropertySchema(
      id: 4,
      name: r'timestamp',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _reviewLogEstimateSize,
  serialize: _reviewLogSerialize,
  deserialize: _reviewLogDeserialize,
  deserializeProp: _reviewLogDeserializeProp,
  idName: r'id',
  indexes: {
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
    r'timestamp': IndexSchema(
      id: 1852253767416892198,
      name: r'timestamp',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'timestamp',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'cardOriginalId': IndexSchema(
      id: 2387257986594315454,
      name: r'cardOriginalId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'cardOriginalId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _reviewLogGetId,
  getLinks: _reviewLogGetLinks,
  attach: _reviewLogAttach,
  version: '3.1.0+1',
);

int _reviewLogEstimateSize(
  ReviewLog object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.cardOriginalId.length * 3;
  bytesCount += 3 + object.packName.length * 3;
  return bytesCount;
}

void _reviewLogSerialize(
  ReviewLog object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.cardOriginalId);
  writer.writeString(offsets[1], object.packName);
  writer.writeLong(offsets[2], object.rating);
  writer.writeLong(offsets[3], object.scheduledDays);
  writer.writeDateTime(offsets[4], object.timestamp);
}

ReviewLog _reviewLogDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ReviewLog();
  object.cardOriginalId = reader.readString(offsets[0]);
  object.id = id;
  object.packName = reader.readString(offsets[1]);
  object.rating = reader.readLong(offsets[2]);
  object.scheduledDays = reader.readLong(offsets[3]);
  object.timestamp = reader.readDateTime(offsets[4]);
  return object;
}

P _reviewLogDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _reviewLogGetId(ReviewLog object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _reviewLogGetLinks(ReviewLog object) {
  return [];
}

void _reviewLogAttach(IsarCollection<dynamic> col, Id id, ReviewLog object) {
  object.id = id;
}

extension ReviewLogQueryWhereSort
    on QueryBuilder<ReviewLog, ReviewLog, QWhere> {
  QueryBuilder<ReviewLog, ReviewLog, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterWhere> anyTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'timestamp'),
      );
    });
  }
}

extension ReviewLogQueryWhere
    on QueryBuilder<ReviewLog, ReviewLog, QWhereClause> {
  QueryBuilder<ReviewLog, ReviewLog, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<ReviewLog, ReviewLog, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterWhereClause> idBetween(
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

  QueryBuilder<ReviewLog, ReviewLog, QAfterWhereClause> packNameEqualTo(
      String packName) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'packName',
        value: [packName],
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterWhereClause> packNameNotEqualTo(
      String packName) {
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

  QueryBuilder<ReviewLog, ReviewLog, QAfterWhereClause> timestampEqualTo(
      DateTime timestamp) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'timestamp',
        value: [timestamp],
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterWhereClause> timestampNotEqualTo(
      DateTime timestamp) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [],
              upper: [timestamp],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [timestamp],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [timestamp],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [],
              upper: [timestamp],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterWhereClause> timestampGreaterThan(
    DateTime timestamp, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'timestamp',
        lower: [timestamp],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterWhereClause> timestampLessThan(
    DateTime timestamp, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'timestamp',
        lower: [],
        upper: [timestamp],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterWhereClause> timestampBetween(
    DateTime lowerTimestamp,
    DateTime upperTimestamp, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'timestamp',
        lower: [lowerTimestamp],
        includeLower: includeLower,
        upper: [upperTimestamp],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterWhereClause> cardOriginalIdEqualTo(
      String cardOriginalId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'cardOriginalId',
        value: [cardOriginalId],
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterWhereClause>
      cardOriginalIdNotEqualTo(String cardOriginalId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cardOriginalId',
              lower: [],
              upper: [cardOriginalId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cardOriginalId',
              lower: [cardOriginalId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cardOriginalId',
              lower: [cardOriginalId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cardOriginalId',
              lower: [],
              upper: [cardOriginalId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ReviewLogQueryFilter
    on QueryBuilder<ReviewLog, ReviewLog, QFilterCondition> {
  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition>
      cardOriginalIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cardOriginalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition>
      cardOriginalIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cardOriginalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition>
      cardOriginalIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cardOriginalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition>
      cardOriginalIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cardOriginalId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition>
      cardOriginalIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'cardOriginalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition>
      cardOriginalIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'cardOriginalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition>
      cardOriginalIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cardOriginalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition>
      cardOriginalIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cardOriginalId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition>
      cardOriginalIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cardOriginalId',
        value: '',
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition>
      cardOriginalIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cardOriginalId',
        value: '',
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> idBetween(
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

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> packNameEqualTo(
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

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> packNameGreaterThan(
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

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> packNameLessThan(
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

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> packNameBetween(
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

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> packNameStartsWith(
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

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> packNameEndsWith(
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

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> packNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'packName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> packNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'packName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> packNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'packName',
        value: '',
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition>
      packNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'packName',
        value: '',
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> ratingEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rating',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> ratingGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rating',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> ratingLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rating',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> ratingBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rating',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition>
      scheduledDaysEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scheduledDays',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition>
      scheduledDaysGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'scheduledDays',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition>
      scheduledDaysLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'scheduledDays',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition>
      scheduledDaysBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'scheduledDays',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> timestampEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition>
      timestampGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> timestampLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> timestampBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timestamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ReviewLogQueryObject
    on QueryBuilder<ReviewLog, ReviewLog, QFilterCondition> {}

extension ReviewLogQueryLinks
    on QueryBuilder<ReviewLog, ReviewLog, QFilterCondition> {}

extension ReviewLogQuerySortBy on QueryBuilder<ReviewLog, ReviewLog, QSortBy> {
  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> sortByCardOriginalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardOriginalId', Sort.asc);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> sortByCardOriginalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardOriginalId', Sort.desc);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> sortByPackName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packName', Sort.asc);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> sortByPackNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packName', Sort.desc);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> sortByRating() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rating', Sort.asc);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> sortByRatingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rating', Sort.desc);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> sortByScheduledDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledDays', Sort.asc);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> sortByScheduledDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledDays', Sort.desc);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension ReviewLogQuerySortThenBy
    on QueryBuilder<ReviewLog, ReviewLog, QSortThenBy> {
  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> thenByCardOriginalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardOriginalId', Sort.asc);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> thenByCardOriginalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardOriginalId', Sort.desc);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> thenByPackName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packName', Sort.asc);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> thenByPackNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packName', Sort.desc);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> thenByRating() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rating', Sort.asc);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> thenByRatingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rating', Sort.desc);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> thenByScheduledDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledDays', Sort.asc);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> thenByScheduledDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledDays', Sort.desc);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension ReviewLogQueryWhereDistinct
    on QueryBuilder<ReviewLog, ReviewLog, QDistinct> {
  QueryBuilder<ReviewLog, ReviewLog, QDistinct> distinctByCardOriginalId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cardOriginalId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QDistinct> distinctByPackName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'packName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QDistinct> distinctByRating() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rating');
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QDistinct> distinctByScheduledDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scheduledDays');
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QDistinct> distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }
}

extension ReviewLogQueryProperty
    on QueryBuilder<ReviewLog, ReviewLog, QQueryProperty> {
  QueryBuilder<ReviewLog, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ReviewLog, String, QQueryOperations> cardOriginalIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cardOriginalId');
    });
  }

  QueryBuilder<ReviewLog, String, QQueryOperations> packNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'packName');
    });
  }

  QueryBuilder<ReviewLog, int, QQueryOperations> ratingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rating');
    });
  }

  QueryBuilder<ReviewLog, int, QQueryOperations> scheduledDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scheduledDays');
    });
  }

  QueryBuilder<ReviewLog, DateTime, QQueryOperations> timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }
}
