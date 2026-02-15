// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'anime_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AnimeModel _$AnimeModelFromJson(Map<String, dynamic> json) {
  return _AnimeModel.fromJson(json);
}

/// @nodoc
mixin _$AnimeModel {
  String get id => throw _privateConstructorUsedError;
  String? get malId => throw _privateConstructorUsedError;
  @JsonKey(name: 'title')
  TitleModel get title => throw _privateConstructorUsedError;
  String? get image => throw _privateConstructorUsedError;
  String? get cover => throw _privateConstructorUsedError;
  int? get popularity => throw _privateConstructorUsedError;
  String? get color => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
  int? get releaseDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'genres')
  List<String>? get genres => throw _privateConstructorUsedError;
  int? get totalEpisodes => throw _privateConstructorUsedError;
  int? get currentEpisode => throw _privateConstructorUsedError;
  String? get type => throw _privateConstructorUsedError;
  String? get countryOfOrigin => throw _privateConstructorUsedError;

  /// Serializes this AnimeModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AnimeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AnimeModelCopyWith<AnimeModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AnimeModelCopyWith<$Res> {
  factory $AnimeModelCopyWith(
          AnimeModel value, $Res Function(AnimeModel) then) =
      _$AnimeModelCopyWithImpl<$Res, AnimeModel>;
  @useResult
  $Res call(
      {String id,
      String? malId,
      @JsonKey(name: 'title') TitleModel title,
      String? image,
      String? cover,
      int? popularity,
      String? color,
      String? description,
      String? status,
      int? releaseDate,
      @JsonKey(name: 'genres') List<String>? genres,
      int? totalEpisodes,
      int? currentEpisode,
      String? type,
      String? countryOfOrigin});

  $TitleModelCopyWith<$Res> get title;
}

/// @nodoc
class _$AnimeModelCopyWithImpl<$Res, $Val extends AnimeModel>
    implements $AnimeModelCopyWith<$Res> {
  _$AnimeModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AnimeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? malId = freezed,
    Object? title = null,
    Object? image = freezed,
    Object? cover = freezed,
    Object? popularity = freezed,
    Object? color = freezed,
    Object? description = freezed,
    Object? status = freezed,
    Object? releaseDate = freezed,
    Object? genres = freezed,
    Object? totalEpisodes = freezed,
    Object? currentEpisode = freezed,
    Object? type = freezed,
    Object? countryOfOrigin = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      malId: freezed == malId
          ? _value.malId
          : malId // ignore: cast_nullable_to_non_nullable
              as String?,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as TitleModel,
      image: freezed == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
      cover: freezed == cover
          ? _value.cover
          : cover // ignore: cast_nullable_to_non_nullable
              as String?,
      popularity: freezed == popularity
          ? _value.popularity
          : popularity // ignore: cast_nullable_to_non_nullable
              as int?,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      releaseDate: freezed == releaseDate
          ? _value.releaseDate
          : releaseDate // ignore: cast_nullable_to_non_nullable
              as int?,
      genres: freezed == genres
          ? _value.genres
          : genres // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      totalEpisodes: freezed == totalEpisodes
          ? _value.totalEpisodes
          : totalEpisodes // ignore: cast_nullable_to_non_nullable
              as int?,
      currentEpisode: freezed == currentEpisode
          ? _value.currentEpisode
          : currentEpisode // ignore: cast_nullable_to_non_nullable
              as int?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      countryOfOrigin: freezed == countryOfOrigin
          ? _value.countryOfOrigin
          : countryOfOrigin // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of AnimeModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TitleModelCopyWith<$Res> get title {
    return $TitleModelCopyWith<$Res>(_value.title, (value) {
      return _then(_value.copyWith(title: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AnimeModelImplCopyWith<$Res>
    implements $AnimeModelCopyWith<$Res> {
  factory _$$AnimeModelImplCopyWith(
          _$AnimeModelImpl value, $Res Function(_$AnimeModelImpl) then) =
      __$$AnimeModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String? malId,
      @JsonKey(name: 'title') TitleModel title,
      String? image,
      String? cover,
      int? popularity,
      String? color,
      String? description,
      String? status,
      int? releaseDate,
      @JsonKey(name: 'genres') List<String>? genres,
      int? totalEpisodes,
      int? currentEpisode,
      String? type,
      String? countryOfOrigin});

  @override
  $TitleModelCopyWith<$Res> get title;
}

/// @nodoc
class __$$AnimeModelImplCopyWithImpl<$Res>
    extends _$AnimeModelCopyWithImpl<$Res, _$AnimeModelImpl>
    implements _$$AnimeModelImplCopyWith<$Res> {
  __$$AnimeModelImplCopyWithImpl(
      _$AnimeModelImpl _value, $Res Function(_$AnimeModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of AnimeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? malId = freezed,
    Object? title = null,
    Object? image = freezed,
    Object? cover = freezed,
    Object? popularity = freezed,
    Object? color = freezed,
    Object? description = freezed,
    Object? status = freezed,
    Object? releaseDate = freezed,
    Object? genres = freezed,
    Object? totalEpisodes = freezed,
    Object? currentEpisode = freezed,
    Object? type = freezed,
    Object? countryOfOrigin = freezed,
  }) {
    return _then(_$AnimeModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      malId: freezed == malId
          ? _value.malId
          : malId // ignore: cast_nullable_to_non_nullable
              as String?,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as TitleModel,
      image: freezed == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
      cover: freezed == cover
          ? _value.cover
          : cover // ignore: cast_nullable_to_non_nullable
              as String?,
      popularity: freezed == popularity
          ? _value.popularity
          : popularity // ignore: cast_nullable_to_non_nullable
              as int?,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      releaseDate: freezed == releaseDate
          ? _value.releaseDate
          : releaseDate // ignore: cast_nullable_to_non_nullable
              as int?,
      genres: freezed == genres
          ? _value._genres
          : genres // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      totalEpisodes: freezed == totalEpisodes
          ? _value.totalEpisodes
          : totalEpisodes // ignore: cast_nullable_to_non_nullable
              as int?,
      currentEpisode: freezed == currentEpisode
          ? _value.currentEpisode
          : currentEpisode // ignore: cast_nullable_to_non_nullable
              as int?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      countryOfOrigin: freezed == countryOfOrigin
          ? _value.countryOfOrigin
          : countryOfOrigin // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AnimeModelImpl implements _AnimeModel {
  const _$AnimeModelImpl(
      {required this.id,
      this.malId,
      @JsonKey(name: 'title') required this.title,
      this.image,
      this.cover,
      this.popularity,
      this.color,
      this.description,
      this.status,
      this.releaseDate,
      @JsonKey(name: 'genres') final List<String>? genres,
      this.totalEpisodes,
      this.currentEpisode,
      this.type,
      this.countryOfOrigin})
      : _genres = genres;

  factory _$AnimeModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AnimeModelImplFromJson(json);

  @override
  final String id;
  @override
  final String? malId;
  @override
  @JsonKey(name: 'title')
  final TitleModel title;
  @override
  final String? image;
  @override
  final String? cover;
  @override
  final int? popularity;
  @override
  final String? color;
  @override
  final String? description;
  @override
  final String? status;
  @override
  final int? releaseDate;
  final List<String>? _genres;
  @override
  @JsonKey(name: 'genres')
  List<String>? get genres {
    final value = _genres;
    if (value == null) return null;
    if (_genres is EqualUnmodifiableListView) return _genres;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final int? totalEpisodes;
  @override
  final int? currentEpisode;
  @override
  final String? type;
  @override
  final String? countryOfOrigin;

  @override
  String toString() {
    return 'AnimeModel(id: $id, malId: $malId, title: $title, image: $image, cover: $cover, popularity: $popularity, color: $color, description: $description, status: $status, releaseDate: $releaseDate, genres: $genres, totalEpisodes: $totalEpisodes, currentEpisode: $currentEpisode, type: $type, countryOfOrigin: $countryOfOrigin)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AnimeModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.malId, malId) || other.malId == malId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.image, image) || other.image == image) &&
            (identical(other.cover, cover) || other.cover == cover) &&
            (identical(other.popularity, popularity) ||
                other.popularity == popularity) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.releaseDate, releaseDate) ||
                other.releaseDate == releaseDate) &&
            const DeepCollectionEquality().equals(other._genres, _genres) &&
            (identical(other.totalEpisodes, totalEpisodes) ||
                other.totalEpisodes == totalEpisodes) &&
            (identical(other.currentEpisode, currentEpisode) ||
                other.currentEpisode == currentEpisode) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.countryOfOrigin, countryOfOrigin) ||
                other.countryOfOrigin == countryOfOrigin));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      malId,
      title,
      image,
      cover,
      popularity,
      color,
      description,
      status,
      releaseDate,
      const DeepCollectionEquality().hash(_genres),
      totalEpisodes,
      currentEpisode,
      type,
      countryOfOrigin);

  /// Create a copy of AnimeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AnimeModelImplCopyWith<_$AnimeModelImpl> get copyWith =>
      __$$AnimeModelImplCopyWithImpl<_$AnimeModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AnimeModelImplToJson(
      this,
    );
  }
}

abstract class _AnimeModel implements AnimeModel {
  const factory _AnimeModel(
      {required final String id,
      final String? malId,
      @JsonKey(name: 'title') required final TitleModel title,
      final String? image,
      final String? cover,
      final int? popularity,
      final String? color,
      final String? description,
      final String? status,
      final int? releaseDate,
      @JsonKey(name: 'genres') final List<String>? genres,
      final int? totalEpisodes,
      final int? currentEpisode,
      final String? type,
      final String? countryOfOrigin}) = _$AnimeModelImpl;

  factory _AnimeModel.fromJson(Map<String, dynamic> json) =
      _$AnimeModelImpl.fromJson;

  @override
  String get id;
  @override
  String? get malId;
  @override
  @JsonKey(name: 'title')
  TitleModel get title;
  @override
  String? get image;
  @override
  String? get cover;
  @override
  int? get popularity;
  @override
  String? get color;
  @override
  String? get description;
  @override
  String? get status;
  @override
  int? get releaseDate;
  @override
  @JsonKey(name: 'genres')
  List<String>? get genres;
  @override
  int? get totalEpisodes;
  @override
  int? get currentEpisode;
  @override
  String? get type;
  @override
  String? get countryOfOrigin;

  /// Create a copy of AnimeModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AnimeModelImplCopyWith<_$AnimeModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TitleModel _$TitleModelFromJson(Map<String, dynamic> json) {
  return _TitleModel.fromJson(json);
}

/// @nodoc
mixin _$TitleModel {
  String? get romaji => throw _privateConstructorUsedError;
  String? get english => throw _privateConstructorUsedError;
  String? get native => throw _privateConstructorUsedError;

  /// Serializes this TitleModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TitleModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TitleModelCopyWith<TitleModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TitleModelCopyWith<$Res> {
  factory $TitleModelCopyWith(
          TitleModel value, $Res Function(TitleModel) then) =
      _$TitleModelCopyWithImpl<$Res, TitleModel>;
  @useResult
  $Res call({String? romaji, String? english, String? native});
}

/// @nodoc
class _$TitleModelCopyWithImpl<$Res, $Val extends TitleModel>
    implements $TitleModelCopyWith<$Res> {
  _$TitleModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TitleModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? romaji = freezed,
    Object? english = freezed,
    Object? native = freezed,
  }) {
    return _then(_value.copyWith(
      romaji: freezed == romaji
          ? _value.romaji
          : romaji // ignore: cast_nullable_to_non_nullable
              as String?,
      english: freezed == english
          ? _value.english
          : english // ignore: cast_nullable_to_non_nullable
              as String?,
      native: freezed == native
          ? _value.native
          : native // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TitleModelImplCopyWith<$Res>
    implements $TitleModelCopyWith<$Res> {
  factory _$$TitleModelImplCopyWith(
          _$TitleModelImpl value, $Res Function(_$TitleModelImpl) then) =
      __$$TitleModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? romaji, String? english, String? native});
}

/// @nodoc
class __$$TitleModelImplCopyWithImpl<$Res>
    extends _$TitleModelCopyWithImpl<$Res, _$TitleModelImpl>
    implements _$$TitleModelImplCopyWith<$Res> {
  __$$TitleModelImplCopyWithImpl(
      _$TitleModelImpl _value, $Res Function(_$TitleModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of TitleModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? romaji = freezed,
    Object? english = freezed,
    Object? native = freezed,
  }) {
    return _then(_$TitleModelImpl(
      romaji: freezed == romaji
          ? _value.romaji
          : romaji // ignore: cast_nullable_to_non_nullable
              as String?,
      english: freezed == english
          ? _value.english
          : english // ignore: cast_nullable_to_non_nullable
              as String?,
      native: freezed == native
          ? _value.native
          : native // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TitleModelImpl implements _TitleModel {
  const _$TitleModelImpl({this.romaji, this.english, this.native});

  factory _$TitleModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TitleModelImplFromJson(json);

  @override
  final String? romaji;
  @override
  final String? english;
  @override
  final String? native;

  @override
  String toString() {
    return 'TitleModel(romaji: $romaji, english: $english, native: $native)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TitleModelImpl &&
            (identical(other.romaji, romaji) || other.romaji == romaji) &&
            (identical(other.english, english) || other.english == english) &&
            (identical(other.native, native) || other.native == native));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, romaji, english, native);

  /// Create a copy of TitleModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TitleModelImplCopyWith<_$TitleModelImpl> get copyWith =>
      __$$TitleModelImplCopyWithImpl<_$TitleModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TitleModelImplToJson(
      this,
    );
  }
}

abstract class _TitleModel implements TitleModel {
  const factory _TitleModel(
      {final String? romaji,
      final String? english,
      final String? native}) = _$TitleModelImpl;

  factory _TitleModel.fromJson(Map<String, dynamic> json) =
      _$TitleModelImpl.fromJson;

  @override
  String? get romaji;
  @override
  String? get english;
  @override
  String? get native;

  /// Create a copy of TitleModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TitleModelImplCopyWith<_$TitleModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AnimeListResponse _$AnimeListResponseFromJson(Map<String, dynamic> json) {
  return _AnimeListResponse.fromJson(json);
}

/// @nodoc
mixin _$AnimeListResponse {
  int? get currentPage => throw _privateConstructorUsedError;
  bool? get hasNextPage => throw _privateConstructorUsedError;
  List<AnimeModel>? get results => throw _privateConstructorUsedError;

  /// Serializes this AnimeListResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AnimeListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AnimeListResponseCopyWith<AnimeListResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AnimeListResponseCopyWith<$Res> {
  factory $AnimeListResponseCopyWith(
          AnimeListResponse value, $Res Function(AnimeListResponse) then) =
      _$AnimeListResponseCopyWithImpl<$Res, AnimeListResponse>;
  @useResult
  $Res call({int? currentPage, bool? hasNextPage, List<AnimeModel>? results});
}

/// @nodoc
class _$AnimeListResponseCopyWithImpl<$Res, $Val extends AnimeListResponse>
    implements $AnimeListResponseCopyWith<$Res> {
  _$AnimeListResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AnimeListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentPage = freezed,
    Object? hasNextPage = freezed,
    Object? results = freezed,
  }) {
    return _then(_value.copyWith(
      currentPage: freezed == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int?,
      hasNextPage: freezed == hasNextPage
          ? _value.hasNextPage
          : hasNextPage // ignore: cast_nullable_to_non_nullable
              as bool?,
      results: freezed == results
          ? _value.results
          : results // ignore: cast_nullable_to_non_nullable
              as List<AnimeModel>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AnimeListResponseImplCopyWith<$Res>
    implements $AnimeListResponseCopyWith<$Res> {
  factory _$$AnimeListResponseImplCopyWith(_$AnimeListResponseImpl value,
          $Res Function(_$AnimeListResponseImpl) then) =
      __$$AnimeListResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int? currentPage, bool? hasNextPage, List<AnimeModel>? results});
}

/// @nodoc
class __$$AnimeListResponseImplCopyWithImpl<$Res>
    extends _$AnimeListResponseCopyWithImpl<$Res, _$AnimeListResponseImpl>
    implements _$$AnimeListResponseImplCopyWith<$Res> {
  __$$AnimeListResponseImplCopyWithImpl(_$AnimeListResponseImpl _value,
      $Res Function(_$AnimeListResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of AnimeListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentPage = freezed,
    Object? hasNextPage = freezed,
    Object? results = freezed,
  }) {
    return _then(_$AnimeListResponseImpl(
      currentPage: freezed == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int?,
      hasNextPage: freezed == hasNextPage
          ? _value.hasNextPage
          : hasNextPage // ignore: cast_nullable_to_non_nullable
              as bool?,
      results: freezed == results
          ? _value._results
          : results // ignore: cast_nullable_to_non_nullable
              as List<AnimeModel>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AnimeListResponseImpl implements _AnimeListResponse {
  const _$AnimeListResponseImpl(
      {this.currentPage, this.hasNextPage, final List<AnimeModel>? results})
      : _results = results;

  factory _$AnimeListResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$AnimeListResponseImplFromJson(json);

  @override
  final int? currentPage;
  @override
  final bool? hasNextPage;
  final List<AnimeModel>? _results;
  @override
  List<AnimeModel>? get results {
    final value = _results;
    if (value == null) return null;
    if (_results is EqualUnmodifiableListView) return _results;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'AnimeListResponse(currentPage: $currentPage, hasNextPage: $hasNextPage, results: $results)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AnimeListResponseImpl &&
            (identical(other.currentPage, currentPage) ||
                other.currentPage == currentPage) &&
            (identical(other.hasNextPage, hasNextPage) ||
                other.hasNextPage == hasNextPage) &&
            const DeepCollectionEquality().equals(other._results, _results));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, currentPage, hasNextPage,
      const DeepCollectionEquality().hash(_results));

  /// Create a copy of AnimeListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AnimeListResponseImplCopyWith<_$AnimeListResponseImpl> get copyWith =>
      __$$AnimeListResponseImplCopyWithImpl<_$AnimeListResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AnimeListResponseImplToJson(
      this,
    );
  }
}

abstract class _AnimeListResponse implements AnimeListResponse {
  const factory _AnimeListResponse(
      {final int? currentPage,
      final bool? hasNextPage,
      final List<AnimeModel>? results}) = _$AnimeListResponseImpl;

  factory _AnimeListResponse.fromJson(Map<String, dynamic> json) =
      _$AnimeListResponseImpl.fromJson;

  @override
  int? get currentPage;
  @override
  bool? get hasNextPage;
  @override
  List<AnimeModel>? get results;

  /// Create a copy of AnimeListResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AnimeListResponseImplCopyWith<_$AnimeListResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
