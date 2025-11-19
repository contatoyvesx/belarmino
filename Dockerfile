# ---------------------------
# 1) Build da aplicação
# ---------------------------
FROM node:20-alpine AS builder
WORKDIR /app

RUN corepack enable

COPY package.json pnpm-lock.yaml ./
RUN pnpm install --no-frozen-lockfile

COPY . .
RUN pnpm run build  # gera o dist

# ---------------------------
# 2) Servidor NGINX
# ---------------------------
FROM nginx:stable-alpine AS runner
WORKDIR /usr/share/nginx/html

# Remove conteúdo padrão do nginx
RUN rm -rf ./*

# Copia os arquivos estáticos do dist
COPY --from=builder /app/dist ./

# Copia configuração otimizada para SPA (importante p/ rotas)
COPY <<EOF /etc/nginx/conf.d/default.conf
server {
    listen 80;
    server_name _;

    root /usr/share/nginx/html;

    location / {
        try_files \$uri /index.html;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|svg|ico|webp)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
EOF

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
