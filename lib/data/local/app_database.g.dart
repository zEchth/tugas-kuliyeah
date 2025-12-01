// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $MataKuliahsTable extends MataKuliahs
    with TableInfo<$MataKuliahsTable, MataKuliah> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MataKuliahsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _namaMeta = const VerificationMeta('nama');
  @override
  late final GeneratedColumn<String> nama = GeneratedColumn<String>(
    'nama',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dosenMeta = const VerificationMeta('dosen');
  @override
  late final GeneratedColumn<String> dosen = GeneratedColumn<String>(
    'dosen',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sksMeta = const VerificationMeta('sks');
  @override
  late final GeneratedColumn<int> sks = GeneratedColumn<int>(
    'sks',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, nama, dosen, sks];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mata_kuliahs';
  @override
  VerificationContext validateIntegrity(
    Insertable<MataKuliah> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('nama')) {
      context.handle(
        _namaMeta,
        nama.isAcceptableOrUnknown(data['nama']!, _namaMeta),
      );
    } else if (isInserting) {
      context.missing(_namaMeta);
    }
    if (data.containsKey('dosen')) {
      context.handle(
        _dosenMeta,
        dosen.isAcceptableOrUnknown(data['dosen']!, _dosenMeta),
      );
    } else if (isInserting) {
      context.missing(_dosenMeta);
    }
    if (data.containsKey('sks')) {
      context.handle(
        _sksMeta,
        sks.isAcceptableOrUnknown(data['sks']!, _sksMeta),
      );
    } else if (isInserting) {
      context.missing(_sksMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MataKuliah map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MataKuliah(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nama: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nama'],
      )!,
      dosen: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dosen'],
      )!,
      sks: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sks'],
      )!,
    );
  }

  @override
  $MataKuliahsTable createAlias(String alias) {
    return $MataKuliahsTable(attachedDatabase, alias);
  }
}

class MataKuliah extends DataClass implements Insertable<MataKuliah> {
  final String id;
  final String nama;
  final String dosen;
  final int sks;
  const MataKuliah({
    required this.id,
    required this.nama,
    required this.dosen,
    required this.sks,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['nama'] = Variable<String>(nama);
    map['dosen'] = Variable<String>(dosen);
    map['sks'] = Variable<int>(sks);
    return map;
  }

  MataKuliahsCompanion toCompanion(bool nullToAbsent) {
    return MataKuliahsCompanion(
      id: Value(id),
      nama: Value(nama),
      dosen: Value(dosen),
      sks: Value(sks),
    );
  }

  factory MataKuliah.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MataKuliah(
      id: serializer.fromJson<String>(json['id']),
      nama: serializer.fromJson<String>(json['nama']),
      dosen: serializer.fromJson<String>(json['dosen']),
      sks: serializer.fromJson<int>(json['sks']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nama': serializer.toJson<String>(nama),
      'dosen': serializer.toJson<String>(dosen),
      'sks': serializer.toJson<int>(sks),
    };
  }

  MataKuliah copyWith({String? id, String? nama, String? dosen, int? sks}) =>
      MataKuliah(
        id: id ?? this.id,
        nama: nama ?? this.nama,
        dosen: dosen ?? this.dosen,
        sks: sks ?? this.sks,
      );
  MataKuliah copyWithCompanion(MataKuliahsCompanion data) {
    return MataKuliah(
      id: data.id.present ? data.id.value : this.id,
      nama: data.nama.present ? data.nama.value : this.nama,
      dosen: data.dosen.present ? data.dosen.value : this.dosen,
      sks: data.sks.present ? data.sks.value : this.sks,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MataKuliah(')
          ..write('id: $id, ')
          ..write('nama: $nama, ')
          ..write('dosen: $dosen, ')
          ..write('sks: $sks')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nama, dosen, sks);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MataKuliah &&
          other.id == this.id &&
          other.nama == this.nama &&
          other.dosen == this.dosen &&
          other.sks == this.sks);
}

class MataKuliahsCompanion extends UpdateCompanion<MataKuliah> {
  final Value<String> id;
  final Value<String> nama;
  final Value<String> dosen;
  final Value<int> sks;
  final Value<int> rowid;
  const MataKuliahsCompanion({
    this.id = const Value.absent(),
    this.nama = const Value.absent(),
    this.dosen = const Value.absent(),
    this.sks = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MataKuliahsCompanion.insert({
    required String id,
    required String nama,
    required String dosen,
    required int sks,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nama = Value(nama),
       dosen = Value(dosen),
       sks = Value(sks);
  static Insertable<MataKuliah> custom({
    Expression<String>? id,
    Expression<String>? nama,
    Expression<String>? dosen,
    Expression<int>? sks,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nama != null) 'nama': nama,
      if (dosen != null) 'dosen': dosen,
      if (sks != null) 'sks': sks,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MataKuliahsCompanion copyWith({
    Value<String>? id,
    Value<String>? nama,
    Value<String>? dosen,
    Value<int>? sks,
    Value<int>? rowid,
  }) {
    return MataKuliahsCompanion(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      dosen: dosen ?? this.dosen,
      sks: sks ?? this.sks,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nama.present) {
      map['nama'] = Variable<String>(nama.value);
    }
    if (dosen.present) {
      map['dosen'] = Variable<String>(dosen.value);
    }
    if (sks.present) {
      map['sks'] = Variable<int>(sks.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MataKuliahsCompanion(')
          ..write('id: $id, ')
          ..write('nama: $nama, ')
          ..write('dosen: $dosen, ')
          ..write('sks: $sks, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $JadwalsTable extends Jadwals with TableInfo<$JadwalsTable, Jadwal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JadwalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mataKuliahIdMeta = const VerificationMeta(
    'mataKuliahId',
  );
  @override
  late final GeneratedColumn<String> mataKuliahId = GeneratedColumn<String>(
    'mata_kuliah_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES mata_kuliahs (id)',
    ),
  );
  static const VerificationMeta _hariMeta = const VerificationMeta('hari');
  @override
  late final GeneratedColumn<String> hari = GeneratedColumn<String>(
    'hari',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jamMulaiMeta = const VerificationMeta(
    'jamMulai',
  );
  @override
  late final GeneratedColumn<DateTime> jamMulai = GeneratedColumn<DateTime>(
    'jam_mulai',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jamSelesaiMeta = const VerificationMeta(
    'jamSelesai',
  );
  @override
  late final GeneratedColumn<DateTime> jamSelesai = GeneratedColumn<DateTime>(
    'jam_selesai',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ruanganMeta = const VerificationMeta(
    'ruangan',
  );
  @override
  late final GeneratedColumn<String> ruangan = GeneratedColumn<String>(
    'ruangan',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    mataKuliahId,
    hari,
    jamMulai,
    jamSelesai,
    ruangan,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'jadwals';
  @override
  VerificationContext validateIntegrity(
    Insertable<Jadwal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('mata_kuliah_id')) {
      context.handle(
        _mataKuliahIdMeta,
        mataKuliahId.isAcceptableOrUnknown(
          data['mata_kuliah_id']!,
          _mataKuliahIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mataKuliahIdMeta);
    }
    if (data.containsKey('hari')) {
      context.handle(
        _hariMeta,
        hari.isAcceptableOrUnknown(data['hari']!, _hariMeta),
      );
    } else if (isInserting) {
      context.missing(_hariMeta);
    }
    if (data.containsKey('jam_mulai')) {
      context.handle(
        _jamMulaiMeta,
        jamMulai.isAcceptableOrUnknown(data['jam_mulai']!, _jamMulaiMeta),
      );
    } else if (isInserting) {
      context.missing(_jamMulaiMeta);
    }
    if (data.containsKey('jam_selesai')) {
      context.handle(
        _jamSelesaiMeta,
        jamSelesai.isAcceptableOrUnknown(data['jam_selesai']!, _jamSelesaiMeta),
      );
    } else if (isInserting) {
      context.missing(_jamSelesaiMeta);
    }
    if (data.containsKey('ruangan')) {
      context.handle(
        _ruanganMeta,
        ruangan.isAcceptableOrUnknown(data['ruangan']!, _ruanganMeta),
      );
    } else if (isInserting) {
      context.missing(_ruanganMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Jadwal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Jadwal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      mataKuliahId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mata_kuliah_id'],
      )!,
      hari: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hari'],
      )!,
      jamMulai: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}jam_mulai'],
      )!,
      jamSelesai: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}jam_selesai'],
      )!,
      ruangan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ruangan'],
      )!,
    );
  }

  @override
  $JadwalsTable createAlias(String alias) {
    return $JadwalsTable(attachedDatabase, alias);
  }
}

class Jadwal extends DataClass implements Insertable<Jadwal> {
  final String id;
  final String mataKuliahId;
  final String hari;
  final DateTime jamMulai;
  final DateTime jamSelesai;
  final String ruangan;
  const Jadwal({
    required this.id,
    required this.mataKuliahId,
    required this.hari,
    required this.jamMulai,
    required this.jamSelesai,
    required this.ruangan,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['mata_kuliah_id'] = Variable<String>(mataKuliahId);
    map['hari'] = Variable<String>(hari);
    map['jam_mulai'] = Variable<DateTime>(jamMulai);
    map['jam_selesai'] = Variable<DateTime>(jamSelesai);
    map['ruangan'] = Variable<String>(ruangan);
    return map;
  }

  JadwalsCompanion toCompanion(bool nullToAbsent) {
    return JadwalsCompanion(
      id: Value(id),
      mataKuliahId: Value(mataKuliahId),
      hari: Value(hari),
      jamMulai: Value(jamMulai),
      jamSelesai: Value(jamSelesai),
      ruangan: Value(ruangan),
    );
  }

  factory Jadwal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Jadwal(
      id: serializer.fromJson<String>(json['id']),
      mataKuliahId: serializer.fromJson<String>(json['mataKuliahId']),
      hari: serializer.fromJson<String>(json['hari']),
      jamMulai: serializer.fromJson<DateTime>(json['jamMulai']),
      jamSelesai: serializer.fromJson<DateTime>(json['jamSelesai']),
      ruangan: serializer.fromJson<String>(json['ruangan']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'mataKuliahId': serializer.toJson<String>(mataKuliahId),
      'hari': serializer.toJson<String>(hari),
      'jamMulai': serializer.toJson<DateTime>(jamMulai),
      'jamSelesai': serializer.toJson<DateTime>(jamSelesai),
      'ruangan': serializer.toJson<String>(ruangan),
    };
  }

  Jadwal copyWith({
    String? id,
    String? mataKuliahId,
    String? hari,
    DateTime? jamMulai,
    DateTime? jamSelesai,
    String? ruangan,
  }) => Jadwal(
    id: id ?? this.id,
    mataKuliahId: mataKuliahId ?? this.mataKuliahId,
    hari: hari ?? this.hari,
    jamMulai: jamMulai ?? this.jamMulai,
    jamSelesai: jamSelesai ?? this.jamSelesai,
    ruangan: ruangan ?? this.ruangan,
  );
  Jadwal copyWithCompanion(JadwalsCompanion data) {
    return Jadwal(
      id: data.id.present ? data.id.value : this.id,
      mataKuliahId: data.mataKuliahId.present
          ? data.mataKuliahId.value
          : this.mataKuliahId,
      hari: data.hari.present ? data.hari.value : this.hari,
      jamMulai: data.jamMulai.present ? data.jamMulai.value : this.jamMulai,
      jamSelesai: data.jamSelesai.present
          ? data.jamSelesai.value
          : this.jamSelesai,
      ruangan: data.ruangan.present ? data.ruangan.value : this.ruangan,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Jadwal(')
          ..write('id: $id, ')
          ..write('mataKuliahId: $mataKuliahId, ')
          ..write('hari: $hari, ')
          ..write('jamMulai: $jamMulai, ')
          ..write('jamSelesai: $jamSelesai, ')
          ..write('ruangan: $ruangan')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, mataKuliahId, hari, jamMulai, jamSelesai, ruangan);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Jadwal &&
          other.id == this.id &&
          other.mataKuliahId == this.mataKuliahId &&
          other.hari == this.hari &&
          other.jamMulai == this.jamMulai &&
          other.jamSelesai == this.jamSelesai &&
          other.ruangan == this.ruangan);
}

class JadwalsCompanion extends UpdateCompanion<Jadwal> {
  final Value<String> id;
  final Value<String> mataKuliahId;
  final Value<String> hari;
  final Value<DateTime> jamMulai;
  final Value<DateTime> jamSelesai;
  final Value<String> ruangan;
  final Value<int> rowid;
  const JadwalsCompanion({
    this.id = const Value.absent(),
    this.mataKuliahId = const Value.absent(),
    this.hari = const Value.absent(),
    this.jamMulai = const Value.absent(),
    this.jamSelesai = const Value.absent(),
    this.ruangan = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JadwalsCompanion.insert({
    required String id,
    required String mataKuliahId,
    required String hari,
    required DateTime jamMulai,
    required DateTime jamSelesai,
    required String ruangan,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       mataKuliahId = Value(mataKuliahId),
       hari = Value(hari),
       jamMulai = Value(jamMulai),
       jamSelesai = Value(jamSelesai),
       ruangan = Value(ruangan);
  static Insertable<Jadwal> custom({
    Expression<String>? id,
    Expression<String>? mataKuliahId,
    Expression<String>? hari,
    Expression<DateTime>? jamMulai,
    Expression<DateTime>? jamSelesai,
    Expression<String>? ruangan,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mataKuliahId != null) 'mata_kuliah_id': mataKuliahId,
      if (hari != null) 'hari': hari,
      if (jamMulai != null) 'jam_mulai': jamMulai,
      if (jamSelesai != null) 'jam_selesai': jamSelesai,
      if (ruangan != null) 'ruangan': ruangan,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JadwalsCompanion copyWith({
    Value<String>? id,
    Value<String>? mataKuliahId,
    Value<String>? hari,
    Value<DateTime>? jamMulai,
    Value<DateTime>? jamSelesai,
    Value<String>? ruangan,
    Value<int>? rowid,
  }) {
    return JadwalsCompanion(
      id: id ?? this.id,
      mataKuliahId: mataKuliahId ?? this.mataKuliahId,
      hari: hari ?? this.hari,
      jamMulai: jamMulai ?? this.jamMulai,
      jamSelesai: jamSelesai ?? this.jamSelesai,
      ruangan: ruangan ?? this.ruangan,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (mataKuliahId.present) {
      map['mata_kuliah_id'] = Variable<String>(mataKuliahId.value);
    }
    if (hari.present) {
      map['hari'] = Variable<String>(hari.value);
    }
    if (jamMulai.present) {
      map['jam_mulai'] = Variable<DateTime>(jamMulai.value);
    }
    if (jamSelesai.present) {
      map['jam_selesai'] = Variable<DateTime>(jamSelesai.value);
    }
    if (ruangan.present) {
      map['ruangan'] = Variable<String>(ruangan.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JadwalsCompanion(')
          ..write('id: $id, ')
          ..write('mataKuliahId: $mataKuliahId, ')
          ..write('hari: $hari, ')
          ..write('jamMulai: $jamMulai, ')
          ..write('jamSelesai: $jamSelesai, ')
          ..write('ruangan: $ruangan, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TugassTable extends Tugass with TableInfo<$TugassTable, TugassData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TugassTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mataKuliahIdMeta = const VerificationMeta(
    'mataKuliahId',
  );
  @override
  late final GeneratedColumn<String> mataKuliahId = GeneratedColumn<String>(
    'mata_kuliah_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES mata_kuliahs (id)',
    ),
  );
  static const VerificationMeta _jenisMeta = const VerificationMeta('jenis');
  @override
  late final GeneratedColumn<String> jenis = GeneratedColumn<String>(
    'jenis',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deskripsiMeta = const VerificationMeta(
    'deskripsi',
  );
  @override
  late final GeneratedColumn<String> deskripsi = GeneratedColumn<String>(
    'deskripsi',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tenggatWaktuMeta = const VerificationMeta(
    'tenggatWaktu',
  );
  @override
  late final GeneratedColumn<DateTime> tenggatWaktu = GeneratedColumn<DateTime>(
    'tenggat_waktu',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attachmentPathMeta = const VerificationMeta(
    'attachmentPath',
  );
  @override
  late final GeneratedColumn<String> attachmentPath = GeneratedColumn<String>(
    'attachment_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Belum Dikerjakan'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    mataKuliahId,
    jenis,
    deskripsi,
    tenggatWaktu,
    attachmentPath,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tugass';
  @override
  VerificationContext validateIntegrity(
    Insertable<TugassData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('mata_kuliah_id')) {
      context.handle(
        _mataKuliahIdMeta,
        mataKuliahId.isAcceptableOrUnknown(
          data['mata_kuliah_id']!,
          _mataKuliahIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mataKuliahIdMeta);
    }
    if (data.containsKey('jenis')) {
      context.handle(
        _jenisMeta,
        jenis.isAcceptableOrUnknown(data['jenis']!, _jenisMeta),
      );
    } else if (isInserting) {
      context.missing(_jenisMeta);
    }
    if (data.containsKey('deskripsi')) {
      context.handle(
        _deskripsiMeta,
        deskripsi.isAcceptableOrUnknown(data['deskripsi']!, _deskripsiMeta),
      );
    } else if (isInserting) {
      context.missing(_deskripsiMeta);
    }
    if (data.containsKey('tenggat_waktu')) {
      context.handle(
        _tenggatWaktuMeta,
        tenggatWaktu.isAcceptableOrUnknown(
          data['tenggat_waktu']!,
          _tenggatWaktuMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tenggatWaktuMeta);
    }
    if (data.containsKey('attachment_path')) {
      context.handle(
        _attachmentPathMeta,
        attachmentPath.isAcceptableOrUnknown(
          data['attachment_path']!,
          _attachmentPathMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TugassData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TugassData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      mataKuliahId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mata_kuliah_id'],
      )!,
      jenis: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}jenis'],
      )!,
      deskripsi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deskripsi'],
      )!,
      tenggatWaktu: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}tenggat_waktu'],
      )!,
      attachmentPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attachment_path'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $TugassTable createAlias(String alias) {
    return $TugassTable(attachedDatabase, alias);
  }
}

class TugassData extends DataClass implements Insertable<TugassData> {
  final String id;
  final String mataKuliahId;
  final String jenis;
  final String deskripsi;
  final DateTime tenggatWaktu;
  final String? attachmentPath;
  final String status;
  const TugassData({
    required this.id,
    required this.mataKuliahId,
    required this.jenis,
    required this.deskripsi,
    required this.tenggatWaktu,
    this.attachmentPath,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['mata_kuliah_id'] = Variable<String>(mataKuliahId);
    map['jenis'] = Variable<String>(jenis);
    map['deskripsi'] = Variable<String>(deskripsi);
    map['tenggat_waktu'] = Variable<DateTime>(tenggatWaktu);
    if (!nullToAbsent || attachmentPath != null) {
      map['attachment_path'] = Variable<String>(attachmentPath);
    }
    map['status'] = Variable<String>(status);
    return map;
  }

  TugassCompanion toCompanion(bool nullToAbsent) {
    return TugassCompanion(
      id: Value(id),
      mataKuliahId: Value(mataKuliahId),
      jenis: Value(jenis),
      deskripsi: Value(deskripsi),
      tenggatWaktu: Value(tenggatWaktu),
      attachmentPath: attachmentPath == null && nullToAbsent
          ? const Value.absent()
          : Value(attachmentPath),
      status: Value(status),
    );
  }

  factory TugassData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TugassData(
      id: serializer.fromJson<String>(json['id']),
      mataKuliahId: serializer.fromJson<String>(json['mataKuliahId']),
      jenis: serializer.fromJson<String>(json['jenis']),
      deskripsi: serializer.fromJson<String>(json['deskripsi']),
      tenggatWaktu: serializer.fromJson<DateTime>(json['tenggatWaktu']),
      attachmentPath: serializer.fromJson<String?>(json['attachmentPath']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'mataKuliahId': serializer.toJson<String>(mataKuliahId),
      'jenis': serializer.toJson<String>(jenis),
      'deskripsi': serializer.toJson<String>(deskripsi),
      'tenggatWaktu': serializer.toJson<DateTime>(tenggatWaktu),
      'attachmentPath': serializer.toJson<String?>(attachmentPath),
      'status': serializer.toJson<String>(status),
    };
  }

  TugassData copyWith({
    String? id,
    String? mataKuliahId,
    String? jenis,
    String? deskripsi,
    DateTime? tenggatWaktu,
    Value<String?> attachmentPath = const Value.absent(),
    String? status,
  }) => TugassData(
    id: id ?? this.id,
    mataKuliahId: mataKuliahId ?? this.mataKuliahId,
    jenis: jenis ?? this.jenis,
    deskripsi: deskripsi ?? this.deskripsi,
    tenggatWaktu: tenggatWaktu ?? this.tenggatWaktu,
    attachmentPath: attachmentPath.present
        ? attachmentPath.value
        : this.attachmentPath,
    status: status ?? this.status,
  );
  TugassData copyWithCompanion(TugassCompanion data) {
    return TugassData(
      id: data.id.present ? data.id.value : this.id,
      mataKuliahId: data.mataKuliahId.present
          ? data.mataKuliahId.value
          : this.mataKuliahId,
      jenis: data.jenis.present ? data.jenis.value : this.jenis,
      deskripsi: data.deskripsi.present ? data.deskripsi.value : this.deskripsi,
      tenggatWaktu: data.tenggatWaktu.present
          ? data.tenggatWaktu.value
          : this.tenggatWaktu,
      attachmentPath: data.attachmentPath.present
          ? data.attachmentPath.value
          : this.attachmentPath,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TugassData(')
          ..write('id: $id, ')
          ..write('mataKuliahId: $mataKuliahId, ')
          ..write('jenis: $jenis, ')
          ..write('deskripsi: $deskripsi, ')
          ..write('tenggatWaktu: $tenggatWaktu, ')
          ..write('attachmentPath: $attachmentPath, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    mataKuliahId,
    jenis,
    deskripsi,
    tenggatWaktu,
    attachmentPath,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TugassData &&
          other.id == this.id &&
          other.mataKuliahId == this.mataKuliahId &&
          other.jenis == this.jenis &&
          other.deskripsi == this.deskripsi &&
          other.tenggatWaktu == this.tenggatWaktu &&
          other.attachmentPath == this.attachmentPath &&
          other.status == this.status);
}

class TugassCompanion extends UpdateCompanion<TugassData> {
  final Value<String> id;
  final Value<String> mataKuliahId;
  final Value<String> jenis;
  final Value<String> deskripsi;
  final Value<DateTime> tenggatWaktu;
  final Value<String?> attachmentPath;
  final Value<String> status;
  final Value<int> rowid;
  const TugassCompanion({
    this.id = const Value.absent(),
    this.mataKuliahId = const Value.absent(),
    this.jenis = const Value.absent(),
    this.deskripsi = const Value.absent(),
    this.tenggatWaktu = const Value.absent(),
    this.attachmentPath = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TugassCompanion.insert({
    required String id,
    required String mataKuliahId,
    required String jenis,
    required String deskripsi,
    required DateTime tenggatWaktu,
    this.attachmentPath = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       mataKuliahId = Value(mataKuliahId),
       jenis = Value(jenis),
       deskripsi = Value(deskripsi),
       tenggatWaktu = Value(tenggatWaktu);
  static Insertable<TugassData> custom({
    Expression<String>? id,
    Expression<String>? mataKuliahId,
    Expression<String>? jenis,
    Expression<String>? deskripsi,
    Expression<DateTime>? tenggatWaktu,
    Expression<String>? attachmentPath,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mataKuliahId != null) 'mata_kuliah_id': mataKuliahId,
      if (jenis != null) 'jenis': jenis,
      if (deskripsi != null) 'deskripsi': deskripsi,
      if (tenggatWaktu != null) 'tenggat_waktu': tenggatWaktu,
      if (attachmentPath != null) 'attachment_path': attachmentPath,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TugassCompanion copyWith({
    Value<String>? id,
    Value<String>? mataKuliahId,
    Value<String>? jenis,
    Value<String>? deskripsi,
    Value<DateTime>? tenggatWaktu,
    Value<String?>? attachmentPath,
    Value<String>? status,
    Value<int>? rowid,
  }) {
    return TugassCompanion(
      id: id ?? this.id,
      mataKuliahId: mataKuliahId ?? this.mataKuliahId,
      jenis: jenis ?? this.jenis,
      deskripsi: deskripsi ?? this.deskripsi,
      tenggatWaktu: tenggatWaktu ?? this.tenggatWaktu,
      attachmentPath: attachmentPath ?? this.attachmentPath,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (mataKuliahId.present) {
      map['mata_kuliah_id'] = Variable<String>(mataKuliahId.value);
    }
    if (jenis.present) {
      map['jenis'] = Variable<String>(jenis.value);
    }
    if (deskripsi.present) {
      map['deskripsi'] = Variable<String>(deskripsi.value);
    }
    if (tenggatWaktu.present) {
      map['tenggat_waktu'] = Variable<DateTime>(tenggatWaktu.value);
    }
    if (attachmentPath.present) {
      map['attachment_path'] = Variable<String>(attachmentPath.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TugassCompanion(')
          ..write('id: $id, ')
          ..write('mataKuliahId: $mataKuliahId, ')
          ..write('jenis: $jenis, ')
          ..write('deskripsi: $deskripsi, ')
          ..write('tenggatWaktu: $tenggatWaktu, ')
          ..write('attachmentPath: $attachmentPath, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MataKuliahsTable mataKuliahs = $MataKuliahsTable(this);
  late final $JadwalsTable jadwals = $JadwalsTable(this);
  late final $TugassTable tugass = $TugassTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    mataKuliahs,
    jadwals,
    tugass,
  ];
}

typedef $$MataKuliahsTableCreateCompanionBuilder =
    MataKuliahsCompanion Function({
      required String id,
      required String nama,
      required String dosen,
      required int sks,
      Value<int> rowid,
    });
typedef $$MataKuliahsTableUpdateCompanionBuilder =
    MataKuliahsCompanion Function({
      Value<String> id,
      Value<String> nama,
      Value<String> dosen,
      Value<int> sks,
      Value<int> rowid,
    });

final class $$MataKuliahsTableReferences
    extends BaseReferences<_$AppDatabase, $MataKuliahsTable, MataKuliah> {
  $$MataKuliahsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$JadwalsTable, List<Jadwal>> _jadwalsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.jadwals,
    aliasName: $_aliasNameGenerator(db.mataKuliahs.id, db.jadwals.mataKuliahId),
  );

  $$JadwalsTableProcessedTableManager get jadwalsRefs {
    final manager = $$JadwalsTableTableManager(
      $_db,
      $_db.jadwals,
    ).filter((f) => f.mataKuliahId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_jadwalsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TugassTable, List<TugassData>> _tugassRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.tugass,
    aliasName: $_aliasNameGenerator(db.mataKuliahs.id, db.tugass.mataKuliahId),
  );

  $$TugassTableProcessedTableManager get tugassRefs {
    final manager = $$TugassTableTableManager(
      $_db,
      $_db.tugass,
    ).filter((f) => f.mataKuliahId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tugassRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MataKuliahsTableFilterComposer
    extends Composer<_$AppDatabase, $MataKuliahsTable> {
  $$MataKuliahsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nama => $composableBuilder(
    column: $table.nama,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dosen => $composableBuilder(
    column: $table.dosen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sks => $composableBuilder(
    column: $table.sks,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> jadwalsRefs(
    Expression<bool> Function($$JadwalsTableFilterComposer f) f,
  ) {
    final $$JadwalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.jadwals,
      getReferencedColumn: (t) => t.mataKuliahId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JadwalsTableFilterComposer(
            $db: $db,
            $table: $db.jadwals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> tugassRefs(
    Expression<bool> Function($$TugassTableFilterComposer f) f,
  ) {
    final $$TugassTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tugass,
      getReferencedColumn: (t) => t.mataKuliahId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TugassTableFilterComposer(
            $db: $db,
            $table: $db.tugass,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MataKuliahsTableOrderingComposer
    extends Composer<_$AppDatabase, $MataKuliahsTable> {
  $$MataKuliahsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nama => $composableBuilder(
    column: $table.nama,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dosen => $composableBuilder(
    column: $table.dosen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sks => $composableBuilder(
    column: $table.sks,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MataKuliahsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MataKuliahsTable> {
  $$MataKuliahsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nama =>
      $composableBuilder(column: $table.nama, builder: (column) => column);

  GeneratedColumn<String> get dosen =>
      $composableBuilder(column: $table.dosen, builder: (column) => column);

  GeneratedColumn<int> get sks =>
      $composableBuilder(column: $table.sks, builder: (column) => column);

  Expression<T> jadwalsRefs<T extends Object>(
    Expression<T> Function($$JadwalsTableAnnotationComposer a) f,
  ) {
    final $$JadwalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.jadwals,
      getReferencedColumn: (t) => t.mataKuliahId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JadwalsTableAnnotationComposer(
            $db: $db,
            $table: $db.jadwals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> tugassRefs<T extends Object>(
    Expression<T> Function($$TugassTableAnnotationComposer a) f,
  ) {
    final $$TugassTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tugass,
      getReferencedColumn: (t) => t.mataKuliahId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TugassTableAnnotationComposer(
            $db: $db,
            $table: $db.tugass,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MataKuliahsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MataKuliahsTable,
          MataKuliah,
          $$MataKuliahsTableFilterComposer,
          $$MataKuliahsTableOrderingComposer,
          $$MataKuliahsTableAnnotationComposer,
          $$MataKuliahsTableCreateCompanionBuilder,
          $$MataKuliahsTableUpdateCompanionBuilder,
          (MataKuliah, $$MataKuliahsTableReferences),
          MataKuliah,
          PrefetchHooks Function({bool jadwalsRefs, bool tugassRefs})
        > {
  $$MataKuliahsTableTableManager(_$AppDatabase db, $MataKuliahsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MataKuliahsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MataKuliahsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MataKuliahsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> nama = const Value.absent(),
                Value<String> dosen = const Value.absent(),
                Value<int> sks = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MataKuliahsCompanion(
                id: id,
                nama: nama,
                dosen: dosen,
                sks: sks,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String nama,
                required String dosen,
                required int sks,
                Value<int> rowid = const Value.absent(),
              }) => MataKuliahsCompanion.insert(
                id: id,
                nama: nama,
                dosen: dosen,
                sks: sks,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MataKuliahsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({jadwalsRefs = false, tugassRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (jadwalsRefs) db.jadwals,
                if (tugassRefs) db.tugass,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (jadwalsRefs)
                    await $_getPrefetchedData<
                      MataKuliah,
                      $MataKuliahsTable,
                      Jadwal
                    >(
                      currentTable: table,
                      referencedTable: $$MataKuliahsTableReferences
                          ._jadwalsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$MataKuliahsTableReferences(
                            db,
                            table,
                            p0,
                          ).jadwalsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.mataKuliahId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (tugassRefs)
                    await $_getPrefetchedData<
                      MataKuliah,
                      $MataKuliahsTable,
                      TugassData
                    >(
                      currentTable: table,
                      referencedTable: $$MataKuliahsTableReferences
                          ._tugassRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$MataKuliahsTableReferences(
                            db,
                            table,
                            p0,
                          ).tugassRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.mataKuliahId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$MataKuliahsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MataKuliahsTable,
      MataKuliah,
      $$MataKuliahsTableFilterComposer,
      $$MataKuliahsTableOrderingComposer,
      $$MataKuliahsTableAnnotationComposer,
      $$MataKuliahsTableCreateCompanionBuilder,
      $$MataKuliahsTableUpdateCompanionBuilder,
      (MataKuliah, $$MataKuliahsTableReferences),
      MataKuliah,
      PrefetchHooks Function({bool jadwalsRefs, bool tugassRefs})
    >;
typedef $$JadwalsTableCreateCompanionBuilder =
    JadwalsCompanion Function({
      required String id,
      required String mataKuliahId,
      required String hari,
      required DateTime jamMulai,
      required DateTime jamSelesai,
      required String ruangan,
      Value<int> rowid,
    });
typedef $$JadwalsTableUpdateCompanionBuilder =
    JadwalsCompanion Function({
      Value<String> id,
      Value<String> mataKuliahId,
      Value<String> hari,
      Value<DateTime> jamMulai,
      Value<DateTime> jamSelesai,
      Value<String> ruangan,
      Value<int> rowid,
    });

final class $$JadwalsTableReferences
    extends BaseReferences<_$AppDatabase, $JadwalsTable, Jadwal> {
  $$JadwalsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MataKuliahsTable _mataKuliahIdTable(_$AppDatabase db) =>
      db.mataKuliahs.createAlias(
        $_aliasNameGenerator(db.jadwals.mataKuliahId, db.mataKuliahs.id),
      );

  $$MataKuliahsTableProcessedTableManager get mataKuliahId {
    final $_column = $_itemColumn<String>('mata_kuliah_id')!;

    final manager = $$MataKuliahsTableTableManager(
      $_db,
      $_db.mataKuliahs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mataKuliahIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$JadwalsTableFilterComposer
    extends Composer<_$AppDatabase, $JadwalsTable> {
  $$JadwalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hari => $composableBuilder(
    column: $table.hari,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get jamMulai => $composableBuilder(
    column: $table.jamMulai,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get jamSelesai => $composableBuilder(
    column: $table.jamSelesai,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ruangan => $composableBuilder(
    column: $table.ruangan,
    builder: (column) => ColumnFilters(column),
  );

  $$MataKuliahsTableFilterComposer get mataKuliahId {
    final $$MataKuliahsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mataKuliahId,
      referencedTable: $db.mataKuliahs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MataKuliahsTableFilterComposer(
            $db: $db,
            $table: $db.mataKuliahs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$JadwalsTableOrderingComposer
    extends Composer<_$AppDatabase, $JadwalsTable> {
  $$JadwalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hari => $composableBuilder(
    column: $table.hari,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get jamMulai => $composableBuilder(
    column: $table.jamMulai,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get jamSelesai => $composableBuilder(
    column: $table.jamSelesai,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ruangan => $composableBuilder(
    column: $table.ruangan,
    builder: (column) => ColumnOrderings(column),
  );

  $$MataKuliahsTableOrderingComposer get mataKuliahId {
    final $$MataKuliahsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mataKuliahId,
      referencedTable: $db.mataKuliahs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MataKuliahsTableOrderingComposer(
            $db: $db,
            $table: $db.mataKuliahs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$JadwalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $JadwalsTable> {
  $$JadwalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get hari =>
      $composableBuilder(column: $table.hari, builder: (column) => column);

  GeneratedColumn<DateTime> get jamMulai =>
      $composableBuilder(column: $table.jamMulai, builder: (column) => column);

  GeneratedColumn<DateTime> get jamSelesai => $composableBuilder(
    column: $table.jamSelesai,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ruangan =>
      $composableBuilder(column: $table.ruangan, builder: (column) => column);

  $$MataKuliahsTableAnnotationComposer get mataKuliahId {
    final $$MataKuliahsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mataKuliahId,
      referencedTable: $db.mataKuliahs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MataKuliahsTableAnnotationComposer(
            $db: $db,
            $table: $db.mataKuliahs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$JadwalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JadwalsTable,
          Jadwal,
          $$JadwalsTableFilterComposer,
          $$JadwalsTableOrderingComposer,
          $$JadwalsTableAnnotationComposer,
          $$JadwalsTableCreateCompanionBuilder,
          $$JadwalsTableUpdateCompanionBuilder,
          (Jadwal, $$JadwalsTableReferences),
          Jadwal,
          PrefetchHooks Function({bool mataKuliahId})
        > {
  $$JadwalsTableTableManager(_$AppDatabase db, $JadwalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JadwalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JadwalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JadwalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> mataKuliahId = const Value.absent(),
                Value<String> hari = const Value.absent(),
                Value<DateTime> jamMulai = const Value.absent(),
                Value<DateTime> jamSelesai = const Value.absent(),
                Value<String> ruangan = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JadwalsCompanion(
                id: id,
                mataKuliahId: mataKuliahId,
                hari: hari,
                jamMulai: jamMulai,
                jamSelesai: jamSelesai,
                ruangan: ruangan,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String mataKuliahId,
                required String hari,
                required DateTime jamMulai,
                required DateTime jamSelesai,
                required String ruangan,
                Value<int> rowid = const Value.absent(),
              }) => JadwalsCompanion.insert(
                id: id,
                mataKuliahId: mataKuliahId,
                hari: hari,
                jamMulai: jamMulai,
                jamSelesai: jamSelesai,
                ruangan: ruangan,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$JadwalsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({mataKuliahId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (mataKuliahId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.mataKuliahId,
                                referencedTable: $$JadwalsTableReferences
                                    ._mataKuliahIdTable(db),
                                referencedColumn: $$JadwalsTableReferences
                                    ._mataKuliahIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$JadwalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JadwalsTable,
      Jadwal,
      $$JadwalsTableFilterComposer,
      $$JadwalsTableOrderingComposer,
      $$JadwalsTableAnnotationComposer,
      $$JadwalsTableCreateCompanionBuilder,
      $$JadwalsTableUpdateCompanionBuilder,
      (Jadwal, $$JadwalsTableReferences),
      Jadwal,
      PrefetchHooks Function({bool mataKuliahId})
    >;
typedef $$TugassTableCreateCompanionBuilder =
    TugassCompanion Function({
      required String id,
      required String mataKuliahId,
      required String jenis,
      required String deskripsi,
      required DateTime tenggatWaktu,
      Value<String?> attachmentPath,
      Value<String> status,
      Value<int> rowid,
    });
typedef $$TugassTableUpdateCompanionBuilder =
    TugassCompanion Function({
      Value<String> id,
      Value<String> mataKuliahId,
      Value<String> jenis,
      Value<String> deskripsi,
      Value<DateTime> tenggatWaktu,
      Value<String?> attachmentPath,
      Value<String> status,
      Value<int> rowid,
    });

final class $$TugassTableReferences
    extends BaseReferences<_$AppDatabase, $TugassTable, TugassData> {
  $$TugassTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MataKuliahsTable _mataKuliahIdTable(_$AppDatabase db) =>
      db.mataKuliahs.createAlias(
        $_aliasNameGenerator(db.tugass.mataKuliahId, db.mataKuliahs.id),
      );

  $$MataKuliahsTableProcessedTableManager get mataKuliahId {
    final $_column = $_itemColumn<String>('mata_kuliah_id')!;

    final manager = $$MataKuliahsTableTableManager(
      $_db,
      $_db.mataKuliahs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mataKuliahIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TugassTableFilterComposer
    extends Composer<_$AppDatabase, $TugassTable> {
  $$TugassTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jenis => $composableBuilder(
    column: $table.jenis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deskripsi => $composableBuilder(
    column: $table.deskripsi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get tenggatWaktu => $composableBuilder(
    column: $table.tenggatWaktu,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attachmentPath => $composableBuilder(
    column: $table.attachmentPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  $$MataKuliahsTableFilterComposer get mataKuliahId {
    final $$MataKuliahsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mataKuliahId,
      referencedTable: $db.mataKuliahs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MataKuliahsTableFilterComposer(
            $db: $db,
            $table: $db.mataKuliahs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TugassTableOrderingComposer
    extends Composer<_$AppDatabase, $TugassTable> {
  $$TugassTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jenis => $composableBuilder(
    column: $table.jenis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deskripsi => $composableBuilder(
    column: $table.deskripsi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get tenggatWaktu => $composableBuilder(
    column: $table.tenggatWaktu,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attachmentPath => $composableBuilder(
    column: $table.attachmentPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  $$MataKuliahsTableOrderingComposer get mataKuliahId {
    final $$MataKuliahsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mataKuliahId,
      referencedTable: $db.mataKuliahs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MataKuliahsTableOrderingComposer(
            $db: $db,
            $table: $db.mataKuliahs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TugassTableAnnotationComposer
    extends Composer<_$AppDatabase, $TugassTable> {
  $$TugassTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get jenis =>
      $composableBuilder(column: $table.jenis, builder: (column) => column);

  GeneratedColumn<String> get deskripsi =>
      $composableBuilder(column: $table.deskripsi, builder: (column) => column);

  GeneratedColumn<DateTime> get tenggatWaktu => $composableBuilder(
    column: $table.tenggatWaktu,
    builder: (column) => column,
  );

  GeneratedColumn<String> get attachmentPath => $composableBuilder(
    column: $table.attachmentPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  $$MataKuliahsTableAnnotationComposer get mataKuliahId {
    final $$MataKuliahsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mataKuliahId,
      referencedTable: $db.mataKuliahs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MataKuliahsTableAnnotationComposer(
            $db: $db,
            $table: $db.mataKuliahs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TugassTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TugassTable,
          TugassData,
          $$TugassTableFilterComposer,
          $$TugassTableOrderingComposer,
          $$TugassTableAnnotationComposer,
          $$TugassTableCreateCompanionBuilder,
          $$TugassTableUpdateCompanionBuilder,
          (TugassData, $$TugassTableReferences),
          TugassData,
          PrefetchHooks Function({bool mataKuliahId})
        > {
  $$TugassTableTableManager(_$AppDatabase db, $TugassTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TugassTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TugassTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TugassTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> mataKuliahId = const Value.absent(),
                Value<String> jenis = const Value.absent(),
                Value<String> deskripsi = const Value.absent(),
                Value<DateTime> tenggatWaktu = const Value.absent(),
                Value<String?> attachmentPath = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TugassCompanion(
                id: id,
                mataKuliahId: mataKuliahId,
                jenis: jenis,
                deskripsi: deskripsi,
                tenggatWaktu: tenggatWaktu,
                attachmentPath: attachmentPath,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String mataKuliahId,
                required String jenis,
                required String deskripsi,
                required DateTime tenggatWaktu,
                Value<String?> attachmentPath = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TugassCompanion.insert(
                id: id,
                mataKuliahId: mataKuliahId,
                jenis: jenis,
                deskripsi: deskripsi,
                tenggatWaktu: tenggatWaktu,
                attachmentPath: attachmentPath,
                status: status,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TugassTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({mataKuliahId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (mataKuliahId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.mataKuliahId,
                                referencedTable: $$TugassTableReferences
                                    ._mataKuliahIdTable(db),
                                referencedColumn: $$TugassTableReferences
                                    ._mataKuliahIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TugassTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TugassTable,
      TugassData,
      $$TugassTableFilterComposer,
      $$TugassTableOrderingComposer,
      $$TugassTableAnnotationComposer,
      $$TugassTableCreateCompanionBuilder,
      $$TugassTableUpdateCompanionBuilder,
      (TugassData, $$TugassTableReferences),
      TugassData,
      PrefetchHooks Function({bool mataKuliahId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MataKuliahsTableTableManager get mataKuliahs =>
      $$MataKuliahsTableTableManager(_db, _db.mataKuliahs);
  $$JadwalsTableTableManager get jadwals =>
      $$JadwalsTableTableManager(_db, _db.jadwals);
  $$TugassTableTableManager get tugass =>
      $$TugassTableTableManager(_db, _db.tugass);
}
