# Malta Wash — agendamento sem veículo e pagamento presencial

## Regra do MVP

Cliente autenticado escolhe serviço, data e horário, e confirma. O cadastro de veículo não faz parte do fluxo. O backend identifica o cliente pela sessão; nome e telefone não são aceitos do payload como identidade do cliente.

Novos agendamentos usam `status=CONFIRMED`, `paymentMode=ON_SITE` e `vehicle=null`. Não há cobrança automática. O painel mostra nome, telefone, serviço, data/hora reservada, data/hora de criação do agendamento e status.

Fluxo operacional: `CONFIRMED → CHECKED_IN → IN_PROGRESS → READY → COMPLETED`.

Registros antigos em `PENDING_PAYMENT` podem fazer check-in presencial. Isso não marca um Payment como pago. Os endpoints de avanço e de criação/check-in de OS toleram ausência de veículo. Registros e vínculos antigos de veículos não são apagados.

`v1-payments-intent` rejeita cobrança vinculada a agendamento avulso. O webhook financeiro não altera o status do agendamento. Planos/fidelidade permanecem em módulo separado; esta entrega não ativa cobrança recorrente.

## Contrato

- `v1-availability-list`: `locationId`, `serviceId`, `date` (YYYY-MM-DD), sem `vehicleId`.
- `v1-appointments-create`: `locationId`, `serviceId`, `startAt` (ISO com fuso); `customerId` somente quando um funcionário agenda em nome do cliente.
- Respostas incluem `customerId`, `customerName`, `customerPhone`, `serviceName`, `startAt`, `createdAt`, `status`, `paymentMode` e demais campos existentes. Nome/telefone/serviço são snapshots obtidos pelo servidor para novos registros; a interface também resolve os vínculos antigos.
- `v1-appointments-advance`: `id`, `status` correspondente à próxima etapa, sem campos de pagamento.
- Cliente continua restrito aos próprios agendamentos; equipe continua sujeita às permissões do tenant.

## Arquivos para atualizar no Back4App

No repositório `Tdk17/Malta_washBanco`, substituir estes quatro arquivos, mantendo a estrutura:

1. `cloud/features/appointments.js`
2. `cloud/features/appointment-flow.js`
3. `cloud/features/work-orders.js`
4. `cloud/features/payments.js`

`cloud/main.js` já registra esses módulos e não precisa mudar nesta entrega. Os testes e o workflow são para GitHub; não precisam ser enviados ao Cloud Code. Commit no GitHub não comprova publicação no Back4App. Publicar o Cloud Code antes de validar o novo front em produção.

## Correções vinculadas à revisão

- Menus e telas ativas deixam de solicitar/listar veículos.
- Agendamentos cancelados não aparecem como confirmados no quadro operacional.
- Horários disponíveis vêm da API; o front não cria horários quando a resposta é vazia ou falha.
- Horários passados são indisponíveis na consulta; reagendamento administrativo envia data com fuso UTC explícito.

## Validação e limites

`node --test tests/appointments-mvp.test.js`: 9 testes com adaptador Parse em memória, cobrindo criação sem veículo, fluxo completo, legado, permissões/isolamento, cancelamento, disponibilidade e separação dos pagamentos. Não substituem teste contra o Back4App publicado.

O frontend tem testes de controller e widget, executados pelo workflow antes de compilar/publicar. Esta entrega não implementa push, lembretes nem confirmação de presença pelo cliente; esses pontos continuam pendentes da revisão. Também não afirma uma auditoria completa de todos os módulos.

## Página inicial: de seis acessos para dois

Arquivo: `lib/Src/Features/public/presentation/pages/home_page.dart`.

- Removidos os dois acessos da barra superior; o cabeçalho fica com logo e nome.
- Removida a seção inferior de cartões Cliente/Empresa, incluindo os componentes que ficaram sem uso.
- Mantidos somente os dois botões abaixo da apresentação principal: **Entrar como cliente** e **Entrar como empresa**.
- Destinos preservados: `/login?area=cliente` e `/login?area=empresa`.
- A página mobile ativa, em `responsive_home_page.dart`, já apresenta apenas esses dois acessos e não precisou mudar.

## Detalhamento do Cloud Code

| Arquivo | Alterações |
|---|---|
| `cloud/features/appointments.js` | Remove consulta e exigência de Vehicle na criação. Identifica Customer pela sessão (ou customerId validado para funcionário). Grava snapshots de nome/telefone/serviço. Força CONFIRMED/ON_SITE mesmo se um front antigo enviar ONLINE. Retorna os novos campos nas respostas. Check-in cria OS com vehicle=null. Disponibilidade deixa horários passados indisponíveis. |
| `cloud/features/appointment-flow.js` | Remove erro APPOINTMENT_PAYMENT_REQUIRED. Permite check-in de legado PENDING_PAYMENT, mudando somente paymentMode operacional para ON_SITE. Mantém validação das etapas, permissões, sincronização da OS e liberação de reserva ao concluir. Criação da OS tolera vehicle=null. |
| `cloud/features/work-orders.js` | Criação direta da OS tolera ausência de veículo do agendamento; usa null em vez de undefined. |
| `cloud/features/payments.js` | Bloqueia intenção de cobrança para appointmentId com APPOINTMENT_PAYMENT_ON_SITE antes de chamar provedor. Retira associação de novos pagamentos a Appointment. Webhook atualiza somente o financeiro e não confirma/reabre atendimento. |

## Campos no banco

| Classe/campo | Tipo | Comportamento |
|---|---|---|
| `Appointment.customerName` | String | Novo snapshot do nome cadastrado em Customer. |
| `Appointment.customerPhone` | String | Novo snapshot do telefone cadastrado em Customer. |
| `Appointment.serviceName` | String | Novo snapshot do nome de Service. |
| `Appointment.vehicle` | Pointer → Vehicle, opcional | Novos agendamentos gravam null. Não excluir vínculos antigos. |
| `WorkOrder.vehicle` | Pointer → Vehicle, opcional | Não pode ser obrigatório. Aceita null. |
| `Appointment.paymentMode` | String existente | ON_SITE em novos agendamentos. |
| `Appointment.status` | String existente | CONFIRMED na criação, sem PENDING_PAYMENT novo. |
| `Appointment.createdAt` | Date do Parse | Usado para exibir quando a reserva foi criada. Não criar outro campo de data para isso. |

Não há migração destrutiva nem exclusão de classes, clientes, veículos ou pagamentos. Se a criação de campos estiver restringida no seu app, cadastre as três Strings antes de publicar. Confirme que nenhuma validação externa ao Cloud Code exige vehicle.

## Arquivos alterados no front

Os caminhos abaixo são relativos à raiz de `Tdk17/malta_wash`.

| Arquivo | Alteração |
|---|---|
| `lib/Src/Features/booking/presentation/controllers/booking_controller.dart` | Remove dependência e consulta ao repositório de veículos; payload sem vehicleId; consulta de horários somente à API. |
| `lib/Src/Features/booking/domain/booking_repository.dart` | Retira vehicleId do contrato de disponibilidade. |
| `lib/Src/Features/booking/data/remote_booking_repository.dart` | Retira vehicleId da requisição. |
| `lib/Src/Features/booking/presentation/pages/booking_page_v2.dart` | Tela ativa passa a Serviço → Horário → Confirmar; resumo sem veículo e com pagamento no local. |
| `lib/Src/Features/booking/presentation/pages/booking_page.dart` | Tela anterior alinhada ao mesmo contrato, para continuar compilando corretamente. |
| `lib/Src/Core/di/service_locator.dart` | Ajusta a criação do BookingController sem VehiclesRepository. |
| `lib/Src/Core/router/app_router.dart` | Antigo endereço de veículos do cliente redireciona para o início do cliente. |
| `lib/Src/Shared/layouts/app_shell.dart` | Remove item Meus veículos do menu do cliente. |
| `lib/Src/Features/client_home/presentation/pages/client_home_page.dart` | Textos orientam serviço, data e horário, sem cadastrar veículo. |
| `lib/Src/Features/operation/presentation/pages/admin_schedule_page.dart` | Remove consulta e exibição de veículos; mostra telefone, data da reserva e data da criação; busca por cliente/telefone/serviço. |
| `lib/Src/Features/operation/presentation/pages/operation_board_page.dart` | Remove consulta e cartões de veículo/placa; mostra contato, data/hora e serviço; cancelados não voltam à coluna de agendados. |
| `lib/Src/Features/operation/presentation/pages/admin_directory_page.dart` | Clientes passa a exibir telefone no lugar de veículo, sem consultar a API de veículos. |
| `lib/Src/Features/public/presentation/pages/home_page.dart` | Remove os quatro acessos repetidos da página inicial. |
| `.github/workflows/deploy-pages.yml` | Executa testes antes do build e da publicação. |

Acrescentados: `test/booking_controller_test.dart` e `test/booking_page_test.dart`. No backend: `tests/appointments-mvp.test.js` e `.github/workflows/test.yml`. Este relatório também foi acrescentado aos dois repositórios.

## Ordem de publicação e conferência manual

1. Atualizar os quatro arquivos de Cloud Code listados acima, a partir da main do backend, e publicar no Back4App.
2. Conferir o build/deploy do front na main.
3. Com cliente sem veículo, reservar um serviço em um horário livre.
4. Conferir nome, telefone, serviço, datas e status na empresa.
5. Avançar chegada → lavagem → pronto → finalizado, sem criar cobrança.
6. Conferir cancelamento e liberação do horário; nenhum agendamento cancelado deve aparecer como confirmado.
7. Conferir que a home tem somente dois botões de entrada.

Push/notificações e confirmação de presença pelo cliente ainda precisam de implementação/validação própria. Publicação e teste com dados reais do Back4App permanecem a cargo do responsável pelo ambiente nesta entrega.
