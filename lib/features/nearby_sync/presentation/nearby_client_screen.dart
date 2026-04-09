import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:digipad_flutter/features/nearby_sync/cubit/nearby_client_cubit.dart';
import 'package:digipad_flutter/features/nearby_sync/cubit/nearby_client_state.dart';
import 'package:digipad_flutter/features/nearby_sync/debug_logger.dart';

/// CLIENT screen — discovers Totem devices and sends photos via Nearby.
class NearbyClientScreen extends StatefulWidget {
  const NearbyClientScreen({super.key});

  @override
  State<NearbyClientScreen> createState() => _NearbyClientScreenState();
}

class _NearbyClientScreenState extends State<NearbyClientScreen> {
  @override
  void initState() {
    super.initState();
    // Try auto-reconnect on open; falls back to discovery UI if not found
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NearbyClientCubit>().tryAutoReconnect();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: BlocBuilder<NearbyClientCubit, NearbyClientState>(
                    builder: (context, state) {
                      if (state is NearbyClientIdle) {
                        return _buildIdle(context);
                      } else if (state is NearbyClientDiscovering) {
                        return _buildDiscovering(context, state);
                      } else if (state is NearbyClientConnecting) {
                        return _buildConnecting(context);
                      } else if (state is NearbyClientConnected) {
                        return _buildConnected(context, state);
                      } else if (state is NearbyClientSendSuccess) {
                        return _buildSuccess(context, state);
                      } else if (state is NearbyClientError) {
                        return _buildError(context, state);
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                // Hard Reset Controls Persistent bar
                Container(
                  color: Colors.black26,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => context.read<NearbyClientCubit>().stopClient(),
                        icon: const Icon(Icons.stop_rounded, size: 16),
                        label: const Text('Detener (Hard Stop)', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.withOpacity(0.2),
                          foregroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => context.read<NearbyClientCubit>().restartClient(),
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: const Text('Reiniciar', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF).withOpacity(0.2),
                          foregroundColor: const Color(0xFF9D97FF),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const DebugConsoleToggle(),
          ],
        ),
      ),
    );
  }

  // ── Common top bar ─────────────────────────────────────────────────────────

  Widget _buildTopBar(BuildContext context, String title,
      {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded,
                color: Colors.white60, size: 20),
            onPressed: () {
              context.read<NearbyClientCubit>().reset();
              Navigator.of(context).pop();
            },
          ),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  // ── Idle ──────────────────────────────────────────────────────────────────

  Widget _buildIdle(BuildContext context) {
    return Column(
      children: [
        _buildTopBar(context, 'Sincronizar Fotos'),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: const Color(0xFF6C63FF).withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Icon(
                    Icons.sensors_rounded,
                    color: Color(0xFF9D97FF),
                    size: 52,
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Conectate al Tótem',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'El Tótem debe estar en la misma sala\ny con la app abierta en modo Tótem.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 36),
                _primaryButton(
                  icon: Icons.radar_rounded,
                  label: 'Buscar Tótem',
                  onTap: () =>
                      context.read<NearbyClientCubit>().startDiscovery(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Discovering ────────────────────────────────────────────────────────────

  Widget _buildDiscovering(
      BuildContext context, NearbyClientDiscovering state) {
    return Column(
      children: [
        _buildTopBar(
          context,
          'Buscando Tótem…',
          trailing: IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: Colors.white38, size: 22),
            onPressed: () =>
                context.read<NearbyClientCubit>().startDiscovery(),
          ),
        ),
        const SizedBox(height: 8),
        // Pulse animation
        _PulseIcon(active: true),
        const SizedBox(height: 24),
        if (state.foundEndpoints.isEmpty) ...[
          const Text(
            'Buscando dispositivos Tótem…',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'Asegurate de que el Tótem esté activo\ny con Bluetooth encendido',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38, fontSize: 13, height: 1.5),
          ),
        ] else ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Selecciona el Tótem al que conectarte:',
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: state.foundEndpoints.entries.map((e) {
                return _EndpointTile(
                  name: e.value,
                  onTap: () => context
                      .read<NearbyClientCubit>()
                      .connectToEndpoint(e.key),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  // ── Connecting ────────────────────────────────────────────────────────────

  Widget _buildConnecting(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor:
                  AlwaysStoppedAnimation<Color>(Color(0xFF5EFCE8)),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Conectando…',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Estableciendo conexión con el Tótem',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ── Connected ─────────────────────────────────────────────────────────────

  Widget _buildConnected(BuildContext context, NearbyClientConnected state) {
    return Column(
      children: [
        _buildTopBar(
          context,
          'Conectado',
          trailing: TextButton.icon(
            onPressed: () =>
                context.read<NearbyClientCubit>().forgetAndDisconnect(),
            icon: const Icon(Icons.link_off_rounded,
                color: Colors.white38, size: 18),
            label: const Text(
              'Desconectar',
              style: TextStyle(color: Colors.white38, fontSize: 13),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00BFA6).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFF00BFA6),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF00E676),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Conectado a ${state.endpointName}',
                        style: const TextStyle(
                          color: Color(0xFF5EFCE8),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Captured count
                if (state.sentCount > 0) ...[
                  Text(
                    '${state.sentCount} foto${state.sentCount == 1 ? '' : 's'} enviada${state.sentCount == 1 ? '' : 's'}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Capture button
                GestureDetector(
                  onTap: state.isSending
                      ? null
                      : () => context
                          .read<NearbyClientCubit>()
                          .captureAndSendPhoto(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: state.isSending
                            ? [Colors.grey.shade800, Colors.grey.shade700]
                            : [
                                const Color(0xFF6C63FF),
                                const Color(0xFF3F3D9E),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: state.isSending
                          ? []
                          : [
                              BoxShadow(
                                color: const Color(0xFF6C63FF)
                                    .withValues(alpha: 0.5),
                                blurRadius: 30,
                                spreadRadius: 4,
                              ),
                            ],
                    ),
                    child: state.isSending
                        ? const Center(
                            child: SizedBox(
                              width: 36,
                              height: 36,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 52,
                          ),
                  ),
                ),

                const SizedBox(height: 18),
                Text(
                  state.isSending ? 'Enviando…' : 'Toca para fotografiar',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Send success ─────────────────────────────────────────────────────────

  Widget _buildSuccess(BuildContext context, NearbyClientSendSuccess state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.5, end: 1.0),
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
            builder: (_, v, child) =>
                Transform.scale(scale: v, child: child),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF00BFA6).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Color(0xFF00E676),
                size: 60,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '¡Foto enviada! (${state.totalSent})',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Foto guardada en el Tótem',
            style: TextStyle(color: Colors.white54, fontSize: 15),
          ),
        ],
      ),
    );
  }

  // ── Error ─────────────────────────────────────────────────────────────────

  Widget _buildError(BuildContext context, NearbyClientError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.redAccent,
              size: 64,
            ),
            const SizedBox(height: 20),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 28),
            _primaryButton(
              icon: Icons.radar_rounded,
              label: 'Buscar Tótem',
              onTap: () =>
                  context.read<NearbyClientCubit>().startDiscovery(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _primaryButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 220,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 22),
        label: Text(
          label,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6C63FF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          shadowColor: const Color(0xFF6C63FF).withValues(alpha: 0.4),
        ),
      ),
    );
  }
}

// ── Pulse animation widget ─────────────────────────────────────────────────

class _PulseIcon extends StatefulWidget {
  final bool active;
  const _PulseIcon({required this.active});

  @override
  State<_PulseIcon> createState() => _PulseIconState();
}

class _PulseIconState extends State<_PulseIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _scale = Tween(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFF6C63FF).withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.4),
            width: 2,
          ),
        ),
        child: const Icon(
          Icons.radar_rounded,
          color: Color(0xFF9D97FF),
          size: 40,
        ),
      ),
    );
  }
}

// ── Endpoint tile ─────────────────────────────────────────────────────────

class _EndpointTile extends StatelessWidget {
  final String name;
  final VoidCallback onTap;

  const _EndpointTile({required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF6C63FF).withValues(alpha: 0.3)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.desktop_windows_rounded,
            color: Color(0xFF9D97FF),
            size: 24,
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: const Text(
          'Tocar para conectar',
          style: TextStyle(color: Colors.white38, fontSize: 12),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          color: Colors.white24,
          size: 16,
        ),
      ),
    );
  }
}
