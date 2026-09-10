# Malta Wash — Gestão & Agendamento Automotivo

Front-end Flutter Web/PWA para gestão e agendamento de lavação automotiva. A primeira implantação visual utiliza a identidade da Clinicar, mantendo o produto preparado para multiempresa/white-label.

## Padrão do projeto

A estrutura segue o mesmo padrão técnico dos demais projetos: `lib/Src/App`, `lib/Src/Core`, `lib/Src/Features` e `lib/Src/Shared`. As features relevantes separam `data`, `domain` e `presentation`. DI com `get_it`, navegação com `go_router`, estado com `signals`, HTTP com `Dio` e sessão persistida com `flutter_secure_storage`.

## Back4App / Parse Server

O front está conectado ao padrão Parse/Back4App:

- Parse API Address: `https://parseapi.back4app.com`
- Cloud Functions: `POST /functions/<nome-da-funcao>`
- `X-Parse-Application-Id`: configurado no build
- `X-Parse-Client-Key`: configurado no build
- `X-Parse-Session-Token`: obtido no login e enviado automaticamente nas operações autenticadas

As rotas lógicas `/v1/...` permanecem centralizadas em `lib/Src/Core/http/endpoints.dart`, mas `HttpManager` converte essas rotas para as Cloud Functions existentes do Malta Wash. Assim, widgets e repositories não precisam conhecer URLs do Parse.

Exemplos:

```text
POST /v1/auth/login       -> POST /functions/v1-auth-login
GET  /v1/customers        -> POST /functions/v1-customers-list
POST /v1/customers        -> POST /functions/v1-customers-create
GET  /v1/availability     -> POST /functions/v1-availability-list
POST /v1/appointments     -> POST /functions/v1-appointments-create
GET  /v1/dashboard/metrics -> POST /functions/v1-dashboard-metrics
```

O frontend também normaliza a resposta padrão do Parse (`result`) e o envelope do backend Malta Wash (`ok`, `data`, `error`, `correlationId`).

## Configuração local

`config/local.json` está ignorado pelo Git. Crie esse arquivo apenas na sua máquina:

```json
{
  "APP_ENV": "development",
  "PARSE_SERVER_URL": "https://parseapi.back4app.com",
  "PARSE_APPLICATION_ID": "SEU_APPLICATION_ID",
  "PARSE_CLIENT_KEY": "SUA_CLIENT_KEY"
}
```

Execute:

```bash
flutter pub get
flutter run -d chrome --dart-define-from-file=config/local.json
```

Não coloque `Master Key` no Flutter. O projeto também não depende de `PARSE_REST_API_KEY` no navegador.

## GitHub Pages

O workflow `.github/workflows/deploy-pages.yml` gera e publica o Flutter Web automaticamente a cada `push` na `main`.

No repositório, configure em **Settings → Secrets and variables → Actions → Variables**:

```text
PARSE_SERVER_URL=https://parseapi.back4app.com
PARSE_APPLICATION_ID=<Application ID do app Malta Wash>
PARSE_CLIENT_KEY=<Client Key do app Malta Wash>
```

`PARSE_SERVER_URL` é opcional porque o workflow já usa o endereço padrão do Back4App quando a variável estiver vazia. `PARSE_APPLICATION_ID` e `PARSE_CLIENT_KEY` são obrigatórios para o deploy.

Não crie variável `PARSE_SESSION_TOKEN`: cada usuário recebe seu próprio token durante o login.

Para o Pages, use **Settings → Pages → Build and deployment → Source → GitHub Actions**.

## Branding

`assets/branding/clinicar_logo.png` é o fallback visual da primeira implantação. A arquitetura permite carregar nome, logo e cores pelo tenant retornado em `v1-auth-me`, sem fixar a marca do cliente nos módulos de negócio.
