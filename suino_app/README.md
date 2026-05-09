# 🐷 Suíno App — Controle de Matrizes Suínas

Aplicativo mobile Flutter para **manejo reprodutivo de suínos**, focado em extrema simplicidade e usabilidade para trabalhadores rurais.

---

## 📱 O que o app faz

O usuário cadastra uma porca com a **data de cobertura** e o sistema calcula automaticamente:

| Evento | Cálculo |
|--------|---------|
| 💉 Medicação | Cobertura + **90 dias** |
| 🐷 Parto | Cobertura + **113 dias** |
| 📦 Apartação | Parto + **35 dias** |

As datas calculadas **podem ser editadas manualmente** e restauradas com um botão.

---

## 🚀 Como rodar

### Pré-requisitos

1. **Flutter SDK** ≥ 3.0.0 — [flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)
2. **Android Studio** ou **VS Code** com extensão Flutter
3. **Dispositivo Android** ou emulador (API 21+)

### Passos

```bash
# 1. Clone ou baixe o projeto
cd suino_app

# 2. Instale as dependências
flutter pub get

# 3. Gere os arquivos de localização
flutter gen-l10n  # se necessário

# 4. Execute no dispositivo
flutter run

# Para build de produção (APK)
flutter build apk --release
# O APK estará em: build/app/outputs/flutter-apk/app-release.apk
```

---

## 📦 Dependências principais

```yaml
# pubspec.yaml
sqflite: ^2.3.3          # Banco de dados SQLite local
provider: ^6.1.2          # Gerenciamento de estado
flutter_local_notifications: ^17.2.3  # Notificações offline
timezone: ^0.9.4          # Fuso horário para notificações
image_picker: ^1.1.2      # Câmera e galeria
permission_handler: ^11.3.1  # Permissões Android
intl: ^0.19.0             # Datas em PT-BR
flutter_localizations     # Localização (parte do SDK)
```

---

## 📁 Estrutura de arquivos

```
lib/
├── main.dart                          # Ponto de entrada
├── core/
│   ├── theme/
│   │   └── app_theme.dart             # Tema global (cores, fontes, botões)
│   └── utils/
│       └── date_utils.dart            # Formatação de datas PT-BR
├── data/
│   ├── database/
│   │   └── database_helper.dart       # Setup SQLite
│   ├── models/
│   │   └── porca_model.dart           # Modelo de dados + regras de negócio
│   └── repositories/
│       └── porca_repository.dart      # CRUD do banco de dados
├── presentation/
│   ├── providers/
│   │   └── porca_provider.dart        # Gerenciamento de estado
│   ├── screens/
│   │   ├── home/
│   │   │   └── home_screen.dart       # Tela inicial com lista
│   │   ├── porca_form/
│   │   │   └── porca_form_screen.dart # Cadastro e edição
│   │   └── porca_detail/
│   │       └── porca_detail_screen.dart # Detalhes e edição de datas
│   └── widgets/
│       ├── porca_card.dart            # Cartão da porca na lista
│       ├── data_field_widget.dart     # Campo de data editável
│       └── resumo_widget.dart         # Resumo de eventos próximos
└── services/
    └── notification_service.dart      # Notificações locais automáticas
```

---

## 🔔 Notificações

As notificações funcionam **100% offline** e disparam às **7h da manhã** do dia do evento:

- **2 dias antes do parto**: aviso antecipado
- **No dia do parto**: "Parto previsto hoje"
- **1 dia antes da medicação**: lembrete
- **No dia da medicação**: "Hora de medicar"
- **1 dia antes da apartação**: aviso
- **No dia da apartação**: "Hora da apartação"

---

## 🎨 Design

- ✅ Fontes grandes (17-22px no corpo)
- ✅ Botões grandes (mínimo 56px de altura)
- ✅ Alto contraste verde/branco
- ✅ Poucos elementos por tela
- ✅ Ícones emoji intuitivos
- ✅ Indicadores de cor: 🟢 normal · 🟡 próximo · 🔴 atrasado

---

## 📋 Regras de negócio

```dart
// Cálculo automático das datas
dataMedicacao = dataCobertura + 90 dias
dataParto     = dataCobertura + 113 dias
dataAparta    = dataParto     + 35 dias

// Edição manual:
// - Usuário edita → flag "editadaManual = true"
// - Sistema não recalcula automaticamente
// - Botão "Restaurar automático" disponível
// - Ao clicar: volta para o valor calculado
```

---

## 🔧 Permissões Android necessárias

| Permissão | Motivo |
|-----------|--------|
| `CAMERA` | Tirar foto da porca |
| `READ_MEDIA_IMAGES` | Escolher da galeria |
| `POST_NOTIFICATIONS` | Notificações (Android 13+) |
| `SCHEDULE_EXACT_ALARM` | Notificações em horário exato |
| `RECEIVE_BOOT_COMPLETED` | Reagendar após reiniciar o celular |

---

## 🔮 Possíveis expansões futuras

- [ ] Exportar relatório em PDF
- [ ] Múltiplos lotes / granjas
- [ ] Histórico de gestações por porca
- [ ] Backup em nuvem (Google Drive)
- [ ] Estatísticas e gráficos simples
- [ ] Widget na tela inicial do Android

---

## 📞 Suporte

Para dúvidas sobre uso ou configuração, verifique:
- `flutter doctor` para problemas de ambiente
- Versão mínima Android: **API 21 (Android 5.0)**
