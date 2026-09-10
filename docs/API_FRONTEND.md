# Malta Wash — integração Front-end ↔ Back4App

O Flutter mantém uma única fonte de rotas lógicas em `lib/Src/Core/http/endpoints.dart`. Essas rotas representam os contratos funcionais `/v1/...`; o transporte real é feito pelo `HttpManager`, que converte cada chamada para uma Cloud Function do Parse Server/Back4App.

Não há mocks de negócio. Sem API/sessão/permissão válida, as páginas exibem os estados reais de loading, empty, error e retry.

## Transporte Parse

Base:

```text
https://parseapi.back4app.com
```

Cloud Functions:

```text
POST /functions/<nome-da-funcao>
```

Headers usados pelo navegador:

```text
X-Parse-Application-Id: <PARSE_APPLICATION_ID>
X-Parse-Client-Key: <PARSE_CLIENT_KEY>
X-Parse-Session-Token: <token da sessão, somente após login>
```

`X-Parse-Session-Token` nunca é variável fixa de GitHub. `v1-auth-login` e `v1-auth-register` devolvem o token da sessão, que é salvo pelo front e enviado automaticamente nas Cloud Functions protegidas.

O Flutter Web não deve receber `Master Key`. O fluxo atual também não exige `PARSE_REST_API_KEY` no cliente.

## Normalização de resposta

O REST do Parse retorna Cloud Functions dentro de `result`. O backend Malta Wash usa o envelope interno:

```json
{
  "result": {
    "ok": true,
    "data": {},
    "correlationId": "req_..."
  }
}
```

ou, em falha de negócio:

```json
{
  "result": {
    "ok": false,
    "error": {
      "code": "...",
      "message": "...",
      "details": {},
      "correlationId": "req_..."
    }
  }
}
```

`HttpManager` remove o wrapper `result`, devolve `data` aos repositories e converte `error` em `ApiException`.

## Mapeamento principal

| Contrato lógico do front | Cloud Function Back4App |
| --- | --- |
| `POST /v1/auth/register` | `v1-auth-register` |
| `POST /v1/auth/login` | `v1-auth-login` |
| `POST /v1/auth/logout` | `v1-auth-logout` |
| `GET /v1/auth/me` | `v1-auth-me` |
| `POST /v1/auth/password-reset` | `v1-auth-password-reset` |
| `GET /v1/availability` | `v1-availability-list` |
| `GET /v1/dashboard/metrics` | `v1-dashboard-metrics` |
| `GET /v1/dashboard/operation` | `v1-dashboard-operation` |
| `GET /v1/reports/sales` | `v1-reports-sales` |
| `GET /v1/reports/services` | `v1-reports-services` |
| `GET /v1/reports/customers` | `v1-reports-customers` |
| `GET /v1/reports/occupancy` | `v1-reports-occupancy` |
| `GET /v1/reports/subscriptions` | `v1-reports-subscriptions` |
| `GET /v1/reports/team` | `v1-reports-team` |
| `GET/PATCH /v1/profile` | `v1-profile-get` / `v1-profile-update` |
| `GET/PATCH /v1/settings` | `v1-settings-get` / `v1-settings-update` |
| `POST /v1/coupons/validate` | `v1-coupons-validate` |
| `POST /v1/payments/intent` | `v1-payments-intent` |
| `POST /v1/reviews` | `v1-reviews-create` |
| `GET /v1/admin/reviews` | `v1-admin-reviews-list` |
| `POST /v1/uploads/presign` | `v1-uploads-presign` |

## CRUD convertido automaticamente

Para recursos CRUD, o `HttpManager` usa o método lógico para selecionar a função:

```text
GET    /v1/customers          -> v1-customers-list
GET    /v1/customers/:id      -> v1-customers-get       { id }
POST   /v1/customers          -> v1-customers-create
PATCH  /v1/customers/:id      -> v1-customers-update    { id, ...payload }
DELETE /v1/vehicles/:id       -> v1-vehicles-delete     { id }
```

O mesmo mecanismo cobre os prefixes disponibilizados pelo backend para `locations`, `customers`, `vehicles`, `services`, `service-addons`, `appointments`, `work-orders`, `plans`, `subscriptions`, `packages`, `coupons`, `payments`, `team`, `shifts`, `blocks`, `loyalty`, `tenants`, `marketing`, `support`, `feature-flags`, `audit-logs` e a camada SaaS.

Ações aninhadas preservam o `id` como parâmetro da Cloud Function:

```text
POST /v1/appointments/:id/cancel       -> v1-appointments-cancel
POST /v1/appointments/:id/reschedule   -> v1-appointments-reschedule
POST /v1/appointments/:id/check-in     -> v1-appointments-check-in
POST /v1/work-orders/:id/start         -> v1-work-orders-start
POST /v1/work-orders/:id/status        -> v1-work-orders-status
POST /v1/work-orders/:id/complete      -> v1-work-orders-complete
POST /v1/work-orders/:id/photos        -> v1-work-orders-photos
POST /v1/subscriptions/:id/cancel      -> v1-subscriptions-cancel
POST /v1/subscriptions/:id/pause       -> v1-subscriptions-pause
GET  /v1/subscriptions/:id/usage       -> v1-subscriptions-usage
POST /v1/packages/:id/purchase         -> v1-packages-purchase
POST /v1/payments/:id/refund           -> v1-payments-refund
PATCH /v1/notifications/:id/read       -> v1-notifications-read
GET  /v1/customers/:id/history         -> v1-customers-history
```

## Configuração local

Crie `config/local.json`; ele já está ignorado pelo Git:

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

## GitHub Pages

O build de produção lê Repository Variables do GitHub Actions:

```text
PARSE_SERVER_URL
PARSE_APPLICATION_ID
PARSE_CLIENT_KEY
```

Configuração: **Settings → Secrets and variables → Actions → Variables**.

O `PARSE_SERVER_URL` pode ficar como `https://parseapi.back4app.com`. Application ID e Client Key devem pertencer ao app Back4App do Malta Wash. O token de sessão é dinâmico e não deve ser cadastrado no GitHub.

## Segurança e multiempresa

Autorização, `tenant`, Membership/RBAC, preços, disponibilidade, benefícios e pagamentos continuam sob responsabilidade das Cloud Functions. O frontend não é fonte de autorização e não deve enviar credenciais administrativas do Parse.
