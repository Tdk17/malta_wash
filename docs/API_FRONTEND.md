# Malta Wash — contratos consumidos pelo front

O front usa uma única fonte de rotas em `lib/Src/Core/http/endpoints.dart`. Não há mocks de negócio: sem API disponível, as páginas exibem loading/empty/error/retry.

## Contratos BASE do documento funcional/técnico

- Auth: `POST /v1/auth/register`, `POST /v1/auth/login`, `POST /v1/auth/logout`, `GET /v1/auth/me`, `POST /v1/auth/password-reset`.
- Empresas/unidades: `/v1/tenants`, `/v1/locations`.
- Clientes/veículos: `/v1/customers`, `/v1/customers/:id/history`, `/v1/vehicles`.
- Catálogo: `/v1/services`, `/v1/service-addons`.
- Agenda: `GET /v1/availability`, `/v1/appointments` e ações `cancel`, `reschedule`, `check-in`.
- Operação: `/v1/work-orders` e ações `start`, `status`, `complete`, `photos`.
- Monetização: `/v1/plans`, `/v1/subscriptions`, `/v1/packages`, `/v1/coupons`, `/v1/payments/intent`, `/v1/payments/:id`, refund e webhook.
- Equipe: `/v1/team`, `/v1/shifts`, `/v1/blocks`.
- Dashboard/relatórios: `/v1/dashboard/metrics`, `/v1/dashboard/operation`, `/v1/reports/*`.
- Comunicação/qualidade: `/v1/notifications`, `/v1/notification-preferences`, `/v1/reviews`, `/v1/admin/reviews`.
- Upload: `POST /v1/uploads/presign`.

## Contratos PROPOSTOS PELO FRONT

As telas abaixo constam no escopo funcional, mas o documento-base não declarou uma rota mínima específica. O front usa estes nomes provisórios e o backend deve confirmá-los antes de produção:

- `GET /v1/payments` — histórico/financeiro.
- `GET/PATCH /v1/profile` — perfil do cliente.
- `GET/PATCH /v1/settings` — configurações administrativas.
- `GET /v1/support/faqs` e `GET/POST /v1/support/tickets` — suporte.
- `GET/POST /v1/marketing/segments` e `/v1/marketing/campaigns` — Marketing/CRM.
- `GET/POST /v1/loyalty` — fidelidade.
- `/v1/saas/plans`, `/v1/saas/billing`, `/v1/feature-flags`, `/v1/audit-logs` — Super Admin SaaS.

## Segurança e multiempresa

`userId` e `tenantId` devem vir da sessão/token. O front não é fonte de autorização. O backend precisa validar Membership/RBAC, isolamento de tenant, idempotência de operações críticas, payload, rate limit e correlationId.

## Execução local

```bash
flutter pub get
flutter run -d chrome --dart-define-from-file=config/dev.json
```

Troque `API_BASE_URL` nos arquivos de ambiente quando o backend estiver disponível. O detalhamento completo de request/response, regras e critérios de aceite está no documento `Especificacao_APIs_Malta_Wash.docx` entregue junto do projeto.
