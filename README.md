# EBooksStore — Infraestrutura

Plataforma de e-commerce de livros físicos e digitais para o mercado moçambicano.  
Arquitectura de microserviços com Docker Compose (dev) e Kubernetes (produção).

---

## Pré-requisitos

| Ferramenta | Versão mínima |
|---|---|
| Docker + Docker Compose | 24+ |
| Git | 2.40+ |
| (opcional) kubectl | 1.28+ — só para deploy K8s |

---

## Estrutura de repositórios

```
workspace-ebooks/
├── ebooks-infra/              ← este repositório (infra + scripts)
├── ebooks-api-gateway/        ← Spring Cloud Gateway  :8080
├── ebooks-auth-service/       ← Spring Boot           :8081
├── ebooks-catalog-service/    ← Spring Boot           :8082
├── ebooks-commerce-service/   ← Spring Boot           :8083
├── ebooks-reading-service/    ← NestJS                :3001
├── ebooks-notification-service/ ← NestJS              :3002
├── ebooks-social-service/     ← NestJS                :3003
├── ebooks-media-service/      ← NestJS                :3004
├── ebooks-partner-service/    ← NestJS                :3005
├── ebooks-delivery-service/   ← NestJS                :3006
├── ebooks-analytics-service/  ← NestJS                :3007
└── ebooks-web/                ← Next.js 16            :3000
```

---

## Setup inicial (primeira vez)

### 1. Clonar todos os repositórios

```bash
git clone git@github.com:devmacuacua/ebooks-infra.git
git clone git@github.com:devmacuacua/ebooks-api-gateway.git
git clone git@github.com:devmacuacua/ebooks-auth-service.git
git clone git@github.com:devmacuacua/ebooks-catalog-service.git
git clone git@github.com:devmacuacua/ebooks-commerce-service.git
git clone git@github.com:devmacuacua/ebooks-reading-service.git
git clone git@github.com:devmacuacua/ebooks-notification-service.git
git clone git@github.com:devmacuacua/ebooks-social-service.git
git clone git@github.com:devmacuacua/ebooks-media-service.git
git clone git@github.com:devmacuacua/ebooks-partner-service.git
git clone git@github.com:devmacuacua/ebooks-delivery-service.git
git clone git@github.com:devmacuacua/ebooks-analytics-service.git
git clone git@github.com:devmacuacua/ebooks-web.git
```

### 2. Criar o ficheiro de ambiente

```bash
cd ebooks-infra/docker
cp .env.example .env
```

Editar o `.env` e preencher as integrações externas:

| Variável | Onde obter | Necessária para |
|---|---|---|
| `SMTP_USER` / `SMTP_PASS` | [mailtrap.io](https://mailtrap.io) (gratuito) | Emails de verificação e reset |
| `NEXT_PUBLIC_FIREBASE_*` | [console.firebase.google.com](https://console.firebase.google.com) | Notificações push |
| `STRIPE_SECRET_KEY` + `NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY` | [dashboard.stripe.com/test](https://dashboard.stripe.com/test/apikeys) | Pagamento por cartão |
| `MPESA_API_KEY` / `MPESA_PUBLIC_KEY` | Portal M-Pesa Business | Pagamento M-Pesa |

> As restantes variáveis já têm valores de desenvolvimento prontos a usar.

### 3. Levantar os serviços

```bash
cd ebooks-infra/scripts
./start.sh --build
```

Na primeira execução o Docker vai compilar todas as imagens (~5–10 min).  
As execuções seguintes arrancam em segundos.

### 4. Popular com dados de teste

```bash
./seed.sh
```

---

## Comandos do dia-a-dia

Todos os scripts estão em `ebooks-infra/scripts/`.

```bash
# Levantar
./start.sh                        # arrancar (sem rebuild)
./start.sh --build                # rebuild + arrancar
./start.sh --with-observability   # + Grafana / Prometheus

# Parar
./stop.sh                         # parar todos os containers

# Saúde
./health.sh                       # verificar se todos os serviços respondem

# Logs
./logs.sh                         # logs de todos os serviços (tail -f)
./logs.sh ebooks-auth-service     # logs de um serviço específico

# Dados de teste
./seed.sh                         # inserir dados fictícios (idempotente)
./seed.sh --reset                 # apagar dados de seed e reinserir

# Base de dados
./backup-db.sh                    # backup de todas as BDs para backups/
./restore-db.sh backups/2025.sql  # restaurar um backup
```

---

## URLs de desenvolvimento

| Serviço | URL | Notas |
|---|---|---|
| **Frontend** | http://localhost:3000 | Next.js |
| **API Gateway** | http://localhost:8080 | Ponto de entrada de todas as APIs |
| **Auth Service** | http://localhost:8081 | Swagger: `/swagger-ui.html` |
| **Catalog Service** | http://localhost:8082 | Swagger: `/swagger-ui.html` |
| **Commerce Service** | http://localhost:8083 | Swagger: `/swagger-ui.html` |
| **Reading Service** | http://localhost:3001 | |
| **Notification Service** | http://localhost:3002 | |
| **Media Service** | http://localhost:3004 | |
| **Partner Service** | http://localhost:3005 | |
| **RabbitMQ UI** | http://localhost:15672 | `ebooks` / `ebooks_secret` |
| **MinIO Console** | http://localhost:9001 | `ebooks_admin` / `ebooks_secret_123` |

---

## Contas de teste

Criadas pelo `seed.sh`:

| Email | Senha | Perfil |
|---|---|---|
| admin@ebooks.co.mz | `Admin@1234` | Administrador |
| francisco@ebooks.co.mz | `Test@1234` | Cliente com subscrição activa |
| maria@ebooks.co.mz | `Test@1234` | Cliente com encomenda |
| joao@ebooks.co.mz | `Test@1234` | Cliente |
| editora@ndzidzi.co.mz | `Test@1234` | Parceiro ACTIVE |

Catálogo de seed: 5 autores moçambicanos · 6 categorias · 7 livros publicados · 1 em revisão · 1 rejeitado.

---

## Arquitectura

```
                    ┌─────────────────────────────────┐
  Browser / App ───▶│   API Gateway  :8080            │
                    │   (Spring Cloud Gateway)        │
                    └──────────────┬──────────────────┘
                                   │ roteia por path
          ┌────────────────────────┼──────────────────┐
          │                        │                  │
   ┌──────▼──────┐   ┌─────────────▼──────┐   ┌──────▼──────┐
   │ Auth :8081  │   │  Catalog  :8082    │   │Commerce:8083│
   │ Spring Boot │   │  Spring Boot       │   │Spring Boot  │
   └─────────────┘   └────────────────────┘   └─────────────┘

   ┌─────────────┐   ┌────────────────────┐   ┌─────────────┐
   │Reading :3001│   │Notification :3002  │   │ Media :3004 │
   │  NestJS     │   │    NestJS          │   │  NestJS     │
   └─────────────┘   └────────────────────┘   └─────────────┘

   ┌─────────────┐   ┌────────────────────┐   ┌─────────────┐
   │Partner :3005│   │ Delivery  :3006    │   │Analytics:3007│
   │  NestJS     │   │    NestJS          │   │  NestJS     │
   └─────────────┘   └────────────────────┘   └─────────────┘

   ─────────── Mensageria assíncrona (RabbitMQ :5672) ───────────

   ┌──────────┐  ┌──────────┐  ┌───────────────┐  ┌──────────┐
   │PostgreSQL│  │  Redis   │  │Elasticsearch  │  │  MinIO   │
   │  :5432   │  │  :6379   │  │    :9200      │  │  :9000   │
   │ 10 BDs   │  │  cache   │  │  full-text    │  │ ficheiros│
   └──────────┘  └──────────┘  └───────────────┘  └──────────┘
```

**Uma base de dados por serviço** (isolamento total):  
`auth_db` · `catalog_db` · `commerce_db` · `reading_db` · `notification_db`  
`social_db` · `media_db` · `partner_db` · `delivery_db` · `analytics_db`

---

## Deploy em produção (Kubernetes)

```bash
cd ebooks-infra/k8s

# Criar namespace e secrets
kubectl apply -f namespace.yaml
cp secrets.example.yaml secrets.yaml
# editar secrets.yaml com valores reais de produção
kubectl apply -f secrets.yaml

# Deploy com Helm
helm upgrade --install ebooks ./chart \
  -f values/production.yaml \
  --namespace ebooks

# Verificar
kubectl get pods -n ebooks
```

> Ver `k8s/README.md` para configuração detalhada de TLS, ingress e scaling.

---

## Resolução de problemas

**Serviço não arranca:**
```bash
./logs.sh <nome-do-servico>
# Ex: ./logs.sh ebooks-catalog-service
```

**Base de dados inacessível:**
```bash
docker compose -f docker/docker-compose.yml ps postgres
# Verificar se o healthcheck passou
```

**Reset completo (apaga tudo e começa do zero):**
```bash
docker compose -f docker/docker-compose.yml down -v   # apaga volumes
./start.sh --build                                     # rebuild + arrancar
./seed.sh                                              # re-popular
```
