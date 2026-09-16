import 'package:flutter/material.dart';
import 'package:malta_wash/Src/Features/public/presentation/pages/home_page.dart';

/// Entrada pública única da aplicação.
///
/// A HomePage já é responsiva e contém somente os dois acessos oficiais:
/// cliente e empresa. Manter uma única implementação evita divergência entre
/// desktop/mobile e impede que versões antigas voltem a exibir botões
/// duplicados.
class ResponsiveHomePage extends StatelessWidget {
  const ResponsiveHomePage({super.key});

  @override
  Widget build(BuildContext context) => const HomePage();
}
