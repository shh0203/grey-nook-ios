import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../api/domain_services.dart';
import '../../providers/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_typography.dart';

// Simple photo service using same api client
class PhotosService {
  PhotosService(this.api);
  final dynamic api;
  Future<List<Map<String, dynamic>>> list() async {
    final r = await api.get('/api/photos');
    return List<Map<String, dynamic>>.from(r as List);
  }
  Future<void> add(String url, {String? caption}) async {
    await api.post('/api/photos', {'url': url, 'caption': caption});
  }
}

class AlbumPage extends ConsumerStatefulWidget {
  const AlbumPage({super.key});
  @override
  ConsumerState<AlbumPage> createState() => _AlbumPageState();
}

class _AlbumPageState extends ConsumerState<AlbumPage> {
  late final PhotosService _svc = PhotosService(ref.read(apiClientProvider));
  Future<List<Map<String, dynamic>>>? _future;

  @override
  void initState() {
    super.initState();
    _future = _svc.list();
  }

  Future<void> _add() async {
    final url = TextEditingController();
    final cap = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cream,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('加一张', style: AppTypography.h2),
            const SizedBox(height: 12),
            TextField(controller: url, decoration: const InputDecoration(labelText: '图片 URL', border: OutlineInputBorder(), filled: true, fillColor: Colors.white)),
            const SizedBox(height: 8),
            TextField(controller: cap, decoration: const InputDecoration(labelText: '说点什么（可选）', border: OutlineInputBorder(), filled: true, fillColor: Colors.white)),
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.butterDeep, padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: () async {
                if (url.text.trim().isEmpty) return;
                await _svc.add(url.text.trim(), caption: cap.text.trim().isEmpty ? null : cap.text.trim());
                if (ctx.mounted) Navigator.pop(ctx);
                setState(() => _future = _svc.list());
              },
              child: Text('加进去', style: AppTypography.h3.copyWith(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(appAuthProvider).user;
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        title: const Text('相册', style: TextStyle(color: AppColors.brownDeep)),
        iconTheme: const IconThemeData(color: AppColors.brownDeep),
        actions: [IconButton(icon: const Icon(Icons.add, color: AppColors.brownDeep), onPressed: _add)],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (ctx, snap) {
          final list = snap.data ?? [];
          if (list.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text('还没有照片～把你们的回忆加上来', style: AppTypography.caption, textAlign: TextAlign.center),
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
            itemCount: list.length,
            itemBuilder: (ctx, i) {
              final p = list[i];
              final mine = p['uploader_id'] == me?.id;
              return ClipRRect(
                borderRadius: AppRadii.medium,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: p['url'] as String,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: AppColors.butter),
                      errorWidget: (_, __, ___) => Container(color: AppColors.butter, child: const Icon(Icons.broken_image)),
                    ),
                    if (mine)
                      const Positioned(top: 6, right: 6, child: Icon(Icons.favorite, color: Colors.white, size: 18)),
                    if (p['caption'] != null)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black54, Colors.transparent]),
                          ),
                          child: Text(p['caption'], style: const TextStyle(color: Colors.white, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
