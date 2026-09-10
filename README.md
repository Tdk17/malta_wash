# Malta Wash — Gestão & Agendamento Automotivo

Front-end Flutter Web/PWA para gestão e agendamento de lavação automotiva. A primeira apresentação utiliza a identidade da Clinicar, mas o produto permanece preparado para multiempresa/white-label.

## Padrão do projeto

Mantém o mesmo padrão dos demais projetos: `lib/Src/App`, `lib/Src/Core`, `lib/Src/Features` e `lib/Src/Shared`. Cada feature relevante separa `data`, `domain` e `presentation`. DI com `get_it`, navegação com `go_router`, estado com `signals`, HTTP com `Dio` e endpoints centralizados.

## Execução local

```bash
flutter pub get
flutter run -d chrome --dart-define-from-file=config/dev.json
```

## GitHub Pages

O repositório possui deploy automático em `.github/workflows/deploy-pages.yml`.

A cada push na branch `main`, o workflow executa:

```bash
flutter pub get
flutter build web --release --base-href "/malta_wash/" --dart-define-from-file=config/prod.json
```

Depois publica `build/web` no GitHub Pages.

URL esperada após a primeira publicação:

`https://tdk17.github.io/malta_wash/`

No GitHub, em **Settings > Pages**, a origem deve estar configurada como **GitHub Actions**.

## API

O front não usa mocks de negócio. Sem backend disponível, as telas exibem estado de erro/indisponível e oferecem retry. Configure `API_BASE_URL` nos arquivos de ambiente. Antes de produção, substitua `https://api.example.com` em `config/prod.json` pela URL real da API.

## Branding

`assets/branding/clinicar_logo.png` é o fallback visual do primeiro cliente. A arquitetura permite substituir o branding a partir da resposta de `GET /v1/auth/me`/tenant sem escrever a marca do cliente diretamente nas páginas.
