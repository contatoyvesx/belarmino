# ---------------------------
# 1) Dependências (cacheável)
# ---------------------------
FROM node:20-alpine AS deps
WORKDIR /app

# Habilita PNPM via Corepack
RUN corepack enable

# Copia somente os arquivos do PNPM (melhor cache)
COPY package.json pnpm-lock.yaml ./

# Instala dependências SEM frozen-lockfile
RUN pnpm install --no-frozen-lockfile


# ---------------------------
# 2) Build da aplicação
# ---------------------------
FROM node:20-alpine AS builder
WORKDIR /app

RUN corepack enable

# Copia node_modules do stage anterior
COPY --from=deps /app/node_modules ./node_modules

# Copia todo o projeto
COPY . .

# Build do frontend (ou do seu app)
RUN pnpm run build


# ---------------------------
# 3) Runner — apenas arquivos estáticos
# ---------------------------
FROM node:20-alpine AS runner
WORKDIR /app

# Copia apenas o resultado final (dist)
COPY --from=builder /app/dist ./dist

# Instala um servidor estático simples (caso precise)
RUN npm install -g serve

EXPOSE 3000

# Comando para servir a aplicação
CMD ["serve", "-s", "dist", "-l", "3000"]
