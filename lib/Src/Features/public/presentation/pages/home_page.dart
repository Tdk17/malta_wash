import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:malta_wash/Src/Core/router/route_paths.dart';
import 'package:malta_wash/Src/Shared/widgets/brand_logo.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
              child: Row(children: [
                const BrandLogo(size: 44),
                const SizedBox(width: 12),
                const Expanded(child: Text('Clinicar', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800))),
                TextButton(onPressed: () => context.go(RoutePaths.login), child: const Text('Entrar')),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: () => context.go(RoutePaths.clientBooking), child: const Text('Agendar')),
              ]),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 56, 28, 80),
                child: Wrap(
                  spacing: 56,
                  runSpacing: 40,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: 560,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Seu carro cuidado nos mínimos detalhes.', style: TextStyle(color: Colors.white, fontSize: 54, fontWeight: FontWeight.w900, height: 1.05)),
                        const SizedBox(height: 22),
                        const Text('Agende sua lavagem, acompanhe o serviço, gerencie seus veículos e aproveite planos e benefícios em um só lugar.', style: TextStyle(color: Colors.white70, fontSize: 19, height: 1.5)),
                        const SizedBox(height: 30),
                        Wrap(spacing: 12, runSpacing: 12, children: [
                          ElevatedButton.icon(onPressed: () => context.go(RoutePaths.clientBooking), icon: const Icon(Icons.calendar_month), label: const Text('Agendar lavagem')),
                          OutlinedButton(onPressed: () => context.go(RoutePaths.register), style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white24), minimumSize: const Size(0, 48)), child: const Text('Criar conta')),
                        ]),
                        const SizedBox(height: 28),
                        const Text('Clinicar • powered by Malta Wash', style: TextStyle(color: Colors.white38)),
                      ]),
                    ),
                    Container(
                      width: 400,
                      padding: const EdgeInsets.all(36),
                      decoration: BoxDecoration(color: const Color(0xFF141A22), borderRadius: BorderRadius.circular(32), border: Border.all(color: Colors.white10)),
                      child: const Column(children: [
                        BrandLogo(size: 160),
                        SizedBox(height: 28),
                        Text('Lavagem automotiva com experiência digital.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                        SizedBox(height: 12),
                        Text('Escolha seu veículo, serviço, data e horário. O sistema consulta apenas horários realmente disponíveis.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white60, height: 1.5)),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
