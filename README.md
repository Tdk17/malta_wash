# Malta Wash — Gestão & Agendamento Automotivo

Front-end Flutter Web/PWA para gestão e agendamento de lavação automotiva. A primeira apresentação utiliza a identidade da Clinicar, mas o produto permanece preparado para multiempresa/white-label.

## Padrão do projeto

Mantém o mesmo padrão dos demais projetos: `lib/Src/App`, `lib/Src/Core`, `lib/Src/Features` e `lib/Src/Shared`. Cada feature relevante separa `data`, `domain` e `presentation`. DI com `get_it`, navegação com `go_router`, estado com `signals`, HTTP com `Dio` e endpoints centralizados.

## Execução

```bash
flutter pub get
flutter run -d chrome --dart-define-from-file=config/dev.json
```

## API

O front não usa mocks de negócio. Sem backend disponível, as telas exibem estado de erro/indisponível e oferecem retry. Configure `API_BASE_URL` nos arquivos de ambiente.

## Branding

`assets/branding/clinicar_logo.png` é o fallback visual do primeiro cliente. A arquitetura permite substituir o branding a partir da resposta de `GET /v1/auth/me`/tenant sem escrever a marca do cliente diretamente nas páginas.
