// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: type=lint
class HomePageStateDB extends DataClass implements Insertable<HomePageStateDB> {
  final int id;
  final bool darkMode;
  final bool swapTrack;
  final int theme;
  final int color;
  final String controls;
  HomePageStateDB(
      {required this.id,
      required this.darkMode,
      required this.swapTrack,
      required this.theme,
      required this.color,
      required this.controls});
  factory HomePageStateDB.fromData(Map<String, dynamic> data,
      {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return HomePageStateDB(
      id: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      darkMode: const BoolType()
          .mapFromDatabaseResponse(data['${effectivePrefix}dark_mode'])!,
      swapTrack: const BoolType()
          .mapFromDatabaseResponse(data['${effectivePrefix}swap_track'])!,
      theme: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}theme'])!,
      color: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}color'])!,
      controls: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}controls'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['dark_mode'] = Variable<bool>(darkMode);
    map['swap_track'] = Variable<bool>(swapTrack);
    map['theme'] = Variable<int>(theme);
    map['color'] = Variable<int>(color);
    map['controls'] = Variable<String>(controls);
    return map;
  }

  HomePageStateCompanion toCompanion(bool nullToAbsent) {
    return HomePageStateCompanion(
      id: Value(id),
      darkMode: Value(darkMode),
      swapTrack: Value(swapTrack),
      theme: Value(theme),
      color: Value(color),
      controls: Value(controls),
    );
  }

  factory HomePageStateDB.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HomePageStateDB(
      id: serializer.fromJson<int>(json['id']),
      darkMode: serializer.fromJson<bool>(json['darkMode']),
      swapTrack: serializer.fromJson<bool>(json['swapTrack']),
      theme: serializer.fromJson<int>(json['theme']),
      color: serializer.fromJson<int>(json['color']),
      controls: serializer.fromJson<String>(json['controls']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'darkMode': serializer.toJson<bool>(darkMode),
      'swapTrack': serializer.toJson<bool>(swapTrack),
      'theme': serializer.toJson<int>(theme),
      'color': serializer.toJson<int>(color),
      'controls': serializer.toJson<String>(controls),
    };
  }

  HomePageStateDB copyWith(
          {int? id,
          bool? darkMode,
          bool? swapTrack,
          int? theme,
          int? color,
          String? controls}) =>
      HomePageStateDB(
        id: id ?? this.id,
        darkMode: darkMode ?? this.darkMode,
        swapTrack: swapTrack ?? this.swapTrack,
        theme: theme ?? this.theme,
        color: color ?? this.color,
        controls: controls ?? this.controls,
      );
  @override
  String toString() {
    return (StringBuffer('HomePageStateDB(')
          ..write('id: $id, ')
          ..write('darkMode: $darkMode, ')
          ..write('swapTrack: $swapTrack, ')
          ..write('theme: $theme, ')
          ..write('color: $color, ')
          ..write('controls: $controls')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, darkMode, swapTrack, theme, color, controls);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HomePageStateDB &&
          other.id == this.id &&
          other.darkMode == this.darkMode &&
          other.swapTrack == this.swapTrack &&
          other.theme == this.theme &&
          other.color == this.color &&
          other.controls == this.controls);
}

class HomePageStateCompanion extends UpdateCompanion<HomePageStateDB> {
  final Value<int> id;
  final Value<bool> darkMode;
  final Value<bool> swapTrack;
  final Value<int> theme;
  final Value<int> color;
  final Value<String> controls;
  const HomePageStateCompanion({
    this.id = const Value.absent(),
    this.darkMode = const Value.absent(),
    this.swapTrack = const Value.absent(),
    this.theme = const Value.absent(),
    this.color = const Value.absent(),
    this.controls = const Value.absent(),
  });
  HomePageStateCompanion.insert({
    this.id = const Value.absent(),
    this.darkMode = const Value.absent(),
    this.swapTrack = const Value.absent(),
    this.theme = const Value.absent(),
    this.color = const Value.absent(),
    this.controls = const Value.absent(),
  });
  static Insertable<HomePageStateDB> custom({
    Expression<int>? id,
    Expression<bool>? darkMode,
    Expression<bool>? swapTrack,
    Expression<int>? theme,
    Expression<int>? color,
    Expression<String>? controls,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (darkMode != null) 'dark_mode': darkMode,
      if (swapTrack != null) 'swap_track': swapTrack,
      if (theme != null) 'theme': theme,
      if (color != null) 'color': color,
      if (controls != null) 'controls': controls,
    });
  }

  HomePageStateCompanion copyWith(
      {Value<int>? id,
      Value<bool>? darkMode,
      Value<bool>? swapTrack,
      Value<int>? theme,
      Value<int>? color,
      Value<String>? controls}) {
    return HomePageStateCompanion(
      id: id ?? this.id,
      darkMode: darkMode ?? this.darkMode,
      swapTrack: swapTrack ?? this.swapTrack,
      theme: theme ?? this.theme,
      color: color ?? this.color,
      controls: controls ?? this.controls,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (darkMode.present) {
      map['dark_mode'] = Variable<bool>(darkMode.value);
    }
    if (swapTrack.present) {
      map['swap_track'] = Variable<bool>(swapTrack.value);
    }
    if (theme.present) {
      map['theme'] = Variable<int>(theme.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (controls.present) {
      map['controls'] = Variable<String>(controls.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HomePageStateCompanion(')
          ..write('id: $id, ')
          ..write('darkMode: $darkMode, ')
          ..write('swapTrack: $swapTrack, ')
          ..write('theme: $theme, ')
          ..write('color: $color, ')
          ..write('controls: $controls')
          ..write(')'))
        .toString();
  }
}

class $HomePageStateTable extends HomePageState
    with TableInfo<$HomePageStateTable, HomePageStateDB> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HomePageStateTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int?> id = GeneratedColumn<int?>(
      'id', aliasedName, false,
      type: const IntType(),
      requiredDuringInsert: false,
      defaultConstraints: 'PRIMARY KEY AUTOINCREMENT',
      defaultValue: const Constant(1));
  final VerificationMeta _darkModeMeta = const VerificationMeta('darkMode');
  @override
  late final GeneratedColumn<bool?> darkMode = GeneratedColumn<bool?>(
      'dark_mode', aliasedName, false,
      type: const BoolType(),
      requiredDuringInsert: false,
      defaultConstraints: 'CHECK (dark_mode IN (0, 1))',
      defaultValue: const Constant(false));
  final VerificationMeta _swapTrackMeta = const VerificationMeta('swapTrack');
  @override
  late final GeneratedColumn<bool?> swapTrack = GeneratedColumn<bool?>(
      'swap_track', aliasedName, false,
      type: const BoolType(),
      requiredDuringInsert: false,
      defaultConstraints: 'CHECK (swap_track IN (0, 1))',
      defaultValue: const Constant(false));
  final VerificationMeta _themeMeta = const VerificationMeta('theme');
  @override
  late final GeneratedColumn<int?> theme = GeneratedColumn<int?>(
      'theme', aliasedName, false,
      type: const IntType(),
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  final VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int?> color = GeneratedColumn<int?>(
      'color', aliasedName, false,
      type: const IntType(),
      requiredDuringInsert: false,
      defaultValue: const Constant(0xFF000000));
  final VerificationMeta _controlsMeta = const VerificationMeta('controls');
  @override
  late final GeneratedColumn<String?> controls = GeneratedColumn<String?>(
      'controls', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 10, maxTextLength: 20),
      type: const StringType(),
      requiredDuringInsert: false,
      defaultValue: const Constant('[0, 1, 2, 3, 4]'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, darkMode, swapTrack, theme, color, controls];
  @override
  String get aliasedName => _alias ?? 'home_page_state';
  @override
  String get actualTableName => 'home_page_state';
  @override
  VerificationContext validateIntegrity(Insertable<HomePageStateDB> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('dark_mode')) {
      context.handle(_darkModeMeta,
          darkMode.isAcceptableOrUnknown(data['dark_mode']!, _darkModeMeta));
    }
    if (data.containsKey('swap_track')) {
      context.handle(_swapTrackMeta,
          swapTrack.isAcceptableOrUnknown(data['swap_track']!, _swapTrackMeta));
    }
    if (data.containsKey('theme')) {
      context.handle(
          _themeMeta, theme.isAcceptableOrUnknown(data['theme']!, _themeMeta));
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('controls')) {
      context.handle(_controlsMeta,
          controls.isAcceptableOrUnknown(data['controls']!, _controlsMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HomePageStateDB map(Map<String, dynamic> data, {String? tablePrefix}) {
    return HomePageStateDB.fromData(data,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $HomePageStateTable createAlias(String alias) {
    return $HomePageStateTable(attachedDatabase, alias);
  }
}

class SongDataDB extends DataClass implements Insertable<SongDataDB> {
  final int id;
  final String artist;
  final String album;
  final String title;
  final String localPath;
  final String art;
  SongDataDB(
      {required this.id,
      required this.artist,
      required this.album,
      required this.title,
      required this.localPath,
      required this.art});
  factory SongDataDB.fromData(Map<String, dynamic> data, {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return SongDataDB(
      id: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      artist: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}artist'])!,
      album: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}album'])!,
      title: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}title'])!,
      localPath: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}local_path'])!,
      art: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}art'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['artist'] = Variable<String>(artist);
    map['album'] = Variable<String>(album);
    map['title'] = Variable<String>(title);
    map['local_path'] = Variable<String>(localPath);
    map['art'] = Variable<String>(art);
    return map;
  }

  SongsCompanion toCompanion(bool nullToAbsent) {
    return SongsCompanion(
      id: Value(id),
      artist: Value(artist),
      album: Value(album),
      title: Value(title),
      localPath: Value(localPath),
      art: Value(art),
    );
  }

  factory SongDataDB.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SongDataDB(
      id: serializer.fromJson<int>(json['id']),
      artist: serializer.fromJson<String>(json['artist']),
      album: serializer.fromJson<String>(json['album']),
      title: serializer.fromJson<String>(json['title']),
      localPath: serializer.fromJson<String>(json['localPath']),
      art: serializer.fromJson<String>(json['art']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'artist': serializer.toJson<String>(artist),
      'album': serializer.toJson<String>(album),
      'title': serializer.toJson<String>(title),
      'localPath': serializer.toJson<String>(localPath),
      'art': serializer.toJson<String>(art),
    };
  }

  SongDataDB copyWith(
          {int? id,
          String? artist,
          String? album,
          String? title,
          String? localPath,
          String? art}) =>
      SongDataDB(
        id: id ?? this.id,
        artist: artist ?? this.artist,
        album: album ?? this.album,
        title: title ?? this.title,
        localPath: localPath ?? this.localPath,
        art: art ?? this.art,
      );
  @override
  String toString() {
    return (StringBuffer('SongDataDB(')
          ..write('id: $id, ')
          ..write('artist: $artist, ')
          ..write('album: $album, ')
          ..write('title: $title, ')
          ..write('localPath: $localPath, ')
          ..write('art: $art')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, artist, album, title, localPath, art);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SongDataDB &&
          other.id == this.id &&
          other.artist == this.artist &&
          other.album == this.album &&
          other.title == this.title &&
          other.localPath == this.localPath &&
          other.art == this.art);
}

class SongsCompanion extends UpdateCompanion<SongDataDB> {
  final Value<int> id;
  final Value<String> artist;
  final Value<String> album;
  final Value<String> title;
  final Value<String> localPath;
  final Value<String> art;
  const SongsCompanion({
    this.id = const Value.absent(),
    this.artist = const Value.absent(),
    this.album = const Value.absent(),
    this.title = const Value.absent(),
    this.localPath = const Value.absent(),
    this.art = const Value.absent(),
  });
  SongsCompanion.insert({
    this.id = const Value.absent(),
    required String artist,
    required String album,
    required String title,
    required String localPath,
    this.art = const Value.absent(),
  })  : artist = Value(artist),
        album = Value(album),
        title = Value(title),
        localPath = Value(localPath);
  static Insertable<SongDataDB> custom({
    Expression<int>? id,
    Expression<String>? artist,
    Expression<String>? album,
    Expression<String>? title,
    Expression<String>? localPath,
    Expression<String>? art,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (artist != null) 'artist': artist,
      if (album != null) 'album': album,
      if (title != null) 'title': title,
      if (localPath != null) 'local_path': localPath,
      if (art != null) 'art': art,
    });
  }

  SongsCompanion copyWith(
      {Value<int>? id,
      Value<String>? artist,
      Value<String>? album,
      Value<String>? title,
      Value<String>? localPath,
      Value<String>? art}) {
    return SongsCompanion(
      id: id ?? this.id,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      title: title ?? this.title,
      localPath: localPath ?? this.localPath,
      art: art ?? this.art,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (album.present) {
      map['album'] = Variable<String>(album.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (art.present) {
      map['art'] = Variable<String>(art.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SongsCompanion(')
          ..write('id: $id, ')
          ..write('artist: $artist, ')
          ..write('album: $album, ')
          ..write('title: $title, ')
          ..write('localPath: $localPath, ')
          ..write('art: $art')
          ..write(')'))
        .toString();
  }
}

class $SongsTable extends Songs with TableInfo<$SongsTable, SongDataDB> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SongsTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int?> id = GeneratedColumn<int?>(
      'id', aliasedName, false,
      type: const IntType(),
      requiredDuringInsert: false,
      defaultConstraints: 'PRIMARY KEY AUTOINCREMENT');
  final VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String?> artist = GeneratedColumn<String?>(
      'artist', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 128),
      type: const StringType(),
      requiredDuringInsert: true);
  final VerificationMeta _albumMeta = const VerificationMeta('album');
  @override
  late final GeneratedColumn<String?> album = GeneratedColumn<String?>(
      'album', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 128),
      type: const StringType(),
      requiredDuringInsert: true);
  final VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String?> title = GeneratedColumn<String?>(
      'title', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 128),
      type: const StringType(),
      requiredDuringInsert: true);
  final VerificationMeta _localPathMeta = const VerificationMeta('localPath');
  @override
  late final GeneratedColumn<String?> localPath = GeneratedColumn<String?>(
      'local_path', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 0, maxTextLength: 1024),
      type: const StringType(),
      requiredDuringInsert: true);
  final VerificationMeta _artMeta = const VerificationMeta('art');
  @override
  late final GeneratedColumn<String?> art = GeneratedColumn<String?>(
      'art', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 0, maxTextLength: 1024),
      type: const StringType(),
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  @override
  List<GeneratedColumn> get $columns =>
      [id, artist, album, title, localPath, art];
  @override
  String get aliasedName => _alias ?? 'songs';
  @override
  String get actualTableName => 'songs';
  @override
  VerificationContext validateIntegrity(Insertable<SongDataDB> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('artist')) {
      context.handle(_artistMeta,
          artist.isAcceptableOrUnknown(data['artist']!, _artistMeta));
    } else if (isInserting) {
      context.missing(_artistMeta);
    }
    if (data.containsKey('album')) {
      context.handle(
          _albumMeta, album.isAcceptableOrUnknown(data['album']!, _albumMeta));
    } else if (isInserting) {
      context.missing(_albumMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(_localPathMeta,
          localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta));
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('art')) {
      context.handle(
          _artMeta, art.isAcceptableOrUnknown(data['art']!, _artMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SongDataDB map(Map<String, dynamic> data, {String? tablePrefix}) {
    return SongDataDB.fromData(data,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $SongsTable createAlias(String alias) {
    return $SongsTable(attachedDatabase, alias);
  }
}

class PlaylistDataDB extends DataClass implements Insertable<PlaylistDataDB> {
  final int id;
  final String title;
  final String description;
  final String art;
  PlaylistDataDB(
      {required this.id,
      required this.title,
      required this.description,
      required this.art});
  factory PlaylistDataDB.fromData(Map<String, dynamic> data, {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return PlaylistDataDB(
      id: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      title: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}title'])!,
      description: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}description'])!,
      art: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}art'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['art'] = Variable<String>(art);
    return map;
  }

  PlaylistsCompanion toCompanion(bool nullToAbsent) {
    return PlaylistsCompanion(
      id: Value(id),
      title: Value(title),
      description: Value(description),
      art: Value(art),
    );
  }

  factory PlaylistDataDB.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistDataDB(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      art: serializer.fromJson<String>(json['art']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'art': serializer.toJson<String>(art),
    };
  }

  PlaylistDataDB copyWith(
          {int? id, String? title, String? description, String? art}) =>
      PlaylistDataDB(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        art: art ?? this.art,
      );
  @override
  String toString() {
    return (StringBuffer('PlaylistDataDB(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('art: $art')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, description, art);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistDataDB &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.art == this.art);
}

class PlaylistsCompanion extends UpdateCompanion<PlaylistDataDB> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> description;
  final Value<String> art;
  const PlaylistsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.art = const Value.absent(),
  });
  PlaylistsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    this.art = const Value.absent(),
  }) : title = Value(title);
  static Insertable<PlaylistDataDB> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? art,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (art != null) 'art': art,
    });
  }

  PlaylistsCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<String>? description,
      Value<String>? art}) {
    return PlaylistsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      art: art ?? this.art,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (art.present) {
      map['art'] = Variable<String>(art.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('art: $art')
          ..write(')'))
        .toString();
  }
}

class $PlaylistsTable extends Playlists
    with TableInfo<$PlaylistsTable, PlaylistDataDB> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistsTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int?> id = GeneratedColumn<int?>(
      'id', aliasedName, false,
      type: const IntType(),
      requiredDuringInsert: false,
      defaultConstraints: 'PRIMARY KEY AUTOINCREMENT');
  final VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String?> title = GeneratedColumn<String?>(
      'title', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 128),
      type: const StringType(),
      requiredDuringInsert: true);
  final VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String?> description = GeneratedColumn<String?>(
      'description', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 0, maxTextLength: 1024),
      type: const StringType(),
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  final VerificationMeta _artMeta = const VerificationMeta('art');
  @override
  late final GeneratedColumn<String?> art = GeneratedColumn<String?>(
      'art', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 0, maxTextLength: 1024),
      type: const StringType(),
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  @override
  List<GeneratedColumn> get $columns => [id, title, description, art];
  @override
  String get aliasedName => _alias ?? 'playlists';
  @override
  String get actualTableName => 'playlists';
  @override
  VerificationContext validateIntegrity(Insertable<PlaylistDataDB> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('art')) {
      context.handle(
          _artMeta, art.isAcceptableOrUnknown(data['art']!, _artMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaylistDataDB map(Map<String, dynamic> data, {String? tablePrefix}) {
    return PlaylistDataDB.fromData(data,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $PlaylistsTable createAlias(String alias) {
    return $PlaylistsTable(attachedDatabase, alias);
  }
}

class PlaylistSongDataDB extends DataClass
    implements Insertable<PlaylistSongDataDB> {
  final int id;
  final int playlist;
  final int song;
  PlaylistSongDataDB(
      {required this.id, required this.playlist, required this.song});
  factory PlaylistSongDataDB.fromData(Map<String, dynamic> data,
      {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return PlaylistSongDataDB(
      id: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      playlist: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}playlist'])!,
      song: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}song'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['playlist'] = Variable<int>(playlist);
    map['song'] = Variable<int>(song);
    return map;
  }

  PlaylistSongsCompanion toCompanion(bool nullToAbsent) {
    return PlaylistSongsCompanion(
      id: Value(id),
      playlist: Value(playlist),
      song: Value(song),
    );
  }

  factory PlaylistSongDataDB.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistSongDataDB(
      id: serializer.fromJson<int>(json['id']),
      playlist: serializer.fromJson<int>(json['playlist']),
      song: serializer.fromJson<int>(json['song']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'playlist': serializer.toJson<int>(playlist),
      'song': serializer.toJson<int>(song),
    };
  }

  PlaylistSongDataDB copyWith({int? id, int? playlist, int? song}) =>
      PlaylistSongDataDB(
        id: id ?? this.id,
        playlist: playlist ?? this.playlist,
        song: song ?? this.song,
      );
  @override
  String toString() {
    return (StringBuffer('PlaylistSongDataDB(')
          ..write('id: $id, ')
          ..write('playlist: $playlist, ')
          ..write('song: $song')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, playlist, song);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistSongDataDB &&
          other.id == this.id &&
          other.playlist == this.playlist &&
          other.song == this.song);
}

class PlaylistSongsCompanion extends UpdateCompanion<PlaylistSongDataDB> {
  final Value<int> id;
  final Value<int> playlist;
  final Value<int> song;
  const PlaylistSongsCompanion({
    this.id = const Value.absent(),
    this.playlist = const Value.absent(),
    this.song = const Value.absent(),
  });
  PlaylistSongsCompanion.insert({
    this.id = const Value.absent(),
    required int playlist,
    required int song,
  })  : playlist = Value(playlist),
        song = Value(song);
  static Insertable<PlaylistSongDataDB> custom({
    Expression<int>? id,
    Expression<int>? playlist,
    Expression<int>? song,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (playlist != null) 'playlist': playlist,
      if (song != null) 'song': song,
    });
  }

  PlaylistSongsCompanion copyWith(
      {Value<int>? id, Value<int>? playlist, Value<int>? song}) {
    return PlaylistSongsCompanion(
      id: id ?? this.id,
      playlist: playlist ?? this.playlist,
      song: song ?? this.song,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (playlist.present) {
      map['playlist'] = Variable<int>(playlist.value);
    }
    if (song.present) {
      map['song'] = Variable<int>(song.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistSongsCompanion(')
          ..write('id: $id, ')
          ..write('playlist: $playlist, ')
          ..write('song: $song')
          ..write(')'))
        .toString();
  }
}

class $PlaylistSongsTable extends PlaylistSongs
    with TableInfo<$PlaylistSongsTable, PlaylistSongDataDB> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistSongsTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int?> id = GeneratedColumn<int?>(
      'id', aliasedName, false,
      type: const IntType(),
      requiredDuringInsert: false,
      defaultConstraints: 'PRIMARY KEY AUTOINCREMENT');
  final VerificationMeta _playlistMeta = const VerificationMeta('playlist');
  @override
  late final GeneratedColumn<int?> playlist = GeneratedColumn<int?>(
      'playlist', aliasedName, false,
      type: const IntType(),
      requiredDuringInsert: true,
      defaultConstraints: 'REFERENCES playlists (id)');
  final VerificationMeta _songMeta = const VerificationMeta('song');
  @override
  late final GeneratedColumn<int?> song = GeneratedColumn<int?>(
      'song', aliasedName, false,
      type: const IntType(),
      requiredDuringInsert: true,
      defaultConstraints: 'REFERENCES songs (id)');
  @override
  List<GeneratedColumn> get $columns => [id, playlist, song];
  @override
  String get aliasedName => _alias ?? 'playlist_songs';
  @override
  String get actualTableName => 'playlist_songs';
  @override
  VerificationContext validateIntegrity(Insertable<PlaylistSongDataDB> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('playlist')) {
      context.handle(_playlistMeta,
          playlist.isAcceptableOrUnknown(data['playlist']!, _playlistMeta));
    } else if (isInserting) {
      context.missing(_playlistMeta);
    }
    if (data.containsKey('song')) {
      context.handle(
          _songMeta, song.isAcceptableOrUnknown(data['song']!, _songMeta));
    } else if (isInserting) {
      context.missing(_songMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaylistSongDataDB map(Map<String, dynamic> data, {String? tablePrefix}) {
    return PlaylistSongDataDB.fromData(data,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $PlaylistSongsTable createAlias(String alias) {
    return $PlaylistSongsTable(attachedDatabase, alias);
  }
}

class AlbumDataDB extends DataClass implements Insertable<AlbumDataDB> {
  final int id;
  final String title;
  final String description;
  final String art;
  AlbumDataDB(
      {required this.id,
      required this.title,
      required this.description,
      required this.art});
  factory AlbumDataDB.fromData(Map<String, dynamic> data, {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return AlbumDataDB(
      id: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      title: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}title'])!,
      description: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}description'])!,
      art: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}art'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['art'] = Variable<String>(art);
    return map;
  }

  AlbumsCompanion toCompanion(bool nullToAbsent) {
    return AlbumsCompanion(
      id: Value(id),
      title: Value(title),
      description: Value(description),
      art: Value(art),
    );
  }

  factory AlbumDataDB.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AlbumDataDB(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      art: serializer.fromJson<String>(json['art']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'art': serializer.toJson<String>(art),
    };
  }

  AlbumDataDB copyWith(
          {int? id, String? title, String? description, String? art}) =>
      AlbumDataDB(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        art: art ?? this.art,
      );
  @override
  String toString() {
    return (StringBuffer('AlbumDataDB(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('art: $art')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, description, art);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AlbumDataDB &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.art == this.art);
}

class AlbumsCompanion extends UpdateCompanion<AlbumDataDB> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> description;
  final Value<String> art;
  const AlbumsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.art = const Value.absent(),
  });
  AlbumsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    this.art = const Value.absent(),
  }) : title = Value(title);
  static Insertable<AlbumDataDB> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? art,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (art != null) 'art': art,
    });
  }

  AlbumsCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<String>? description,
      Value<String>? art}) {
    return AlbumsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      art: art ?? this.art,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (art.present) {
      map['art'] = Variable<String>(art.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlbumsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('art: $art')
          ..write(')'))
        .toString();
  }
}

class $AlbumsTable extends Albums with TableInfo<$AlbumsTable, AlbumDataDB> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlbumsTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int?> id = GeneratedColumn<int?>(
      'id', aliasedName, false,
      type: const IntType(),
      requiredDuringInsert: false,
      defaultConstraints: 'PRIMARY KEY AUTOINCREMENT');
  final VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String?> title = GeneratedColumn<String?>(
      'title', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 128),
      type: const StringType(),
      requiredDuringInsert: true);
  final VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String?> description = GeneratedColumn<String?>(
      'description', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 0, maxTextLength: 1024),
      type: const StringType(),
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  final VerificationMeta _artMeta = const VerificationMeta('art');
  @override
  late final GeneratedColumn<String?> art = GeneratedColumn<String?>(
      'art', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 0, maxTextLength: 1024),
      type: const StringType(),
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  @override
  List<GeneratedColumn> get $columns => [id, title, description, art];
  @override
  String get aliasedName => _alias ?? 'albums';
  @override
  String get actualTableName => 'albums';
  @override
  VerificationContext validateIntegrity(Insertable<AlbumDataDB> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('art')) {
      context.handle(
          _artMeta, art.isAcceptableOrUnknown(data['art']!, _artMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AlbumDataDB map(Map<String, dynamic> data, {String? tablePrefix}) {
    return AlbumDataDB.fromData(data,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $AlbumsTable createAlias(String alias) {
    return $AlbumsTable(attachedDatabase, alias);
  }
}

class AlbumSongDataDB extends DataClass implements Insertable<AlbumSongDataDB> {
  final int id;
  final int album;
  final int song;
  AlbumSongDataDB({required this.id, required this.album, required this.song});
  factory AlbumSongDataDB.fromData(Map<String, dynamic> data,
      {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return AlbumSongDataDB(
      id: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      album: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}album'])!,
      song: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}song'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['album'] = Variable<int>(album);
    map['song'] = Variable<int>(song);
    return map;
  }

  AlbumSongsCompanion toCompanion(bool nullToAbsent) {
    return AlbumSongsCompanion(
      id: Value(id),
      album: Value(album),
      song: Value(song),
    );
  }

  factory AlbumSongDataDB.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AlbumSongDataDB(
      id: serializer.fromJson<int>(json['id']),
      album: serializer.fromJson<int>(json['album']),
      song: serializer.fromJson<int>(json['song']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'album': serializer.toJson<int>(album),
      'song': serializer.toJson<int>(song),
    };
  }

  AlbumSongDataDB copyWith({int? id, int? album, int? song}) => AlbumSongDataDB(
        id: id ?? this.id,
        album: album ?? this.album,
        song: song ?? this.song,
      );
  @override
  String toString() {
    return (StringBuffer('AlbumSongDataDB(')
          ..write('id: $id, ')
          ..write('album: $album, ')
          ..write('song: $song')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, album, song);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AlbumSongDataDB &&
          other.id == this.id &&
          other.album == this.album &&
          other.song == this.song);
}

class AlbumSongsCompanion extends UpdateCompanion<AlbumSongDataDB> {
  final Value<int> id;
  final Value<int> album;
  final Value<int> song;
  const AlbumSongsCompanion({
    this.id = const Value.absent(),
    this.album = const Value.absent(),
    this.song = const Value.absent(),
  });
  AlbumSongsCompanion.insert({
    this.id = const Value.absent(),
    required int album,
    required int song,
  })  : album = Value(album),
        song = Value(song);
  static Insertable<AlbumSongDataDB> custom({
    Expression<int>? id,
    Expression<int>? album,
    Expression<int>? song,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (album != null) 'album': album,
      if (song != null) 'song': song,
    });
  }

  AlbumSongsCompanion copyWith(
      {Value<int>? id, Value<int>? album, Value<int>? song}) {
    return AlbumSongsCompanion(
      id: id ?? this.id,
      album: album ?? this.album,
      song: song ?? this.song,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (album.present) {
      map['album'] = Variable<int>(album.value);
    }
    if (song.present) {
      map['song'] = Variable<int>(song.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlbumSongsCompanion(')
          ..write('id: $id, ')
          ..write('album: $album, ')
          ..write('song: $song')
          ..write(')'))
        .toString();
  }
}

class $AlbumSongsTable extends AlbumSongs
    with TableInfo<$AlbumSongsTable, AlbumSongDataDB> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlbumSongsTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int?> id = GeneratedColumn<int?>(
      'id', aliasedName, false,
      type: const IntType(),
      requiredDuringInsert: false,
      defaultConstraints: 'PRIMARY KEY AUTOINCREMENT');
  final VerificationMeta _albumMeta = const VerificationMeta('album');
  @override
  late final GeneratedColumn<int?> album = GeneratedColumn<int?>(
      'album', aliasedName, false,
      type: const IntType(),
      requiredDuringInsert: true,
      defaultConstraints: 'REFERENCES albums (id)');
  final VerificationMeta _songMeta = const VerificationMeta('song');
  @override
  late final GeneratedColumn<int?> song = GeneratedColumn<int?>(
      'song', aliasedName, false,
      type: const IntType(),
      requiredDuringInsert: true,
      defaultConstraints: 'REFERENCES songs (id)');
  @override
  List<GeneratedColumn> get $columns => [id, album, song];
  @override
  String get aliasedName => _alias ?? 'album_songs';
  @override
  String get actualTableName => 'album_songs';
  @override
  VerificationContext validateIntegrity(Insertable<AlbumSongDataDB> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('album')) {
      context.handle(
          _albumMeta, album.isAcceptableOrUnknown(data['album']!, _albumMeta));
    } else if (isInserting) {
      context.missing(_albumMeta);
    }
    if (data.containsKey('song')) {
      context.handle(
          _songMeta, song.isAcceptableOrUnknown(data['song']!, _songMeta));
    } else if (isInserting) {
      context.missing(_songMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AlbumSongDataDB map(Map<String, dynamic> data, {String? tablePrefix}) {
    return AlbumSongDataDB.fromData(data,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $AlbumSongsTable createAlias(String alias) {
    return $AlbumSongsTable(attachedDatabase, alias);
  }
}

abstract class _$SharedDatabase extends GeneratedDatabase {
  _$SharedDatabase(QueryExecutor e) : super(SqlTypeSystem.defaultInstance, e);
  late final $HomePageStateTable homePageState = $HomePageStateTable(this);
  late final $SongsTable songs = $SongsTable(this);
  late final $PlaylistsTable playlists = $PlaylistsTable(this);
  late final $PlaylistSongsTable playlistSongs = $PlaylistSongsTable(this);
  late final $AlbumsTable albums = $AlbumsTable(this);
  late final $AlbumSongsTable albumSongs = $AlbumSongsTable(this);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [homePageState, songs, playlists, playlistSongs, albums, albumSongs];
}
