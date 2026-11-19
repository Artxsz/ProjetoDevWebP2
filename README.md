# TaskFlow - Gerenciador de Tarefas

**Autor:** Arthur do Vale Rodrigues  
**Curso:** Desenvolvimento de Software Multiplataforma (DSM - V) - Fatec Osasco  
**Repositório:** [https://github.com/Artxsz/ProjetoDevWebP2.git](https://github.com/Artxsz/ProjetoDevWebP2.git)

TaskFlow é uma aplicação multiplataforma de lista de tarefas (To-Do List) desenvolvida com **Flutter** e **Dart**. O aplicativo permite que cada usuário crie uma conta segura, autentique-se e gerencie suas tarefas pessoais com sincronização em tempo real na nuvem por meio do **Supabase**.

---

## 📌 Descrição do Aplicativo

O aplicativo oferece uma interface limpa, responsiva e organizada para o controle de atividades diárias. Todas as tarefas criadas são vinculadas diretamente ao usuário autenticado, utilizando políticas de segurança a nível de linha (*Row Level Security - RLS*) no PostgreSQL para garantir que cada usuário visualize e gerencie exclusivamente os seus próprios registros.

---

## 🚀 Funcionalidades Principais

- **Autenticação Completa:** Cadastro de novos usuários, login com e-mail e senha, manutenção de sessão ativa e logout.
- **Proteção de Telas:** Controle de acesso que impede usuários não autenticados de acessarem a tela principal (`/home`).
- **CRUD Completo de Tarefas:**
  - **Criar (Create):** Adição de novas tarefas com título obrigatório e descrição opcional.
  - **Ler (Read):** Carregamento e listagem das tarefas do usuário autenticado, ordenadas das mais recentes para as mais antigas.
  - **Atualizar (Update):** Edição de título e descrição via formulário modal e marcação rápida de tarefas como concluídas ou pendentes.
  - **Deletar (Delete):** Exclusão permanente de tarefas do banco de dados.
- **Validação e Tratamento de Erros:** Validação de campos vazios, formato de e-mail e tamanho mínimo de senha, além de feedback visual (`SnackBar`) para erros de autenticação ou conexão.

---

## 🛠️ Tecnologias Utilizadas

- **Flutter:** Framework UI para desenvolvimento multiplataforma (Mobile, Web e Desktop).
- **Dart:** Linguagem de programação utilizada na lógica e interface do aplicativo.
- **Supabase Auth:** Serviço de gerenciamento de autenticação e sessão de usuários.
- **Supabase Database (PostgreSQL):** Banco de dados relacional em nuvem para persistência das tarefas.

---

## 📂 Arquitetura do Projeto

O código-fonte está organizado seguindo boas práticas de separação de responsabilidades (UI, Serviços, Modelos e Componentes):

```text
lib/
├── main.dart                  # Inicialização do Supabase, tema e gerenciamento de rotas
├── models/
│   └── task_model.dart        # Modelo de dados da tarefa e serialização (fromMap / toMap)
├── screens/
│   ├── home_screen.dart       # Tela principal protegida (listagem e modal de criação/edição)
│   ├── login_screen.dart      # Tela de login com validação de formulário
│   └── register_screen.dart   # Tela de cadastro de novos usuários
├── services/
│   ├── auth_service.dart      # Serviço de autenticação (signIn, signUp, signOut)
│   └── database_service.dart  # Serviço de banco de dados (operações de CRUD na tabela tasks)
└── widgets/
    └── task_tile.dart         # Componente visual reutilizável para exibição de cada tarefa
```

---

## 🔐 Descrição da Autenticação e Base de Dados

- **Autenticação (`AuthService`):** Utiliza o `Supabase Auth` com provedor de e-mail e senha. Ao iniciar o aplicativo, a sessão atual é verificada (`currentSession`) para redirecionar automaticamente o usuário para `/home` (se autenticado) ou `/login` (se não autenticado).
- **Base de Dados (`DatabaseService`):** Realiza as operações de CRUD na tabela `public.tasks` hospedada no Supabase. Cada registro contém `id` (UUID), `user_id` (UUID referenciando `auth.users`), `title` (texto), `description` (texto), `is_done` (booleano) e `created_at` (timestamp).

### Estrutura SQL da Tabela e Políticas RLS (Supabase)

```sql
create table if not exists public.tasks (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users(id) on delete cascade not null,
  title text not null,
  description text default '',
  is_done boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.tasks enable row level security;

create policy "Usuarios gerenciam suas proprias tarefas"
on public.tasks for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);
```

---

## ▶️ Instruções para Executar o Projeto

> **Nota para avaliação:** As credenciais de conexão com o projeto no Supabase (`url` e `publishableKey`) já estão configuradas no arquivo `lib/main.dart`. Não é necessário criar ou configurar um banco externo para testar a aplicação.

1. **Clone o repositório:**
   ```bash
   git clone [https://github.com/Artxsz/ProjetoDevWebP2.git](https://github.com/Artxsz/ProjetoDevWebP2.git)
   cd ProjetoDevWebP2
   ```

2. **Instale as dependências do Flutter:**
   ```bash
   flutter pub get
   ```

3. **Execute a aplicação:**
   - Para executar no navegador Chrome ou dispositivo padrão:
     ```bash
     flutter run
     ```
   - Para executar em qualquer navegador via servidor web local (`localhost`):
     ```bash
     flutter run -d web-server --web-port 8080
     ```
     Em seguida, abra o navegador em `http://localhost:8080`.

4. **Testando o aplicativo:**
   - Na tela inicial de login, clique em **"Não tem uma conta? Cadastre-se"** para criar um novo usuário com qualquer e-mail válido e senha (mínimo de 6 caracteres), realizando o acesso imediato à tela de tarefas.