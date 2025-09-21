# 📚 Sistema Escolar – Modelo ER (PostgreSQL + Docker)

Este projeto implementa o modelo entidade-relacionamento da escola do Chaves (com o Professor Girafales agora como diretor 🎓).  
O banco de dados foi construído em **PostgreSQL** rodando em **Docker**, com apoio do **pgAdmin** para visualização.  

Inclui duas consultas principais que o “diretor” precisa:
1. **Carga horária semanal de cada professor**.  
2. **Lista de salas com horários livres e ocupados**.

---

## 🚀 Como usar

### 1. Pré-requisitos
- [Docker](https://docs.docker.com/get-docker/) instalado  
- [Docker Compose](https://docs.docker.com/compose/) (já vem junto nas versões atuais do Docker Desktop)  
- Git instalado (para clonar o repositório)

### 2. Clonar o repositório
```bash
git clone https://github.com/<seu-usuario>/<seu-repositorio>.git
cd <seu-repositorio>/er-school
```

### 3. Subir os containers
O comando a seguir deve ser executado **dentro da pasta `er-school/`** (onde está o `docker-compose.yml`).  
Na primeira execução, o PostgreSQL será inicializado com o **schema** e os **dados de exemplo** que estão em `db/`.

```bash
docker compose up -d
```

Isso vai subir dois serviços:
- **Postgres** → banco de dados em `localhost:5432` (usuário: `admin`, senha: `admin`, banco: `school`)  
- **pgAdmin** → interface web em [http://localhost:8080](http://localhost:8080) (login: `admin@local` / senha: `admin`)  

### 4. Estrutura de pastas
```
er-school/
├─ db/
│  ├─ 01_schema.sql      # Criação do schema (tabelas, constraints, tipos, índices)
│  └─ 02_seed.sql        # Dados de exemplo (departamentos, professores, disciplinas, turmas, horários)
├─ queries/
│  ├─ horas_professor.sql        # Consulta da carga horária semanal por professor
│  └─ salas_livres_ocupadas.sql  # Consulta dos intervalos livres/ocupados por sala
├─ docker-compose.yml
└─ README.md
```

### 5. Executar consultas

Para rodar as queries já prontas:

#### A) Horas por professor
```bash
docker exec -it er_school_pg psql -U admin -d school -f /queries/horas_professor.sql
```

Exemplo de saída:
```
 id |       professor        | horas_semanais
----+------------------------+----------------
  2 | Prof. Jirafales Junior |           4.00
  1 | Prof. Girafales        |           3.33
```

#### B) Salas livres e ocupadas
```bash
docker exec -it er_school_pg psql -U admin -d school -f /queries/salas_livres_ocupadas.sql
```

Exemplo de saída:
```
 room | day_of_week | start_time | end_time | status
------+-------------+------------+----------+---------
 101  | 1           | 07:00:00   | 08:00:00 | livre
 101  | 1           | 08:00:00   | 10:00:00 | ocupado
 101  | 1           | 10:00:00   | 22:00:00 | livre
```

### 6. Resetar o banco
Se precisar recriar tudo do zero (schema + seed):
```bash
docker compose down -v   # derruba containers e apaga volume (dados)
docker compose up -d     # sobe de novo e recria o banco
```

---

## 🛠️ Como funciona

- Os arquivos de **schema** e **seed** em `db/` são executados automaticamente pelo PostgreSQL na **primeira vez que o volume é criado**.  
- O diretório `queries/` é montado no container, permitindo rodar consultas prontas com `psql -f`.  
- O script `salas_livres_ocupadas.sql` utiliza a técnica de **gaps & islands** para consolidar intervalos livres/ocupados, sem depender de slots fixos de tempo.  

---

## 📌 Dados de exemplo

- **Professores:** Prof. Girafales (Português I) e Prof. Jirafales Junior (Cálculo I)  
- **Salas:** 101, 102, 201 em prédios A e B  
- **Turmas:** Português I (Seg e Qua de manhã), Cálculo I (Ter e Qui de manhã)  

Isso garante que as consultas tragam resultados reais logo após a instalação.

---
