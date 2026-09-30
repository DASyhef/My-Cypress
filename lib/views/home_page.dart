import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      theme.scaffoldBackgroundColor,
                      BlendMode.multiply,
                    ),
                    child: Image.asset(
                      'assets/images/Logo.png',
                      width: 80,
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My-Cypress',
                          style: theme.textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Avant que la mort vous la mette dans le cul',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Text(
                'Consignez vos volontés personnelles en toute sérénité.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Au-delà des aspects juridiques et successoraux gérés par le notaire, '
                'My-Cypress vous permet de consigner vos choix intimes : messages à vos proches, '
                'souhaits pour vos animaux de compagnie, musique ou déroulement de la cérémonie, '
                'transmission de vos comptes ou souvenirs numériques.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}