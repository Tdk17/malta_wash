# Malta Wash — Auditoria funcional Front-end + API

Data: 11/09/2026

## Escopo auditado

- acesso público, login, cadastro de cliente e bloqueio de auto cadastro de empresa;
- área do cliente: início, veículos, agendamento, meus agendamentos, plano e perfil;
- área da empresa: dashboard, agendamentos, atendimentos, clientes, serviços, planos de fidelidade e configurações;
- integração Flutter Web -> Parse Server/Back4App via Cloud Functions;
- roteamento, contratos `/v1/...`, normalização de respostas e deploy GitHub Pages.

## Resultado geral

O front está estruturado para trabalhar sem mocks e converte os endpoints lógicos `/v1/...` para Cloud Functions `v1-*` no Back4App. O deploy valida a presença de `PARSE_APPLICATION_ID` e `PARSE_CLIENT_KEY` antes de publicar.

A compilação/deploy via GitHub Actions é o teste automatizado disponível no repositório. Teste E2E autenticado de produção depende de uma sessão real de usuário e de dados reais no Back4App; portanto não deve ser considerado validado apenas por inspeção de código.

## Correções aplicadas nesta auditoria

1. **Plano + Fidelidade unificados**
   - removida a opção separada `Fidelidade` do menu da empresa;
   - menu único: `Planos de fidelidade`;
   - rota antiga `/admin/fidelidade` redireciona para `/admin/planos`;
   - tela administrativa grava somente em `/v1/plans`;
   - área do cliente mostra apenas campos de negócio dos planos, sem IDs/timestamps.

2. **Auto cadastro de empresa bloqueado**
   - a rota antiga de cadastro de empresa redireciona para login de empresa;
   - cadastro público permanece apenas para cliente.

3. **Duplicidades operacionais removidas**
   - Agenda foi consolidada em Agendamentos;
   - Veículos da empresa foi consolidado em Clientes;
   - cliente + veículos ficam vinculados na mesma visão administrativa.

4. **Agendamento do cliente estabilizado**
   - normalização de múltiplos formatos de horário;
   - fallback de horários baseado na configuração real da empresa quando disponibilidade vier vazia;
   - confirmação navega para `Meus agendamentos`, sem modal que deixava tela branca.

5. **Meus agendamentos do cliente**
   - mostra somente data, horário e status;
   - não expõe ID, start/end bruto, payment, createdAt ou campos internos.

6. **Atendimentos da empresa**
   - cruza agendamento com clientes, veículos e serviços;
   - mostra cliente, modelo, placa, serviço e horário;
   - fluxo operacional: Agendado -> Chegou -> Lavando -> Pronto -> Finalizado.

## Contratos de API que precisam estar garantidos no Back4App

### 1. Disponibilidade

Cloud Function: `v1-availability-list`

Entrada esperada:

```json
{
  "locationId": "string opcional enquanto houver local padrão",
  "serviceId": "string",
  "vehicleId": "string",
  "date": "YYYY-MM-DD"
}
```

Resposta recomendada:

```json
{
  "ok": true,
  "data": {
    "slots": [
      {"startAt": "2026-09-11T08:00:00-03:00", "available": true},
      {"startAt": "2026-09-11T09:00:00-03:00", "available": true}
    ]
  }
}
```

A API deve calcular slots usando:
- horário de abertura/fechamento;
- dias de funcionamento;
- duração do serviço;
- bloqueios;
- agendamentos existentes;
- timezone da empresa.

**Problema observado anteriormente:** resposta vazia mesmo com agenda configurada. O front possui fallback, porém o backend deve ser a fonte definitiva da disponibilidade.

### 2. Agendamentos — listagem

Cloud Function: `v1-appointments-list`

Cada item deve retornar, no mínimo:

```json
{
  "id": "appointmentId",
  "customerId": "customerId",
  "vehicleId": "vehicleId",
  "serviceId": "serviceId",
  "startAt": "2026-09-11T14:00:00-03:00",
  "status": "CONFIRMED"
}
```

Recomendado retornar também objetos resumidos para evitar múltiplas consultas:

```json
{
  "customer": {"id": "...", "name": "Pedro", "email": "..."},
  "vehicle": {"id": "...", "model": "Corsa", "plate": "ABC1D23"},
  "service": {"id": "...", "name": "Lavagem completa"}
}
```

A listagem deve respeitar RBAC:
- cliente vê somente os próprios agendamentos;
- empresa vê somente os agendamentos da própria empresa/tenant.

### 3. Agendamentos — criação

Cloud Function: `v1-appointments-create`

Entrada:

```json
{
  "locationId": "string quando exigido pelo backend",
  "vehicleId": "string",
  "serviceId": "string",
  "startAt": "ISO-8601"
}
```

Resposta mínima:

```json
{
  "ok": true,
  "data": {
    "id": "appointmentId",
    "startAt": "ISO-8601",
    "status": "CONFIRMED"
  }
}
```

A criação precisa persistir corretamente os ponteiros/IDs de cliente, veículo, serviço e empresa para que Agendamentos e Atendimentos consigam resolver os dados.

### 4. Atualização de status operacional

O front atualmente usa:

```text
PATCH /v1/appointments/:id
-> v1-appointments-update
```

Payload:

```json
{"status":"CHECKED_IN"}
```

Estados utilizados:

```text
CONFIRMED
CHECKED_IN
IN_PROGRESS
READY
COMPLETED
```

O backend deve aceitar e validar essas transições. Se a regra de negócio exigir ações dedicadas, implementar funções específicas e ajustar o front:

```text
v1-appointments-check-in
v1-appointments-start
v1-appointments-ready
v1-appointments-complete
```

### 5. Configuração da agenda

Funções necessárias:

```text
v1-settings-get
v1-settings-update
v1-locations-list/create/update
v1-shifts-list/create/update
v1-blocks-list/create/delete
```

Campos usados pelo front:

```json
{
  "companyName": "Malta Wash",
  "email": "...",
  "phone": "...",
  "openingTime": "08:00",
  "closingTime": "18:00",
  "slotMinutes": 30,
  "workingDays": [1,2,3,4,5,6],
  "defaultLocationId": "..."
}
```

### 6. Clientes e veículos

Funções mínimas:

```text
v1-customers-list/get/update/delete
v1-vehicles-list/create/get/update/delete
```

`v1-vehicles-list` deve retornar `customerId`/`ownerId` ou objeto `customer` para permitir vínculo determinístico.

### 7. Serviços

Funções mínimas:

```text
v1-services-list/create/get/update/delete
```

Campos esperados:

```json
{
  "id": "...",
  "name": "Lavagem completa",
  "description": "...",
  "price": 80.0,
  "durationMinutes": 60,
  "active": true
}
```

### 8. Planos de fidelidade — contrato unificado

A interface passou a usar **somente `/v1/plans`**. A API `v1-loyalty-*` deve ser considerada legada para este produto.

Funções necessárias:

```text
v1-plans-list
v1-plans-create
v1-plans-get
v1-plans-update
v1-plans-delete
```

Payload atual do front:

```json
{
  "name": "Plano Premium",
  "description": "...",
  "price": 99.90,
  "billingCycle": "MONTHLY",
  "active": true,
  "paymentProvider": "MERCADO_PAGO",
  "benefits": "Lavagens e vantagens incluídas"
}
```

Para fidelidade mais avançada, preferir evoluir o mesmo recurso `plan`, por exemplo:

```json
{
  "loyalty": {
    "enabled": true,
    "pointsPerPurchase": 1,
    "reward": "1 lavagem após 10 usos"
  }
}
```

Não criar novamente uma tela/recurso separado de fidelidade.

### 9. Assinaturas

Funções necessárias para o cliente:

```text
v1-subscriptions-list
v1-subscriptions-create
v1-subscriptions-get
v1-subscriptions-cancel
v1-subscriptions-pause
v1-subscriptions-usage
```

A assinatura deve retornar somente dados de negócio necessários ao cliente, como `planName`, `status`, `price`, `nextBillingAt` e benefícios.

### 10. Perfil

Funções obrigatórias:

```text
v1-profile-get
v1-profile-update
```

O retorno não deve obrigar o front a mostrar campos técnicos. Campos recomendados: `name`, `email`, `phone`.

## Integração Parse / segurança

O front usa:

```text
POST https://parseapi.back4app.com/functions/<function>
X-Parse-Application-Id
X-Parse-Client-Key
X-Parse-Session-Token (rotas autenticadas)
```

Não usar Master Key ou REST API Key no Flutter Web.

## Validação necessária no backend antes do piloto

Executar com uma conta real de cliente e uma conta real de empresa:

1. login cliente;
2. cadastrar veículo;
3. listar serviços;
4. consultar disponibilidade;
5. criar agendamento;
6. confirmar que o agendamento aparece em `Meus agendamentos`;
7. login empresa;
8. confirmar que o mesmo agendamento aparece em `Agendamentos`;
9. confirmar cliente, veículo, placa e serviço;
10. avançar status até `COMPLETED`;
11. confirmar mudança refletida para o cliente;
12. criar plano de fidelidade;
13. listar plano no cliente;
14. validar criação/consulta de assinatura quando o backend de pagamento estiver disponível.

## Pendências de backend classificadas

### Bloqueantes

- `v1-availability-list` precisa devolver slots confiáveis sem depender do fallback do front.
- `v1-appointments-create` precisa persistir relações cliente/veículo/serviço corretamente.
- `v1-appointments-list` precisa devolver os relacionamentos ou IDs suficientes para resolução.
- `v1-appointments-update` precisa aceitar transições operacionais ou ser substituído por ações específicas.

### Importantes

- consolidar fidelidade dentro de `v1-plans`;
- garantir `v1-profile-get/update`;
- garantir `v1-settings-*`, `v1-locations-*` e `v1-shifts-*` com os campos descritos;
- normalizar timezone e ISO-8601 em todas as datas.

### Não bloqueantes para MVP

- Mercado Pago recorrente completo;
- relatórios avançados;
- notificações push/WhatsApp;
- feature flags/SaaS avançado.

## Critério de pronto

O MVP pode ser considerado pronto para piloto quando:

- build/deploy passa;
- login funciona nos dois perfis;
- cliente cadastra veículo e agenda;
- horários vêm do backend corretamente;
- empresa vê o agendamento com cliente/veículo/placa/serviço;
- fluxo operacional avança até finalizado;
- cliente vê data/horário/status atualizados;
- serviços e planos de fidelidade são CRUD reais;
- nenhuma tela principal depende de mock ou mostra campos técnicos do banco.
