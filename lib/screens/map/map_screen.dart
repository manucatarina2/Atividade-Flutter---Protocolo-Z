import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../models/shelter.dart';
import '../../models/horde_alert.dart';
import '../../state/shelter/shelter_provider.dart';
import '../../state/horde/horde_provider.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();
  LatLng _currentCenter = const LatLng(-23.5505, -46.6333);
  bool _loadingLocation = true;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _loadingLocation = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _loadingLocation = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _loadingLocation = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentCenter = LatLng(position.latitude, position.longitude);
        _loadingLocation = false;
      });
      _mapController.move(_currentCenter, 14.0);
    } catch (e) {
      setState(() => _loadingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sheltersAsync = ref.watch(sheltersProvider);
    final alertsAsync = ref.watch(activeAlertsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Sobrevivência'),
        actions: [
          IconButton(
            icon: const Icon(Icons.warning_amber_rounded,
                color: AppColors.danger),
            tooltip: 'Reportar Horda',
            onPressed: () => _showAlertDialog(_currentCenter),
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_loadingLocation)
            const Center(child: CircularProgressIndicator())
          else
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentCenter,
                initialZoom: 14.0,
                onTap: (tapPosition, point) {
                  _showCreateShelterDialog(point);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.protocoloz.app',
                ),
                if (sheltersAsync.hasValue)
                  MarkerLayer(
                    markers: sheltersAsync.value!.map((shelter) {
                      return Marker(
                        point: LatLng(shelter.latitude, shelter.longitude),
                        width: 40,
                        height: 40,
                        child: GestureDetector(
                          onTap: () => context.go('/abrigos/${shelter.id}'),
                          child: const Icon(
                            Icons.home,
                            color: AppColors.primary,
                            size: 36,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                if (alertsAsync.hasValue)
                  MarkerLayer(
                    markers: alertsAsync.value!.map((alert) {
                      return Marker(
                        point: LatLng(alert.latitude, alert.longitude),
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.warning,
                          color: AppColors.danger,
                          size: 36,
                        ),
                      );
                    }).toList(),
                  ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentCenter,
                      width: 20,
                      height: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              heroTag: 'gps_btn',
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.primary,
              onPressed: _getUserLocation,
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateShelterDialog(LatLng point) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    bool isPublic = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Novo Abrigo',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nome do Abrigo'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration:
                    const InputDecoration(labelText: 'Descrição (opcional)'),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Abrigo Público?'),
                subtitle: const Text('Se desligado, só sua facção poderá ver.'),
                value: isPublic,
                activeColor: AppColors.primary,
                onChanged: (val) => setModalState(() => isPublic = val),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isEmpty) return;
                  await ref.read(shelterRepositoryProvider).createShelter(
                        name: nameController.text,
                        description: descController.text,
                        latitude: point.latitude,
                        longitude: point.longitude,
                        visibility: isPublic ? 'public' : 'faction',
                      );
                  ref.invalidate(sheltersProvider);
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Cadastrar Abrigo'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showAlertDialog(LatLng point) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reportar Horda Aqui?'),
        content:
            const Text('Um alerta será emitido para todos os sobreviventes.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () async {
              await ref.read(hordeRepositoryProvider).createAlert(
                    latitude: point.latitude,
                    longitude: point.longitude,
                    intensity: 'alta',
                    description: 'Horda avistada!',
                  );
              ref.invalidate(activeAlertsProvider);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Reportar'),
          ),
        ],
      ),
    );
  }
}
