# wib

Aplicativo simplificado de orçamento e gestão de carteira de investimentos.

## Stack

| Parte | Tecnologia |
|---|---|
| Backend | Java 25, Spring Boot 4, Spring Modulith, Maven (wrapper incluso) |
| Frontend | React + TypeScript, Vite, Node 26 |
| Integração bancária | [Pluggy](https://pluggy.ai) |

## Estrutura

```
wib/
├── backend/    API Spring Boot
├── frontend/   SPA React
└── openspec/   Specs e changes (OpenSpec)
```

## Pré-requisitos

- **Java 25**
- **Node 26** via [nvm](https://github.com/nvm-sh/nvm) (a versão está fixada em `frontend/.nvmrc`)
- **Docker** com Docker Compose (para o PostgreSQL)

O Maven não precisa ser instalado: use o `./mvnw` dentro de `backend/`.

## Configuração

Cada aplicação tem o próprio `.env`, que não é versionado. Copie os exemplos e preencha:

```bash
cp backend/.env.example backend/.env
```

> Segredos (como as credenciais da Pluggy) ficam **apenas** no backend. Variáveis do frontend (`VITE_*`) são públicas e vão para o navegador.

## Rodando em desenvolvimento

**Banco de dados** (PostgreSQL 18, porta 5432), a partir da raiz do repositório:

```bash
docker compose up -d     # liga o banco
docker compose stop      # desliga, mantendo os dados
docker compose down -v   # apaga o container e os dados
```

**Backend** (porta 8080, requer o banco no ar):

```bash
cd backend
./mvnw spring-boot:run
```

**Frontend** (porta 5173):

```bash
cd frontend
nvm use
npm install
npm run dev
```

Acesse http://localhost:5173. Em desenvolvimento, o Vite repassa as requisições para `/api` ao backend em `localhost:8080`, então não é preciso configurar CORS.

## Imagem de produção

O `Dockerfile` na raiz gera uma imagem única: o build do frontend é servido pelo próprio Spring Boot, então SPA e `/api` ficam na mesma origem. A configuração vem por variáveis de ambiente (as mesmas do `backend/.env.example`).

```bash
docker build -t wib .
docker run -p 8080:8080 \
  -e DB_URL=jdbc:postgresql://<host>:5432/wib -e DB_USER=wib -e DB_PASSWORD=... \
  -e PLUGGY_CLIENT_ID=... -e PLUGGY_CLIENT_SECRET=... \
  wib
```

Health check: `GET /actuator/health`.

## Testes

```bash
cd backend && ./mvnw test      # requer o banco no ar; inclui a verificação de módulos do Spring Modulith
cd frontend && npm run lint
```
