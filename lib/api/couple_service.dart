import '../api/api_client.dart';

class CoupleInfo {
  final int id;
  final int userA;
  final int? userB;
  final String? inviteCode;
  final String? anniversaryDate;
  final String petName;
  final String? nameA;
  final String? nameB;
  CoupleInfo({
    required this.id,
    required this.userA,
    required this.userB,
    required this.inviteCode,
    required this.anniversaryDate,
    required this.petName,
    required this.nameA,
    required this.nameB,
  });
  factory CoupleInfo.fromJson(Map<String, dynamic> j) => CoupleInfo(
        id: j['id'] as int,
        userA: j['user_a'] as int,
        userB: j['user_b'] as int?,
        inviteCode: j['invite_code'] as String?,
        anniversaryDate: j['anniversary_date'] as String?,
        petName: (j['pet_name'] as String?) ?? 'Nook',
        nameA: j['name_a'] as String?,
        nameB: j['name_b'] as String?,
      );
  bool get isPaired => userB != null;
}

class CoupleService {
  CoupleService(this.api);
  final ApiClient api;

  Future<CoupleInfo?> me() async {
    final r = await api.get('/api/me');
    if (r == null) return null;
    final c = r['couple'];
    if (c == null) return null;
    return CoupleInfo.fromJson(c as Map<String, dynamic>);
  }

  Future<CoupleInfo> createInvite() async {
    final r = await api.post('/api/couple/invite');
    return (await me())!;
  }

  Future<CoupleInfo> joinInvite(String code) async {
    await api.post('/api/couple/join', {'inviteCode': code});
    return (await me())!;
  }

  Future<void> setAnniversary(String isoDate) async {
    await api.post('/api/couple/anniversary', {'date': isoDate});
  }
}
