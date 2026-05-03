// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flashcard.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetFlashcardCollection on Isar {
  IsarCollection<Flashcard> get flashcards => this.collection();
}

const FlashcardSchema = CollectionSchema(
  name: r'Flashcard',
  id: -5712857134961670327,
  properties: {
    r'answer': PropertySchema(
      id: 0,
      name: r'answer',
      type: IsarType.string,
    ),
    r'audioPath': PropertySchema(
      id: 1,
      name: r'audioPath',
      type: IsarType.string,
    ),
    r'cardType': PropertySchema(
      id: 2,
      name: r'cardType',
      type: IsarType.string,
    ),
    r'consecutiveLapses': PropertySchema(
      id: 3,
      name: r'consecutiveLapses',
      type: IsarType.long,
    ),
    r'decayRate': PropertySchema(
      id: 4,
      name: r'decayRate',
      type: IsarType.double,
    ),
    r'extraDataJson': PropertySchema(
      id: 5,
      name: r'extraDataJson',
      type: IsarType.string,
    ),
    r'fixedPhaseQueue': PropertySchema(
      id: 6,
      name: r'fixedPhaseQueue',
      type: IsarType.doubleList,
    ),
    r'imagePath': PropertySchema(
      id: 7,
      name: r'imagePath',
      type: IsarType.string,
    ),
    r'isoCode': PropertySchema(
      id: 8,
      name: r'isoCode',
      type: IsarType.string,
    ),
    r'lastReview': PropertySchema(
      id: 9,
      name: r'lastReview',
      type: IsarType.dateTime,
    ),
    r'learningStep': PropertySchema(
      id: 10,
      name: r'learningStep',
      type: IsarType.long,
    ),
    r'lifetimeCorrectCount': PropertySchema(
      id: 11,
      name: r'lifetimeCorrectCount',
      type: IsarType.long,
    ),
    r'lifetimeReviewCount': PropertySchema(
      id: 12,
      name: r'lifetimeReviewCount',
      type: IsarType.long,
    ),
    r'lifetimeWrongCount': PropertySchema(
      id: 13,
      name: r'lifetimeWrongCount',
      type: IsarType.long,
    ),
    r'manualReviewOverrideDay': PropertySchema(
      id: 14,
      name: r'manualReviewOverrideDay',
      type: IsarType.dateTime,
    ),
    r'nextReview': PropertySchema(
      id: 15,
      name: r'nextReview',
      type: IsarType.dateTime,
    ),
    r'originalId': PropertySchema(
      id: 16,
      name: r'originalId',
      type: IsarType.string,
    ),
    r'packName': PropertySchema(
      id: 17,
      name: r'packName',
      type: IsarType.string,
    ),
    r'question': PropertySchema(
      id: 18,
      name: r'question',
      type: IsarType.string,
    ),
    r'repetitionCount': PropertySchema(
      id: 19,
      name: r'repetitionCount',
      type: IsarType.long,
    ),
    r'reviewPriorityAnchor': PropertySchema(
      id: 20,
      name: r'reviewPriorityAnchor',
      type: IsarType.dateTime,
    ),
    r'sentence': PropertySchema(
      id: 21,
      name: r'sentence',
      type: IsarType.string,
    ),
    r'sentenceAudioPath': PropertySchema(
      id: 22,
      name: r'sentenceAudioPath',
      type: IsarType.string,
    ),
    r'state': PropertySchema(
      id: 23,
      name: r'state',
      type: IsarType.string,
      enumMap: _FlashcardstateEnumValueMap,
    ),
    r'totalStudyTimeMs': PropertySchema(
      id: 24,
      name: r'totalStudyTimeMs',
      type: IsarType.long,
    ),
    r'translation': PropertySchema(
      id: 25,
      name: r'translation',
      type: IsarType.string,
    )
  },
  estimateSize: _flashcardEstimateSize,
  serialize: _flashcardSerialize,
  deserialize: _flashcardDeserialize,
  deserializeProp: _flashcardDeserializeProp,
  idName: r'id',
  indexes: {
    r'originalId': IndexSchema(
      id: -8365773424467627071,
      name: r'originalId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'originalId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'isoCode': IndexSchema(
      id: 893107209402907405,
      name: r'isoCode',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isoCode',
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
    r'cardType': IndexSchema(
      id: 6535750989912943294,
      name: r'cardType',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'cardType',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'nextReview': IndexSchema(
      id: 316564737852968787,
      name: r'nextReview',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'nextReview',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _flashcardGetId,
  getLinks: _flashcardGetLinks,
  attach: _flashcardAttach,
  version: '3.1.0+1',
);

int _flashcardEstimateSize(
  Flashcard object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.answer.length * 3;
  {
    final value = object.audioPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.cardType.length * 3;
  {
    final value = object.extraDataJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.fixedPhaseQueue.length * 8;
  {
    final value = object.imagePath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.isoCode.length * 3;
  bytesCount += 3 + object.originalId.length * 3;
  bytesCount += 3 + object.packName.length * 3;
  bytesCount += 3 + object.question.length * 3;
  {
    final value = object.sentence;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.sentenceAudioPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.state.name.length * 3;
  {
    final value = object.translation;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _flashcardSerialize(
  Flashcard object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.answer);
  writer.writeString(offsets[1], object.audioPath);
  writer.writeString(offsets[2], object.cardType);
  writer.writeLong(offsets[3], object.consecutiveLapses);
  writer.writeDouble(offsets[4], object.decayRate);
  writer.writeString(offsets[5], object.extraDataJson);
  writer.writeDoubleList(offsets[6], object.fixedPhaseQueue);
  writer.writeString(offsets[7], object.imagePath);
  writer.writeString(offsets[8], object.isoCode);
  writer.writeDateTime(offsets[9], object.lastReview);
  writer.writeLong(offsets[10], object.learningStep);
  writer.writeLong(offsets[11], object.lifetimeCorrectCount);
  writer.writeLong(offsets[12], object.lifetimeReviewCount);
  writer.writeLong(offsets[13], object.lifetimeWrongCount);
  writer.writeDateTime(offsets[14], object.manualReviewOverrideDay);
  writer.writeDateTime(offsets[15], object.nextReview);
  writer.writeString(offsets[16], object.originalId);
  writer.writeString(offsets[17], object.packName);
  writer.writeString(offsets[18], object.question);
  writer.writeLong(offsets[19], object.repetitionCount);
  writer.writeDateTime(offsets[20], object.reviewPriorityAnchor);
  writer.writeString(offsets[21], object.sentence);
  writer.writeString(offsets[22], object.sentenceAudioPath);
  writer.writeString(offsets[23], object.state.name);
  writer.writeLong(offsets[24], object.totalStudyTimeMs);
  writer.writeString(offsets[25], object.translation);
}

Flashcard _flashcardDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Flashcard();
  object.answer = reader.readString(offsets[0]);
  object.audioPath = reader.readStringOrNull(offsets[1]);
  object.cardType = reader.readString(offsets[2]);
  object.consecutiveLapses = reader.readLong(offsets[3]);
  object.decayRate = reader.readDouble(offsets[4]);
  object.extraDataJson = reader.readStringOrNull(offsets[5]);
  object.fixedPhaseQueue = reader.readDoubleList(offsets[6]) ?? [];
  object.id = id;
  object.imagePath = reader.readStringOrNull(offsets[7]);
  object.isoCode = reader.readString(offsets[8]);
  object.lastReview = reader.readDateTime(offsets[9]);
  object.learningStep = reader.readLong(offsets[10]);
  object.lifetimeCorrectCount = reader.readLong(offsets[11]);
  object.lifetimeReviewCount = reader.readLong(offsets[12]);
  object.lifetimeWrongCount = reader.readLong(offsets[13]);
  object.manualReviewOverrideDay = reader.readDateTime(offsets[14]);
  object.nextReview = reader.readDateTime(offsets[15]);
  object.originalId = reader.readString(offsets[16]);
  object.packName = reader.readString(offsets[17]);
  object.question = reader.readString(offsets[18]);
  object.repetitionCount = reader.readLong(offsets[19]);
  object.reviewPriorityAnchor = reader.readDateTime(offsets[20]);
  object.sentence = reader.readStringOrNull(offsets[21]);
  object.sentenceAudioPath = reader.readStringOrNull(offsets[22]);
  object.state =
      _FlashcardstateValueEnumMap[reader.readStringOrNull(offsets[23])] ??
          CardState.newCard;
  object.totalStudyTimeMs = reader.readLong(offsets[24]);
  object.translation = reader.readStringOrNull(offsets[25]);
  return object;
}

P _flashcardDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readDoubleList(offset) ?? []) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readDateTime(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    case 12:
      return (reader.readLong(offset)) as P;
    case 13:
      return (reader.readLong(offset)) as P;
    case 14:
      return (reader.readDateTime(offset)) as P;
    case 15:
      return (reader.readDateTime(offset)) as P;
    case 16:
      return (reader.readString(offset)) as P;
    case 17:
      return (reader.readString(offset)) as P;
    case 18:
      return (reader.readString(offset)) as P;
    case 19:
      return (reader.readLong(offset)) as P;
    case 20:
      return (reader.readDateTime(offset)) as P;
    case 21:
      return (reader.readStringOrNull(offset)) as P;
    case 22:
      return (reader.readStringOrNull(offset)) as P;
    case 23:
      return (_FlashcardstateValueEnumMap[reader.readStringOrNull(offset)] ??
          CardState.newCard) as P;
    case 24:
      return (reader.readLong(offset)) as P;
    case 25:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _FlashcardstateEnumValueMap = {
  r'newCard': r'newCard',
  r'learning': r'learning',
  r'review': r'review',
  r'relearning': r'relearning',
};
const _FlashcardstateValueEnumMap = {
  r'newCard': CardState.newCard,
  r'learning': CardState.learning,
  r'review': CardState.review,
  r'relearning': CardState.relearning,
};

Id _flashcardGetId(Flashcard object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _flashcardGetLinks(Flashcard object) {
  return [];
}

void _flashcardAttach(IsarCollection<dynamic> col, Id id, Flashcard object) {
  object.id = id;
}

extension FlashcardQueryWhereSort
    on QueryBuilder<Flashcard, Flashcard, QWhere> {
  QueryBuilder<Flashcard, Flashcard, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterWhere> anyNextReview() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'nextReview'),
      );
    });
  }
}

extension FlashcardQueryWhere
    on QueryBuilder<Flashcard, Flashcard, QWhereClause> {
  QueryBuilder<Flashcard, Flashcard, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Flashcard, Flashcard, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterWhereClause> idBetween(
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

  QueryBuilder<Flashcard, Flashcard, QAfterWhereClause> originalIdEqualTo(
      String originalId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'originalId',
        value: [originalId],
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterWhereClause> originalIdNotEqualTo(
      String originalId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'originalId',
              lower: [],
              upper: [originalId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'originalId',
              lower: [originalId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'originalId',
              lower: [originalId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'originalId',
              lower: [],
              upper: [originalId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterWhereClause> isoCodeEqualTo(
      String isoCode) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isoCode',
        value: [isoCode],
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterWhereClause> isoCodeNotEqualTo(
      String isoCode) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isoCode',
              lower: [],
              upper: [isoCode],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isoCode',
              lower: [isoCode],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isoCode',
              lower: [isoCode],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isoCode',
              lower: [],
              upper: [isoCode],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterWhereClause> packNameEqualTo(
      String packName) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'packName',
        value: [packName],
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterWhereClause> packNameNotEqualTo(
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

  QueryBuilder<Flashcard, Flashcard, QAfterWhereClause> cardTypeEqualTo(
      String cardType) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'cardType',
        value: [cardType],
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterWhereClause> cardTypeNotEqualTo(
      String cardType) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cardType',
              lower: [],
              upper: [cardType],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cardType',
              lower: [cardType],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cardType',
              lower: [cardType],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cardType',
              lower: [],
              upper: [cardType],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterWhereClause> nextReviewEqualTo(
      DateTime nextReview) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'nextReview',
        value: [nextReview],
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterWhereClause> nextReviewNotEqualTo(
      DateTime nextReview) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nextReview',
              lower: [],
              upper: [nextReview],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nextReview',
              lower: [nextReview],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nextReview',
              lower: [nextReview],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nextReview',
              lower: [],
              upper: [nextReview],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterWhereClause> nextReviewGreaterThan(
    DateTime nextReview, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'nextReview',
        lower: [nextReview],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterWhereClause> nextReviewLessThan(
    DateTime nextReview, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'nextReview',
        lower: [],
        upper: [nextReview],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterWhereClause> nextReviewBetween(
    DateTime lowerNextReview,
    DateTime upperNextReview, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'nextReview',
        lower: [lowerNextReview],
        includeLower: includeLower,
        upper: [upperNextReview],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension FlashcardQueryFilter
    on QueryBuilder<Flashcard, Flashcard, QFilterCondition> {
  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> answerEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'answer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> answerGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'answer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> answerLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'answer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> answerBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'answer',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> answerStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'answer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> answerEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'answer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> answerContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'answer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> answerMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'answer',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> answerIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'answer',
        value: '',
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> answerIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'answer',
        value: '',
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> audioPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'audioPath',
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      audioPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'audioPath',
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> audioPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'audioPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      audioPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'audioPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> audioPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'audioPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> audioPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'audioPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> audioPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'audioPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> audioPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'audioPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> audioPathContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'audioPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> audioPathMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'audioPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> audioPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'audioPath',
        value: '',
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      audioPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'audioPath',
        value: '',
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> cardTypeEqualTo(
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

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> cardTypeGreaterThan(
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

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> cardTypeLessThan(
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

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> cardTypeBetween(
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

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> cardTypeStartsWith(
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

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> cardTypeEndsWith(
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

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> cardTypeContains(
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

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> cardTypeMatches(
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

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> cardTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cardType',
        value: '',
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      cardTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cardType',
        value: '',
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      consecutiveLapsesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'consecutiveLapses',
        value: value,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      consecutiveLapsesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'consecutiveLapses',
        value: value,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      consecutiveLapsesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'consecutiveLapses',
        value: value,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      consecutiveLapsesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'consecutiveLapses',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> decayRateEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'decayRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      decayRateGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'decayRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> decayRateLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'decayRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> decayRateBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'decayRate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      extraDataJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'extraDataJson',
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      extraDataJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'extraDataJson',
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      extraDataJsonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'extraDataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      extraDataJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'extraDataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      extraDataJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'extraDataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      extraDataJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'extraDataJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      extraDataJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'extraDataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      extraDataJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'extraDataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      extraDataJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'extraDataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      extraDataJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'extraDataJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      extraDataJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'extraDataJson',
        value: '',
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      extraDataJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'extraDataJson',
        value: '',
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      fixedPhaseQueueElementEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fixedPhaseQueue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      fixedPhaseQueueElementGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fixedPhaseQueue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      fixedPhaseQueueElementLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fixedPhaseQueue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      fixedPhaseQueueElementBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fixedPhaseQueue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      fixedPhaseQueueLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'fixedPhaseQueue',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      fixedPhaseQueueIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'fixedPhaseQueue',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      fixedPhaseQueueIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'fixedPhaseQueue',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      fixedPhaseQueueLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'fixedPhaseQueue',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      fixedPhaseQueueLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'fixedPhaseQueue',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      fixedPhaseQueueLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'fixedPhaseQueue',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> imagePathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'imagePath',
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      imagePathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'imagePath',
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> imagePathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      imagePathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'imagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> imagePathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'imagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> imagePathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'imagePath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> imagePathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'imagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> imagePathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'imagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> imagePathContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'imagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> imagePathMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'imagePath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> imagePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imagePath',
        value: '',
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      imagePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'imagePath',
        value: '',
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> isoCodeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isoCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> isoCodeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isoCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> isoCodeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isoCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> isoCodeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isoCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> isoCodeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'isoCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> isoCodeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'isoCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> isoCodeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'isoCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> isoCodeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'isoCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> isoCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isoCode',
        value: '',
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      isoCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'isoCode',
        value: '',
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> lastReviewEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastReview',
        value: value,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      lastReviewGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastReview',
        value: value,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> lastReviewLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastReview',
        value: value,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> lastReviewBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastReview',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> learningStepEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'learningStep',
        value: value,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      learningStepGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'learningStep',
        value: value,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      learningStepLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'learningStep',
        value: value,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> learningStepBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'learningStep',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      lifetimeCorrectCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lifetimeCorrectCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      lifetimeCorrectCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lifetimeCorrectCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      lifetimeCorrectCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lifetimeCorrectCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      lifetimeCorrectCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lifetimeCorrectCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      lifetimeReviewCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lifetimeReviewCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      lifetimeReviewCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lifetimeReviewCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      lifetimeReviewCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lifetimeReviewCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      lifetimeReviewCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lifetimeReviewCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      lifetimeWrongCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lifetimeWrongCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      lifetimeWrongCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lifetimeWrongCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      lifetimeWrongCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lifetimeWrongCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      lifetimeWrongCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lifetimeWrongCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      manualReviewOverrideDayEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'manualReviewOverrideDay',
        value: value,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      manualReviewOverrideDayGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'manualReviewOverrideDay',
        value: value,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      manualReviewOverrideDayLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'manualReviewOverrideDay',
        value: value,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      manualReviewOverrideDayBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'manualReviewOverrideDay',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> nextReviewEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nextReview',
        value: value,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      nextReviewGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nextReview',
        value: value,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> nextReviewLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nextReview',
        value: value,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> nextReviewBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nextReview',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> originalIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'originalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      originalIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'originalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> originalIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'originalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> originalIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'originalId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      originalIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'originalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> originalIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'originalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> originalIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'originalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> originalIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'originalId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      originalIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'originalId',
        value: '',
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      originalIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'originalId',
        value: '',
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> packNameEqualTo(
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

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> packNameGreaterThan(
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

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> packNameLessThan(
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

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> packNameBetween(
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

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> packNameStartsWith(
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

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> packNameEndsWith(
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

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> packNameContains(
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

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> packNameMatches(
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

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> packNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'packName',
        value: '',
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      packNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'packName',
        value: '',
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> questionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'question',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> questionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'question',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> questionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'question',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> questionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'question',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> questionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'question',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> questionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'question',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> questionContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'question',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> questionMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'question',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> questionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'question',
        value: '',
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      questionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'question',
        value: '',
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      repetitionCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'repetitionCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      repetitionCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'repetitionCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      repetitionCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'repetitionCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      repetitionCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'repetitionCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      reviewPriorityAnchorEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reviewPriorityAnchor',
        value: value,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      reviewPriorityAnchorGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reviewPriorityAnchor',
        value: value,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      reviewPriorityAnchorLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reviewPriorityAnchor',
        value: value,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      reviewPriorityAnchorBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reviewPriorityAnchor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> sentenceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sentence',
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      sentenceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sentence',
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> sentenceEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sentence',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> sentenceGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sentence',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> sentenceLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sentence',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> sentenceBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sentence',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> sentenceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sentence',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> sentenceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sentence',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> sentenceContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sentence',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> sentenceMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sentence',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> sentenceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sentence',
        value: '',
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      sentenceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sentence',
        value: '',
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      sentenceAudioPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sentenceAudioPath',
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      sentenceAudioPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sentenceAudioPath',
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      sentenceAudioPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sentenceAudioPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      sentenceAudioPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sentenceAudioPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      sentenceAudioPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sentenceAudioPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      sentenceAudioPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sentenceAudioPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      sentenceAudioPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sentenceAudioPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      sentenceAudioPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sentenceAudioPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      sentenceAudioPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sentenceAudioPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      sentenceAudioPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sentenceAudioPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      sentenceAudioPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sentenceAudioPath',
        value: '',
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      sentenceAudioPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sentenceAudioPath',
        value: '',
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> stateEqualTo(
    CardState value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'state',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> stateGreaterThan(
    CardState value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'state',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> stateLessThan(
    CardState value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'state',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> stateBetween(
    CardState lower,
    CardState upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'state',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> stateStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'state',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> stateEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'state',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> stateContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'state',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> stateMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'state',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> stateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'state',
        value: '',
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> stateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'state',
        value: '',
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      totalStudyTimeMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalStudyTimeMs',
        value: value,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
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

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
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

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
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

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      translationIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'translation',
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      translationIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'translation',
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> translationEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'translation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      translationGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'translation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> translationLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'translation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> translationBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'translation',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      translationStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'translation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> translationEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'translation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> translationContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'translation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition> translationMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'translation',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      translationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'translation',
        value: '',
      ));
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterFilterCondition>
      translationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'translation',
        value: '',
      ));
    });
  }
}

extension FlashcardQueryObject
    on QueryBuilder<Flashcard, Flashcard, QFilterCondition> {}

extension FlashcardQueryLinks
    on QueryBuilder<Flashcard, Flashcard, QFilterCondition> {}

extension FlashcardQuerySortBy on QueryBuilder<Flashcard, Flashcard, QSortBy> {
  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByAnswer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'answer', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByAnswerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'answer', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByAudioPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioPath', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByAudioPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioPath', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByCardType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardType', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByCardTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardType', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByConsecutiveLapses() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consecutiveLapses', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy>
      sortByConsecutiveLapsesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consecutiveLapses', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByDecayRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'decayRate', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByDecayRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'decayRate', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByExtraDataJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'extraDataJson', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByExtraDataJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'extraDataJson', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByImagePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imagePath', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByImagePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imagePath', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByIsoCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isoCode', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByIsoCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isoCode', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByLastReview() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReview', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByLastReviewDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReview', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByLearningStep() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'learningStep', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByLearningStepDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'learningStep', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy>
      sortByLifetimeCorrectCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lifetimeCorrectCount', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy>
      sortByLifetimeCorrectCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lifetimeCorrectCount', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByLifetimeReviewCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lifetimeReviewCount', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy>
      sortByLifetimeReviewCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lifetimeReviewCount', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByLifetimeWrongCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lifetimeWrongCount', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy>
      sortByLifetimeWrongCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lifetimeWrongCount', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy>
      sortByManualReviewOverrideDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'manualReviewOverrideDay', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy>
      sortByManualReviewOverrideDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'manualReviewOverrideDay', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByNextReview() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextReview', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByNextReviewDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextReview', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByOriginalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalId', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByOriginalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalId', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByPackName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packName', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByPackNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packName', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByQuestion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'question', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByQuestionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'question', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByRepetitionCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repetitionCount', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByRepetitionCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repetitionCount', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy>
      sortByReviewPriorityAnchor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewPriorityAnchor', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy>
      sortByReviewPriorityAnchorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewPriorityAnchor', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortBySentence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sentence', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortBySentenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sentence', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortBySentenceAudioPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sentenceAudioPath', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy>
      sortBySentenceAudioPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sentenceAudioPath', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByState() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'state', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByStateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'state', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByTotalStudyTimeMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalStudyTimeMs', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy>
      sortByTotalStudyTimeMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalStudyTimeMs', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByTranslation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'translation', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> sortByTranslationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'translation', Sort.desc);
    });
  }
}

extension FlashcardQuerySortThenBy
    on QueryBuilder<Flashcard, Flashcard, QSortThenBy> {
  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByAnswer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'answer', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByAnswerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'answer', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByAudioPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioPath', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByAudioPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioPath', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByCardType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardType', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByCardTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardType', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByConsecutiveLapses() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consecutiveLapses', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy>
      thenByConsecutiveLapsesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consecutiveLapses', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByDecayRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'decayRate', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByDecayRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'decayRate', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByExtraDataJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'extraDataJson', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByExtraDataJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'extraDataJson', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByImagePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imagePath', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByImagePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imagePath', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByIsoCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isoCode', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByIsoCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isoCode', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByLastReview() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReview', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByLastReviewDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReview', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByLearningStep() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'learningStep', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByLearningStepDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'learningStep', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy>
      thenByLifetimeCorrectCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lifetimeCorrectCount', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy>
      thenByLifetimeCorrectCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lifetimeCorrectCount', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByLifetimeReviewCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lifetimeReviewCount', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy>
      thenByLifetimeReviewCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lifetimeReviewCount', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByLifetimeWrongCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lifetimeWrongCount', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy>
      thenByLifetimeWrongCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lifetimeWrongCount', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy>
      thenByManualReviewOverrideDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'manualReviewOverrideDay', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy>
      thenByManualReviewOverrideDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'manualReviewOverrideDay', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByNextReview() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextReview', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByNextReviewDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextReview', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByOriginalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalId', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByOriginalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalId', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByPackName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packName', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByPackNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packName', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByQuestion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'question', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByQuestionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'question', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByRepetitionCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repetitionCount', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByRepetitionCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repetitionCount', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy>
      thenByReviewPriorityAnchor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewPriorityAnchor', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy>
      thenByReviewPriorityAnchorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewPriorityAnchor', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenBySentence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sentence', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenBySentenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sentence', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenBySentenceAudioPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sentenceAudioPath', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy>
      thenBySentenceAudioPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sentenceAudioPath', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByState() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'state', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByStateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'state', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByTotalStudyTimeMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalStudyTimeMs', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy>
      thenByTotalStudyTimeMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalStudyTimeMs', Sort.desc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByTranslation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'translation', Sort.asc);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QAfterSortBy> thenByTranslationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'translation', Sort.desc);
    });
  }
}

extension FlashcardQueryWhereDistinct
    on QueryBuilder<Flashcard, Flashcard, QDistinct> {
  QueryBuilder<Flashcard, Flashcard, QDistinct> distinctByAnswer(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'answer', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QDistinct> distinctByAudioPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'audioPath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QDistinct> distinctByCardType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cardType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QDistinct> distinctByConsecutiveLapses() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'consecutiveLapses');
    });
  }

  QueryBuilder<Flashcard, Flashcard, QDistinct> distinctByDecayRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'decayRate');
    });
  }

  QueryBuilder<Flashcard, Flashcard, QDistinct> distinctByExtraDataJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'extraDataJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QDistinct> distinctByFixedPhaseQueue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fixedPhaseQueue');
    });
  }

  QueryBuilder<Flashcard, Flashcard, QDistinct> distinctByImagePath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'imagePath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QDistinct> distinctByIsoCode(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isoCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QDistinct> distinctByLastReview() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastReview');
    });
  }

  QueryBuilder<Flashcard, Flashcard, QDistinct> distinctByLearningStep() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'learningStep');
    });
  }

  QueryBuilder<Flashcard, Flashcard, QDistinct>
      distinctByLifetimeCorrectCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lifetimeCorrectCount');
    });
  }

  QueryBuilder<Flashcard, Flashcard, QDistinct>
      distinctByLifetimeReviewCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lifetimeReviewCount');
    });
  }

  QueryBuilder<Flashcard, Flashcard, QDistinct> distinctByLifetimeWrongCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lifetimeWrongCount');
    });
  }

  QueryBuilder<Flashcard, Flashcard, QDistinct>
      distinctByManualReviewOverrideDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'manualReviewOverrideDay');
    });
  }

  QueryBuilder<Flashcard, Flashcard, QDistinct> distinctByNextReview() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nextReview');
    });
  }

  QueryBuilder<Flashcard, Flashcard, QDistinct> distinctByOriginalId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'originalId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QDistinct> distinctByPackName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'packName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QDistinct> distinctByQuestion(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'question', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QDistinct> distinctByRepetitionCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'repetitionCount');
    });
  }

  QueryBuilder<Flashcard, Flashcard, QDistinct>
      distinctByReviewPriorityAnchor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reviewPriorityAnchor');
    });
  }

  QueryBuilder<Flashcard, Flashcard, QDistinct> distinctBySentence(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sentence', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QDistinct> distinctBySentenceAudioPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sentenceAudioPath',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QDistinct> distinctByState(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'state', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Flashcard, Flashcard, QDistinct> distinctByTotalStudyTimeMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalStudyTimeMs');
    });
  }

  QueryBuilder<Flashcard, Flashcard, QDistinct> distinctByTranslation(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'translation', caseSensitive: caseSensitive);
    });
  }
}

extension FlashcardQueryProperty
    on QueryBuilder<Flashcard, Flashcard, QQueryProperty> {
  QueryBuilder<Flashcard, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Flashcard, String, QQueryOperations> answerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'answer');
    });
  }

  QueryBuilder<Flashcard, String?, QQueryOperations> audioPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'audioPath');
    });
  }

  QueryBuilder<Flashcard, String, QQueryOperations> cardTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cardType');
    });
  }

  QueryBuilder<Flashcard, int, QQueryOperations> consecutiveLapsesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'consecutiveLapses');
    });
  }

  QueryBuilder<Flashcard, double, QQueryOperations> decayRateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'decayRate');
    });
  }

  QueryBuilder<Flashcard, String?, QQueryOperations> extraDataJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'extraDataJson');
    });
  }

  QueryBuilder<Flashcard, List<double>, QQueryOperations>
      fixedPhaseQueueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fixedPhaseQueue');
    });
  }

  QueryBuilder<Flashcard, String?, QQueryOperations> imagePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'imagePath');
    });
  }

  QueryBuilder<Flashcard, String, QQueryOperations> isoCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isoCode');
    });
  }

  QueryBuilder<Flashcard, DateTime, QQueryOperations> lastReviewProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastReview');
    });
  }

  QueryBuilder<Flashcard, int, QQueryOperations> learningStepProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'learningStep');
    });
  }

  QueryBuilder<Flashcard, int, QQueryOperations>
      lifetimeCorrectCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lifetimeCorrectCount');
    });
  }

  QueryBuilder<Flashcard, int, QQueryOperations> lifetimeReviewCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lifetimeReviewCount');
    });
  }

  QueryBuilder<Flashcard, int, QQueryOperations> lifetimeWrongCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lifetimeWrongCount');
    });
  }

  QueryBuilder<Flashcard, DateTime, QQueryOperations>
      manualReviewOverrideDayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'manualReviewOverrideDay');
    });
  }

  QueryBuilder<Flashcard, DateTime, QQueryOperations> nextReviewProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nextReview');
    });
  }

  QueryBuilder<Flashcard, String, QQueryOperations> originalIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'originalId');
    });
  }

  QueryBuilder<Flashcard, String, QQueryOperations> packNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'packName');
    });
  }

  QueryBuilder<Flashcard, String, QQueryOperations> questionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'question');
    });
  }

  QueryBuilder<Flashcard, int, QQueryOperations> repetitionCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'repetitionCount');
    });
  }

  QueryBuilder<Flashcard, DateTime, QQueryOperations>
      reviewPriorityAnchorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reviewPriorityAnchor');
    });
  }

  QueryBuilder<Flashcard, String?, QQueryOperations> sentenceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sentence');
    });
  }

  QueryBuilder<Flashcard, String?, QQueryOperations>
      sentenceAudioPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sentenceAudioPath');
    });
  }

  QueryBuilder<Flashcard, CardState, QQueryOperations> stateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'state');
    });
  }

  QueryBuilder<Flashcard, int, QQueryOperations> totalStudyTimeMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalStudyTimeMs');
    });
  }

  QueryBuilder<Flashcard, String?, QQueryOperations> translationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'translation');
    });
  }
}
