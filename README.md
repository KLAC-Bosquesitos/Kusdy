# Kusdy

CRM móvil a medida para Energica Solar S.A., hecho en Flutter con Supabase como backend. Centraliza clientes, llamadas, citas, visitas, cotizaciones y seguimientos para que a los vendedores no se les pase nada.

## Documentación

| Archivo | Para qué sirve |
|---|---|
| [`CLAUDE.md`](CLAUDE.md) | Contexto completo: problema, usuario, alcance y decisiones técnicas. |
| [`kusdy/SPECS.md`](kusdy/SPECS.md) | Fase actual, tareas y registro de avance. |
| [`AGENTES.md`](AGENTES.md) | Reglas para los agentes de IA que trabajen en el proyecto. |

## Estructura

- `kusdy/`: proyecto Flutter de la aplicación.

## Cómo correr la app

```bash
cd kusdy
flutter pub get
flutter run
```

## Flujo de trabajo

Issue -> Rama -> Pull Request -> Revisión -> Merge. Nadie trabaja directamente sobre `main`.
