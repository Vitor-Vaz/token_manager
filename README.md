# Token Manager

Sistema de gerenciamento de tokens com controle de estados e histórico de auditoria.

## Índice

- [Como Rodar](#como-rodar)
- [Como Funciona](#como-funciona)
- [API Endpoints](#api-endpoints)
- [Testes](#testes)

---

## Como Rodar

### Pré-requisitos

- Elixir 1.15+
- Erlang/OTP 27+
- PostgreSQL
- Docker e Docker Compose (opcional)

### Setup com Docker

```bash
# Subir o banco de dados
docker-compose up -d

# Instalar dependências
mix deps.get

# Criar e migrar o banco de dados
mix ecto.setup

# Popular o banco com dados iniciais
mix run priv/repo/seeds.exs

# Rodar o servidor
mix phx.server
```

O servidor estará disponível em `http://localhost:4000`.

### Setup sem Docker

```bash
# Configurar PostgreSQL (ajuste config/dev.exs se necessário)
# Criar database: token_manager_dev

# Instalar dependências
mix deps.get

# Criar e migrar o banco de dados
mix ecto.setup

# Popular o banco com dados iniciais
mix run priv/repo/seeds.exs

# Rodar o servidor
mix phx.server
```

### Importar rotas no Insomnia

Importe o arquivo `export_routes.json` no Insomnia para testar todas as rotas da API.

---

## Como Funciona

### Visão Geral

O Token Manager é um sistema de gerenciamento de tokens que controla a atribuição de tokens a usuários com base em estados bem definidos. O sistema mantém um histórico completo de auditoria de todas as transições de estado.

### Estados dos Tokens

Os tokens podem estar em dois estados:

- **available** - Token disponível para ser atribuído
- **active** - Token atribuído a um usuário

### Fluxo de Estados

1. **Token Disponível**: Token criado ou liberado, aguardando atribuição
2. **Atribuição**: Quando um usuário solicita um token, o sistema:
   - Busca um token com status `available`
   - Atualiza o status para `active`
   - Associa ao `user_id`
   - Define data de expiração (`expires_at`) para 2 minutos à frente
   - Registra auditoria da operação

3. **Expiração Automática**: Um GenServer executa a cada 10 segundos:
   - Busca todos os tokens `active` com `expires_at` menor que o momento atual
   - Atualiza status para `expired`
   - Remove associação com usuário

4. **Limpeza Manual**: Endpoint `clear_all_tokens`:
   - Libera todos os tokens ativos/expirados
   - Retorna status para `available`
   - Remove associação com usuário

### Histórico de Auditoria

Todas as operações são registradas na tabela `token_audits`:
- Usuário que recebeu/liberou o token
- Timestamp da operação
- Permite rastreamento completo do histórico de cada token

### Funcionalidades

- Atribuição automática de tokens disponíveis
- Controle de expiração com data/hora
- Liberação automática de tokens expirados (a cada 10s)
- Limpeza manual de todos os tokens
- Histórico de auditoria completo
- Filtros avançados (status, user_id, expires_before)
- Informações detalhadas de tokens


## API Endpoints

### Tokens

#### Atribuir Token
```http
POST /api/assign_token/:user_id
```

#### Listar Tokens (com filtros)
```http
GET /api/tokens?status=active&user_id=1&expires_before=2025-12-31T23:59:59Z
```

#### Buscar Informações do Token
```http
GET /api/token/:token_id
```

#### Histórico de Auditoria
```http
GET /api/token_history/:token_id
```

#### Limpar Todos os Tokens
```http
PUT /api/clear_all_tokens
```

### Usuários

#### Listar Usuários
```http
GET /api/users/:limit
```

---

## Testes

### Rodar todos os testes
```bash
mix test
```

### Verificar cobertura
```bash
mix test --cover
```

### Linter e formatação
```bash
# Verificar formatação
mix format --check-formatted

# Formatar código
mix format

# Rodar Credo (análise estática)
mix credo --strict
```

### Scripts de Test

Execute o script de assignes test para validar performance:

```bash
# 10 usuários (padrão)
mix run priv/scripts/assignes_test.exs

# 100 usuários
mix run priv/scripts/assignes_test.exs 100

# 1000 usuários
mix run priv/scripts/assignes_test.exs 1000
```
