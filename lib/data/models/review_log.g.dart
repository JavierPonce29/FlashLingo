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
    r'cardType': PropertySchema(
      id: 1,
      name: r'cardType',
      type: IsarType.string,
    ),
    r'daysLate': PropertySchema(
      id: 2,
      name: r'daysLate',
      type: IsarType.long,
    ),
    r'flashcardId': PropertySchema(
      id: 3,
      name: r'flashcardId',
      type: IsarType.long,
    ),
    r'isCorrect': PropertySchema(
      id: 4,
      name: r'isCorrect',
      type: IsarType.bool,
    ),
    r'newNextReview': PropertySchema(
      id: 5,
      name: r'newNextReview',
      type: IsarType.dateTime,
    ),
    r'newState': PropertySchema(
      id: 6,
      name: r'newState',
      type: IsarType.string,
    ),
    r'packName': PropertySchema(
      id: 7,
      name: r'packName',
      type: IsarType.string,
    ),
    r'previousNextReview': PropertySchema(
      id: 8,
      name: r'previousNextReview',
      type: IsarType.dateTime,
    ),
    r'previousState': PropertySchema(
      id: 9,
      name: r'previousState',
      type: IsarType.string,
    ),
    r'rating': PropertySchema(
      id: 10,
      name: r'rating',
      type: IsarType.long,
    ),
    r'scheduledDays': PropertySchema(
      id: 11,
      name: r'scheduledDays',
      type: IsarType.long,
    ),
    r'sessionId': PropertySchema(
      id: 12,
      name: r'sessionId',
      type: IsarType.string,
    ),
    r'studyDay': PropertySchema(
      id: 13,
      name: r'studyDay',
      type: IsarType.dateTime,
    ),
    r'studyDurationMs': PropertySchema(
      id: 14,
      name: r'studyDurationMs',
      type: IsarType.long,
    ),
    r'timestamp': PropertySchema(
      id: 15,
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
    ),
    r'flashcardId': IndexSchema(
      id: -8337910829515384627,
      name: r'flashcardId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'flashcardId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'sessionId': IndexSchema(
      id: 6949518585047923839,
      name: r'sessionId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'sessionId',
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
  bytesCount += 3 + object.cardType.length * 3;
  bytesCount += 3 + object.newState.length * 3;
  bytesCount += 3 + object.packName.length * 3;
  bytesCount += 3 + object.previousState.length * 3;
  bytesCount += 3 + object.sessionId.length * 3;
  return bytesCount;
}

void _reviewLogSerialize(
  ReviewLog object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.cardOriginalId);
  writer.writeString(offsets[1], object.cardType);
  writer.writeLong(offsets[2], object.daysLate);
  writer.writeLong(offsets[3], object.flashcardId);
  writer.writeBool(offsets[4], object.isCorrect);
  writer.writeDateTime(offsets[5], object.newNextReview);
  writer.writeString(offsets[6], object.newState);
  writer.writeString(offsets[7], object.packName);
  writer.writeDateTime(offsets[8], object.previousNextReview);
  writer.writeString(offsets[9], object.previousState);
  writer.writeLong(offsets[10], object.rating);
  writer.writeLong(offsets[11], object.scheduledDays);
  writer.writeString(offsets[12], object.sessionId);
  writer.writeDateTime(offsets[13], object.studyDay);
  writer.writeLong(offsets[14], object.studyDurationMs);
  writer.writeDateTime(offsets[15], object.timestamp);
}

ReviewLog _reviewLogDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ReviewLog();
  object.cardOriginalId = reader.readString(offsets[0]);
  object.cardType = reader.readString(offsets[1]);
  object.daysLate = reader.readLong(offsets[2]);
  object.flashcardId = reader.readLong(offsets[3]);
  object.id = id;
  object.isCorrect = reader.readBool(offsets[4]);
  object.newNextReview = reader.readDateTime(offsets[5]);
  object.newState = reader.readString(offsets[6]);
  object.packName = reader.readString(offsets[7]);
  object.previousNextReview = reader.readDateTime(offsets[8]);
  object.previousState = reader.readString(offsets[9]);
  object.rating = reader.readLong(offsets[10]);
  object.scheduledDays = reader.readLong(offsets[11]);
  object.sessionId = reader.readString(offsets[12]);
  object.studyDay = reader.readDateTime(offsets[13]);
  object.studyDurationMs = reader.readLong(offsets[14]);
  object.timestamp = reader.readDateTime(offsets[15]);
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
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readDateTime(offset)) as P;
    case 14:
      return (reader.readLong(offset)) as P;
    case 15:
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

  QueryBuilder<ReviewLog, ReviewLog, QAfterWhere> anyStudyDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'studyDay'),
      );
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterWhere> anyFlashcardId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'flashcardId'),
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

  QueryBuilder<ReviewLog, ReviewLog, QAfterWhereClause> studyDayEqualTo(
      DateTime studyDay) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'studyDay',
        value: [studyDay],
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterWhereClause> studyDayNotEqualTo(
      DateTime studyDay) {
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

  QueryBuilder<ReviewLog, ReviewLog, QAfterWhereClause> studyDayGreaterThan(
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

  QueryBuilder<ReviewLog, ReviewLog, QAfterWhereClause> studyDayLessThan(
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

  QueryBuilder<ReviewLog, ReviewLog, QAfterWhereClause> studyDayBetween(
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

  QueryBuilder<ReviewLog, ReviewLog, QAfterWhereClause> flashcardIdEqualTo(
      int flashcardId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'flashcardId',
        value: [flashcardId],
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterWhereClause> flashcardIdNotEqualTo(
      int flashcardId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'flashcardId',
              lower: [],
              upper: [flashcardId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'flashcardId',
              lower: [flashcardId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'flashcardId',
              lower: [flashcardId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'flashcardId',
              lower: [],
              upper: [flashcardId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterWhereClause> flashcardIdGreaterThan(
    int flashcardId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'flashcardId',
        lower: [flashcardId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterWhereClause> flashcardIdLessThan(
    int flashcardId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'flashcardId',
        lower: [],
        upper: [flashcardId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterWhereClause> flashcardIdBetween(
    int lowerFlashcardId,
    int upperFlashcardId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'flashcardId',
        lower: [lowerFlashcardId],
        includeLower: includeLower,
        upper: [upperFlashcardId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterWhereClause> sessionIdEqualTo(
      String sessionId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sessionId',
        value: [sessionId],
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterWhereClause> sessionIdNotEqualTo(
      String sessionId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionId',
              lower: [],
              upper: [sessionId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionId',
              lower: [sessionId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionId',
              lower: [sessionId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionId',
              lower: [],
              upper: [sessionId],
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

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> cardTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cardType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> cardTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cardType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> cardTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cardType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> cardTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cardType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> cardTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'cardType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> cardTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'cardType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> cardTypeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cardType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> cardTypeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cardType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> cardTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cardType',
        value: '',
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition>
      cardTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cardType',
        value: '',
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> daysLateEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'daysLate',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> daysLateGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'daysLate',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> daysLateLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'daysLate',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> daysLateBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'daysLate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> flashcardIdEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'flashcardId',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition>
      flashcardIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'flashcardId',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> flashcardIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'flashcardId',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> flashcardIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'flashcardId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
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

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> isCorrectEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isCorrect',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition>
      newNextReviewEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'newNextReview',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition>
      newNextReviewGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'newNextReview',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition>
      newNextReviewLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'newNextReview',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition>
      newNextReviewBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'newNextReview',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> newStateEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'newState',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> newStateGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'newState',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> newStateLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'newState',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> newStateBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'newState',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> newStateStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'newState',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> newStateEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'newState',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> newStateContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'newState',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> newStateMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'newState',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> newStateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'newState',
        value: '',
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition>
      newStateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'newState',
        value: '',
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

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition>
      previousNextReviewEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'previousNextReview',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition>
      previousNextReviewGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'previousNextReview',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition>
      previousNextReviewLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'previousNextReview',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition>
      previousNextReviewBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'previousNextReview',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition>
      previousStateEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'previousState',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition>
      previousStateGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'previousState',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition>
      previousStateLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'previousState',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition>
      previousStateBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'previousState',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition>
      previousStateStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'previousState',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition>
      previousStateEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'previousState',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition>
      previousStateContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'previousState',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition>
      previousStateMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'previousState',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition>
      previousStateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'previousState',
        value: '',
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition>
      previousStateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'previousState',
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

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> sessionIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition>
      sessionIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> sessionIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> sessionIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sessionId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> sessionIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> sessionIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> sessionIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> sessionIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sessionId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> sessionIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sessionId',
        value: '',
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition>
      sessionIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sessionId',
        value: '',
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> studyDayEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'studyDay',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> studyDayGreaterThan(
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

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> studyDayLessThan(
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

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition> studyDayBetween(
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

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition>
      studyDurationMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'studyDurationMs',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition>
      studyDurationMsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'studyDurationMs',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition>
      studyDurationMsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'studyDurationMs',
        value: value,
      ));
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterFilterCondition>
      studyDurationMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'studyDurationMs',
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

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> sortByCardType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardType', Sort.asc);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> sortByCardTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardType', Sort.desc);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> sortByDaysLate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'daysLate', Sort.asc);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> sortByDaysLateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'daysLate', Sort.desc);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> sortByFlashcardId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'flashcardId', Sort.asc);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> sortByFlashcardIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'flashcardId', Sort.desc);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> sortByIsCorrect() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCorrect', Sort.asc);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> sortByIsCorrectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCorrect', Sort.desc);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> sortByNewNextReview() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newNextReview', Sort.asc);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> sortByNewNextReviewDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newNextReview', Sort.desc);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> sortByNewState() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newState', Sort.asc);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> sortByNewStateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newState', Sort.desc);
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

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> sortByPreviousNextReview() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousNextReview', Sort.asc);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy>
      sortByPreviousNextReviewDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousNextReview', Sort.desc);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> sortByPreviousState() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousState', Sort.asc);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> sortByPreviousStateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousState', Sort.desc);
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

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> sortBySessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.asc);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> sortBySessionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.desc);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> sortByStudyDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studyDay', Sort.asc);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> sortByStudyDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studyDay', Sort.desc);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> sortByStudyDurationMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studyDurationMs', Sort.asc);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> sortByStudyDurationMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studyDurationMs', Sort.desc);
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

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> thenByCardType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardType', Sort.asc);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> thenByCardTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardType', Sort.desc);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> thenByDaysLate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'daysLate', Sort.asc);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> thenByDaysLateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'daysLate', Sort.desc);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> thenByFlashcardId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'flashcardId', Sort.asc);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> thenByFlashcardIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'flashcardId', Sort.desc);
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

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> thenByIsCorrect() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCorrect', Sort.asc);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> thenByIsCorrectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCorrect', Sort.desc);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> thenByNewNextReview() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newNextReview', Sort.asc);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> thenByNewNextReviewDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newNextReview', Sort.desc);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> thenByNewState() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newState', Sort.asc);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> thenByNewStateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newState', Sort.desc);
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

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> thenByPreviousNextReview() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousNextReview', Sort.asc);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy>
      thenByPreviousNextReviewDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousNextReview', Sort.desc);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> thenByPreviousState() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousState', Sort.asc);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> thenByPreviousStateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousState', Sort.desc);
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

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> thenBySessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.asc);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> thenBySessionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.desc);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> thenByStudyDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studyDay', Sort.asc);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> thenByStudyDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studyDay', Sort.desc);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> thenByStudyDurationMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studyDurationMs', Sort.asc);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QAfterSortBy> thenByStudyDurationMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studyDurationMs', Sort.desc);
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

  QueryBuilder<ReviewLog, ReviewLog, QDistinct> distinctByCardType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cardType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QDistinct> distinctByDaysLate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'daysLate');
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QDistinct> distinctByFlashcardId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'flashcardId');
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QDistinct> distinctByIsCorrect() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isCorrect');
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QDistinct> distinctByNewNextReview() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'newNextReview');
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QDistinct> distinctByNewState(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'newState', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QDistinct> distinctByPackName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'packName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QDistinct> distinctByPreviousNextReview() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'previousNextReview');
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QDistinct> distinctByPreviousState(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'previousState',
          caseSensitive: caseSensitive);
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

  QueryBuilder<ReviewLog, ReviewLog, QDistinct> distinctBySessionId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sessionId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QDistinct> distinctByStudyDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'studyDay');
    });
  }

  QueryBuilder<ReviewLog, ReviewLog, QDistinct> distinctByStudyDurationMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'studyDurationMs');
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

  QueryBuilder<ReviewLog, String, QQueryOperations> cardTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cardType');
    });
  }

  QueryBuilder<ReviewLog, int, QQueryOperations> daysLateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'daysLate');
    });
  }

  QueryBuilder<ReviewLog, int, QQueryOperations> flashcardIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'flashcardId');
    });
  }

  QueryBuilder<ReviewLog, bool, QQueryOperations> isCorrectProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isCorrect');
    });
  }

  QueryBuilder<ReviewLog, DateTime, QQueryOperations> newNextReviewProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'newNextReview');
    });
  }

  QueryBuilder<ReviewLog, String, QQueryOperations> newStateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'newState');
    });
  }

  QueryBuilder<ReviewLog, String, QQueryOperations> packNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'packName');
    });
  }

  QueryBuilder<ReviewLog, DateTime, QQueryOperations>
      previousNextReviewProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'previousNextReview');
    });
  }

  QueryBuilder<ReviewLog, String, QQueryOperations> previousStateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'previousState');
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

  QueryBuilder<ReviewLog, String, QQueryOperations> sessionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sessionId');
    });
  }

  QueryBuilder<ReviewLog, DateTime, QQueryOperations> studyDayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'studyDay');
    });
  }

  QueryBuilder<ReviewLog, int, QQueryOperations> studyDurationMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'studyDurationMs');
    });
  }

  QueryBuilder<ReviewLog, DateTime, QQueryOperations> timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }
}
