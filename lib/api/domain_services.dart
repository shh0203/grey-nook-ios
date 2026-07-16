import '../api/api_client.dart';

class Memory {
  final int id;
  final String title;
  final String memoryDate;
  final String? note;
  final String icon;
  Memory({required this.id, required this.title, required this.memoryDate, this.note, this.icon = 'star'});
  factory Memory.fromJson(Map<String, dynamic> j) => Memory(
        id: j['id'] as int,
        title: j['title'] as String,
        memoryDate: j['memory_date'] as String,
        note: j['note'] as String?,
        icon: (j['icon'] as String?) ?? 'star',
      );
}

class MemoriesService {
  MemoriesService(this.api);
  final ApiClient api;
  Future<List<Memory>> list() async {
    final r = await api.get('/api/memories');
    return (r as List).map((e) => Memory.fromJson(e as Map<String, dynamic>)).toList();
  }
  Future<Memory> add({required String title, required String date, String? note, String icon = 'star'}) async {
    final r = await api.post('/api/memories', {'title': title, 'memoryDate': date, 'note': note, 'icon': icon});
    return Memory.fromJson({...r as Map<String, dynamic>, 'title': title, 'memory_date': date, 'note': note, 'icon': icon});
  }
  Future<void> remove(int id) async => api.delete('/api/memories/$id');
}

class Mood {
  final int id;
  final int userId;
  final String mood;
  final String? note;
  final int createdAt;
  Mood({required this.id, required this.userId, required this.mood, this.note, required this.createdAt});
  factory Mood.fromJson(Map<String, dynamic> j) => Mood(
        id: j['id'] as int,
        userId: j['user_id'] as int,
        mood: j['mood'] as String,
        note: j['note'] as String?,
        createdAt: j['created_at'] as int,
      );
}

class MoodsService {
  MoodsService(this.api);
  final ApiClient api;
  Future<List<Mood>> list() async {
    final r = await api.get('/api/moods');
    return (r as List).map((e) => Mood.fromJson(e as Map<String, dynamic>)).toList();
  }
  Future<void> add({required String mood, String? note}) async {
    await api.post('/api/moods', {'mood': mood, 'note': note});
  }
}

class TaskItem {
  final int id;
  final String title;
  final bool done;
  final String? dueDate;
  TaskItem({required this.id, required this.title, required this.done, this.dueDate});
  factory TaskItem.fromJson(Map<String, dynamic> j) => TaskItem(
        id: j['id'] as int,
        title: j['title'] as String,
        done: (j['done'] as int) == 1,
        dueDate: j['due_date'] as String?,
      );
}

class TasksService {
  TasksService(this.api);
  final ApiClient api;
  Future<List<TaskItem>> list() async {
    final r = await api.get('/api/tasks');
    return (r as List).map((e) => TaskItem.fromJson(e as Map<String, dynamic>)).toList();
  }
  Future<void> add(String title, {String? dueDate}) async {
    await api.post('/api/tasks', {'title': title, 'dueDate': dueDate});
  }
  Future<void> toggle(int id) async => api.post('/api/tasks/$id/toggle');
  Future<void> remove(int id) async => api.delete('/api/tasks/$id');
}

class Letter {
  final int id;
  final int senderId;
  final String ciphertext;
  final int? unlockAt;
  final bool unlocked;
  Letter({required this.id, required this.senderId, required this.ciphertext, this.unlockAt, required this.unlocked});
  factory Letter.fromJson(Map<String, dynamic> j) => Letter(
        id: j['id'] as int,
        senderId: j['sender_id'] as int,
        ciphertext: j['ciphertext'] as String,
        unlockAt: j['unlock_at'] as int?,
        unlocked: (j['unlocked'] as int) == 1,
      );
}

class LettersService {
  LettersService(this.api);
  final ApiClient api;
  Future<List<Letter>> list() async {
    final r = await api.get('/api/letters');
    return (r as List).map((e) => Letter.fromJson(e as Map<String, dynamic>)).toList();
  }
  Future<void> add(String ciphertext, {int? unlockAt}) async {
    await api.post('/api/letters', {'ciphertext': ciphertext, 'unlockAt': unlockAt});
  }
  Future<void> open(int id) async => api.post('/api/letters/$id/open');
}

class Pet {
  final int coupleId;
  final String petName;
  final int hunger;
  final int mood;
  final int intimacy;
  final int? lastFed;
  final int? lastPlayed;
  final int updatedAt;
  Pet({
    required this.coupleId,
    required this.petName,
    required this.hunger,
    required this.mood,
    required this.intimacy,
    this.lastFed,
    this.lastPlayed,
    required this.updatedAt,
  });
  factory Pet.fromJson(Map<String, dynamic> j) => Pet(
        coupleId: j['couple_id'] as int,
        petName: (j['pet_name'] as String?) ?? 'Nook',
        hunger: (j['hunger'] as num).toInt(),
        mood: (j['mood'] as num).toInt(),
        intimacy: (j['intimacy'] as num).toInt(),
        lastFed: j['last_fed'] as int?,
        lastPlayed: j['last_played'] as int?,
        updatedAt: j['updated_at'] as int,
      );
}

class PetService {
  PetService(this.api);
  final ApiClient api;
  Future<Pet> get() async {
    final r = await api.get('/api/pet');
    return Pet.fromJson(r as Map<String, dynamic>);
  }
  Future<Pet> action(String a) async {
    final r = await api.post('/api/pet/action', {'action': a});
    return Pet.fromJson(r as Map<String, dynamic>);
  }
  Future<void> rename(String name) async {
    await api.post('/api/pet/name', {'name': name});
  }
}
